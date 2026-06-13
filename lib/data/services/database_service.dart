import 'package:flutter/foundation.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:home_widget/home_widget.dart';
import '../models/habit.dart';
import '../models/habit_log.dart';
import '../models/habit_stack.dart';
import './streak_service.dart';

class DatabaseService {
  static DatabaseService? _instance;
  static Database? _database;

  DatabaseService._();

  static Future<DatabaseService> getInstance() async {
    _instance ??= DatabaseService._();
    await _instance!._init();
    return _instance!;
  }

  Future<void> _init() async {
    if (_database != null) return;
    final dbPath = await getDatabasesPath();
    _database = await openDatabase(
      join(dbPath, 'ink.db'),
      version: 2,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE habits (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            name TEXT NOT NULL,
            targetDaysOfWeek TEXT NOT NULL DEFAULT '',
            timesPerDay INTEGER NOT NULL DEFAULT 1,
            strictMode INTEGER NOT NULL DEFAULT 0,
            isArchived INTEGER NOT NULL DEFAULT 0,
            createdAt TEXT NOT NULL
          )
        ''');
        await db.execute('''
          CREATE TABLE habit_logs (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            habitId INTEGER NOT NULL,
            date TEXT NOT NULL,
            completionCount INTEGER NOT NULL DEFAULT 0,
            UNIQUE(habitId, date)
          )
        ''');
        await db.execute('CREATE INDEX idx_logs_date ON habit_logs(date)');
        await db.execute(
            'CREATE INDEX idx_logs_habitId ON habit_logs(habitId)');
        await db.execute('''
          CREATE TABLE habit_stacks (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            name TEXT NOT NULL,
            habitIds TEXT NOT NULL,
            createdAt TEXT NOT NULL
          )
        ''');
      },
      onUpgrade: (db, oldVersion, newVersion) async {
        if (oldVersion < 2) {
          await db.execute('''
            CREATE TABLE IF NOT EXISTS habit_stacks (
              id INTEGER PRIMARY KEY AUTOINCREMENT,
              name TEXT NOT NULL,
              habitIds TEXT NOT NULL,
              createdAt TEXT NOT NULL
            )
          ''');
        }
      },
    );
  }

  Database get db => _database!;

  // ── Habits ──────────────────────────────────────────────────────────────

  Future<List<Habit>> getActiveHabits() async {
    final maps = await db.query(
      'habits',
      where: 'isArchived = ?',
      whereArgs: [0],
      orderBy: 'createdAt ASC',
    );
    return maps.map(Habit.fromMap).toList();
  }

  Future<List<Habit>> getArchivedHabits() async {
    final maps = await db.query(
      'habits',
      where: 'isArchived = ?',
      whereArgs: [1],
      orderBy: 'createdAt DESC',
    );
    return maps.map(Habit.fromMap).toList();
  }

  Future<int> saveHabit(Habit habit) async {
    if (habit.id == null) {
      return db.insert('habits', habit.toMap());
    } else {
      await db.update(
        'habits',
        habit.toMap(),
        where: 'id = ?',
        whereArgs: [habit.id],
      );
      return habit.id!;
    }
  }

  Future<void> deleteHabit(int id) async {
    await db.delete('habits', where: 'id = ?', whereArgs: [id]);
    await db.delete('habit_logs', where: 'habitId = ?', whereArgs: [id]);
  }

  Future<void> archiveHabit(int id, {required bool archive}) async {
    await db.update(
      'habits',
      {'isArchived': archive ? 1 : 0},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // ── HabitLogs ────────────────────────────────────────────────────────────

  Future<List<HabitLog>> getLogsForHabit(int habitId) async {
    final maps = await db.query(
      'habit_logs',
      where: 'habitId = ?',
      whereArgs: [habitId],
      orderBy: 'date ASC',
    );
    return maps.map(HabitLog.fromMap).toList();
  }

  Future<HabitLog?> getTodayLog(int habitId) async {
    final today = _dateKey(DateTime.now());
    final maps = await db.query(
      'habit_logs',
      where: 'habitId = ? AND date = ?',
      whereArgs: [habitId, today],
    );
    return maps.isEmpty ? null : HabitLog.fromMap(maps.first);
  }

  Future<Map<int, HabitLog>> getAllTodayLogs() async {
    final today = _dateKey(DateTime.now());
    final maps = await db.query(
      'habit_logs',
      where: 'date = ?',
      whereArgs: [today],
    );
    final result = <int, HabitLog>{};
    for (final map in maps) {
      final log = HabitLog.fromMap(map);
      result[log.habitId] = log;
    }
    return result;
  }

  Future<HabitLog> incrementToday(int habitId) async {
    final today = _dateKey(DateTime.now());
    final existing = await getTodayLog(habitId);
    if (existing == null) {
      final id = await db.insert('habit_logs', {
        'habitId': habitId,
        'date': today,
        'completionCount': 1,
      });
      return HabitLog(id: id, habitId: habitId, date: DateTime.now(), completionCount: 1);
    } else {
      final newCount = existing.completionCount + 1;
      await db.update(
        'habit_logs',
        {'completionCount': newCount},
        where: 'id = ?',
        whereArgs: [existing.id],
      );
      return existing.copyWith(completionCount: newCount);
    }
  }

  Future<HabitLog?> decrementToday(int habitId) async {
    final existing = await getTodayLog(habitId);
    if (existing == null || existing.completionCount <= 0) return null;
    final newCount = existing.completionCount - 1;
    await db.update(
      'habit_logs',
      {'completionCount': newCount},
      where: 'id = ?',
      whereArgs: [existing.id],
    );
    return existing.copyWith(completionCount: newCount);
  }

  Future<List<HabitLog>> getLogsForMonth(int year, int month) async {
    final start =
        '${year.toString()}-${month.toString().padLeft(2, '0')}-01';
    final endMonth = month == 12 ? 1 : month + 1;
    final endYear = month == 12 ? year + 1 : year;
    final end =
        '${endYear.toString()}-${endMonth.toString().padLeft(2, '0')}-01';
    final maps = await db.query(
      'habit_logs',
      where: 'date >= ? AND date < ?',
      whereArgs: [start, end],
    );
    return maps.map(HabitLog.fromMap).toList();
  }

  static String _dateKey(DateTime dt) {
    return '${dt.year}-${dt.month.toString().padLeft(2, '0')}-${dt.day.toString().padLeft(2, '0')}';
  }

  Future<Habit?> getHabitById(int id) async {
    final maps = await db.query(
      'habits',
      where: 'id = ?',
      whereArgs: [id],
    );
    return maps.isEmpty ? null : Habit.fromMap(maps.first);
  }

  Future<HabitLog> setTodayCompletion(int habitId, int count) async {
    final today = _dateKey(DateTime.now());
    final existing = await getTodayLog(habitId);
    if (existing == null) {
      final id = await db.insert('habit_logs', {
        'habitId': habitId,
        'date': today,
        'completionCount': count,
      });
      return HabitLog(id: id, habitId: habitId, date: DateTime.now(), completionCount: count);
    } else {
      await db.update(
        'habit_logs',
        {'completionCount': count},
        where: 'id = ?',
        whereArgs: [existing.id],
      );
      return existing.copyWith(completionCount: count);
    }
  }

  // ── HabitStacks ─────────────────────────────────────────────────────────

  Future<List<HabitStack>> getAllStacks() async {
    final maps = await db.query('habit_stacks', orderBy: 'createdAt ASC');
    return maps.map(HabitStack.fromMap).toList();
  }

  Future<int> saveStack(HabitStack stack) async {
    if (stack.id == null) {
      return db.insert('habit_stacks', stack.toMap());
    } else {
      await db.update(
        'habit_stacks',
        stack.toMap(),
        where: 'id = ?',
        whereArgs: [stack.id],
      );
      return stack.id!;
    }
  }

  Future<void> deleteStack(int id) async {
    await db.delete('habit_stacks', where: 'id = ?', whereArgs: [id]);
  }

  static Future<void> updateWidgetDataFromDb() async {
    try {
      final dbService = await DatabaseService.getInstance();
      final activeHabits = await dbService.getActiveHabits();
      final today = DateTime.now();
      final todayHabits = activeHabits.where((h) => h.isScheduledFor(today)).toList();
      final todayLogs = await dbService.getAllTodayLogs();

      // Sort incomplete habits first
      todayHabits.sort((a, b) {
        final aLog = todayLogs[a.id];
        final bLog = todayLogs[b.id];
        final aCompleted = (aLog?.completionCount ?? 0) >= a.timesPerDay;
        final bCompleted = (bLog?.completionCount ?? 0) >= b.timesPerDay;
        if (aCompleted && !bCompleted) return 1;
        if (!aCompleted && bCompleted) return -1;
        return 0;
      });

      final totalHabitsCount = todayHabits.length;
      final count = totalHabitsCount < 4 ? totalHabitsCount : 4;
      await HomeWidget.saveWidgetData<int>('habit_count', count);

      final truncatedCount = totalHabitsCount > 4 ? totalHabitsCount - 4 : 0;
      await HomeWidget.saveWidgetData<int>('habit_truncated_count', truncatedCount);

      for (int i = 0; i < 4; i++) {
        if (i < count) {
          final habit = todayHabits[i];
          final log = todayLogs[habit.id];
          final completed = (log?.completionCount ?? 0) >= habit.timesPerDay;

          final logs = await dbService.getLogsForHabit(habit.id!);
          final streak = StreakService.calculateCurrentStreak(habit, logs);

          await HomeWidget.saveWidgetData<int>('habit_id_$i', habit.id!);
          await HomeWidget.saveWidgetData<String>('habit_name_$i', habit.name);
          await HomeWidget.saveWidgetData<bool>('habit_completed_$i', completed);
          await HomeWidget.saveWidgetData<int>('habit_streak_$i', streak);
        } else {
          await HomeWidget.saveWidgetData<int>('habit_id_$i', -1);
          await HomeWidget.saveWidgetData<String>('habit_name_$i', '');
          await HomeWidget.saveWidgetData<bool>('habit_completed_$i', false);
          await HomeWidget.saveWidgetData<int>('habit_streak_$i', 0);
        }
      }

      await HomeWidget.updateWidget(
        name: 'AadatWidgetProvider',
        androidName: 'AadatWidgetProvider',
      );
    } catch (e) {
      // Avoid crashing background isolate or main thread
      debugPrint('Error updating widget: $e');
    }
  }


}
