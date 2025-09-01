import 'package:hive/hive.dart';

part 'hourly_activity.g.dart';

@HiveType(typeId: 5)
class HourlyActivity extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final DateTime date;

  @HiveField(2)
  final int hour; // 0-23

  @HiveField(3)
  String activity;

  @HiveField(4)
  final DateTime createdAt;

  @HiveField(5)
  DateTime updatedAt;

  HourlyActivity({
    required this.id,
    required this.date,
    required this.hour,
    required this.activity,
    required this.createdAt,
    required this.updatedAt,
  });

  String get hourDisplay {
    if (hour == 0) return '12:00 AM';
    if (hour < 12) return '$hour:00 AM';
    if (hour == 12) return '12:00 PM';
    return '${hour - 12}:00 PM';
  }

  String get timeRange {
    final nextHour = hour + 1;
    final currentDisplay = hourDisplay;
    final nextDisplay = nextHour == 24
        ? '12:00 AM'
        : nextHour == 12
        ? '12:00 PM'
        : nextHour > 12
        ? '${nextHour - 12}:00 PM'
        : '$nextHour:00 AM';
    return '$currentDisplay - $nextDisplay';
  }

  void updateActivity(String newActivity) {
    activity = newActivity;
    updatedAt = DateTime.now();
    save();
  }
}
