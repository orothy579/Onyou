import 'dart:math';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:onebody/widgets/TooltipBalloon.dart';
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
      "너희는 그리스도의 몸이요 지체의 각 부분이라",
      "오직 사랑 안에서 참된 것을 하여 범사에 그에게까지 자랄지라 그는 머리니 곧 그리스도라",
      "내게 주신 영광을 내가 그들에게 주었사오니 이는 우리가 하나가 된 것 같이 그들도 하나가 되게 하려 함이니이다",
      "이에 예수께서 제자들에게 이르시되 누구든지 나를 따라오려거든 자기를 부인하고 자기 십자가를 지고 나를 따를 것이니라 "
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
              <Widget>[
                Column(
                  children: [
                    //"공지사항"
                    SizedBox(height: 20.0),
                    //carousel
                    Stack(
                      children: [
                        //CustomShadow(color: Colors.black,width: 260, height: 400,),
                        StreamBuilder(
                          stream: FirebaseFirestore.instance
                              .collection('Notice')
                              .snapshots(),
                          builder: (context, snapshot) {
                            if (snapshot.hasError ||
                                snapshot.connectionState ==
                                    ConnectionState.waiting) {
                              return const Center(
                                  child: CircularProgressIndicator());
                            }

                            List<dynamic> imgList = snapshot.data!.docs
                                .map((DocumentSnapshot document) {
                              Map<String, dynamic> data =
                                  document.data() as Map<String, dynamic>;
                              return data['image'];
                            }).toList();

                            List<Widget> imageSliders = imgList
                                .map((item) => Container(
                                      decoration: BoxDecoration(
                                        border: Border.all(
                                            color: Color(0xff52525C), width: 2),
                                        borderRadius:
                                            BorderRadius.circular(10.0),
                                        // boxShadow: [
                                        //   BoxShadow(
                                        //     color: Color(0xff0014FF).withOpacity(1), // 그림자의 색상
                                        //     spreadRadius: 3,  // 그림자의 확장 반경
                                        //     offset: Offset(3, 3),
                                        //   )
                                        // ]
                                      ),
                                      child: ClipRRect(
                                        borderRadius:
                                            BorderRadius.circular(5.0),
                                        child: Stack(
                                          children: <Widget>[
                                            Image.network(item,
                                                fit: BoxFit.cover,
                                                width: double.infinity),
                                            Positioned(
                                              bottom: -20.0,
                                              left: 0.0,
                                              right: 0.0,
                                              child: Container(
                                                color: Colors.transparent,
                                                padding: EdgeInsets.symmetric(
                                                    horizontal: 20.0,
                                                    vertical: 10.0),
                                                child: Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment
                                                          .spaceBetween,
                                                  children: [
                                                    Text(
                                                      '${snapshot.data!.docs[imgList.indexOf(item)]['name']}',
                                                      style: TextStyle(
                                                        color: Colors.white,
                                                        fontSize: 20.0,
                                                        fontWeight:
                                                            FontWeight.bold,
                                                      ),
                                                    ),
                                                    TextButton(
                                                      onPressed: () {
                                                        Navigator.pushNamed(
                                                            context, '/login');
                                                      },
                                                      child: const Text(
                                                        "더 알아보기",
                                                        style: TextStyle(
                                                          color: Colors.white,
                                                          fontSize: 15.0,
                                                          fontWeight:
                                                              FontWeight.bold,
                                                        ),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ))
                                .toList();

                            return Padding(
                              padding: const EdgeInsets.fromLTRB(0, 8, 0, 0),
                              child: CarouselSlider(
                                options: CarouselOptions(
                                  viewportFraction: 0.9,
                                  height: 113,
                                  enlargeCenterPage: true,
                                  enableInfiniteScroll: false,
                                  initialPage: 0,
                                  autoPlay: true,
                                ),
                                items: imageSliders,
                              ),
                            );
                          },
                        ),
                        Align(
                          alignment: Alignment.topCenter,
                          child: Padding(
                            padding: const EdgeInsets.only(top: 0.0),
                            child: Container(
                              height: 20,
                              width: 60,
                              alignment: Alignment.center,
                              decoration: BoxDecoration(
                                color: Color(0xff0014FF),
                                border: Border.all(
                                    color: Color(0xff52525C), width: 2),
                                borderRadius: BorderRadius.circular(15),
                              ),
                              child: const Text("주요 공지",
                                  style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 10)),
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 30.0),

                    Container(
                      margin: const EdgeInsets.fromLTRB(22, 0, 0, 0),
                      child: Row(
                        children: [
                          const Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // 한국어 텍스트
                              Text(
                                '원바디 커뮤니티란?',
                                style: TextStyle(
                                  fontSize: 20.0,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              SizedBox(width: 10.0), // 간격 추가
                              // 영어 텍스트
                              Text(
                                "Get to Know Onebody Community!",
                                style: TextStyle(
                                  fontSize: 15.0,
                                  color: Color(0xff52525C),
                                ),
                              ),
                              SizedBox(width: 10.0), // 간격 추가
                              // 버튼
                            ],
                          ),
                          const SizedBox(width: 12.0),
                          Container(
                            alignment: Alignment.center,
                            width: 35,
                            height: 35,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(12),

                                boxShadow: [
                                  BoxShadow(
                                    color: Color(0xff0014FF).withOpacity(1), // 그림자의 색상
                                    spreadRadius: 0.8,  // 그림자의 확장 반경
                                    offset: Offset(2, 2),
                                  )
                                ]

                            ),
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.white,
                                side: BorderSide(color: Color(0xff52525C), width: 2.0),
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12)
                                ),
                                elevation: 1.0,
                                padding: EdgeInsets.fromLTRB(2, 0, 0, 0)
                              ),
                              onPressed: () {
                                // TODO: 버튼이 클릭될 때 수행할 작업
                              },
                              child: Icon(
                                Icons.arrow_forward_ios_rounded,
                                color: Color(0xff52525C),
                                size: 18.0,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    //Who are we?

                    const SizedBox(height: 8.0),

                    CarouselSlider(
                      options: CarouselOptions(
                        height: 240,
                        autoPlay: true,
                        autoPlayInterval: const Duration(seconds: 10),
                        viewportFraction: 1,
                      ),
                      items: listWhoarewe
                          .map((item) => Container(
                                margin:
                                    const EdgeInsets.symmetric(horizontal: 20),
                                decoration: BoxDecoration(
                                  border: Border.all(
                                      color: Color(0xff52525C), width: 1),
                                  borderRadius: BorderRadius.circular(10.0),
                                  color: Colors.white,
                                ),
                                child: Center(child: item),
                              ))
                          .toList(),
                    ),
                    const SizedBox(height: 30.0),

                    Container(
                      margin: const EdgeInsets.fromLTRB(22, 0, 0, 0),
                      child: const Row(
                        children: [
                          Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // 한국어 텍스트
                              Text(
                                '커뮤니티',
                                style: TextStyle(
                                  fontSize: 20.0,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                          SizedBox(width: 10,),
                          Text(
                            "We are Onebody Community",
                            style: TextStyle(
                              fontSize: 15.0,
                              color: Color(0xff52525C),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 8.0),

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
