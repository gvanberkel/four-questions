import 'dart:async';

import 'package:flutter/material.dart';
import 'package:four_questions/auth/account.dart';
import 'package:four_questions/auth/browser.dart';
import 'package:four_questions/auth/google_auth.dart';
import 'package:four_questions/auth/sign_in_service.dart';
import 'package:four_questions/check_in/check_in_store.dart';
import 'package:four_questions/config.dart';
import 'package:four_questions/data/local_store.dart';
import 'package:four_questions/data/sheets_gateway.dart';
import 'package:four_questions/model/local_day.dart';
import 'package:four_questions/model/question.dart';

enum AppStage {
  /// No one is signed in, or their sign-in needs a tap to renew.
  signedOut,

  /// On the way to Google for a fresh token.
  renewing,

  /// Waiting for the sheet the first time, with nothing on the device.
  loading,

  /// The first load failed and there is nothing on the device to show.
  failed,

  /// The account may not edit the sheet.
  noAccess,

  /// A first sign-in: asking the name the person goes by.
  welcome,

  question,
  summary,
}

/// Which screen the app is on and everything that moves it: signing in,
/// renewing the token, checking access, and the walk through the questions.
class AppController extends ChangeNotifier {
  AppController({
    required this.local,
    required this.signIn,
    required this.browser,
    required this.openGateway,
    DateTime Function()? now,
    this._today,
  })  : _now = now ?? DateTime.now,
        themeMode = ValueNotifier(local.themeMode);

  final LocalStore local;
  final SignInService signIn;
  final Browser browser;

  /// The sheet, reached with whichever token is current.
  final SheetsGateway Function(String? Function() token) openGateway;

  final DateTime Function() _now;
  final LocalDay Function()? _today;

  final ValueNotifier<ThemeMode> themeMode;

  /// The name being typed on the welcome screen.
  String nameDraft = '';

  Account? _account;
  AccessToken? _token;
  String? _signInMessage;
  bool _renewing = false;

  CheckInStore? _store;
  bool? _canEdit;
  String? _accessMessage;
  Object? _accessError;

  int? _index;
  bool _forward = true;
  bool _seenSummary = false;
  LocalDay? _placedFor;

  final _subscriptions = <StreamSubscription<void>>[];

  /// Renew a token this close to expiry before it is needed.
  static const _renewMargin = Duration(minutes: 5);
  static const _silentKey = 'fq.silentAt';
  static const _viewKey = 'fq.view';

  Account? get account => _account;
  String? get signInMessage => _signInMessage;
  bool get signInConfigured => signIn.configured;
  String? get accessMessage => _accessMessage;
  CheckInStore? get store => _store;

  int? get questionIndex => _index;
  bool get forward => _forward;

  /// Whether the question screen offers a way back to the summary.
  bool get canShowSummary => _seenSummary || (_store?.allAnswered ?? false);

  Question? get currentQuestion {
    final questions = _store?.questions ?? const [];
    final i = _index;
    return i == null || i >= questions.length ? null : questions[i];
  }

  AppStage get stage {
    if (_renewing) return AppStage.renewing;
    final store = _store;
    if (_account == null || store == null) return AppStage.signedOut;
    if (_canEdit == false) return AppStage.noAccess;
    if (!store.hasData || _canEdit == null) {
      final failed =
          (!store.hasData && store.refreshError != null && !store.refreshing) ||
              (_canEdit == null && _accessError != null);
      return failed ? AppStage.failed : AppStage.loading;
    }
    if (store.needsName) return AppStage.welcome;
    return currentQuestion == null ? AppStage.summary : AppStage.question;
  }

  /// Why the first load failed.
  Object? get failure => _store?.refreshError ?? _accessError;

  /// Reads any answer from Google in the address bar, then signs in, renews
  /// or shows the sign-in screen.
  void start() {
    _subscriptions
      ..add(browser.onVisible.listen((_) => _onVisible()))
      ..add(browser.onOnline.listen((_) => _store?.flush()));
    _takeSignIn();
    _resume();
  }

