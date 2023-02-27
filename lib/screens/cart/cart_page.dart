import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:onebody/controllers/cart_controller.dart';
import 'package:onebody/controllers/recommended_product_controller.dart';
import 'package:onebody/routes/route_helper.dart';
import 'package:onebody/style/app_styles.dart';
import 'package:onebody/utils/app_constant.dart';

import '../../controllers/popular_product_controller.dart';
import '../../utils/bigText.dart';
import '../../utils/dimension.dart';
import '../../utils/smallText.dart';
import '../../widgets/app_icon.dart';
import 'package:get/get.dart';

import '../bottom_bar.dart';

class CartPage extends StatelessWidget {
  const CartPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Stack (
        children: [
          Positioned(
              top: Dimensions.height20*3,
              left: Dimensions.width20,
              right: Dimensions.width20,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  GestureDetector(
                    onTap:(){
                      Navigator.pop(context);

                    },
                    child: AppIcon(
                      icon: Icons.arrow_back_ios,
                      iconColor: Colors.white,
                      backgroundColor: mainGreen,
                      iconSize: Dimensions.iconSize16,
                    ),
                  ),
                  SizedBox(width: Dimensions.width20*10),
                  GestureDetector(
                    onTap: (){
                      Get.to(() => BottomBar(id: 2,));
                    },
                    child: AppIcon(
                      icon: Icons.home_outlined,
                      iconColor: Colors.white,
                      backgroundColor: mainGreen,
                      iconSize: Dimensions.iconSize16,
                    ),
                  ) ,
                  AppIcon(
                    icon: Icons.shopping_cart,
                    iconColor: Colors.white,
                    backgroundColor: mainGreen,
                    iconSize: Dimensions.iconSize16,
                  )
                ],
          )),
          Positioned(
              top: Dimensions.height20*5,
              left: Dimensions.width20,
              right: Dimensions.width20,
              bottom: 0,
              child: Container(
                margin: EdgeInsets.only(top: Dimensions.height15),
                child: MediaQuery.removePadding(
                  context: context,
                  removeTop: true,
                  child: GetBuilder<CartController>(builder: (cartController){
                    var _cartList = cartController.getItems;
                    return ListView.builder(
                        itemCount: _cartList.length,
                        itemBuilder: (_,index){
                          return Container(
                            height:Dimensions.height20*5,
                            width: double.maxFinite,
                            child: Row(
                              children: [
                                GestureDetector(
                                  onTap: (){
                                    var popularIndex = Get.find<PopularProductController>()
                                        .popularProductList
                                        .indexOf(_cartList[index].product!);
                                    if(popularIndex >= 0 ){
                                      Get.toNamed(RouteHelper.getPopularProducts(popularIndex , "cartPage"));
                                    }else{
                                      var recommendedIndex = Get.find<RecommendedProductController>()
                                          .recommendedProductList
                                          .indexOf(_cartList[index].product!);
                                      Get.toNamed(RouteHelper.getRecommendedProducts(recommendedIndex, "cartPage"));
                                    }
                                  },
                                  child: Container(
                                    width: Dimensions.height20*5,
                                    height: Dimensions.height20*5,
                                    margin: EdgeInsets.only(bottom: Dimensions.height10),
                                    decoration: BoxDecoration(
                                        image: DecorationImage(
                                            fit: BoxFit.cover,
                                            image: NetworkImage(
                                              AppConstants.BASE_URL+AppConstants.UPLOAD_URL+ cartController.getItems[index].img!

                                            )
                                        ),
                                        borderRadius: BorderRadius.circular(Dimensions.radius20),
                                        color: Colors.white
                                    ),

                                  ),
                                ),
                                SizedBox(width: Dimensions.width10,),
                                Expanded(
                                    child:
                                    Container(
                                      height: Dimensions.height20*5,
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                        children: [
                                          BigText(text: cartController.getItems[index].name! , color: Colors.black54,),
                                          SmallText(text : "spicy"),
                                          Row(
                                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                            children: [
                                              BigText(text: cartController.getItems[index].price.toString() , color: Colors.redAccent,),


                                              GetBuilder<PopularProductController>(builder: (popularProduct) {
                                                return Container(
                                                  padding: EdgeInsets.only(
                                                      top: Dimensions.height10,
                                                      bottom: Dimensions
                                                          .height10,
                                                      left: Dimensions.width10,
                                                      right: Dimensions
                                                          .width10),
                                                  decoration: BoxDecoration(
                                                      borderRadius: BorderRadius
                                                          .circular(
                                                          Dimensions.radius20),
                                                      color: Colors.white),
                                                  child: Row(
                                                    children: [
                                                      GestureDetector(
                                                          onTap: () {
                                                            cartController.addItem(_cartList[index].product!, -1);
                                                          },
                                                          child: Icon(
                                                            Icons.remove,
                                                            color: Colors
                                                                .black26,
                                                          )),
                                                      SizedBox(
                                                        width: Dimensions
                                                            .width10 / 2,
                                                      ),
                                                      BigText(text: _cartList[index].quantity.toString()),
                                                      SizedBox(
                                                        width: Dimensions
                                                            .width10 / 2,
                                                      ),
                                                      GestureDetector(
                                                          onTap: () {
                                                            cartController.addItem(_cartList[index].product!, 1);
                                                            print("Being Tapped");
                                                          },
                                                          child: Icon(
                                                            Icons.add,
                                                            color: Colors
                                                                .black26,
                                                          ))
                                                    ],
                                                  ),
                                                );
                                              })
                                            ],
                                          )
                                        ],
                                      ),

                                    ))
                              ],
                            ),
                          );
                        });
                  }),
                ),

          ))
        ],
      ),
        bottomNavigationBar:
        GetBuilder<PopularProductController>(builder: (controller){
          return Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: EdgeInsets.only(
                  left: Dimensions.width20*2.5,
                  right: Dimensions.width20*2.5,
                  top: Dimensions.height10,
                  bottom: Dimensions.height10,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    GestureDetector(
                      onTap: (){
                        controller.setQuantity(false);
                      },

                    ),
                    BigText(text: "${product.price!}  X  ${controller.inCartItems}", size: Dimensions.font26,),



                  ],
                ),
              ),
              Container(
                height: Dimensions.bottomHeightBar,
                padding: EdgeInsets.only(top: Dimensions.height30, bottom: Dimensions.height30, left: Dimensions.width20),
                decoration: BoxDecoration(
                    color: Colors.grey.shade200,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(Dimensions.radius20*2),
                      topRight: Radius.circular(Dimensions.radius20*2),
                    )
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    Container(
                      padding: EdgeInsets.only(top: Dimensions.height20 , bottom: Dimensions.height20, left: Dimensions.width20, right: Dimensions.width20),
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(Dimensions.radius20),
                          color: Colors.white
                      ),
                      child: Icon(
                        Icons.favorite,
                        color: Colors.redAccent,
                      ),
                    ),
                    GestureDetector(
                      onTap: (){
                        controller.addItem(product);
                      },
                      child: Container(
                          padding: EdgeInsets.only(top: Dimensions.height20 , bottom: Dimensions.height20, left: Dimensions.width20, right: Dimensions.width20),
                          child: BigText(text: "${product.price!} | Add to Cart" , color: Colors.white,),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(Dimensions.radius20),
                            color: mainGreen,
                          )
                      ),
                    )
                  ],
                ),
              ),
            ],
          );
        }
        )
    );
  }
}
