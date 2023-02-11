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

  static final List<Widget>_widgetOptions = <Widget>[
    const HomePage(),
    const Text("Search"),
    const Text("Tickets"),
    const Text("Profile")
  ];

  void _onItemTapped(int index){
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
         backgroundColor: Colors.transparent,
         elevation: 0,
         leading: IconButton(
             icon: Icon(
               Icons.menu,
             ),
             onPressed: () => {Navigator.pushNamed(context, '/profile')}),
         actions: <Widget>[
           IconButton(
               icon: Icon(
                 Icons.shopping_cart,
               ),
               onPressed: () => {Navigator.pushNamed(context, '/wishlist')}),
           IconButton(
               icon: Icon(
                 Icons.add,
               ),
               onPressed: ()  {
                 Navigator.push(
                     context,
                     PageRouteBuilder(
               pageBuilder: (context,__,___) => AddNoticePage(),
               transitionDuration: Duration.zero,
               reverseTransitionDuration: Duration.zero,
                     ),
                 );
               }
           ),
           IconButton(
               icon: Icon(
                 Icons.add_circle,
               ),
               onPressed: ()  {
                 Navigator.push(
                   context,
                   PageRouteBuilder(
                     pageBuilder: (context,__,___) => AddStoryPage(),
                     transitionDuration: Duration.zero,
                     reverseTransitionDuration: Duration.zero,
                   ),
                 );
               }
           ),
           IconButton(
               icon: const Icon(
                 Icons.exit_to_app,
               ),
               onPressed: () async {
                 Navigator.pushNamed(context, '/login');
                 await FirebaseAuth.instance.signOut();
               }
               ),
         ],
       ),

       body : Center(child: _widgetOptions[_selectedIndex]),
       bottomNavigationBar:


         BottomNavigationBar(
           currentIndex: _selectedIndex,
           onTap: _onItemTapped,
           elevation: 10,
           showSelectedLabels: true,
           showUnselectedLabels: true,
           selectedItemColor: kShrinePink300,
           unselectedItemColor: kShrineBrown900,
           items: [
             BottomNavigationBarItem(
               icon: InkWell(
                 onDoubleTap: () {controller.jumpTo(0);},
                 child : Icon(Icons.home),
                 ),
               label: "홈"
             ),
             BottomNavigationBarItem(
                 icon: InkWell(
                   onDoubleTap: () {controller.jumpTo(0);},
                   child : Icon(Icons.group),
                 ),
                 label: "팀"
             ),
             BottomNavigationBarItem(
                 icon: InkWell(
                   onDoubleTap: () {controller.jumpTo(0);},
                   child : Icon(Icons.shopping_cart),
                 ),
                 label: "쇼핑"
             ),
             BottomNavigationBarItem(
                 icon: InkWell(
                   onDoubleTap: () {controller.jumpTo(0);},
                   child : Icon(Icons.settings),
                 ),
                 label: "설정"
             ),
           ],
         ),
     );
   }
 }
