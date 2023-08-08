import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'app.dart';
import 'firebase_options.dart';
import 'helper/dependencies.dart' as dep;
import 'package:provider/provider.dart';
import 'package:kakao_flutter_sdk_common/kakao_flutter_sdk_common.dart';


import 'model/utils.dart';

Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  print('Handling a background message ${message.messageId}');
}


Future<void> main() async{

  WidgetsFlutterBinding.ensureInitialized();

  KakaoSdk.init(
    nativeAppKey: '5bf2605b815ccdf83bfe6e59a0c43d85',
    javaScriptAppKey: '1df23e709fe1c0e1acffdc3a13156ae2',
  );

  WidgetsFlutterBinding.ensureInitialized();
  await dep.init();
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  await FirebaseMessaging.instance.getInitialMessage();
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

  runApp(
    ChangeNotifierProvider(
      create: (context) => EventProvider(),
      child: OnyouApp(),
    )
  );

}