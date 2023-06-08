import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:geolocator/geolocator.dart';
import 'package:nearbii/Model/notifStorage.dart';
import 'package:nearbii/constants.dart';
import 'package:nearbii/screens/auth/otp_screen.dart';
import 'package:nearbii/screens/bottom_bar/master_screen.dart';
import 'package:nearbii/screens/bottom_bar/permissiondenied_screen.dart';
import 'package:velocity_x/velocity_x.dart';

import 'LoginSignUpScreen.dart';
import 'auth_services.dart';

class SignInScreen extends StatefulWidget {
  const SignInScreen({Key? key}) : super(key: key);

  @override
  State<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> {
  final mobileController = TextEditingController();

  String referalcode = "";

  _checkUser() async {
    await FirebaseFirestore.instance
        .collection('User')
        .where('phone', isEqualTo: '+91${mobileController.text}')
        .get()
        .then((value) async {
      if (value.docs.isNotEmpty) {
        ReferalCheck exists = await checkReferalCode(referalcode);
        if (exists.value) {
          Navigator.of(context).push(
            MaterialPageRoute(
                builder: (context) => OTP(
                      phone: mobileController.text,
                      password: 'test1234',
                      referal: referalcode,
                      exists: exists,
                    )),
          );
        } else {
          Fluttertoast.showToast(msg: "Inavlid Referal");
        }
      } else {
        Fluttertoast.showToast(msg: 'Account does not exist! Create Account');
      }
    });
  }

  @override
  void dispose() {
    mobileController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;

    return Scaffold(
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.only(top: 55, left: 34, right: 34),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              //let's go label
              Text(
                'Lets Go!',
                style: TextStyle(
                  color: kLoadingScreenTextColor,
                  fontSize: 20,
                  fontWeight: FontWeight.w500,
                ),
                textAlign: TextAlign.center,
              ),
              //textfield
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 32),
                child: SizedBox(
                  height: 50,
                  child: TextFormField(
                    controller: mobileController,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      hintText: 'Phone Number',
                      hintStyle: TextStyle(
                          color: kHintTextColor,
                          fontSize: 18,
                          fontWeight: FontWeight.w400),
                      floatingLabelBehavior: FloatingLabelBehavior.always,
                      prefixIcon: const Icon(
                        Icons.phone_outlined,
                        size: 20,
                      ),
                      prefixIconColor: kHintTextColor,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 13,
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(2),
                        borderSide: BorderSide(color: kSignInContainerColor),
                        gapPadding: 10,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(2),
                        borderSide: BorderSide(color: kSignInContainerColor),
                        gapPadding: 10,
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(2),
                        borderSide: BorderSide(color: kSignInContainerColor),
                        gapPadding: 10,
                      ),
                    ),
                  ),
                ),
              ),
              //sign in button
              GestureDetector(
                onTap: () {
                  if (mobileController.text.toString().isEmpty) {
                    Fluttertoast.showToast(msg: "Enter Number");
                    return;
                  }
                  _checkUser();
                },
                child: Container(
                  width: width - 68,
                  height: 50,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(5),
                    color: kSignInContainerColor,
                  ),
                  child: const Center(
                    child: Text(
                      'Sign In',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ),
                ),
              ),
              //divider
              Padding(
                padding: const EdgeInsets.only(top: 90, bottom: 30),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Expanded(
                      child: Divider(
                        color: kHintTextColor,
                      ),
                    ),
                    Text(
                      'Or ',
                      style: TextStyle(
                        color: kDividerColor,
                        fontSize: 18,
                        fontWeight: FontWeight.w400,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    Expanded(
                      child: Divider(
                        color: kHintTextColor,
                      ),
                    ),
                  ],
                ),
              ),
              //google container
              GestureDetector(
                onTap: () {
                  signup(context, referalcode);
                },
                child: Container(
                  width: double.infinity,
                  height: 50,
                  decoration: BoxDecoration(
                    color: Colors.transparent,
                    borderRadius: BorderRadius.circular(5),
                    border: Border.all(color: kSignInContainerColor),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        const SizedBox(
                          width: 3,
                        ),
                        Image.asset(
                          'assets/icons/google.png',
                          height: 25,
                          width: 25,
                          fit: BoxFit.fill,
                        ),
                        const SizedBox(
                          width: 30,
                        ),
                        const Text(
                          'Continue with google',
                          style: TextStyle(
                            color: Colors.black,
                            fontSize: 18,
                            fontWeight: FontWeight.w400,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(
                height: 25,
              ),
              //facebook
              GestureDetector(
                onTap: () {
                  signInWithFacebook(context, referalcode);
                },
                child: Container(
                  width: double.infinity,
                  height: 50,
                  decoration: BoxDecoration(
                    color: Colors.transparent,
                    borderRadius: BorderRadius.circular(5),
                    border: Border.all(color: kSignInContainerColor),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Icon(
                          Icons.facebook,
                          size: 25,
                          color: Colors.blue.shade900,
                        ),
                        const SizedBox(
                          width: 30,
                        ),
                        const Text(
                          'Continue with facebook',
                          style: TextStyle(
                            color: Colors.black,
                            fontSize: 18,
                            fontWeight: FontWeight.w400,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              Container(
                      width: double.infinity,
                      height: 50,
                      decoration: BoxDecoration(
                        color: Colors.transparent,
                        borderRadius: BorderRadius.circular(5),
                        border: Border.all(color: kSignInContainerColor),
                      ),
                      child: TextField(
                        onChanged: (value) {
                          referalcode = value;
                        },
                        decoration: const InputDecoration(
                            border: InputBorder.none,
                            hintText: "Have a Referall code?"),
                      ).px12())
                  .py24(),

              //bottom label
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 67),
                child: RichText(
                  text: TextSpan(
                      text: 'Don’t have an account?',
                      style: TextStyle(
                        color: kLoadingScreenTextColor,
                        fontSize: 14,
                        fontWeight: FontWeight.w400,
                      ),
                      children: [
                        TextSpan(
                          text: ' Sign Up',
                          style: TextStyle(
                            color: kSignInBottomLabelColor,
                            fontSize: 14,
                            fontWeight: FontWeight.w900,
                          ),
                          recognizer: TapGestureRecognizer()
                            ..onTap = () => {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) =>
                                            const LoginSignUpScreen(
                                                loginState: false)),
                                  ),
                                },
                        ),
                      ]),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _determinePosition() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      Navigator.of(context).push(MaterialPageRoute(builder: ((context) {
        return const PermissionDenied();
      })));
      await Geolocator.openLocationSettings();
      // return Future.error('Location services are disabled.');
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied ||
        permission == LocationPermission.deniedForever) {
      Navigator.of(context).push(MaterialPageRoute(builder: ((context) {
        return const PermissionDenied();
      })));
      return;
    }
    Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: ((context) {
      return const MasterPage(
        currentIndex: 0,
      );
    })), (route) => false);
  }
}
