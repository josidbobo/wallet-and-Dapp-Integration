import 'package:flutter/material.dart';

class EventWidget extends StatelessWidget {
  const EventWidget({
    super.key,
    required this.title,
    required this.content,
  });

  final String title;
  final String content;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(
        title,
        
      ),
      content: Text(content),
      actions: [
        TextButton(
          child: const Text(
            ""
          ),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
      ],
    );
  }
}