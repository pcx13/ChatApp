import 'dart:async';

import 'package:chat_app/screen/home_screen.dart';
import 'package:chat_app/utils/styles.dart';
import 'package:chat_app/utils/utils.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class VerifyEmailScreen extends StatefulWidget {
  const VerifyEmailScreen({Key? key}) : super(key: key);

  @override
  State<VerifyEmailScreen> createState() => _VerifyEmailScreenState();
}

class _VerifyEmailScreenState extends State<VerifyEmailScreen> {
  bool isEmailVerified = false;
  bool canResendEmail = false;
  Timer? timer;

  @override
  void initState() {
    super.initState();
    isEmailVerified = FirebaseAuth.instance.currentUser!.emailVerified;

    if (!isEmailVerified) {
      sendVerificationEmail();

      timer = Timer.periodic(
        const Duration(seconds: 3),
        (_) => checkEmailVerified(),
      );
    }
  }

  Future checkEmailVerified() async {
    await FirebaseAuth.instance.currentUser!.reload();

    setState(() {
      isEmailVerified = FirebaseAuth.instance.currentUser!.emailVerified;
    });

    if (isEmailVerified) {
      timer?.cancel();
    }
  }

  Future sendVerificationEmail() async {
    try {
      final user = FirebaseAuth.instance.currentUser!;
      await user.sendEmailVerification();
      setState(() => canResendEmail = false);
      await Future.delayed(const Duration(seconds: 5));
      setState(() => canResendEmail = true);
    } catch (e) {
      Utils.showSnackBar(
        e.toString(),
        Styles.snackBarColor,
      );
    }
  }

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final mq = MediaQuery.of(context).size;

    return isEmailVerified
        ? const HomeScreen()
        : Scaffold(
            backgroundColor: Styles.bodyColor,
            appBar: AppBar(
              backgroundColor: Styles.appBarColor,
              title: const Text('Verify Email'),
            ),
            body: Padding(
              padding: EdgeInsets.all(mq.width * 0.042),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'A verification email has been sent to your email.',
                    style: TextStyle(
                      fontSize: mq.width * 0.055,
                      color: Styles.textColor,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: mq.width * 0.055),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      fixedSize: Size(double.maxFinite, mq.width * 0.125),
                      shape: const StadiumBorder(),
                    ),
                    onPressed: canResendEmail ? sendVerificationEmail : null,
                    child: Text(
                      'Resent Email',
                      style: TextStyle(fontSize: mq.width * 0.055),
                    ),
                  ),
                  SizedBox(height: mq.width * 0.042),
                  TextButton(
                    style: ElevatedButton.styleFrom(
                      fixedSize: Size(double.maxFinite, mq.width * 0.125),
                      shape: const StadiumBorder(),
                    ),
                    onPressed: () => FirebaseAuth.instance.signOut(),
                    child: Text(
                      'Cancel',
                      style: TextStyle(fontSize: mq.width * 0.055),
                    ),
                  ),
                ],
              ),
            ),
          );
  }
}
