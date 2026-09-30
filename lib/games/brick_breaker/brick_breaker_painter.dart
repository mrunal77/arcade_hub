import 'package:flutter/material.dart';
import 'brick_breaker_game.dart';

class BrickBreakerPainter extends CustomPainter {
  final BrickBreakerGameModule game;

  BrickBreakerPainter({required this.game});

  @override
  void paint(Canvas canvas, Size size) {
    final scaleX = size.width / BrickBreakerGameModule.worldWidth;
    final scaleY = size.height / BrickBreakerGameModule.worldHeight;

    // Background arcade grid
    final gridPaint = Paint()
      ..color = const Color(0x10FF9100)
      ..strokeWidth = 1;
    for (double x = 0; x < size.width; x += 30) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), gridPaint);
    }
    for (double y = 0; y < size.height; y += 30) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), gridPaint);
    }

    // Top border header wall
    final wallPaint = Paint()
      ..color = const Color(0xFFFF9100)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3;
    canvas.drawLine(Offset(0, 0.06 * scaleY), Offset(size.width, 0.06 * scaleY), wallPaint);

    // Draw Bricks
    for (final brick in game.bricks) {
      if (brick.isDestroyed) continue;

      final rect = Rect.fromLTRB(
        brick.rect.left * scaleX,
        brick.rect.top * scaleY,
        brick.rect.right * scaleX,
        brick.rect.bottom * scaleY,
      );

      final rrect = RRect.fromRectAndRadius(rect, const Radius.circular(4));

      // Glow effect
      final glowPaint = Paint()
        ..color = brick.color.withValues(alpha: 0.35)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4);
      canvas.drawRRect(rrect, glowPaint);

      final paint = Paint()
        ..color = brick.hp > 1 ? brick.color.withValues(alpha: 0.85) : brick.color
        ..style = PaintingStyle.fill;
      canvas.drawRRect(rrect, paint);

      // Inner highlight border
      final border = Paint()
        ..color = Colors.white.withValues(alpha: 0.5)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.5;
      canvas.drawRRect(rrect, border);
    }

    // Draw Particles
    for (final p in game.particles) {
      final pPos = Offset(p.position.dx * scaleX, p.position.dy * scaleY);
      final pPaint = Paint()
        ..color = p.color.withValues(alpha: p.life.clamp(0.0, 1.0))
        ..style = PaintingStyle.fill;
      canvas.drawCircle(pPos, p.size * p.life, pPaint);
    }

    // Draw Paddle
    final paddleRect = Rect.fromLTWH(
      (game.paddleX - game.paddleWidth / 2) * scaleX,
      BrickBreakerGameModule.paddleY * scaleY,
      game.paddleWidth * scaleX,
      BrickBreakerGameModule.paddleHeight * scaleY,
    );
    final paddleRRect = RRect.fromRectAndRadius(paddleRect, const Radius.circular(8));

    final paddleGlow = Paint()
      ..color = const Color(0xFF00E5FF).withValues(alpha: 0.4)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8);
    canvas.drawRRect(paddleRRect, paddleGlow);

    final paddlePaint = Paint()
      ..color = const Color(0xFF00E5FF)
      ..style = PaintingStyle.fill;
    canvas.drawRRect(paddleRRect, paddlePaint);

    // Draw Ball
    final ballCenter = Offset(game.ballPos.dx * scaleX, game.ballPos.dy * scaleY);
    final ballR = BrickBreakerGameModule.ballRadius * scaleX;

    final ballGlow = Paint()
      ..color = const Color(0xFFFFD600).withValues(alpha: 0.5)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6);
    canvas.drawCircle(ballCenter, ballR * 1.5, ballGlow);

    final ballPaint = Paint()..color = const Color(0xFFFFD600);
    canvas.drawCircle(ballCenter, ballR, ballPaint);
  }

  @override
  bool shouldRepaint(covariant BrickBreakerPainter oldDelegate) => true;
}
