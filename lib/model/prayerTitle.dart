import 'package:cloud_firestore/cloud_firestore.dart';

class PrayerTitle {
  final Timestamp dateTime;
  final DocumentReference userRef;
  final String description;

  PrayerTitle({
    required this.dateTime,
    required this.userRef,
    required this.description,
  });

  // Firebase에 저장할 수 있는 Map 형태로 데이터를 변환합니다.
  Map<String, dynamic> toMap() {
    return {
      'dateTime': dateTime,
      'userRef': userRef,
      'description': description,
    };
  }

  // Firestore 문서를 PrayerTitle 객체로 변환하는 정적 메서드를 추가
  factory PrayerTitle.fromDocument(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return PrayerTitle(
      dateTime: data['dateTime'],
      userRef: data['userRef'],
      description: data['description'],
    );
  }
}
