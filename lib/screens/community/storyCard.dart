import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart'; // 추가된 import

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

  bool _showFullDescription = false;

  @override
  Widget build(BuildContext context) {
    _isLiked = widget.story.likes!.contains(FirebaseAuth.instance.currentUser!.uid);

    String displayDescription;
    if (widget.story.description!.length > 20) {
      displayDescription = _showFullDescription
          ? widget.story.description!
          : widget.story.description!.substring(0, 20);
    } else {
      displayDescription = widget.story.description!;
    }
    return Container(
      margin: EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20.0),
        border: Border.all(color: Colors.grey[200]!),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.3),
            spreadRadius: 2.0,
            blurRadius: 5.0,
            offset: Offset(0, 3),
          ),
        ],


      ),

      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.all(16.0),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 25,
                  backgroundImage: NetworkImage(widget.story.u_image!),
                ),
                SizedBox(width: 10.0),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.story.title!,
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
                    ),
                    Text(
                      widget.story.name!,
                      style: TextStyle(color: Colors.grey[600]),
                    ),
                  ],
                )
              ],
            ),
          ),
          Container(
            width: double.infinity,
            height: 300.0,
            child: CarouselSlider.builder(
              itemCount: widget.story.images!.length,
              itemBuilder: (context, index, realIdx) {
                return Image.network(
                  widget.story.images![index],
                  fit: BoxFit.cover,
                );
              },
              options: CarouselOptions(
                autoPlay: false,
                enlargeCenterPage: true,
                viewportFraction: 1.0,
                aspectRatio: 16/9,
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    IconButton(
                      icon: Icon(
                        _isLiked ? Icons.favorite : Icons.favorite_border,
                        color: _isLiked ? Colors.red : Colors.grey[600],
                      ),
                      onPressed: _toggleLike,
                    ),
                    Text('${widget.story.likes!.length}', style: TextStyle(fontWeight: FontWeight.bold)),
                  ],
                ),
                IconButton(
                  icon: Icon(Icons.comment, color: Colors.grey[600]),
                  onPressed: () {
                    showModalBottomSheet(
                      context: context,
                      isScrollControlled: true,
                      builder: (BuildContext context) {
                        double height = MediaQuery.of(context).size.height;

                        return ConstrainedBox(
                          constraints: BoxConstraints(
                            maxHeight: height * 0.8,
                          ),
                          child: CommentPage(story: widget.story),
                        );
                      },
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.vertical(
                          top: Radius.circular(20),
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: widget.story.description!.length > 20
                ? RichText(
              text: TextSpan(
                style: DefaultTextStyle.of(context).style,
                children: [
                  TextSpan(text: displayDescription),
                  TextSpan(
                    text: _showFullDescription ? " 접기" : " ... 더보기",
                    style: TextStyle(color: Colors.blue),
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
