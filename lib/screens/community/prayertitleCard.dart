import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../../model/PrayerTitle.dart';

class PrayerCard extends StatefulWidget {
  final PrayerTitle prayer;
  final bool isMine;

  PrayerCard({required this.prayer, required this.isMine});

  @override
  _PrayerCardState createState() => _PrayerCardState();
}

class _PrayerCardState extends State<PrayerCard>
    with SingleTickerProviderStateMixin {
  bool _isPrayedFor = false;
  late AnimationController _prayerAnimationController;
  late Animation<double> _prayerAnimation;

  String? userName;
  String? userURL;
  String? teamName;

  @override
  void initState() {
    super.initState();

    _isPrayedFor = widget.prayer.prayedFor
            ?.contains(FirebaseAuth.instance.currentUser!.uid) ??
        false;

    _prayerAnimationController = AnimationController(
      duration: const Duration(seconds: 1),
      vsync: this,
    );
    _prayerAnimation = Tween<double>(begin: 0, end: 1).animate(CurvedAnimation(
      parent: _prayerAnimationController,
      curve: Curves.elasticOut,
    ));

    _fetchUserAndTeamData();
  }

  _fetchUserAndTeamData() async {
    DocumentSnapshot userDoc = await widget.prayer.userRef!.get();
    setState(() {
      userName = userDoc['name'];
      userURL = userDoc['image'];
    });

    if (widget.prayer.teamRef != null) {
      DocumentSnapshot teamDoc = await widget.prayer.teamRef!.get();
      setState(() {
        teamName = teamDoc['name'];
      });
    }
  }

  _togglePrayedFor() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      DocumentReference prayerDoc = FirebaseFirestore.instance
          .collection('prayers')
          .doc(widget.prayer.id);
      if (_isPrayedFor) {
        await prayerDoc.update({
          'prayedFor': FieldValue.arrayRemove([user.uid]),
        });
      } else {
        if (widget.prayer.prayedFor == null) {
          await prayerDoc.update({
            'prayedFor': [user.uid]
          });
        } else {
          await prayerDoc.update({
            'prayedFor': FieldValue.arrayUnion([user.uid]),
          });
        }
        _prayerAnimationController.forward().then((_) {
          Future.delayed(Duration(seconds: 1), () {
            _prayerAnimationController.reverse();
          });
        });
      }
      setState(() {
        _isPrayedFor = !_isPrayedFor;
      });
    }
  }

  Future<void> _deletePrayer() async {
    await FirebaseFirestore.instance.collection('prayers').doc(widget.prayer.id).delete();
  }
  _showDeleteConfirmationDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('기도 삭제'),
          content: Text('이 기도를 정말로 삭제하시겠습니까?'),
          actions: [
            TextButton(
              child: Text('취소'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text('삭제'),
              onPressed: () {
                _deletePrayer(); Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }


  @override
  Widget build(BuildContext context) {
    return StreamBuilder<DocumentSnapshot>(
      stream: FirebaseFirestore.instance
          .collection('prayers')
          .doc(widget.prayer.id)
          .snapshots(),
      builder: (context, snapshot) {
        // 여기서 로딩 상태를 검사하고 로딩 인디케이터를 반환합니다.
        if (!snapshot.hasData || userName == null || userURL == null) {
          return Center(child: CircularProgressIndicator());
        }

        final prayerData = snapshot.data!.data() as Map<String, dynamic>;
        final prayedForList = List<String>.from(prayerData['prayedFor'] ?? []);
        _isPrayedFor =
            prayedForList.contains(FirebaseAuth.instance.currentUser!.uid);

        return Stack(
          children: [
            Card(
              color: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(
                side: BorderSide(color: Color(0xff52525C), width: 1), // 테두리의 색상과 두께를 지정합니다.
                borderRadius: BorderRadius.circular(10),
              ),
              margin: const EdgeInsets.all(15.0),
              child: Container(

                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: Color(0xff0092FABC).withOpacity(1),
                      spreadRadius: 0.8,
                      offset: Offset(0,4),
                    ),
                  ],
                ),
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          CircleAvatar(
                            backgroundImage: NetworkImage(userURL!),
                            radius: 20,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              widget.prayer.title,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 18,
                                color: Colors.black,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          if (widget.isMine) // 로그인한 사용자가 업로드한 사용자와 동일한 경우
                            IconButton(
                              icon: const Icon(Icons.delete, color: Colors.red),
                              onPressed: _showDeleteConfirmationDialog,
                            ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(userName ?? '',
                          style:
                              TextStyle(fontSize: 16, color: Colors.grey[600])),
                      const SizedBox(height: 5),
                      Text(widget.prayer.description,
                          style: const TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 16)),
                      SizedBox(height: 10),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          Row(
                            children: [
                              IconButton(
                                icon: FaIcon(
                                    _isPrayedFor
                                        ? FontAwesomeIcons.handsPraying
                                        : FontAwesomeIcons.hand,
                                    color: _isPrayedFor
                                        ? Colors.blue
                                        : Colors.grey[600]),
                                onPressed: _togglePrayedFor,
                              ),
                              Text('${prayedForList.length}')
                            ],
                          ),
                          Row(
                            children: [
                              IconButton(
                                icon: Icon(Icons.comment_outlined, color:Colors.grey[600]),
                                onPressed: () {
                                  // TODO: Implement comment functionality
                                },
                              ),
                              const Text(
                                  '0') // TODO: Replace with the actual comment count
                            ],
                          ),
                          IconButton(
                            icon: Icon(Icons.share_outlined), // Share Icon
                            onPressed: () {
                              // TODO: Implement share functionality
                            },
                          ),

                        ],
                      ),
                      if (teamName != null)
                        Text('Team: $teamName',
                            style:
                                TextStyle(fontSize: 14, color: Colors.grey[600])),
                    ],
                  ),
                ),
              ),
            ),
            if (_isPrayedFor)
              Positioned.fill(
                child: Center(
                  child: ScaleTransition(
                    scale: _prayerAnimation,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        FaIcon(FontAwesomeIcons.handsPraying,
                            color: Colors.blue),
                        Text('기도해주셔서 감사해요!',
                            style: TextStyle(fontWeight: FontWeight.bold)),
                      ],
                    ),
                  ),
                ),
              ),
          ],
        );
      },
    );
  }

  @override
  void dispose() {
    _prayerAnimationController.dispose();
    super.dispose();
  }
}
