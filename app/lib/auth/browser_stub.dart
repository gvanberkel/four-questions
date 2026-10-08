import 'package:four_questions/auth/browser.dart';

/// Off the web there is no window; this one stays where it is.
class PlatformBrowser implements Browser {
  final _session = <String, String>{};

  @override
  Uri get location => Uri.parse('http://localhost/');

  @override
  void replaceLocation(Uri uri) {}

  @override
  void navigateTo(Uri uri) {}

  @override
  void openInNewTab(Uri uri) {}

  @override
  String? sessionValue(String key) => _session[key];

  @override
  void setSessionValue(String key, String? value) =>
      value == null ? _session.remove(key) : _session[key] = value;

  @override
  Stream<void> get onVisible => const Stream.empty();

  @override
  Stream<void> get onOnline => const Stream.empty();
}
