import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:onebody/controllers/cart_controller.dart';
import 'package:onebody/controllers/popular_product_controller.dart';
import 'package:onebody/routes/route_helper.dart';
import 'package:onebody/widgets/app_column.dart';
import 'package:onebody/widgets/expandable_text_widget.dart';
import '../../../style/app_styles.dart';
import '../../../utils/app_constant.dart';
import '../../../utils/bigText.dart';
import '../../../utils/dimension.dart';
import '../../../widgets/app_icon.dart';


class PopularProductDetail extends StatelessWidget {
  int pageId;
  PopularProductDetail({Key? key, required this.pageId}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    var product = Get.find<PopularProductController>().popularProductList[pageId];
    Get.find<PopularProductController>().initProduct(Get.find<CartController>());

    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          //background image
          Positioned(
              left: 0,
              right: 0,
              child: Container(
                width: double.maxFinite,
                height: Dimensions.popularProdImgSize,
                decoration:
                BoxDecoration(
                  image: DecorationImage(
                    fit: BoxFit.cover,
                    image: NetworkImage(
                        AppConstants.BASE_URL+AppConstants.UPLOAD_URL+product.img
                    ),
                  )
                ),

          )),
          //icon widget
          Positioned(
              top: Dimensions.height45,
              left: Dimensions.width20,
              right: Dimensions.width20,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  GestureDetector(
                      onTap:(){
                        Get.toNamed(RouteHelper.getInitial());
                      },
                      child: AppIcon(icon: Icons.arrow_back_ios)),
                  AppIcon(icon: Icons.shopping_cart_outlined),
                ],
              )
          ),
          //introduction of food
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            top: Dimensions.popularProdImgSize-20,
            child: Container(
              padding: EdgeInsets.only(left: Dimensions.width20, right: Dimensions.width20 , top: Dimensions.height20),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.only(
                    topRight: Radius.circular(Dimensions.radius20),
                    topLeft: Radius.circular(Dimensions.radius20)
                ),
                color: Colors.white
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  AppColumn(text: product.name.toString(),),
                  SizedBox(height: Dimensions.height20,),
                  BigText(text: "Introduce"),
                  SizedBox(height: Dimensions.height20,),
                  //expandable text widget
                  Expanded(child: SingleChildScrollView(child: ExpandableTextWdiget(text: product.description)))
                ],
              ),

          ),
          ),
        ],
      ),
      //bottomNavigationBar
      bottomNavigationBar: GetBuilder<PopularProductController>(builder: (popularProduct){
        return Container(
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
                child: Row(
                  children: [
                    GestureDetector(
                        onTap: (){
                          popularProduct.setQuantity(false);
                        },
                        child: Icon(Icons.remove,
                          color:  Colors.black26,)
                    ),
                    SizedBox(width: Dimensions.width10/5,),
                    BigText(text: popularProduct.quantity.toString()),
                    SizedBox(width: Dimensions.width10/5,),
                    GestureDetector(
                        onTap: (){
                          popularProduct.setQuantity(true);
                        },
                        child: Icon(Icons.add,
                          color:  Colors.black26,)
                    )
                  ],
                ),
              ),
              Container(
                  padding: EdgeInsets.only(top: Dimensions.height20 , bottom: Dimensions.height20, left: Dimensions.width20, right: Dimensions.width20),
                  child: GestureDetector(
                      onTap: (){
                        popularProduct.addItem(product);
                      },
                      child: BigText(text: "${product.price * popularProduct.quantity} | Add to Cart" , color: Colors.white,)),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(Dimensions.radius20),
                    color: mainGreen,
                  )
              )
            ],
          ),
        );

      })

    );
  }
}
