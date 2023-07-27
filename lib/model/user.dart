import 'package:cloud_firestore/cloud_firestore.dart';

class Users  {
  Users({
    this.email,
    this.uid,
    this.image,
    this.name,
    this.status_message,
    this.prayerTitle,
    this.teamRef,
  });

  String? email;
  String? uid;
  String? image;
  String? name;
  String? status_message;
  List<String>? prayerTitle;
  DocumentReference? teamRef;
  DocumentReference? reference;

  Users.fromJson(dynamic json, this.reference){
    email = json['email'];
    uid = json['uid'];
    image = json['image'];
    name = json['name'];
    status_message = json['status_message'];
    prayerTitle = List<String>.from(json['prayerTitle'] ?? []);
    if (json['teamRef'] != null && json['teamRef'] != "") {
      teamRef = FirebaseFirestore.instance.doc(json['teamRef']);
    }
  }

  Users.fromSnapshot(DocumentSnapshot<Map<String, dynamic>> snapshot)
      : this.fromJson(snapshot.data(), snapshot.reference);
}
