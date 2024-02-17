import 'package:flutter/material.dart';
import 'dart:math' as math;
import 'package:firebase_core/firebase_core.dart';
import 'package:janken_game/result_page.dart';
import 'firebase_options.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

//sqflite
class Memo {
  final int id;
  final String text;

//データモデルの定義
  Memo({required this.id, required this.text});

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'text': text,
    };
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
          "CREATE TABLE memo(id INTEGER PRIMARY KEY AUTOINCREMENT, text TEXT)",
        );
      },
      version: 1,
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
    final List<Map<String, dynamic>> maps = await db.query('memo');
    return List.generate(maps.length, (i) {
      return Memo(
        id: maps[i]['id'],
        text: maps[i]['text'],
      );
    });
  }
}

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});
  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int consecutiveVictories = 0;

  Hand? myHand;
  Hand? computerHand;
  Result? result;

//じゃんけんボタン押下時
  run() {
    var random = math.Random();
    setState(() {
      final randomJan = random.nextInt(3);

      computerHand = Hand.values[randomJan];
      matchUpProcessing();
    });
  }

//結果判定処理
  matchUpProcessing() {
    if (computerHand == myHand) {
      result = Result.draw;
    } else if (computerHand?.text == '👊' && myHand?.text == '✋' ||
        computerHand?.text == '✋' && myHand?.text == '✌️' ||
        computerHand?.text == '✌️' && myHand?.text == '👊') {
      result = Result.win;
      consecutiveVictories++;
    } else if (computerHand?.text == '✋' && myHand?.text == '👊' ||
        computerHand?.text == '👊' && myHand?.text == '✌️' ||
        computerHand?.text == '✌️' && myHand?.text == '✋') {
      result = Result.lose;
      consecutiveVictoriesReset();
    }
  }

//リセット
  reset() {
    setState(() {
      myHand = null;
      result = null;
      computerHand = null;
      consecutiveVictoriesReset();
    });
  }

  List<Memo> _memoList = [];
//負けた際や、リセットボタンを押下した際に連勝数を0にする
  consecutiveVictoriesReset() async {
    //insert処理
    Memo memo = Memo(text: 'じゃむおじさん', id: consecutiveVictories);
    await Memo.insertMemo(memo);
    if (consecutiveVictories != 0) {
      //get
      _memoList = await Memo.getMemos();
      for (Memo m in _memoList) {
        print(m.id);
      }
    }
    consecutiveVictories = 0;
  }

  @override
  Widget build(BuildContext context) {
    //TODO: ゲーム画面の前にスタート画面を作成する
    //TODO: 連勝ランキングに遷移する画面もあると良い
    //↓はスマホローカルに保存する
    //TODO: どこかに過去の連勝記録の値を保存する
    //TODO: CPUが悩む動作などあればよさそう
    //TODO: ルーレット機能など
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: const Text('じゃんけん✊'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              result?.text ?? '',
              style: TextStyle(fontSize: 30),
            ),
            Text('$consecutiveVictories連勝'),
            const Text(
              '相手',
              style: TextStyle(fontSize: 30),
            ),
            Text(
              computerHand?.text ?? '❓',
              style: TextStyle(fontSize: 100),
            ),
            const SizedBox(
              height: 80,
            ),
            const Text(
              '自分',
              style: TextStyle(fontSize: 30),
            ),
            Text(
              myHand?.text ?? '❓',
              style: TextStyle(fontSize: 200),
            ),
            Center(
                child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton(
                  onPressed: () {
                    myHand = Hand.rock;
                    run();
                  },
                  child: const Text('👊'),
                ),
                const SizedBox(width: 20),
                ElevatedButton(
                  onPressed: () {
                    myHand = Hand.scissors;
                    run();
                  },
                  child: const Text('✌️'),
                ),
                const SizedBox(width: 20),
                ElevatedButton(
                  onPressed: () {
                    myHand = Hand.paper;
                    run();
                  },
                  child: const Text('✋'),
                )
              ],
            )),
            ElevatedButton(
              onPressed: () {
                reset();
              },
              child: const Text('リセット'),
            )
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(onPressed: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => resultPage()),
        );
      }),
    );
  }
}

//じゃんけんの手持ちを管理
enum Hand {
  rock,
  scissors,
  paper;

  String get text {
    switch (this) {
      case Hand.rock:
        return '👊';
      case Hand.scissors:
        return '✌️';
      case Hand.paper:
        return '✋';
    }
  }
}

//結果を管理
enum Result {
  win,
  lose,
  draw;

  String get text {
    switch (this) {
      case Result.win:
        return '結果： あなたの勝利！';
      case Result.lose:
        return '結果： 残念負けです';
      case Result.draw:
        return '結果： 引き分け';
    }
  }
}
