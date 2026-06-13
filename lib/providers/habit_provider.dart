import 'package:flutter/foundation.dart';
import '../data/models/habit.dart';
import '../data/models/habit_log.dart';
import '../data/models/habit_stack.dart';
import '../data/services/database_service.dart';
import '../data/services/streak_service.dart';

class HabitProvider extends ChangeNotifier {
  late DatabaseService _db;
  bool _initialized = false;

  List<Habit> _activeHabits = [];
  List<Habit> _archivedHabits = [];
  Map<int, HabitLog> _todayLogs = {};
  final Map<int, List<HabitLog>> _allLogs = {};
  final Map<int, int> _streaks = {};
  final Map<int, int> _bestStreaks = {};
  List<HabitStack> _stacks = [];

  List<Habit> get activeHabits => _activeHabits;
  List<Habit> get archivedHabits => _archivedHabits;
  Map<int, HabitLog> get todayLogs => _todayLogs;
  List<HabitStack> get stacks => _stacks;
  bool get initialized => _initialized;

  Future<void> init() async {
    _db = await DatabaseService.getInstance();
    await refresh();
    _initialized = true;
    notifyListeners();
  }

  Future<void> refresh() async {
    _activeHabits = await _db.getActiveHabits();
    _archivedHabits = await _db.getArchivedHabits();
    _todayLogs = await _db.getAllTodayLogs();
    _stacks = await _db.getAllStacks();

    for (final habit in [..._activeHabits, ..._archivedHabits]) {
      final logs = await _db.getLogsForHabit(habit.id!);
      _allLogs[habit.id!] = logs;
      _streaks[habit.id!] = StreakService.calculateCurrentStreak(habit, logs);
      _bestStreaks[habit.id!] = StreakService.calculateBestStreak(habit, logs);
    }

    notifyListeners();
  }

  List<Habit> get todayHabits {
    final today = DateTime.now();
    return _activeHabits.where((h) => h.isScheduledFor(today)).toList();
  }

  int remainingTodayCount() {
    return todayHabits.where((h) {
      final log = _todayLogs[h.id];
      return (log?.completionCount ?? 0) < h.timesPerDay;
    }).length;
  }

  int getCompletionCount(int habitId) {
    return _todayLogs[habitId]?.completionCount ?? 0;
  }

  bool isCompleted(int habitId, int timesPerDay) {
    return getCompletionCount(habitId) >= timesPerDay;
  }

  int getStreak(int habitId) => _streaks[habitId] ?? 0;
  int getBestStreak(int habitId) => _bestStreaks[habitId] ?? 0;

  List<HabitLog> getLogsForHabit(int habitId) => _allLogs[habitId] ?? [];

  Future<List<HabitLog>> getLogsForMonth(int year, int month) async {
    return _db.getLogsForMonth(year, month);
  }

  Habit? _findActiveHabit(int id) {
    for (final h in _activeHabits) {
      if (h.id == id) return h;
    }
    return null;
  }

  HabitStack? getStackForHabit(int habitId) {
    for (final s in _stacks) {
      if (s.habitIds.contains(habitId)) {
        return s;
      }
    }
    return null;
  }

  int getStackStreak(HabitStack stack) {
    final habitsInStack = <Habit>[];
    for (final id in stack.habitIds) {
      final h = _findActiveHabit(id);
      if (h != null) {
        habitsInStack.add(h);
      }
    }
    return StreakService.calculateStackStreak(habitsInStack, _allLogs);
  }

  bool shouldHighlightHabit(int habitId, HabitStack stack) {
    int firstUncompletedIdx = -1;
    for (int i = 0; i < stack.habitIds.length; i++) {
      final id = stack.habitIds[i];
      final h = _findActiveHabit(id);
      if (h == null) continue;
      final completed = isCompleted(id, h.timesPerDay);
      if (!completed) {
        firstUncompletedIdx = i;
        break;
      }
    }
    if (firstUncompletedIdx > 0) {
      return stack.habitIds[firstUncompletedIdx] == habitId;
    }
    return false;
  }

  // ── CRUD ────────────────────────────────────────────────────────────────

  Future<void> addHabit(Habit habit) async {
    await _db.saveHabit(habit);
    await refresh();
    await DatabaseService.updateWidgetDataFromDb();
  }

  Future<void> updateHabit(Habit habit) async {
    await _db.saveHabit(habit);
    await refresh();
    await DatabaseService.updateWidgetDataFromDb();
  }

  Future<void> createStack(String name, List<int> habitIds) async {
    final stack = HabitStack(
      name: name,
      habitIds: habitIds,
      createdAt: DateTime.now(),
    );
    await _db.saveStack(stack);
    await refresh();
    await DatabaseService.updateWidgetDataFromDb();
  }

  Future<void> updateStack(HabitStack stack) async {
    await _db.saveStack(stack);
    await refresh();
    await DatabaseService.updateWidgetDataFromDb();
  }

  Future<void> deleteStack(int stackId) async {
    await _db.deleteStack(stackId);
    await refresh();
    await DatabaseService.updateWidgetDataFromDb();
  }

  Future<void> checkIn(int habitId) async {
    final log = await _db.incrementToday(habitId);
    _todayLogs[habitId] = log;
    final habit = _activeHabits.firstWhere((h) => h.id == habitId);
    final logs = await _db.getLogsForHabit(habitId);
    _allLogs[habitId] = logs;
    _streaks[habitId] = StreakService.calculateCurrentStreak(habit, logs);
    _bestStreaks[habitId] = StreakService.calculateBestStreak(habit, logs);
    notifyListeners();
    await DatabaseService.updateWidgetDataFromDb();
  }

  Future<void> undo(int habitId) async {
    final log = await _db.decrementToday(habitId);
    if (log != null) {
      _todayLogs[habitId] = log;
    } else {
      _todayLogs.remove(habitId);
    }
    final habit = _activeHabits.firstWhere((h) => h.id == habitId);
    final logs = await _db.getLogsForHabit(habitId);
    _allLogs[habitId] = logs;
    _streaks[habitId] = StreakService.calculateCurrentStreak(habit, logs);
    notifyListeners();
    await DatabaseService.updateWidgetDataFromDb();
  }

  Future<void> archiveHabit(int habitId) async {
    await _db.archiveHabit(habitId, archive: true);
    await refresh();
    await DatabaseService.updateWidgetDataFromDb();
  }

  Future<void> restoreHabit(int habitId) async {
    await _db.archiveHabit(habitId, archive: false);
    await refresh();
    await DatabaseService.updateWidgetDataFromDb();
  }

  Future<void> deleteHabit(int habitId) async {
    await _db.deleteHabit(habitId);
    for (final stack in _stacks) {
      if (stack.habitIds.contains(habitId)) {
        final updatedIds = List<int>.from(stack.habitIds)..remove(habitId);
        if (updatedIds.isEmpty) {
          await _db.deleteStack(stack.id!);
        } else {
          await _db.saveStack(stack.copyWith(habitIds: updatedIds));
        }
        break;
      }
    }
    await refresh();
    await DatabaseService.updateWidgetDataFromDb();
  }


}
