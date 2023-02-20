import 'package:flutter/cupertino.dart';

import 'dimension.dart';

class BigText extends StatelessWidget {
  Color? color;
  final String text;
  double size;
  double height;

  BigText({Key? key, this.color = const Color(0x0fffffff),
    required this.text,
    this.size =0,
    this.height = 1.2
  }) : super(key: key);



  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: TextStyle(
        color: color,
        fontSize: size ==0?Dimensions.font20:size,
        height: height
      ),
    );
  }
}
