import 'dart:collection';

import 'package:chat_app/api/firebase_api.dart';
import 'package:chat_app/model/user.dart';
import 'package:chat_app/screen/chat_screen.dart';
import 'package:chat_app/screen/contacts_screen.dart';
import 'package:chat_app/screen/my_profile_screen.dart';
import 'package:chat_app/utils/custom_search_delegate.dart';
import 'package:chat_app/utils/styles.dart';
import 'package:chat_app/utils/utils.dart';
import 'package:chat_app/widgets/dialogs/delete_dialog.dart';
import 'package:chat_app/widgets/user_card.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  HashSet<ChatUser> selectedUser = HashSet();
  bool isMultiSelectEnabled = false;

  @override
  void initState() {
    super.initState();
    FirebaseApi.getToken();
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
                  selectedUser.clear();
                  isMultiSelectEnabled = false;
                  setState(() {});
                },
                icon: Icon(Styles.clearIcon),
              )
            : null,
        title: isMultiSelectEnabled
            ? Utils.selectionCount(selectedUser)
            : const Text('Chat'),
        actions: [
          Visibility(
            visible: selectedUser.isNotEmpty,
            child: IconButton(
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (BuildContext context) =>
                      DeleteDialog(voidCallback: deleteUser),
                );
              },
              icon: Icon(Styles.binIcon),
            ),
          ),
          Visibility(
            visible: !isMultiSelectEnabled,
            child: IconButton(
              onPressed: () {
                showSearch(
                  context: context,
                  delegate: CustomSearchDelegate(),
                );
              },
              icon: Icon(Styles.searchIcon),
            ),
          ),
          Visibility(
            visible: !isMultiSelectEnabled,
            child: PopupMenuButton(
              color: Styles.bodyColor,
              icon: Icon(
                Styles.popUpIcon,
                color: Styles.textColor,
              ),
              itemBuilder: (context) => [
                PopupMenuItem(
                  value: 0,
                  child: Text(
                    'Profile',
                    style: TextStyle(color: Styles.textColor),
                  ),
                ),
                PopupMenuItem(
                  value: 1,
                  child: Text(
                    'Log out',
                    style: TextStyle(color: Styles.textColor),
                  ),
                ),
              ],
              onSelected: (value) {
                if (value == 0) {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => const MyProfileScreen(),
                    ),
                  );
                }
                if (value == 1) {
                  FirebaseAuth.instance.signOut();
                }
              },
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: StreamBuilder(
            stream: FirebaseApi.getMyUsersId(),
            builder: (context, snapshot1) {
              switch (snapshot1.connectionState) {
                case ConnectionState.waiting:
                case ConnectionState.none:
                  return const Center(child: CircularProgressIndicator());
                case ConnectionState.active:
                case ConnectionState.done:
                  return StreamBuilder(
                    stream: FirebaseApi.getMyUsers(
                        snapshot1.data?.docs.map((e) => e.id).toList() ?? []),
                    builder: (context, snapshot) {
                      switch (snapshot1.connectionState) {
                        case ConnectionState.waiting:
                        case ConnectionState.none:

                        case ConnectionState.active:
                        case ConnectionState.done:
                          final users = snapshot.data ?? [];

                          if (users.isNotEmpty) {
                            return ListView.builder(
                                physics: const BouncingScrollPhysics(),
                                itemCount: users.length,
                                itemBuilder: (context, index) {
                                  final user = users[index];

                                  return Container(
                                    color: selectedUser.contains(user)
                                        ? Styles.selectColor
                                        : null,
                                    child: UserCard(
                                      user: user,
                                      onTap: () {
                                        if (isMultiSelectEnabled) {
                                          multiSelection(user);
                                        } else {
                                          Navigator.of(context).push(
                                            MaterialPageRoute(
                                              builder: (context) =>
                                                  ChatScreen(user: user),
                                            ),
                                          );
                                        }
                                      },
                                      onLongPress: () {
                                        isMultiSelectEnabled = true;
                                        multiSelection(user);
                                      },
                                    ),
                                  );
                                });
                          } else {
                            return Center(
                              child: Text(
                                '',
                                style: TextStyle(
                                  color: Styles.textColor,
                                  fontSize: mq.width * 0.055,
                                ),
                              ),
                            );
                          }
                      }
                    },
                  );
              }
            }),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.of(context).push(
            MaterialPageRoute(builder: (context) {
              return const ContactsScreen();
            }),
          );
        },
        child: Icon(Styles.chatIcon),
      ),
    );
  }

  void multiSelection(ChatUser user) {
    if (isMultiSelectEnabled) {
      if (selectedUser.contains(user)) {
        selectedUser.remove(user);
        if (selectedUser.isEmpty) isMultiSelectEnabled = false;
      } else {
        selectedUser.add(user);
      }
      setState(() {});
    }
  }

  void deleteUser() {
    for (var user in selectedUser) {
      FirebaseApi.deleteChatUser(user.id, FirebaseApi.groupId(user.id));
    }
    selectedUser.clear();
    isMultiSelectEnabled = false;
    setState(() {});
    Navigator.pop(context);
  }
}
