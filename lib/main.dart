import 'package:chat_app/firebase_options.dart';
import 'package:chat_app/screen/verify_email_screen.dart';
import 'package:chat_app/utils/auth_page.dart';
import 'package:chat_app/utils/styles.dart';
import 'package:chat_app/utils/utils.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_notification_channel/flutter_notification_channel.dart';
import 'package:flutter_notification_channel/notification_importance.dart';

Future main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  notificationChannel();
  runApp(const MyApp());
}

Future notificationChannel() async {
  await FlutterNotificationChannel.registerNotificationChannel(
    id: 'chats',
    name: 'Chats',
    description: 'Message Notification',
    importance: NotificationImportance.IMPORTANCE_HIGH,
  );
}

final navigatorKey = GlobalKey<NavigatorState>();

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      scaffoldMessengerKey: Utils.messengerKey,
      navigatorKey: navigatorKey,
      theme: ThemeData(primarySwatch: Styles.primary),
      home: Scaffold(
        body: StreamBuilder(
            stream: FirebaseAuth.instance.authStateChanges(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              } else if (snapshot.hasError) {
                final mq = MediaQuery.of(context).size;
                return Center(
                  child: Text(
                    'ERROR',
                    style: TextStyle(
                      color: Styles.textColor,
                      fontSize: mq.width * 0.055,
                    ),
                  ),
                );
              } else if (snapshot.hasData) {
                return const VerifyEmailScreen();
              } else {
                return const AuthPage();
              }
            }),
      ),
    );
  }
}
