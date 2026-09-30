import 'package:flutter/material.dart';
import 'space_shooter_game.dart';

class SpaceShooterPainter extends CustomPainter {
  final SpaceShooterGameModule game;

  SpaceShooterPainter({required this.game});

  @override
  void paint(Canvas canvas, Size size) {
    final scaleX = size.width / SpaceShooterGameModule.worldWidth;
    final scaleY = size.height / SpaceShooterGameModule.worldHeight;

    // Deep space background
    canvas.drawRect(Offset.zero & size, Paint()..color = const Color(0xFF070B19));

    // Draw Starfield
    for (final s in game.stars) {
      final pos = Offset(s.position.dx * scaleX, s.position.dy * scaleY);
      final starPaint = Paint()
        ..color = Colors.white.withValues(alpha: s.alpha)
        ..style = PaintingStyle.fill;
      canvas.drawCircle(pos, s.size, starPaint);
    }

    // Draw Particles (Explosions)
    for (final p in game.particles) {
      final pos = Offset(p.position.dx * scaleX, p.position.dy * scaleY);
      final pPaint = Paint()
        ..color = p.color.withValues(alpha: p.life.clamp(0.0, 1.0))
        ..style = PaintingStyle.fill;
      canvas.drawCircle(pos, 3.5 * p.life, pPaint);
    }

    // Draw Lasers
    for (final laser in game.lasers) {
      final pos = Offset(laser.position.dx * scaleX, laser.position.dy * scaleY);
      final glowPaint = Paint()
        ..color = laser.color.withValues(alpha: 0.5)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4);
      canvas.drawCircle(pos, 5, glowPaint);

      final lPaint = Paint()
        ..color = laser.color
        ..strokeWidth = 3.5
        ..strokeCap = StrokeCap.round;
      canvas.drawLine(pos - const Offset(0, 8), pos + const Offset(0, 8), lPaint);
    }

    // Draw Enemies
    for (final enemy in game.enemies) {
      final center = Offset(enemy.position.dx * scaleX, enemy.position.dy * scaleY);
      final ew = enemy.size.width * scaleX;
      final eh = enemy.size.height * scaleY;

      Color eColor = const Color(0xFFFF1744);
      if (enemy.type == EnemyType.cruiser) {
        eColor = const Color(0xFFD500F9);
      } else if (enemy.type == EnemyType.interceptor) {
        eColor = const Color(0xFFFF9100);
      }

      final glow = Paint()
        ..color = eColor.withValues(alpha: 0.4)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6);
      canvas.drawCircle(center, ew * 0.6, glow);

      final path = Path()
        ..moveTo(center.dx, center.dy + eh / 2) // Pointing down
        ..lineTo(center.dx - ew / 2, center.dy - eh / 2)
        ..lineTo(center.dx + ew / 2, center.dy - eh / 2)
        ..close();

      final ePaint = Paint()
        ..color = eColor
        ..style = PaintingStyle.fill;
      canvas.drawPath(path, ePaint);
    }

    // Draw Player Ship
    final pCenter = Offset(game.playerPos.dx * scaleX, game.playerPos.dy * scaleY);
    final pw = SpaceShooterGameModule.playerWidth * scaleX;
    final ph = SpaceShooterGameModule.playerHeight * scaleY;

    final playerGlow = Paint()
      ..color = const Color(0xFF00E5FF).withValues(alpha: 0.45)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8);
    canvas.drawCircle(pCenter, pw * 0.7, playerGlow);

    final shipPath = Path()
      ..moveTo(pCenter.dx, pCenter.dy - ph / 2) // Nose pointing up
      ..lineTo(pCenter.dx - pw / 2, pCenter.dy + ph / 2)
      ..lineTo(pCenter.dx, pCenter.dy + ph / 4)
      ..lineTo(pCenter.dx + pw / 2, pCenter.dy + ph / 2)
      ..close();

    final shipPaint = Paint()
      ..color = const Color(0xFF00E5FF)
      ..style = PaintingStyle.fill;
    canvas.drawPath(shipPath, shipPaint);

    final cockpitPaint = Paint()..color = Colors.white;
    canvas.drawCircle(pCenter - Offset(0, ph * 0.1), pw * 0.18, cockpitPaint);
  }

  @override
  bool shouldRepaint(covariant SpaceShooterPainter oldDelegate) => true;
}
