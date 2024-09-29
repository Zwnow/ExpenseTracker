import 'package:namer_app/src/expenses/expense.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();

  // Private constructor
  DatabaseHelper._internal();

  // Factory constructor
  factory DatabaseHelper() => _instance;

  static Database? _database;

  // Method to get the database instance
  Future<Database> get database async {
    if (_database != null) return _database!;

    // Initialize the database
    _database = await _initDatabase();
    return _database!;
  }

  // Method to initialize the database
  Future<Database> _initDatabase() async {
    return await openDatabase(
      join(await getDatabasesPath(), 'expense_tracker.db'),
      onCreate: (db, version) async {
        await db.execute(
            'CREATE TABLE IF NOT EXISTS accounts(id INTEGER PRIMARY KEY AUTOINCREMENT, name TEXT NOT NULL, total REAL)');
        await db.execute(
            'CREATE TABLE IF NOT EXISTS categories(id INTEGER PRIMARY KEY AUTOINCREMENT, name TEXT NOT NULL, description TEXT)');
        await db.execute(
            'CREATE TABLE IF NOT EXISTS expenses(id INTEGER PRIMARY KEY AUTOINCREMENT, account_id INTEGER NOT NULL, category_id INTEGER, title TEXT NOT NULL, amount REAL NOT NULL, created_on TEXT NOT NULL)');
      },
      version: 1,
    );
  }


  /* Expenses */

  Future<void> insertExpense(Expense expense) async {
    final db = await database;

    await db.insert(
      'expenses',
      expense.toMap(),
      conflictAlgorithm: ConflictAlgorithm.rollback,
    );
  }

  Future<List<Expense>> expenses() async {
    final db = await database;

    final List<Map<String, Object?>> expenseMaps = await db.query('expenses');

    return [
      for(final {
        'id': id as int,
        'account_id': accountId as int,
        'category_id': categoryId as int,
        'title': title as String,
        'amount': amount as double,
        'created_on': createdOn as String,
      } in expenseMaps)
      Expense(DateTime.parse(createdOn), title, amount, accountId, categoryId, id)
    ];
  }

  Future<void> updateExpense(Expense expense) async {
    final db = await database;

    await db.update(
      'expenses',
      expense.toMap(),
      where: 'id = ?',
      whereArgs: [expense.id],
    );
  }

  Future<void> deleteDog(int id) async {
    final db = await database;

    await db.delete(
      'expenses',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  /* Account */

}
