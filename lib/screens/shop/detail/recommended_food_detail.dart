import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:onebody/style/app_styles.dart';
import 'package:onebody/widgets/app_icon.dart';
import 'package:onebody/widgets/expandable_text_widget.dart';
import '../../../utils/bigText.dart';
import '../../../utils/dimension.dart';


class RecommendedFoodDetail extends StatelessWidget {
  const RecommendedFoodDetail({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            toolbarHeight: 70,
            title: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                AppIcon(icon: Icons.clear),
                AppIcon(icon: Icons.shopping_cart_outlined)
              ],
            ),
            bottom: PreferredSize(
              preferredSize: Size.fromHeight(20),
              child: Container(
                child: Center(child: BigText(size:Dimensions.font26, text:"리하 레터")),
                width: double.maxFinite,
                padding: EdgeInsets.only(top: 5,bottom: 10),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(Dimensions.radius20),
                    topRight: Radius.circular(Dimensions.radius20)
                  )
                ),
              )
            ),
            pinned: true,
            backgroundColor: mainGreen,
            expandedHeight: 300,
            flexibleSpace: FlexibleSpaceBar(
              background: Image.network(
                  "https://mblogthumb-phinf.pstatic.net/MjAyMzAyMTVfMTUz/MDAxNjc2NDQzMzYyNDY1.iOzvVIBj9ATNLZANkokK3mkx46N_szRFhqZW241kGOgg.diFK84OXUkGPm5xsLIYe2pcYqktj9pMnMkHnPsdKxXsg.JPEG.navicey/3C95DFBC-F9EA-4FB5-B8C9-CCAA7EC7B0D9.jpg?type=w800",
                width: double.maxFinite,
                fit: BoxFit.cover,
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Column(
              children: [
                Container(
                  child: ExpandableTextWdiget( text:
                      "예수님께서는 38년 된 병자에게 물어보셨습니다. “네가 낫고자 하느냐”  "
                          "38년 동안 외로이 연못 옆에 누워  물이 움직일 때 까지(천사가 내려와"
                          " 물을 움직이게 할 때 들어가면 낫기 때문 - 요5:4)기다리며 살았던"
                          " 그 병자는  어떤 마음으로 하루 하루를, 38년을 살았을까요.  그 세"
                          "월동안 병이 익숙해지고, 병이 나을꺼라는 기대와그에 따른 절망의 반복 속."
                          " 이제는 병이 나을꺼라는 믿음보단병이 낫지 못할꺼라는 믿음이 더 강해져 기대"
                          "도 소망도 갖지 못하는그런 마음이었을까요. 예수께서는 우리에게도 물어보십니다."
                          " 한나야, 너가 정말 낫기를 원하니? 치유의 하나님인 나를 신뢰하니? 반드시 반드"
                          ""
                          "시, 너를 이전보다 건강케 할거라는 약속이 여전히 너를 주장하니? 무어라 대답할까"
                          "요. 믿음의 대답을 주께 드리기 원합니다. "
                          "예수님께서는 38년 된 병자에게 물어보셨습니다. “네가 낫고자 하느냐”  "
                          "38년 동안 외로이 연못 옆에 누워  물이 움직일 때 까지(천사가 내려와"
                          " 물을 움직이게 할 때 들어가면 낫기 때문 - 요5:4)기다리며 살았던"
                          " 그 병자는  어떤 마음으로 하루 하루를, 38년을 살았을까요.  그 세"
                          "월동안 병이 익숙해지고, 병이 나을꺼라는 기대와그에 따른 절망의 반복 속."
                          " 이제는 병이 나을꺼라는 믿음보단병이 낫지 못할꺼라는 믿음이 더 강해져 기대"
                          "도 소망도 갖지 못하는그런 마음이었을까요. 예수께서는 우리에게도 물어보십니다."
                          " 한나야, 너가 정말 낫기를 원하니? 치유의 하나님인 나를 신뢰하니? 반드시 반드"
                          ""
                          "시, 너를 이전보다 건강케 할거라는 약속이 여전히 너를 주장하니? 무어라 대답할까"
                          "요. 믿음의 대답을 주께 드리기 원합니다. "
                          "예수님께서는 38년 된 병자에게 물어보셨습니다. “네가 낫고자 하느냐”  "
                          "38년 동안 외로이 연못 옆에 누워  물이 움직일 때 까지(천사가 내려와"
                          " 물을 움직이게 할 때 들어가면 낫기 때문 - 요5:4)기다리며 살았던"
                          " 그 병자는  어떤 마음으로 하루 하루를, 38년을 살았을까요.  그 세"
                          "월동안 병이 익숙해지고, 병이 나을꺼라는 기대와그에 따른 절망의 반복 속."
                          " 이제는 병이 나을꺼라는 믿음보단병이 낫지 못할꺼라는 믿음이 더 강해져 기대"
                          "도 소망도 갖지 못하는그런 마음이었을까요. 예수께서는 우리에게도 물어보십니다."
                          " 한나야, 너가 정말 낫기를 원하니? 치유의 하나님인 나를 신뢰하니? 반드시 반드"
                          ""
                          "시, 너를 이전보다 건강케 할거라는 약속이 여전히 너를 주장하니? 무어라 대답할까"
                          "요. 믿음의 대답을 주께 드리기 원합니다. "
                          "예수님께서는 38년 된 병자에게 물어보셨습니다. “네가 낫고자 하느냐”  "
                          "38년 동안 외로이 연못 옆에 누워  물이 움직일 때 까지(천사가 내려와"
                          " 물을 움직이게 할 때 들어가면 낫기 때문 - 요5:4)기다리며 살았던"
                          " 그 병자는  어떤 마음으로 하루 하루를, 38년을 살았을까요.  그 세"
                          "월동안 병이 익숙해지고, 병이 나을꺼라는 기대와그에 따른 절망의 반복 속."
                          " 이제는 병이 나을꺼라는 믿음보단병이 낫지 못할꺼라는 믿음이 더 강해져 기대"
                          "도 소망도 갖지 못하는그런 마음이었을까요. 예수께서는 우리에게도 물어보십니다."
                          " 한나야, 너가 정말 낫기를 원하니? 치유의 하나님인 나를 신뢰하니? 반드시 반드"
                          ""
                          "시, 너를 이전보다 건강케 할거라는 약속이 여전히 너를 주장하니? 무어라 대답할까"
                          "요. 믿음의 대답을 주께 드리기 원합니다. ",
                  ),
                  margin: EdgeInsets.only(left: Dimensions.width20 , right: Dimensions.width20),
                ),
              ],
            ),
          )
        ],
      ),
      bottomNavigationBar: Column(
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
                AppIcon(
                    iconSize: Dimensions.iconSize24,
                    iconColor: Colors.white,
                    backgroundColor: mainGreen,
                    icon: Icons.remove),
                BigText(text:"2000원"+" X " +"0", size: Dimensions.font26,),
                AppIcon(
                    iconSize: Dimensions.iconSize24,
                    iconColor: Colors.white,
                    backgroundColor: mainGreen,
                    icon: Icons.add
                )

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
                    color: mainGreen,
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
        ],
      ),
    );
  }
}
