import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('habits.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(
      path,
      version: 1,
      onCreate: _createDB,
    );
  }

  Future<void> _createDB(Database db, int version) async {
    const idType = 'INTEGER PRIMARY KEY AUTOINCREMENT';
    const textType = 'TEXT NOT NULL';
    const textTypeNullable = 'TEXT';
    const integerType = 'INTEGER NOT NULL';

    // Create habits table
    await db.execute('''
      CREATE TABLE habits (
        id $idType,
        name $textType,
        description $textTypeNullable,
        created_at $textType,
        updated_at $textType
      )
    ''');

    // Create progress table
    await db.execute('''
      CREATE TABLE progress (
        id $idType,
        habit_id $integerType,
        date $textType,
        completed $integerType,
        notes $textTypeNullable,
        FOREIGN KEY (habit_id) REFERENCES habits (id) ON DELETE CASCADE
      )
    ''');

    // Create index on habit_id for faster queries
    await db.execute('''
      CREATE INDEX idx_progress_habit_id ON progress(habit_id)
    ''');

    // Create index on date for faster queries
    await db.execute('''
      CREATE INDEX idx_progress_date ON progress(date)
    ''');
  }

  Future<void> close() async {
    final db = await database;
    await db.close();
  }
}

