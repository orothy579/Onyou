import 'package:cloud_firestore/cloud_firestore.dart';

class Team {
  final String id; // Firestore 문서 ID
  final String name; // 팀 이름
  final List<DocumentReference> users; // 팀에 속한 유저들의 문서 참조
  final List<String> prayerTitles; // 팀 내 기도제목들
  final List<DocumentReference> stories; // 팀원들이 올린 스토리의 문서 참조

  Team({
    required this.id,
    required this.name,
    required this.users,
    required this.prayerTitles,
    required this.stories,
  });

  // Firestore 문서를 Team 객체로 변환
  factory Team.fromDocument(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return Team(
      id: doc.id,
      name: data['name'],
      users: (data['users'] as List).map((userRef) => FirebaseFirestore.instance.doc(userRef)).toList(),
      prayerTitles: List<String>.from(data['prayerTitles']),
      stories: (data['stories'] as List).map((storyRef) => FirebaseFirestore.instance.doc(storyRef)).toList(),
    );
  }

  // Team 객체를 Firestore 문서로 변환
  Map<String, dynamic> toDocument() {
    return {
      'name': name,
      'users': users.map((docRef) => docRef.path).toList(),
      'prayerTitles': prayerTitles,
      'stories': stories.map((docRef) => docRef.path).toList(),
    };
  }
}
