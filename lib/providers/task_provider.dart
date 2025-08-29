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

  Future<void> addTask(
    String title,
    DateTime dateTime, {
    TaskType taskType = TaskType.checkbox,
    bool isDaily = false,
  }) async {
    try {
      if (isDaily) {
        // Create daily tasks for the next 30 days using the specified time
        final startDate = DateTime.now();
        for (int i = 0; i < 30; i++) {
          final taskDate = startDate.add(Duration(days: i));
          final task = Task(
            id: 'daily_task_${title.hashCode}_${taskDate.millisecondsSinceEpoch}',
            title: title,
            dateTime: DateTime(
              taskDate.year,
              taskDate.month,
              taskDate.day,
              dateTime.hour, // Use the specified time
              dateTime.minute,
            ),
            createdAt: DateTime.now(),
            taskType: taskType,
          );

          await DatabaseService.addTask(task);
          _tasks.add(task);
        }
      } else {
        final task = Task(
          id: 'task_${DateTime.now().millisecondsSinceEpoch}',
          title: title,
          dateTime: dateTime,
          createdAt: DateTime.now(),
          taskType: taskType,
        );

        await DatabaseService.addTask(task);
        _tasks.add(task);
      }
      notifyListeners();
    } catch (e) {
      debugPrint('Error adding task: $e');
    }
  }

  // Method to check and create daily tasks for a specific date
  Future<void> ensureDailyTasksForDate(DateTime date) async {
    // This will be used to extend daily tasks when navigating to future dates
    // For now, we'll create tasks for 30 days when a daily task is first created
    notifyListeners();
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

  Future<void> deleteDailyTasks(String taskTitle) async {
    try {
      // Find all tasks with the same title (daily tasks)
      final tasksToDelete = _tasks
          .where((task) => task.title == taskTitle)
          .toList();

      // Delete each task from database and local list
      for (final task in tasksToDelete) {
        await DatabaseService.deleteTask(task.id);
        _tasks.removeWhere((t) => t.id == task.id);
      }

      notifyListeners();
      debugPrint(
        'Deleted ${tasksToDelete.length} daily tasks with title: $taskTitle',
      );
    } catch (e) {
      debugPrint('Error deleting daily tasks: $e');
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
