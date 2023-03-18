import 'package:chat_app/utils/styles.dart';
import 'package:flutter/material.dart';

class CopyToast extends StatelessWidget {
  const CopyToast({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final mq = MediaQuery.of(context).size;

    return Container(
      padding: EdgeInsets.all(mq.width * 0.033),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(mq.width),
        color: Styles.black87Color,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            height: mq.width * 0.04,
            width: mq.width * 0.04,
            child: Image.asset('assets/app_logo.png'),
          ),
          SizedBox(width: mq.width * 0.033),
          Text(
            'Message copied',
            style: TextStyle(
              color: Styles.textColor,
              fontSize: mq.width * 0.04,
            ),
          ),
        ],
      ),
    );
  }
}
