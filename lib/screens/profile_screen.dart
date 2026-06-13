import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../providers/theme_provider.dart';
import '../providers/habit_provider.dart';
import 'settings_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _nameController = TextEditingController();
  bool _editing = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _nameController.text = context.read<ThemeProvider>().userName;
    });
  }

  Future<void> _saveName() async {
    final name = _nameController.text.trim();
    if (name.isNotEmpty) {
      await context.read<ThemeProvider>().setUserName(name);
    }
    setState(() => _editing = false);
    HapticFeedback.mediumImpact();
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }


  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final userName = context.watch<ThemeProvider>().userName;
    final onSurfaceColor = theme.colorScheme.onSurface;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            // Settings Icon Row aligned to the right
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
              child: Align(
                alignment: Alignment.centerRight,
                child: GestureDetector(
                  onTap: () {
                    HapticFeedback.selectionClick();
                    Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => const SettingsScreen()),
                    );
                  },
                  child: Icon(
                    Icons.settings_outlined,
                    size: 22,
                    color: onSurfaceColor,
                  ),
                ),
              ),
            ),

            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                children: [
                  const SizedBox(height: 20),

                  // Name (editable inline, tap to edit)
                  Center(
                    child: _editing
                        ? Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              SizedBox(
                                width: 200,
                                child: TextField(
                                  controller: _nameController,
                                  autofocus: true,
                                  textAlign: TextAlign.center,
                                  style: GoogleFonts.dmSans(
                                    fontSize: 28,
                                    fontWeight: FontWeight.w700,
                                    color: onSurfaceColor,
                                  ),
                                  decoration: InputDecoration(
                                    border: UnderlineInputBorder(
                                      borderSide: BorderSide(
                                          color: onSurfaceColor, width: 1.5),
                                    ),
                                    focusedBorder: UnderlineInputBorder(
                                      borderSide: BorderSide(
                                          color: onSurfaceColor, width: 2),
                                    ),
                                    contentPadding:
                                        const EdgeInsets.symmetric(vertical: 4),
                                  ),
                                  onSubmitted: (_) => _saveName(),
                                ),
                              ),
                              const SizedBox(width: 8),
                              GestureDetector(
                                onTap: _saveName,
                                child: Icon(Icons.check,
                                    size: 20, color: onSurfaceColor),
                              ),
                            ],
                          )
                        : GestureDetector(
                            onTap: () {
                              _nameController.text = userName;
                              setState(() => _editing = true);
                            },
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  userName.isEmpty ? 'Your Name' : userName,
                                  style: GoogleFonts.dmSans(
                                    fontSize: 28,
                                    fontWeight: FontWeight.w700,
                                    color: onSurfaceColor,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                const Icon(Icons.edit_outlined,
                                    size: 16, color: Color(0xFF888888)),
                              ],
                            ),
                          ),
                  ),
                  const SizedBox(height: 4),

                  // "Aadat" small label below it
                  Center(
                    child: Text(
                      'Aadat',
                      style: GoogleFonts.dmSans(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        letterSpacing: 2,
                        color: const Color(0xFF888888),
                      ),
                    ),
                  ),

                  const SizedBox(height: 40),

                  // 2x2 Stats Grid
                  _buildStatsGrid(context),

                  const SizedBox(height: 40),

                  // App Version
                  Center(
                    child: Text(
                      'Aadat v1.0.0',
                      style: GoogleFonts.dmSans(
                        fontSize: 11,
                        color: const Color(0xFF888888),
                      ),
                    ),
                  ),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatsGrid(BuildContext context) {
    final habitProvider = context.watch<HabitProvider>();
    final allHabits = [...habitProvider.activeHabits, ...habitProvider.archivedHabits];

    int totalCheckIns = 0;
    int longestStreak = 0;
    int habitsCreated = allHabits.length;
    DateTime? earliestDate;

    for (var habit in allHabits) {
      if (earliestDate == null || habit.createdAt.isBefore(earliestDate)) {
        earliestDate = habit.createdAt;
      }
      final streak = habitProvider.getBestStreak(habit.id!);
      if (streak > longestStreak) {
        longestStreak = streak;
      }
      for (var log in habitProvider.getLogsForHabit(habit.id!)) {
        totalCheckIns += log.completionCount;
      }
    }

    int daysTracked = 0;
    if (earliestDate != null) {
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);
      final earliest = DateTime(earliestDate.year, earliestDate.month, earliestDate.day);
      daysTracked = today.difference(earliest).inDays + 1;
    }

    final theme = Theme.of(context);
    final onSurfaceColor = theme.colorScheme.onSurface;
    final dividerColor = onSurfaceColor.withValues(alpha: 0.15);

    return Column(
      children: [
        // Top solid border line
        Container(
          height: 1,
          width: double.infinity,
          color: onSurfaceColor,
        ),
        Row(
          children: [
            Expanded(
              child: _buildStatCell('Total Check-ins', totalCheckIns.toString(), onSurfaceColor, dividerColor, rightBorder: true),
            ),
            Expanded(
              child: _buildStatCell('Longest Streak', longestStreak.toString(), onSurfaceColor, dividerColor),
            ),
          ],
        ),
        // Middle thin horizontal divider
        Container(
          height: 0.5,
          width: double.infinity,
          color: dividerColor,
        ),
        Row(
          children: [
            Expanded(
              child: _buildStatCell('Days Tracked', daysTracked.toString(), onSurfaceColor, dividerColor, rightBorder: true),
            ),
            Expanded(
              child: _buildStatCell('Habits Created', habitsCreated.toString(), onSurfaceColor, dividerColor),
            ),
          ],
        ),
        // Bottom solid border line
        Container(
          height: 1,
          width: double.infinity,
          color: onSurfaceColor,
        ),
      ],
    );
  }

  Widget _buildStatCell(String label, String value, Color textColor, Color dividerColor, {bool rightBorder = false}) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
      decoration: BoxDecoration(
        border: Border(
          right: rightBorder ? BorderSide(color: dividerColor, width: 0.5) : BorderSide.none,
        ),
      ),
      child: Column(
        children: [
          Text(
            value,
            style: GoogleFonts.dmSans(
              fontSize: 32,
              fontWeight: FontWeight.w700,
              color: textColor,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label.toUpperCase(),
            textAlign: TextAlign.center,
            style: GoogleFonts.dmSans(
              fontSize: 10,
              fontWeight: FontWeight.w700,
              letterSpacing: 1.0,
              color: const Color(0xFF888888),
            ),
          ),
        ],
      ),
    );
  }
}
