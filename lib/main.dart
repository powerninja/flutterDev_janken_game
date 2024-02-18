import 'package:flutter/material.dart';
import 'dart:math' as math;
import 'package:firebase_core/firebase_core.dart';
import 'package:janken_game/result_page.dart';
import 'firebase_options.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'DBHelper.dart';
import 'dart:math' as math;

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
    var randomId = math.Random().nextInt(10);
    if (consecutiveVictories != 0) {
      //insert処理
      Memo memo = Memo(
          text: 'じゃむおじさん',
          id: randomId,
          rpsConsecutiveWins: consecutiveVictories);
      await Memo.insertMemo(memo);
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
          MaterialPageRoute(builder: (context) => ResultPage()),
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
