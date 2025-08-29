import 'package:hive/hive.dart';

part 'user_settings.g.dart';

@HiveType(typeId: 3)
class UserSettings extends HiveObject {
  @HiveField(0)
  String username;

  @HiveField(1)
  bool isDarkMode;

  @HiveField(2)
  String primaryColor; // Hex color string

  @HiveField(3)
  DateTime lastPdfGenerated;

  UserSettings({
    required this.username,
    this.isDarkMode = false,
    this.primaryColor = '#6366F1', // Indigo
    required this.lastPdfGenerated,
  });
}
