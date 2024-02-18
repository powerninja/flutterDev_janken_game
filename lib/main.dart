import 'package:flutter/material.dart';
import 'dart:math' as math;
import 'package:janken_game/result_page.dart';
import 'DBHelper.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';

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
  // TextEditingControllerのインスタンスを作成
  final TextEditingController _controller = TextEditingController();
  // 入力されたテキストを格納する変数
  String _inputText = '';

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
          text: _inputText,
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
    //TODO: 連勝数を出した方が良い
    //TODO: DBに日時を追加する
    //TODO:あいこの数と勝利数をプラスして表示する
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text('$_inputText さん : じゃんけん✊'),
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
              style: const TextStyle(fontSize: 100),
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
      floatingActionButton: SpeedDial(
        animatedIcon: AnimatedIcons.menu_close,
        animatedIconTheme: const IconThemeData(size: 22.0),
        curve: Curves.bounceIn,
        children: [
          SpeedDialChild(
              child: const Icon(Icons.assignment),
              backgroundColor: Colors.blue,
              label: "連勝数を確認する",
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => ResultPage()),
                );
              },
              labelStyle: const TextStyle(fontWeight: FontWeight.w500)),
          SpeedDialChild(
              child: const Icon(Icons.edit),
              backgroundColor: Colors.green,
              label: "プレイヤー名を変更する",
              onTap: () {
                showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return AlertDialog(
                          title: const Text('プレイヤー名を入力してください'),
                          content: TextField(
                              autofocus: true,
                              decoration: const InputDecoration(
                                hintText: '山田 太郎...',
                              ),
                              controller: _controller),
                          actions: <Widget>[
                            TextButton(
                                child: const Text('閉じる'),
                                onPressed: () {
                                  Navigator.of(context).pop();
                                }),
                            TextButton(
                                onPressed: () {
                                  Navigator.of(context).pop();
                                  setState(() {
                                    _inputText = _controller.text;
                                  });
                                },
                                child: const Text('変更'))
                          ]);
                    });
              },
              labelStyle: const TextStyle(fontWeight: FontWeight.w500)),
        ],
      ),
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
