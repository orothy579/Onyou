import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:onebody/controllers/cart_controller.dart';
import 'package:onebody/style/app_styles.dart';
import 'package:onebody/utils/app_constant.dart';
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
        body:
          Stack(
            children: [
              Positioned(
                  top: Dimensions.height20 * 3,
                  left: Dimensions.width20,
                  right: Dimensions.width20,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      GestureDetector(
                        onTap: () {
                          Navigator.pop(context);
                        },
                        child: AppIcon(
                          icon: Icons.arrow_back_ios,
                          iconColor: Colors.white,
                          backgroundColor: mainGreen,
                          iconSize: Dimensions.iconSize16,
                        ),
                      ),
                      SizedBox(width: Dimensions.width20 * 10),
                      GestureDetector(
                        onTap: () {
                          Get.to(() => BottomBar(id: 2,));
                        },
                        child: AppIcon(
                          icon: Icons.home_outlined,
                          iconColor: Colors.white,
                          backgroundColor: mainGreen,
                          iconSize: Dimensions.iconSize16,
                        ),
                      ),
                      AppIcon(
                        icon: Icons.shopping_cart,
                        iconColor: Colors.white,
                        backgroundColor: mainGreen,
                        iconSize: Dimensions.iconSize16,
                      )
                    ],
                  )),
              Positioned(
                top:  Dimensions.height20*5,
                left: Dimensions.width20,
                right: Dimensions.width20,
                bottom: 0,
                child: Container(
                  margin: EdgeInsets.only(top: Dimensions.height15),
                  child: MediaQuery.removePadding(
                    context: context,
                    removeTop: true,
                    child: GetBuilder<CartController>(builder: (cartController){
                      return ListView.builder(
                          itemCount: cartController.getItems.length,
                          itemBuilder: (_,index){
                            return Container(
                              width: double.maxFinite,
                              height: 100,
                              child: Row(
                                children: [
                                  Container(
                                    width: Dimensions.height20*5,
                                    height: Dimensions.height20*5,
                                    margin: EdgeInsets.only(bottom: Dimensions.height10),
                                    decoration: BoxDecoration(
                                        image: DecorationImage(
                                            fit: BoxFit.cover,
                                            image: NetworkImage(
                                              AppConstants.BASE_URL+AppConstants.UPLOAD_URL+cartController.getItems[index].img!
                                            )
                                        ),
                                        borderRadius: BorderRadius.circular(Dimensions.radius20),
                                        color: Colors.white
                                    ),
                                  ),
                                  SizedBox(width: Dimensions.width10,),
                                  Expanded(child: Container(
                                    height: Dimensions.height20*5,
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                      children: [
                                        BigText(text: cartController.getItems[index].name! , color: Colors.black54,),
                                        SmallText(text: "Spicy"),
                                        Row(
                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                          children: [
                                            BigText(text: cartController.getItems[index].price.toString(), color: Colors.redAccent,),
                                            Container(
                                              padding: EdgeInsets.only(
                                                  top: Dimensions.height10,
                                                  bottom: Dimensions.height10,
                                                  left: Dimensions.width10,
                                                  right: Dimensions.width10),
                                              decoration: BoxDecoration(
                                                  borderRadius: BorderRadius.circular(Dimensions.radius20),
                                                  color: Colors.white),
                                              child: Row(
                                                children: [
                                                  GestureDetector(
                                                      onTap: () {
                                                        //popularProduct.setQuantity(false);
                                                      },
                                                      child: Icon(
                                                        Icons.remove,
                                                        color: Colors.black26,
                                                      )),
                                                  SizedBox(
                                                    width: Dimensions.width10 / 2,
                                                  ),
                                                  BigText(text: "0"),//popularProduct.inCartItems.toString()),
                                                  SizedBox(
                                                    width: Dimensions.width10 / 2,
                                                  ),
                                                  GestureDetector(
                                                      onTap: () {
                                                        //popularProduct.setQuantity(true);
                                                      },
                                                      child: Icon(
                                                        Icons.add,
                                                        color: Colors.black26,
                                                      ))
                                                ],
                                              ),
                                            ),
                                          ],
                                        )
                                      ],
                                    ),
                                  ))
                                ],
                              ),
                            );
                          });
                    },),
                  ),

              ),)

            ],
          ),
    );
  }
}
