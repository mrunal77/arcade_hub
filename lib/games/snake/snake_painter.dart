import 'dart:math';
import 'package:flutter/material.dart';
import '../../core/game_engine.dart';
import 'snake_game.dart';

class SnakePainter extends CustomPainter {
  final SnakeGameModule game;
  final double animationValue;

  SnakePainter({required this.game, this.animationValue = 0.0});

  @override
  void paint(Canvas canvas, Size size) {
    final cellWidth = size.width / SnakeGameModule.gridWidth;
    final cellHeight = size.height / SnakeGameModule.gridHeight;

    // Background grid lines
    final gridPaint = Paint()
      ..color = const Color(0x1500E676)
      ..strokeWidth = 1;

    for (int x = 0; x <= SnakeGameModule.gridWidth; x++) {
      canvas.drawLine(
        Offset(x * cellWidth, 0),
        Offset(x * cellWidth, size.height),
        gridPaint,
      );
    }
    for (int y = 0; y <= SnakeGameModule.gridHeight; y++) {
      canvas.drawLine(
        Offset(0, y * cellHeight),
        Offset(size.width, y * cellHeight),
        gridPaint,
      );
    }

    // Border glowing wall
    final borderPaint = Paint()
      ..color = const Color(0xFF00E676)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.5;
    canvas.drawRect(Offset.zero & size, borderPaint);

    // Render Food
    if (game.food != null) {
      final f = game.food!;
      final center = Offset(
        (f.position.x + 0.5) * cellWidth,
        (f.position.y + 0.5) * cellHeight,
      );
      final radius = min(cellWidth, cellHeight) * 0.4;

      Color foodColor;
      switch (f.type) {
        case FoodType.normal:
          foodColor = const Color(0xFFFF1744);
          break;
        case FoodType.golden:
          foodColor = const Color(0xFFFFD600);
          break;
        case FoodType.speed:
          foodColor = const Color(0xFF00E5FF);
          break;
      }

      // Outer pulsing glow
      final glowPaint = Paint()
        ..color = foodColor.withValues(alpha: (0.35 + 0.15 * sin(animationValue * pi * 2)).clamp(0.0, 1.0))
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6);
      canvas.drawCircle(center, radius * 1.3, glowPaint);

      final foodPaint = Paint()..color = foodColor;
      canvas.drawCircle(center, radius, foodPaint);

      // Inner highlight dot
      final highlight = Paint()..color = Colors.white.withValues(alpha: 0.8);
      canvas.drawCircle(center - Offset(radius * 0.3, radius * 0.3), radius * 0.25, highlight);
    }

    // Render Snake Body
    final body = game.body;
    if (body.isEmpty) return;

    for (int i = body.length - 1; i >= 0; i--) {
      final p = body[i];
      final rect = Rect.fromLTWH(
        p.x * cellWidth + 1,
        p.y * cellHeight + 1,
        cellWidth - 2,
        cellHeight - 2,
      );

      final isHead = i == 0;
      final t = (body.length - i) / body.length;

      final color = isHead
          ? const Color(0xFF00E676)
          : Color.lerp(const Color(0xFF00B0FF), const Color(0xFF1DE9B6), t)!;

      final paint = Paint()
        ..color = color
        ..style = PaintingStyle.fill;

      final rrect = RRect.fromRectAndRadius(rect, Radius.circular(isHead ? 6 : 4));
      canvas.drawRRect(rrect, paint);

      if (isHead) {
        // Draw eyes based on direction
        final eyePaint = Paint()..color = Colors.black;
        final pupilPaint = Paint()..color = Colors.white;

        double eyeR = min(cellWidth, cellHeight) * 0.12;
        Offset eye1, eye2;

        switch (game.currentDirection) {
          case GameDirection.up:
            eye1 = Offset(rect.left + rect.width * 0.3, rect.top + rect.height * 0.3);
            eye2 = Offset(rect.left + rect.width * 0.7, rect.top + rect.height * 0.3);
            break;
          case GameDirection.down:
            eye1 = Offset(rect.left + rect.width * 0.3, rect.top + rect.height * 0.7);
            eye2 = Offset(rect.left + rect.width * 0.7, rect.top + rect.height * 0.7);
            break;
          case GameDirection.left:
            eye1 = Offset(rect.left + rect.width * 0.3, rect.top + rect.height * 0.3);
            eye2 = Offset(rect.left + rect.width * 0.3, rect.top + rect.height * 0.7);
            break;
          case GameDirection.right:
          case GameDirection.none:
            eye1 = Offset(rect.left + rect.width * 0.7, rect.top + rect.height * 0.3);
            eye2 = Offset(rect.left + rect.width * 0.7, rect.top + rect.height * 0.7);
            break;
        }

        canvas.drawCircle(eye1, eyeR, eyePaint);
        canvas.drawCircle(eye2, eyeR, eyePaint);
        canvas.drawCircle(eye1, eyeR * 0.4, pupilPaint);
        canvas.drawCircle(eye2, eyeR * 0.4, pupilPaint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant SnakePainter oldDelegate) => true;
}
