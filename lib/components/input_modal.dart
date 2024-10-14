import 'package:flutter/material.dart';

Future<String?> showInputModal(BuildContext context) {
  final TextEditingController controller = TextEditingController();

  return showDialog<String>(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: const Text('Input Modal'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(hintText: 'Enter something...'),
        ),
        actions: <Widget>[
          TextButton(
            onPressed: () {
              Navigator.of(context).pop(); // Close the dialog
            },
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop(controller.text); // Pass the input text
            },
            child: const Text('OK'),
          ),
        ],
      );
    },
  );
}
