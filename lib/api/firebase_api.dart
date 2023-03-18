import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:chat_app/model/message.dart';
import 'package:chat_app/model/user.dart';
import 'package:chat_app/utils/utils.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:http/http.dart';
import 'package:uuid/uuid.dart';

class FirebaseApi {
  static String groupId(String id) {
    final myId = FirebaseAuth.instance.currentUser!.uid;
    if (myId.compareTo(id) > 0) {
      return '$myId-$id';
    } else {
      return '$id-$myId';
    }
  }

  static Future createUser(String email) async {
    final myId = FirebaseAuth.instance.currentUser!.uid;
    Reference refRoot = FirebaseStorage.instance.ref().child('profiles');
    final imageUrl = await refRoot.child('profile.png').getDownloadURL();

    final chatUser = ChatUser(
      id: myId,
      name: email,
      avatar: imageUrl,
      about: 'Hi! I\'m new here.',
      pushToken: '',
    );

    final refUser = FirebaseFirestore.instance.collection('Users').doc(myId);
    await refUser.set(chatUser.toJson());
  }

  static Stream<List<ChatUser>> getAllUsers() {
    final user = FirebaseAuth.instance.currentUser!;
    return FirebaseFirestore.instance
        .collection('Users')
        .where('id', isNotEqualTo: user.uid)
        .snapshots()
        .transform(Utils.transformer(ChatUser.fromJson));
  }

  static Stream<QuerySnapshot<Map<String, dynamic>>> getMyUsersId() {
    final user = FirebaseAuth.instance.currentUser!;
    return FirebaseFirestore.instance
        .collection('Users')
        .doc(user.uid)
        .collection('MyUsers')
        .snapshots();
  }

  static Stream<List<ChatUser>> getMyUsers(List<String> ids) {
    return FirebaseFirestore.instance
        .collection('Users')
        .where('id', whereIn: ids.isEmpty ? [''] : ids)
        .snapshots()
        .transform(Utils.transformer(ChatUser.fromJson));
  }

  static Future addChatUser(ChatUser me, ChatUser chatUser) async {
    final myRef = FirebaseFirestore.instance
        .collection('Users')
        .doc(me.id)
        .collection('MyUsers')
        .doc(chatUser.id);

    final userRef = FirebaseFirestore.instance
        .collection('Users')
        .doc(chatUser.id)
        .collection('MyUsers')
        .doc(me.id);

    final meExists = await myRef.get().then((value) => value.exists);
    final userExists = await userRef.get().then((value) => value.exists);

    if (meExists && userExists) {
      return;
    } else {
      myRef.set({});
      userRef.set({});
    }
  }

  static Future deleteChatUser(String userId, String groupId) async {
    final user = FirebaseAuth.instance.currentUser!;

    await FirebaseFirestore.instance
        .collection('Users')
        .doc(user.uid)
        .collection('MyUsers')
        .doc(userId)
        .delete();

    final batch = FirebaseFirestore.instance.batch();

    var snapshot = await FirebaseFirestore.instance
        .collection('Chats')
        .doc(groupId)
        .collection(user.uid)
        .get();

    for (var doc in snapshot.docs) {
      batch.delete(doc.reference);
    }
    await batch.commit();
  }

  static Future uploadMessage(ChatUser me, ChatUser chatUser, String groupId,
      String message, int type) async {
    final messageId = const Uuid().v4();
    final myRefMessages = FirebaseFirestore.instance
        .collection('Chats')
        .doc(groupId)
        .collection(me.id)
        .doc(messageId);

    final userRefMessages = FirebaseFirestore.instance
        .collection('Chats')
        .doc(groupId)
        .collection(chatUser.id)
        .doc(messageId);

    final newMessage = Message(
      id: messageId,
      idFrom: me.id,
      idTo: chatUser.id,
      text: message,
      date: DateTime.now(),
      readTime: '',
      read: false,
      type: type,
    );

    await myRefMessages.set(newMessage.toJson()).then((value) async {
      await userRefMessages.set(newMessage.toJson());
      addChatUser(me, chatUser);
      sendPushNotification(
        me,
        chatUser,
        type == TypeMessage.text ? message : '[ image ]',
      );
    });
  }