  void _takeSignIn() {
    final result = signIn.takeResult();
    switch (result) {
      case SignedIn(:final account, :final token):
        if (local.account?.email.toLowerCase() != account.email.toLowerCase()) {
          local.forgetPerson();
        }
        local
          ..account = account
          ..token = token;
        browser.setSessionValue(_silentKey, null);
        _signInMessage = null;
      case SignInFailed(silent: true):
        // Google needs to ask something: the sign-in screen offers the tap.
        _signInMessage = null;
      case SignInFailed(:final reason) when reason == SignInFailed.stale:
        break;
      case SignInFailed(:final declined) when declined:
        _signInMessage = 'Sign-in was cancelled.';
      case SignInFailed(:final reason)
          when reason == SignInFailed.sheetsNotGranted:
        _signInMessage = 'Four Questions needs your permission to see and '
            'edit Google Sheets, to read the questions and save your '
            'answers. Please tick that box when Google asks.';
      case SignInFailed(:final reason):
        _signInMessage = 'Google sign-in did not work ($reason). Try again.';
      case null:
        break;
    }
  }

  void _resume() {
    _account = local.account;
    _token = local.token;
    final account = _account;
    final token = _token;

    if (account == null) {
      _closeStore();
    } else if (token != null && token.isFreshAt(_now())) {
      _openStore(account);
      if (!token.isFreshAt(_now(), margin: _renewMargin)) _renewSilently();
    } else if (!_renewSilently()) {
      _closeStore();
    }
    notifyListeners();
  }

  /// A `prompt=none` round trip to Google, at most once a minute so a refusal
  /// cannot loop. False when it was not attempted.
  bool _renewSilently() {
    final account = _account;
    if (account == null || !signIn.configured) return false;
    final last = int.tryParse(browser.sessionValue(_silentKey) ?? '');
    final now = _now().millisecondsSinceEpoch;
    if (last != null && now - last < const Duration(minutes: 1).inMilliseconds) {
      return false;
    }
    browser.setSessionValue(_silentKey, '$now');
    _rememberView();
    _renewing = true;
    notifyListeners();
    signIn.signIn(prompt: SignInPrompt.none, loginHint: account.email);
    _afterSignIn();
    return true;
  }

  /// The sign-in screen's button.
  void signInWithGoogle({bool chooseAccount = false}) {
    _signInMessage = null;
    signIn.signIn(
      prompt: chooseAccount ? SignInPrompt.chooseAccount : SignInPrompt.auto,
      loginHint: chooseAccount ? null : local.account?.email,
    );
    _afterSignIn();
  }

  // Google navigates away, so for it nothing more happens here; the demo
  // signs in on the spot.
  void _afterSignIn() {
    final result = signIn.takeResult();
    if (result == null) return;
    _renewing = false;
    if (result is SignedIn) {
      if (local.account?.email.toLowerCase() !=
          result.account.email.toLowerCase()) {
        _closeStore();
        local.forgetPerson();
      }
      local
        ..account = result.account
        ..token = result.token;
    }
    _resume();
  }

  void signOut() {
    _closeStore();
    local.forgetPerson();
    browser.setSessionValue(_silentKey, null);
    _account = null;
    _token = null;
    _signInMessage = null;
    notifyListeners();
  }

  void useAnotherAccount() {
    signOut();
    signInWithGoogle(chooseAccount: true);
  }

  void _openStore(Account account) {
    final existing = _store;
    if (existing != null && existing.me.email == account.email) {
      existing.resume();
      return;
    }
    _closeStore();

    final gateway = openGateway(() => _token?.value);
    final store = CheckInStore(
      local: local,
      gateway: gateway,
      me: account,
      today: _today,
      onAuthExpired: _onAuthExpired,
      onAccessDenied: _onAccessDenied,
    )..addListener(_onStoreChanged);
    _store = store;

    _canEdit = local.confirmedEditor?.toLowerCase() == account.email.toLowerCase()
        ? true
        : null;
    nameDraft = account.firstName;
    _accessError = null;
    _restoreView();
    unawaited(store.start());
    unawaited(_checkAccess(gateway, account));
  }

  Future<void> _checkAccess(SheetsGateway gateway, Account account) async {
    try {
      final ok = await gateway.canEdit();
      if (_store?.me != account) return;
      if (ok) {
        _canEdit = true;
        local.confirmedEditor = account.email;
      } else {
        _onAccessDenied('This account can see the sheet but not edit it.');
      }
    } on SheetsAuthException {
      _onAuthExpired();
    } on SheetsAccessException catch (e) {
      _onAccessDenied(e.message);
    } on Object catch (e) {
      _accessError = e;
    }
    notifyListeners();
  }

  void _onAccessDenied(String message) {
    _canEdit = false;
    _accessMessage = message;
    local.confirmedEditor = null;
    notifyListeners();
  }

  void _onAuthExpired() {
    _token = null;
    local.token = null;
    if (!_renewSilently()) notifyListeners();
  }

