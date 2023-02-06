import 'package:carousel_slider/carousel_slider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/material/bottom_navigation_bar.dart';
import 'colors.dart';


List<String> list = <String>['OCB', 'OBC', 'OEC', 'OFC' , 'OSW'];



class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0;

  void _onItemTapped(int index){
    setState(() {
      _selectedIndex = index;
    });
  }

  // For Dropdown
  String _dropdownValue = list.first;

  @override
  Widget build(BuildContext context) {
    return
      Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: IconButton(
              icon:  Icon(
                Icons.menu,
              ),
              onPressed: () => {Navigator.pushNamed(context, '/profile')}),
          actions: <Widget>[
            IconButton(
                icon: Icon(
                  Icons.shopping_cart,
                ),
                onPressed: () => {Navigator.pushNamed(context, '/wishlist')}

            ),
            IconButton(
                icon: Icon(
                  Icons.add,
                ),
                onPressed: () => {Navigator.pushNamed(context, '/add')}),
          ],
        ),
        body: Column(
          children: <Widget>[
            //Dropdown
            DropdownButton<String>(
                value: _dropdownValue,
                items: list.map<DropdownMenuItem<String>>((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
                onChanged: (String? value) {
                  setState(() {
                    _dropdownValue = value!;
                  });
                }),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text("함께 기도해요!   ",
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    )),
                Icon(
                  Icons.handshake,
                  color: Colors.purple,
                )
              ],
            ),
          
            StreamBuilder(
              stream: FirebaseFirestore.instance
                .collection('notice')
                .doc('image')
                .snapshots(),
              builder: (context , snapshot){
                List<dynamic> imgList = snapshot.data?.get('image');

                List<Widget> imageSliders = imgList
                    .map((item) => Container(
                  child: Container(
                    margin: EdgeInsets.all(5.0),
                    child: ClipRRect(
                        borderRadius: BorderRadius.all(Radius.circular(5.0)),
                        child: Stack(
                          children: <Widget>[
                            Image.network( item,
                                 fit: BoxFit.cover, width: 1000.0),
                            Positioned(
                              bottom: 0.0,
                              left: 0.0,
                              right: 0.0,
                              child: Container(
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: [
                                      Color.fromARGB(200, 0, 0, 0),
                                      Color.fromARGB(0, 0, 0, 0)
                                    ],
                                    begin: Alignment.bottomCenter,
                                    end: Alignment.topCenter,
                                  ),
                                ),
                                padding: EdgeInsets.symmetric(
                                    vertical: 10.0, horizontal: 20.0),
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
                        )),
                  ),
                ))
                    .toList();

                if(snapshot.data != null){
                  return CarouselSlider(
                    options: CarouselOptions(
                      aspectRatio: 2.0,
                      enlargeCenterPage: true,
                      enableInfiniteScroll: false,
                      initialPage: 2,
                      autoPlay: true,
                    ),
                    items: imageSliders,
                  );
                }
                else {
                  return const Center(child: CircularProgressIndicator());
                }
              }
            )
          ],
        ),
        bottomNavigationBar: BottomNavigationBar(
          items: <BottomNavigationBarItem>[
            BottomNavigationBarItem(
              icon: Icon(Icons.home ,),
              label: '홈',

    ),
            BottomNavigationBarItem(
              icon: Icon(Icons.group),
              label: '팀'
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.shopping_cart),
              label :'쇼핑'
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.settings),
              label :'설정'
            ),
          ],
          selectedItemColor: kShrinePink300,
          unselectedItemColor: kShrineBrown900,
          currentIndex: _selectedIndex,
          onTap: _onItemTapped,


        ),
      );
  }
}
