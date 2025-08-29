import 'package:hive/hive.dart';

part 'task.g.dart';

// Task type enum
@HiveType(typeId: 4)
enum TaskType {
  @HiveField(0)
  checkbox,
  @HiveField(1)
  text,
  @HiveField(2)
  number,
}

@HiveType(typeId: 0)
class Task extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  String title;

  @HiveField(2)
  DateTime dateTime;

  @HiveField(3)
  bool isCompleted;

  @HiveField(4)
  DateTime createdAt;

  @HiveField(5)
  DateTime? updatedAt;

  @HiveField(6)
  TaskType taskType;

  @HiveField(7)
  String? textValue;

  @HiveField(8)
  double? numberValue;

  Task({
    required this.id,
    required this.title,
    required this.dateTime,
    this.isCompleted = false,
    required this.createdAt,
    this.updatedAt,
    this.taskType = TaskType.checkbox,
    this.textValue,
    this.numberValue,
  });

  // Get formatted time string (e.g., "10:30 AM")
  String get timeString {
    final hour = dateTime.hour;
    final minute = dateTime.minute;
    final period = hour >= 12 ? 'PM' : 'AM';
    final displayHour = hour > 12 ? hour - 12 : (hour == 0 ? 12 : hour);
    return '${displayHour.toString().padLeft(2, '0')}:${minute.toString().padLeft(2, '0')} $period';
  }

  // Check if task is for today
  bool get isToday {
    final now = DateTime.now();
    return dateTime.year == now.year &&
        dateTime.month == now.month &&
        dateTime.day == now.day;
  }

  // Get date string (e.g., "2024-03-15")
  String get dateString {
    return '${dateTime.year}-${dateTime.month.toString().padLeft(2, '0')}-${dateTime.day.toString().padLeft(2, '0')}';
  }
}
