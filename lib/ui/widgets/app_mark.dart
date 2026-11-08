import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../theme/palette.dart';

/// App mark: a donut ring – the dashboard's spending chart – on a deep
/// glaucous tile. Same geometry as the launcher icon.
class AppMark extends StatelessWidget {
  const AppMark({super.key, this.size = 72});

  final double size;

  @override
  Widget build(BuildContext context) => SizedBox.square(dimension: size, child: CustomPaint(painter: _MarkPainter()));
}

class _MarkPainter extends CustomPainter {
  static const tile = Color(0xFF4E5D52);
  static const arcs = [
    (Color(0xFFF7F3EA), -90.0, 150.0),
    (Palette.creamYellow, 96.0, 72.0),
    (Palette.greenYellowBright, 204.0, 30.0),
  ];

  @override
  void paint(Canvas canvas, Size size) {
    final s = size.width;
    canvas.drawRRect(
      RRect.fromRectAndRadius(Offset.zero & size, Radius.circular(s * 0.24)),
      Paint()..color = tile,
    );
    final r = s * 0.215;
    final rect = Rect.fromCircle(center: Offset(s / 2, s / 2), radius: r);
    for (final (color, start, sweep) in arcs) {
      canvas.drawArc(
        rect,
        start * math.pi / 180,
        sweep * math.pi / 180,
        false,
        Paint()
          ..color = color
          ..style = PaintingStyle.stroke
          ..strokeWidth = s * 0.108
          ..strokeCap = StrokeCap.round,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
