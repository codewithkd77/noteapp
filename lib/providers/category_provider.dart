import 'package:flutter/foundation.dart' hide Category;
import '../models/category.dart';
import '../services/database_service.dart';

class CategoryProvider extends ChangeNotifier {
  List<Category> _categories = [];
  bool _isLoading = false;

  List<Category> get categories => _categories;
  bool get isLoading => _isLoading;

  Future<void> loadCategories() async {
    _isLoading = true;
    notifyListeners();

    try {
      _categories = DatabaseService.getCategories();
    } catch (e) {
      debugPrint('Error loading categories: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> addCategory(String name, String color) async {
    try {
      final category = Category(
        id: 'category_${DateTime.now().millisecondsSinceEpoch}',
        name: name,
        color: color,
        entries: [],
        createdAt: DateTime.now(),
      );

      await DatabaseService.addCategory(category);
      _categories.add(category);
      notifyListeners();
    } catch (e) {
      debugPrint('Error adding category: $e');
    }
  }

  Future<void> updateCategory(Category category) async {
    try {
      await DatabaseService.updateCategory(category);
      final index = _categories.indexWhere((c) => c.id == category.id);
      if (index != -1) {
        _categories[index] = category;
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Error updating category: $e');
    }
  }

  Future<void> deleteCategory(String categoryId) async {
    try {
      await DatabaseService.deleteCategory(categoryId);
      _categories.removeWhere((category) => category.id == categoryId);
      notifyListeners();
    } catch (e) {
      debugPrint('Error deleting category: $e');
    }
  }

  Future<void> addCategoryEntry(String categoryId, String content) async {
    try {
      final category = _categories.firstWhere((c) => c.id == categoryId);
      final entry = CategoryEntry(
        id: 'entry_${DateTime.now().millisecondsSinceEpoch}',
        content: content,
        createdAt: DateTime.now(),
      );

      category.entries.add(entry);
      await updateCategory(category);
    } catch (e) {
      debugPrint('Error adding category entry: $e');
    }
  }

  Future<void> updateCategoryEntry(
    String categoryId,
    String entryId,
    String newContent,
  ) async {
    try {
      final category = _categories.firstWhere((c) => c.id == categoryId);
      final entryIndex = category.entries.indexWhere((e) => e.id == entryId);

      if (entryIndex != -1) {
        category.entries[entryIndex].content = newContent;
        category.entries[entryIndex].updatedAt = DateTime.now();
        await updateCategory(category);
      }
    } catch (e) {
      debugPrint('Error updating category entry: $e');
    }
  }

  Future<void> deleteCategoryEntry(String categoryId, String entryId) async {
    try {
      final category = _categories.firstWhere((c) => c.id == categoryId);
      category.entries.removeWhere((entry) => entry.id == entryId);
      await updateCategory(category);
    } catch (e) {
      debugPrint('Error deleting category entry: $e');
    }
  }

  Category? getCategoryById(String categoryId) {
    try {
      return _categories.firstWhere((c) => c.id == categoryId);
    } catch (e) {
      return null;
    }
  }
}
