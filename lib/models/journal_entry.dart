import 'package:hive/hive.dart';

part 'journal_entry.g.dart';

@HiveType(typeId: 6)
class JournalEntry extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  String title;

  @HiveField(2)
  String content;

  @HiveField(3)
  final DateTime createdAt;

  @HiveField(4)
  DateTime updatedAt;

  @HiveField(5)
  JournalType type;

  @HiveField(6)
  String? mood; // Optional mood for the entry

  @HiveField(7)
  List<String> tags; // Tags for categorization

  JournalEntry({
    required this.id,
    required this.title,
    required this.content,
    required this.createdAt,
    required this.updatedAt,
    required this.type,
    this.mood,
    this.tags = const [],
  });

  void updateContent(
    String newTitle,
    String newContent, {
    String? newMood,
    List<String>? newTags,
  }) {
    title = newTitle;
    content = newContent;
    if (newMood != null) mood = newMood;
    if (newTags != null) tags = newTags;
    updatedAt = DateTime.now();
    save();
  }
}

@HiveType(typeId: 7)
enum JournalType {
  @HiveField(0)
  diary,

  @HiveField(1)
  affirmation,

  @HiveField(2)
  gratitude,

  @HiveField(3)
  reflection,
}
