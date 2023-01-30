import 'package:flutter/material.dart';
import 'home.dart';
import 'login.dart';

class OnyouApp extends StatefulWidget {
  const OnyouApp({Key? key}) : super(key: key);

  @override
  State<OnyouApp> createState() => _OnyouAppState();
}

class _OnyouAppState extends State<OnyouApp> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Onyou',
      initialRoute: '/login',
      debugShowCheckedModeBanner: false,
      routes: {
        '/home' : (BuildContext context) => const HomePage(),
        '/login' : (BuildContext context) => const LoginPage(),
      },
    );
  }
}
