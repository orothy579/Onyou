import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:onebody/screens/community/prayertitleCard.dart';
import 'package:onebody/screens/community/storyCard.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../model/Story.dart';
import 'package:intl/src/intl/date_format.dart';

import '../../model/PrayerTitle.dart';
//
//
// class MixedList extends StatelessWidget {
//
//
//   @override
//   Widget build(BuildContext context) {
//     final currentUserUid = FirebaseAuth.instance.currentUser?.uid;
//
//     return StreamBuilder(
//       stream: StreamZip([
//         FirebaseFirestore.instance
//             .collection('story')
//             .orderBy('create_timestamp', descending: true)
//             .snapshots(),
//         FirebaseFirestore.instance
//             .collection('prayers')
//             .orderBy('dateTime', descending: true)
//             .snapshots(),
//       ]),
//       builder: (context, AsyncSnapshot<List<QuerySnapshot>> snapshot) {
//         if (!snapshot.hasData) {
//           return CircularProgressIndicator();
//         }
//
//         final storyDocs = snapshot.data![0].docs;
//         final prayerDocs = snapshot.data![1].docs;
//
//         List<MixedItem> mixedItems = [];
//
//         for (final doc in storyDocs) {
//           final story = Story.fromQuerySnapshot(doc as QueryDocumentSnapshot<Map<String, dynamic>>);
//           mixedItems.add(MixedItem(story.create_timestamp!, 'story', story));
//         }
//
//         for (final doc in prayerDocs) {
//           final prayer = PrayerTitle.fromDocument(doc);
//           mixedItems.add(MixedItem(prayer.dateTime, 'prayer', prayer));
//         }
//
//         mixedItems.sort((a, b) => b.timestamp.compareTo(a.timestamp));
//
//         Map<DateTime, List<MixedItem>> mixedItemsByDate = {};
//         for (var item in mixedItems) {
//           final DateTime date = item.timestamp.toDate();
//           final key = DateTime(date.year, date.month, date.day);
//           if (mixedItemsByDate.containsKey(key)) {
//             mixedItemsByDate[key]!.add(item);
//           } else {
//             mixedItemsByDate[key] = [item];
//           }
//         }
//
//         List<Widget> sections = [];
//         mixedItemsByDate.entries.forEach((entry) {
//           sections.add(
//             Text(
//               DateFormat('yyyy년 MM월 dd일').format(entry.key),
//               style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black26),
//               textAlign: TextAlign.center,
//             ),
//           );
//
//           sections.addAll(entry.value.map((item) {
//             if (item.type == 'story') {
//               final story = item.data as Story?;
//               if (story == null) {
//                 return Center(child: Text("이야기가 없습니다."));
//               }
//               return StoryCard(
//                   key : ValueKey(story.id),
//                   story: story
//               );
//             }
//             else {
//               final prayer = item.data as PrayerTitle?;
//               if (prayer == null) {
//                 return Center(child: Text("기도 제목이 없습니다."));
//               }
//               final isMine = currentUserUid == prayer.userRef.id;
//               return PrayerCard(prayer: prayer, isMine: isMine);
//             }
//           }).toList());
//
//         });
//
//         return SingleChildScrollView(
//           child: Column(
//             children: sections,
//           ),
//         );
//       },
//     );
//   }
// }
//
//
// class MixedItem {
//   final Timestamp timestamp;
//   final String type;
//   final dynamic data;
//
//   MixedItem(this.timestamp, this.type, this.data);
// }



