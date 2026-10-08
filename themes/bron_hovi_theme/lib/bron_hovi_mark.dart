import 'package:flutter/widgets.dart';

class BronHoviMark extends StatelessWidget {
  const BronHoviMark({
    super.key,
    required this.size,
    required this.selfColor,
    required this.partnerColor,
  });

  final double size;

  final Color selfColor;

  final Color partnerColor;

  @override
  Widget build(BuildContext context) {
    return ExcludeSemantics(
      child: CustomPaint(
        size: Size.square(size),
        painter: _RingsPainter(selfColor: selfColor, partnerColor: partnerColor),
      ),
    );
  }
}

class _RingsPainter extends CustomPainter {
  _RingsPainter({required this.selfColor, required this.partnerColor});

  final Color selfColor;
  final Color partnerColor;

  static const double _radius = 0.28;
  static const double _stroke = 0.11;
  static const double _offset = 0.16;

  @override
  void paint(Canvas canvas, Size size) {
    final side = size.shortestSide;
    final centre = Offset(size.width / 2, size.height / 2);
    final radius = side * _radius;
    final offset = Offset(side * _offset, 0);

    Paint ring(Color color) => Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = side * _stroke
      ..color = color;

    canvas.drawCircle(centre + offset, radius, ring(partnerColor));
    canvas.drawCircle(centre - offset, radius, ring(selfColor));
  }

  @override
  bool shouldRepaint(covariant _RingsPainter oldDelegate) =>
      oldDelegate.selfColor != selfColor ||
      oldDelegate.partnerColor != partnerColor;
}
