





import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:onebody/addPages/addnotice.dart';
import 'package:onebody/addPages/addstory.dart';
import 'package:onebody/screens/home.dart';

import '../app_styles.dart';

class BottomBar extends StatefulWidget {
  const BottomBar({Key? key}) : super(key: key);

  @override
  State<BottomBar> createState() => _BottomBarState();
}

class _BottomBarState extends State<BottomBar> {
  int _selectedIndex = 0;

  static final List<Widget> _widgetOptions = <Widget>[
    const HomePage(),
    const Text("Search"),
    const Text("Tickets"),
    const Text("Profile")
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  late ScrollController _scrollController;

  @override
  Widget build(BuildContext context) {
    var controller = PrimaryScrollController.of(context);

    return Scaffold(
        appBar: AppBar(
          backgroundColor: mainGreen,
          elevation: 0,
          automaticallyImplyLeading: false,
          title: Text(
            "Onebody Community",
            style: TextStyle(fontSize:10, color: Colors.white),
          ),
          // leading:
          // IconButton(
          //     icon: const Icon(
          //       Icons.exit_to_app,
          //       color: Colors.white,
          //     ),
          //     onPressed: () async {
          //       Navigator.pushNamed(context, '/login');
          //       await FirebaseAuth.instance.signOut();
          //     }
          // ),

          actions: <Widget>[
            IconButton(
                icon: Icon(
                  Icons.shopping_cart,
                  color: Colors.white,
                ),
                onPressed: () => {Navigator.pushNamed(context, '/wishlist')}),
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
                      pageBuilder: (context, __, ___) => AddStoryPage(),
                      transitionDuration: Duration.zero,
                      reverseTransitionDuration: Duration.zero,
                    ),
                  );
                }),
          ],
        ),
        body:  _widgetOptions[_selectedIndex],
        bottomNavigationBar: GestureDetector(
          onDoubleTap: () {
            controller.animateTo(0,
                duration: Duration(milliseconds: 280), curve: Curves.linear);
          },
          child: BottomNavigationBar(
            currentIndex: _selectedIndex,
            onTap: _onItemTapped,
            elevation: 10,
            showSelectedLabels: true,
            showUnselectedLabels: true,
            selectedItemColor: Colors.white,
            unselectedItemColor: Colors.black,
            items: [
              BottomNavigationBarItem(
                icon: Icon(Icons.home_outlined),
                label: "홈",
              ),
              BottomNavigationBarItem(
                  icon: Icon(Icons.groups_outlined), label: "팀", backgroundColor: mainGreen),
              BottomNavigationBarItem(
                  icon: Icon(Icons.shopping_cart_outlined), label: "굿즈"),
              BottomNavigationBarItem(
                  icon: Icon(Icons.settings_outlined), label: "설정"),
            ],
          ),
        ));
  }
}