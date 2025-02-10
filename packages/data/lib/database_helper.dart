import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class DatabaseHelper {
  static const _dbname = 'expense_tracker.db';
  static Database? _db;
  static final DatabaseHelper databaseHelper = DatabaseHelper._();

  Future<Database> get database async {
    _db ??= await _initDb();
    return _db!;
  }

  DatabaseHelper._();

  Future<Database> _initDb() async {
    String databasesPath = await getDatabasesPath();
    String path = join(databasesPath, _dbname);
    return openDatabase(path, version: 1, onCreate: _createDb);
  }

  Future<void> _createDb(Database db, int version) async {
    await db.execute('''
    CREATE TABLE Categories (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      category TEXT NOT NULL UNIQUE
    )
  ''');

    await db.execute('''
    CREATE TABLE Expenses (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      category INTEGER NOT NULL,
      note TEXT NOT NULL,
      amount REAL NOT NULL,
      date TEXT NOT NULL,
      FOREIGN KEY (category) REFERENCES Categories(id)
    )
  ''');
    return;
  }
}
