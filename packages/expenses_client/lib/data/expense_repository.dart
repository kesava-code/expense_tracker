import 'package:data/data.dart'; // Import the data package
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

  Future<List<Expense>> getExpenses({
    DateTime? startDate,
    DateTime? endDate,
    List<int>? categoryIds,
    double? minAmount,
    double? maxAmount,
    String? sortBy, // "amount", "date", "category"
    String? sortOrder, // "ASC", "DESC"
  }) async {
    final db = await _databaseHelper.database;
    final whereClauseData = _buildWhereClause(startDate, endDate, categoryIds, minAmount, maxAmount);
    final whereClause = whereClauseData[0];
    final whereArgs = whereClauseData[1].split(',');

    String orderByClause = '';
    if (sortBy != null) {
      orderByClause = 'ORDER BY $sortBy ${sortOrder ?? "ASC"}';
    }

    final query = 'SELECT * FROM Expenses ${whereClause.isNotEmpty ? 'WHERE $whereClause' : ''} $orderByClause';
    final List<Map<String, dynamic>> maps = await db.rawQuery(query, whereArgs);

    return List.generate(maps.length, (i) {
      final map = maps[i];
      map['date'] = DateTime.parse(map['date']);
      return Expense.fromMap(map);
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


    final query = 'SELECT SUM(amount) FROM Expenses ${whereClause.isNotEmpty ? 'WHERE $whereClause' : ''}';
    final result = await db.rawQuery(query, whereArgs);

    final sum = result.isNotEmpty && result[0]['SUM(amount)'] != null
        ? double.parse(result[0]['SUM(amount)'].toString())
        : 0.0;

    return sum;
  }

}