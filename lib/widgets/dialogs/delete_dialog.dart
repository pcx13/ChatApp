import 'package:chat_app/utils/styles.dart';
import 'package:flutter/material.dart';

class DeleteDialog extends StatelessWidget {
  final VoidCallback voidCallback;

  const DeleteDialog({Key? key, required this.voidCallback}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final mq = MediaQuery.of(context).size;

    return AlertDialog(
      backgroundColor: Styles.bodyColor,
      title: Text(
        'All selected items will be deleted',
        style: TextStyle(color: Styles.textColor),
      ),
      actions: [
        MaterialButton(
          onPressed: () {
            Navigator.pop(context);
          },
          child: Text(
            'Cancel',
            style: TextStyle(
              fontSize: mq.width * 0.042,
              color: Styles.snackBarColor,
            ),
          ),
        ),
        MaterialButton(
          onPressed: voidCallback,
          child: Text(
            'Delete',
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
