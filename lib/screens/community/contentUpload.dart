import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class UploadStory extends StatefulWidget {
  @override
  _UploadStoryState createState() => _UploadStoryState();
}

class _UploadStoryState extends State<UploadStory> {
  final _contentController = TextEditingController();
  final _auth = FirebaseAuth.instance;

  _upload() async {
    final user = _auth.currentUser;
    if (user != null && _contentController.text.isNotEmpty) {
      await FirebaseFirestore.instance.collection('stories').add({
        'userId': user.uid,
        'content': _contentController.text,
        'timestamp': Timestamp.now(),
        'likes': [],
      });
      _contentController.clear();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        TextField(
          controller: _contentController,
          decoration: InputDecoration(labelText: "Your Story"),
          maxLines: 5,
        ),
        ElevatedButton(
          onPressed: _upload,
          child: Text("Upload"),
        ),
      ],
    );
  }
}
