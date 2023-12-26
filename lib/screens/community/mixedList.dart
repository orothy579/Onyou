import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:onebody/screens/addPages/selectionPage.dart';
import 'package:onebody/screens/community/prayertitleCard.dart';
import 'package:onebody/screens/community/storyCard.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../model/Story.dart';
import 'package:intl/src/intl/date_format.dart';
import '../../model/PrayerTitle.dart';
import '../../model/user.dart';
import '../../widgets/TooltipBalloon.dart';
import '../home/home.dart';
import 'dart:ui'; // for the BackdropFilter

final Map<String, Uri> _url = {
  "Instagram": Uri.parse('https://www.instagram.com/onebody_community/'),
  "Youtube": Uri.parse('https://www.youtube.com/@Onebodycommunity'),
};

Future<void> _launchUrl(Uri url) async {
  if (!await launchUrl(url)) {
    throw 'Could not launch $url';
  }
}

List<String> bibleVerses = [
  "너희는 그리스도의 몸이요 지체의 각 부분이라",
  "오직 사랑 안에서 참된 것을 하여 범사에 그에게까지 자랄지라 그는 머리니 곧 그리스도라",
  "내게 주신 영광을 내가 그들에게 주었사오니 이는 우리가 하나가 된 것 같이 그들도 하나가 되게 하려 함이니이다",
  "이에 예수께서 제자들에게 이르시되 누구든지 나를 따라오려거든 자기를 부인하고 자기 십자가를 지고 나를 따를 것이니라 "
  // Add other verses...
];

String randomVerse = bibleVerses[Random().nextInt(bibleVerses.length)];

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
          final story = Story.fromQuerySnapshot(
              doc as QueryDocumentSnapshot<Map<String, dynamic>>);
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

    sections.add(
        Container(
          margin: EdgeInsets.all(10),
          child: Stack(
            clipBehavior: Clip.none, // Overflow를 허용합니다.
            children: <Widget>[
              // 텍스트와 버튼을 포함하는 Row
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Text(
                    "공동체 소식 타임라인",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color(0xff52525C),
                    ),
                  ),
                  Container(
                    width: 35,
                    height: 35,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Color(0xff0014FF).withOpacity(1),
                          spreadRadius: 0.8,
                          offset: Offset(1, 1),
                        ),
                      ],
                    ),
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        side: BorderSide(color: Color(0xff52525C), width: 2.0),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 1.0,
                        padding: EdgeInsets.fromLTRB(2, 0, 0, 0),
                      ),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => SelectionPage())
                        );
                      },
                      child: const Icon(
                        Icons.add,
                        color: Color(0xff52525C),
                        size: 25.0,
                      ),
                    ),
                  ),
                ],
              ),
              // 선을 그리는 Container
              Positioned(
                left: 0,
                right: 0,
                bottom: -10, // 버튼 밑으로 선을 내리려면 여기 값을 음수로 설정합니다.
                child: Container(
                  height: 1.0,
                  color: Colors.black,
                ),
              ),

            ],
          ),
        ),

    );

    mixedItemsByDate.entries.forEach((entry) {
      sections.add(
        SizedBox(height: 10)
      );
      sections.add(
        Text(
          DateFormat('yyyy년 MM월 dd일').format(entry.key),
          style: const TextStyle(
              fontSize: 10, fontWeight: FontWeight.bold, color: Colors.black26),
          textAlign: TextAlign.center,
        ),
      );

      sections.addAll(entry.value.map((item) {
        if (item.type == 'story') {
          final story = item.data as Story?;
          if (story == null) {
            return const Center(child: Text("이야기가 없습니다."));
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

    return CustomScrollView(
      slivers: [
        SliverAppBar(
          automaticallyImplyLeading: false,
          backgroundColor: Colors.transparent,
          elevation: 20,
          flexibleSpace: FlexibleSpaceBar(
            titlePadding: EdgeInsets.fromLTRB(15, 70, 0, 20),
            title: FutureBuilder<Users>(
              future: getUser(FirebaseAuth.instance.currentUser!.uid),
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  Users data = snapshot.data!;
                  return Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          color: Color(0xff92FABC),
                          shape: BoxShape.circle,
                        ),
                        width: 40,
                        height: 40,
                        child: ClipOval(
                          child: Image.network(
                            data.image!,
                            fit: BoxFit
                                .cover, // Ensure the image covers the container
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Flexible(
                            child: FutureBuilder<DocumentSnapshot>(
                              future: data.teamRef
                                  ?.get(), // assuming teamRef is a DocumentReference
                              builder: (context, teamSnapshot) {
                                if (teamSnapshot.connectionState ==
                                    ConnectionState.waiting) {
                                  return Text("Loading team...");
                                } else if (teamSnapshot.hasError) {
                                  return Text("Error: ${teamSnapshot.error}");
                                } else if (!teamSnapshot.hasData) {
                                  return Text("No team data");
                                } else {
                                  Map<String, dynamic>? teamData =
                                      teamSnapshot.data!.data()
                                          as Map<String, dynamic>?;
                                  return Text(
                                    "${teamData?['name'] ?? 'No Name'}",
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                        fontSize: 10,
                                        fontFamily: 'Pretendard',
                                        color: Color(0xff52525C)),
                                  );
                                }
                              },
                            ),
                          ),
                          Text(
                            data.name!,
                            style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.bold,
                                fontFamily: 'Pretendard',
                                color: Color(0xff52525C)),
                          ),
                        ],
                      ),
                      const Spacer(),
                    ],
                  );
                } else if (snapshot.hasError) {
                  return Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                      'Error: ${snapshot.error}',
                      style: TextStyle(fontSize: 15),
                    ),
                  );
                } else {
                  return const Center(child: CircularProgressIndicator());
                }
              },
            ),
            background: TooltipBalloon(
              text: randomVerse,
            ),
            centerTitle: false,
            expandedTitleScale: 1.0,
          ),
          actions: <Widget>[
            IconButton(
              icon: const FaIcon(
                FontAwesomeIcons.instagram,
                color: Colors.black,
              ),
              onPressed: () {
                _launchUrl(_url['Instagram']!);
              },
            ),
            IconButton(
              icon: const FaIcon(
                FontAwesomeIcons.youtube,
                color: Colors.red,
              ),
              onPressed: () {
                _launchUrl(_url['Youtube']!);
              },
            ),
          ],
          expandedHeight: 120,
        ),
        SliverList(
          delegate: SliverChildListDelegate(
            sections,
          ),
        )
      ],
    );
  }
}

class MixedItem {
  final Timestamp timestamp;
  final String type;
  final dynamic data;

  MixedItem(this.timestamp, this.type, this.data);
}
