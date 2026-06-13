import 'package:flutter_test/flutter_test.dart';
import 'package:aadat/data/models/habit.dart';
import 'package:aadat/data/models/habit_log.dart';
import 'package:aadat/data/services/streak_service.dart';

void main() {
  test('Verifies profile statistics calculation matches design requirements against seeded debug data', () {
    final now = DateTime.now();
    DateTime getDay(int offsetDays) {
      final date = now.add(Duration(days: offsetDays));
      return DateTime(date.year, date.month, date.day);
    }

    // 1. Setup the 5 test habits
    final habit0 = Habit(
      id: 0,
      name: "Morning Run",
      targetDaysOfWeek: const [], // Daily
      timesPerDay: 1,
      strictMode: false,
      isArchived: false,
      createdAt: getDay(-14),
    );
    final habit1 = Habit(
      id: 1,
      name: "Read 20 Pages",
      targetDaysOfWeek: const [], // Daily
      timesPerDay: 1,
      strictMode: true,
      isArchived: false,
      createdAt: getDay(-14),
    );
    final habit2 = Habit(
      id: 2,
      name: "Meditate",
      targetDaysOfWeek: const [0, 2, 4], // Mon, Wed, Fri
      timesPerDay: 1,
      strictMode: false,
      isArchived: false,
      createdAt: getDay(-14),
    );
    final habit3 = Habit(
      id: 3,
      name: "No Phone After 10pm",
      targetDaysOfWeek: const [], // Daily
      timesPerDay: 1,
      strictMode: true,
      isArchived: false,
      createdAt: getDay(-14),
    );
    final habit4 = Habit(
      id: 4,
      name: "Drink Water",
      targetDaysOfWeek: const [], // Daily
      timesPerDay: 5,
      strictMode: false,
      isArchived: false,
      createdAt: getDay(-1), // New habit (1-2 days old)
    );

    final habits = [habit0, habit1, habit2, habit3, habit4];
    final logs = <HabitLog>[];

    // -- Habit 0: Morning Run (Long Streak, 14 days)
    for (int i = -13; i <= 0; i++) {
      logs.add(HabitLog(habitId: 0, date: getDay(i), completionCount: 1));
    }

    // -- Habit 1: Read 20 Pages (Long Streak, 14 days)
    for (int i = -13; i <= 0; i++) {
      logs.add(HabitLog(habitId: 1, date: getDay(i), completionCount: 1));
    }

    // -- Habit 2: Meditate (Completed all target days - Mon, Wed, Fri)
    for (int i = -13; i <= 0; i++) {
      final date = getDay(i);
      final weekdayIdx = date.weekday - 1; // 0=Mon..6=Sun
      if (const [0, 2, 4].contains(weekdayIdx)) {
        logs.add(HabitLog(habitId: 2, date: date, completionCount: 1));
      }
    }

    // -- Habit 3: No Phone After 10pm (Broken Streak)
    // Completed days -13 to -4 (10 day streak)
    for (int i = -13; i <= -4; i++) {
      logs.add(HabitLog(habitId: 3, date: getDay(i), completionCount: 1));
    }
    // Missed on -3 (no log)
    // Completed days -2 to 0 (3 day streak)
    for (int i = -2; i <= 0; i++) {
      logs.add(HabitLog(habitId: 3, date: getDay(i), completionCount: 1));
    }

    // -- Habit 4: Drink Water (New habit, 2 days completed)
    logs.add(HabitLog(habitId: 4, date: getDay(-1), completionCount: 5));
    logs.add(HabitLog(habitId: 4, date: getDay(0), completionCount: 5));

    // 2. Perform Stats Grid calculation logic from ProfileScreen
    int totalCheckIns = 0;
    int longestStreak = 0;
    int habitsCreated = habits.length;
    DateTime? earliestDate;

    for (var habit in habits) {
      if (earliestDate == null || habit.createdAt.isBefore(earliestDate)) {
        earliestDate = habit.createdAt;
      }
      
      final habitLogs = logs.where((log) => log.habitId == habit.id).toList();
      final streak = StreakService.calculateBestStreak(habit, habitLogs);
      if (streak > longestStreak) {
        longestStreak = streak;
      }
      
      for (var log in habitLogs) {
        totalCheckIns += log.completionCount;
      }
    }

    int daysTracked = 0;
    if (earliestDate != null) {
      final today = DateTime(now.year, now.month, now.day);
      final earliest = DateTime(earliestDate.year, earliestDate.month, earliestDate.day);
      daysTracked = today.difference(earliest).inDays + 1;
    }

    // 3. Verify correctness of statistics against expected values
    
    // Habits Created: total count, including archived (5 habits)
    expect(habitsCreated, 5);
    
    // Days Tracked: days since earliest habit's createdAt (getDay(-14) to getDay(0) is exactly 15 days)
    expect(daysTracked, 15);

    // Longest Streak: best streak across all habits
    // habit0 (Morning Run): 14 days
    // habit1 (Read 20 Pages): 14 days
    // habit2 (Meditate): target days completed
    // habit3 (No Phone): 10 days
    // habit4 (Drink Water): 2 days
    // The longest streak should be 14 days.
    expect(longestStreak, 14);

    // Total Check-ins: sum of completionCount across all logs
    // habit0: 14 check-ins
    // habit1: 14 check-ins
    // habit2: Mon, Wed, Fri check-ins over 14 days.
    // habit3: 10 + 3 = 13 check-ins
    // habit4: 5 + 5 = 10 check-ins
    int expectedMeditateCheckins = 0;
    for (int i = -13; i <= 0; i++) {
      final date = getDay(i);
      final weekdayIdx = date.weekday - 1;
      if (const [0, 2, 4].contains(weekdayIdx)) {
        expectedMeditateCheckins++;
      }
    }
    final expectedTotalCheckIns = 14 + 14 + expectedMeditateCheckins + 13 + 10;
    expect(totalCheckIns, expectedTotalCheckIns);
  });
}
