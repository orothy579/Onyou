import 'dart:developer' as developer;
import 'dart:developer';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:onebody/screens/addPages/selectionPage.dart';
import 'package:onebody/style/app_styles.dart';
import '../../model/Story.dart';
import 'package:image_picker/image_picker.dart';

import '../bottom_bar.dart';

class AddStoryPage extends StatefulWidget {
  const AddStoryPage({Key? key}) : super(key: key);

  @override
  State<AddStoryPage> createState() => _AddStoryPageState();
}

class _AddStoryPageState extends State<AddStoryPage> {
  String? _selectedTeam;
  final List<String> _teams = [
    'Branding',
    'Builder Community',
    'OBC',
    'OCB',
    'OEC',
    'OFC',
    'OSW',
    'Onebody FC',
    'Onebody House',
    '이웃'
  ];

  DocumentReference? _userTeamRef;
  String? _userTeamName;

  @override
  void initState() {
    super.initState();
    _fetchUserTeam();
  }

  _fetchUserTeam() async {
    final DocumentReference userRef =
        FirebaseFirestore.instance.collection('users').doc(_uid);
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

  final _title = TextEditingController();
  final _description = TextEditingController();
  List<String> _imageUrls = []; // List to store multiple image URLs

  uploadImages() async {
    final _firebaseStorage = FirebaseStorage.instance;
    final ImagePicker _picker = ImagePicker();

    List<XFile>? images = await _picker.pickMultiImage();

    if (images != null) {
      for (int i = 0; i < images.length; i++) {
        var image = images[i];
        var file = File(image.path);

        // 현재 시간 정보를 얻습니다.
        DateTime now = DateTime.now();

        // 이미지 번호를 추가하여 파일 이름을 생성합니다.
        String uniqueFileName =
            'story/${now.year}-${now.month}-${now.day}_${now.hour}:${now.minute}:${now.second}_${i + 1}.jpg';

        try {
          // 이미지를 업로드합니다.
          var snapshot =
              await _firebaseStorage.ref().child(uniqueFileName).putFile(file);

          // 업로드된 이미지의 다운로드 URL을 얻어옵니다.
          var downloadUrl = await snapshot.ref.getDownloadURL();

          setState(() {
            _imageUrls.add(downloadUrl);
          });
        } catch (e) {
          print('이미지 업로드 실패: $e');
        }
      }
    }
  }

  final db = FirebaseFirestore.instance;
  final _uid = FirebaseAuth.instance.currentUser!.uid;

  void StorySession() async {
    Timestamp now = Timestamp.now();

    // Get a reference to the Firestore collection
    final CollectionReference myCollection =
        FirebaseFirestore.instance.collection('users');

    // Get a document reference
    final DocumentReference documentRef = myCollection.doc(_uid);

    // Get the value of a specific field in the document
    final fieldValname = await documentRef.get().then((doc) => doc.get('name'));
    final fieldValimage =
        await documentRef.get().then((doc) => doc.get('image'));

    // Ensure there is at least a default image URL
    _imageUrls.add(
        "https://cdn.icon-icons.com/icons2/2770/PNG/512/camera_icon_176688.png");

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
      Navigator.push(
          context, MaterialPageRoute(builder: (context) => BottomBar(id: 1)));
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
        title:
            Text('소식을 전하세요 ☺️', style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.send),
            onPressed: () {
              if (_formKey.currentState!.validate()) {
                // Form 검증
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
                onPressed: uploadImages,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.add_photo_alternate,
                      size: 25,
                    ),
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
                  child: DropdownButtonFormField<String>(
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
                        : [
                            DropdownMenuItem<String>(
                              value: _userTeamName,
                              child: Text(_userTeamName!),
                            )
                          ],
                  )),
              SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}
