import '../models/habit.dart';
import '../models/habit_log.dart';

class StreakService {
  /// Calculate the current streak for a habit given all its logs.
  ///
  /// Rules:
  /// - Only scheduled days count
  /// - Strict ON: any missed scheduled day resets streak to 0
  /// - Strict OFF: one grace day allowed; two consecutive misses = reset
  /// - Streak = consecutive scheduled days where completionCount >= timesPerDay
  static int calculateCurrentStreak(Habit habit, List<HabitLog> logs) {
    final logMap = <String, HabitLog>{};
    for (final log in logs) {
      logMap[_dateKey(log.date)] = log;
    }

    final today = _normalizeDate(DateTime.now());
    int streak = 0;
    int consecutiveMisses = 0;
    DateTime day = today;

    // Walk backwards from today (max 1 year lookback)
    for (int i = 0; i < 365; i++) {
      if (!habit.isScheduledFor(day)) {
        day = day.subtract(const Duration(days: 1));
        continue;
      }

      final log = logMap[_dateKey(day)];
      final count = log?.completionCount ?? 0;
      final completed = count >= habit.timesPerDay;

      // Don't penalize today if it hasn't ended yet
      final isToday = _isSameDay(day, today);

      if (completed) {
        streak++;
        consecutiveMisses = 0;
      } else if (isToday) {
        day = day.subtract(const Duration(days: 1));
        continue;
      } else {
        if (habit.strictMode) {
          break;
        } else {
          consecutiveMisses++;
          if (consecutiveMisses >= 2) break;
        }
      }

      day = day.subtract(const Duration(days: 1));
    }

    return streak;
  }

  /// Calculate the best (longest) streak ever for a habit
  static int calculateBestStreak(Habit habit, List<HabitLog> logs) {
    if (logs.isEmpty) return 0;

    final logMap = <String, HabitLog>{};
    for (final log in logs) {
      logMap[_dateKey(log.date)] = log;
    }

    final sortedDates = logs.map((l) => _normalizeDate(l.date)).toList()
      ..sort();
    if (sortedDates.isEmpty) return 0;

    final earliest = sortedDates.first;
    final today = _normalizeDate(DateTime.now());

    int bestStreak = 0;
    int currentStreak = 0;
    int consecutiveMisses = 0;

    DateTime day = earliest;
    while (!day.isAfter(today)) {
      if (habit.isScheduledFor(day)) {
        final log = logMap[_dateKey(day)];
        final count = log?.completionCount ?? 0;
        final completed = count >= habit.timesPerDay;

        if (completed) {
          currentStreak++;
          consecutiveMisses = 0;
          if (currentStreak > bestStreak) bestStreak = currentStreak;
        } else {
          if (habit.strictMode) {
            currentStreak = 0;
            consecutiveMisses = 0;
          } else {
            consecutiveMisses++;
            if (consecutiveMisses >= 2) {
              currentStreak = 0;
              consecutiveMisses = 0;
            }
          }
        }
      }
      day = day.add(const Duration(days: 1));
    }

    return bestStreak;
  }

  /// Calculate the current streak for a stack given all logs.
  /// Streak for a stack = consecutive days where ALL habits in the stack were completed
  static int calculateStackStreak(List<Habit> stackHabits, Map<int, List<HabitLog>> allLogs) {
    if (stackHabits.isEmpty) return 0;

    final logMaps = <int, Map<String, HabitLog>>{};
    for (final habit in stackHabits) {
      final habitLogs = allLogs[habit.id!] ?? [];
      final logMap = <String, HabitLog>{};
      for (final log in habitLogs) {
        logMap[_dateKey(log.date)] = log;
      }
      logMaps[habit.id!] = logMap;
    }

    final today = _normalizeDate(DateTime.now());
    int streak = 0;
    DateTime day = today;

    // Max 1 year lookback
    for (int i = 0; i < 365; i++) {
      bool allCompleted = true;
      for (final habit in stackHabits) {
        final log = logMaps[habit.id!]?[_dateKey(day)];
        final count = log?.completionCount ?? 0;
        if (count < habit.timesPerDay) {
          allCompleted = false;
          break;
        }
      }

      final isToday = _isSameDay(day, today);
      if (allCompleted) {
        streak++;
      } else if (isToday) {
        // Don't penalize today if it hasn't ended yet
        day = day.subtract(const Duration(days: 1));
        continue;
      } else {
        break;
      }

      day = day.subtract(const Duration(days: 1));
    }

    return streak;
  }

  static String _dateKey(DateTime dt) {
    final d = _normalizeDate(dt);
    return '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';
  }

  static DateTime _normalizeDate(DateTime dt) {
    return DateTime(dt.year, dt.month, dt.day);
  }

  static bool _isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }
}
