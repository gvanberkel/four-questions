import 'dart:async';

import 'package:four_questions/auth/browser.dart';
import 'package:web/web.dart' as web;

class PlatformBrowser implements Browser {
  @override
  Uri get location => Uri.parse(web.window.location.href);

  @override
  void replaceLocation(Uri uri) =>
      web.window.history.replaceState(null, '', uri.toString());

  @override
  void navigateTo(Uri uri) => web.window.location.assign(uri.toString());

  @override
  void openInNewTab(Uri uri) =>
      web.window.open(uri.toString(), '_blank', 'noopener');

  @override
  String? sessionValue(String key) => web.window.sessionStorage.getItem(key);

  @override
  void setSessionValue(String key, String? value) => value == null
      ? web.window.sessionStorage.removeItem(key)
      : web.window.sessionStorage.setItem(key, value);

  @override
  Stream<void> get onVisible => web.CustomEventProviders.visibilityChangeEvent
      .forTarget(web.document)
      .where((_) => web.document.visibilityState == 'visible');

  @override
  Stream<void> get onOnline =>
      web.EventStreamProviders.onlineEvent.forTarget(web.window);
}
