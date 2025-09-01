import 'package:flutter/foundation.dart';
import 'package:hive/hive.dart';
import '../models/hourly_activity.dart';

class HourlyTasksProvider extends ChangeNotifier {
  static const String _boxName = 'hourlyActivities';
  Box<HourlyActivity>? _box;

  List<HourlyActivity> _activities = [];
  DateTime _selectedDate = DateTime.now();

  List<HourlyActivity> get activities => _activities;
  DateTime get selectedDate => _selectedDate;

  Future<void> initialize() async {
    _box = await Hive.openBox<HourlyActivity>(_boxName);
    await loadActivitiesForDate(_selectedDate);
  }

  Future<void> loadActivitiesForDate(DateTime date) async {
    _selectedDate = DateTime(date.year, date.month, date.day);

    if (_box == null) return;

    // Load existing activities for the selected date
    final existingActivities = _box!.values
        .where(
          (activity) =>
              activity.date.year == _selectedDate.year &&
              activity.date.month == _selectedDate.month &&
              activity.date.day == _selectedDate.day,
        )
        .toList();

    // Create a map for quick lookup
    final activityMap = <int, HourlyActivity>{};
    for (final activity in existingActivities) {
      activityMap[activity.hour] = activity;
    }

    // Create activities for all 24 hours
    _activities = List.generate(24, (hour) {
      if (activityMap.containsKey(hour)) {
        return activityMap[hour]!;
      } else {
        // Create a new activity for this hour
        final newActivity = HourlyActivity(
          id: '${_selectedDate.millisecondsSinceEpoch}_$hour',
          date: _selectedDate,
          hour: hour,
          activity: '',
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );
        return newActivity;
      }
    });

    notifyListeners();
  }

  Future<void> updateActivity(int hour, String activity) async {
    if (_box == null || hour < 0 || hour > 23) return;

    final existingActivity = _activities.firstWhere(
      (a) => a.hour == hour,
      orElse: () => HourlyActivity(
        id: '${_selectedDate.millisecondsSinceEpoch}_$hour',
        date: _selectedDate,
        hour: hour,
        activity: activity,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),
    );

    if (existingActivity.key != null) {
      // Update existing activity
      existingActivity.updateActivity(activity);
    } else {
      // Save new activity
      existingActivity.activity = activity;
      await _box!.add(existingActivity);
    }

    // Update the local list
    final index = _activities.indexWhere((a) => a.hour == hour);
    if (index != -1) {
      _activities[index] = existingActivity;
    }

    notifyListeners();
  }

  Future<void> changeDate(DateTime newDate) async {
    await loadActivitiesForDate(newDate);
  }

  Future<void> clearActivitiesForDate(DateTime date) async {
    if (_box == null) return;

    final activitiesToDelete = _box!.values
        .where(
          (activity) =>
              activity.date.year == date.year &&
              activity.date.month == date.month &&
              activity.date.day == date.day,
        )
        .toList();

    for (final activity in activitiesToDelete) {
      await activity.delete();
    }

    if (date.year == _selectedDate.year &&
        date.month == _selectedDate.month &&
        date.day == _selectedDate.day) {
      await loadActivitiesForDate(_selectedDate);
    }
  }

  List<HourlyActivity> getActivitiesForDateRange(DateTime start, DateTime end) {
    if (_box == null) return [];

    return _box!.values
        .where(
          (activity) =>
              activity.date.isAfter(start.subtract(const Duration(days: 1))) &&
              activity.date.isBefore(end.add(const Duration(days: 1))),
        )
        .toList();
  }
}
