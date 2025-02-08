import 'package:flutter_test/flutter_test.dart';
import 'package:data/database_helper.dart'; // Replace with your package name

void main() {
 
  late DatabaseHelper dbHelper;

  setUp(() async {
    // Initialize an in-memory database for testing
   
    dbHelper = DatabaseHelper.databaseHelper; // Get the singleton
  });


  group('DatabaseHelper Tests', () {
    test('Database Initialization and Singleton', () async {
      final dbClient1 = await dbHelper.database;
      final dbClient2 = await dbHelper.database;

      expect(dbClient1, isNotNull); // Check if the database is opened
      expect(dbClient2, isNotNull);
      expect(dbClient1, same(dbClient2)); // Verify singleton instance
    });

    test('Table Creation', () async {
      final dbClient = await dbHelper.database;

      // Check if the Categories table exists
      final categoriesTableExists = await dbClient.rawQuery(
          "SELECT name FROM sqlite_master WHERE type='table' AND name='Categories'");
      expect(categoriesTableExists.isNotEmpty, true);

      // Check if the Expenses table exists
      final expensesTableExists = await dbClient.rawQuery(
          "SELECT name FROM sqlite_master WHERE type='table' AND name='Expenses'");
      expect(expensesTableExists.isNotEmpty, true);


      // You could add further checks here to verify column names and types
      // if needed, but the above is a good start.

    });

    test('Add and Get Category', () async {
      final dbClient = await dbHelper.database;
      final categoryId = await dbClient.insert('Categories', {'category': 'Food'});
      expect(categoryId, isNotNull);

      final result = await dbClient.query('Categories', where: 'id = ?', whereArgs: [categoryId]);
      expect(result.isNotEmpty, true);
      expect(result.first['category'], 'Food');

    });

        test('Add and Get Expense', () async {
      final dbClient = await dbHelper.database;
      final categoryId = await dbClient.insert('Categories', {'category': 'Food'});
      expect(categoryId, isNotNull);
      final expenseId = await dbClient.insert('Expenses', {'category': categoryId, 'amount': 10.0, 'date': DateTime.now().toIso8601String()});
      expect(expenseId, isNotNull);

      final result = await dbClient.query('Expenses', where: 'id = ?', whereArgs: [expenseId]);
      expect(result.isNotEmpty, true);
      expect(result.first['amount'], 10.0);

    });
  });
}