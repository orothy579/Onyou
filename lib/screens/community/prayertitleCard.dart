import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

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
    );
    _prayerAnimation = Tween<double>(begin: 0, end: 1).animate(CurvedAnimation(
      parent: _prayerAnimationController,
      curve: Curves.elasticOut,
    ));

    // Retrieve user and team data from Firebase when the widget is initialized
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
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Card(
          elevation: 8, // 그림자 강조
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          child: ListTile(
            leading: Icon(
              _isPrayedFor ? Icons.accessibility_new : Icons.accessibility,
              color: _isPrayedFor ? Colors.blue : Colors.grey[600],
              size: 30, // 아이콘 크기 조절
            ),
            title: Text(widget.prayer.description, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)), // 텍스트 스타일 변경
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('By: $userName', style: TextStyle(fontSize: 16)), // 텍스트 스타일 변경
                if (teamName != null) Text('Team: $teamName', style: TextStyle(fontSize: 16)), // 텍스트 스타일 변경
              ],
            ),
            trailing: Text('${widget.prayer.prayedFor?.length ?? 0}', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20)), // 텍스트 크기 조절
            onTap: _togglePrayedFor,
          ),
        ),
        if (_prayerAnimation.status == AnimationStatus.forward || _prayerAnimation.status == AnimationStatus.completed)
          Center(
            child: ScaleTransition(
              scale: _prayerAnimation,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.accessibility_new, color: Colors.blue, size: 100),
                  Text('Prayed for this!', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 24)),
                ],
              ),
            ),
          ),
      ],
    );
  }
  @override
  void dispose() {
    _prayerAnimationController.dispose();
    super.dispose();
  }
}
