import 'dart:developer';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../../model/prayerTitle.dart';

class AddPrayPage extends StatefulWidget {
  const AddPrayPage({Key? key}) : super(key: key);

  @override
  State<AddPrayPage> createState() => _AddPrayPageState();
}

class _AddPrayPageState extends State<AddPrayPage> {
  final _title = TextEditingController();
  final _description = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  final db = FirebaseFirestore.instance;
  final _uid = FirebaseAuth.instance.currentUser!.uid;
  DocumentReference? _userTeamRef;

  @override
  void initState() {
    super.initState();
    _fetchUserTeam();
  }

  _fetchUserTeam() async {
    final DocumentReference userRef = FirebaseFirestore.instance.collection('users').doc(_uid);
    final userDoc = await userRef.get();
    setState(() {
      _userTeamRef = FirebaseFirestore.instance.doc(userDoc['teamRef']);
    });
  }

  void addPrayerTitle() async {
    if (_userTeamRef == null) {
      log("User's team not found");
      return;
    }

    Timestamp now = Timestamp.now();

    // 먼저 PrayerTitle 객체 없이 데이터를 Firestore에 추가합니다.
    DocumentReference ref = await db.collection('prayers').add({
      'title' : _title.text,
      'dateTime': now,
      'userRef': db.collection('users').doc(_uid),
      'description': _description.text,
      'teamRef': _userTeamRef!,

    });

    // 추가된 문서의 ID를 추출합니다.
    String docId = ref.id;

    // 이제 ID를 사용하여 PrayerTitle 객체를 생성할 수 있습니다.
    PrayerTitle prayerTitle = PrayerTitle(
      title: _title.text,
      id: docId,
      dateTime: now,
      userRef: db.collection('users').doc(_uid),
      description: _description.text,
      teamRef: _userTeamRef!,
    );

    log("Prayer Title uploaded successfully with ID: $docId");
    Navigator.pushNamed(context, '/home');
  }



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: Text('기도 제목 추가', style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.send),
            onPressed: () {
              if (_formKey.currentState!.validate()) { // Form 검증
                addPrayerTitle();
              }
            },
          )
        ],
      ),
      body: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              children: [
                if (_userTeamRef != null)
                  DropdownButton<DocumentReference>(
                    value: _userTeamRef,
                    items: [
                      DropdownMenuItem(
                        child: Text(_userTeamRef!.id),
                        value: _userTeamRef,
                      ),
                      // 다른 팀의 항목도 추가 가능
                    ],
                    onChanged: (newTeam) {
                      setState(() {
                        _userTeamRef = newTeam;
                      });
                    },
                  ),
                SizedBox(height: 20),
                TextFormField(
                  controller: _title,
                  maxLines: 1,
                  decoration: InputDecoration(
                    labelText: '제목을 입력해주세요.',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(15),
                    )
                  ),
                  validator: (value){
                    if (value == null || value.isEmpty) {
                      return '내용을 입력해주세요.';
                    }
                    return null;
                  }


                ),
                SizedBox(height: 15.0,),
                TextFormField(
                  controller: _description,
                  maxLines: 5,
                  decoration: InputDecoration(
                    labelText: '무얼 같이 기도할까요?',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                  ),
                  validator: (value){
                    if(value == null || value.isEmpty){
                      return '내용을 입력해주세요.';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
