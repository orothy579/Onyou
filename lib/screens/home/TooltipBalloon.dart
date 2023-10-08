import 'package:flutter/material.dart';



class TooltipBalloon extends StatelessWidget {
  final String text;

  TooltipBalloon({required this.text});

  @override
  Widget build(BuildContext context) {
    // TextPainter to measure the text size
    final textPainter = TextPainter(
      text: TextSpan(
        text: text,
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.bold,
          fontFamily: 'Pretendard',
          color: Color(0xff52525C),
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout(minWidth: 0, maxWidth: double.infinity);

    final textPadding = EdgeInsets.fromLTRB(16.0, 10.0, 16.0, 16.0);
    final balloonPadding = EdgeInsets.only(left: 40, right: 40, top: 100, bottom: 20);

    return Padding(
      padding: balloonPadding,
      child: CustomPaint(
        painter: TooltipPainter(textSize: textPainter.size),
        child: Container(
          alignment: Alignment.center,
          padding: textPadding,
          child: Text(
            text,
            textAlign: TextAlign.center,
            style: textPainter.text!.style,
          ),
        ),
      ),
    );
  }
}

class TooltipPainter extends CustomPainter {
  final Size textSize;

  TooltipPainter({required this.textSize});

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Rect.fromPoints(Offset(0, 10), Offset(size.width, size.height));
    final rrect = RRect.fromRectAndRadius(rect, Radius.circular(12.0));

    final paint = Paint()
      ..color = Colors.white.withOpacity(0.9)
      ..style = PaintingStyle.fill;

    final outlinePaint = Paint()
      ..color = Colors.black
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.5;

    final shadowPaint = Paint()
      ..color = Color(0xffFE9393);

    // Paint the shadow
    canvas.drawRRect(rrect.shift(Offset(2, 2)), shadowPaint);
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

