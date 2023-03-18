import 'package:chat_app/api/firebase_api.dart';
import 'package:chat_app/model/user.dart';
import 'package:chat_app/screen/chat_screen.dart';
import 'package:chat_app/utils/custom_search_delegate.dart';
import 'package:chat_app/utils/styles.dart';
import 'package:chat_app/widgets/dialogs/profile_dialog.dart';
import 'package:flutter/material.dart';

class ContactsScreen extends StatelessWidget {
  const ContactsScreen({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final mq = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: Styles.bodyColor,
      appBar: AppBar(
        backgroundColor: Styles.appBarColor,
        title: const Text('Select Contact'),
        actions: [
          IconButton(
            onPressed: () {
              showSearch(
                context: context,
                delegate: CustomSearchDelegate(),
              );
            },
            icon: Icon(Styles.searchIcon),
          ),
        ],
      ),
      body: SafeArea(
        child: StreamBuilder<List<ChatUser>>(
          stream: FirebaseApi.getAllUsers(),
          builder: (context, snapshot) {
            switch (snapshot.connectionState) {
              case ConnectionState.waiting:
                return const Center(
                  child: CircularProgressIndicator(),
                );
              default:
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
                  final users = snapshot.data;
                  if (users!.isEmpty) {
                    return Center(
                      child: Text(
                        'No Profiles Found',
                        style: TextStyle(
                          color: Styles.textColor,
                          fontSize: mq.width * 0.055,
                        ),
                      ),
                    );
                  } else {
                    return ListView.builder(
                        physics: const BouncingScrollPhysics(),
                        itemCount: users.length,
                        itemBuilder: (context, index) {
                          final user = users[index];

                          return InkWell(
                            onTap: () {
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (context) => ChatScreen(user: user),
                                ),
                              );
                            },
                            child: Padding(
                              padding: EdgeInsets.all(mq.width * 0.042),
                              child: Row(
                                children: <Widget>[
                                  InkWell(
                                    onTap: () {
                                      showDialog(
                                        context: context,
                                        builder: (_) =>
                                            ProfileDialog(user: user),
                                      );
                                    },
                                    child: Material(
                                      shape: const StadiumBorder(),
                                      clipBehavior: Clip.hardEdge,
                                      child: Image.network(
                                        user.avatar,
                                        fit: BoxFit.cover,
                                        width: mq.width * 0.14,
                                        height: mq.width * 0.14,
                                        loadingBuilder: (BuildContext context,
                                            Widget child,
                                            ImageChunkEvent? loadingProgress) {
                                          if (loadingProgress == null) {
                                            return child;
                                          }
                                          return SizedBox(
                                            width: mq.width * 0.14,
                                            height: mq.width * 0.14,
                                            child: Center(
                                              child: CircularProgressIndicator(
                                                color: Styles.primaryColor,
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
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            user.name,
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                            style: TextStyle(
                                              color: Styles.textColor,
                                              fontSize: mq.width * 0.05,
                                            ),
                                          ),
                                          SizedBox(height: mq.width * 0.014),
                                          Text(
                                            user.about,
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                            style: TextStyle(
                                                color: Styles.hintColor),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        });
                  }
                }
            }
          },
        ),
      ),
    );
  }
}
