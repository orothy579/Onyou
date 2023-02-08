import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class BottomBar extends StatefulWidget {
   const BottomBar({Key? key}) : super(key: key);

   @override
   State<BottomBar> createState() => _BottomBarState();
 }

 class _BottomBarState extends State<BottomBar> {
   @override
   Widget build(BuildContext context) {
     return Scaffold(
       appBar: AppBar(
         title: Text("Onebody"),
       ),
       body : Center(
         child: Text (
           "My body"
         ),
       ),
       bottomNavigationBar: BottomNavigationBar(
         elevation: 10,
         showSelectedLabels: false,
         showUnselectedLabels: false,
         selectedItemColor: Colors.blueGrey,
         unselectedItemColor: Color(0xFF526480),
         items: const[
           BottomNavigationBarItem(icon: Icon(Icons.home), label: '홈',),
           BottomNavigationBarItem(icon: Icon(Icons.group), label: '팀'),
           BottomNavigationBarItem(icon: Icon(Icons.shopping_cart), label: '쇼핑'),
           BottomNavigationBarItem(icon: Icon(Icons.settings), label: '설정'),
         ],

       ),
     );
   }
 }
