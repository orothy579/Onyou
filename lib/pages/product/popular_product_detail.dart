import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:onebody/widgets/app_column.dart';
import 'package:onebody/widgets/expandable_text_widget.dart';

import '../../style/app_styles.dart';
import '../../utils/bigText.dart';
import '../../utils/dimension.dart';
import '../../utils/smallText.dart';
import '../../widgets/app_icon.dart';
import '../../widgets/icon_and_text_widget.dart';

class PopularProductDetail extends StatelessWidget {
  const PopularProductDetail({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
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
                        "https://i.pinimg.com/564x/1a/fa/2c/1afa2cf5e0a145e4ceae527a14e99754.jpg"
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
                  AppIcon(icon: Icons.arrow_back_ios),
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
                  AppColumn(text: "말씀 카드",),
                  SizedBox(height: Dimensions.height20,),
                  BigText(text: "Introduce"),
                  SizedBox(height: Dimensions.height20,),
                  //expandable text widget
                  Expanded(child: SingleChildScrollView(child: ExpandableTextWdiget(text: "예수님께서는 38년 된 병자에게 물어보셨습니다. “네가 낫고자 하느냐”  38년 동안 외로이 연못 옆에 누워  물이 움직일 때 까지(천사가 내려와 물을 움직이게 할 때 들어가면 낫기 때문 - 요5:4)기다리며 살았던 그 병자는  어떤 마음으로 하루 하루를, 38년을 살았을까요.  그 세월동안 병이 익숙해지고, 병이 나을꺼라는 기대와그에 따른 절망의 반복 속. 이제는 병이 나을꺼라는 믿음보단병이 낫지 못할꺼라는 믿음이 더 강해져 기대도 소망도 갖지 못하는그런 마음이었을까요. 예수께서는 우리에게도 물어보십니다. 한나야, 너가 정말 낫기를 원하니? 치유의 하나님인 나를 신뢰하니? 반드시 반드시, 너를 이전보다 건강케 할거라는 약속이 여전히 너를 주장하니? 무어라 대답할까요. 믿음의 대답을 주께 드리기 원합니다.  ”예 주님, 제가 정말 낫기를 원합니다.“ ")))

                ],
              ),

          ),
          ),
        ],
      ),
      //bottomNavigationBar
      bottomNavigationBar: Container(
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
                  Icon(Icons.remove, color: Colors.black26,),
                  SizedBox(width: Dimensions.width10/5,),
                  BigText(text: "0"),
                  SizedBox(width: Dimensions.width10/5,),
                  Icon(Icons.add, color:  Colors.black26,)
                ],
              ),
            ),
            Container(
                padding: EdgeInsets.only(top: Dimensions.height20 , bottom: Dimensions.height20, left: Dimensions.width20, right: Dimensions.width20),
                child: BigText(text: "\$10 | Add to Cart" , color: Colors.white,),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(Dimensions.radius20),
                color: mainGreen,
              )
            )
          ],
        ),
      ),
    );
  }
}
