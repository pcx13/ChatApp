import 'package:chat_app/model/user.dart';
import 'package:chat_app/screen/photo_screen.dart';
import 'package:chat_app/screen/user_profile_screen.dart';
import 'package:chat_app/utils/styles.dart';
import 'package:flutter/material.dart';

class ProfileDialog extends StatelessWidget {
  final ChatUser user;

  const ProfileDialog({Key? key, required this.user}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final mq = MediaQuery.of(context).size;

    return AlertDialog(
      contentPadding: EdgeInsets.zero,
      backgroundColor: Styles.bodyColor,
      content: SizedBox(
        height: mq.width * 0.75,
        width: mq.width * 0.75,
        child: Stack(
          children: [
            Align(
              alignment: Alignment.center,
              child: InkWell(
                splashColor: Colors.transparent,
                highlightColor: Colors.transparent,
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => PhotoScreen(
                        name: user.name,
                        url: user.avatar,
                      ),
                    ),
                  );
                },
                child: Material(
                  shape: const StadiumBorder(),
                  clipBehavior: Clip.hardEdge,
                  child: Image.network(
                    user.avatar,
                    width: mq.width * 0.55,
                    height: mq.width * 0.55,
                    fit: BoxFit.cover,
                    loadingBuilder: (BuildContext context, Widget child,
                        ImageChunkEvent? loadingProgress) {
                      if (loadingProgress == null) {
                        return child;
                      }
                      return SizedBox(
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
            ),
            Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: Styles.black38Color,
              ),
              child: Padding(
                padding: EdgeInsets.all(mq.width * 0.028),
                child: Text(
                  user.name,
                  style: TextStyle(
                    fontSize: mq.width * 0.05,
                    color: Styles.textColor,
                  ),
                ),
              ),
            ),
            Positioned(
              right: mq.width * 0.02,
              bottom: mq.width * 0.02,
              child: IconButton(
                onPressed: () {
                  Navigator.pop(context);
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => UserProfileScreen(user: user),
                    ),
                  );
                },
                icon: Icon(
                  Styles.infoIcon,
                  color: Styles.primaryColor,
                  size: mq.width * 0.08,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
