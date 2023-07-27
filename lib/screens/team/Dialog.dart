import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class EventInputDialog extends StatelessWidget {
  final Function(String) onSave;

  EventInputDialog({required this.onSave});

  @override
  Widget build(BuildContext context) {
    final controller = TextEditingController();

    return AlertDialog(
      title: Text('New event'),
      content: TextField(
        controller: controller,
        decoration: InputDecoration(hintText: 'Event title'),
      ),
      actions: <Widget>[
        TextButton(
          child: Text('Cancel'),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        TextButton(
          child: Text('Save'),
          onPressed: () {
            final title = controller.text;
            if (title.isNotEmpty) {
              onSave(title);
              Navigator.of(context).pop();
            }
          },
        ),
      ],
    );
  }
}
