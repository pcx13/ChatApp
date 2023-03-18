import 'package:chat_app/model/user.dart';
import 'package:chat_app/screen/photo_screen.dart';
import 'package:chat_app/utils/styles.dart';
import 'package:flutter/material.dart';

class UserProfileScreen extends StatefulWidget {
  final ChatUser user;

  const UserProfileScreen({Key? key, required this.user}) : super(key: key);

  @override
  State<UserProfileScreen> createState() => _UserProfileScreenState();
}

class _UserProfileScreenState extends State<UserProfileScreen> {
  @override
  Widget build(BuildContext context) {
    final mq = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: Styles.bodyColor,
      appBar: AppBar(
        backgroundColor: Styles.appBarColor,
        title: Text(widget.user.name),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(mq.width * 0.042),
        child: Center(
          child: Column(
            children: [
              SizedBox(height: mq.width * 0.083),
              TextButton(
                style: ButtonStyle(
                  overlayColor: MaterialStateProperty.all(Colors.transparent),
                ),
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => PhotoScreen(
                        name: widget.user.name,
                        url: widget.user.avatar,
                      ),
                    ),
                  );
                },
                child: Material(
                  borderRadius: BorderRadius.circular(mq.width),
                  clipBehavior: Clip.hardEdge,
                  child: Image.network(
                    widget.user.avatar,
                    fit: BoxFit.cover,
                    height: mq.width * 0.55,
                    width: mq.width * 0.55,
                    loadingBuilder: (BuildContext context, Widget child,
                        ImageChunkEvent? loadingProgress) {
                      if (loadingProgress == null) return child;
                      return SizedBox(
                        width: mq.width * 0.55,
                        height: mq.width * 0.55,
                        child: Center(
                          child: CircularProgressIndicator(
                            color: Styles.primaryColor,
                            value: loadingProgress.expectedTotalBytes != null
                                ? loadingProgress.cumulativeBytesLoaded /
                                    loadingProgress.expectedTotalBytes!
                                : null,
                          ),
                        ),
                      );
                    },
                    errorBuilder: (
                      BuildContext context,
                      Object exception,
                      StackTrace? stackTrace,
                    ) {
                      return const Center(
                        child: CircularProgressIndicator(),
                      );
                    },
                  ),
                ),
              ),
              SizedBox(height: mq.width * 0.139),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Styles.infoIcon,
                    color: Styles.primaryColor,
                  ),
                  SizedBox(width: mq.width * 0.028),
                  Flexible(
                    child: Text(
                      widget.user.about,
                      maxLines: null,
                      style: TextStyle(
                        fontSize: mq.width * 0.05,
                        color: Styles.textColor,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
