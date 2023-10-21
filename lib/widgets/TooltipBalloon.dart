import 'package:flutter/material.dart';

class TooltipBalloon extends StatelessWidget {
  final String text;

  TooltipBalloon({required this.text});

  @override
  Widget build(BuildContext context) {
    final textPadding = EdgeInsets.all(10.0);
    final balloonPadding = EdgeInsets.only(left: 110, right: 10, top: 114, bottom: 20);

    return Padding(
      padding: balloonPadding,
      child: IntrinsicHeight(
        child: CustomPaint(
           painter: TooltipPainter(),
          child: Container(

            padding: textPadding,
            child: Center(
              child: Text(
                text,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Pretendard',
                  color: Color(0xff52525C),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}


class TooltipPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final rect = Rect.fromPoints(Offset(0, 0), Offset(size.width, size.height));
    final rrect = RRect.fromRectAndRadius(rect, Radius.circular(12.0));

    final paint = Paint()
      ..color = Colors.white.withOpacity(1)
      ..style = PaintingStyle.fill;

    final outlinePaint = Paint()
      ..color = Colors.black
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;

    final shadowPaint = Paint()
      ..color = Color(0xffFE9393);

    // Paint the shadow
    canvas.drawRRect(rrect.shift(Offset(5, 0)), shadowPaint);
    // Paint the main box
    canvas.drawRRect(rrect, paint);
    // Paint the outline
    canvas.drawRRect(rrect, outlinePaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return false;
  }
}
