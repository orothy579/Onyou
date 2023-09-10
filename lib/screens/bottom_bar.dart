import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:onebody/screens/community/mixedList.dart';
import 'package:onebody/screens/gallery/GalleryPage.dart';
import 'package:onebody/screens/home/home.dart';
import 'package:http/http.dart' as http;
import 'package:onebody/screens/settings/settings.dart';
import '../style/app_styles.dart';
import 'calendar/calendar.dart';

class BottomBar extends StatefulWidget {
  int id;
  BottomBar({Key? key, required this.id}) : super(key: key);

  @override
  State<BottomBar> createState() => _BottomBarState();
}

class _BottomBarState extends State<BottomBar> {
  // int _selectedIndex = id;
  String? mtoken;
  late FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

  int get _selectedIndex => widget.id;



  void initState(){
    super.initState();
    requestPermission();
    getToken();
    initInfo();

  }

  initInfo(){
    var iOSInitialize = const DarwinInitializationSettings();
    var androidInitialize = const AndroidInitializationSettings('@mipmap/ic_launcher'); // 골뱅이 되어 있는거 아이콘 입니당 경로 : android > app > src > main> res> mipmap-hdpi [ 무조건 png 이어야함]
    var initializationSettings = InitializationSettings(android: androidInitialize, iOS: iOSInitialize);


    flutterLocalNotificationsPlugin.initialize(initializationSettings);

    FirebaseMessaging.onMessage.listen((RemoteMessage message) async {
      print("--- onMessage ---");
      print("on Message : ${message.notification?.title}/${message.notification?.body}");

      BigTextStyleInformation bigTextStyleInformation = BigTextStyleInformation(
        message.notification!.body.toString(), htmlFormatBigText: true,
        contentTitle: message.notification!.title.toString(), htmlFormatContent: true,
      );

      AndroidNotificationDetails androidPlatformChannelSpecifics = AndroidNotificationDetails(
        'dbfood' , 'dbfood' , importance: Importance.high,
        styleInformation: bigTextStyleInformation, priority: Priority.high, playSound: true,
      );

      NotificationDetails platformChannelSpecifics = NotificationDetails(android: androidPlatformChannelSpecifics,
          iOS: const DarwinNotificationDetails()
      );
      await flutterLocalNotificationsPlugin.show(0, message.notification?.title, message.notification?.body,
          platformChannelSpecifics,
          payload: message.data['title']
      );

    });


  }

  void getToken() async {
    await FirebaseMessaging.instance.getToken().then(
            (token) {
          setState(() {
            mtoken = token;
            print("My token is $mtoken");
          });
          saveToken(token!);
        }
    );
  }
  //save Token in firebase, Token is different from different device
  void saveToken(String token) async {
    await FirebaseFirestore.instance.collection("UserTokens").doc("User2").set(
        {
          'token' : token,
        }
    );
  }

  void requestPermission() async {
    FirebaseMessaging messaging = FirebaseMessaging.instance;

    NotificationSettings settings = await messaging.requestPermission(
      alert: true,
      announcement: false,
      badge: true,
      carPlay: false,
      criticalAlert: false,
      provisional: false,
      sound: true,
    );

    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      print('User granted permission');
    } else if (settings.authorizationStatus == AuthorizationStatus.provisional) {
      print('User granted provisional permission');
    } else {
      print('User declined or has not accepted permission');
    }

  }

  void sendPushMessage(String token , String body , String title) async {
    await http.post(
        Uri.parse('https://fcm.googleapis.com/fcm/send'),
        headers: <String, String>{
          'Content-Type' : 'application/json',
          'Authorization' : 'key=AAAAdhLBm9c:APA91bGsfbO7sXFLiOAzNaGzpL3QtrslmmKPifFzFnAOXFiFkdKD77132opf2Mw3rbUkI3m8K08oD3DqAoS_qX5AByfO_3jjz9wuxnJLfuK9YdGvhkBslvrpJb6D_5I2aKp4MVj1lsa8'
        },
        body: jsonEncode(
          <String,dynamic> {

            'priority': 'high',
            'data' : <String, dynamic> {
              'click_action' : 'FLUTTER_NOTIFICATION_CLICK',
              'status' : 'done',
              'body' : body,
              'title' : title,
            },
            "notification" : <String, dynamic>{
              "title" : title,
              "body" : body,
              "android_channel_id" : "dbfood"
            },
            "to": token,
          },
        )
    );

    print("$title / ${body}");
  }

  static final List<Widget> _widgetOptions = <Widget>[
    const HomePage(),
    MixedList(),
    GalleryPage(),
    const CalendarPage(),
    SettingsPage(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      widget.id = index;
    });
  }

  late ScrollController _scrollController;

  @override
  Widget build(BuildContext context) {
    var controller = PrimaryScrollController.of(context);

    return Scaffold(
        body: _widgetOptions[_selectedIndex],
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
                  icon: Icon(Icons.view_timeline_outlined), label: "커뮤니티"),
              BottomNavigationBarItem(
                  icon: FaIcon(FontAwesomeIcons.photoFilm), label: "사진첩"),
              // BottomNavigationBarItem(
              //     icon: Icon(Icons.shopping_cart_outlined), label: "굿즈"),
              BottomNavigationBarItem(icon: Icon(Icons.calendar_month_outlined), label: "일정"),
              BottomNavigationBarItem(
                  icon: Icon(Icons.settings_outlined), label: "설정"),
            ],
          ),
        ));
  }
}
