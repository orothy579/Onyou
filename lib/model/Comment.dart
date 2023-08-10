import 'package:cloud_firestore/cloud_firestore.dart';

class Comment {
  final String id;               // 댓글의 고유 ID
  final DocumentReference userRef; // 댓글을 작성한 사용자의 문서 참조
  final String content;          // 댓글 내용
  final DateTime timestamp;      // 댓글 작성 시각
  final String? replyToId;       // 대댓글의 경우 원 댓글의 ID. 일반 댓글의 경우 null.

  Comment({
    required this.id,
    required this.userRef,
    required this.content,
    required this.timestamp,
    this.replyToId,
  });

  // Firestore로부터 데이터를 불러와 Comment 객체로 변환
  factory Comment.fromDocument(DocumentSnapshot doc) {
    return Comment(
      id: doc.id,
      userRef: doc['userRef'],
      content: doc['content'],
      timestamp: (doc['timestamp'] as Timestamp).toDate(),
      replyToId: doc['replyToId'],
    );
  }

  // Comment 객체를 Firestore에 저장하기 위한 map 형태로 변환
  Map<String, dynamic> toMap() {
    return {
      'userRef': userRef,
      'content': content,
      'timestamp': timestamp,
      'replyToId': replyToId,
    };
  }
}
