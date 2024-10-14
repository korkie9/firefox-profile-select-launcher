import 'package:flutter/material.dart';

typedef StringCallback = void Function(String);

class LongButtonList extends StatelessWidget {
  final List<String> users;
  final StringCallback onLongButtonPressed;
  final int activeButtonIndex;
  const LongButtonList(
      {super.key,
      required this.users,
      required this.onLongButtonPressed,
      required this.activeButtonIndex});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.all(8),
      itemCount: users.length,
      itemBuilder: (context, index) {
        return Container(
          margin: const EdgeInsets.symmetric(vertical: 8),
          width: double.infinity,
          child: ElevatedButton(
            onPressed: () {
              onLongButtonPressed(users[index]);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor:
                  activeButtonIndex == index ? Colors.cyan : Colors.grey,
              padding:
                  const EdgeInsets.symmetric(vertical: 16), // Adjusts height
            ),
            child: Text(users[index]),
          ),
        );
      },
    );
  }
}
