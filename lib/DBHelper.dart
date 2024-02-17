import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DBHelper {
  static Database? _database;

  static Future<void> initDb() async {
    if (_database != null) return;
    try {
      String path = join(await getDatabasesPath(), 'app_data.db');
      _database = await openDatabase(
        path,
        version: 1,
        onCreate: (db, version) {
          return db.execute(
            "CREATE TABLE memos(id INTEGER PRIMARY KEY AUTOINCREMENT, content TEXT)",
          );
        },
      );
    } catch (e) {
      print(e);
    }
  }

  static Future<List<Map<String, dynamic>>> getMemos() async {
    final List<Map<String, dynamic>> maps = await _database!.query('memos');
    return maps;
  }

  static Future<void> insertMemo(Map<String, dynamic> data) async {
    await _database!.insert(
      'memos',
      data,
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }
}
