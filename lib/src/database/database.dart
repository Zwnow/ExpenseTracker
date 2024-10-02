import 'package:namer_app/src/accounts/account.dart';
import 'package:namer_app/src/categories/category.dart';
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
    String dbPath = await getDatabasesPath();
    String path = join(dbPath, 'expense_tracker.db');

    await deleteDatabase(path);

    return await openDatabase(
      join(await getDatabasesPath(), 'expense_tracker.db'),
      onCreate: (db, version) async {
        await db.execute('DROP TABLE IF EXISTS accounts');
        await db.execute('DROP TABLE IF EXISTS categories');
        await db.execute('DROP TABLE IF EXISTS expenses');
        print("INIT: DROPPED TABLES");
        await db.execute(
            'CREATE TABLE IF NOT EXISTS accounts(id INTEGER PRIMARY KEY AUTOINCREMENT, name TEXT NOT NULL, total REAL)');
        print("INIT: CREATED ACCOUNTS TABLE");
        await db.execute(
            'CREATE TABLE IF NOT EXISTS categories(id INTEGER PRIMARY KEY AUTOINCREMENT, name TEXT NOT NULL, description TEXT)');
        print("INIT: CREATED CATEGORIES TABLE");

        await db.execute("INSERT INTO categories (name) VALUES ('Lebensmittel')");
        await db.execute("INSERT INTO categories (name) VALUES ('Hygenie')");
        print("INIT: CREATED CATEGORIES SAMPLE VALUES");

        await db.execute(
            'CREATE TABLE IF NOT EXISTS expenses(id INTEGER PRIMARY KEY AUTOINCREMENT, account_id INTEGER NOT NULL, category_id INTEGER, title TEXT NOT NULL, amount REAL NOT NULL, created_on TEXT NOT NULL, interval TEXT NOT NULL)');
        print("INIT: CREATED EXPENSES TABLE");
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
    final db = await database; // Ensure you're getting the database instance

    // Query the database for expenses
    final List<Map<String, Object?>> expenseMaps = await db.query('expenses');

    // Map each entry to an Expense object
    return expenseMaps.map((expenseMap) {
      return Expense(
        DateTime.parse(expenseMap['created_on']
            as String), // Parsing the created_on field to DateTime
        expenseMap['title'] as String,
        expenseMap['amount'] as double,
        expenseMap['account_id'] as int,
        expenseMap['category_id'] as int,
        expenseMap['id'] as int,
        expenseMap['interval']
            as PaymentInterval, // Convert the interval to the PaymentInterval enum
      );
    }).toList();
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

  Future<void> deleteExpense(int id) async {
    final db = await database;

    await db.delete(
      'expenses',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  /* Account */
  Future<void> insertAccount(Account account) async {
    final db = await database;

    await db.insert(
      'accounts', 
      account.toMapWithoutId(), 
      conflictAlgorithm: ConflictAlgorithm.rollback
    );
  }

  Future<List<Account>> accounts() async {
    final db = await database;

    final List<Map<String, Object?>> accountMaps = await db.query('accounts');

    return [
      for(final {
        'id': id as int,
        'name': name as String,
        'total': total as double,
      } in accountMaps)
      Account(id: id, name: name, total: total)
    ];
  }

  Future<void> updateAccount(Account account) async {
    final db = await database;

    await db.update(
      'accounts',
      account.toMap(),
      where: 'id = ?',
      whereArgs: [account.id],
      conflictAlgorithm: ConflictAlgorithm.rollback,
    );
  }

  Future<void> deleteAccount(int id) async {
    final db = await database;

    await db.delete(
      'accounts',
      where: 'id = ?',
      whereArgs: [id],
    );
  }


  /* Categories */
  Future<void> insertCategory(Category category) async {
    final db = await database;

    await db.insert(
      'categories',
      category.toMap(),
      conflictAlgorithm: ConflictAlgorithm.rollback,
    );
  }

Future<List<Category>> categories() async {
    final db = await database; // Ensure you're getting the database instance

    // Query the database for categories
    final List<Map<String, Object?>> categoryMaps =
        await db.query('categories');

    // Map each entry to a Category object
    return categoryMaps.map((categoryMap) {
      return Category(
        id: categoryMap['id'] as int,
        name: categoryMap['name'] as String,
        description: categoryMap['description'] as String,
      );
    }).toList();
  }

  Future<void> updateCategory(Category category) async {
    final db = await database;
    
    await db.update(
      'categories',
      category.toMap(),
      where: 'id = ?',
      whereArgs: [category.id],
      conflictAlgorithm: ConflictAlgorithm.rollback
    );
  }

  Future<void> deleteCategory(int id) async {
    final db = await database;

    await db.delete(
      'categories',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

}
