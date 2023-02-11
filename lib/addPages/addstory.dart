import 'dart:developer';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:onebody/screens/bottom_bar.dart';

import '../model/Story.dart';



class AddStoryPage extends StatefulWidget {
  const AddStoryPage({Key? key}) : super(key: key);

  @override
  State<AddStoryPage> createState() => _AddStoryPageState();
}


class _AddStoryPageState extends State<AddStoryPage> {
  final _title = TextEditingController();
  final _description = TextEditingController();
  String imageUrl= "https://img1.daumcdn.net/thumb/R1280x0/?scode=mtistory2&fname=https%3A%2F%2Ft1.daumcdn.net%2Fcfile%2Ftistory%2F257CF14F56D00BF80D";
  //upload images to Storage
  uploadImage() async {
    String dt  = DateTime.now().toString();
    final _firebaseStorage = FirebaseStorage.instance;
    final ImagePicker _picker = ImagePicker();
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    var file = File(image!.path);

    var snapshot = await _firebaseStorage.ref().child('story/story-$dt').putFile(file);
    var downloadUrl = await snapshot.ref.getDownloadURL();
    setState(() {
      imageUrl = downloadUrl;
    });
  }

  //Create products data to Firestore Database.
  final db = FirebaseFirestore.instance;

  void noticeSession() async {
    Timestamp now = Timestamp.now();

    imageUrl == null ? imageUrl = "https://img1.daumcdn.net/thumb/R1280x0/?scode=mtistory2&fname=https%3A%2F%2Ft1.daumcdn.net%2Fcfile%2Ftistory%2F257CF14F56D00BF80D" : null;

    Story story = Story(
      image: imageUrl,
      title: _title.text,
      description: _description.text,
      create_timestamp: now,
    );


    await db.collection('story').doc(story.title).set(story.toJson()).then(
            (value) => log("Story uploaded successfully!"),
        onError: (e) => log("Error while uploading!"));

    Navigator.pushNamed(context,'/home');
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(

        appBar: AppBar(
          leading:
          IconButton(
              icon: Icon(Icons.arrow_back),
              onPressed: ()  {
                Navigator.push(
                  context,
                  PageRouteBuilder(
                    pageBuilder: (context,__,___) => BottomBar(),
                    transitionDuration: Duration.zero,
                    reverseTransitionDuration: Duration.zero,
                  ),
                );
              }
          ),
          title: Text('이야기 나누기'),

          centerTitle: true,

          actions: <Widget>[
            IconButton(
              icon: Icon(Icons.save),
              onPressed: noticeSession,
            )
          ],
        ),

        body:
        SingleChildScrollView(
          child: Column(
            children: [
              Container(
                  margin: EdgeInsets.all(50),
                  child: (imageUrl != null)
                      ? Image.network(imageUrl)
                      : Image.network(
                      'https://mblogthumb-phinf.pstatic.net/MjAxNzA2MThfODEg/MDAxNDk3NzExNzEzODM3.prLxdRgEPcgdHtuCpSb_oq1dFOMOs3XmcJYfc6e4dEkg.YYczrm92ql7i7kO8EaRzy3Hr8ysxYVymceHeVORLhwgg.JPEG.charis628/1496480599234.jpg?type=w800')),
              Row(
                children: [
                  IconButton(onPressed: uploadImage, icon: Icon(Icons.camera_alt))
                ],
              ),
              const SizedBox(height: 18.0),

              Row(
                children: <Widget>[
                  Expanded(child: Card(child: Column(children: [
                    TextField(
                      controller: _title,
                      decoration: InputDecoration(
                        labelText: '제목을 입력 해주세요.',
                      ),
                    ),
                    SizedBox(height: 18.0,),
                    TextField(
                      controller: _description,
                      decoration: InputDecoration(
                        labelText: '어떤 이야기를 전하고 싶나요?',
                      ),
                    ),
                    SizedBox(height: 100.0,),

                  ],),))
                ],
              ),

            ],
          ),
        ),
        resizeToAvoidBottomInset: true
    );
  }
}
