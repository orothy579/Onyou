import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../../model/Story.dart';
import '../community/storyCard.dart';

class StoryList extends StatelessWidget {
  final DocumentReference teamRef;
  StoryList({required this.teamRef});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('팀 스토리 목록')),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder(
                stream: FirebaseFirestore.instance
                    .collection('story')
                    .where('teamRef', isEqualTo: teamRef.path)
                    .snapshots(),
                builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
                  if (!snapshot.hasData) {
                    return Center(child: CircularProgressIndicator());
                  }

                  if (snapshot.hasError) {
                    print(snapshot.error);
                    return Center(child: Text("Error: ${snapshot.error}"));
                  }

                  if (snapshot.data!.docs.isEmpty) {
                    print(teamRef.path); // teamRef의 경로 출력

                    return Center(
                      child: Text(
                        "아직 올려진 스토리가 없습니다. 새로운 스토리를 업로드 하세요!",
                        style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold),
                        textAlign: TextAlign.center,
                      ),
                    );
                  }

                  return ListView.builder(
                    itemCount: snapshot.data!.docs.length,
                    itemBuilder: (context, index) {
                      final storyDoc = snapshot.data!.docs[index]
                          as QueryDocumentSnapshot<Map<String, dynamic>>;
                      final story = Story.fromQuerySnapshot(storyDoc);
                      return StoryCard(story: story);
                    },
                  );
                }),
          ),
        ],
      ),
    );
  }
}
