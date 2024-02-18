import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

//sqflite
class Memo {
  final int id;
  final String text;
  final int rpsConsecutiveWins;

//データモデルの定義
  Memo(
      {required this.id, required this.text, required this.rpsConsecutiveWins});

  Map<String, dynamic> toMap() {
    return {'id': id, 'text': text, 'rpsConsecutiveWins': rpsConsecutiveWins};
  }

//テーブル作成
  static Future<Database> get database async {
    // openDatabase() データベースに接続
    final Future<Database> database = openDatabase(
      // getDatabasesPath() データベースファイルを保存するパス取得
      join(await getDatabasesPath(), 'memo_database.db'),
      onCreate: (db, version) {
        return db.execute(
          // テーブルの作成
          "CREATE TABLE memo(id INTEGER PRIMARY KEY AUTOINCREMENT, text TEXT, rpsConsecutiveWins INTEGER)",
        );
      },
      version: 2,
    );
    return database;
  }

//データ挿入
  static Future<void> insertMemo(Memo memo) async {
    final Database db = await database;
    await db.insert(
      'memo',
      memo.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  //データの取得
  static Future<List<Memo>> getMemos() async {
    final Database db = await database;
    final List<Map<String, dynamic>> maps =
        await db.query('memo', orderBy: 'rpsConsecutiveWins DESC');
    return List.generate(maps.length, (i) {
      return Memo(
        id: maps[i]['id'],
        text: maps[i]['text'],
        rpsConsecutiveWins: maps[i]['rpsConsecutiveWins'],
      );
    });
  }
}
