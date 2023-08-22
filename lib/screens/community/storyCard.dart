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

  bool _isCurrentUserStoryOwner() {
    final currentUserRef = 'users/' + FirebaseAuth.instance.currentUser!.uid;
    return currentUserRef == widget.story.userRef!.path;
  }



  @override
  Widget build(BuildContext context) {
    double fontSize = widget.story.title!.length > 10 ? 15 : 20;

    print(FirebaseAuth.instance.currentUser!.uid);
    print(widget.story.userRef!.path);


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
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: fontSize),
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
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
                    return ClipRRect(
                      borderRadius: BorderRadius.circular(20.0), // 둥근 모서리 추가
                      child: Image.network(
                        widget.story.images![index],
                        fit: BoxFit.cover,
                      ),
                    );
                  },
                  options: CarouselOptions(
                    autoPlay: false,
                    enlargeCenterPage: true,
                    viewportFraction: 0.8, // 가운데 이미지를 제외하고 양쪽 이미지가 조금 보이게 수정
                    aspectRatio: 16 / 9,
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

                    if (_isCurrentUserStoryOwner())  // 게시물의 작성자만 삭제 아이콘 표시
                      IconButton(
                        icon: Icon(Icons.delete, color: Colors.red[600]),
                        onPressed: () async {
                          await FirebaseFirestore.instance
                              .collection('story')
                              .doc(widget.story.id)
                              .delete();
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
