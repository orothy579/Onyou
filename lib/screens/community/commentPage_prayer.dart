import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:onebody/model/PrayerTitle.dart';

import '../../model/Story.dart';

class CommentPagePrayer extends StatelessWidget {
  final PrayerTitle prayerTitle;
  final TextEditingController _commentController = TextEditingController();

  CommentPagePrayer({required this.prayerTitle});

  Future<void> _submitComment() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null && _commentController.text.isNotEmpty) {
      await FirebaseFirestore.instance
          .collection('prayers')
          .doc(prayerTitle.id)
          .collection('comments')
          .add({
        'userId': user.uid,
        'content': _commentController.text,
        'timestamp': Timestamp.now(),
      });
      _commentController.clear();
    }
  }

  String _timeAgoFromTimestamp(DateTime timestamp) {
    final current = DateTime.now();
    final difference = current.difference(timestamp);

    if (difference.inSeconds < 60) {
      return '${difference.inSeconds}초 전';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes}분 전';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}시간 전';
    } else if (difference.inDays < 30) {
      return '${difference.inDays}일 전';
    } else {
      return '한 달 이상 전';
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
              child: StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('prayers')
                    .doc(prayerTitle.id)
                    .collection('comments')
                    .orderBy('timestamp', descending: true)
                    .snapshots(),
                builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return CircularProgressIndicator();
                  }

                  if (snapshot.hasError) {
                    return Text('Error: ${snapshot.error}');
                  }

                  final comments = snapshot.data!.docs;

                  return ListView.builder(
                    itemCount: comments.length,
                    itemBuilder: (context, index) {
                      final doc = comments[index];

                      return FutureBuilder<DocumentSnapshot>(
                        future: FirebaseFirestore.instance
                            .collection('users')
                            .doc(doc['userId'])
                            .get(),
                        builder: (context, AsyncSnapshot<DocumentSnapshot> userSnapshot) {
                          if (userSnapshot.connectionState == ConnectionState.waiting) {
                            return CircularProgressIndicator();
                          }

                          if (userSnapshot.hasError) {
                            return Text('Error: ${userSnapshot.error}');
                          }

                          final userDoc = userSnapshot.data!;
                          final String username = userDoc['name'];
                          final String userImage = userDoc['image'];

                          return ListTile(
                            leading: CircleAvatar(
                              backgroundImage: NetworkImage(userImage),
                            ),
                            title: Text(doc['content']),
                            subtitle: Row(
                              children: [
                                Text(username, style: TextStyle(fontWeight: FontWeight.bold)),
                                SizedBox(width: 10),
                                Text(_timeAgoFromTimestamp(doc['timestamp'].toDate())),
                              ],
                            ),
                          );
                        },
                      );
                    },
                  );
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: SingleChildScrollView(
                reverse: true,
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
                padding: EdgeInsets.only(
                    bottom: MediaQuery.of(context).viewInsets.bottom),
              ),
            )
          ],
        );
      },
      initialChildSize: 1.0, // Change this value as needed
      minChildSize: 0.5, // Change this value as needed
      maxChildSize: 1.0, // Change this value as needed
    );
  }
}
