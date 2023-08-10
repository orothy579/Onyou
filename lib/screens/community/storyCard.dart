import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

import '../../model/Story.dart';
import 'commentPage.dart';

class StoryCard extends StatefulWidget {
  final Story story;

  StoryCard({required this.story});

  @override
  _StoryCardState createState() => _StoryCardState();
}

class _StoryCardState extends State<StoryCard> {
  bool _isLiked = false;

  _toggleLike() async {

    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      if (_isLiked) {
        await FirebaseFirestore.instance
            .collection('story')
            .doc(widget.story.id)
            .update({
          'likes': FieldValue.arrayRemove([user.uid]),
        });
      } else {
        await FirebaseFirestore.instance
            .collection('story')
            .doc(widget.story.id)
            .update({
          'likes': FieldValue.arrayUnion([user.uid]),
        });
      }
      setState(() {
        _isLiked = !_isLiked;
      });
    }


  }

  bool  _showFullDescription = false ;

  @override
  Widget build(BuildContext context) {
    _isLiked =
        widget.story.likes!.contains(FirebaseAuth.instance.currentUser!.uid);

    String displayDescription;
    if (widget.story.description!.length > 20) {
      displayDescription = _showFullDescription
          ? widget.story.description!
          : widget.story.description!.substring(0, 20);
    } else {
      displayDescription = widget.story.description!;
    }

    return Card(
      shadowColor: Colors.grey,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ListTile(
            leading: CircleAvatar(
              backgroundImage: NetworkImage(widget.story.u_image!),
            ),
            title: Text(widget.story.title!),
            subtitle: Text(widget.story.name!),
          ),
          Container(
            width: double.infinity,
            height: 300.0,
            child: Image.network(
              widget.story.image!,
              fit: BoxFit.cover,
            ),
          ),
          SizedBox(height: 8.0),
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              IconButton(
                icon: Icon(
                  _isLiked ? Icons.favorite : Icons.favorite_border,
                  color: _isLiked ? Colors.red : Colors.grey,
                ),
                onPressed: _toggleLike,
              ),
              Text('${widget.story.likes!.length}'),
              IconButton(
                icon: Icon(Icons.comment),
                onPressed: () {
                  showModalBottomSheet(
                    context: context,
                    isScrollControlled: true, // 스크롤을 제어하여 Bottom Sheet의 크기를 조절
                    builder: (BuildContext context) {
                      // 화면 크기를 가져옴
                      double height = MediaQuery.of(context).size.height;

                      return ConstrainedBox(
                        constraints: BoxConstraints(
                          maxHeight: height * 0.8, // 화면 높이의 70%를 최대 높이로 지정
                        ),
                        child: CommentPage(story: widget.story),
                      );
                    },
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.vertical(
                        top: Radius.circular(20), // Top 부분을 둥글게
                      ),
                    ),
                  );
                },
              )


            ],
          ),
          Padding(
            padding: const EdgeInsets.all(10.0),
            child: widget.story.description!.length > 20
                ? RichText(
              text: TextSpan(
                style: DefaultTextStyle.of(context).style,
                children: [
                  TextSpan(text: displayDescription),
                  TextSpan(
                    text: _showFullDescription ? " 접기" : " ... 더보기",
                    style: TextStyle(color: Colors.grey),
                    recognizer: TapGestureRecognizer()
                      ..onTap = () {
                        setState(() {
                          _showFullDescription = !_showFullDescription;
                        });
                      },
                  ),
                ],
              ),
            )
                : Text(widget.story.description!),
          ),
        ],
      ),
    );

  }
}
