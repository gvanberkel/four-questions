import 'package:flutter/material.dart';

enum ActionTone {
  neutral,

  accent,

  positive,

  attention,
}

typedef ActionToneColors = ({
  Color foreground,
  Color background,
  Color emphasis,
});

extension ActionToneResolution on ActionTone {
  ActionToneColors resolve(ColorScheme scheme) => switch (this) {
        ActionTone.neutral => (
            foreground: scheme.onSecondaryContainer,
            background: scheme.secondaryContainer,
            emphasis: scheme.outline,
          ),
        ActionTone.accent => (
            foreground: scheme.onPrimaryContainer,
            background: scheme.primaryContainer,
            emphasis: scheme.primary,
          ),
        ActionTone.positive => (
            foreground: scheme.onTertiaryContainer,
            background: scheme.tertiaryContainer,
            emphasis: scheme.tertiary,
          ),
        ActionTone.attention => (
            foreground: scheme.onErrorContainer,
            background: scheme.errorContainer,
            emphasis: scheme.error,
          ),
      };
}
