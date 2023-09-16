import 'package:carousel_slider/carousel_slider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:onebody/screens/home/teamGridWidget.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../style/app_styles.dart';
import 'package:logger/logger.dart';
import '../../model/Notice.dart';
import '../../model/Story.dart';
import '../../model/user.dart';
import '../addPages/addnotice.dart';
import '../addPages/selectionPage.dart';

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
    List<Widget> list_whoarewe = <Widget>[
      Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [
        Text(
          "Onebody Community(OC)는\n"
          "예수그리스도의 한 몸 된 지체로서\n"
          "살아계신 하나님과 몸의 머리 되신 \n예수그리스도의 지상명령에 순종합니다.",
        ),
        Column(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            TextButton(
              child: Text("더 알아보기", style: TextStyle(color: kShrineBrown900)),
              onPressed: () => {_launchUrl(_url['Instagram']!)},
            ),
          ],
        ),
      ]),
      Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          Icon(
            Icons.volunteer_activism_outlined,
            size: 50,
          ),
          Text("인스타그램에 방문 하셔서 \n다양한 소식과 혜택을 접해 보세요!" , style: TextStyle(fontFamily: 'Pretendard'),),
          Column(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              TextButton(
                child: const Text(
                  "방문하기",
                  style: TextStyle(color: Colors.black54),
                ),
                onPressed: () => {_launchUrl(_url['Instagram']!)},
              ),
            ],
          )
        ],
      ),
      Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          const Icon(Icons.video_camera_back, size: 50),
          const Text("새로운 영상이 올라왔어요!"),
          Column(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              TextButton(
                child: const Text(
                  "방문하기",
                  style: TextStyle(color: Colors.black54),
                ),
                onPressed: () => {_launchUrl(_url['Youtube']!)},
              ),
            ],
          )
        ],
      ),
      Center(
        child: IconButton(
          iconSize: 50,
          icon: Icon(Icons.question_mark),
          onPressed: () {
            Navigator.pushNamed(context, '/sentence');
          },
        ),
      ),
    ];

    return Scaffold(
      body:
      CustomScrollView(
        // CustomScrollView는 children이 아닌 slivers를 사용하며, slivers에는 스크롤이 가능한 위젯이나 리스트가 등록가능함
        slivers: <Widget>[
          // 앱바 추가
          SliverAppBar(
            automaticallyImplyLeading: false,
            elevation: 20,
            flexibleSpace: FlexibleSpaceBar(
              titlePadding: EdgeInsets.fromLTRB(15, 45, 0, 0),
              title: FutureBuilder<Users>(
                future: getUser(FirebaseAuth.instance.currentUser!.uid),
                builder: (context, snapshot) {
                  if (snapshot.hasData) {
                    Users data = snapshot.data!;
                    return ListView(
                      children: [
                        Text(
                          "Shalom,",
                          style: TextStyle(fontSize: 15 , fontFamily: 'Pretendard'),
                        ),
                        Row(
                          children: [
                            Text(
                              "${data.name!} 님",
                              style: TextStyle(
                                  fontSize: 20, fontWeight: FontWeight.bold , fontFamily: 'Pretendard'),
                            ),
                            Container(
                              alignment: Alignment.bottomRight,
                              child: Container(
                                decoration: BoxDecoration(
                                    color: camel, shape: BoxShape.circle),
                                width: 20,
                                height: 20,
                                child: Image.network(data.image!),
                              ),
                            )
                          ],
                        ),
                      ],
                    );
                  } else if (snapshot.hasError) {
                    return Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(
                          'Error: ${snapshot.error}',
                          style: TextStyle(fontSize: 15),
                        ));
                  } else {
                    return const Center(child: CircularProgressIndicator());
                  }
                },
              ),
              centerTitle: false,
              expandedTitleScale: 1.0,
            ),
            actions: <Widget>[
              IconButton(
                  icon: Icon(
                    Icons.add,
                    color: Colors.white,
                  ),
                  onPressed: () {
                    Navigator.push(
                      context,
                      PageRouteBuilder(
                        pageBuilder: (context, __, ___) => AddNoticePage(),
                        transitionDuration: Duration.zero,
                        reverseTransitionDuration: Duration.zero,
                      ),
                    );
                  }),
              IconButton(
                  icon: Icon(
                    Icons.add_circle,
                    color: Colors.white,
                  ),
                  onPressed: () {
                    Navigator.push(
                      context,
                      PageRouteBuilder(
                        pageBuilder: (context, __, ___) => SelectionPage(),
                        transitionDuration: Duration.zero,
                        reverseTransitionDuration: Duration.zero,
                      ),
                    );
                  }),
              IconButton(
                  icon: const Icon(
                    Icons.exit_to_app,
                    color: Colors.white,
                  ),
                  onPressed: () async {
                    await FirebaseAuth.instance.signOut();
                    await GoogleSignIn().signOut();

                    Navigator.pushNamed(context, '/login');
                  }),
            ],
            // 최대 높이
            expandedHeight: 100,
          ),
          // 리스트 추가
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
                          child: Text("News", style: headLineGreenStyle)
                      ),
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
                                          decoration: BoxDecoration(
                                            gradient: LinearGradient(
                                              colors: [
                                                Color.fromARGB(100, 0, 0, 0),
                                                Color.fromARGB(0, 0, 0, 0)
                                              ],
                                              begin: Alignment.bottomCenter,
                                              end: Alignment.topCenter,
                                            ),
                                          ),
                                          padding: EdgeInsets.symmetric(
                                              vertical: 10.0, horizontal: 20.0),
                                          child: Text(
                                            '${documents[imgList.indexOf(item)]['name']}',
                                            style: TextStyle(
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
                                            child: Text(
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
                    SizedBox(height: 30.0),
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
                    SizedBox(height: 30.0),
                    Container(
                        child: CarouselSlider(
                      options: CarouselOptions(
                        height: 150,
                        autoPlay: true,
                        autoPlayInterval: Duration(seconds: 10),
                        viewportFraction: 1,
                      ),
                      items: list_whoarewe
                          .map((item) => Container(
                                margin: EdgeInsets.symmetric(horizontal: 20),
                                child: Center(child: item),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(10.0),
                                  color: camel,
                                ),
                              ))
                          .toList(),
                    )),
                    SizedBox(height: 30.0),
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
