// ignore_for_file: prefer_const_constructors

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:nearbii/constants.dart';
import 'package:nearbii/screens/auth/otp_screen.dart';
import 'package:velocity_x/velocity_x.dart';

import '../../Model/notifStorage.dart';
import 'LoginSignUpScreen.dart';
import 'auth_services.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({Key? key}) : super(key: key);

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final mobileController = TextEditingController();
  // final passwordController = TextEditingController();
  // final confirmPasswordController = TextEditingController();
  final nameController = TextEditingController();
  final formGlobalKey = GlobalKey<FormState>();

  bool isPasswordHidden = true;
  bool isConfirmPasswordHidden = true;

  String referalcode = "";

  @override
  void dispose() {
    mobileController.dispose();
    // passwordController.dispose();
    // confirmPasswordController.dispose();
    nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;

    return Scaffold(
      body: SingleChildScrollView(
        child: Form(
          key: formGlobalKey,
          child: Padding(
            padding: const EdgeInsets.only(top: 55, left: 16, right: 16),
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
                Padding(
                  padding: const EdgeInsets.only(top: 40, bottom: 10),
                  child: Column(
                    children: [
                      //name field
                      SizedBox(
                        height: 50,
                        child: TextFormField(
                          //controller: mobileController,
                          keyboardType: TextInputType.text,
                          controller: nameController,
                          decoration: InputDecoration(
                            hintText: 'Full Name',
                            hintStyle: TextStyle(
                                color: kHintTextColor,
                                fontSize: 18,
                                fontWeight: FontWeight.w400),
                            floatingLabelBehavior: FloatingLabelBehavior.always,
                            prefixIcon: Icon(
                              Icons.person_outline,
                              size: 20,
                            ),
                            prefixIconColor: kHintTextColor,
                            contentPadding: EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 13,
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(2),
                              borderSide:
                                  BorderSide(color: kSignInContainerColor),
                              gapPadding: 10,
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(2),
                              borderSide:
                                  BorderSide(color: kSignInContainerColor),
                              gapPadding: 10,
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(2),
                              borderSide:
                                  BorderSide(color: kSignInContainerColor),
                              gapPadding: 10,
                            ),
                          ),
                        ),
                      ),
                      //number field
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 25),
                        child: SizedBox(
                          height: 50,
                          child: TextFormField(
                            controller: mobileController,
                            keyboardType: TextInputType.number,
                            decoration: InputDecoration(
                              hintText: 'Number',
                              hintStyle: TextStyle(
                                  color: kHintTextColor,
                                  fontSize: 18,
                                  fontWeight: FontWeight.w400),
                              floatingLabelBehavior:
                                  FloatingLabelBehavior.always,
                              prefixIcon: Icon(
                                Icons.phone_outlined,
                                size: 20,
                              ),
                              prefixIconColor: kHintTextColor,
                              contentPadding: EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 13,
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(2),
                                borderSide:
                                    BorderSide(color: kSignInContainerColor),
                                gapPadding: 10,
                              ),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(2),
                                borderSide:
                                    BorderSide(color: kSignInContainerColor),
                                gapPadding: 10,
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(2),
                                borderSide:
                                    BorderSide(color: kSignInContainerColor),
                                gapPadding: 10,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                //sign in button
                GestureDetector(
                  onTap: () async {
                    if (formGlobalKey.currentState!.validate()) {
                      formGlobalKey.currentState!.save();
                      ReferalCheck exists = await checkReferalCode(referalcode);
                      if (exists.value) {
                        Notifcheck.currentVendor = null;
                        Navigator.of(context).push(
                          MaterialPageRoute(
                              builder: (context) => OTP(
                                    phone: mobileController.text,
                                    name: nameController.text,
                                    password: 'test1234',
                                    referal: referalcode,
                                    exists: exists,
                                  )),
                        );
                      } else {
                        Fluttertoast.showToast(msg: "Inavlid Referal");
                      }
                    }
                  },
                  child: Container(
                    width: width - 68,
                    height: 50,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(5),
                      color: kSignInContainerColor,
                    ),
                    child: Center(
                      child: Text(
                        'Sign Up',
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
                  padding: const EdgeInsets.only(top: 20, bottom: 30),
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
                          SizedBox(
                            width: 3,
                          ),
                          Image.asset(
                            'assets/icons/google.png',
                            height: 25,
                            width: 25,
                            fit: BoxFit.fill,
                          ),
                          SizedBox(
                            width: 30,
                          ),
                          Text(
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
                SizedBox(
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
                          SizedBox(
                            width: 30,
                          ),
                          Text(
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
                      text: 'Already have an account?',
                      style: TextStyle(
                        color: kLoadingScreenTextColor,
                        fontSize: 14,
                        fontWeight: FontWeight.w400,
                      ),
                      children: [
                        TextSpan(
                          text: '  Sign In',
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
                                        builder: (context) => LoginSignUpScreen(
                                            loginState: true)),
                                  ),
                                },
                        ),
                      ],
                    ),
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
