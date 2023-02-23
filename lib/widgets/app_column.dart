import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../style/app_styles.dart';
import '../utils/bigText.dart';
import '../utils/dimension.dart';
import '../utils/smallText.dart';
import 'icon_and_text_widget.dart';

class AppColumn extends StatelessWidget {
  final String text;
  const AppColumn({Key? key, required this.text}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        BigText(
          text: text,
          size: Dimensions.font26,
          color: Colors.black,
        ),
        SizedBox(
          height: Dimensions.height10,
        ),
        Row(
          children: [
            Wrap(
              children: List.generate(5, (index) {
                return Icon(
                  Icons.star,
                  color: mainGreen,
                  size: Dimensions.iconSize16,
                );
              }),
            ),
            SizedBox(
              width: Dimensions.width10,
            ),
            SmallText(text: "4.5"),
            SizedBox(
              width: Dimensions.width10,
            ),
            SmallText(text: "1287"),
            SizedBox(
              width: Dimensions.width10,
            ),
            SmallText(
              text: "comments",
            )
          ],
        ),
        SizedBox(
          height: Dimensions.height10,
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            IconAndTextWidget(
                icon: Icons.circle_sharp,
                text: "Normal",
                iconColor: camel),
            IconAndTextWidget(
                icon: Icons.location_on,
                text: "1.7",
                iconColor: camel),
            IconAndTextWidget(
                icon: Icons.access_time_sharp,
                text: "32min",
                iconColor: camel),
          ],
        )
      ],
    );
  }
}
