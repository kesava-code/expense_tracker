import 'package:data/data.dart'; // Import the data package
import 'package:expenses_client/expenses_client.dart';
import 'package:expenses_client/models/expense.dart'; // Import Expense model

class ExpenseRepository {
  final DatabaseHelper _databaseHelper = DatabaseHelper.databaseHelper; // Get the singleton

List<String> _buildWhereClause(
    DateTime? startDate,
    DateTime? endDate,
    List<int>? categoryIds,
    double? minAmount,
    double? maxAmount,
    
  ) {
    final List<String> whereClauses = [];
    final List<String> whereArgs = [];

    if (startDate != null) {
      whereClauses.add('date >= ?');
      whereArgs.add(startDate.toIso8601String());
    }

    if (endDate != null) {
      whereClauses.add('date <= ?');
      whereArgs.add(endDate.toIso8601String());
    }

    if (categoryIds != null && categoryIds.isNotEmpty) {
      final categoryPlaceholders = List.generate(categoryIds.length, (_) => '?').join(',');
      whereClauses.add('category IN ($categoryPlaceholders)');
      whereArgs.addAll(categoryIds.map((id) => id.toString()));
    }

    if (minAmount != null) {
      whereClauses.add('amount >= ?');
      whereArgs.add(minAmount.toString());
    }

    if (maxAmount != null) {
      whereClauses.add('amount <= ?');
      whereArgs.add(maxAmount.toString());
    }
    return [whereClauses.join(' AND '), whereArgs.join(',')];
  }

  Future<List<ExpenseCategory>> getExpenses({
    DateTime? startDate,
    DateTime? endDate,
    List<int>? categoryIds,
    double? minAmount,
    double? maxAmount,
    String? sortBy, // "amount", "date", "category"
    String? sortOrder, // "ASC", "DESC"
    int? limit,
    int? offset
  }) async {
    final db = await _databaseHelper.database;
    final whereClauseData = _buildWhereClause(startDate, endDate, categoryIds, minAmount, maxAmount);
    final whereClause = whereClauseData[0];
    final whereArgs = whereClauseData[1].split(',');

    String orderByClause = '';
    if (sortBy != null) {
      orderByClause = 'ORDER BY $sortBy ${sortOrder ?? "ASC"}';
    }

    String limitClause = '';
    if (limit != null) {
      limitClause = 'LIMIT $limit';
      if (offset != null) { // Add offset to limit clause
        limitClause += ' OFFSET $offset';
      }
    } else if (offset != null) { // Handle offset only case
      limitClause = 'OFFSET $offset';
    }

    //final query = 'SELECT * FROM Expenses ${whereClause.isNotEmpty ? 'WHERE $whereClause' : ''} $orderByClause $limitClause';
    final query = '''
      SELECT 
        e.*,  -- All columns from the Expenses table
        c.category AS categoryName -- The category name from the Categories table
      FROM Expenses e
      INNER JOIN Categories c ON e.category = c.id
      ${whereClause.isNotEmpty ? 'WHERE $whereClause' : ''}
      $orderByClause
      $limitClause
    ''';
    final List<Map<String, dynamic>> maps = await db.rawQuery(query, whereArgs);

    return List.generate(maps.length, (i) {
      final map = maps[i];
      map['date'] = DateTime.parse(map['date']);
      return ExpenseCategory.fromMap(map);
    });
  }

  Future<int?> addExpense(Expense expense) async {
    final db = await _databaseHelper.database;
    final values = expense.toMap();
    values['date'] = expense.date.toIso8601String(); // Serialize DateTime to String
    return await db.insert('Expenses', values);
  }

  Future<int> updateExpense(Expense expense) async {
    final db = await _databaseHelper.database;
    final values = expense.toMap();
    values.remove('date'); // Ensure date is not updated

    return await db.update('Expenses', values,
        where: 'id = ?', whereArgs: [expense.id]);
  }

  Future<int> deleteExpense(int id) async {
    final dbClient = await _databaseHelper.database;
    return await dbClient.delete('Expenses', where: 'id = ?', whereArgs: [id]);
  }

Future<double> getExpensesSum({
    DateTime? startDate,
    DateTime? endDate,
    List<int>? categoryIds,
    double? minAmount,
    double? maxAmount,
  }) async {
    final db = await _databaseHelper.database;
    final whereClauseData = _buildWhereClause(startDate, endDate, categoryIds, minAmount, maxAmount);
    final whereClause = whereClauseData[0];
    final whereArgs = whereClauseData[1].split(',');


    final query = 'SELECT SUM(amount) as sum FROM Expenses ${whereClause.isNotEmpty ? 'WHERE $whereClause' : ''}';
    final result = await db.rawQuery(query, whereArgs);

    final sum = result.isNotEmpty && result[0]['sum'] != null
        ? double.parse(result[0]['sum'].toString())
        : 0.0;

    return sum;
  }

}