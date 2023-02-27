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
  String? _imageUrl;

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
      _imageUrl = downloadUrl;
    });
  }

  //Create products data to Firestore Database.
  final db = FirebaseFirestore.instance;
  final _uid = FirebaseAuth.instance.currentUser!.uid;




  void StorySession() async {
    Timestamp now = Timestamp.now();

    // Get a reference to the Firestore collection
    final CollectionReference myCollection = FirebaseFirestore.instance.collection('users');

  // Get a document reference
    final DocumentReference documentRef = myCollection.doc(_uid);

  // Get the value of a specific field in the document
    final fieldValname = await documentRef.get().then((doc) => doc.get('name'));
    final fieldValimage = await documentRef.get().then((doc) => doc.get('image'));


    _imageUrl == null ? _imageUrl = "https://cdn.icon-icons.com/icons2/2770/PNG/512/camera_icon_176688.png" : null;

    Story story = Story(
      image: _imageUrl,
      name : fieldValname,
      u_image : fieldValimage,
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
                    pageBuilder: (context,__,___) => BottomBar(id: 0),
                    transitionDuration: Duration.zero,
                    reverseTransitionDuration: Duration.zero,
                  ),
                );
              }
          ),
          title: Text('소식을 전하세요 ☺️'),

          centerTitle: true,

          actions: <Widget>[
            IconButton(
              icon: Icon(Icons.send),
              onPressed: StorySession,
            )
          ],
        ),

        body:
        SingleChildScrollView(
          child: Column(
            children: [
              Container(
                  margin: EdgeInsets.all(25),
                  child: (_imageUrl != null)
                      ? Image.network(_imageUrl!)
                      : IconButton(onPressed: uploadImage, icon: Icon(Icons.camera_alt_outlined), iconSize: 300,)

              ),

              const SizedBox(height: 18.0),

              Row(
                children: <Widget>[
                  Expanded(child: Card(child: Column(children: [
                    SizedBox(height: 100.0,),
                    TextField(
                      controller: _title,
                      decoration: InputDecoration(
                        labelText: '제목을 입력 해주세요.',
                      ),
                    ),
                    SizedBox(height: 100.0,),
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
