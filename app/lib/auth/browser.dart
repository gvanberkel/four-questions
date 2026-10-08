import 'package:four_questions/auth/browser_stub.dart'
    if (dart.library.js_interop) 'package:four_questions/auth/browser_web.dart'
    as platform;

/// The few things sign-in and the shell need from the browser window, behind
/// an interface so they can be tested off the web.
abstract interface class Browser {
  factory Browser() = platform.PlatformBrowser;

  Uri get location;

  /// Changes the address bar without loading anything.
  void replaceLocation(Uri uri);

  /// Leaves the app for [uri].
  void navigateTo(Uri uri);

  void openInNewTab(Uri uri);

  /// Kept for this tab only, across a round trip to another site.
  String? sessionValue(String key);
  void setSessionValue(String key, String? value);

  /// Fires when the tab comes back into view.
  Stream<void> get onVisible;

  /// Fires when the device regains its network connection.
  Stream<void> get onOnline;
}
