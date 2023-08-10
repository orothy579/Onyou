import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';
import '../../model/Story.dart';
import 'commentPage.dart';

class StoryList extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: StreamBuilder(
            stream: FirebaseFirestore.instance.collection('story').orderBy('create_timestamp', descending: true).snapshots(),
            builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
              if (!snapshot.hasData) {
                return CircularProgressIndicator();
              }
              return ListView.builder(
                itemCount: snapshot.data!.docs.length,
                itemBuilder: (context, index) {
                  final storyDoc = snapshot.data!.docs[index] as QueryDocumentSnapshot<Map<String,dynamic>>;
                  final story = Story.fromQuerySnapshot(storyDoc);
                  return StoryCard(story: story);
                },
              );
            },
          ),
        ),
      ],
    );
  }
}

class StoryCard extends StatefulWidget {
  final Story story;
  StoryCard({required this.story});
  @override
  _StoryCardState createState() => _StoryCardState();
}

class _StoryCardState extends State<StoryCard> with SingleTickerProviderStateMixin {
  bool _isLiked = false;
  late AnimationController _heartAnimationController;
  late Animation<double> _heartAnimation;

  @override
  void initState() {
    super.initState();
    _heartAnimationController = AnimationController(
      duration: const Duration(seconds: 1),
      vsync: this,
    );
    _heartAnimation = Tween<double>(begin: 0, end: 1).animate(CurvedAnimation(
      parent: _heartAnimationController,
      curve: Curves.elasticOut,
    ));
  }

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
        _heartAnimationController.forward().then((_) {
          Future.delayed(Duration(seconds: 1), () {
            _heartAnimationController.reverse();
          });
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
    return Stack(
      children: [
        Container(
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
              // ... (기존의 Container 내용)
            ],
          ),
        ),
        Center(
          child: ScaleTransition(
            scale: _heartAnimation,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.favorite, color: Colors.red, size: 200),
                Text('공감해주셔서 감사해요!', style: TextStyle(fontWeight: FontWeight.bold)),
              ],
            ),
          ),
        ),
      ],
    );
  }

  @override
  void dispose() {
    _heartAnimationController.dispose();
    super.dispose();
  }
}
