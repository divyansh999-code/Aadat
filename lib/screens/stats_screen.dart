import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'settings_screen.dart';
import '../providers/habit_provider.dart';
import '../data/models/habit.dart';
import '../widgets/matrix_cell.dart';

class StatsScreen extends StatefulWidget {
  const StatsScreen({super.key});

  @override
  State<StatsScreen> createState() => _StatsScreenState();
}

class _StatsScreenState extends State<StatsScreen> {
  late DateTime _selectedWeekStart;

  @override
  void initState() {
    super.initState();
    _selectedWeekStart = _findStartOfWeek(DateTime.now());
  }

  DateTime _findStartOfWeek(DateTime date) {
    return DateTime(date.year, date.month, date.day).subtract(Duration(days: date.weekday - 1));
  }

  MatrixCellState _cellState(Habit habit, DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final compareDate = DateTime(date.year, date.month, date.day);

    // Future days = empty
    if (compareDate.isAfter(today)) return MatrixCellState.empty;

    // Not scheduled = empty
    if (!habit.isScheduledFor(compareDate)) return MatrixCellState.empty;

    final provider = context.read<HabitProvider>();
    final habitLogs = provider.getLogsForHabit(habit.id!);

    final matching = habitLogs
        .where((l) =>
            l.date.year == compareDate.year &&
            l.date.month == compareDate.month &&
            l.date.day == compareDate.day)
        .toList();
    final log = matching.isEmpty ? null : matching.first;

    final count = log?.completionCount ?? 0;
    if (count <= 0) return MatrixCellState.missed;
    if (count >= habit.timesPerDay) return MatrixCellState.completed;
    return MatrixCellState.partial;
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<HabitProvider>(
      builder: (context, provider, _) {
        final habits = provider.activeHabits;
        
        final now = DateTime.now();
        final currentWeekStart = _findStartOfWeek(now);
        final String titleLabel;
        if (_selectedWeekStart.year == currentWeekStart.year &&
            _selectedWeekStart.month == currentWeekStart.month &&
            _selectedWeekStart.day == currentWeekStart.day) {
          titleLabel = 'This Week — Habit Matrix';
        } else {
          final weekEnd = _selectedWeekStart.add(const Duration(days: 6));
          final startStr = DateFormat('MMM d').format(_selectedWeekStart);
          final endStr = DateFormat('MMM d').format(weekEnd);
          titleLabel = '$startStr - $endStr — Habit Matrix';
        }

        final theme = Theme.of(context);
        final isDark = theme.brightness == Brightness.dark;
        final onSurfaceColor = theme.colorScheme.onSurface;
        final dividerColor = isDark ? const Color(0xFF333333) : const Color(0xFFEEEEEE);

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

                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Week navigation
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                titleLabel,
                                style: GoogleFonts.dmSans(
                                  fontSize: 22,
                                  fontWeight: FontWeight.w800,
                                  color: onSurfaceColor,
                                ),
                              ),
                            ),
                            IconButton(
                              onPressed: () {
                                setState(() {
                                  _selectedWeekStart = _selectedWeekStart.subtract(const Duration(days: 7));
                                });
                              },
                              icon: Icon(Icons.chevron_left,
                                  size: 20, color: onSurfaceColor),
                              padding: EdgeInsets.zero,
                            ),
                            IconButton(
                              onPressed: () {
                                setState(() {
                                  _selectedWeekStart = _selectedWeekStart.add(const Duration(days: 7));
                                });
                              },
                              icon: Icon(Icons.chevron_right,
                                  size: 20, color: onSurfaceColor),
                              padding: EdgeInsets.zero,
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),

                        // Matrix grid
                        if (habits.isEmpty)
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 48),
                            child: Center(
                              child: Text(
                                'No habits yet.',
                                style: GoogleFonts.dmSans(
                                  fontSize: 14,
                                  color: const Color(0xFF888888),
                                ),
                              ),
                            ),
                          )
                        else
                          _buildMatrix(habits),

                        const SizedBox(height: 24),

                        // Streak summary
                        if (habits.isNotEmpty) ...[
                          Divider(color: dividerColor),
                          const SizedBox(height: 16),
                          Row(
                            children: [
                              _StreakStat(
                                label: 'Current Streak',
                                value: habits.isNotEmpty
                                    ? provider.getStreak(habits.first.id!)
                                    : 0,
                              ),
                              const SizedBox(width: 32),
                              _StreakStat(
                                label: 'Best Streak',
                                value: habits.isNotEmpty
                                    ? provider.getBestStreak(habits.first.id!)
                                    : 0,
                              ),
                            ],
                          ),
                          const SizedBox(height: 24),
                        ],
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildMatrix(List<Habit> habits) {
    final theme = Theme.of(context);
    final onSurfaceColor = theme.colorScheme.onSurface;
    const dayLabels = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];

    return LayoutBuilder(
      builder: (context, constraints) {
        final totalWidth = constraints.maxWidth;
        final dayCellWidth = totalWidth * 0.10;
        final matrixCellSize = (dayCellWidth * 0.65).clamp(16.0, 24.0);
        final rowHeight = (matrixCellSize + 12.0);

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header row: day names
            Row(
              children: [
                Expanded(
                  flex: 3,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 4),
                    child: Text(
                      'HABIT',
                      style: GoogleFonts.dmSans(
                        fontSize: 8,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.8,
                        color: onSurfaceColor,
                      ),
                    ),
                  ),
                ),
                ...List.generate(7, (d) {
                  return Expanded(
                    flex: 1,
                    child: SizedBox(
                      height: 20,
                      child: Center(
                        child: Text(
                          dayLabels[d],
                          style: GoogleFonts.dmSans(
                            fontSize: 8,
                            fontWeight: FontWeight.w600,
                            color: onSurfaceColor,
                          ),
                        ),
                      ),
                    ),
                  );
                }),
              ],
            ),
            // Border line
            Container(
              height: 1,
              width: double.infinity,
              color: onSurfaceColor,
            ),

            // Habit rows
            ...habits.asMap().entries.map((entry) {
              final rowIdx = entry.key;
              final habit = entry.value;
              return _HabitRow(
                habit: habit,
                weekStart: _selectedWeekStart,
                matrixCellSize: matrixCellSize,
                rowHeight: rowHeight,
                getCellState: (date) => _cellState(habit, date),
                rowIndex: rowIdx,
              );
            }),

            // Bottom border
            Container(
              height: 1,
              width: double.infinity,
              color: onSurfaceColor,
            ),
          ],
        );
      },
    );
  }
}

