import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import '../data/models/habit.dart';


class HabitCard extends StatefulWidget {
  final Habit habit;
  final int completionCount;
  final int streak;
  final VoidCallback onCheckIn;
  final VoidCallback onUndo;
  final int animationIndex;
  final bool isStacked;
  final bool isFirstOfStack;
  final bool isLastOfStack;
  final bool highlight;
  final VoidCallback? onLongPress;

  const HabitCard({
    super.key,
    required this.habit,
    required this.completionCount,
    required this.streak,
    required this.onCheckIn,
    required this.onUndo,
    this.animationIndex = 0,
    this.isStacked = false,
    this.isFirstOfStack = false,
    this.isLastOfStack = false,
    this.highlight = false,
    this.onLongPress,
  });

  @override
  State<HabitCard> createState() => _HabitCardState();
}

class _HabitCardState extends State<HabitCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _bounceController;
  late Animation<double> _scaleAnim;

  @override
  void initState() {
    super.initState();
    _bounceController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _scaleAnim = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween(begin: 1.0, end: 1.25)
            .chain(CurveTween(curve: Curves.easeOut)),
        weight: 40,
      ),
      TweenSequenceItem(
        tween: Tween(begin: 1.25, end: 0.9)
            .chain(CurveTween(curve: Curves.easeIn)),
        weight: 30,
      ),
      TweenSequenceItem(
        tween: Tween(begin: 0.9, end: 1.0)
            .chain(CurveTween(curve: Curves.elasticOut)),
        weight: 30,
      ),
    ]).animate(_bounceController);
  }

  @override
  void dispose() {
    _bounceController.dispose();
    super.dispose();
  }

  bool get isCompleted =>
      widget.completionCount >= widget.habit.timesPerDay;

  void _handleTap() {
    if (!isCompleted) {
      HapticFeedback.mediumImpact();
      _bounceController.forward(from: 0);
      widget.onCheckIn();
    }
  }

  void _handleLongPress() {
    if (widget.onLongPress != null) {
      widget.onLongPress!();
    }
  }

  @override
  Widget build(BuildContext context) {
    final progress =
        '${widget.completionCount}/${widget.habit.timesPerDay} SESSIONS';
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final primaryColor = theme.colorScheme.primary;
    final surfaceColor = theme.colorScheme.surface;
    final onSurfaceColor = theme.colorScheme.onSurface;

    final hasCompletions = widget.completionCount > 0;
    final borderColor = isCompleted
        ? primaryColor
        : (hasCompletions ? primaryColor : const Color(0xFFDDDDDD));

    Widget cardBody = Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: surfaceColor,
        border: Border.all(
          color: widget.highlight ? primaryColor : borderColor,
          width: (isCompleted || hasCompletions || widget.highlight) ? 1.5 : 1.0,
        ),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: _handleTap,
          onLongPress: _handleLongPress,
          borderRadius: BorderRadius.circular(8),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            child: Row(
              children: [
                // Check circle
                Stack(
                  alignment: Alignment.center,
                  clipBehavior: Clip.none,
                  children: [
                    if (widget.isStacked)
                      CustomPaint(
                        size: const Size(28, 28),
                        painter: StackConnectorPainter(
                          hasTop: !widget.isFirstOfStack,
                          hasBottom: !widget.isLastOfStack,
                          color: isDark ? const Color(0xFF444444) : const Color(0xFFDDDDDD),
                        ),
                      ),
                    AnimatedBuilder(
                      animation: _scaleAnim,
                      builder: (context, child) => Transform.scale(
                        scale: _bounceController.isAnimating
                            ? _scaleAnim.value
                            : 1.0,
                        child: child,
                      ),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 250),
                        curve: Curves.easeOut,
                        width: 28,
                        height: 28,
                        decoration: BoxDecoration(
                          color: isCompleted ? primaryColor : surfaceColor,
                          shape: BoxShape.circle,
                          border: isCompleted
                              ? null
                              : (hasCompletions
                                  ? null
                                  : Border.all(
                                      color: primaryColor,
                                      width: 2,
                                    )),
                        ),
                        child: isCompleted
                            ? Icon(
                                Icons.check,
                                color: surfaceColor,
                                size: 16,
                              )
                            : (hasCompletions
                                ? CustomPaint(
                                    size: const Size(28, 28),
                                    painter: _PartialCirclePainter(color: primaryColor),
                                  )
                                : null),
                      ),
                    ),
                  ],
                ),
                const SizedBox(width: 14),
                  // Habit info
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.habit.name,
                          style: GoogleFonts.dmSans(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            color: onSurfaceColor,
                          ),
                        ),
                        const SizedBox(height: 3),
                        Row(
                          children: [
                            Text(
                              progress,
                              style: GoogleFonts.dmSans(
                                fontSize: 10,
                                fontWeight: FontWeight.w500,
                                color: isDark ? const Color(0xFFAAAAAA) : const Color(0xFF888888),
                                letterSpacing: 0.5,
                              ),
                            ),
                            const SizedBox(width: 10),
                            const Text('🔥',
                                style: TextStyle(fontSize: 10)),
                            const SizedBox(width: 2),
                            Text(
                              '${widget.streak}',
                              style: GoogleFonts.dmSans(
                                fontSize: 10,
                                fontWeight: FontWeight.w600,
                                color: onSurfaceColor,
                                letterSpacing: 0.3,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      );

      if (widget.highlight) {
        cardBody = cardBody.animate(
          onPlay: (controller) => controller.repeat(reverse: true),
        ).scale(
          begin: const Offset(1.0, 1.0),
          end: const Offset(1.015, 1.015),
          duration: 1000.ms,
          curve: Curves.easeInOut,
        ).boxShadow(
          begin: const BoxShadow(color: Colors.transparent),
          end: BoxShadow(
            color: primaryColor.withValues(alpha: 0.06),
            blurRadius: 8,
            spreadRadius: 2,
          ),
          duration: 1000.ms,
          curve: Curves.easeInOut,
        );
      }

    return Animate(
      effects: [
        SlideEffect(
          begin: const Offset(0, 0.3),
          end: Offset.zero,
          duration: Duration(milliseconds: 300 + widget.animationIndex * 60),
          curve: Curves.easeOut,
        ),
        FadeEffect(
          duration: Duration(milliseconds: 300 + widget.animationIndex * 60),
          curve: Curves.easeOut,
        ),
      ],
      child: cardBody,
    );
  }
}

class _PartialCirclePainter extends CustomPainter {
  final Color color;

  _PartialCirclePainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;

    // Draw outline
    final borderPaint = Paint()
      ..color = color
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;
    canvas.drawCircle(center, radius - 1, borderPaint);

    // Fill diagonal half
    final fillPaint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    final rect = Rect.fromCircle(center: center, radius: radius - 1);
    // Draw 180 degrees arc starting at -135 degrees (diagonal split)
    canvas.drawArc(rect, -2.35619, 3.14159, true, fillPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class StackConnectorPainter extends CustomPainter {
  final bool hasTop;
  final bool hasBottom;
  final Color color;

  StackConnectorPainter({
    required this.hasTop,
    required this.hasBottom,
    required this.color,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    final centerX = size.width / 2;
    final centerY = size.height / 2;

    if (hasTop) {
      canvas.drawLine(Offset(centerX, centerY), Offset(centerX, -35), paint);
    }
    if (hasBottom) {
      canvas.drawLine(Offset(centerX, centerY), Offset(centerX, size.height + 35), paint);
    }
  }

  @override
  bool shouldRepaint(covariant StackConnectorPainter oldDelegate) {
    return oldDelegate.hasTop != hasTop ||
        oldDelegate.hasBottom != hasBottom ||
        oldDelegate.color != color;
  }
}
