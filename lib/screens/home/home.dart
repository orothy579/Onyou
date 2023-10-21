import 'dart:math';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:onebody/screens/home/TooltipBalloon.dart';
import 'package:onebody/screens/home/teamGridWidget.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../style/app_styles.dart';
import 'package:logger/logger.dart';
import '../../model/Notice.dart';
import '../../model/Story.dart';
import '../../model/user.dart';


//관련 url 집어 넣는 url
final Map<String, Uri> _url = {
  "Instagram": Uri.parse('https://www.instagram.com/onebody_community/'),
  "Youtube": Uri.parse('https://www.youtube.com/@Onebodycommunity'),
};

Future<void> _launchUrl(Uri url) async {
  if (!await launchUrl(url)) {
    throw 'Could not launch $url';
  }
}

Future<Users> getUser(String userkey) async {
  DocumentReference<Map<String, dynamic>> documentReference =
      FirebaseFirestore.instance.collection('users').doc(userkey);
  final DocumentSnapshot<Map<String, dynamic>> documentSnapshot =
      await documentReference.get();
  Users user = Users.fromSnapshot(documentSnapshot);
  return user;
}

Future<List<Story>> getDataASC() async {
  var logger = Logger();

  CollectionReference<Map<String, dynamic>> collectionReference =
      FirebaseFirestore.instance.collection('story');
  QuerySnapshot<Map<String, dynamic>> querySnapshot = await collectionReference
      .orderBy('create_timestamp', descending: true)
      .get();

  final List<Story> storys = [];
  for (var doc in querySnapshot.docs) {
    Story storys1 = Story.fromQuerySnapshot(doc);

    storys.add(storys1);
  }
  logger.d(storys);
  return storys;
}