class _HabitRow extends StatelessWidget {
  final Habit habit;
  final DateTime weekStart;
  final double matrixCellSize;
  final double rowHeight;
  final MatrixCellState Function(DateTime date) getCellState;
  final int rowIndex;

  const _HabitRow({
    required this.habit,
    required this.weekStart,
    required this.matrixCellSize,
    required this.rowHeight,
    required this.getCellState,
    required this.rowIndex,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final onSurfaceColor = theme.colorScheme.onSurface;

    return Container(
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: onSurfaceColor.withValues(alpha: 0.15), width: 0.5),
        ),
      ),
      child: Row(
        children: [
          // Habit name
          Expanded(
            flex: 3,
            child: Container(
              height: rowHeight,
              padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
              decoration: BoxDecoration(
                border: Border(
                  right: BorderSide(color: onSurfaceColor.withValues(alpha: 0.15), width: 0.5),
                ),
              ),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  habit.name,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.dmSans(
                    fontSize: 9,
                    fontWeight: FontWeight.w500,
                    color: onSurfaceColor,
                    height: 1.1,
                  ),
                ),
              ),
            ),
          ),
          // Day cells
          ...List.generate(7, (d) {
            final date = weekStart.add(Duration(days: d));
            final state = getCellState(date);
            final delay = (rowIndex * 7 + d) * 5;
            return Expanded(
              flex: 1,
              child: SizedBox(
                height: rowHeight,
                child: Center(
                  child: MatrixCell(
                    state: state,
                    size: matrixCellSize,
                    animationDelay: delay.clamp(0, 800),
                  ),
                ),
              ),
            );
          }),
        ],
      ),
    );
  }
}

class _StreakStat extends StatelessWidget {
  final String label;
  final int value;

  const _StreakStat({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label.toUpperCase(),
          style: GoogleFonts.dmSans(
            fontSize: 9,
            fontWeight: FontWeight.w600,
            letterSpacing: 1.0,
            color: const Color(0xFF888888),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          '$value days',
          style: GoogleFonts.dmSans(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: theme.colorScheme.onSurface,
          ),
        ),
      ],
    );
  }
}
