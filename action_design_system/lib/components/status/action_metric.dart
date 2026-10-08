import 'package:flutter/material.dart';
import 'package:action_design_system/components/page/action_section_header.dart';
import 'package:action_design_system/foundations/tokens/action_spacing.dart';

class ActionMetric extends StatelessWidget {
  const ActionMetric({
    super.key,
    required this.label,
    required this.value,
    this.unit,
    this.caption,
    this.delta,
    this.compact = false,
  });

  final String label;
  final String value;
  final String? unit;
  final String? caption;

  final Widget? delta;

  final bool compact;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final valueText = Text.rich(
      TextSpan(
        text: value,
        children: unit == null
            ? null
            : [
                TextSpan(
                  text: ' $unit',
                  style: theme.textTheme.bodySmall?.copyWith(fontSize: 12),
                ),
              ],
      ),
      style: compact
          ? theme.textTheme.titleMedium?.copyWith(fontSize: 15)
          : theme.textTheme.headlineMedium?.copyWith(fontSize: 28, height: 1),
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        ActionEyebrow(label),
        SizedBox(height: compact ? 2 : ActionSpacing.xs),
        if (delta == null)
          valueText
        else
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            mainAxisSize: MainAxisSize.min,
            children: [
              valueText,
              const SizedBox(width: ActionSpacing.sm - 2),
              delta!,
            ],
          ),
        if (caption != null) ...[
          const SizedBox(height: ActionSpacing.xs),
          Text(caption!, style: theme.textTheme.bodySmall),
        ],
      ],
    );
  }
}

class ActionTrendLine extends StatelessWidget {
  const ActionTrendLine({
    super.key,
    required this.values,
    this.width = 146,
    this.height = 56,
    this.startLabel,
    this.endLabel,
    this.highlightLast = true,
  });

  final List<double> values;
  final double width;
  final double height;

  final String? startLabel;
  final String? endLabel;

  final bool highlightLast;

  @override
  Widget build(BuildContext context) {
    if (values.length < 2) return const SizedBox.shrink();
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return ExcludeSemantics(
      child: SizedBox(
        width: width,
        height: height,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: CustomPaint(
                painter: _TrendPainter(
                  values: values,
                  line: scheme.primary,
                  guide: scheme.outlineVariant,
                  highlight: highlightLast ? scheme.error : scheme.primary,
                ),
              ),
            ),
            if (startLabel != null || endLabel != null) ...[
              const SizedBox(height: ActionSpacing.xs),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(startLabel ?? '', style: theme.textTheme.labelSmall),
                  Text(endLabel ?? '', style: theme.textTheme.labelSmall),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _TrendPainter extends CustomPainter {
  _TrendPainter({
    required this.values,
    required this.line,
    required this.guide,
    required this.highlight,
  });

  final List<double> values;
  final Color line;
  final Color guide;
  final Color highlight;

  @override
  void paint(Canvas canvas, Size size) {
    final lowest = values.reduce((a, b) => a < b ? a : b);
    final highest = values.reduce((a, b) => a > b ? a : b);
    final span = highest - lowest;
    const inset = 6.0;
    final usable = size.height - inset * 2;

    double x(int i) => size.width * i / (values.length - 1);
    double y(double v) =>
        span == 0 ? size.height / 2 : inset + usable - ((v - lowest) / span) * usable;

    canvas.drawLine(
      Offset(0, size.height - 2),
      Offset(size.width, size.height - 2),
      Paint()
        ..color = guide
        ..strokeWidth = 1,
    );

    final path = Path()..moveTo(x(0), y(values.first));
    for (var i = 1; i < values.length; i++) {
      path.lineTo(x(i), y(values[i]));
    }
    canvas.drawPath(
      path,
      Paint()
        ..color = line
        ..strokeWidth = 2
        ..strokeJoin = StrokeJoin.round
        ..style = PaintingStyle.stroke,
    );

    for (var i = 0; i < values.length; i++) {
      final last = i == values.length - 1;
      canvas.drawCircle(
        Offset(x(i).clamp(3.0, size.width - 3), y(values[i])),
        last ? 4 : 3,
        Paint()..color = last ? highlight : line,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _TrendPainter old) =>
      old.values != values || old.line != line || old.highlight != highlight;
}
