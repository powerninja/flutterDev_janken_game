import 'package:flutter/material.dart';
import 'dart:math' as math;
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

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
  String myHand = '❓';
  String result = '';
  int consecutiveVictories = 0;
  String rivalHand = '❓';

  run(String myHandNow) {
    var random = math.Random();
    setState(() {
      final randomJan = random.nextInt(3);
      myHand = myHandNow;

      rivalHand = Hand.values[randomJan].text;
      if (rivalHand == myHand) {
        result = Result.draw.text;
      } else if (rivalHand == '👊' && myHand == '✋' ||
          rivalHand == '✋' && myHand == '✌️' ||
          rivalHand == '✌️' && myHand == '👊') {
        result = Result.win.text;
        consecutiveVictories++;
      } else if (rivalHand == '✋' && myHand == '👊' ||
          rivalHand == '👊' && myHand == '✌️' ||
          rivalHand == '✌️' && myHand == '✋') {
        result = Result.lose.text;
        consecutiveVictoriesReset();
      }
    });
  }

  reset() {
    setState(() {
      result = '';
      myHand = '❓';
      rivalHand = '❓';
      consecutiveVictoriesReset();
    });
  }

//負けた際や、リセットボタンを押下した際に連勝数を0にする
  consecutiveVictoriesReset() {
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
              result,
              style: TextStyle(fontSize: 30),
            ),
            Text('$consecutiveVictories連勝'),
            const Text(
              '相手',
              style: TextStyle(fontSize: 30),
            ),
            Text(
              rivalHand,
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
              myHand,
              style: TextStyle(fontSize: 200),
            ),
            Center(
                child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton(
                  onPressed: () {
                    run('👊');
                  },
                  child: const Text('👊'),
                ),
                const SizedBox(width: 20),
                ElevatedButton(
                  onPressed: () {
                    run('✌️');
                  },
                  child: const Text('✌️'),
                ),
                const SizedBox(width: 20),
                ElevatedButton(
                  onPressed: () {
                    run('✋');
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
      floatingActionButton: FloatingActionButton(onPressed: () {}),
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