//
// class MixedList extends StatelessWidget {
//   Stream<List<MixedItem>> getMergedStream() {
//     final storyStream = FirebaseFirestore.instance
//         .collection('story')
//         .orderBy('create_timestamp', descending: true)
//         .snapshots().handleError((error) => print ("Error in storyStream  $error"))
//         .map((snap) => snap.docs.map((doc) => MixedItem(doc['create_timestamp'] as Timestamp, 'story', Story.fromQuerySnapshot(doc as QueryDocumentSnapshot<Map<String, dynamic>>))).toList());
//
//     final prayerStream = FirebaseFirestore.instance
//         .collection('prayers')
//         .orderBy('dateTime', descending: true)
//         .snapshots()
//         .map((snap) => snap.docs.map((doc) => MixedItem(doc['dateTime'] as Timestamp, 'prayer', PrayerTitle.fromDocument(doc as QueryDocumentSnapshot<Map<String, dynamic>>))).toList());
//
//     return StreamGroup.merge([storyStream, prayerStream]);
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     final currentUserUid = FirebaseAuth.instance.currentUser?.uid;
//
//     return StreamBuilder(
//       stream: getMergedStream(),
//       builder: (context, AsyncSnapshot<List<MixedItem>> snapshot) {
//         print("Snapshot data: ${snapshot.data}");
//
//         if (!snapshot.hasData) {
//           return CircularProgressIndicator();
//         }
//
//         List<MixedItem> mixedItems = snapshot.data!;
//         mixedItems.sort((a, b) => b.timestamp.compareTo(a.timestamp));
//
//         return ListView.builder(
//           itemCount: mixedItems.length,
//           itemBuilder: (context, index) {
//             final item = mixedItems[index];
//             if (item.data is Story) {
//               return StoryCard(
//                 story: item.data as Story,
//               );
//             } else if (item.data is PrayerTitle) {
//               final isMine = currentUserUid == (item.data as PrayerTitle).userRef.id;
//               return PrayerCard(
//                 prayer: item.data as PrayerTitle,
//                 isMine: isMine,
//               );
//             } else {
//               return SizedBox.shrink(); // 예상치 못한 타입이면 아무것도 표시하지 않음
//             }
//           },
//         );
//       },
//     );
//   }
// }
//
// class MixedItem {
//   final Timestamp timestamp;
//   final String type;
//   final dynamic data;
//
//   MixedItem(this.timestamp, this.type, this.data);
// }


class MixedList extends StatefulWidget {
  @override
  _MixedListState createState() => _MixedListState();
}

class _MixedListState extends State<MixedList> {
  List<MixedItem> mixedItems = [];

  @override
  void initState() {
    super.initState();

    // Listen to each stream and add items to mixedItems
    FirebaseFirestore.instance
        .collection('story')
        .orderBy('create_timestamp', descending: true)
        .snapshots()
        .listen((snapshot) {
      setState(() {
        mixedItems.removeWhere((item) => item.type == 'story');
        for (final doc in snapshot.docs) {
          final story = Story.fromQuerySnapshot(doc as QueryDocumentSnapshot<Map<String, dynamic>>);
          mixedItems.add(MixedItem(story.create_timestamp!, 'story', story));
        }
        mixedItems.sort((a, b) => b.timestamp.compareTo(a.timestamp));
      });
    });

    FirebaseFirestore.instance
        .collection('prayers')
        .orderBy('dateTime', descending: true)
        .snapshots()
        .listen((snapshot) {
      setState(() {
        mixedItems.removeWhere((item) => item.type == 'prayer');
        for (final doc in snapshot.docs) {
          final prayer = PrayerTitle.fromDocument(doc);
          mixedItems.add(MixedItem(prayer.dateTime, 'prayer', prayer));
        }
        mixedItems.sort((a, b) => b.timestamp.compareTo(a.timestamp));
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final currentUserUid = FirebaseAuth.instance.currentUser?.uid;

    if (mixedItems.isEmpty) {
      return CircularProgressIndicator();
    }

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
          final story = item.data as Story?;
          if (story == null) {
            return Center(child: Text("이야기가 없습니다."));
          }
          return StoryCard(
              key: ValueKey(story.id),
              story: story
          );
        } else {
          final prayer = item.data as PrayerTitle?;
          if (prayer == null) {
            return Center(child: Text("기도 제목이 없습니다."));
          }
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
  }
}

class MixedItem {
  final Timestamp timestamp;
  final String type;
  final dynamic data;

  MixedItem(this.timestamp, this.type, this.data);
}
