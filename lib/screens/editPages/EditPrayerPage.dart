import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class EditPrayerPage extends StatefulWidget {
  final String documentId;

  EditPrayerPage({required this.documentId});

  @override
  _EditPrayerPageState createState() => _EditPrayerPageState();
}

class _EditPrayerPageState extends State<EditPrayerPage> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // 기존 데이터를 불러오기
    fetchData();
  }

  Future<void> fetchData() async {
    try {
      // Firestore에서 현재 데이터 가져오기
      DocumentSnapshot documentSnapshot = await FirebaseFirestore.instance
          .collection('prayers')
          .doc(widget.documentId)
          .get();

      // 현재 데이터를 화면에 표시
      if (documentSnapshot.exists) {
        Map<String, dynamic> data =
        documentSnapshot.data() as Map<String, dynamic>;

        _titleController.text = data['title'];
        _descriptionController.text = data['description'];
      }
    } catch (e) {
      print('Error fetching data: $e');
    }
  }

  Future<void> updatePrayer() async {
    try {
      // Firestore에서 데이터 업데이트
      await FirebaseFirestore.instance.collection('prayers').doc(widget.documentId).update({
        'title': _titleController.text,
        'description': _descriptionController.text,
      });

      // 수정이 완료되면 이전 화면으로 돌아가기
      Navigator.pop(context);
    } catch (e) {
      print('Error updating data: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('기도 수정 페이지'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _titleController,
              decoration: InputDecoration(labelText: '제목 수정'),
            ),
            SizedBox(height: 20),
            TextField(
              controller: _descriptionController,
              decoration: InputDecoration(labelText: '설명 수정'),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                // 수정된 데이터 업데이트
                updatePrayer();
              },
              child: Text('수정 완료'),
            ),
          ],
        ),
      ),
    );
  }
}
