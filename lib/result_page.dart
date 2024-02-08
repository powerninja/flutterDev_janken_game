import 'package:flutter/material.dart';

class resultPage extends StatelessWidget {
  //イニシャライザ(コンストラクタ)を記述する
  resultPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: const Text('じゃんけん✊'),
      ),
      body: Container(
        child: Text('結果表示'),
      ),
    );
  }
}