  void _closeStore() {
    _store
      ?..removeListener(_onStoreChanged)
      ..dispose();
    _store = null;
    _canEdit = null;
    _accessMessage = null;
    _accessError = null;
    _placedFor = null;
    _index = null;
    _seenSummary = false;
  }

  /// Retry after a failed first load.
  void retry() {
    final store = _store;
    final account = _account;
    if (store == null || account == null) return;
    _accessError = null;
    unawaited(store.refresh());
    if (_canEdit == null) {
      unawaited(_checkAccess(openGateway(() => _token?.value), account));
    }
    notifyListeners();
  }

  void refresh() => _store?.refresh();

  void openSheet() => browser.openInNewTab(AppConfig.spreadsheetUrl);

  void _onStoreChanged() {
    final store = _store!;
    if (store.hasData && _placedFor != store.day) {
      _placedFor = store.day;
      _place(store);
    }
    final count = store.questions.length;
    if (_index != null && _index! >= count) _index = count == 0 ? null : count - 1;
    notifyListeners();
  }

  /// Opens on the first question not yet answered today, or on the summary
  /// when there is none.
  void _place(CheckInStore store) {
    if (_index != null) return;
    final questions = store.questions;
    final first = questions.indexWhere((q) => !store.isAnswered(q));
    _index = first < 0 ? null : first;
    _forward = true;
    if (first < 0) _seenSummary = true;
  }

  void _onVisible() {
    final store = _store;
    if (store == null) return;
    final token = _token;
    if (token == null || !token.isFreshAt(_now(), margin: _renewMargin)) {
      if (_renewSilently()) return;
    }
    final day = store.day;
    store.checkDay();
    if (store.day != day) {
      _index = null;
      _placedFor = null;
      _seenSummary = false;
    }
    unawaited(store.flush());
  }

  void next() {
    final i = _index;
    if (i == null) return;
    unawaited(_store?.flush());
    _forward = true;
    if (i + 1 >= (_store?.questions.length ?? 0)) {
      showSummary();
    } else {
      _index = i + 1;
      notifyListeners();
    }
  }

  void back() {
    final i = _index;
    if (i == null || i == 0) return;
    unawaited(_store?.flush());
    _forward = false;
    _index = i - 1;
    notifyListeners();
  }

  void goToQuestion(int index) {
    final count = _store?.questions.length ?? 0;
    if (index < 0 || index >= count) return;
    unawaited(_store?.flush());
    _forward = _index == null || index >= _index!;
    _index = index;
    notifyListeners();
  }

  void edit(Question question) {
    final index = _store?.questions.indexOf(question) ?? -1;
    if (index >= 0) goToQuestion(index);
  }

  void showSummary() {
    unawaited(_store?.flush());
    _index = null;
    _seenSummary = true;
    notifyListeners();
  }

  void setThemeMode(ThemeMode mode) {
    themeMode.value = mode;
    local.themeMode = mode;
  }

  void setNameDraft(String value) {
    nameDraft = value;
    notifyListeners();
  }

  void saveName() {
    final name = nameDraft.trim();
    if (name.isEmpty) return;
    _store?.saveName(name);
  }

  /// Asks the sheet again whether this account may edit it.
  void recheckAccess() {
    final account = _account;
    if (account == null || _store == null) return;
    _canEdit = null;
    _accessMessage = null;
    _accessError = null;
    notifyListeners();
    unawaited(_checkAccess(openGateway(() => _token?.value), account));
    unawaited(_store!.refresh());
  }

  // Where the person was survives a token-renewing round trip to Google.
  // Renewing before anything is open leaves an earlier record alone.
  void _rememberView() {
    final store = _store;
    if (store == null || !store.hasData) return;
    browser.setSessionValue(_viewKey, '${store.day.iso}|${_index ?? 'summary'}');
  }

  void _restoreView() {
    final saved = browser.sessionValue(_viewKey);
    browser.setSessionValue(_viewKey, null);
    final parts = saved?.split('|');
    if (parts == null || parts.length != 2) return;
    final day = LocalDay.tryParse(parts[0]);
    if (day == null || day != (_today ?? () => LocalDay.of(_now()))()) return;
    _placedFor = day;
    _index = int.tryParse(parts[1]);
    _seenSummary = _index == null;
  }

  @override
  void dispose() {
    for (final s in _subscriptions) {
      s.cancel();
    }
    _closeStore();
    themeMode.dispose();
    super.dispose();
  }
}
