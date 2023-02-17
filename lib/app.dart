import 'package:flutter/material.dart';
import 'package:onebody/addPages/addnotice.dart';
import 'package:onebody/addPages/addstory.dart';
import 'package:onebody/practice/main_screen.dart';
import 'package:onebody/screens/bottom_bar.dart';
import 'package:onebody/screens/sentence.dart';
import 'login.dart';
import 'style/app_styles.dart';

final ThemeData _onbodyTheme = _buildOnebodyTheme();

ThemeData _buildOnebodyTheme() {
  final ThemeData base = ThemeData.light();
  return base.copyWith(
      colorScheme: base.colorScheme.copyWith(
      primary: mainGreen,
      onPrimary: Colors.white,
      secondary: Colors.white,
      error: kShrineErrorRed,
  ),
  // TODO: Add the text themes (103)
  // TODO: Add the icon themes (103)
  // TODO: Decorate the inputs (103)
  );
}


class OnyouApp extends StatefulWidget {
  const OnyouApp({Key? key}) : super(key: key);

  @override
  State<OnyouApp> createState() => _OnyouAppState();
}

class _OnyouAppState extends State<OnyouApp> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Onebody Community',
      initialRoute: '/login',
      debugShowCheckedModeBanner: false,
      routes: {
        '/home' : (BuildContext context) => const BottomBar(),
        '/login' : (BuildContext context) => const LoginPage(),
        '/addnotice' : (BuildContext context) => const AddNoticePage(),
        '/addstory' : (BuildContext context) => const AddStoryPage(),
        '/sentence' : (BuildContext context) => const SentencePage(),
      },
      theme: _onbodyTheme,
    );
  }
}
