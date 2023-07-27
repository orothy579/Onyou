import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:onebody/screens/shop/productPage.dart';
import 'package:onebody/style/app_styles.dart';
import 'package:onebody/utils/smallText.dart';

import '../../utils/dimension.dart';

class ShopPage extends StatefulWidget {
  const ShopPage({Key? key}) : super(key: key);

  @override
  State<ShopPage> createState() => _ShopPageState();
}

class _ShopPageState extends State<ShopPage> {
  @override
  Widget build(BuildContext context) {
    print("current height is " + MediaQuery.of(context).size.height.toString());
    return

      Scaffold(
      body:
      // Center(
      //   child: Text(
      //     '곧 업데이트 될 예정입니다. ☺️',
      //     style: TextStyle(fontSize: 24),
      //   ),
      // ),

      Column(
        children: [
          Container(
            margin: EdgeInsets.only(top: Dimensions.height45, bottom: Dimensions.height15),
            padding: EdgeInsets.only(left: Dimensions.width20, right: Dimensions.width20),
            child: Column(
              children: [
                Container(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        children: [
                          Text("Shopping" , style: headLineGreenStyle,),
                          Row(
                            children: [
                              SmallText(text: "리하레터" , color: Colors.black54,),
                              Icon(Icons.arrow_drop_down)
                            ],
                          )

                        ],
                      ),
                      Center(
                        child: Container(
                          width: Dimensions.height45,
                          height: Dimensions.height45,
                          child: Icon(Icons.search , color: Colors.white, size: Dimensions.iconSize24,),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(Dimensions.radius15),
                            color: mainGreen,
                          ),

                        ),
                      )
                    ],
                  ),
                ),
              ],
            ),
          ),
          Expanded(child: SingleChildScrollView(child: ProductPage()))
        ],
      )
    );

  }
}
