import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class EditStoryPage extends StatefulWidget {
  final String documentId;

  EditStoryPage({required this.documentId});

  @override
  _EditPageStoryState createState() => _EditPageStoryState();
}

class _EditPageStoryState extends State<EditStoryPage> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  String? _selectedTeam;
  final List<String> _teams = [
    'Branding',
    'Builder Community',
    'OBC',
    'OCB',
    'OEC',
    'OFC',
    'OSW',
    'Onebody FC',
    'Onebody House',
    '이웃'
  ];

  @override
  void initState() {
    super.initState();
    // Fetch existing data
    fetchData();
  }

  Future<void> fetchData() async {
    try {
      // Retrieve current data from Firestore
      DocumentSnapshot documentSnapshot = await FirebaseFirestore.instance
          .collection('story') // Replace with your actual collection name
          .doc(widget.documentId)
          .get();

      // Display current data on the screen
      if (documentSnapshot.exists) {
        Map<String, dynamic> data = documentSnapshot.data() as Map<String, dynamic>;
        _titleController.text = data['title']; // Replace with your field names
        _descriptionController.text = data['description'];
        _selectedTeam = data['teamRef'];
      }
    } catch (e) {
      print('Error fetching data: $e');
    }
  }

  Future<void> updateData() async {
    try {
      // Update data in Firestore
      await FirebaseFirestore.instance
          .collection('story') // Replace with your actual collection name
          .doc(widget.documentId)
          .update({
        'title': _titleController.text,
        'description': _descriptionController.text,
        'teamRef': _selectedTeam,
      });

      // Navigate back to the previous screen after the update is complete
      Navigator.pop(context);
    } catch (e) {
      print('Error updating data: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Edit Page'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _titleController,
              decoration: InputDecoration(labelText: 'Edit Title'),
            ),
            SizedBox(height: 20),
            TextField(
              controller: _descriptionController,
              decoration: InputDecoration(labelText: 'Edit Description'),
            ),
            SizedBox(height: 20),
            DropdownButtonFormField<String>(
              value: _selectedTeam,
              onChanged: (String? value) {
                setState(() {
                  _selectedTeam = value;
                });
              },
              items: _teams.map((String team) {
                return DropdownMenuItem<String>(
                  value: team,
                  child: Text(team),
                );
              }).toList(),
              decoration: InputDecoration(
                labelText: 'Select Team',
              ),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                // Update the edited data
                updateData();
              },
              child: Text('Update Data'),
            ),
          ],
        ),
      ),
    );
  }
}
