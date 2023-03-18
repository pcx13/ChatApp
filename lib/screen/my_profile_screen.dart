import 'dart:io';

import 'package:chat_app/screen/photo_screen.dart';
import 'package:chat_app/utils/styles.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:uuid/uuid.dart';

class MyProfileScreen extends StatefulWidget {
  const MyProfileScreen({Key? key}) : super(key: key);

  @override
  State<MyProfileScreen> createState() => _MyProfileScreenState();
}

class _MyProfileScreenState extends State<MyProfileScreen> {
  final myId = FirebaseAuth.instance.currentUser!.uid;
  final email = FirebaseAuth.instance.currentUser!.email!;
  TextEditingController? nameController;
  TextEditingController? statusController;
  File? image;
  UploadTask? uploadTask;
  String name = '';
  String status = '';
  String url = '';

  @override
  void initState() {
    super.initState();
    getMyInfo().then((value) {
      nameController = TextEditingController(text: name);
      statusController = TextEditingController(text: status);
    });
  }

  @override
  void dispose() {
    statusController!.dispose();
    nameController!.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final mq = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: Styles.bodyColor,
      appBar: AppBar(
        backgroundColor: Styles.appBarColor,
        title: const Text('My Profile'),
        actions: [
          IconButton(
            onPressed: () async {
              await editProfile();
              if (context.mounted) Navigator.of(context).pop();
            },
            icon: Icon(Styles.checkIcon),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(mq.width * 0.042),
        child: Column(
          children: [
            SizedBox(height: mq.width * 0.028),
            Stack(
              children: [
                InkWell(
                  splashColor: Colors.transparent,
                  highlightColor: Colors.transparent,
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => PhotoScreen(
                          name: name,
                          url: url,
                        ),
                      ),
                    );
                  },
                  child: Material(
                    borderRadius: BorderRadius.circular(mq.width),
                    clipBehavior: Clip.hardEdge,
                    child: image != null
                        ? Image.file(
                            File(image!.path),
                            fit: BoxFit.cover,
                            height: mq.width * 0.55,
                            width: mq.width * 0.55,
                            errorBuilder: (
                              BuildContext context,
                              Object exception,
                              StackTrace? stackTrace,
                            ) {
                              return const Center(
                                child: CircularProgressIndicator(),
                              );
                            },
                          )
                        : Image.network(
                            url,
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
                                    value: loadingProgress.expectedTotalBytes !=
                                            null
                                        ? loadingProgress
                                                .cumulativeBytesLoaded /
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
                Positioned(
                  right: mq.width * 0.03,
                  bottom: mq.width * 0.03,
                  child: Container(
                    height: mq.width * 0.11,
                    width: mq.width * 0.11,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Styles.fillColor,
                    ),
                    child: IconButton(
                      onPressed: selectImage,
                      icon: Icon(
                        Styles.editIcon,
                        color: Styles.primaryColor,
                        size: mq.width * 0.07,
                      ),
                      highlightColor: Colors.transparent,
                      splashColor: Colors.transparent,
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: mq.width * 0.055),
            Text(
              email,
              style: TextStyle(color: Styles.hintColor),
            ),
            SizedBox(height: mq.width * 0.11),
            TextField(
              controller: nameController,
              inputFormatters: [LengthLimitingTextInputFormatter(30)],
              textInputAction: TextInputAction.next,
              style: TextStyle(
                color: Styles.textColor,
                fontSize: mq.width * 0.047,
              ),
              decoration: InputDecoration(
                hintText: 'Name',
                hintStyle: TextStyle(
                  color: Styles.hintColor,
                ),
                border: InputBorder.none,
                prefixIcon: Icon(
                  Styles.profileIcon,
                  color: Styles.primaryColor,
                ),
              ),
            ),
            Divider(height: 1.5, color: Styles.hintColor),
            SizedBox(height: mq.width * 0.042),
            TextField(
              controller: statusController,
              inputFormatters: [LengthLimitingTextInputFormatter(200)],
              textInputAction: TextInputAction.done,
              style: TextStyle(
                color: Styles.textColor,
                fontSize: mq.width * 0.047,
              ),
              decoration: InputDecoration(
                hintText: 'Status',
                hintStyle: TextStyle(
                  color: Styles.hintColor,
                ),
                border: InputBorder.none,
                prefixIcon: Icon(
                  Styles.infoIcon,
                  color: Styles.primaryColor,
                ),
              ),
            ),
            Divider(height: 1.5, color: Styles.hintColor),
            SizedBox(height: mq.width * 0.083),
            StreamBuilder<TaskSnapshot>(
                stream: uploadTask?.snapshotEvents,
                builder: (context, snapshot) {
                  if (snapshot.hasData) {
                    final data = snapshot.data!;
                    double progress = data.bytesTransferred / data.totalBytes;
                    return SizedBox(
                      height: 0.139,
                      child: Stack(
                        fit: StackFit.expand,
                        children: [
                          LinearProgressIndicator(
                            value: progress,
                            backgroundColor: Styles.fillColor,
                            color: Styles.progressColor,
                          ),
                          Center(
                            child: Text(
                              '${(100 * progress).roundToDouble()}%',
                              style: TextStyle(color: Styles.textColor),
                            ),
                          ),
                        ],
                      ),
                    );
                  } else {
                    return const SizedBox.shrink();
                  }
                }),
          ],
        ),
      ),
    );
  }

  Future getMyInfo() async {
    await FirebaseFirestore.instance
        .collection('Users')
        .doc(myId)
        .get()
        .then((value) {
      setState(() {
        name = value.data()!['name'];
        status = value.data()!['about'];
        url = value.data()!['avatar'];
      });
    });
  }

  Future selectImage() async {
    final file = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (file == null) return;
    final imageTemp = File(file.path);
    setState(() {
      image = imageTemp;
    });
  }

  Future editProfile() async {
    final fileId = const Uuid().v4();
    final reference = FirebaseStorage.instance.ref().child('profiles');
    final imageToUpload = reference.child(fileId);
    final docUser = FirebaseFirestore.instance.collection('Users').doc(myId);

    if (nameController!.text.trim().isNotEmpty) {
      await docUser.update({'name': nameController!.text.trim()});
    }

    if (statusController!.text.trim().isNotEmpty) {
      await docUser.update({'about': statusController!.text});
    }

    if (image != null) {
      final defaultUrl = await reference.child('profile.png').getDownloadURL();

      if (url != defaultUrl) {
        await FirebaseStorage.instance.refFromURL(url).delete();
      }
      setState(() {
        uploadTask = imageToUpload.putFile(File(image!.path));
      });
      final snapshot = await uploadTask!.whenComplete(() {});
      final profile = await snapshot.ref.getDownloadURL();
      await docUser.update({'avatar': profile});
      setState(() {
        uploadTask = null;
      });
    }
  }
}
