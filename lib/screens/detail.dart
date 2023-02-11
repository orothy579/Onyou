import 'package:flutter/cupertino.dart';
import 'package:onebody/model/Story.dart';

class DetailPage extends StatefulWidget {
  const DetailPage({Key? key, required Story storys}) : super(key: key);

  @override
  State<DetailPage> createState() => _DetailPageState();
}

class _DetailPageState extends State<DetailPage> {
  @override
  Widget build(BuildContext context) {
    return Container(
      child: Text("hi"),
    );
  }
}
