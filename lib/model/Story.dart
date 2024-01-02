import 'package:cloud_firestore/cloud_firestore.dart';

class Story {
  Story({
    this.id,
    this.userId,
    this.images, // 수정됨
    this.title,
    this.name,
    this.u_image,
    this.description,
    this.create_timestamp,
    this.userRef,
    this.teamRef,
    this.reference,
    this.likes,
  });

  String? id;
  String? userId;
  List<String>? images; // 수정됨
  String? title;
  String? name;
  String? u_image;
  String? description;
  Timestamp? create_timestamp;
  DocumentReference? userRef;
  DocumentReference? teamRef;
  DocumentReference? reference;
  List<String>? likes;


  Story.fromJson(dynamic json, this.reference) {
    id = json['id'] as String?;
    images = json['images'] != null ? List<String>.from(json['images']) : null;
    title = json['title'];
    name = json['name'];
    u_image = json['u_image'];
    description = json['description'];
    create_timestamp = json['create_timestamp'];
    userRef = json['userRef'] != null
        ? FirebaseFirestore.instance.doc(json['userRef'])
        : null;
    teamRef = json['teamRef'] != null
        ? FirebaseFirestore.instance.doc(json['teamRef'])
        : null;
    likes = json['likes'] != null ? List<String>.from(json['likes']) : [];
  }

  factory Story.fromDocument(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;

    return Story(
      id: doc.id,
      images: data['images'] != null ? List<String>.from(data['images']) : null,
      title: data['title'],
      name: data['name'],
      u_image: data['u_image'],
      description: data['description'],
      create_timestamp: data['create_timestamp'],
      userRef: data['userRef'] != null
          ? FirebaseFirestore.instance.doc(data['userRef'])
          : null,
      teamRef: data['teamRef'] != null
          ? FirebaseFirestore.instance.doc(data['teamRef'])
          : null,
      likes: data['likes'] != null ? List<String>.from(data['likes']) : [],
      reference: doc.reference, // 여기서 reference를 설정해줍니다.
    );
  }


  factory Story.fromQuerySnapshot(QueryDocumentSnapshot<Map<String, dynamic>> snapshot) {
    return Story(
      id: snapshot.id,
      images: snapshot['images'] != null
          ? List<String>.from(snapshot['images'])
          : null,
      title: snapshot['title'],
      name: snapshot['name'],
      u_image: snapshot['u_image'],
      description: snapshot['description'],
      create_timestamp: snapshot['create_timestamp'],
      userRef: snapshot['userRef'],  // No need for additional conversion if it's already a DocumentReference
      teamRef: snapshot['teamRef'],  // No need for additional conversion if it's already a DocumentReference
      likes: snapshot['likes'] != null
          ? List<String>.from(snapshot['likes'])
          : [],
      reference: snapshot.reference,
    );
  }

}