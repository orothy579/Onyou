import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:http/http.dart' as http;

class MainScreen extends StatefulWidget {
  const MainScreen({Key? key}) : super(key: key);

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  String? mtoken;
  late FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
  TextEditingController username = TextEditingController();
  TextEditingController title = TextEditingController();
  TextEditingController body = TextEditingController();


  @override
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
  //save Token in firebase, Token is diffretn from diffrent device
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

    print("Hello 찬휘");
    print("$title / ${body}");
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextFormField(
              controller: username,
            ),
            TextFormField(
              controller: title,
            ),
            TextFormField(
              controller: body,
            ),
            GestureDetector(
              onTap: () async {
                String name = username.text.trim();
                String titleText = title.text;
                String bodyText = body.text;

                if(name != ""){
                  DocumentSnapshot snap =
                      await FirebaseFirestore.instance.collection("UserTokens").doc(name).get();

                  String token = snap['token'];
                  print(token);

                  sendPushMessage(token, titleText, bodyText);

                }

              },
              child: Container(
                margin: const EdgeInsets.all(20),
                height: 40,
                width: 200,

                decoration: BoxDecoration(
                  color: Colors.green,
                  borderRadius:  BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.red.withOpacity(0.5)
                    )
                  ]
                ),

                child: Center(child: Text('button'),),
              ),
            )
          ],
        ),
      )
    );
  }



}


