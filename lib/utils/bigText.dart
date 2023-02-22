import 'package:flutter/cupertino.dart';

import 'dimension.dart';

class BigText extends StatelessWidget {
  Color? color;
  final String text;
  double size;
  TextOverflow overFlow;

  BigText({Key? key, this.color = const Color(0xFF000000),
    required this.text,
    this.size =0,
    this.overFlow = TextOverflow.ellipsis
  }) : super(key: key);



  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: TextStyle(
        color: color,
        fontSize: size ==0?Dimensions.font20:size,
      ),
    );
  }
}
