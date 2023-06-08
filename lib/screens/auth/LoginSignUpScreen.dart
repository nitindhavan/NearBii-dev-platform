// ignore_for_file: prefer_const_constructors

import 'package:flutter/material.dart';
import 'package:nearbii/constants.dart';
import 'package:velocity_x/velocity_x.dart';

import 'SignInScreen.dart';
import 'SignUpScreen.dart';

class LoginSignUpScreen extends StatefulWidget {
  final bool loginState;

  const LoginSignUpScreen({
    Key? key,
    required this.loginState,
  }) : super(key: key);

  @override
  State<LoginSignUpScreen> createState() => _LoginSignUpScreenState();
}

class _LoginSignUpScreenState extends State<LoginSignUpScreen> {
  bool loginState = true;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    loginState = widget.loginState;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false, //new line
      body: Padding(
        padding: const EdgeInsets.fromLTRB(8, 30, 8, 0),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  GestureDetector(
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(4),
                        color: loginState
                            ? kSignInContainerColor
                            : Colors.transparent,
                      ),
                      padding: const EdgeInsets.all(8),
                      child: Text(
                        "Sign in",
                      ),
                    ),
                    onTap: () => setState(() {
                      loginState = true;
                    }),
                  ),
                  SizedBox(
                    width: 16,
                  ),
                  GestureDetector(
                    onTap: () => setState(() {
                      loginState = false;
                    }),
                    child: Container(
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(4),
                          color: !loginState
                              ? kSignInContainerColor
                              : Colors.transparent),
                      padding: const EdgeInsets.all(8),
                      child: Text("Sign up"),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(
              child: loginState ? SignInScreen() : SignUpScreen(),
            ).expand(),
          ],
        ),
      ),
    );
  }
}
