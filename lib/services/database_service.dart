import 'package:hive_flutter/hive_flutter.dart';
import '../models/task.dart';
import '../models/category.dart';
import '../models/user_settings.dart';
import '../models/hourly_activity.dart';
import '../models/journal_entry.dart';

class DatabaseService {
  static const String _tasksBoxName = 'tasks';
  static const String _categoriesBoxName = 'categories';
  static const String _settingsBoxName = 'settings';

  static Box<Task>? _tasksBox;
  static Box<Category>? _categoriesBox;
  static Box<UserSettings>? _settingsBox;

  // Initialize Hive database
  static Future<void> initialize() async {
    await Hive.initFlutter();

    // Register adapters
    Hive.registerAdapter(TaskAdapter());
    Hive.registerAdapter(TaskTypeAdapter());
    Hive.registerAdapter(CategoryAdapter());
    Hive.registerAdapter(CategoryEntryAdapter());
    Hive.registerAdapter(UserSettingsAdapter());
    Hive.registerAdapter(HourlyActivityAdapter());
    Hive.registerAdapter(JournalEntryAdapter());
    Hive.registerAdapter(JournalTypeAdapter());

    // Open boxes
    _tasksBox = await Hive.openBox<Task>(_tasksBoxName);
    _categoriesBox = await Hive.openBox<Category>(_categoriesBoxName);
    _settingsBox = await Hive.openBox<UserSettings>(_settingsBoxName);

    // Initialize default settings if not exists
    if (_settingsBox!.isEmpty) {
      final defaultSettings = UserSettings(
        username: 'User',
        lastPdfGenerated: DateTime.now().subtract(const Duration(days: 30)),
      );
      await _settingsBox!.put('settings', defaultSettings);
    }

    // Initialize default categories if not exists
    if (_categoriesBox!.isEmpty) {
      await _createDefaultCategories();
    }
  }

  // Create default categories
  static Future<void> _createDefaultCategories() async {
    final defaultCategories = [
      Category(
        id: 'notes_${DateTime.now().millisecondsSinceEpoch}',
        name: 'Notes',
        color: '#3B82F6', // Blue
        entries: [],
        createdAt: DateTime.now(),
      ),
      Category(
        id: 'learnings_${DateTime.now().millisecondsSinceEpoch}',
        name: 'Learnings',
        color: '#10B981', // Green
        entries: [],
        createdAt: DateTime.now(),
      ),
      Category(
        id: 'books_${DateTime.now().millisecondsSinceEpoch}',
        name: 'Books',
        color: '#F59E0B', // Amber
        entries: [],
        createdAt: DateTime.now(),
      ),
    ];

    for (final category in defaultCategories) {
      await _categoriesBox!.put(category.id, category);
    }
  }

  // Task operations
  static Future<void> addTask(Task task) async {
    await _tasksBox!.put(task.id, task);
  }

  static Future<void> updateTask(Task task) async {
    task.updatedAt = DateTime.now();
    await _tasksBox!.put(task.id, task);
  }

  static Future<void> deleteTask(String taskId) async {
    await _tasksBox!.delete(taskId);
  }

  static List<Task> getTasks() {
    return _tasksBox!.values.toList();
  }

  static List<Task> getTasksForDate(DateTime date) {
    return _tasksBox!.values
        .where(
          (task) =>
              task.dateTime.year == date.year &&
              task.dateTime.month == date.month &&
              task.dateTime.day == date.day,
        )
        .toList()
      ..sort((a, b) => a.dateTime.compareTo(b.dateTime));
  }

  static List<Task> getTodayTasks() {
    final today = DateTime.now();
    return getTasksForDate(today);
  }

  // Category operations
  static Future<void> addCategory(Category category) async {
    await _categoriesBox!.put(category.id, category);
  }

  static Future<void> updateCategory(Category category) async {
    category.updatedAt = DateTime.now();
    await _categoriesBox!.put(category.id, category);
  }

  static Future<void> deleteCategory(String categoryId) async {
    await _categoriesBox!.delete(categoryId);
  }

  static List<Category> getCategories() {
    return _categoriesBox!.values.toList()
      ..sort((a, b) => a.name.compareTo(b.name));
  }

  static Category? getCategory(String categoryId) {
    return _categoriesBox!.get(categoryId);
  }

  // User settings operations
  static UserSettings getUserSettings() {
    return _settingsBox!.get('settings')!;
  }

  static Future<void> updateUserSettings(UserSettings settings) async {
    await _settingsBox!.put('settings', settings);
  }

  // Search operations
  static List<dynamic> search(String query) {
    final results = <dynamic>[];
    final lowerQuery = query.toLowerCase();

    // Search tasks
    final tasks = _tasksBox!.values
        .where((task) => task.title.toLowerCase().contains(lowerQuery))
        .toList();
    results.addAll(tasks);

    // Search categories and their entries
    final categories = _categoriesBox!.values.toList();
    for (final category in categories) {
      // Search category name
      if (category.name.toLowerCase().contains(lowerQuery)) {
        results.add(category);
      }

      // Search category entries
      final matchingEntries = category.entries
          .where((entry) => entry.content.toLowerCase().contains(lowerQuery))
          .toList();
      results.addAll(matchingEntries);
    }

    return results;
  }

  // Get tasks for a specific month
  static List<Task> getTasksForMonth(int year, int month) {
    return _tasksBox!.values
        .where(
          (task) => task.dateTime.year == year && task.dateTime.month == month,
        )
        .toList()
      ..sort((a, b) => a.dateTime.compareTo(b.dateTime));
  }

  // Close all boxes
  static Future<void> close() async {
    await _tasksBox?.close();
    await _categoriesBox?.close();
    await _settingsBox?.close();
  }
}
