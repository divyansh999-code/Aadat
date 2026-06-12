import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'settings_screen.dart';
import '../providers/habit_provider.dart';
import '../data/models/habit.dart';

class ArchiveScreen extends StatelessWidget {
  const ArchiveScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<HabitProvider>(
      builder: (context, provider, _) {
        final archived = provider.archivedHabits;

        final theme = Theme.of(context);
        final isDark = theme.brightness == Brightness.dark;
        final onSurfaceColor = theme.colorScheme.onSurface;
        final dividerColor = isDark ? const Color(0xFF333333) : const Color(0xFFEEEEEE);

        return Scaffold(
          backgroundColor: theme.scaffoldBackgroundColor,
          body: SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // App bar
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Aadat',
                        style: GoogleFonts.dmSans(
                          fontSize: 22,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 3,
                          color: onSurfaceColor,
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
                            size: 22, color: onSurfaceColor),
                      ),
                    ],
                  ),
                ),

                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Archive',
                        style: GoogleFonts.dmSans(
                          fontSize: 30,
                          fontWeight: FontWeight.w800,
                          color: onSurfaceColor,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Past habits, preserved.',
                        style: GoogleFonts.dmSans(
                          fontSize: 13,
                          color: const Color(0xFF888888),
                        ),
                      ),
                    ],
                  ),
                ).animate().fadeIn(duration: 300.ms),

                const SizedBox(height: 12),
                Divider(color: dividerColor),

                Expanded(
                  child: archived.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                'Nothing archived yet.',
                                style: GoogleFonts.dmSans(
                                  fontSize: 14,
                                  color: const Color(0xFF888888),
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Long-press a habit to archive it.',
                                style: GoogleFonts.dmSans(
                                  fontSize: 12,
                                  color: const Color(0xFFAAAAAA),
                                ),
                              ),
                            ],
                          ),
                        )
                      : ListView.separated(
                          itemCount: archived.length,
                          separatorBuilder: (_, __) =>
                              Divider(color: dividerColor, height: 1),
                          itemBuilder: (context, i) {
                            final habit = archived[i];
                            return _ArchivedHabitTile(
                              habit: habit,
                              index: i,
                              onRestore: () async {
                                HapticFeedback.mediumImpact();
                                await provider.restoreHabit(habit.id!);
                                if (context.mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(
                                        '"${habit.name}" restored.',
                                        style: GoogleFonts.dmSans(
                                            color: theme.colorScheme.surface),
                                      ),
                                      backgroundColor: onSurfaceColor,
                                      behavior: SnackBarBehavior.floating,
                                      shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(8)),
                                    ),
                                  );
                                }
                              },
                              onDelete: () =>
                                  _confirmDelete(context, provider, habit),
                            );
                          },
                        ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _confirmDelete(
      BuildContext context, HabitProvider provider, Habit habit) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Colors.white,
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        title: Text(
          'Delete "${habit.name}"?',
          style: GoogleFonts.dmSans(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: Colors.black,
          ),
        ),
        content: Text(
          'This will permanently delete the habit and all its logs.',
          style: GoogleFonts.dmSans(
            fontSize: 13,
            color: const Color(0xFF888888),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: Text(
              'CANCEL',
              style: GoogleFonts.dmSans(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: const Color(0xFF888888),
              ),
            ),
          ),
          TextButton(
            onPressed: () async {
              Navigator.of(ctx).pop();
              HapticFeedback.heavyImpact();
              await provider.deleteHabit(habit.id!);
            },
            child: Text(
              'DELETE',
              style: GoogleFonts.dmSans(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: Colors.black,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ArchivedHabitTile extends StatelessWidget {
  final Habit habit;
  final int index;
  final VoidCallback onRestore;
  final VoidCallback onDelete;

  const _ArchivedHabitTile({
    required this.habit,
    required this.index,
    required this.onRestore,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final archivedDate = DateFormat('MMM dd, yyyy').format(habit.createdAt);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Animate(
      effects: [
        FadeEffect(
          delay: Duration(milliseconds: index * 60),
          duration: const Duration(milliseconds: 300),
        ),
        SlideEffect(
          begin: const Offset(0.05, 0),
          end: Offset.zero,
          delay: Duration(milliseconds: index * 60),
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        ),
      ],
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              habit.name,
              style: GoogleFonts.dmSans(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Archived on $archivedDate',
              style: GoogleFonts.dmSans(
                fontSize: 11,
                color: const Color(0xFF888888),
              ),
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                GestureDetector(
                  onTap: onRestore,
                  child: Text(
                    'RESTORE',
                    style: GoogleFonts.dmSans(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.8,
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Container(
                  width: 1,
                  height: 12,
                  color: isDark ? const Color(0xFF333333) : const Color(0xFFDDDDDD),
                ),
                const SizedBox(width: 16),
                GestureDetector(
                  onTap: onDelete,
                  child: Text(
                    'DELETE',
                    style: GoogleFonts.dmSans(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.8,
                      color: const Color(0xFF888888),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
