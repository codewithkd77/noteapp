import 'package:flutter/foundation.dart';
import '../models/task.dart';
import '../services/database_service.dart';

class TaskProvider extends ChangeNotifier {
  List<Task> _tasks = [];
  DateTime _selectedDate = DateTime.now();
  bool _isLoading = false;

  List<Task> get tasks => _tasks;
  DateTime get selectedDate => _selectedDate;
  bool get isLoading => _isLoading;

  List<Task> get todayTasks {
    final today = DateTime.now();
    return _tasks
        .where(
          (task) =>
              task.dateTime.year == today.year &&
              task.dateTime.month == today.month &&
              task.dateTime.day == today.day,
        )
        .toList()
      ..sort((a, b) => a.dateTime.compareTo(b.dateTime));
  }

  List<Task> get selectedDateTasks {
    return _tasks
        .where(
          (task) =>
              task.dateTime.year == _selectedDate.year &&
              task.dateTime.month == _selectedDate.month &&
              task.dateTime.day == _selectedDate.day,
        )
        .toList()
      ..sort((a, b) => a.dateTime.compareTo(b.dateTime));
  }

  Future<void> loadTasks() async {
    _isLoading = true;
    notifyListeners();

    try {
      _tasks = DatabaseService.getTasks();
    } catch (e) {
      debugPrint('Error loading tasks: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Create Royal Routine tasks for any specific date
  Future<void> ensureRoyalRoutineTasksForDate(DateTime date) async {
    final dateStart = DateTime(date.year, date.month, date.day);
    final dateEnd = dateStart.add(const Duration(days: 1));

    // Check if Royal Routine tasks already exist for this date
    final hasRoyalTasks = _tasks.any(
      (task) =>
          task.isDefault &&
          task.dateTime.isAfter(dateStart) &&
          task.dateTime.isBefore(dateEnd),
    );

    if (!hasRoyalTasks) {
      await _createRoyalRoutineTasks(dateStart);
      notifyListeners();
    }
  }

  Future<void> _createRoyalRoutineTasks(DateTime date) async {
    final defaultTasks = [
      // 🌅 Morning Rituals Section
      Task(
        id: 'royal_morning_wakeup_${date.millisecondsSinceEpoch}',
        title: '☐ Wake up at ____ AM',
        dateTime: date.add(const Duration(hours: 6)),
        createdAt: DateTime.now(),
        taskType: TaskType.text,
        isDefault: true,
      ),
      Task(
        id: 'royal_morning_meditation_time_${date.millisecondsSinceEpoch}',
        title: '☐ Meditation (____ mins)',
        dateTime: date.add(const Duration(hours: 6, minutes: 5)),
        createdAt: DateTime.now(),
        taskType: TaskType.number,
        isDefault: true,
      ),
      Task(
        id: 'royal_morning_mindfulness_${date.millisecondsSinceEpoch}',
        title: '☐ Mindfulness practice',
        dateTime: date.add(const Duration(hours: 6, minutes: 10)),
        createdAt: DateTime.now(),
        taskType: TaskType.checkbox,
        isDefault: true,
      ),
      Task(
        id: 'royal_morning_gratitude_${date.millisecondsSinceEpoch}',
        title: '☐ Gratitude note',
        dateTime: date.add(const Duration(hours: 6, minutes: 15)),
        createdAt: DateTime.now(),
        taskType: TaskType.text,
        isDefault: true,
      ),
      Task(
        id: 'royal_morning_reading_${date.millisecondsSinceEpoch}',
        title: '☐ Reading (____ pages / mins)',
        dateTime: date.add(const Duration(hours: 6, minutes: 20)),
        createdAt: DateTime.now(),
        taskType: TaskType.number,
        isDefault: true,
      ),
      Task(
        id: 'royal_morning_workout_${date.millisecondsSinceEpoch}',
        title: '☐ Workout / Training (____ mins)',
        dateTime: date.add(const Duration(hours: 6, minutes: 25)),
        createdAt: DateTime.now(),
        taskType: TaskType.number,
        isDefault: true,
      ),

      // 📖 Day's Focus Section
      Task(
        id: 'royal_priority_1_${date.millisecondsSinceEpoch}',
        title: 'Today\'s Priority #1',
        dateTime: date.add(const Duration(hours: 8)),
        createdAt: DateTime.now(),
        taskType: TaskType.text,
        isDefault: true,
      ),
      Task(
        id: 'royal_priority_2_${date.millisecondsSinceEpoch}',
        title: 'Today\'s Priority #2',
        dateTime: date.add(const Duration(hours: 8, minutes: 5)),
        createdAt: DateTime.now(),
        taskType: TaskType.text,
        isDefault: true,
      ),
      Task(
        id: 'royal_priority_3_${date.millisecondsSinceEpoch}',
        title: 'Today\'s Priority #3',
        dateTime: date.add(const Duration(hours: 8, minutes: 10)),
        createdAt: DateTime.now(),
        taskType: TaskType.text,
        isDefault: true,
      ),
      Task(
        id: 'royal_notes_ideas_${date.millisecondsSinceEpoch}',
        title: 'Notes / Ideas / Inspirations',
        dateTime: date.add(const Duration(hours: 8, minutes: 15)),
        createdAt: DateTime.now(),
        taskType: TaskType.text,
        isDefault: true,
      ),

      // 🌙 Night Rituals Section
      Task(
        id: 'royal_night_reflection_${date.millisecondsSinceEpoch}',
        title: '☐ Reflection & Journaling',
        dateTime: date.add(const Duration(hours: 20)),
        createdAt: DateTime.now(),
        taskType: TaskType.checkbox,
        isDefault: true,
      ),
      Task(
        id: 'royal_night_mindfulness_${date.millisecondsSinceEpoch}',
        title: '☐ Mindfulness / Breathing (____ mins)',
        dateTime: date.add(const Duration(hours: 20, minutes: 5)),
        createdAt: DateTime.now(),
        taskType: TaskType.number,
        isDefault: true,
      ),
      Task(
        id: 'royal_night_reading_${date.millisecondsSinceEpoch}',
        title: '☐ Reading (____ pages / mins)',
        dateTime: date.add(const Duration(hours: 20, minutes: 10)),
        createdAt: DateTime.now(),
        taskType: TaskType.number,
        isDefault: true,
      ),
      Task(
        id: 'royal_night_gratitude_${date.millisecondsSinceEpoch}',
        title: '☐ Gratitude',
        dateTime: date.add(const Duration(hours: 20, minutes: 15)),
        createdAt: DateTime.now(),
        taskType: TaskType.text,
        isDefault: true,
      ),
      Task(
        id: 'royal_night_sleep_${date.millisecondsSinceEpoch}',
        title: '☐ Sleep at ____ PM',
        dateTime: date.add(const Duration(hours: 20, minutes: 20)),
        createdAt: DateTime.now(),
        taskType: TaskType.text,
        isDefault: true,
      ),

      // 🏆 Daily Self-Tracking Section
      Task(
        id: 'royal_track_meditation_${date.millisecondsSinceEpoch}',
        title: 'Meditation: ☐ Done / Time',
        dateTime: date.add(const Duration(hours: 12)),
        createdAt: DateTime.now(),
        taskType: TaskType.number,
        isDefault: true,
      ),
      Task(
        id: 'royal_track_mindfulness_${date.millisecondsSinceEpoch}',
        title: 'Mindfulness: ☐ Done',
        dateTime: date.add(const Duration(hours: 12, minutes: 5)),
        createdAt: DateTime.now(),
        taskType: TaskType.checkbox,
        isDefault: true,
      ),
      Task(
        id: 'royal_track_workout_${date.millisecondsSinceEpoch}',
        title: 'Workout: ☐ Done / Type',
        dateTime: date.add(const Duration(hours: 12, minutes: 10)),
        createdAt: DateTime.now(),
        taskType: TaskType.text,
        isDefault: true,
      ),
      Task(
        id: 'royal_track_reading_pages_${date.millisecondsSinceEpoch}',
        title: 'Reading: Pages',
        dateTime: date.add(const Duration(hours: 12, minutes: 15)),
        createdAt: DateTime.now(),
        taskType: TaskType.number,
        isDefault: true,
      ),
      Task(
        id: 'royal_track_diet_${date.millisecondsSinceEpoch}',
        title: 'Diet / Nutrition',
        dateTime: date.add(const Duration(hours: 12, minutes: 20)),
        createdAt: DateTime.now(),
        taskType: TaskType.text,
        isDefault: true,
      ),

      // 📌 Reflection Section
      Task(
        id: 'royal_reflection_win_${date.millisecondsSinceEpoch}',
        title: 'One win today',
        dateTime: date.add(const Duration(hours: 21)),
        createdAt: DateTime.now(),
        taskType: TaskType.text,
        isDefault: true,
      ),
      Task(
        id: 'royal_reflection_lesson_${date.millisecondsSinceEpoch}',
        title: 'Lesson learned',
        dateTime: date.add(const Duration(hours: 21, minutes: 5)),
        createdAt: DateTime.now(),
        taskType: TaskType.text,
        isDefault: true,
      ),
      Task(
        id: 'royal_reflection_mood_${date.millisecondsSinceEpoch}',
        title: 'Mood rating (1–10)',
        dateTime: date.add(const Duration(hours: 21, minutes: 10)),
        createdAt: DateTime.now(),
        taskType: TaskType.number,
        isDefault: true,
      ),
    ];

    // Add all default tasks
    for (final task in defaultTasks) {
      await DatabaseService.addTask(task);
      _tasks.add(task);
    }
  }

  Future<void> addTask(String title, DateTime dateTime) async {
    try {
      final task = Task(
        id: 'task_${DateTime.now().millisecondsSinceEpoch}',
        title: title,
        dateTime: dateTime,
        createdAt: DateTime.now(),
        taskType: TaskType.checkbox,
        isDefault: false,
      );

      await DatabaseService.addTask(task);
      _tasks.add(task);
      notifyListeners();
    } catch (e) {
      debugPrint('Error adding task: $e');
    }
  }

  Future<void> updateTask(Task task) async {
    try {
      await DatabaseService.updateTask(task);
      final index = _tasks.indexWhere((t) => t.id == task.id);
      if (index != -1) {
        _tasks[index] = task;
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Error updating task: $e');
    }
  }

  Future<void> toggleTaskCompletion(Task task) async {
    try {
      task.isCompleted = !task.isCompleted;
      await updateTask(task);
    } catch (e) {
      debugPrint('Error toggling task completion: $e');
    }
  }

  Future<void> deleteTask(String taskId) async {
    try {
      await DatabaseService.deleteTask(taskId);
      _tasks.removeWhere((task) => task.id == taskId);
      notifyListeners();
    } catch (e) {
      debugPrint('Error deleting task: $e');
    }
  }

  void setSelectedDate(DateTime date) {
    _selectedDate = date;
    notifyListeners();
  }

  void goToPreviousDay() {
    _selectedDate = _selectedDate.subtract(const Duration(days: 1));
    notifyListeners();
  }

  void goToNextDay() {
    _selectedDate = _selectedDate.add(const Duration(days: 1));
    notifyListeners();
  }

  void goToToday() {
    _selectedDate = DateTime.now();
    notifyListeners();
  }
}
