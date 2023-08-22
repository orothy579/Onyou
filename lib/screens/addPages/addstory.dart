import 'dart:developer';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../../model/Story.dart';


class AddStoryPage extends StatefulWidget {
  const AddStoryPage({Key? key}) : super(key: key);

  @override
  State<AddStoryPage> createState() => _AddStoryPageState();
}

class _AddStoryPageState extends State<AddStoryPage> {
  final _title = TextEditingController();
  final _description = TextEditingController();
  List<String> _imageUrls = []; // 이미지 URL 목록을 저장

  String? _selectedTeam;
  final List<String> _teams = [
    'Branding', 'Builder Community', 'OBC', 'OCB', 'OEC',
    'OFC', 'OSW', 'Onebody FC', 'Onebody House', '이웃'
  ];



  uploadFiles() async {
    String dt = DateTime.now().toString();
    final _firebaseStorage = FirebaseStorage.instance;

    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        allowMultiple: true,
        type: FileType.custom,
        allowedExtensions: ['jpg', 'jpeg', 'png', 'gif', 'mp4', 'mov', 'avi', 'mkv'], // 이미지 및 동영상 확장자 추가
      );

      if (result == null || result.files.isEmpty) return; // 사용자가 파일 선택을 취소한 경우

      for (var file in result.files) {
        var currentFile = File(file.path!);  // non-null assertion 추가
        String fileName = currentFile.path.split('/').last;
        var snapshot = await _firebaseStorage.ref().child('story/story-$dt-$fileName').putFile(currentFile);
        var downloadUrl = await snapshot.ref.getDownloadURL();
        _imageUrls.add(downloadUrl); // 이 경우 _imageUrls에 이미지와 동영상 URL이 모두 포함됩니다.
      }

      setState(() {});
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('파일이 성공적으로 업로드되었습니다!')),
      );
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('파일 업로드 중 문제가 발생했습니다.')),
      );
    }
  }

  final db = FirebaseFirestore.instance;
  final _uid = FirebaseAuth.instance.currentUser!.uid;


  void StorySession() async {
    Timestamp now = Timestamp.now();
    final CollectionReference myCollection = FirebaseFirestore.instance.collection('users');
    final DocumentReference documentRef = myCollection.doc(_uid);

    DocumentReference? teamDocumentRef;
    if (_selectedTeam != null) {
      teamDocumentRef = db.collection('teams').doc(_selectedTeam);
    }

    final documentData = await documentRef.get();
    final fieldValname = documentData.get('name');
    final fieldValimage = documentData.get('image');

    Story story = Story(
      id: _title.text,
      images: _imageUrls,
      name: fieldValname,
      u_image: fieldValimage,
      title: _title.text,
      description: _description.text,
      create_timestamp: now,
      userRef: documentRef,
      teamRef: teamDocumentRef,
      likes: [],
    );

    try {
      await db.collection('story').doc(story.title).set(story.toJson());
      log("Story uploaded successfully!");
      Navigator.pushNamed(context, '/home');
    } catch (e) {
      log("Error while uploading!");
    }
  }


  final _formKey = GlobalKey<FormState>();


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        backgroundColor: Colors.deepPurpleAccent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: Text('소식을 전하세요 ☺️', style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.send),
            onPressed: StorySession,
          )
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [


            SizedBox(height: 10),
            GridView.builder(
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
              ),
              itemCount: _imageUrls.length,
              itemBuilder: (context, index) {
                return Image.network(_imageUrls[index], fit: BoxFit.cover);
              },
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: uploadFiles,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.add_photo_alternate, size: 25,),
                  SizedBox(width: 5),
                  Text("사진 추가", style: TextStyle(fontSize: 16)),
                ],
              ),
              style: ElevatedButton.styleFrom(
                primary: Colors.deepPurpleAccent,
                padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
              ),
            ),
            SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: TextField(
                controller: _title,
                decoration: InputDecoration(
                  labelText: '제목을 입력 해주세요.',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                ),
              ),
            ),
            SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: TextField(
                controller: _description,
                maxLines: 5,
                decoration: InputDecoration(
                  labelText: '어떤 이야기를 전하고 싶나요?',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                ),
              ),
            ),

            SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: DropdownButton<String>(
                hint: Text('팀을 선택해주세요.'),
                value: _selectedTeam,
                onChanged: (String? value) {
                  setState(() {
                    _selectedTeam = value;
                  });
                },
                items: _teams.map<DropdownMenuItem<String>>((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
              ),
            ),
            SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
