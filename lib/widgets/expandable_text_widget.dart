import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:onebody/style/app_styles.dart';
import 'package:onebody/utils/smallText.dart';

import '../utils/dimension.dart';

class ExpandableTextWdiget extends StatefulWidget {
  final String text;
  const ExpandableTextWdiget({Key? key, required this.text}) : super(key: key);

  @override
  State<ExpandableTextWdiget> createState() => _ExpandableTextWdigetState();
}

class _ExpandableTextWdigetState extends State<ExpandableTextWdiget> {
  late String firstHalf;
  late String secondHalf;

  bool hiddenText = true;

  double textHeight = Dimensions.screenHeight/5.63;

  @override
  void initState(){
    super.initState();
    if(widget.text.length > textHeight){
      firstHalf = widget.text.substring(0,textHeight.toInt());
      secondHalf = widget.text.substring(textHeight.toInt()+1, widget.text.length);
    } else{
      firstHalf = widget.text;
      secondHalf = "";
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: secondHalf.isEmpty?SmallText(size:Dimensions.font16,text: firstHalf):Column(
        children: [
          SmallText(height:1.8, color:Colors.black54,size:Dimensions.font16, text: hiddenText?(firstHalf+". . ."):(firstHalf+secondHalf)),
          InkWell(
            onTap:(){
              setState(() {
                hiddenText = !hiddenText;
              });
            },
            child: Row(
              children: [
                SmallText(text: "Show more" , color: mainGreen,),
                Icon(hiddenText?Icons.arrow_drop_down:Icons.arrow_drop_up, color: mainGreen,)
              ],
            ),
          )
        ],
      ),
    );
  }
}
