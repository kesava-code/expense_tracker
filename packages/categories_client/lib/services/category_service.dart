import 'package:categories_client/data/category_repository.dart';
import 'package:categories_client/models/category.dart';

class CategoryService {
  final CategoryRepository _categoryRepository;

  CategoryService({CategoryRepository? categoryRepository})
      : _categoryRepository = categoryRepository ?? CategoryRepository();

   Future<List<Category>> getCategories({
    List<int>? ids,
    String? searchTerm,
    String? sortBy,
    String? sortOrder,
  }) async {
    return _categoryRepository.getCategories(
      ids: ids,
      searchTerm: searchTerm,
      sortBy: sortBy,
      sortOrder: sortOrder,
    );
  }

  Future<Category?> addCategory(Category category) async {
    final id = await _categoryRepository.addCategory(category);
    if (id != null) {
      category.id = id;
      return category;
    }
    return null;
  }

  Future<void> updateCategory(Category category) async {
    await _categoryRepository.updateCategory(category);
  }

  Future<void> deleteCategory(int id) async {
    await _categoryRepository.deleteCategory(id);
  }
}