import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:geolocator/geolocator.dart';
import 'package:nearbii/Model/notifStorage.dart';
import 'package:nearbii/constants.dart';
import 'package:nearbii/main.dart';
import 'package:nearbii/screens/bottom_bar/master_screen.dart';
import 'package:nearbii/screens/bottom_bar/permissiondenied_screen.dart';
import 'package:nearbii/services/setUserMode.dart';
import 'package:pinput/pinput.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:velocity_x/velocity_x.dart';

import 'auth_services.dart';

class OTP extends StatefulWidget {
  final String phone;
  final String name;
  final String password;
  final ReferalCheck exists;
  final String referal;
  const OTP(
      {super.key,
      required this.phone,
      this.name = 'Guest',
      this.password = 'fd',
      required this.referal,
      required this.exists});

  @override
  _OTPState createState() => _OTPState();
}

class _OTPState extends State<OTP> {
  final FocusNode _pinPutFocusNode = FocusNode();
  final TextEditingController _pinPutController = TextEditingController();
  final defaultPinTheme = PinTheme(
    width: 56,
    height: 56,
    textStyle: const TextStyle(
      fontSize: 28,
      fontWeight: FontWeight.w400,
    ),
    decoration: BoxDecoration(
      border: Border.all(color: const Color.fromRGBO(234, 239, 243, 1)),
      borderRadius: BorderRadius.circular(20),
    ),
  );
  var pinPutDecoration;
  String? token;
  _fetchToken() async {
    token = await FirebaseMessaging.instance.getToken();
    if (mounted) {
      setState(() {});
    }
  }

  late String _verificationCode;
  String smsCode = "123456";
  _verifyPhone() async {
    log(widget.exists.toString(), name: "referal");
    await FirebaseAuth.instance.verifyPhoneNumber(
        phoneNumber: '+91${widget.phone}',
        verificationCompleted: (PhoneAuthCredential credential) async {
          log("auto");
          await FirebaseAuth.instance
              .signInWithCredential(credential)
              .then((value) async {
            if (value.user != null) {
              registerUser(value.user!);
            } else {}
          });
        },
        verificationFailed: (FirebaseAuthException e) {
          ScaffoldMessenger.of(context)
              .showSnackBar(SnackBar(content: Text(e.toString())));
          print(e.message);
        },
        codeSent: (String verficationID, int? resendToken) {
          setState(() {
            _verificationCode = verficationID;
          });
        },
        codeAutoRetrievalTimeout: (String verificationID) {
          _verificationCode = verificationID;
        },
        timeout: const Duration(seconds: 30));
  }

  bool isLoading = false;

  _showNotification(String name) {
    flutterLocalNotificationsPlugin.show(
      0,
      "Welcome To Nearbii",
      "Thank you $name, for choosing NEARBII ❤",
      NotificationDetails(
        android: AndroidNotificationDetails(
          channel.id,
          channel.name,
          channelDescription: channel.description,
          color: Colors.blue,
          playSound: true,
          styleInformation: const BigTextStyleInformation(''),
        ),
      ),
    );
  }

  @override
  void initState() {
    pinPutDecoration ==
        defaultPinTheme.copyDecorationWith(
          borderRadius: BorderRadius.circular(12),
          color: Colors.white,
          border: Border.all(
            color: kSignInContainerColor,
          ),
        );
    super.initState();
    _fetchToken();
    _verifyPhone();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        leading: GestureDetector(
          onTap: () => Navigator.pop(context),
          child: const Icon(
            Icons.arrow_back_ios,
            size: 15,
            color: Colors.black,
          ),
        ),
        title: const Text(
          'Verify phone',
          style: TextStyle(
            fontWeight: FontWeight.w400,
            fontSize: 19,
            color: Colors.black,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 50),
                child: Text(
                  'Code is sent to ${widget.phone}',
                  style: const TextStyle(
                    fontWeight: FontWeight.w400,
                    fontSize: 14,
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(0),
                child: Pinput(
                  length: 6,
                  autofocus: true,

                  focusNode: _pinPutFocusNode,
                  controller: _pinPutController,
                  submittedPinTheme: pinPutDecoration,
                  focusedPinTheme: pinPutDecoration,
                  followingPinTheme: pinPutDecoration,
                  pinAnimationType: PinAnimationType.fade,
                  // onSubmit: (String val){
                  //   print(val);
                  // },
                ),
              ),
              const SizedBox(
                height: 62,
              ),
              InkWell(
                onTap: () {
                  _verifyPhone();
                },
                child: RichText(
                  text: TextSpan(
                      text: 'Didn\'t receive an OTP?  ',
                      style: const TextStyle(
                        fontWeight: FontWeight.w400,
                        fontSize: 13,
                        color: Color(0xFF676767),
                      ),
                      children: [
                        TextSpan(
                          text: 'Resend OTP',
                          style: TextStyle(
                            fontWeight: FontWeight.w400,
                            fontSize: 13,
                            color: kSignInContainerColor,
                          ),
                        ),
                      ]),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 30, bottom: 72),
                child: GestureDetector(
                  onTap: () async {
                    try {
                      smsCode = _pinPutController.text;
                      print("object $smsCode");
                      SharedPreferences sp =
                          await SharedPreferences.getInstance();
                      await FirebaseAuth.instance
                          .signInWithCredential(PhoneAuthProvider.credential(
                              verificationId: _verificationCode,
                              smsCode: smsCode))
                          .then((value) async {
                        if (value.user != null) {
                          registerUser(value.user!);
                        }
                      });
                    } catch (e) {
                      print(e);
                      FocusScope.of(context).unfocus();
                      ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('invalid OTP')));
                    }
                  },
                  child: Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: kSignInContainerColor,
                    ),
                    child: const Padding(
                      padding: EdgeInsets.only(top: 15, bottom: 16),
                      child: Text(
                        'Verify',
                        style: TextStyle(
                          color: Colors.white,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                ),
              ),
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

  void registerUser(User user) {
    Map<String, dynamic> employeeDetails = {
      "phone": "+91${widget.phone}",
      "token": token,
      "name": widget.name,
      "password": widget.password,
      "type": "User",
      "offerNotif": false,
      "eventNotif": false,
      "newNotif": false,
      "userId": user.uid.substring(0, 20),
      "wallet": 0,
      "image":
          "https://firebasestorage.googleapis.com/v0/b/neabiiapp.appspot.com/o/360_F_64678017_zUpiZFjj04cnLri7oADnyMH0XBYyQghG.jpg?alt=media&token=27052833-5800-4721-9429-d21c4a3eac1b",
      "referalcode": widget.referal
    };
    FirebaseFirestore.instance
        .collection("User")
        .doc(user.uid.substring(0, 20))
        .get()
        .then((values) async {
      var data = values.data();
      if (data == null) {
        log("null", name: "checkuser");
        FirebaseFirestore.instance
            .collection("User")
            .doc(user.uid.substring(0, 20))
            .set(employeeDetails);
        ScaffoldMessenger.of(context)
            .showSnackBar(const SnackBar(content: Text('Done')));
        user.updateDisplayName(widget.name);
        data = employeeDetails;
        if (widget.exists.uid.isNotEmptyAndNotNull) {
          saveReferalWallet(widget.referal, user.displayName,
              user.uid.substring(0, 20), widget.exists, "otp");
        }
        setUserMode();
        _determinePosition();
      } else {
        log("notnull", name: "checkuser");
        data["type"] == "User" ? setUserMode() : setVendorMode();
        _determinePosition();
      }
    });
  }
}
