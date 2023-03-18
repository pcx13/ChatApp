import 'package:chat_app/api/firebase_api.dart';
import 'package:chat_app/model/user.dart';
import 'package:chat_app/screen/chat_screen.dart';
import 'package:chat_app/utils/styles.dart';
import 'package:flutter/material.dart';

class CustomSearchDelegate extends SearchDelegate {
  @override
  ThemeData appBarTheme(BuildContext context) {
    final mq = MediaQuery.of(context).size;

    return ThemeData(
      scaffoldBackgroundColor: Styles.bodyColor,
      hintColor: Styles.hintColor,
      inputDecorationTheme:
          const InputDecorationTheme(border: InputBorder.none),
      textTheme: TextTheme(
        titleLarge: TextStyle(
          color: Styles.textColor,
          fontSize: mq.width * 0.047,
        ),
        titleMedium: TextStyle(
          color: Styles.textColor,
          fontSize: mq.width * 0.047,
        ),
      ),
      appBarTheme: AppBarTheme(
        color: Styles.appBarColor,
      ),
    );
  }

  @override
  List<Widget>? buildActions(BuildContext context) {
    return [
      IconButton(
        onPressed: () => query = '',
        icon: Icon(Styles.clearIcon),
      ),
    ];
  }

  @override
  Widget? buildLeading(BuildContext context) {
    return IconButton(
      onPressed: () => close(context, null),
      icon: Icon(Styles.backIcon),
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    final mq = MediaQuery.of(context).size;

    return StreamBuilder<List<ChatUser>>(
      stream: FirebaseApi.getAllUsers(),
      builder: (context, snapshot) {
        switch (snapshot.connectionState) {
          case ConnectionState.waiting:
            return const Center(child: CircularProgressIndicator());
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
                    'No Users Found',
                    style: TextStyle(
                      color: Styles.textColor,
                      fontSize: mq.width * 0.055,
                    ),
                  ),
                );
              } else {
                if (users
                    .where((element) => element.name
                        .toString()
                        .toLowerCase()
                        .contains(query.toLowerCase()))
                    .isEmpty) {
                  return Center(
                    child: Text(
                      'No search query found',
                      style: TextStyle(
                        color: Styles.textColor,
                        fontSize: mq.width * 0.055,
                      ),
                    ),
                  );
                }

                return ListView(
                  children: [
                    ...users
                        .where((element) => element.name
                            .toString()
                            .toLowerCase()
                            .contains(query.toLowerCase()))
                        .map((data) {
                      return ListTile(
                        contentPadding: EdgeInsets.all(mq.width * 0.042),
                        onTap: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (context) => ChatScreen(user: data),
                            ),
                          );
                        },
                        leading: Material(
                          borderRadius:
                          BorderRadius.all(Radius.circular(mq.width * 0.07)),
                          clipBehavior: Clip.hardEdge,
                          child: Image.network(
                            data.avatar,
                            fit: BoxFit.cover,
                            width: 50,
                            height: 50,
                            loadingBuilder: (BuildContext context, Widget child,
                                ImageChunkEvent? loadingProgress) {
                              if (loadingProgress == null) return child;
                              return SizedBox(
                                width: mq.width * 0.139,
                                height: mq.width * 0.139,
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
                        title: Text(
                          data.name,
                          style: TextStyle(
                            color: Styles.textColor,
                            fontSize: mq.width * 0.05,
                          ),
                        ),
                      );
                    })
                  ],
                );
              }
            }
        }
      },
    );
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    return const Text('');
  }
}
