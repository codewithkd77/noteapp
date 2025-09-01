import 'package:flutter/foundation.dart';
import 'package:hive/hive.dart';
import '../models/journal_entry.dart';

class JournalProvider extends ChangeNotifier {
  static const String _boxName = 'journalEntries';
  Box<JournalEntry>? _box;

  List<JournalEntry> _entries = [];
  bool _isLoading = false;

  List<JournalEntry> get entries => _entries;
  bool get isLoading => _isLoading;

  // Get entries by type
  List<JournalEntry> get diaryEntries =>
      _entries.where((entry) => entry.type == JournalType.diary).toList();

  List<JournalEntry> get affirmations =>
      _entries.where((entry) => entry.type == JournalType.affirmation).toList();

  List<JournalEntry> get gratitudeEntries =>
      _entries.where((entry) => entry.type == JournalType.gratitude).toList();

  List<JournalEntry> get reflections =>
      _entries.where((entry) => entry.type == JournalType.reflection).toList();

  Future<void> initialize() async {
    _isLoading = true;
    notifyListeners();

    try {
      _box = await Hive.openBox<JournalEntry>(_boxName);
      await loadEntries();
    } catch (e) {
      debugPrint('Error initializing journal provider: $e');
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> loadEntries() async {
    if (_box == null) return;

    _entries = _box!.values.toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
    notifyListeners();
  }

  Future<void> addEntry({
    required String title,
    required String content,
    required JournalType type,
    String? mood,
    List<String>? tags,
  }) async {
    if (_box == null) return;

    final entry = JournalEntry(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: title,
      content: content,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
      type: type,
      mood: mood,
      tags: tags ?? [],
    );

    await _box!.add(entry);
    await loadEntries();
  }

  Future<void> updateEntry(
    JournalEntry entry, {
    required String title,
    required String content,
    String? mood,
    List<String>? tags,
  }) async {
    entry.updateContent(title, content, newMood: mood, newTags: tags);
    await loadEntries();
  }

  Future<void> deleteEntry(JournalEntry entry) async {
    await entry.delete();
    await loadEntries();
  }

  Future<void> deleteAllEntries() async {
    if (_box == null) return;

    await _box!.clear();
    await loadEntries();
  }

  List<JournalEntry> searchEntries(String query) {
    if (query.isEmpty) return _entries;

    final lowercaseQuery = query.toLowerCase();
    return _entries.where((entry) {
      return entry.title.toLowerCase().contains(lowercaseQuery) ||
          entry.content.toLowerCase().contains(lowercaseQuery) ||
          entry.tags.any((tag) => tag.toLowerCase().contains(lowercaseQuery));
    }).toList();
  }

  List<JournalEntry> getEntriesForDate(DateTime date) {
    return _entries.where((entry) {
      return entry.createdAt.year == date.year &&
          entry.createdAt.month == date.month &&
          entry.createdAt.day == date.day;
    }).toList();
  }

  Map<String, int> getEntriesByType() {
    return {
      'Diary': diaryEntries.length,
      'Affirmations': affirmations.length,
      'Gratitude': gratitudeEntries.length,
      'Reflections': reflections.length,
    };
  }
}
