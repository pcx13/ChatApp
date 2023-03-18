import 'package:chat_app/api/firebase_api.dart';
import 'package:chat_app/model/message.dart';
import 'package:chat_app/model/user.dart';
import 'package:chat_app/utils/styles.dart';
import 'package:chat_app/widgets/dialogs/profile_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:intl/intl.dart';

class UserCard extends StatefulWidget {
  final ChatUser user;
  final VoidCallback onTap;
  final VoidCallback onLongPress;

  const UserCard({
    Key? key,
    required this.user,
    required this.onTap,
    required this.onLongPress,
  }) : super(key: key);

  @override
  State<UserCard> createState() => _UserCardState();
}

class _UserCardState extends State<UserCard> {
  Message? _message;
  Duration difference = const Duration(seconds: 0);

  @override
  Widget build(BuildContext context) {
    final mq = MediaQuery.of(context).size;

    return StreamBuilder(
      stream: FirebaseApi.getLastMessages(FirebaseApi.groupId(widget.user.id)),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          final messages = snapshot.data!.toList();
          if (messages.isNotEmpty) _message = messages[0];

          return InkWell(
            onTap: widget.onTap,
            onLongPress: widget.onLongPress,
            child: Padding(
              padding: EdgeInsets.all(mq.width * 0.042),
              child: Row(
                children: <Widget>[
                  InkWell(
                    onTap: () {
                      showDialog(
                        context: context,
                        builder: (_) => ProfileDialog(user: widget.user),
                      );
                    },
                    child: Material(
                      shape: const StadiumBorder(),
                      clipBehavior: Clip.hardEdge,
                      child: Image.network(
                        widget.user.avatar,
                        fit: BoxFit.cover,
                        width: mq.width * 0.139,
                        height: mq.width * 0.139,
                        loadingBuilder: (BuildContext context, Widget child,
                            ImageChunkEvent? loadingProgress) {
                          if (loadingProgress == null) {
                            return child;
                          }
                          return SizedBox(
                            width: mq.width * 0.139,
                            height: mq.width * 0.139,
                            child: Center(
                              child: CircularProgressIndicator(
                                color: Styles.primaryColor,
                                value: loadingProgress.expectedTotalBytes !=
                                        null
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
                  Flexible(
                    child: Container(
                      margin: EdgeInsets.only(left: mq.width * 0.042),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Flexible(
                                child: Text(
                                  widget.user.name,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    color: Styles.textColor,
                                    fontSize: mq.width * 0.05,
                                  ),
                                ),
                              ),
                              _message != null
                                  ? _message!.idFrom == widget.user.id &&
                                          _message!.read == false
                                      ? Text(
                                          timelineFormat(_message!.date),
                                          style: TextStyle(
                                              color: Styles.newMsgColor),
                                        )
                                      : Text(
                                          timelineFormat(_message!.date),
                                          style: TextStyle(
                                              color: Styles.hintColor),
                                        )
                                  : const Text(''),
                            ],
                          ),
                          SizedBox(height: mq.width * 0.0139),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Flexible(
                                child: Text(
                                  _message != null
                                      ? _message!.type == TypeMessage.image
                                          ? '[ image ]'
                                          : _message!.text
                                      : widget.user.about,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(color: Styles.hintColor),
                                ),
                              ),
                              _message != null &&
                                      _message!.idFrom == widget.user.id &&
                                      _message!.read == false
                                  ? Container(
                                      margin: EdgeInsets.only(right: mq.width * 0.055),
                                      width: mq.width * 0.047,
                                      height: mq.width * 0.047,
                                      decoration: BoxDecoration(
                                        color: Styles.newMsgColor,
                                        borderRadius: BorderRadius.circular(mq.width),
                                      ),
                                    )
                                  : const SizedBox.shrink(),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        }
        if (snapshot.hasError) {
          return Center(
            child: Text(
              'Something Went Wrong Try later',
              style: TextStyle(
                color: Styles.textColor,
                fontSize: mq.width * 0.055,
              ),
            ),
          );
        } else {
          return const Center(child: CircularProgressIndicator());
        }
      },
    );
  }

  String timelineFormat(DateTime dateTime) {
    SchedulerBinding.instance.addPostFrameCallback((_) {
      setState(() {
        difference = DateTime.now().difference(dateTime);
      });
    });
    if (difference.inMinutes < 60) {
      return '${difference.inMinutes} min ago';
    } else if (difference.inHours < 2) {
      return '1 hour ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours} hours ago';
    } else if (difference.inDays < 30) {
      var dateFormat = DateFormat('dd MMM HH:mm');
      return dateFormat.format(dateTime);
    } else {
      var dateFormat = DateFormat('dd/MM/yyyy');
      return dateFormat.format(dateTime);
    }
  }
}
