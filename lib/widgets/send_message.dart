import 'dart:io';

import 'package:chat_app/api/firebase_api.dart';
import 'package:chat_app/model/message.dart';
import 'package:chat_app/model/user.dart';
import 'package:chat_app/utils/styles.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:emoji_picker_flutter/emoji_picker_flutter.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:uuid/uuid.dart';

class SendMessage extends StatefulWidget {
  final ChatUser user;
  final String groupId;

  const SendMessage({
    Key? key,
    required this.user,
    required this.groupId,
  }) : super(key: key);

  @override
  State<SendMessage> createState() => _SendMessageState();
}

class _SendMessageState extends State<SendMessage> {
  ChatUser? me;
  final messageController = TextEditingController();
  UploadTask? uploadTask;
  bool _showEmoji = false;
  bool _isUploading = false;
  bool _isValid = false;

  @override
  void initState() {
    super.initState();
    getMyInfo();
    messageController.addListener(() {
      if (messageController.text.trim().isEmpty) {
        setState(() => _isValid = false);
      } else {
        setState(() => _isValid = true);
      }
    });
  }

  @override
  void dispose() {
    super.dispose();
    messageController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final mq = MediaQuery.of(context).size;

    return WillPopScope(
      onWillPop: () {
        if (_showEmoji) {
          setState(() => _showEmoji = !_showEmoji);
          return Future.value(false);
        } else {
          return Future.value(true);
        }
      },
      child: Column(
        children: [
          if (_isUploading)
            Align(
              alignment: Alignment.centerRight,
              child: Padding(
                padding: EdgeInsets.symmetric(
                  vertical: mq.width * 0.028,
                  horizontal: mq.width * 0.055,
                ),
                child: const CircularProgressIndicator(strokeWidth: 2),
              ),
            ),
          Padding(
            padding: EdgeInsets.all(mq.width * 0.0139),
            child: Row(
              children: [
                GestureDetector(
                  onTap: selectImage,
                  child: Container(
                    width: mq.width * 0.13,
                    height: mq.width * 0.13,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Styles.fillColor,
                    ),
                    child: Icon(
                      Styles.galleryIcon,
                      color: Styles.textColor,
                      size: mq.width * 0.07,
                    ),
                  ),
                ),
                SizedBox(width: mq.width * 0.0139),
                Expanded(
                  child: TextField(
                    controller: messageController,
                    textCapitalization: TextCapitalization.sentences,
                    textAlignVertical: TextAlignVertical.center,
                    autocorrect: true,
                    enableSuggestions: true,
                    keyboardType: TextInputType.multiline,
                    minLines: 1,
                    maxLines: 5,
                    style: TextStyle(
                      color: Styles.textColor,
                      fontSize: mq.width * 0.05,
                    ),
                    decoration: InputDecoration(
                      hintText: 'Message',
                      hintStyle: TextStyle(
                        color: Styles.hintColor,
                      ),
                      filled: true,
                      fillColor: Styles.fillColor,
                      isDense: true,
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: mq.width * 0.05,
                        vertical: mq.width * 0.03,
                      ),
                      border: OutlineInputBorder(
                        borderSide: BorderSide.none,
                        borderRadius: BorderRadius.circular(mq.width * 0.1),
                      ),
                      prefixIcon: GestureDetector(
                        onTap: () {
                          FocusScope.of(context).unfocus();
                          setState(() => _showEmoji = !_showEmoji);
                        },
                        child: Icon(
                          Styles.emojiIcon,
                          color: Styles.textColor,
                          size: mq.width * 0.07,
                        ),
                      ),
                    ),
                    onTap: () {
                      if (_showEmoji) setState(() => _showEmoji = !_showEmoji);
                    },
                  ),
                ),
                SizedBox(width: mq.width * 0.0139),
                GestureDetector(
                  onTap: _isValid
                      ? () async {
                          await FirebaseApi.uploadMessage(
                            me!,
                            widget.user,
                            widget.groupId,
                            messageController.text.trim(),
                            TypeMessage.text,
                          );
                          setState(() => messageController.clear());
                        }
                      : null,
                  child: Container(
                    width: mq.width * 0.13,
                    height: mq.width * 0.13,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: _isValid ? Styles.primaryColor : Styles.fillColor,
                    ),
                    child: Icon(
                      Styles.sendIcon,
                      color: _isValid ? Styles.textColor : Styles.hintColor,
                      size: mq.width * 0.07,
                    ),
                  ),
                ),
              ],
            ),
          ),
          if (_showEmoji)
            SizedBox(
              height: MediaQuery.of(context).size.height * 0.3,
              child: EmojiPicker(
                textEditingController: messageController,
                config: Config(
                  columns: 7,
                  emojiSizeMax: 32 * (Platform.isIOS ? 1.30 : 1.0),
                  bgColor: Styles.bodyColor,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Future getMyInfo() async {
    final myId = FirebaseAuth.instance.currentUser!.uid;
    await FirebaseFirestore.instance.collection('Users').doc(myId).get().then(
          (value) => setState(() => me = ChatUser.fromJson(value.data()!)),
        );
  }

  Future selectImage() async {
    final file = await ImagePicker().pickMultiImage();
    final fileId = const Uuid().v4();
    final reference = FirebaseStorage.instance.ref().child('sent');
    final imageToUpload = reference.child(fileId);
    for (var i in file) {
      final image = File(i.path);
      setState(() => _isUploading = true);
      setState(() {
        uploadTask = imageToUpload.putFile(File(image.path));
      });
      final snapshot = await uploadTask!.whenComplete(() {});
      final url = await snapshot.ref.getDownloadURL();
      await FirebaseApi.uploadMessage(
        me!,
        widget.user,
        widget.groupId,
        url,
        TypeMessage.image,
      );
      setState(() => uploadTask = null);
      setState(() => _isUploading = false);
    }
  }
}
