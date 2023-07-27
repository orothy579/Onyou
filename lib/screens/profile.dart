import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class ProfilePage extends StatefulWidget {
  ProfilePage({Key? key}) : super(key: key);

  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  late TextEditingController _statusController;
  String? _chosenTeam;
  String? imageUrl;

  @override
  void initState() {
    super.initState();
    _statusController = TextEditingController();
  }

  @override
  void dispose() {
    _statusController.dispose();
    super.dispose();
  }

  Future<void> _showTeamPickerDialog() async {
    await showDialog<String>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Pick a team'),
          content: Column(
            children: ['OBC', 'OEC', 'OFC', 'OCB']
                .map((team) => RadioListTile<String>(
              title: Text(team),
              value: team,
              groupValue: _chosenTeam,
              onChanged: (value) {
                setState(() {
                  _chosenTeam = value;
                });
                Navigator.of(context).pop();
              },
            ))
                .toList(),
          ),
        );
      },
    );
  }

  uploadImage() async {
    String dt = DateTime.now().toString();
    final _firebaseStorage = FirebaseStorage.instance;
    final ImagePicker _picker = ImagePicker();
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    var file = File(image!.path);

    var snapshot =
    await _firebaseStorage.ref().child('profile/profile-$dt').putFile(file);
    var downloadUrl = await snapshot.ref.getDownloadURL();
    setState(() {
      imageUrl = downloadUrl;
    });
  }

  Future<void> updateUser(String uid,
      {String? name,
        String? image,
        String? status_message,
        List<String>? prayerTitle,
        DocumentReference? teamRef}) {
    return FirebaseFirestore.instance.collection('users').doc(uid).set({
      'name': name ?? "익명",
      'uid': uid,
      'image': image ??
          'https://img.freepik.com/premium-vector/cute-jesus-with-finger-heart-shape_123847-889.jpg',
      'status_message': status_message ?? "",
      'prayTitle': prayerTitle ?? [],
      'teamRef': teamRef?.path ?? "", // convert DocumentReference to string path
    }, SetOptions(merge: true));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Profile'),
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.all(8),
        children: <Widget>[
          Card(
            child: ListTile(
              title: Text('Pick a team'),
              subtitle: _chosenTeam != null ? Text('Selected Team: $_chosenTeam') : null,
              trailing: IconButton(
                icon: Icon(Icons.edit),
                onPressed: _showTeamPickerDialog,
              ),
            ),
          ),
          Card(
            child: ListTile(
              title: TextFormField(
                controller: _statusController,
                decoration: InputDecoration(labelText: 'Status Message'),
              ),
            ),
          ),
          Card(
            child: ListTile(
              title: Text('Pick an image'),
              subtitle: imageUrl != null ? Image.network(imageUrl!) : null,
              trailing: IconButton(
                icon: Icon(Icons.image),
                onPressed: uploadImage,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 16.0),
            child: Center(
              child: ElevatedButton(
                child: const Text('OK'),
                onPressed: () async {
                  await updateUser(
                    FirebaseAuth.instance.currentUser!.uid,
                    name: _statusController.text,
                    image: imageUrl,
                    status_message: _statusController.text,
                    teamRef: FirebaseFirestore.instance.doc('teams/$_chosenTeam'),
                  );
                  showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return AlertDialog(
                        title: Text("Profile Updated"),
                        content: Text("Your profile has been successfully updated!"),
                        actions: <Widget>[
                          TextButton(
                            child: Text("Close"),
                            onPressed: () {
                              Navigator.of(context).pop();
                              Navigator.of(context).pop();
                            },
                          ),
                        ],
                      );
                    },
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}
