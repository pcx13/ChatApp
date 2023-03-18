import 'package:chat_app/utils/styles.dart';
import 'package:flutter/material.dart';

class ReadAtDialog extends StatelessWidget {
  final String title;
  final String content;

  const ReadAtDialog({Key? key, required this.title, required this.content})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    final mq = MediaQuery.of(context).size;

    return AlertDialog(
      backgroundColor: Styles.bodyColor,
      title: Text(
        title,
        style: TextStyle(color: Styles.hintColor),
      ),
      content: Text(
        content,
        style: TextStyle(color: Styles.textColor),
      ),
      actions: [
        MaterialButton(
          onPressed: () {
            Navigator.pop(context);
          },
          child: Text(
            'Ok',
            style: TextStyle(
              fontSize: mq.width * 0.042,
              color: Styles.snackBarColor,
            ),
          ),
        ),
      ],
    );
  }
}
