import 'package:carousel_slider/carousel_slider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../app_styles.dart';
import '../main2.dart';

List<String> list_dropdown = <String>['OCB', 'OBC', 'OEC', 'OFC', 'OSW'];
List<Widget> list_whoarewe =
<Widget>[
  Text('원바디 커뮤니티와 SNS 친구를 맺고 다양한 이벤트 혜택을 누려보세요. 인스타그램 방문하기'),
  Row(
    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
    children: [
      Icon (Icons.video_camera_back , size: 30,),
      Text("새로운 영상이 올라왔어요!"),
    ],
  ),
  Text('원바디 커뮤니티와 SNS 친구를 맺고 다양한 이벤트 혜택을 누려보세요. 인스타그램 방문하기'),
  Text('원바디 커뮤니티와 SNS 친구를 맺고 다양한 이벤트 혜택을 누려보세요. 인스타그램 방문하기'),

];


class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final _uid = FirebaseAuth.instance.currentUser!.uid;
  // For Dropdown
  String _dropdownValue = list_dropdown.first;
  int _current = 0;
  final CarouselController _controller = CarouselController();

  @override
  Widget build(BuildContext context) {
    return 
       Scaffold(
        body: SingleChildScrollView(
          child: Column(
                children: <Widget>[
                  //For dropdown
                  //Dropdown
                  // DropdownButton<String>(
                  //     value: _dropdownValue,
                  //     items: list.map<DropdownMenuItem<String>>((String value) {
                  //       return DropdownMenuItem<String>(
                  //         value: value,
                  //         child: Text(value),
                  //       );
                  //     }).toList(),
                  //     onChanged: (String? value) {
                  //       setState(() {
                  //         _dropdownValue = value!;
                  //       });
                  //     }),
                  //Welcome Message With Stream Builder

                  // //For welcome message
                  // StreamBuilder(
                  //   stream: FirebaseFirestore.instance
                  //       .collection('users')
                  //       .doc(_uid)
                  //       .snapshots(),
                  //   builder: (context, snapshot) {
                  //     if (snapshot.hasData && snapshot.data?.exists != null) {
                  //       String name = snapshot.data!.get('email');
                  //       return Row(
                  //         mainAxisAlignment: MainAxisAlignment.center,
                  //         children: [
                  //           Text("${name} 님 안녕하세요! ",
                  //               style: TextStyle(
                  //                 fontSize: 10,
                  //                 fontWeight: FontWeight.bold,
                  //               )),
                  //           Icon(
                  //             Icons.handshake,
                  //           )
                  //         ],
                  //       );
                  //     } else {
                  //       return const Center(child: CircularProgressIndicator());
                  //     }
                  //   },
                  // ),
                  //"공지사항"
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Row(children: [Text("SHALOM!", style: headLineStyle2)]),
                  ),
                  //For blank
                  SizedBox(height: 18.0),
                  //carousel
                  StreamBuilder(
                      stream: FirebaseFirestore.instance
                          .collection('notice')
                          .doc('image')
                          .snapshots(),
                      builder: (context, snapshot) {
                        if (snapshot.hasData && snapshot.data?.exists != null) {
                          List<dynamic> imgList = snapshot.data?.get('image');
                          List<Widget> imageSliders = imgList
                              .map((item) => ClipRRect(
                                  borderRadius: const BorderRadius.all(Radius.circular(20.0)),
                                  child: Stack(
                                    children: <Widget>[
                                      Image.network(item, fit: BoxFit.contain, width: 1000.0),
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
                                              vertical: 10.0,
                                              horizontal: 20.0
                                          ),
                                          child: Text(
                                            'No. ${imgList.indexOf(item)} image',
                                            style: TextStyle(
                                              color: Colors.white,
                                              fontSize: 20.0,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ))).toList();

                          return CarouselSlider(
                            options: CarouselOptions(
                              enlargeCenterPage: true,
                              enableInfiniteScroll: false,
                              initialPage: 0,
                              autoPlay: false,
                            ),
                            items: imageSliders,
                          );
                        } else {
                          return const Center(child: CircularProgressIndicator());
                        }
                      }),
                  SizedBox(height: 18.0),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child:
                    Row(children: [Text("WHO ARE WE?", style: headLineStyle2)]),
                  ),
                  SizedBox(height: 18.0),
                  Container(
                          child: CarouselSlider(
                            options: CarouselOptions(
                              height: 150,
                              autoPlay: true,
                              autoPlayInterval: Duration(seconds: 10) ,
                              viewportFraction: 1,
                            ),
                            items: list_whoarewe
                                .map((item) => Container(
                              margin: EdgeInsets.symmetric(horizontal: 20),
                              child: Center(child: item),
                              color: kShrinePink100,
                            ))
                                .toList(),
                          )),
                ],
              ),
            ),
    );

  }
}
