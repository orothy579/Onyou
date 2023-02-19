import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:onebody/style/app_styles.dart';
import 'package:onebody/style/bigText.dart';
import 'package:onebody/style/icon_and_text_widget.dart';

import '../style/smallText.dart';

class ProductPage extends StatefulWidget {
  const ProductPage({Key? key}) : super(key: key);

  @override
  State<ProductPage> createState() => _ProductPageState();
}

class _ProductPageState extends State<ProductPage> {
  PageController pageController = PageController(viewportFraction: 0.9);
  var _currPageValue = 0.0;

  @override
  void initState(){
    super.initState();
    pageController.addListener(() {
      _currPageValue= pageController.page!;
      setState(() {
        _currPageValue = pageController.page!;
      });
    });
  }

  @override
  void dispose(){
    pageController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 320,
      child: PageView.builder(
        controller: pageController,
          itemCount: 5,
          itemBuilder: (context,position){
        return _buildPageItem(position);
      }),
    );
  }
  Widget _buildPageItem(int index){


    return Stack(
      children:
      [
        Container(
          height: 220,
          margin: EdgeInsets.only(left: 10, right: 10),
          decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(30),
              color: index.isEven?Color(0xFF69c5df):Color(0xFF9294cc),
              image: DecorationImage(
                  fit: BoxFit.cover,
                  image: NetworkImage(
                      "https://i.pinimg.com/564x/1a/fa/2c/1afa2cf5e0a145e4ceae527a14e99754.jpg"
                  ),
              ),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.7),
                blurRadius: 5.0,
                spreadRadius: 0.0,
                offset: Offset(0,7)
              )
            ]
          ),
        ),

        Align(
          alignment: Alignment.bottomCenter,
          child:
          Container(
            height: 130,
            margin: EdgeInsets.only(left: 40, right: 40, bottom: 30),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(30),
              color: Colors.white,
                boxShadow: [
                  BoxShadow(
                      color: Colors.grey.withOpacity(0.7),
                      blurRadius: 5.0,
                      spreadRadius: 0.0,
                      offset: Offset(0,7)
                  )
                ]
            ),
            child: Container(
              padding: EdgeInsets.only(top: 15, left: 15, right: 15),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  BigText(text: "말씀 카드" , color: Colors.black54,),
                  SizedBox(height: 10,),
                  Row(
                    children: [
                      Wrap(
                        children: List.generate(5, (index) {return Icon(Icons.star, color: mainGreen, size: 15,);}),
                      ),
                      SizedBox(width: 10,),
                      SmallText(text:"4.5"),
                      SizedBox(width: 10,),
                      SmallText(text: "1287"),
                      SizedBox(width: 10,),
                      SmallText(text: "comments",)
                    ],
                  ),
                  SizedBox(height: 20,),
                  Row(
                    children: [
                      IconAndTextWidget(
                          icon: Icons.circle_sharp,
                          text: "Normal",
                          iconColor: camel
                      ),
                      IconAndTextWidget(
                          icon: Icons.location_on,
                          text: "1.7",
                          iconColor: camel
                      ),
                      IconAndTextWidget(
                          icon: Icons.access_time_sharp,
                          text: "32min",
                          iconColor: camel
                      ),

                    ],
                  )


                ],
              ),

            ),
      ),
        ),
    ]
    );
  }
}
