import 'dart:math';
import 'package:flutter/material.dart';

const Color inkBlue = Color(0xFF1F3F9E);
const Color pencilRed = Color(0xFFC62828);
const Color pencilGrey = Color(0xFF4A4A4A);
const Color paperColor = Color(0xFFFBF7EA);

/// Notebook paper: ruled lines, red margin and punched holes.
class PaperPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawRect(Offset.zero & size, Paint()..color = paperColor);

    final ruled = Paint()
      ..color = const Color(0x552B78C2)
      ..strokeWidth = 1;
    for (double y = 70; y < size.height; y += 32) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), ruled);
    }

    final margin = Paint()
      ..color = const Color(0x77E53935)
      ..strokeWidth = 1.6;
    canvas.drawLine(const Offset(44, 0), Offset(44, size.height), margin);

    final hole = Paint()..color = const Color(0xFFD9D2BC);
    final holeEdge = Paint()
      ..color = const Color(0xFFBDB59B)
      ..style = PaintingStyle.stroke;
    for (final f in [0.15, 0.5, 0.85]) {
      final c = Offset(18, size.height * f);
      canvas.drawCircle(c, 7, hole);
      canvas.drawCircle(c, 7, holeEdge);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// Hand-drawn wobbly # grid.
class GridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width, h = size.height;
    final p = Paint()
      ..color = pencilGrey
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4.5
      ..strokeCap = StrokeCap.round;

    // vertical lines
    final v1 = Path()
      ..moveTo(w / 3 + 3, 4)
      ..quadraticBezierTo(w / 3 - 5, h / 2, w / 3 + 2, h - 4);
    final v2 = Path()
      ..moveTo(2 * w / 3 - 3, 6)
      ..quadraticBezierTo(2 * w / 3 + 5, h / 2, 2 * w / 3 - 1, h - 6);
    // horizontal lines
    final h1 = Path()
      ..moveTo(4, h / 3 - 2)
      ..quadraticBezierTo(w / 2, h / 3 + 6, w - 4, h / 3 + 2);
    final h2 = Path()
      ..moveTo(6, 2 * h / 3 + 3)
      ..quadraticBezierTo(w / 2, 2 * h / 3 - 5, w - 6, 2 * h / 3 - 1);

    for (final path in [v1, v2, h1, h2]) {
      canvas.drawPath(path, p);
      // faint second pencil pass for a sketchy look
      canvas.drawPath(
        path.shift(const Offset(1.5, 1.5)),
        p
          ..color = pencilGrey.withValues(alpha: 0.35)
          ..strokeWidth = 2,
      );
      p
        ..color = pencilGrey
        ..strokeWidth = 4.5;
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// Animated X (blue ink) or O (red pencil). [t] goes from 0 to 1.
class MarkPainter extends CustomPainter {
  MarkPainter(this.symbol, this.t);
  final String symbol;
  final double t;

  @override
  void paint(Canvas canvas, Size size) {
    final isX = symbol == 'X';
    final color = isX ? inkBlue : pencilRed;
    final main = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeWidth = 8;
    final faint = Paint()
      ..color = color.withValues(alpha: 0.35)
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeWidth = 3;

    final w = size.width, h = size.height;

    if (isX) {
      final t1 = (t * 2).clamp(0.0, 1.0);
      final t2 = (t * 2 - 1).clamp(0.0, 1.0);
      final a1 = Offset(w * 0.06, h * 0.08), b1 = Offset(w * 0.94, h * 0.93);
      final a2 = Offset(w * 0.93, h * 0.05), b2 = Offset(w * 0.07, h * 0.95);
      if (t1 > 0) {
        canvas.drawLine(a1, Offset.lerp(a1, b1, t1)!, main);
        canvas.drawLine(a1 + const Offset(3, 2),
            Offset.lerp(a1, b1, t1)! + const Offset(3, 2), faint);
      }
      if (t2 > 0) {
        canvas.drawLine(a2, Offset.lerp(a2, b2, t2)!, main);
        canvas.drawLine(a2 + const Offset(-2, 3),
            Offset.lerp(a2, b2, t2)! + const Offset(-2, 3), faint);
      }
    } else {
      final rect = Rect.fromLTWH(w * 0.05, h * 0.06, w * 0.9, h * 0.88);
      final sweep = 2 * pi * 1.06 * t;
      canvas.drawArc(rect, -pi * 0.65, sweep, false, main);
      canvas.drawArc(rect.shift(const Offset(2, 2)), -pi * 0.65, sweep, false,
          faint);
    }
  }

  @override
  bool shouldRepaint(covariant MarkPainter old) =>
      old.t != t || old.symbol != symbol;
}

/// Red marker line striking through the winning cells.
class WinLinePainter extends CustomPainter {
  WinLinePainter(this.line, this.t);
  final List<int> line;
  final double t;

  @override
  void paint(Canvas canvas, Size size) {
    final cw = size.width / 3, ch = size.height / 3;
    Offset center(int i) => Offset((i % 3 + 0.5) * cw, (i ~/ 3 + 0.5) * ch);

    final a = center(line.first), c = center(line.last);
    final dir = (c - a) / (c - a).distance;
    final start = a - dir * (cw * 0.38);
    final end = c + dir * (cw * 0.38);

    final p = Paint()
      ..color = const Color(0xCCD32F2F)
      ..strokeWidth = 9
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(start, Offset.lerp(start, end, t)!, p);
  }

  @override
  bool shouldRepaint(covariant WinLinePainter old) => old.t != t;
}
