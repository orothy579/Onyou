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

class _PrayerCardState extends State<PrayerCard> with SingleTickerProviderStateMixin {
  bool _isPrayedFor = false;
  bool _showThankYouMessage = false;  // 추가된 변수
  late AnimationController _prayerAnimationController;
  late Animation<double> _prayerAnimation;

  String? userName;
  String? teamName;



  @override
  void initState() {
    super.initState();

    _isPrayedFor = widget.prayer.prayedFor?.contains(FirebaseAuth.instance.currentUser!.uid) ?? false;

    _prayerAnimationController = AnimationController(
      duration: const Duration(seconds: 1),
      vsync: this,
      value: 1.0,
    );

    _prayerAnimation = Tween<double>(begin: 1.0, end: 1.0).animate(CurvedAnimation(
      parent: _prayerAnimationController,
      curve: Curves.elasticOut,
    ));

    _fetchUserAndTeamData();
  }


  _fetchUserAndTeamData() async {
    if (widget.prayer.userRef != null) {
      DocumentSnapshot userDoc = await widget.prayer.userRef!.get();
      setState(() {
        userName = userDoc['name'];
      });
    }

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
      DocumentReference prayerDoc = FirebaseFirestore.instance.collection('prayers').doc(widget.prayer.id);
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

    if (!_isPrayedFor) {
      _prayerAnimationController.forward().then((_) {
        setState(() {
          _showThankYouMessage = true;
        });
        Future.delayed(Duration(seconds: 1), () {
          _prayerAnimationController.reverse().then((_) {
            setState(() {
              _showThankYouMessage = false;
            });
          });
        });
      });
    }
  }


  @override
  Widget build(BuildContext context) {
    return StreamBuilder<DocumentSnapshot>(
      stream: FirebaseFirestore.instance.collection('prayers').doc(widget.prayer.id).snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return CircularProgressIndicator();
        }

        final prayerData = snapshot.data!.data() as Map<String, dynamic>;
        final prayedForList = List<String>.from(prayerData['prayedFor'] ?? []);
        _isPrayedFor = prayedForList.contains(FirebaseAuth.instance.currentUser!.uid);

        return Stack( // <-- Stack 위젯으로 감싸기 시작
          children: [
          Card(
          elevation: 1,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          child: Padding(
            padding: EdgeInsets.all(10.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CircleAvatar(
                      backgroundImage: NetworkImage('<USER_IMAGE_URL>'), // Use Firebase storage URL for user image
                      radius: 25,
                    ),
                    SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(userName ?? '', style: TextStyle( fontSize: 16)),
                          SizedBox(height: 5),
                          Text(widget.prayer.description, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                        ],
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    Row(
                      children: [
                        IconButton(
                          icon: Icon(Icons.comment_outlined),
                          onPressed: () {
                            // TODO: Implement comment functionality
                          },
                        ),
                        Text('0')  // TODO: Replace with the actual comment count
                      ],
                    ),
                    Row(
                      children: [
                        ScaleTransition(
                          scale: _prayerAnimation,
                          child: IconButton(
                            icon: FaIcon(_isPrayedFor ? FontAwesomeIcons.handsPraying : FontAwesomeIcons.hand, color: _isPrayedFor ? Colors.blue : Colors.grey[600]),
                            onPressed: _togglePrayedFor,
                          ),
                        ),
                        Text('${prayedForList.length}')
                      ],
                    ),
                    IconButton(
                      icon: Icon(Icons.share_outlined),  // Share Icon
                      onPressed: () {
                        // TODO: Implement share functionality
                      },
                    ),
                  ],
                ),
                if (teamName != null) Text('Team: $teamName', style: TextStyle(fontSize: 14, color: Colors.grey[600])),


              ],
            ),

          ),

        ),

            if (_showThankYouMessage)
              Positioned.fill(
                child: Center(
                  child: ScaleTransition(
                    scale: _prayerAnimation,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        FaIcon(FontAwesomeIcons.handsPraying , color: Colors.blue,),
                        Text('기도해주셔서 감사해요!', style: TextStyle(fontWeight: FontWeight.bold)),
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
