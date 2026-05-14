import 'package:flutter/material.dart';

class CrescentPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = const Color(0xFF2E7D32);
    final outerCenter = Offset(size.width * 0.54, size.height * 0.55);
    final outerRadius = size.width * 0.38;

    canvas.saveLayer(Offset.zero & size, Paint());
    canvas.drawCircle(outerCenter, outerRadius, paint);

    final clearPaint = Paint()..blendMode = BlendMode.clear;
    final innerCenter = outerCenter + Offset(size.width * 0.18, -size.height * 0.12);
    final innerRadius = outerRadius * 0.8;
    canvas.drawCircle(innerCenter, innerRadius, clearPaint);
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
