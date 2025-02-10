import 'package:data/data.dart';
import 'package:categories_client/models/category.dart';

class CategoryRepository {
  final DatabaseHelper _databaseHelper = DatabaseHelper.databaseHelper;


  Future<List<Category>> getCategories({
    List<int>? ids, // List of category IDs to filter by
    String? searchTerm, // Search term
    String? sortBy, // "name" (only option for now)
    String? sortOrder, // "ASC", "DESC"
  }) async {
    final db = await _databaseHelper.database;
    final List<String> whereClauses = [];
    final List<String> whereArgs = [];

    if (ids != null && ids.isNotEmpty) {
      final idPlaceholders = List.generate(ids.length, (_) => '?').join(',');
      whereClauses.add('id IN ($idPlaceholders)');
      whereArgs.addAll(ids.map((id) => id.toString()));
    }

    if (searchTerm != null && searchTerm.isNotEmpty) {
      whereClauses.add('name LIKE ?');
      whereArgs.add('%$searchTerm%');
    }

    String whereClause = whereClauses.isNotEmpty ? 'WHERE ${whereClauses.join(' AND ')}' : '';

    String orderByClause = '';
    if (sortBy != null) {
      orderByClause = 'ORDER BY $sortBy ${sortOrder ?? "ASC"}';
    }

    final query = 'SELECT * FROM Categories $whereClause $orderByClause'; // Combine WHERE and ORDER BY
    final List<Map<String, dynamic>> maps = await db.rawQuery(query, whereArgs);

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