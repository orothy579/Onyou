import 'package:flutter/material.dart';
import 'package:onebody/controllers/popular_product_controller.dart';
import 'package:onebody/routes/route_helper.dart';
import 'package:onebody/screens/addPages/addnotice.dart';
import 'package:onebody/screens/addPages/addstory.dart';
import 'package:onebody/screens/bottom_bar.dart';
import 'package:onebody/screens/cart/cart_page.dart';
import 'package:onebody/screens/home/home.dart';
import 'package:onebody/screens/home/sentence.dart';
import 'package:onebody/screens/profile.dart';
import 'package:onebody/screens/register.dart';
import 'package:onebody/screens/shop/shop.dart';
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
      home: HomePage(),
      debugShowCheckedModeBanner: false,
      getPages: RouteHelper.routes,
      routes: {
        '/home' : (BuildContext context) => BottomBar(id : 0),
        '/login' : (BuildContext context) => LoginPage(),
        '/addnotice' : (BuildContext context) => const AddNoticePage(),
        '/addstory' : (BuildContext context) => const AddStoryPage(),
        '/sentence' : (BuildContext context) => const SentencePage(),
        '/shop' : (BuildContext context) => const ShopPage(),
        '/hommie': (BuildContext context) => const HomePage(),
        '/cart' : (BuildContext context) => const CartPage(),
        '/register' : (BuildContext context) => RegisterPage(),
        '/profileRegister' : (BuildContext context) => ProfilePage(),
      },
      theme: _onbodyTheme,
    );
  }
}
