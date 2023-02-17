import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:onebody/screens/productPage.dart';
import 'package:onebody/style/app_styles.dart';
import 'package:onebody/style/smallText.dart';

class ShopPage extends StatefulWidget {
  const ShopPage({Key? key}) : super(key: key);

  @override
  State<ShopPage> createState() => _ShopPageState();
}

class _ShopPageState extends State<ShopPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Container(
            margin: EdgeInsets.only(top: 45, bottom: 15),
            padding: EdgeInsets.only(left: 20, right: 20),
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
                          width: 45,
                          height: 45,
                          child: Icon(Icons.search , color: Colors.white,),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(15),
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
          ProductPage()
        ],
      )
    );

  }
}
