import 'dart:developer';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:onebody/screens/bottom_bar.dart';
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

  uploadImages() async {
    String dt = DateTime.now().toString();
    final _firebaseStorage = FirebaseStorage.instance;
    final ImagePicker _picker = ImagePicker();

    List<XFile>? images = await _picker.pickMultiImage();
    for (var image in images!) {
      var file = File(image.path);
      var snapshot = await _firebaseStorage.ref().child('story/story-$dt-${image.name}').putFile(file);
      var downloadUrl = await snapshot.ref.getDownloadURL();
      _imageUrls.add(downloadUrl);
    }
    setState(() {});
  }

  final db = FirebaseFirestore.instance;
  final _uid = FirebaseAuth.instance.currentUser!.uid;

  void StorySession() async {
    Timestamp now = Timestamp.now();
    final CollectionReference myCollection = FirebaseFirestore.instance.collection('users');
    final DocumentReference documentRef = myCollection.doc(_uid);

    final fieldValname = await documentRef.get().then((doc) => doc.get('name'));
    final fieldValimage = await documentRef.get().then((doc) => doc.get('image'));

    Story story = Story(
      id: _title.text,
      images: _imageUrls,  // 수정됨: 이미지 URL 목록을 전달
      name: fieldValname,
      u_image: fieldValimage,
      title: _title.text,
      description: _description.text,
      create_timestamp: now,
      userRef: documentRef,
      likes: [],
    );

    await db.collection('story').doc(story.title).set(story.toJson()).then(
          (value) => log("Story uploaded successfully!"),
      onError: (e) => log("Error while uploading!"),
    );

    Navigator.pushNamed(context, '/home');
  }


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
              onPressed: uploadImages,
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
          ],
        ),
      ),
    );
  }
}
