import 'dart:collection';

import 'package:chat_app/api/firebase_api.dart';
import 'package:chat_app/model/message.dart';
import 'package:chat_app/model/user.dart';
import 'package:chat_app/screen/photo_screen.dart';
import 'package:chat_app/screen/user_profile_screen.dart';
import 'package:chat_app/utils/styles.dart';
import 'package:chat_app/utils/utils.dart';
import 'package:chat_app/widgets/copy_toast.dart';
import 'package:chat_app/widgets/dialogs/delete_dialog.dart';
import 'package:chat_app/widgets/dialogs/read_at_dialog.dart';
import 'package:chat_app/widgets/send_message.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:grouped_list/grouped_list.dart';
import 'package:intl/intl.dart';

class ChatScreen extends StatefulWidget {
  final ChatUser user;

  const ChatScreen({
    Key? key,
    required this.user,
  }) : super(key: key);

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final myId = FirebaseAuth.instance.currentUser!.uid;
  final dateFormat = DateFormat('HH:mm');
  HashSet<Message> selectedMessage = HashSet();
  bool isMultiSelectEnabled = false;
  FToast? fToast;

  @override
  void initState() {
    super.initState();
    fToast = FToast();
    fToast!.init(context);
  }

  @override
  Widget build(BuildContext context) {
    final mq = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: Styles.bodyColor,
      appBar: AppBar(
        backgroundColor: Styles.appBarColor,
        leading: isMultiSelectEnabled
            ? IconButton(
                onPressed: () {
                  selectedMessage.clear();
                  isMultiSelectEnabled = false;
                  setState(() {});
                },
                icon: Icon(Styles.clearIcon),
              )
            : null,
        title: isMultiSelectEnabled
            ? Utils.selectionCount(selectedMessage)
            : ListTile(
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) =>
                          UserProfileScreen(user: widget.user),
                    ),
                  );
                },
                title: Text(
                  widget.user.name,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: Styles.textColor,
                    fontSize: mq.width * 0.05,
                  ),
                ),
              ),
        actions: [
          Visibility(
            visible: selectedMessage.length == 1 &&
                selectedMessage.single.type == TypeMessage.text,
            child: IconButton(
              onPressed: () async {
                await Clipboard.setData(
                  ClipboardData(text: selectedMessage.single.text),
                ).then((value) {
                  fToast!.showToast(
                    gravity: ToastGravity.BOTTOM,
                    child: const CopyToast(),
                  );
                });
                selectedMessage.clear();
                isMultiSelectEnabled = false;
                setState(() {});
              },
              icon: Icon(Styles.copyIcon),
            ),
          ),
          Visibility(
            visible: selectedMessage.isNotEmpty,
            child: IconButton(
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (BuildContext context) =>
                      DeleteDialog(voidCallback: deleteMessage),
                );
              },
              icon: Icon(Styles.binIcon),
            ),
          ),
          Visibility(
            visible: selectedMessage.length == 1 &&
                selectedMessage.single.idFrom == myId,
            child: IconButton(
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (BuildContext context) => ReadAtDialog(
                    title: selectedMessage.single.type == TypeMessage.text
                        ? 'Read at:'
                        : 'Seen at:',
                    content: Utils.readTime(selectedMessage.single.readTime),
                  ),
                );
              },
              icon: Icon(Styles.infoIcon),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: StreamBuilder<List<Message>>(
                stream: FirebaseApi.getAllMessages(
                    FirebaseApi.groupId(widget.user.id)),
                builder: (context, snapshot) {
                  if (snapshot.hasData) {
                    FirebaseApi.updateMessageRead(
                        FirebaseApi.groupId(widget.user.id),
                        myId,
                        widget.user.id);
                    final messages = snapshot.data;

                    return messages!.isEmpty
                        ? const Text('')
                        : GroupedListView<Message, DateTime>(
                            physics: const BouncingScrollPhysics(),
                            elements: messages,
                            reverse: true,
                            order: GroupedListOrder.DESC,
                            useStickyGroupSeparators: true,
                            floatingHeader: true,
                            itemComparator: (message1, message2) =>
                                message1.date.compareTo(message2.date),
                            groupBy: (message) => DateTime(
                              message.date.year,
                              message.date.month,
                              message.date.day,
                            ),
                            groupHeaderBuilder: (Message message) => SizedBox(
                              height: mq.width * 0.14,
                              child: Center(
                                child: Card(
                                  color: Styles.black38Color,
                                  child: Padding(
                                    padding: EdgeInsets.all(mq.width * 0.015),
                                    child: Text(
                                      DateFormat.yMMMd().format(message.date),
                                      style: TextStyle(color: Styles.textColor),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            itemBuilder: (context, Message message) {
                              bool isMe = message.idFrom == myId;
                              return InkWell(
                                onTap: () {
                                  multiSelection(message);
                                },
                                onLongPress: () {
                                  isMultiSelectEnabled = true;
                                  multiSelection(message);
                                },
                                child: Container(
                                  padding: EdgeInsets.symmetric(
                                      horizontal: mq.width * 0.042),
                                  color: selectedMessage.contains(message)
                                      ? Styles.selectColor
                                      : null,
                                  child: Row(
                                    mainAxisAlignment: isMe
                                        ? MainAxisAlignment.end
                                        : MainAxisAlignment.start,
                                    children: [
                                      Container(
                                        padding: EdgeInsets.only(
                                          left: mq.width * 0.028,
                                          right: mq.width * 0.028,
                                          bottom: mq.width * 0.028,
                                          top: mq.width * 0.014,
                                        ),
                                        margin: EdgeInsets.symmetric(
                                            vertical: mq.width * 0.01),
                                        constraints: BoxConstraints(
                                            maxWidth: mq.width * 0.8),
                                        decoration: BoxDecoration(
                                          color: isMe
                                              ? Styles.primaryColor
                                              : Styles.fillColor,
                                          borderRadius: isMe
                                              ? BorderRadius.all(
                                                      Radius.circular(mq.width * 0.042))
                                                  .subtract(
                                            BorderRadius.only(
                                                    bottomRight:
                                                        Radius.circular(mq.width * 0.042),
                                                  ),
                                                )
                                              : BorderRadius.all(
                                                      Radius.circular(mq.width * 0.042))
                                                  .subtract(
                                            BorderRadius.only(
                                                    bottomLeft:
                                                        Radius.circular(mq.width * 0.042),
                                                  ),
                                                ),
                                        ),
                                        child: Stack(
                                          children: [
                                            Padding(
                                              padding: EdgeInsets.only(
                                                right: mq.width * 0.1,
                                              ),
                                              child: message.type ==
                                                      TypeMessage.text
                                                  ? Text(
                                                      message.text,
                                                      style: TextStyle(
                                                          fontSize: mq.width * 0.045,
                                                          color:
                                                              Styles.textColor,
                                                          height: mq.width * 0.00375),
                                                      textAlign:
                                                          TextAlign.start,
                                                    )
                                                  : TextButton(
                                                      onPressed: () {
                                                        Navigator.of(context)
                                                            .push(
                                                          MaterialPageRoute(
                                                            builder: (context) =>
                                                                PhotoScreen(
                                                                    name: '',
                                                                    url: message
                                                                        .text),
                                                          ),
                                                        );
                                                      },
                                                      child: Material(
                                                        child: Image.network(
                                                          message.text,
                                                          fit: BoxFit.cover,
                                                          height:
                                                              mq.width * 0.55,
                                                          width:
                                                              mq.width * 0.55,
                                                          errorBuilder: (
                                                            BuildContext
                                                                context,
                                                            Object exception,
                                                            StackTrace?
                                                                stackTrace,
                                                          ) {
                                                            return const Center(
                                                              child:
                                                                  CircularProgressIndicator(),
                                                            );
                                                          },
                                                          loadingBuilder:
                                                              (BuildContext
                                                                      context,
                                                                  Widget child,
                                                                  ImageChunkEvent?
                                                                      loadingProgress) {
                                                            if (loadingProgress ==
                                                                null) {
                                                              return child;
                                                            }
                                                            return SizedBox(
                                                              width: mq.width *
                                                                  0.55,
                                                              height: mq.width *
                                                                  0.55,
                                                              child: Center(
                                                                child:
                                                                    CircularProgressIndicator(
                                                                  color: Styles
                                                                      .primaryColor,
                                                                  value: loadingProgress
                                                                              .expectedTotalBytes !=
                                                                          null
                                                                      ? loadingProgress
                                                                              .cumulativeBytesLoaded /
                                                                          loadingProgress
                                                                              .expectedTotalBytes!
                                                                      : null,
                                                                ),
                                                              ),
                                                            );
                                                          },
                                                        ),
                                                      ),
                                                    ),
                                            ),
                                            Positioned(
                                              bottom: -mq.width * 0.008,
                                              right: 0,
                                              child: Text(
                                                dateFormat.format(message.date),
                                                style: TextStyle(
                                                    fontSize: mq.width * 0.033,
                                                    color: isMe
                                                        ? Styles.fillColor
                                                        : Styles.hintColor),
                                                textAlign: TextAlign.end,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          );
                  }
                  if (snapshot.hasError) {
                    return Center(
                      child: Text(
                        'Something Went Wrong Try later',
                        style: TextStyle(
                          color: Styles.textColor,
                          fontSize: 20,
                        ),
                      ),
                    );
                  } else {
                    return const Center(child: CircularProgressIndicator());
                  }
                },
              ),
            ),
            SendMessage(
              user: widget.user,
              groupId: FirebaseApi.groupId(widget.user.id),
            ),
          ],
        ),
      ),
    );
  }

  void multiSelection(Message message) {
    if (isMultiSelectEnabled) {
      if (selectedMessage.contains(message)) {
        selectedMessage.remove(message);
        if (selectedMessage.isEmpty) isMultiSelectEnabled = false;
      } else {
        selectedMessage.add(message);
      }
      setState(() {});
    }
  }

  void deleteMessage() {
    for (var message in selectedMessage) {
      FirebaseApi.deleteMessages(
        message,
        FirebaseApi.groupId(widget.user.id),
        widget.user.id,
      );
    }
    selectedMessage.clear();
    isMultiSelectEnabled = false;
    setState(() {});
    Navigator.pop(context);
  }
}
