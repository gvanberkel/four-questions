import 'dart:async';

import 'package:web/web.dart' as web;

/// Takes down the HTML splash in `web/index.html`.
///
/// The splash is markup, not Flutter: it is on screen within milliseconds of
/// the first byte of the document, long before the engine has downloaded,
/// which is the whole reason it exists. That means it can only be dismissed
/// from the document too — the app asks for it, the page does it.
///
/// Two steps rather than one `remove()`: the class starts the fade the
/// stylesheet describes, and the element leaves the document once the fade is
/// over. Removing it outright would cut the greyed-out screen away in a
/// single frame, which reads as a flicker.
const String _elementId = 'fq-splash';
const String _doneClass = 'is-done';

/// Matches the transition in `web/index.html`. Shorter and the element would
/// vanish mid-fade; longer and it sits over a live app, swallowing taps.
const Duration _fade = Duration(milliseconds: 220);

/// Safe to call more than once, and when there is no splash — a page served
/// from an older cached `index.html` simply has nothing to take down.
void dismissSplash() {
  final element = web.document.getElementById(_elementId);
  if (element == null) return;
  element.classList.add(_doneClass);
  // A closure, not a tear-off: `remove()` is an interop member and the web
  // compilers refuse to tear one off.
  Timer(_fade, () => element.remove());
}
