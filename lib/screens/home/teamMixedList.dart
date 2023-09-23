import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../../model/PrayerTitle.dart';
import '../../model/Story.dart';
import 'package:flutter/cupertino.dart';
import 'package:onebody/screens/community/prayertitleCard.dart';
import 'package:onebody/screens/community/storyCard.dart';
import 'package:intl/src/intl/date_format.dart';
import '../../model/user.dart';
import '../home/home.dart';
import 'dart:ui';
import 'dart:async';
import 'package:intl/intl.dart';

class TeamMixedList extends StatefulWidget {
  final DocumentReference teamRef;

  TeamMixedList({required this.teamRef});

  @override
  _TeamMixedListState createState() => _TeamMixedListState();
}

class _TeamMixedListState extends State<TeamMixedList> {
  List<MixedItem> mixedItems = [];
  late StreamSubscription storySubscription;
  late StreamSubscription prayerSubscription;

  @override
  void initState() {
    super.initState();

    storySubscription = FirebaseFirestore.instance
        .collection('story')
        .where('teamRef', isEqualTo: widget.teamRef.path)
        .orderBy('create_timestamp', descending: true)
        .snapshots()
        .listen((snapshot) {
      if (mounted) {
        setState(() {
          mixedItems.removeWhere((item) => item.type == 'story');
          for (final doc in snapshot.docs) {
            final story = Story.fromQuerySnapshot(
                doc as QueryDocumentSnapshot<Map<String, dynamic>>);
            mixedItems.add(MixedItem(story.create_timestamp!, 'story', story));
          }
          mixedItems.sort((a, b) => b.timestamp.compareTo(a.timestamp));
        });
      }
    });

    prayerSubscription = FirebaseFirestore.instance
        .collection('prayers')
        .where('teamRef', isEqualTo: widget.teamRef)
        .orderBy('dateTime', descending: true)
        .snapshots()
        .listen((snapshot) {
      if (mounted) {
        setState(() {
          mixedItems.removeWhere((item) => item.type == 'prayer');
          for (final doc in snapshot.docs) {
            final prayer = PrayerTitle.fromDocument(doc);
            mixedItems.add(MixedItem(prayer.dateTime, 'prayer', prayer));
          }
          mixedItems.sort((a, b) => b.timestamp.compareTo(a.timestamp));
        });
      }
    });
  }

  @override
  void dispose() {
    storySubscription.cancel();
    prayerSubscription.cancel();
    super.dispose();
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
          style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black26,
              fontFamily: 'Pretendard'),
          textAlign: TextAlign.center,
        ),
      );

      sections.addAll(entry.value.map((item) {
        if (item.type == 'story') {
          final story = item.data as Story?;
          if (story == null) {
            return Center(child: Text("이야기가 없습니다."));
          }
          return StoryCard(key: ValueKey(story.id), story: story);
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

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            automaticallyImplyLeading: false,
            elevation: 0,
            backgroundColor: Colors.transparent,
            flexibleSpace: LayoutBuilder(
              builder: (BuildContext context, BoxConstraints constraints) {
                return FlexibleSpaceBar(
                  titlePadding: EdgeInsets.fromLTRB(15, 45, 0, 0),
                  title: FutureBuilder<Users>(
                    future: getUser(FirebaseAuth.instance.currentUser!.uid),
                    builder: (context, snapshot) {
                      if (snapshot.hasData) {
                        Users data = snapshot.data!;
                        return SingleChildScrollView(
                          scrollDirection: Axis.vertical,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "Shalom,",
                                style: TextStyle(
                                    fontSize: 15, color: Colors.black , fontFamily: 'Pretendard'),
                              ),
                              Row(
                                children: [
                                  Text(
                                    "${data.name!} 님",
                                    style: TextStyle(
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold,
                                        fontFamily: 'Pretendard',
                                        color: Colors.black),
                                  ),
                                  Container(
                                    alignment: Alignment.bottomRight,
                                    child: Container(
                                      decoration: BoxDecoration(
                                          color: Colors.transparent,
                                          shape: BoxShape.circle,
                                          border:
                                              Border.all(color: Colors.black)),
                                      width: 20,
                                      height: 20,
                                      child: ClipOval(
                                        child: Image.network(data.image!),
                                      ),
                                    ),
                                  )
                                ],
                              ),
                            ],
                          ),
                        );
                      } else {
                        return CircularProgressIndicator();
                      }
                    },
                  ),
                );
              },
            ),
            actions: <Widget>[
              // Your existing action buttons here
            ],
            expandedHeight: 100,
          ),
          SliverList(
            delegate: SliverChildListDelegate(
              sections,
            ),
          )
        ],
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
