import 'dart:developer';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:onebody/screens/bottom_bar.dart';

import '../model/Notice.dart';



class AddNoticePage extends StatefulWidget {
  const AddNoticePage({Key? key}) : super(key: key);

  @override
  State<AddNoticePage> createState() => _AddNoticePageState();
}


class _AddNoticePageState extends State<AddNoticePage> {
  final _title = TextEditingController();
  final _description = TextEditingController();
  String? imageUrl;

  //upload images to Storage
  uploadImage() async {
    String dt  = DateTime.now().toString();
    final _firebaseStorage = FirebaseStorage.instance;
    final ImagePicker _picker = ImagePicker();
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    var file = File(image!.path);

    var snapshot = await _firebaseStorage.ref().child('notice/notice-$dt').putFile(file);
    var downloadUrl = await snapshot.ref.getDownloadURL();
    setState(() {
      imageUrl = downloadUrl;
    });
  }

  //Create products data to Firestore Database.
  final db = FirebaseFirestore.instance;

  void noticeSession() async {
    final now = FieldValue.serverTimestamp();
    imageUrl == null ? imageUrl = "https://cdn.icon-icons.com/icons2/2770/PNG/512/camera_icon_176688.png" : null;

    Notice notice = Notice(
      image: imageUrl,
      title: _title.text,
      description: _description.text,
      create_timestamp: now,
    );


    await db.collection('Notice').doc(notice.title).set(notice.toJson()).then(
            (value) => log("Notice uploaded successfully!"),
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
          title: Text('공지를 추가 해요 ⭐️'),

          centerTitle: true,

          actions: <Widget>[
            IconButton(
              icon: Icon(Icons.send),
              onPressed: noticeSession,
            )
          ],
        ),

        body:
        SingleChildScrollView(
          child: Column(
            children: [
              Container(
                  margin: EdgeInsets.all(25),
                  child: (imageUrl != null)
                      ? Image.network(imageUrl!)
                      : IconButton(onPressed: uploadImage, icon: Icon(Icons.camera_alt_outlined), iconSize: 300,)
              ),

              const SizedBox(height: 18.0),

              Row(
                children: <Widget>[
                  Expanded(child: Card(child: Column(children: [
                    TextField(
                      controller: _title,
                      decoration: InputDecoration(
                        labelText: '공지 제목을 입력 해주세요 (홈 화면에 표시 돼요.)',
                      ),
                    ),
                    SizedBox(height: 18.0,),
                    TextField(
                      controller: _description,
                      decoration: InputDecoration(
                        labelText: '자세한 내용을 입력해주세요.',
                      ),
                    ),
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
