import 'dart:developer';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:onebody/style/app_styles.dart';
import '../../model/Story.dart';
import 'package:image_picker/image_picker.dart';

class AddStoryPage extends StatefulWidget {
  const AddStoryPage({Key? key}) : super(key: key);

  @override
  State<AddStoryPage> createState() => _AddStoryPageState();
}

class _AddStoryPageState extends State<AddStoryPage> {
  final _title = TextEditingController();
  final _description = TextEditingController();
  List<String> _imageUrls = [];
  String? _selectedTeam;
  final List<String> _teams = [
    'Branding', 'Builder Community', 'OBC', 'OCB', 'OEC',
    'OFC', 'OSW', 'Onebody FC', 'Onebody House', '이웃'
  ];

  DocumentReference? _userTeamRef;
  String? _userTeamName;

  @override
  void initState() {
    super.initState();
    _fetchUserTeam();
  }

  _fetchUserTeam() async {
    final DocumentReference userRef = FirebaseFirestore.instance.collection('users').doc(_uid);
    final userDoc = await userRef.get();
    final teamRefStr = userDoc['teamRef'];

    if (teamRefStr != null) {
      _userTeamRef = FirebaseFirestore.instance.doc(teamRefStr);
      final teamDoc = await _userTeamRef!.get();
      setState(() {
        _userTeamName = teamDoc['name'];
      });
    }
  }




  // Form의 상태를 추적하기 위한 GlobalKey
  final _formKey = GlobalKey<FormState>();

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

  final ImagePicker picker = ImagePicker();
  final List<XFile> _images = [];

  void _selectImages() async {
    final List<XFile>? selectedImages = await picker.pickMultiImage();

    if (selectedImages != null) {
      setState(() {
        _images.addAll(selectedImages);
      });
    }
  }


  void _uploadImages() async {
    String dt = DateTime.now().toString();
    final _firebaseStorage = FirebaseStorage.instance;

    for (var file in _images) {
      final File currentFile = File(file.path);
      String fileName = currentFile.path.split('/').last;
      var snapshot = await _firebaseStorage.ref().child('story/story-$dt-$fileName').putFile(currentFile);
      var downloadUrl = await snapshot.ref.getDownloadURL();
    }
  }




  final db = FirebaseFirestore.instance;
  final _uid = FirebaseAuth.instance.currentUser!.uid;

  void StorySession() async {

    String dt = DateTime.now().toString();
    final _firebaseStorage = FirebaseStorage.instance;

    for (var file in _images) {
      final File currentFile = File(file.path);
      String fileName = currentFile.path.split('/').last;
      var snapshot = await _firebaseStorage.ref().child('story/story-$dt-$fileName').putFile(currentFile);
      var downloadUrl = await snapshot.ref.getDownloadURL();
    }

    Timestamp now = Timestamp.now();
    final CollectionReference myCollection = FirebaseFirestore.instance.collection('users');
    final DocumentReference documentRef = myCollection.doc(_uid);

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
      teamRef: _userTeamRef,
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        backgroundColor: onebody1,
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
            onPressed: () {
              if (_formKey.currentState!.validate()) { // Form 검증
                StorySession();
              }
            },
          )
        ],
      ),
      body: SingleChildScrollView(
        child: Form(
          key: _formKey,
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
                  backgroundColor: onebody1,
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
                child:

                DropdownButtonFormField<String>(
                  hint: Text('팀을 선택해주세요.'),
                  value: _userTeamName,
                  onChanged: (String? value) {
                    // 본인이 속한 팀만 표시되기 때문에 별도의 변경 작업은 필요하지 않습니다.
                  },
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return '팀 정보가 없습니다.';
                    }
                    return null;
                  },
                  items: _userTeamName == null
                      ? []
                      : [DropdownMenuItem<String>(
                    value: _userTeamName,
                    child: Text(_userTeamName!),
                  )],
                )

              ),
              SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}
