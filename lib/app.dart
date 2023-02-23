import 'package:flutter/material.dart';
import 'package:onebody/controllers/popular_product_controller.dart';
import 'package:onebody/screens/addPages/addnotice.dart';
import 'package:onebody/screens/addPages/addstory.dart';
import 'package:onebody/screens/bottom_bar.dart';
import 'package:onebody/screens/sentence.dart';
import 'package:onebody/screens/shop/detail/popular_product_detail.dart';
import 'package:onebody/screens/shop/detail/recommended_food_detail.dart';
import 'controllers/recommended_product_controller.dart';
import 'screens/login.dart';
import 'style/app_styles.dart';
import 'package:get/get.dart';

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
    Get.find<PopularProductController>().getPopularProductList();
    Get.find<RecommendedProductController>().getRecommendedProductList();

    return GetMaterialApp(
      title: 'Onebody Community',
      initialRoute: '/login',
      debugShowCheckedModeBanner: false,
      routes: {
        '/home' : (BuildContext context) => const BottomBar(),
        '/login' : (BuildContext context) => const LoginPage(),
        '/addnotice' : (BuildContext context) => const AddNoticePage(),
        '/addstory' : (BuildContext context) => const AddStoryPage(),
        '/sentence' : (BuildContext context) => const SentencePage(),
        '/popular_detail' : (BuildContext context) => const PopularProductDetail(),
        '/recommended_detail' :(BuildContext context) => const RecommendedFoodDetail()
      },
      theme: _onbodyTheme,
    );
  }
}
