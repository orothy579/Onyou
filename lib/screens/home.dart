import 'package:carousel_slider/carousel_slider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../app_styles.dart';
import '../model/Notice.dart';
import 'package:logger/logger.dart';

import '../model/Story.dart';
import 'detail.dart';


List<String> list_dropdown = <String>['OCB', 'OBC', 'OEC', 'OFC', 'OSW'];
List<Widget> list_whoarewe =
<Widget>[
  Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,

      children: [
          Text(
          "Onebody Community(OC)는\n"
          "예수그리스도의 한 몸 된 지체로서\n"
          "살아계신 하나님과 몸의 머리 되신 \n예수그리스도의 지상명령에 순종합니다.",
          ),
          Column(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              TextButton(
                child:  Text("더 알아보기" , style: TextStyle(color: kShrineBrown900)),
                onPressed: () => {
                  _launchUrl(_url['Instagram']!)
                },
              ),
            ],
          )
        ]
    ),
  Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        Icon (Icons.volunteer_activism_outlined, size: 50,),
        Text("인스타그램에 방문 하셔서 \n다양한 소식과 혜택을 접해 보세요!"),
        Column(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            TextButton(
              child: const Text("방문하기" , style: TextStyle(color: Colors.black54),),
              onPressed: () => {
                _launchUrl(_url['Instagram']!)
              },
            ),
          ],
        )
      ],

    ),
  Row(
    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
    children: [
      const Icon (Icons.video_camera_back , size: 50),
      const Text("새로운 영상이 올라왔어요!"),
      Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          TextButton(
            child: const Text("방문하기" , style: TextStyle(color: Colors.black54),),
            onPressed: () => {
              _launchUrl(_url['Youtube']!)
            },
          ),
        ],
      )
    ],
  ),
];

//관련 url 집어 넣는 url
final Map<String, Uri> _url= {
  "Instagram" : Uri.parse('https://www.instagram.com/onebody_community/'),
  "Youtube" : Uri.parse('https://www.youtube.com/@Onebodycommunity'),
};

Future<void> _launchUrl(Uri url) async {
  if (!await launchUrl(url)) {
    throw 'Could not launch $url';
  }
}

Future<List<Story>> getDataASC() async {
  var logger = Logger();

  CollectionReference<Map<String, dynamic>> collectionReference =
  FirebaseFirestore.instance.collection('story');
  QuerySnapshot<Map<String, dynamic>> querySnapshot =
  await collectionReference.orderBy('create_timestamp',descending: true).get();

  final List<Story> storys = [];
  for (var doc in querySnapshot.docs) {
    Story storys1 = Story.fromQuerySnapshot(doc);

    storys.add(storys1);
  }
  logger.d(storys);
  return storys;
}



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
          scrollDirection: Axis.vertical,
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
                    child: Row(children: [
                      Icon(Icons.hail),
                      Text("SHALOM!", style: headLineStyle2)
                    ]),
                  ), //For blank
                  SizedBox(height: 18.0), //carousel
                  SizedBox(height: 18.0),
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
                              borderRadius: const BorderRadius.all(Radius.circular(10.0),),
                              child: Stack(
                                children: <Widget>[
                                  Image.network(item, fit: BoxFit.contain, width: 100000,),
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
                  //Who are we?
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Row(
                        children: [
                      Text("WHO ARE WE?", style: headLineStyle2)
                    ]
                    ),
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
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(10.0),
                                color: kShrinePink100,

                              ),
                            ))
                                .toList(),
                          )),
                  SizedBox(height: 18.0),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child:
                    Row(children: [Text("Our Story", style: headLineStyle2)]),
                  ),
                  SizedBox(height: 18.0),

                  FutureBuilder<List<Story>>(
                        future: getDataASC(),
                        builder: (context, snapshot) {
                          if (snapshot.hasData) {
                            List<Story> datas = snapshot.data!;
                            return
                              GridView.builder(
                                itemCount: datas.length,
                                itemBuilder: (BuildContext context, int index) {
                                  Story data = datas[index];

                                  return Card(
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(20)
                                    ),
                                    clipBehavior: Clip.antiAlias,
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: <Widget>[

                                        AspectRatio(
                                            aspectRatio: 18 / 11,
                                            child: Image.network(data.image!)),
                                        Expanded(
                                          child: Padding(
                                            padding: const EdgeInsets.fromLTRB(16.0, 12.0, 16.0, 8.0),
                                            child: SingleChildScrollView(
                                              child: Column(
                                                crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                                children: <Widget>[
                                                  Text(
                                                    "[${data.title!}]",
                                                    selectionColor: Colors.deepPurple,
                                                    maxLines: 1,
                                                  ),
                                                  const SizedBox(height: 8.0),
                                                  Text(" ${data.description}"),
                                                  const SizedBox(height: 8.0),
                                                  Row(
                                                    mainAxisAlignment:
                                                    MainAxisAlignment.end,
                                                    crossAxisAlignment:
                                                    CrossAxisAlignment.end,
                                                    children: [
                                                      TextButton(
                                                        child: const Text("more"),
                                                        style: TextButton.styleFrom(
                                                          padding: EdgeInsets.zero,
                                                          minimumSize: Size.zero,
                                                          textStyle: const TextStyle(
                                                              fontSize: 10,
                                                              overflow:
                                                              TextOverflow.ellipsis),
                                                          tapTargetSize:
                                                          MaterialTapTargetSize
                                                              .shrinkWrap,
                                                        ),
                                                        onPressed: () => {
                                                          Navigator.of(context).push(
                                                              MaterialPageRoute(
                                                                  builder: (context) =>
                                                                      DetailPage(storys: datas[index],
                                                                      )))
                                                        },
                                                      ),
                                                    ],
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  );

                                },
                                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: 2,
                                  childAspectRatio: 8 / 9,
                                ),
                                  shrinkWrap: true
                              );
                          }
                          else if (snapshot.hasError) {
                            return Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Text(
                                  'Error: ${snapshot.error}',
                                  style: TextStyle(fontSize: 15),
                                ));
                          }
                          else {
                            return const Center(child: CircularProgressIndicator());
                          }
                        }),




                ],
              ),
            ),
    );

  }
}
