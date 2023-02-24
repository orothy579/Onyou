import 'package:get/get.dart';
import 'package:onebody/screens/home.dart';
import 'package:onebody/screens/shop/detail/popular_product_detail.dart';
import '../screens/shop/detail/recommended_food_detail.dart';

class RouteHelper{
  static const String initial="/home";
  static const String popularProduct = "/home/popular_detail";
  static const String recommendedProduct = "/home/recommended_detail";


  static String getInitial() =>'$initial';
  static String getPopularProducts(int pageId)=> '$popularProduct?pageId=$pageId';
  static String getRecommendedProducts(int pageId)=> '$recommendedProduct?pageId=$pageId';


  static List<GetPage> routes = [
    GetPage(name: initial , page: ()=>HomePage()),
    GetPage(
        name: popularProduct,
        page:(){
          var pageId = Get.parameters['pageId'];
         return PopularProductDetail(pageId: int.parse(pageId!));
        },
        transition: Transition.downToUp
    ),
    GetPage(
        name: recommendedProduct,
        page:(){
          var pageId = Get.parameters['pageId'];
          return RecommendedFoodDetail(pageId: int.parse(pageId!));
        },
        transition: Transition.downToUp
    ),
  ];

}