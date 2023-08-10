import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../model/Story.dart';

class CommentPage extends StatelessWidget {
  final Story story;
  final TextEditingController _commentController = TextEditingController();

  CommentPage({required this.story});

  Future<void> _submitComment() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null && _commentController.text.isNotEmpty) {
      await FirebaseFirestore.instance
          .collection('story')
          .doc(story.id)
          .collection('comments')
          .add({
        'userId': user.uid,
        'content': _commentController.text,
        'timestamp': Timestamp.now(),
      });
      _commentController.clear();
    }
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(

      builder: (BuildContext context, ScrollController scrollController) {
        return Column(
          children: [
            Center(
              child: Container(
                margin: EdgeInsets.only(top: 12.0, bottom: 16.0),
                width: 40.0,
                height: 5.0,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(12.0),
                ),
              ),
            ),

            Container(
              height: 40.0,
              padding: const EdgeInsets.all(8.0),
              alignment: Alignment.center,
              child: Text(
                '댓글',
                style: TextStyle(
                  fontSize: 20.0,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            Divider(
              thickness: 1.5,
            ),
            Expanded(
              child: StreamBuilder(
                stream: FirebaseFirestore.instance
                    .collection('story')
                    .doc(story.id)
                    .collection('comments')
                    .orderBy('timestamp', descending: true)
                    .snapshots(),
                builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
                  if (!snapshot.hasData) {
                    return CircularProgressIndicator();
                  }

                  return ListView.builder(
                    itemCount: snapshot.data!.docs.length,
                    itemBuilder: (context, index) {
                      final doc = snapshot.data!.docs[index];
                      return ListTile(
                        title: Text(doc['content']),
                        subtitle: Text(doc['timestamp'].toDate().toString()),
                      );
                    },
                  );
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: TextField(
                controller: _commentController,
                decoration: InputDecoration(
                  labelText: 'Write a comment...',
                  suffixIcon: IconButton(
                    icon: Icon(Icons.send),
                    onPressed: _submitComment,
                  ),
                ),
              ),
            ),
          ],
        );
      },
      initialChildSize: 1.0, // Change this value as needed
      minChildSize: 0.5, // Change this value as needed
      maxChildSize: 1.0, // Change this value as needed
    );
  }
}
