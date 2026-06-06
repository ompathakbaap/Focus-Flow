import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class TimerPainter extends CustomPainter {
  final double progress; // 0.0 to 1.0
  final Color accentColor;
  final Color glowColor;
  final bool isRunning;

  TimerPainter({
    required this.progress,
    required this.accentColor,
    required this.glowColor,
    required this.isRunning,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = math.min(size.width, size.height) / 2 - 16;

    // Track background
    final trackPaint = Paint()
      ..color = AppTheme.border
      ..style = PaintingStyle.stroke
      ..strokeWidth = 6
      ..strokeCap = StrokeCap.round;

    canvas.drawCircle(center, radius, trackPaint);

    // Tick marks
    _drawTickMarks(canvas, center, radius, size);

    // Glow layer (only when running)
    if (isRunning && progress > 0) {
      final glowPaint = Paint()
        ..color = glowColor
        ..style = PaintingStyle.stroke
        ..strokeWidth = 14
        ..strokeCap = StrokeCap.round
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8);

      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        -math.pi / 2,
        2 * math.pi * progress,
        false,
        glowPaint,
      );
    }

    // Progress arc
    if (progress > 0) {
      final progressPaint = Paint()
        ..color = accentColor
        ..style = PaintingStyle.stroke
        ..strokeWidth = 6
        ..strokeCap = StrokeCap.round;

      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        -math.pi / 2,
        2 * math.pi * progress,
        false,
        progressPaint,
      );

      // End dot
      final angle = -math.pi / 2 + 2 * math.pi * progress;
      final dotX = center.dx + radius * math.cos(angle);
      final dotY = center.dy + radius * math.sin(angle);

      final dotPaint = Paint()..color = accentColor;
      canvas.drawCircle(Offset(dotX, dotY), 5, dotPaint);
    }
  }

  void _drawTickMarks(Canvas canvas, Offset center, double radius, Size size) {
    const totalTicks = 60;
    for (int i = 0; i < totalTicks; i++) {
      final angle = (i / totalTicks) * 2 * math.pi - math.pi / 2;
      final isMajor = i % 5 == 0;
      final tickLength = isMajor ? 10.0 : 5.0;
      final tickRadius = radius + 12;

      final startX = center.dx + (tickRadius - tickLength) * math.cos(angle);
      final startY = center.dy + (tickRadius - tickLength) * math.sin(angle);
      final endX = center.dx + tickRadius * math.cos(angle);
      final endY = center.dy + tickRadius * math.sin(angle);

      final tickPaint = Paint()
        ..color = isMajor
            ? AppTheme.textTertiary
            : AppTheme.textTertiary.withOpacity(0.3)
        ..strokeWidth = isMajor ? 1.5 : 0.8
        ..strokeCap = StrokeCap.round;

      canvas.drawLine(Offset(startX, startY), Offset(endX, endY), tickPaint);
    }
  }

  @override
  bool shouldRepaint(TimerPainter oldDelegate) =>
      oldDelegate.progress != progress ||
      oldDelegate.isRunning != isRunning ||
      oldDelegate.accentColor != accentColor;
}
