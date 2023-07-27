import 'package:get/get.dart';
import 'package:onebody/screens/home/home.dart';
import 'package:onebody/screens/shop/detail/popular_product_detail.dart';
import '../screens/cart/cart_page.dart';
import '../screens/shop/detail/recommended_food_detail.dart';

class RouteHelper{
  static const String initial="/home";
  static const String popularProduct = "/home/popular_detail";
  static const String recommendedProduct = "/home/recommended_detail";
  static const String cartPage = "/cartpage";


  static String getInitial() =>'$initial';
  static String getPopularProducts(int pageId, String page)=> '$popularProduct?pageId=$pageId&page=$page';
  static String getRecommendedProducts(int pageId, String page)=> '$recommendedProduct?pageId=$pageId&page=$page';
  static String getCartPgae() =>'$cartPage';


  static List<GetPage> routes = [
    GetPage(name: initial , page: ()=>HomePage()),
    GetPage(
        name: popularProduct,
        page:(){
          var pageId = Get.parameters['pageId'];
          var page = Get.parameters['page'];
         return PopularProductDetail(pageId: int.parse(pageId!) , page:page!);
        },
        transition: Transition.downToUp
    ),
    GetPage(
        name: recommendedProduct,
        page:(){
          var pageId = Get.parameters['pageId'];
          var page = Get.parameters["page"];
          return RecommendedFoodDetail(pageId: int.parse(pageId!) , page:page!);
        },
        transition: Transition.downToUp
    ),
    GetPage(name: cartPage, page: (){
      return CartPage();
    },
      transition: Transition.fadeIn
    )
  ];

}