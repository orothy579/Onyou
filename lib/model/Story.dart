import 'package:cloud_firestore/cloud_firestore.dart';

class Story {
  Story({
    this. id,
    this. userId,
    this.image,
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
  String? image;
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
    image = json['image'];
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

  Map<String, dynamic> toJson() => {
    "image": image,
    "title": title,
    "name": name,
    "u_image": u_image,
    "description": description,
    "create_timestamp": create_timestamp,
    "userRef": userRef?.path,
    "teamRef": teamRef?.path,
    "likes": likes,
  };

  Story.fromQuerySnapshot(QueryDocumentSnapshot<Map<String, dynamic>> snapshot)
      : this.fromJson(snapshot.data(), snapshot.reference);
}
