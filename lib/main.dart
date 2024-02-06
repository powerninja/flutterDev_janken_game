import 'package:flutter/material.dart';
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
  final jansen = ['👊', '✌️', '✋', ''];
  int randomJan = 3;
  String userHand = '';
  String result = '';

//TODO: 連勝数を記述する
  run(String userHandNow) {
    var random = math.Random();
    setState(() {
      randomJan = random.nextInt(3);
      userHand = userHandNow;
      if (jansen[randomJan] == userHand) {
        result = '結果： 引き分け';
      } else if (jansen[randomJan] == '👊' && userHand == '✋' ||
          jansen[randomJan] == '✋' && userHand == '✌️' ||
          jansen[randomJan] == '✌️' && userHand == '👊') {
        result = '結果： あなたの勝利！';
      } else if (jansen[randomJan] == '✋' && userHand == '👊' ||
          jansen[randomJan] == '👊' && userHand == '✌️' ||
          jansen[randomJan] == '✌️' && userHand == '✋') {
        result = '結果： 残念負けです';
      }
    });
  }

  reset() {
    setState(() {
      randomJan = 3;
      result = '';
      userHand = '';
    });
  }

  @override
  Widget build(BuildContext context) {
    //TODO: ゲーム画面の前にスタート画面を作成する
    //TODO: 連勝ランキングに遷移する画面もあると良い
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
            const Text(
              '相手',
              style: TextStyle(fontSize: 30),
            ),
            Text(
              jansen[randomJan],
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
              userHand,
              style: TextStyle(fontSize: 200),
            ),
            Center(
                child: Row(
              //TODO: 3つのボタンを中心にする
              children: [
                ElevatedButton(
                  onPressed: () {
                    run('👊');
                  },
                  child: const Text('👊'),
                ),
                ElevatedButton(
                  onPressed: () {
                    run('✌️');
                  },
                  child: const Text('✌️'),
                ),
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
      // floatingActionButton: FloatingActionButton(
      //   onPressed: (){}),
      //   tooltip: 'Increment',
      //   child: const Icon(Icons.add),
      // ),
    );
  }
}
