import 'package:flutter/widgets.dart';
import 'package:four_questions/splash/splash_stub.dart'
    if (dart.library.js_interop) 'package:four_questions/splash/splash_web.dart'
    as splash;

/// Marks the first frame worth showing, and takes the HTML splash down at it.
///
/// The splash (`web/index.html`) draws the question screen in grey with the
/// mark in the bar, and it is up before the engine exists. The engine's own
/// first frames are *not* the moment to reveal: a token being renewed by a
/// round trip to Google, or a first visit still waiting on the sheet, would
/// replace a full screen with a spinner — a step backwards, then forwards
/// again. Those stages stay behind the splash (see `Application`), and the
/// splash comes down where the app first has something real: a question, the
/// summary, the welcome, the sign-in screen, or an error to act on.
///
/// Wrapping rather than calling: a widget can only know it has been built,
/// and `initState` gives us that once rather than on every rebuild.
class SplashHandoff extends StatefulWidget {
  const SplashHandoff({super.key, required this.child});

  final Widget child;

  @override
  State<SplashHandoff> createState() => _SplashHandoffState();
}

class _SplashHandoffState extends State<SplashHandoff> {
  @override
  void initState() {
    super.initState();
    // After this frame, never during it: the splash must not come down onto
    // a window Flutter has built but not yet painted.
    WidgetsBinding.instance.addPostFrameCallback((_) => splash.dismissSplash());
  }

  @override
  Widget build(BuildContext context) => widget.child;
}

/// The splash normally comes down at the first real screen
/// ([SplashHandoff]). This is the case where none arrives — a Google round
/// trip or a sheet that never answers — and the splash would otherwise sit
/// over the app for good. The spinner underneath is better than a frozen page.
void holdSplashNoLongerThan(Duration limit) =>
    Future<void>.delayed(limit, splash.dismissSplash);
