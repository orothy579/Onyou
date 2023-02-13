import 'package:cloud_firestore/cloud_firestore.dart';


class Story  {
  Story({
    this.image,
    this.title,
    this.name,
    this.u_image,
    this.description,
    this.create_timestamp,
    this.reference,
  });

  String? image;
  String? title;
  String? name;
  String? u_image;
  String? description;
  Timestamp? create_timestamp;
  DocumentReference? reference;

  Story.fromJson(dynamic json, this.reference){
    image = json['image'];
    title = json['title'];
    name = json['name'];
    u_image = json['u_image'];
    description = json['description'];
    create_timestamp = json['create_timestamp'];
  }

  Map<String, dynamic> toJson() => {
    "image" : image,
    "title" : title,
    "name" : name,
    "u_image" : u_image,
    "description" : description,
    "create_timestamp" : create_timestamp,
  };

  Story.fromQuerySnapshot(QueryDocumentSnapshot<Map<String, dynamic>> snapshot)
      : this.fromJson(snapshot.data(),snapshot.reference);

}


