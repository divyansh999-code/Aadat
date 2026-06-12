import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../providers/habit_provider.dart';
import '../providers/theme_provider.dart';
import 'settings_screen.dart';
import '../widgets/habit_card.dart';
import '../widgets/add_habit_sheet.dart';
import '../widgets/streak_particle.dart';
import '../widgets/stack_editor_sheet.dart';
import '../data/models/habit.dart';
import '../data/models/habit_stack.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with WidgetsBindingObserver {
  int? _lastStreakMilestone;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      context.read<HabitProvider>().refresh();
    }
  }

  String _greeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good morning,';
    if (hour < 17) return 'Good afternoon,';
    return 'Good evening,';
  }

  Future<void> _showAddHabitSheet() async {
    HapticFeedback.lightImpact();
    final result = await showModalBottomSheet<Habit>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      useSafeArea: true,
      builder: (_) => const AddHabitSheet(),
    );

    if (result != null && mounted) {
      await context.read<HabitProvider>().addHabit(result);
    }
  }

  void _checkStreakMilestone(int habitId, int streak) {
    const milestones = [7, 21, 30, 60, 100];
    if (milestones.contains(streak) && _lastStreakMilestone != streak) {
      setState(() => _lastStreakMilestone = streak);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<HabitProvider>(
      builder: (context, provider, _) {
        if (!provider.initialized) {
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(color: Colors.black, strokeWidth: 1.5),
            ),
          );
        }

        final habits = provider.todayHabits;
        final remaining = provider.remainingTodayCount();
        final now = DateTime.now();

        final theme = Theme.of(context);
        final isDark = theme.brightness == Brightness.dark;
        final userName = context.watch<ThemeProvider>().userName;
        final dividerColor = isDark ? const Color(0xFF333333) : const Color(0xFFEEEEEE);
        final entryBorderColor = isDark ? const Color(0xFF444444) : const Color(0xFFCCCCCC);

        return Scaffold(
          backgroundColor: theme.scaffoldBackgroundColor,
          body: SafeArea(
            child: Column(
              children: [
                // App bar
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      GestureDetector(
                        onLongPress: () => _showDebugSeedDialog(context),
                        child: Text(
                          'Aadat',
                          style: GoogleFonts.dmSans(
                            fontSize: 22,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 3,
                            color: theme.colorScheme.onSurface,
                          ),
                        ),
                      ),
                      GestureDetector(
                        onTap: () {
                          HapticFeedback.selectionClick();
                          Navigator.of(context).push(
                            MaterialPageRoute(builder: (_) => const SettingsScreen()),
                          );
                        },
                        child: Icon(Icons.settings_outlined,
                            size: 22, color: theme.colorScheme.onSurface),
                      ),
                    ],
                  ),
                ),

                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    children: [
                      const SizedBox(height: 8),

                      // Greeting
                      Text(
                        _greeting(),
                        style: GoogleFonts.dmSans(
                          fontSize: 13,
                          fontWeight: FontWeight.w400,
                          color: const Color(0xFF888888),
                        ),
                      ).animate().fadeIn(duration: 400.ms),
                      Text(
                        userName,
                        style: GoogleFonts.dmSans(
                          fontSize: 30,
                          fontWeight: FontWeight.w800,
                          color: theme.colorScheme.onSurface,
                          height: 1.1,
                        ),
                      ).animate().fadeIn(duration: 400.ms, delay: 50.ms),
                      const SizedBox(height: 4),
                      Text(
                        DateFormat('MMMM d, yyyy').format(now).toUpperCase(),
                        style: GoogleFonts.dmSans(
                          fontSize: 10,
                          fontWeight: FontWeight.w500,
                          letterSpacing: 1.5,
                          color: const Color(0xFF888888),
                        ),
                      ).animate().fadeIn(duration: 400.ms, delay: 100.ms),

                      const SizedBox(height: 24),
                      Divider(color: dividerColor),
                      const SizedBox(height: 20),

                      // Section header
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            "Today's Ledger",
                            style: GoogleFonts.dmSans(
                              fontSize: 20,
                              fontWeight: FontWeight.w700,
                              color: theme.colorScheme.onSurface,
                            ),
                          ),
                          if (remaining > 0)
                            Text(
                              '$remaining REMAINING',
                              style: GoogleFonts.dmSans(
                                fontSize: 10,
                                fontWeight: FontWeight.w600,
                                letterSpacing: 1.0,
                                color: theme.colorScheme.onSurface,
                              ),
                            ),
                        ],
                      ).animate().fadeIn(duration: 300.ms, delay: 150.ms),
                      const SizedBox(height: 16),

                      // Habit cards
                      // Habit cards grouped by stack
                      if (habits.isEmpty)
                        _EmptyState(onAdd: _showAddHabitSheet)
                      else ...() {
                        final stacks = provider.stacks;
                        final stackedHabitIds = <int>{};
                        for (final stack in stacks) {
                          stackedHabitIds.addAll(stack.habitIds);
                        }

                        final standaloneHabits = habits.where((h) => !stackedHabitIds.contains(h.id)).toList();
                        final listWidgets = <Widget>[];
                        int animationIndex = 0;

                        // Render stacks
                        for (final stack in stacks) {
                          final todayStackHabits = <Habit>[];
                          for (final id in stack.habitIds) {
                            for (final h in habits) {
                              if (h.id == id) {
                                todayStackHabits.add(h);
                                break;
                              }
                            }
                          }

                          if (todayStackHabits.isNotEmpty) {
                            final stackStreak = provider.getStackStreak(stack);

                            listWidgets.add(
                              GestureDetector(
                                onLongPress: () => _showStackActionSheet(stack),
                                behavior: HitTestBehavior.opaque,
                                child: Padding(
                                  padding: const EdgeInsets.only(top: 14, bottom: 8, left: 4),
                                  child: Row(
                                    children: [
                                      Text(
                                        stack.name.toUpperCase(),
                                        style: GoogleFonts.dmSans(
                                          fontSize: 10,
                                          fontWeight: FontWeight.w800,
                                          letterSpacing: 1.5,
                                          color: isDark ? const Color(0xFFAAAAAA) : const Color(0xFF666666),
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      Text(
                                        '🔥 $stackStreak',
                                        style: GoogleFonts.dmSans(
                                          fontSize: 10,
                                          fontWeight: FontWeight.w800,
                                          color: theme.colorScheme.onSurface,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ).animate().fadeIn(duration: 300.ms),
                            );

                            for (int j = 0; j < todayStackHabits.length; j++) {
                              final habit = todayStackHabits[j];
                              final count = provider.getCompletionCount(habit.id!);
                              final streak = provider.getStreak(habit.id!);
                              final isFirst = j == 0;
                              final isLast = j == todayStackHabits.length - 1;
                              final highlight = provider.shouldHighlightHabit(habit.id!, stack);

                              listWidgets.add(
                                Stack(
                                  alignment: Alignment.center,
                                  children: [
                                    HabitCard(
                                      habit: habit,
                                      completionCount: count,
                                      streak: streak,
                                      animationIndex: animationIndex++,
                                      isStacked: true,
                                      isFirstOfStack: isFirst,
                                      isLastOfStack: isLast,
                                      highlight: highlight,
                                      onCheckIn: () async {
                                        await provider.checkIn(habit.id!);
                                        final newStreak = provider.getStreak(habit.id!);
                                        _checkStreakMilestone(habit.id!, newStreak);
                                      },
                                      onUndo: () => provider.undo(habit.id!),
                                      onLongPress: () => _showHabitActionSheet(habit),
                                    ),
                                    if (_lastStreakMilestone != null &&
                                        streak == _lastStreakMilestone)
                                      StreakParticleBurst(
                                          streakCount: _lastStreakMilestone!),
                                  ],
                                ),
                              );
                            }
                          }
                        }

                        // Render standalone habits
                        if (standaloneHabits.isNotEmpty) {
                          if (listWidgets.isNotEmpty) {
                            listWidgets.add(const SizedBox(height: 12));
                          }
                          for (final habit in standaloneHabits) {
                            final count = provider.getCompletionCount(habit.id!);
                            final streak = provider.getStreak(habit.id!);

                            listWidgets.add(
                              Stack(
                                alignment: Alignment.center,
                                children: [
                                  HabitCard(
                                    habit: habit,
                                    completionCount: count,
                                    streak: streak,
                                    animationIndex: animationIndex++,
                                    onCheckIn: () async {
                                      await provider.checkIn(habit.id!);
                                      final newStreak = provider.getStreak(habit.id!);
                                      _checkStreakMilestone(habit.id!, newStreak);
                                    },
                                    onUndo: () => provider.undo(habit.id!),
                                    onLongPress: () => _showHabitActionSheet(habit),
                                  ),
                                  if (_lastStreakMilestone != null &&
                                      streak == _lastStreakMilestone)
                                    StreakParticleBurst(
                                        streakCount: _lastStreakMilestone!),
                                ],
                              ),
                            );
                          }
                        }

                        return listWidgets;
                      }(),

                      const SizedBox(height: 10),

                      // Side-by-side action buttons
                      Row(
                        children: [
                          Expanded(
                            child: GestureDetector(
                              onTap: _showAddHabitSheet,
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 150),
                                height: 52,
                                decoration: BoxDecoration(
                                  color: theme.colorScheme.surface,
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(
                                    color: entryBorderColor,
                                    width: 1,
                                    strokeAlign: BorderSide.strokeAlignCenter,
                                  ),
                                ),
                                child: CustomPaint(
                                  painter: _DashedBorderPainter(color: isDark ? const Color(0xFF666666) : const Color(0xFF888888)),
                                  child: Center(
                                    child: Text(
                                      '+ NEW ENTRY',
                                      style: GoogleFonts.dmSans(
                                        fontSize: 11,
                                        fontWeight: FontWeight.w700,
                                        letterSpacing: 1.5,
                                        color: theme.colorScheme.onSurface,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: GestureDetector(
                              onTap: () async {
                                HapticFeedback.lightImpact();
                                await showModalBottomSheet(
                                  context: context,
                                  isScrollControlled: true,
                                  backgroundColor: Colors.transparent,
                                  useSafeArea: true,
                                  builder: (_) => const StackEditorSheet(),
                                );
                              },
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 150),
                                height: 52,
                                decoration: BoxDecoration(
                                  color: theme.colorScheme.surface,
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(
                                    color: entryBorderColor,
                                    width: 1,
                                    strokeAlign: BorderSide.strokeAlignCenter,
                                  ),
                                ),
                                child: CustomPaint(
                                  painter: _DashedBorderPainter(color: isDark ? const Color(0xFF666666) : const Color(0xFF888888)),
                                  child: Center(
                                    child: Text(
                                      '＋ NEW STACK',
                                      style: GoogleFonts.dmSans(
                                        fontSize: 11,
                                        fontWeight: FontWeight.w700,
                                        letterSpacing: 1.5,
                                        color: theme.colorScheme.onSurface,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ).animate().fadeIn(duration: 300.ms, delay: 200.ms),
                      const SizedBox(height: 24),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // ==========================================
  // DEBUG ONLY - Temporary database seeding dialog
  // ==========================================
  void _showDebugSeedDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Theme.of(context).colorScheme.surface,
        title: Text(
          'Seed Debug Data?',
          style: GoogleFonts.dmSans(fontWeight: FontWeight.w700),
        ),
        content: Text(
          'This will delete all current habits, logs, and stacks, and seed the database with mock screenshot data. This is a debug-only feature.',
          style: GoogleFonts.dmSans(),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(
              'Cancel',
              style: GoogleFonts.dmSans(color: const Color(0xFF888888)),
            ),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(ctx);
              HapticFeedback.heavyImpact();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Seeding screenshot data...'),
                  duration: Duration(seconds: 1),
                ),
              );
              await context.read<HabitProvider>().debugSeedData();
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Database seeded successfully!'),
                    duration: Duration(seconds: 1),
                  ),
                );
              }
            },
            child: Text(
              'Seed',
              style: GoogleFonts.dmSans(color: Colors.red, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  void _showHabitActionSheet(Habit habit) {
    HapticFeedback.mediumImpact();
    final provider = context.read<HabitProvider>();
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final textStyle = GoogleFonts.dmSans(fontSize: 15, color: theme.colorScheme.onSurface);
    final count = provider.getCompletionCount(habit.id!);

    showModalBottomSheet(
      context: context,
      backgroundColor: theme.colorScheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (_) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 16),
              child: Text(
                habit.name.toUpperCase(),
                style: GoogleFonts.dmSans(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1.5,
                  color: const Color(0xFF888888),
                ),
              ),
            ),
            Divider(color: isDark ? const Color(0xFF333333) : const Color(0xFFEEEEEE), height: 1),
            if (count > 0)
              ListTile(
                leading: Icon(Icons.undo_outlined, color: theme.colorScheme.onSurface),
                title: Text('Undo Check-in', style: textStyle),
                onTap: () {
                  Navigator.pop(context);
                  provider.undo(habit.id!);
                },
              ),
            ListTile(
              leading: Icon(Icons.edit_outlined, color: theme.colorScheme.onSurface),
              title: Text('Edit', style: textStyle),
              onTap: () async {
                Navigator.pop(context);
                final result = await showModalBottomSheet<Habit>(
                  context: context,
                  isScrollControlled: true,
                  backgroundColor: Colors.transparent,
                  useSafeArea: true,
                  builder: (_) => AddHabitSheet(habit: habit),
                );
                if (result != null && mounted) {
                  await provider.updateHabit(result);
                }
              },
            ),
            ListTile(
              leading: Icon(Icons.archive_outlined, color: theme.colorScheme.onSurface),
              title: Text('Archive', style: textStyle),
              onTap: () {
                Navigator.pop(context);
                provider.archiveHabit(habit.id!);
              },
            ),
            ListTile(
              leading: const Icon(Icons.delete_outline, color: Colors.red),
              title: Text('Delete', style: textStyle.copyWith(color: Colors.red)),
              onTap: () {
                Navigator.pop(context);
                _showDeleteConfirmationDialog(habit);
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showDeleteConfirmationDialog(Habit habit) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Theme.of(context).colorScheme.surface,
        title: Text(
          'Delete Habit?',
          style: GoogleFonts.dmSans(fontWeight: FontWeight.w700),
        ),
        content: Text(
          'Are you sure you want to permanently delete "${habit.name}"? This action cannot be undone.',
          style: GoogleFonts.dmSans(),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(
              'Cancel',
              style: GoogleFonts.dmSans(color: const Color(0xFF888888)),
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              context.read<HabitProvider>().deleteHabit(habit.id!);
            },
            child: Text(
              'Delete',
              style: GoogleFonts.dmSans(color: Colors.red, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  void _showStackActionSheet(HabitStack stack) {
    HapticFeedback.mediumImpact();
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final textStyle = GoogleFonts.dmSans(fontSize: 15, color: theme.colorScheme.onSurface);

    showModalBottomSheet(
      context: context,
      backgroundColor: theme.colorScheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (_) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 16),
              child: Text(
                stack.name.toUpperCase(),
                style: GoogleFonts.dmSans(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1.5,
                  color: const Color(0xFF888888),
                ),
              ),
            ),
            Divider(color: isDark ? const Color(0xFF333333) : const Color(0xFFEEEEEE), height: 1),
            ListTile(
              leading: Icon(Icons.edit_outlined, color: theme.colorScheme.onSurface),
              title: Text('Edit Stack', style: textStyle),
              onTap: () async {
                Navigator.pop(context);
                await showModalBottomSheet(
                  context: context,
                  isScrollControlled: true,
                  backgroundColor: Colors.transparent,
                  useSafeArea: true,
                  builder: (_) => StackEditorSheet(stack: stack),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.delete_outline, color: Colors.red),
              title: Text('Delete Stack', style: textStyle.copyWith(color: Colors.red)),
              onTap: () {
                Navigator.pop(context);
                _showDeleteStackConfirmationDialog(stack);
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showDeleteStackConfirmationDialog(HabitStack stack) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Theme.of(context).colorScheme.surface,
        title: Text(
          'Delete Stack?',
          style: GoogleFonts.dmSans(fontWeight: FontWeight.w700),
        ),
        content: Text(
          'Are you sure you want to delete the stack "${stack.name}"? The habits inside the stack will not be deleted; they will become standalone habits.',
          style: GoogleFonts.dmSans(),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(
              'Cancel',
              style: GoogleFonts.dmSans(color: const Color(0xFF888888)),
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              context.read<HabitProvider>().deleteStack(stack.id!);
            },
            child: Text(
              'Delete',
              style: GoogleFonts.dmSans(color: Colors.red, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  final VoidCallback onAdd;
  const _EmptyState({required this.onAdd});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 32),
      child: Column(
        children: [
          Text(
            'No habits scheduled for today.',
            style: GoogleFonts.dmSans(
              fontSize: 14,
              color: const Color(0xFF888888),
            ),
          ),
          const SizedBox(height: 8),
          TextButton(
            onPressed: onAdd,
            child: Text(
              'Add your first habit →',
              style: GoogleFonts.dmSans(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: Theme.of(context).colorScheme.onSurface,
                decoration: TextDecoration.underline,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _DashedBorderPainter extends CustomPainter {
  final Color color;
  _DashedBorderPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    const dashWidth = 6.0;
    const dashSpace = 5.0;
    final paint = Paint()
      ..color = color
      ..strokeWidth = 1
      ..style = PaintingStyle.stroke;

    double x = 0;
    while (x < size.width) {
      canvas.drawLine(Offset(x, 0), Offset(x + dashWidth, 0), paint);
      canvas.drawLine(
          Offset(x, size.height), Offset(x + dashWidth, size.height), paint);
      x += dashWidth + dashSpace;
    }
    double y = 0;
    while (y < size.height) {
      canvas.drawLine(Offset(0, y), Offset(0, y + dashWidth), paint);
      canvas.drawLine(
          Offset(size.width, y), Offset(size.width, y + dashWidth), paint);
      y += dashWidth + dashSpace;
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
