import 'package:cloud_firestore/cloud_firestore.dart';


class Notice  {

  Notice({
    this.image,
    this.title,
    this.description,
    this.create_timestamp,
    this.reference,
  });

  String? image;
  String? title;
  String? description;
  FieldValue? create_timestamp;
  DocumentReference? reference;

  Notice.fromJson(dynamic json, this.reference){
    image = json['image'];
    title = json['name'];
    description = json['description'];
    create_timestamp = json['create_timestamp'];

  }

  Map<String, dynamic> toJson() => {
    "image" : image,
    "name" : title,
    "description" : description,
    "create_timestamp" : create_timestamp,
  };

  Notice.fromQuerySnapshot(QueryDocumentSnapshot<Map<String, dynamic>> snapshot)
      : this.fromJson(snapshot.data(),snapshot.reference);

}





