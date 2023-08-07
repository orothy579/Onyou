import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:intl/intl.dart';


import '../../model/prayerTitle.dart';

class TeamDetailPage extends StatelessWidget {
  final DocumentSnapshot teamDocument;

  TeamDetailPage({required this.teamDocument});

  // Some TextField Controllers to get input from the user
  final descriptionController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('${teamDocument['name']} 기도제목', style: TextStyle(color: Colors.black)),
        backgroundColor: Colors.white,
        iconTheme: IconThemeData(color: Colors.black),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          children: <Widget>[
            Expanded(
              flex: 1,
              child: StreamBuilder<QuerySnapshot>(
                stream: teamDocument.reference
                    .collection('prayerTitles')
                    .orderBy('dateTime', descending: true)
                    .snapshots(),
                builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
                  if (snapshot.hasError) {
                    return Text('Something went wrong');
                  }

                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(child: CircularProgressIndicator());
                  }

                  List<DocumentSnapshot> docs = snapshot.data!.docs;

                  // 분류 작업 시작
                  Map<DateTime, List<PrayerTitle>> prayerTitlesByDate = {};
                  for (var doc in docs) {
                    final PrayerTitle prayerTitle = PrayerTitle.fromDocument(doc);
                    final DateTime date = prayerTitle.dateTime.toDate();

                    // 날짜에 따라 문서를 분류합니다.
                    final key = DateTime(date.year, date.month, date.day); // key로 사용될 날짜. 시간은 무시합니다.
                    if (prayerTitlesByDate.containsKey(key)) {
                      prayerTitlesByDate[key]!.add(prayerTitle);
                    } else {
                      prayerTitlesByDate[key] = [prayerTitle];
                    }
                  }

                  // 각 섹션을 위한 ListView.builder를 생성합니다.
                  List<Widget> sections = [];
                  prayerTitlesByDate.entries.forEach((entry) {
                    sections.add(
                      Text(
                        DateFormat('yyyy년 MM월 dd일').format(entry.key), // 헤더를 날짜로 설정합니다.
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black26),
                        textAlign: TextAlign.center
                      ),
                    );

                    sections.add(
                      SizedBox(height: 10),
                    );

                    sections.add(
                      ListView.builder(
                        shrinkWrap: true,
                        physics: NeverScrollableScrollPhysics(),
                        itemCount: entry.value.length,
                        itemBuilder: (context, index) {
                          // 다른 부분의 코드를 사용하면서 각 기도 제목을 만듭니다.
                          final PrayerTitle prayerTitle = entry.value[index];
                          final bool isMine = FirebaseAuth.instance.currentUser!.uid == prayerTitle.userRef.id;

                          return FutureBuilder<DocumentSnapshot>(
                            future: prayerTitle.userRef.get(),
                            builder: (BuildContext context, AsyncSnapshot<DocumentSnapshot> userSnapshot) {
                              if (userSnapshot.hasError) {
                                return Text('Something went wrong');
                              }

                              if (userSnapshot.connectionState == ConnectionState.waiting) {
                                return Center(child: CircularProgressIndicator());
                              }

                              Map<String, dynamic> userData = userSnapshot.data!.data() as Map<String, dynamic>;
                              String userName = userData['name'];

                              return Slidable(
                                endActionPane: ActionPane(
                                  motion: ScrollMotion(),
                                  children: [
                                    SlidableAction(
                                      onPressed: (context) async {
                                        await docs[index].reference.delete();
                                      },
                                      label: 'Delete',
                                      backgroundColor: Colors.red,
                                      icon: Icons.delete,
                                    ),
                                  ],
                                ),
                                enabled: isMine,
                                child: Card(
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: ListTile(
                                      title: Text(prayerTitle.description),
                                      subtitle: Text(userName)),
                                ),
                              );
                            },
                          );
                        },
                      ),
                    );
                  });

                  return ListView(
                    children: sections,
                  );
                },
              ),
            ),
          TextField(
              controller: descriptionController,
              decoration: InputDecoration(
                hintText: '기도제목을 입력하세요.',
                filled: true, // 채워진 스타일
                fillColor: Colors.white, // 채움 색상은 흰색
                contentPadding: EdgeInsets.all(15.0), // 패딩 값 추가
                border: OutlineInputBorder(
                  // 외곽선 스타일 변경
                  borderRadius: BorderRadius.circular(10.0), // 외곽선 둥글게
                  borderSide: BorderSide.none, // 외곽선 없음
                ),
                suffixIcon: IconButton(
                  icon: Icon(Icons.send),
                  onPressed: () async {
                    final Currentuser = FirebaseAuth.instance.currentUser;

                    if (Currentuser != null) {
                      final prayerTitle = PrayerTitle(
                        dateTime: Timestamp.fromDate(DateTime.now()),
                        userRef: FirebaseFirestore.instance
                            .collection('users')
                            .doc(Currentuser.uid),
                        description: descriptionController.text,
                      );

                      await FirebaseFirestore.instance
                          .collection('teams')
                          .doc(teamDocument.id)
                          .update({
                        'prayerTitle': FirebaseFirestore.instance
                            .collection('teams')
                            .doc(teamDocument.id)
                            .collection('prayerTitles')
                            .add(prayerTitle.toMap())
                      });

                      descriptionController.clear();
                    }
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
// import 'package:flutter/material.dart';
//
// class TeamDetailPage extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text('팀예시', style: TextStyle(fontFamily: 'Billabong', fontSize: 35.0)),
//         actions: <Widget>[
//           IconButton(
//             icon: Icon(Icons.add_box_outlined),
//             onPressed: () {},
//           ),
//           IconButton(
//             icon: Icon(Icons.favorite_border_outlined),
//             onPressed: () {},
//           ),
//           IconButton(
//             icon: Icon(Icons.chat_bubble_outline),
//             onPressed: () {},
//           ),
//         ],
//       ),
//       body: ListView.builder(
//         itemCount: 5, // or however many posts you want
//         itemBuilder: (BuildContext context, int index) {
//           return Column(
//             children: <Widget>[
//               ListTile(
//                 leading: CircleAvatar(
//                   backgroundImage: NetworkImage('https://i.pinimg.com/564x/bf/51/15/bf511502f561794019d0d8cd13fb17f9.jpg'),
//                 ),
//                 title: Text('User $index'),
//                 trailing: IconButton(
//                   icon: Icon(Icons.more_horiz),
//                   onPressed: () {},
//                 ),
//               ),
//               Container(
//                 constraints: BoxConstraints.expand(
//                   height: Theme.of(context).textTheme.headlineMedium!.fontSize! * 1.1 + 200.0,
//                 ),
//                 child: Image.network(
//                   'https://i.pinimg.com/564x/dd/45/22/dd4522d608c0cf639ff65a5098425093.jpg',
//                   fit: BoxFit.cover,
//                 ),
//               ),
//               Row(
//                 mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                 children: <Widget>[
//                   Row(
//                     children: <Widget>[
//                       IconButton(
//                         icon: Icon(Icons.favorite_border),
//                         onPressed: () {},
//                       ),
//                       IconButton(
//                         icon: Icon(Icons.mode_comment_outlined),
//                         onPressed: () {},
//                       ),
//                       IconButton(
//                         icon: Icon(Icons.share_outlined),
//                         onPressed: () {},
//                       ),
//                     ],
//                   ),
//                   IconButton(
//                     icon: Icon(Icons.bookmark_border),
//                     onPressed: () {},
//                   ),
//                 ],
//               ),
//               Padding(
//                 padding: const EdgeInsets.symmetric(horizontal: 16.0),
//                 child: Text(
//                   'Liked by username and others',
//                   style: TextStyle(fontWeight: FontWeight.bold),
//                 ),
//               ),
//               Padding(
//                 padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
//                 child: Text(
//                   'View all comments',
//                   style: TextStyle(color: Colors.grey),
//                 ),
//               ),
//             ],
//           );
//         },
//       ),
//     );
//   }
// }
