import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

enum MatrixCellState { completed, missed, partial, empty }

class MatrixCell extends StatelessWidget {
  final MatrixCellState state;
  final int animationDelay;
  final double size;

  const MatrixCell({
    super.key,
    required this.state,
    this.animationDelay = 0,
    this.size = 16.0,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final color = theme.colorScheme.onSurface;
    final emptyColor = isDark ? const Color(0xFF333333) : const Color(0xFFDDDDDD);
    Widget cell;

    switch (state) {
      case MatrixCellState.completed:
        cell = Container(
          width: size,
          height: size,
          color: color,
        );
        break;
      case MatrixCellState.missed:
        cell = Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            border: Border.all(color: color, width: 1),
          ),
        );
        break;
      case MatrixCellState.partial:
        cell = CustomPaint(
          size: Size(size, size),
          painter: _PartialCellPainter(color: color),
        );
        break;
      case MatrixCellState.empty:
        cell = Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            border: Border.all(color: emptyColor, width: 1),
          ),
        );
        break;
    }

    return Animate(
      effects: [
        FadeEffect(
          delay: Duration(milliseconds: animationDelay),
          duration: const Duration(milliseconds: 200),
        ),
        ScaleEffect(
          begin: const Offset(0.5, 0.5),
          end: const Offset(1.0, 1.0),
          delay: Duration(milliseconds: animationDelay),
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOut,
        ),
      ],
      child: Padding(
        padding: const EdgeInsets.all(2),
        child: cell,
      ),
    );
  }
}

class _PartialCellPainter extends CustomPainter {
  final Color color;
  _PartialCellPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    // Draw outline
    final borderPaint = Paint()
      ..color = color
      ..strokeWidth = 1
      ..style = PaintingStyle.stroke;
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), borderPaint);

    // Fill diagonal half
    final fillPaint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    final path = Path()
      ..moveTo(0, 0)
      ..lineTo(size.width, 0)
      ..lineTo(0, size.height)
      ..close();
    canvas.drawPath(path, fillPaint);
  }

  @override
  bool shouldRepaint(covariant _PartialCellPainter oldDelegate) => oldDelegate.color != color;
}
