import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:onebody/screens/community/prayertitleCard.dart';
import 'package:onebody/screens/community/storyCard.dart';
import 'package:async/async.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../model/Story.dart';
import 'package:intl/src/intl/date_format.dart';

import '../../model/PrayerTitle.dart';

class MixedList extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final currentUserUid = FirebaseAuth.instance.currentUser?.uid;

    return StreamBuilder(
      stream: StreamZip([
        FirebaseFirestore.instance
            .collection('story')
            .orderBy('create_timestamp', descending: true)
            .snapshots(),
        FirebaseFirestore.instance
            .collection('prayers')
            .orderBy('dateTime', descending: true)
            .snapshots(),
      ]),
      builder: (context, AsyncSnapshot<List<QuerySnapshot>> snapshot) {
        if (!snapshot.hasData) {
          return CircularProgressIndicator();
        }

        final storyDocs = snapshot.data![0].docs;
        final prayerDocs = snapshot.data![1].docs;

        List<MixedItem> mixedItems = [];

        for (final doc in storyDocs) {
          final story = Story.fromQuerySnapshot(doc as QueryDocumentSnapshot<Map<String, dynamic>>);
          mixedItems.add(MixedItem(story.create_timestamp!, 'story', story));
        }

        for (final doc in prayerDocs) {
          final prayer = PrayerTitle.fromDocument(doc);
          mixedItems.add(MixedItem(prayer.dateTime, 'prayer', prayer));
        }

        mixedItems.sort((a, b) => b.timestamp.compareTo(a.timestamp));

        Map<DateTime, List<MixedItem>> mixedItemsByDate = {};
        for (var item in mixedItems) {
          final DateTime date = item.timestamp.toDate();
          final key = DateTime(date.year, date.month, date.day);
          if (mixedItemsByDate.containsKey(key)) {
            mixedItemsByDate[key]!.add(item);
          } else {
            mixedItemsByDate[key] = [item];
          }
        }

        List<Widget> sections = [];
        mixedItemsByDate.entries.forEach((entry) {
          sections.add(
            Text(
              DateFormat('yyyy년 MM월 dd일').format(entry.key),
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black26),
              textAlign: TextAlign.center,
            ),
          );

          sections.addAll(entry.value.map((item) {
            if (item.type == 'story') {
              return StoryCard(story: item.data as Story);
            } else {
              final prayer = item.data as PrayerTitle;
              final isMine = currentUserUid == prayer.userRef.id;
              return PrayerCard(prayer: prayer, isMine: isMine);
            }
          }).toList());
        });

        return SingleChildScrollView(
          child: Column(
            children: sections,
          ),
        );
      },
    );
  }
}


class MixedItem {
  final Timestamp timestamp;
  final String type;
  final dynamic data;

  MixedItem(this.timestamp, this.type, this.data);
}
