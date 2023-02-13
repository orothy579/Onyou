import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';


class SentencePage extends StatelessWidget {
  const SentencePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Text(
            "Onebody Community(OC)는\n\n"
            "온 열방에 존재하는\n예수그리스도의 한 몸 된 지체로서\n\n"
                "살아계신 하나님과\n"
            "몸의 머리 되신\n예수그리스도를 통한"
                "\n\n그 분의 지상명령에 순종합니다."
        ),
      ),
    );
  }
}
