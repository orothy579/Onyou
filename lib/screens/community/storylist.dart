import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:onebody/screens/community/storyCard.dart';

import '../../model/Story.dart';

class StoryList extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: StreamBuilder(
            stream: FirebaseFirestore.instance.collection('story').orderBy('create_timestamp', descending: true).snapshots(),
            builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
              if (!snapshot.hasData) {
                return CircularProgressIndicator();
              }

              return ListView.builder(
                itemCount: snapshot.data!.docs.length,
                itemBuilder: (context, index) {
                  final storyDoc = snapshot.data!.docs[index] as QueryDocumentSnapshot<Map<String,dynamic>>;
                  final story = Story.fromQuerySnapshot(storyDoc);

                  return StoryCard(story: story);
                },
              );
            },
          ),
        ),
      ],
    );
  }
}

