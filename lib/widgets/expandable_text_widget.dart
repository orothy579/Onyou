import 'package:flutter/cupertino.dart';

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
  //

  @override
  void initState(){
    super.initState();
    if(widget.text.length > textHeight){
      firstHalf = widget.text.substring(0,textHeight.toInt());
      secondHalf = widget.text.substring(textHeight.toInt()+1, widget.text.length);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container();
  }
}