Future<List<Notice>> getNoticeDataASC() async {
  var logger = Logger();

  CollectionReference<Map<String, dynamic>> collectionReference =
      FirebaseFirestore.instance.collection('Notice');
  QuerySnapshot<Map<String, dynamic>> querySnapshot = await collectionReference
      .orderBy('create_timestamp', descending: true)
      .get();

  final List<Notice> notice = [];
  for (var doc in querySnapshot.docs) {
    Notice notice1 = Notice.fromQuerySnapshot(doc);

    notice.add(notice1);
  }
  logger.d(Notice);
  return notice;
}

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final _uid = FirebaseAuth.instance.currentUser!.uid;
  // For Dropdown
  int _current = 0;
  final CarouselController _controller = CarouselController();

  @override
  Widget build(BuildContext context) {
    List<Widget> listWhoarewe = <Widget>[
      Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [
        const Text(
          "Onebody Community(OC)는\n"
          "예수그리스도의 한 몸 된 지체로서\n"
          "살아계신 하나님과 몸의 머리 되신 \n예수그리스도의 지상명령에 순종합니다.",
        ),
        Column(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            TextButton(
              child: const Text("더 알아보기",
                  style: TextStyle(color: kShrineBrown900)),
              onPressed: () => {_launchUrl(_url['Instagram']!)},
            ),
          ],
        ),
      ]),
    ];

    List<String> bibleVerses = [
      "너희는 그리스도의 몸이요 지체의 각 부분이라 (고전12:27)",
      // Add other verses...
    ];
    String randomVerse = bibleVerses[Random().nextInt(bibleVerses.length)];

    return Scaffold(
      body: CustomScrollView(
        // CustomScrollView는 children이 아닌 slivers를 사용하며, slivers에는 스크롤이 가능한 위젯이나 리스트가 등록가능함
        slivers: <Widget>[
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
              background: TooltipBalloon(text: randomVerse,),

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
              <Widget>[
                Column(
                  children: [
                    //"공지사항"
                    SizedBox(height: 30.0),
                    //carousel
                    Center(
                      child: Container(
                          height: 25,
                          width: 100,
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                              color: boxGrey,
                              borderRadius: BorderRadius.circular(10)),
                          child: Text("News", style: headLineGreenStyle)),
                    ),
                    //For blank
                    SizedBox(height: 30.0),
                    StreamBuilder(
                        stream: FirebaseFirestore.instance
                            .collection('Notice')
                            .snapshots(),
                        builder: (context, snapshot) {
                          if (snapshot.hasError ||
                              snapshot.connectionState ==
                                  ConnectionState.waiting)
                            return const Center(
                                child: CircularProgressIndicator());

                          //ChatGpt 리얼 대박이다 !! 고마워!!! document의 전체 내용을 받아와!
                          List<dynamic> imgList = snapshot.data!.docs
                              .map((DocumentSnapshot document) {
                            Map<String, dynamic> data =
                                document.data() as Map<String, dynamic>;
                            return data['image'];
                          }).toList();

                          List<dynamic> noticeName = snapshot.data!.docs
                              .map((DocumentSnapshot document) {
                            Object? data = document.get("name");
                            return data;
                          }).toList();

                          final List<QueryDocumentSnapshot> documents =
                              snapshot.data!.docs;

                          List<Widget> imageSliders = imgList
                              .map((item) => ClipRRect(
                                  borderRadius: const BorderRadius.all(
                                    Radius.circular(10.0),
                                  ),
                                  child: Stack(
                                    children: <Widget>[
                                      Image.network(
                                        item,
                                        fit: BoxFit.contain,
                                        width: 100000,
                                      ),
                                      Positioned(
                                        bottom: 0.0,
                                        left: 0.0,
                                        right: 0.0,
                                        child: Container(
                                          decoration: const BoxDecoration(
                                            gradient: LinearGradient(
                                              colors: [
                                                Color.fromARGB(100, 0, 0, 0),
                                                Color.fromARGB(0, 0, 0, 0)
                                              ],
                                              begin: Alignment.bottomCenter,
                                              end: Alignment.topCenter,
                                            ),
                                          ),
                                          padding: const EdgeInsets.symmetric(
                                              vertical: 10.0, horizontal: 20.0),
                                          child: Text(
                                            '${documents[imgList.indexOf(item)]['name']}',
                                            style: const TextStyle(
                                              color: Colors.white,
                                              fontSize: 20.0,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                      ),
                                      Positioned(
                                        bottom: 0.0,
                                        left: 200.0,
                                        right: 0.0,
                                        child: TextButton(
                                            onPressed: () {
                                              Navigator.pushNamed(
                                                  context, '/login');
                                            },
                                            child: const Text(
                                              "더 알아보기",
                                              style: TextStyle(
                                                color: Colors.white,
                                                fontSize: 15.0,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            )),
                                      ),
                                    ],
                                  )))
                              .toList();

                          return CarouselSlider(
                            options: CarouselOptions(
                              enlargeCenterPage: true,
                              enableInfiniteScroll: false,
                              initialPage: 0,
                              autoPlay: true,
                            ),
                            items: imageSliders,
                          );
                        }),
                    const SizedBox(height: 30.0),
                    //Who are we?
                    Center(
                      child: Container(
                          height: 25,
                          width: 100,
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                              color: boxGrey,
                              borderRadius: BorderRadius.circular(10)),
                          child: Text("소개", style: headLineGreenStyle)),
                    ),
                    const SizedBox(height: 30.0),
                    CarouselSlider(
                      options: CarouselOptions(
                        height: 150,
                        autoPlay: true,
                        autoPlayInterval: const Duration(seconds: 10),
                        viewportFraction: 1,
                      ),
                      items: listWhoarewe
                          .map((item) => Container(
                                margin:
                                    const EdgeInsets.symmetric(horizontal: 20),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(10.0),
                                  color: camel,
                                ),
                                child: Center(child: item),
                              ))
                          .toList(),
                    ),
                    const SizedBox(height: 30.0),
                  ],
                ),
              ],
            ),
          ),
          TeamGridWidget(),
        ],
      ),
    );
  }
}
