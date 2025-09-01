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

  Future<void> addCategory(
    String name,
    String color, {
    String? parentId,
  }) async {
    try {
      final category = Category(
        id: 'category_${DateTime.now().millisecondsSinceEpoch}',
        name: name,
        color: color,
        entries: [],
        createdAt: DateTime.now(),
        parentId: parentId,
      );

      await DatabaseService.addCategory(category);
      _categories.add(category);

      // If this is a subcategory, update the parent's subcategory list
      if (parentId != null) {
        final parentCategory = _categories.firstWhere((c) => c.id == parentId);
        parentCategory.subcategoryIds.add(category.id);
        await DatabaseService.updateCategory(parentCategory);
      }

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

  Future<void> addCategoryEntry(
    String categoryId,
    String description, {
    String? title,
    String? link,
  }) async {
    try {
      debugPrint('Adding entry to category: $categoryId');
      debugPrint('Description: $description');
      debugPrint('Title: $title');
      debugPrint('Link: $link');

      final category = _categories.firstWhere((c) => c.id == categoryId);
      debugPrint('Found category: ${category.name}');

      final entry = CategoryEntry(
        id: 'entry_${DateTime.now().millisecondsSinceEpoch}',
        content: description,
        createdAt: DateTime.now(),
        title: title,
        description: description,
        link: link,
      );

      debugPrint('Created entry with ID: ${entry.id}');
      category.entries.add(entry);
      debugPrint('Category now has ${category.entries.length} entries');

      await updateCategory(category);
      debugPrint('Category updated in database');
    } catch (e) {
      debugPrint('Error adding category entry: $e');
      rethrow;
    }
  }

  Future<void> updateCategoryEntry(
    String categoryId,
    String entryId,
    String description, {
    String? title,
    String? link,
  }) async {
    try {
      final category = _categories.firstWhere((c) => c.id == categoryId);
      final entryIndex = category.entries.indexWhere((e) => e.id == entryId);

      if (entryIndex != -1) {
        final entry = category.entries[entryIndex];
        entry.content = description;
        entry.title = title;
        entry.description = description;
        entry.link = link;
        entry.updatedAt = DateTime.now();
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

  // Get only main categories (no parent)
  List<Category> get mainCategories =>
      _categories.where((c) => c.isMainCategory).toList();

  // Get subcategories for a parent category
  List<Category> getSubcategories(String parentId) {
    return _categories.where((c) => c.parentId == parentId).toList();
  }

  // Get all subcategories for a parent with their entries count
  List<Category> getSubcategoriesWithEntries(String parentId) {
    final subcategories = getSubcategories(parentId);
    return subcategories..sort((a, b) => a.name.compareTo(b.name));
  }
}
