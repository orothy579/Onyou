import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class TeamDetailPage extends StatelessWidget {
  final DocumentSnapshot teamDocument;

  TeamDetailPage({required this.teamDocument});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Team Detail', style: TextStyle(color: Colors.black)),
        backgroundColor: Colors.white,
        iconTheme: IconThemeData(color: Colors.black),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          children: <Widget>[
            Expanded(
              flex: 1,
              child: StreamBuilder<DocumentSnapshot>(
                stream: teamDocument.reference.snapshots(),
                builder: (BuildContext context, AsyncSnapshot<DocumentSnapshot> snapshot) {
                  if (snapshot.hasError) {
                    return Text('Something went wrong');
                  }

                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(child: CircularProgressIndicator());
                  }

                  Map<String, dynamic> data = snapshot.data!.data() as Map<String, dynamic>;
                  List<Widget> prayerTitleWidgets = (data['prayerTitle'] as List).map<Widget>((item) {
                    return Card(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: ListTile(title: Text(item.toString())),
                    );
                  }).toList();
                  return ListView(
                    children: prayerTitleWidgets,
                  );
                },
              ),
            ),
            SizedBox(height: 20),
            Expanded(
              flex: 1,
              child: StreamBuilder<QuerySnapshot>(
                stream: teamDocument.reference.collection('stories').orderBy('create_timestamp', descending: true).snapshots(),
                builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
                  if (snapshot.hasError) {
                    return Text('Something went wrong');
                  }

                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(child: CircularProgressIndicator());
                  }

                  List<Widget> storyWidgets = snapshot.data!.docs.map((DocumentSnapshot document) {
                    Map<String, dynamic> data = document.data() as Map<String, dynamic>;
                    return Card(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: ListTile(
                        leading: CircleAvatar(backgroundImage: NetworkImage(data['u_image'])),
                        title: Text(data['title']),
                        subtitle: Text(data['description']),
                      ),
                    );
                  }).toList();

                  return ListView(
                    children: storyWidgets,
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
