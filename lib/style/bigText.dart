import 'package:flutter/cupertino.dart';

class BigText extends StatelessWidget {
  Color? color;
  final String text;
  double size;
  double height;

  BigText({Key? key, this.color = const Color(0x0fffffff),
    required this.text,
    this.size =20,
    this.height = 1.2
  }) : super(key: key);



  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: TextStyle(
        color: color,
        fontSize: size,
        height: height
      ),
    );
  }
}
