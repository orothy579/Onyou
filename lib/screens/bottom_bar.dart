import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:onebody/screens/home.dart';

import '../addPages/addnotice.dart';
import '../addPages/addstory.dart';
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
        body: Center(child: _widgetOptions[_selectedIndex]),
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
            selectedItemColor: mainGreen,
            unselectedItemColor: Colors.black,
            items: [
              BottomNavigationBarItem(
                  icon: Icon(Icons.home_outlined),
                  label: "홈", ),
              BottomNavigationBarItem(
                  icon: Icon(Icons.groups_outlined), label: "팀"),
              BottomNavigationBarItem(
                  icon: Icon(Icons.shopping_cart_outlined), label: "굿즈"),
              BottomNavigationBarItem(
                  icon: Icon(Icons.settings_outlined), label: "설정"),
            ],
          ),
        ));
  }
}
