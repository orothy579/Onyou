import 'package:cloud_firestore/cloud_firestore.dart';

class PrayerTitle {
  final String id;
  final Timestamp dateTime;
  final DocumentReference userRef;
  final String description;
  DocumentReference? teamRef;
  List<String>? prayedFor;// prayedFor 필드 추가

  PrayerTitle({
    required this.id,
    required this.dateTime,
    required this.userRef,
    required this.description,
    this.teamRef,
    this.prayedFor,  // 생성자에 추가
  });

  // Firebase에 저장할 수 있는 Map 형태로 데이터를 변환합니다.
  Map<String, dynamic> toMap() {
    return {
      'dateTime': dateTime,
      'userRef': userRef,
      'description': description,
      'teamRef': teamRef,
      'prayedFor': prayedFor,  // Firebase 저장을 위해 추가
    };
  }

  // Firestore 문서를 PrayerTitle 객체로 변환하는 정적 메서드를 추가
  factory PrayerTitle.fromDocument(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;

    List<String>? prayedForList;
    if (data['prayedFor'] != null) {
      prayedForList = (data['prayedFor'] as List).map((item) => item.toString()).toList();
    }

    return PrayerTitle(
      id: doc.id,
      dateTime: data['dateTime'],
      userRef: data['userRef'],
      description: data['description'],
      teamRef: data['teamRef'],
      prayedFor: prayedForList, // Firestore로부터 prayedFor를 읽어와 객체를 생성
    );
  }
}
