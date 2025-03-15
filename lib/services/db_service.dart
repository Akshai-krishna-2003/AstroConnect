import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:firebase_auth/firebase_auth.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  factory DatabaseHelper() => _instance;
  DatabaseHelper._internal();

  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    String path = join(await getDatabasesPath(), 'astrology_history.db');

    return await openDatabase(
      path,
      version: 3, // 🚀 Increment version for the new image_path column
      onCreate: _onCreate,
      onUpgrade: _onUpgrade, // Handle database upgrades
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE history (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        user_id TEXT NOT NULL,
        name TEXT NOT NULL,
        dob TEXT NOT NULL,
        gender TEXT,
        time_of_birth TEXT NOT NULL,
        place_of_birth TEXT NOT NULL,
        response TEXT NOT NULL,
        image_path TEXT, -- 📷 New column for images
        type TEXT NOT NULL  -- 'individual' or 'compatibility'
      )
    ''');
    print("✅ Database created successfully.");
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      await db.execute('ALTER TABLE history ADD COLUMN user_id TEXT');
      print("✅ Database upgraded: 'user_id' column added.");
    }
    if (oldVersion < 3) {
      await db.execute('ALTER TABLE history ADD COLUMN image_path TEXT');
      print("✅ Database upgraded: 'image_path' column added.");
    }
  }

  Future<void> insertHistory(Map<String, dynamic> data) async {
    final db = await database;
    String? userId = FirebaseAuth.instance.currentUser?.uid;

    if (userId == null) {
      print("❌ Error: No user ID found. Unable to store history.");
      return;
    }

    data["user_id"] = userId;

    try {
      await db.insert('history', data);
      print("✅ History successfully inserted for user: $userId");
    } catch (e) {
      print("❌ Error inserting history: $e");
    }
  }

  Future<List<Map<String, dynamic>>> getHistory(String type) async {
    final db = await database;
    String? userId = FirebaseAuth.instance.currentUser?.uid;

    if (userId == null) {
      print("❌ Error: No user ID found. Unable to fetch history.");
      return [];
    }

    final result = await db.query(
      'history',
      where: 'type = ? AND user_id = ?',
      whereArgs: [type, userId],
      orderBy: "id DESC",
    );

    print("📜 Retrieved ${result.length} history records for user: $userId");
    return result.isNotEmpty ? result : [];
  }

  Future<void> deleteUserHistory() async {
    final db = await database;
    String? userId = FirebaseAuth.instance.currentUser?.uid;

    if (userId == null) return;

    await db.delete('history', where: 'user_id = ?', whereArgs: [userId]);
    print("🗑️ History cleared for user: $userId");
  }
}
