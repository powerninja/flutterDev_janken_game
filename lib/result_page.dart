import 'package:flutter/material.dart';
import 'DBHelper.dart';

class ResultPage extends StatelessWidget {
  ResultPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('結果表示'),
      ),
      body: FutureBuilder<List<Memo>>(
        future: Memo.getMemos(), // DBHelperから非同期でメモを取得
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            // データの取得中に表示するウィジェット
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            // エラーが発生した場合に表示するウィジェット
            return Center(child: Text('エラーが発生しました'));
          } else if (snapshot.hasData) {
            // データが正常に取得できた場合に表示するウィジェット
            List<Memo> memos = snapshot.data!;
            return ListView.builder(
              itemCount: memos.length,
              itemBuilder: (context, index) {
                Memo memo = memos[index];
                return ListTile(
                  title: Text('連勝数：${memo.rpsConsecutiveWins}連勝'),
                  subtitle: Text(memo.text),
                  leading: const Icon(Icons.account_circle),
                  // その他メモの詳細を表示
                );
              },
            );
          } else {
            // データが空の場合に表示するウィジェット
            return Center(child: Text('データがありません'));
          }
        },
      ),
    );
  }
}
