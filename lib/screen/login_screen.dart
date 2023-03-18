import 'package:chat_app/main.dart';
import 'package:chat_app/screen/forgot_password_screen.dart';
import 'package:chat_app/utils/styles.dart';
import 'package:chat_app/utils/utils.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

class LoginScreen extends StatefulWidget {
  final VoidCallback onClickedSignUp;

  const LoginScreen({Key? key, required this.onClickedSignUp})
      : super(key: key);

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  final textFieldFocusNode = FocusNode();
  bool _obscured = true;

  void _toggleObscured() {
    setState(() {
      _obscured = !_obscured;
      if (textFieldFocusNode.hasPrimaryFocus) return;
      textFieldFocusNode.canRequestFocus = false;
    });
  }

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final mq = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: Styles.bodyColor,
      appBar: AppBar(
        backgroundColor: Styles.appBarColor,
        title: const Text('Login'),
      ),
      body: Padding(
        padding: EdgeInsets.all(mq.width * 0.042),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              controller: emailController,
              textInputAction: TextInputAction.next,
              style: TextStyle(color: Styles.textColor),
              decoration: InputDecoration(
                hintText: 'Email',
                hintStyle: TextStyle(color: Styles.hintColor),
                filled: true,
                fillColor: Styles.fillColor,
                border: OutlineInputBorder(
                  borderSide: BorderSide.none,
                  borderRadius: BorderRadius.circular(mq.width * 0.042),
                ),
              ),
            ),
            SizedBox(height: mq.width * 0.042),
            TextField(
              controller: passwordController,
              keyboardType: TextInputType.visiblePassword,
              obscureText: _obscured,
              focusNode: textFieldFocusNode,
              textInputAction: TextInputAction.done,
              style: TextStyle(color: Styles.textColor),
              decoration: InputDecoration(
                hintText: 'Password',
                hintStyle: TextStyle(color: Styles.hintColor),
                filled: true,
                fillColor: Styles.fillColor,
                border: OutlineInputBorder(
                  borderSide: BorderSide.none,
                  borderRadius: BorderRadius.circular(mq.width * 0.042),
                ),
                suffixIcon: IconButton(
                  onPressed: _toggleObscured,
                  highlightColor: Colors.transparent,
                  splashColor: Colors.transparent,
                  icon: Icon(
                    _obscured ? Styles.eyeOnIcon : Styles.eyeOffIcon,
                    color: Styles.hintColor,
                  ),
                ),
              ),
            ),
            SizedBox(height: mq.width * 0.055),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                fixedSize: Size(double.maxFinite, mq.width * 0.125),
                shape: const StadiumBorder(),
              ),
              onPressed: signIn,
              child: Text(
                'Login',
                style: TextStyle(fontSize: mq.width * 0.055),
              ),
            ),
            SizedBox(height: mq.width * 0.055),
            GestureDetector(
              child: Text(
                'Forgot Password?',
                style: TextStyle(
                  decoration: TextDecoration.underline,
                  color: Styles.richTextColor,
                  fontSize: mq.width * 0.045,
                ),
              ),
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => const ForgotPasswordScreen(),
                  ),
                );
              },
            ),
            SizedBox(height: mq.width * 0.042),
            RichText(
              text: TextSpan(
                style: TextStyle(
                  color: Styles.textColor,
                  fontSize: mq.width * 0.045,
                ),
                text: 'Don\'t have an account?  ',
                children: [
                  TextSpan(
                    recognizer: TapGestureRecognizer()
                      ..onTap = widget.onClickedSignUp,
                    text: 'Sign up',
                    style: TextStyle(
                      color: Styles.richTextColor,
                    ),
                  )
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future signIn() async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(
        child: CircularProgressIndicator(),
      ),
    );
    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: emailController.text.trim(),
        password: passwordController.text.trim(),
      );
    } on FirebaseAuthException catch (_) {
      Utils.showSnackBar(
        'Please enter the correct email and password.',
        Styles.snackBarColor,
      );
    }
    navigatorKey.currentState!.popUntil((route) => route.isFirst);
  }
}
