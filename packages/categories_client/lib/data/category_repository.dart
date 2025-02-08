import 'package:data/data.dart';
import 'package:categories_client/models/category.dart';

class CategoryRepository {
  final DatabaseHelper _databaseHelper = DatabaseHelper.databaseHelper;


  Future<List<Category>> getCategories({String? searchTerm}) async {
    final db = await _databaseHelper.database;
    String whereClause = '';
    List<String> whereArgs = [];

    if (searchTerm != null && searchTerm.isNotEmpty) {
      whereClause = 'name LIKE ?'; // Use LIKE for search
      whereArgs = ['%$searchTerm%']; // Add wildcards for partial matches
    }

    final List<Map<String, dynamic>> maps = await db.query(
      'Categories',
      where: whereClause,
      whereArgs: whereArgs,
    );

    return List.generate(maps.length, (i) {
      return Category.fromMap(maps[i]);
    });
  }

  Future<int?> addCategory(Category category) async {
    final db = await _databaseHelper.database;
    return await db.insert('Categories', category.toMap());
  }

  Future<int> updateCategory(Category category) async {
    final db = await _databaseHelper.database;
    return await db.update('Categories', category.toMap(),
        where: 'id = ?', whereArgs: [category.id]);
  }

  Future<int> deleteCategory(int id) async {
    final db = await _databaseHelper.database;
    return await db.delete('Categories', where: 'id = ?', whereArgs: [id]);
  }
}