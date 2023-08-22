import 'package:flutter/material.dart';
import 'addpray.dart';
import 'addstory.dart';

class SelectionPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("선택 페이지")),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            InkWell(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => AddStoryPage()),
                );
              },
              child: Column(
                children: [
                  Icon(Icons.book, size: 80), // 책 아이콘
                  Text("스토리 추가"),
                ],
              ),
            ),
            SizedBox(height: 40),
            InkWell(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => AddPrayPage()),
                );
              },
              child: Column(
                children: [
                  Icon(Icons.church_outlined, size: 80), // 기도하는 사람 아이콘
                  Text("기도 제목 추가"),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
