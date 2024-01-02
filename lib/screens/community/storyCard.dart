import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
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
            stream: FirebaseFirestore.instance
                .collection('story')
                .orderBy('create_timestamp', descending: true)
                .snapshots(),
            builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
              if (!snapshot.hasData) {
                return CircularProgressIndicator();
              }
              return ListView.builder(
                itemCount: snapshot.data!.docs.length,
                itemBuilder: (context, index) {
                  final storyDoc = snapshot.data!.docs[index]
                  as QueryDocumentSnapshot<Map<String, dynamic>>;
                  final story = Story.fromQuerySnapshot(storyDoc);
                  return StoryCard(
                      key : ValueKey(story.id),
                      story: story
                  );
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
  StoryCard({required this.story, Key? key}) : super(key: key);
  @override
  _StoryCardState createState() => _StoryCardState();
}

class _StoryCardState extends State<StoryCard> with SingleTickerProviderStateMixin {
  late AnimationController _heartAnimationController;
  late Animation<double> _heartAnimation;

  bool isLiked = false;

  @override
  void initState() {
    super.initState();

    isLiked = widget.story.likes!.contains(FirebaseAuth.instance.currentUser!.uid);

    _heartAnimationController = AnimationController(
      duration: const Duration(seconds: 1),
      vsync: this,
    );
    _heartAnimation = Tween<double>(begin: 0, end: 1).animate(CurvedAnimation(
      parent: _heartAnimationController,
      curve: Curves.elasticOut,
    ));
  }

  Future<void> _toggleLike() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final storyRef = FirebaseFirestore.instance.collection('story').doc(widget.story.id);

    if (isLiked) {
      await storyRef.update({
        'likes': FieldValue.arrayRemove([user.uid]),
      });
    } else {
      await storyRef.update({
        'likes': FieldValue.arrayUnion([user.uid]),
      });
      _heartAnimationController.forward().then((_) {
        Future.delayed(Duration(seconds: 1), () {
          _heartAnimationController.reverse();
        });
      });
    }
    setState(() {
      isLiked = !isLiked;
    });
  }


  Future<void> _deleteStory() async {
    // Firestore에서 스토리 데이터 가져오기
    var storyDocument = await FirebaseFirestore.instance.collection('story').doc(widget.story.id).get();
    var storyData = storyDocument.data();

    if (storyData != null && storyData['images'] != null) {
      // Firebase Storage에서 각 이미지 삭제
      List<String> imageUrls = List<String>.from(storyData['images']);
      for (String imageUrl in imageUrls) {
        await FirebaseStorage.instance.refFromURL(imageUrl).delete();
      }
    }

    // Firestore에서 스토리 삭제
    await FirebaseFirestore.instance.collection('story').doc(widget.story.id).delete();
  }

  Future<void> _showPopupMenu(BuildContext context) async {
    RenderBox button = context.findRenderObject() as RenderBox;
    var offset = button.localToGlobal(Offset.zero);

    List<PopupMenuEntry<String>> popupMenuItems = [
      if (_isCurrentUserStoryOwner()) // 게시물의 작성자만 삭제 아이콘 표시
        PopupMenuItem<String>(
        value: 'edit',
        child: ListTile(
          title: Text('수정하기'),
        ),
      ),
      if (_isCurrentUserStoryOwner()) // 게시물의 작성자만 삭제 아이콘 표시
        PopupMenuItem<String>(
          value: 'delete',
          child: ListTile(
            title: Text('삭제하기'),
          ),
          onTap: () {
            _showDeleteConfirmationDialog();
          },
        ),
      PopupMenuItem<String>(
        value: 'share',
        child: ListTile(
          title: Text('공유하기'),
        ),
      ),
    ];

    await showMenu(
      context: context,
      position: RelativeRect.fromLTRB(
        offset.dx + 300,
        offset.dy + 70,
        MediaQuery.of(context).size.width - offset.dx,
        MediaQuery.of(context).size.height - offset.dy,
      ),
      items: popupMenuItems,
      elevation: 8.0,
    );
  }


  void _showDeleteConfirmationDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('스토리 삭제'),
          content: Text('이 스토리를 정말로 삭제하시겠습니까?'),
          actions: [
            TextButton(
              child: Text('취소'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text('삭제'),
              onPressed: () async {
                await _deleteStory();
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  bool _showFullDescription = false;

  bool _isCurrentUserStoryOwner() {
    final currentUserRef = 'users/' + FirebaseAuth.instance.currentUser!.uid;
    return currentUserRef == widget.story.userRef!.path;
  }


  @override
  Widget build(BuildContext context) {
    double fontSize = widget.story.title!.length > 10 ? 15 : 20;
    isLiked =
        widget.story.likes!.contains(FirebaseAuth.instance.currentUser!.uid);
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
            borderRadius: BorderRadius.circular(12.0),
            border: Border.all(color: Color(0xff52525C)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: EdgeInsets.all(16.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    CircleAvatar(
                      radius: 25,
                      backgroundImage: NetworkImage(widget.story.u_image!),
                    ),
                    SizedBox(width: 15.0,),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.story.title!,
                          style: TextStyle(
                              fontWeight: FontWeight.bold, fontSize: fontSize),
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                        ),
                        Text(
                          widget.story.name!,
                          style: TextStyle(color: Colors.grey[600]),
                        ),
                      ],
                    ),
                    Spacer(), // Added Spacer to push IconButton to the right
                      IconButton(
                          icon: const Icon(Icons.more_vert, color: Colors.grey),
                          onPressed: () async {
                            await _showPopupMenu(context);
                          },
                        ),

                  ],
                ),
              ),
              Visibility(
                visible: widget.story.images != null && widget.story.images!.isNotEmpty,
                child: Container(
                  width: double.infinity,
                  height: 300.0,
                  child: CarouselSlider.builder(
                    itemCount: widget.story.images!.length,
                    itemBuilder: (context, index, realIdx) {
                      return ClipRRect(
                        borderRadius: BorderRadius.circular(20.0),
                        child: Image.network(
                          widget.story.images![index],
                          fit: BoxFit.cover,
                        ),
                      );
                    },
                    options: CarouselOptions(
                      autoPlay: false,
                      enlargeCenterPage: true,
                      viewportFraction: 0.8,
                      aspectRatio: 16 / 9,
                    ),
                  ),
                ),
              ),

              Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Row(
                      children: [
                        IconButton(
                          icon: Icon(
                            isLiked ? Icons.favorite : Icons.favorite_border,
                            color: isLiked ? Colors.red : Colors.grey[600],
                          ),
                          onPressed: _toggleLike,
                        ),
                        Text('${widget.story.likes!.length}',
                            style: TextStyle(fontWeight: FontWeight.bold)),
                      ],
                    ),
                    IconButton(
                      icon:
                      Icon(Icons.comment_outlined, color: Colors.grey[600]),
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
                padding:
                const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
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
                              _showFullDescription =
                              !_showFullDescription;
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
                Text('공감해주셔서 감사해요!',
                    style: TextStyle(fontWeight: FontWeight.bold)),
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