  static Stream<List<Message>> getAllMessages(String groupId) {
    final user = FirebaseAuth.instance.currentUser!;
    return FirebaseFirestore.instance
        .collection('Chats')
        .doc(groupId)
        .collection(user.uid)
        .orderBy(MessageField.date, descending: true)
        .snapshots()
        .transform(Utils.transformer(Message.fromJson));
  }

  static Stream<List<Message>> getLastMessages(String groupId) {
    final user = FirebaseAuth.instance.currentUser!;
    return FirebaseFirestore.instance
        .collection('Chats')
        .doc(groupId)
        .collection(user.uid)
        .orderBy(MessageField.date, descending: true)
        .limit(1)
        .snapshots()
        .transform(Utils.transformer(Message.fromJson));
  }

  static Future updateMessageRead(
      String groupId, String myId, String userId) async {
    final now = DateTime.now().millisecondsSinceEpoch.toString();

    await FirebaseFirestore.instance
        .collection('Chats')
        .doc(groupId)
        .collection(userId)
        .where('idTo', isEqualTo: myId)
        .where('read', isEqualTo: false)
        .get()
        .then((query) async {
      for (var doc in query.docs) {
        await doc.reference.update({'readTime': now, 'read': true});
      }
    });

    await FirebaseFirestore.instance
        .collection('Chats')
        .doc(groupId)
        .collection(myId)
        .where('idTo', isEqualTo: myId)
        .where('read', isEqualTo: false)
        .get()
        .then((query) async {
      for (var doc in query.docs) {
        await doc.reference.update({'readTime': now, 'read': true});
      }
    });
  }

  static Future deleteMessages(
      Message message, String groupId, String id) async {
    final user = FirebaseAuth.instance.currentUser!;
    await FirebaseFirestore.instance
        .collection('Chats')
        .doc(groupId)
        .collection(user.uid)
        .doc(message.id)
        .delete();

    await FirebaseFirestore.instance
        .collection('Chats')
        .doc(groupId)
        .collection(id)
        .where('id', isEqualTo: message.id)
        .where('idFrom', isEqualTo: user.uid)
        .where('read', isEqualTo: false)
        .get()
        .then((value) {
      value.docs.first.reference.delete();
    });

    if (message.type == TypeMessage.image &&
        message.idFrom == user.uid &&
        message.read == false) {
      await FirebaseStorage.instance.refFromURL(message.text).delete();
    }
  }

  static Future getToken() async {
    final myId = FirebaseAuth.instance.currentUser!.uid;
    final token = await FirebaseMessaging.instance.getToken();
    await FirebaseFirestore.instance
        .collection('Users')
        .doc(myId)
        .update({'pushToken': token});

    await FirebaseMessaging.instance.requestPermission(
      alert: true,
      sound: true,
      badge: true,
      announcement: false,
      carPlay: false,
      criticalAlert: false,
      provisional: false,
    );
  }

  static Future sendPushNotification(
      ChatUser me, ChatUser chatUser, String message) async {
    try {
      final body = {
        "to": chatUser.pushToken,
        "notification": {
          "title": me.name,
          "body": message,
          "android_channel_id": "chats",
        },
        "data": {"some_data": "User ID: ${me.id}"},
      };
      await post(
        Uri.parse('https://fcm.googleapis.com/fcm/send'),
        headers: {
          HttpHeaders.contentTypeHeader: 'application/json',
          HttpHeaders.authorizationHeader:
              'key=AAAAGsw24kM:APA91bGpT4tN9Er40QiLoAUlzuH-Lql_LL6o58334Eu6MYY9po4FNbDDrMCIqhGg4Wu238xo853Xevaftf5M3Usf6TfzVrhAud3c6PsKbJZd5UawdZVzbr0R9Mg7BLl4TFewnbPwzr17',
        },
        body: jsonEncode(body),
      );
    } catch (e) {
      log(e.toString());
    }
  }
}
