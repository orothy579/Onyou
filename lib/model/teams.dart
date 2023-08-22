import 'package:cloud_firestore/cloud_firestore.dart';

class Team {
  final String id; // Firestore 문서 ID
  final String name; // 팀 이름
  final List<DocumentReference> users; // 팀에 속한 유저들의 문서 참조
  final List<DocumentReference> prayerTitles; // 팀 내 기도제목들을 참조하는 문서 참조
  final List<DocumentReference> stories; // 팀원들이 올린 스토리의 문서 참조
  final String imgURL;

  Team({
    required this.id,
    required this.name,
    required this.users,
    required this.prayerTitles,
    required this.stories,
    required this.imgURL,
  });

  // Firestore 문서를 Team 객체로 변환
  factory Team.fromDocument(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return Team(
      id: doc.id,
      name: data['name'] ?? "",
      users: (data['users'] as List? ?? []).whereType<DocumentReference>().toList(),
      prayerTitles: (data['prayerTitles'] as List? ?? []).whereType<DocumentReference>().toList(),
      stories: (data['stories'] as List? ?? []).whereType<DocumentReference>().toList(),
      imgURL: data['imgURL'] ?? "",
    );
  }

  // Team 객체를 Firestore 문서로 변환
  Map<String, dynamic> toDocument() {
    return {
      'name': name,
      'users': users.map((docRef) => docRef.path).toList(),
      'prayerTitles': prayerTitles.map((docRef) => docRef.path).toList(),
      'stories': stories.map((docRef) => docRef.path).toList(),
      'imgURL': imgURL,
    };
  }
}
