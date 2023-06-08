import 'dart:developer';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:nearbii/services/sendNotification/notificatonByCity/cityNotiication.dart';
import 'package:velocity_x/velocity_x.dart';
import 'package:nearbii/Model/notifStorage.dart';
import 'package:nearbii/screens/auth/AuthenticationForm.dart';
import 'package:nearbii/screens/bottom_bar/master_screen.dart';
import 'package:nearbii/screens/bottom_bar/permissiondenied_screen.dart';

final FirebaseAuth auth = FirebaseAuth.instance;
String? token;

_fetchToken() async {
  token = await FirebaseMessaging.instance.getToken();
}

Future<void> signup(BuildContext context, String referalcode) async {
  var exists = await checkReferalCode(referalcode);
  if (!exists.value) {
    Fluttertoast.showToast(msg: "Invalid Referal");
    return;
  }
  try {
    final GoogleSignIn googleSignIn = GoogleSignIn();
    try {
      await googleSignIn.disconnect();
    } on Exception {
      // TODO
    }
    _fetchToken();

    final GoogleSignInAccount? googleSignInAccount =
        await googleSignIn.signIn();
    if (googleSignInAccount == null) return;
    final GoogleSignInAuthentication googleSignInAuthentication =
        await googleSignInAccount.authentication;
    final AuthCredential authCredential = GoogleAuthProvider.credential(
        idToken: googleSignInAuthentication.idToken,
        accessToken: googleSignInAuthentication.accessToken);

    // Getting users credential
    UserCredential result = await auth.signInWithCredential(authCredential);
    User? user = result.user;

    Map<String, dynamic> employeeDetails = {
      "phone": auth.currentUser!.phoneNumber,
      "token": token,
      "name": user!.displayName,
      "password": user.email,
      "type": "User",
      "userId": auth.currentUser!.uid.substring(0, 20),
      "wallet": 0,
      "image":
          "https://firebasestorage.googleapis.com/v0/b/neabiiapp.appspot.com/o/360_F_64678017_zUpiZFjj04cnLri7oADnyMH0XBYyQghG.jpg?alt=media&token=27052833-5800-4721-9429-d21c4a3eac1b",
      "referalcode": referalcode
    };
    String randomUUDI = user.uid.substring(0, 20);
    FirebaseFirestore.instance
        .collection("User")
        .where("userId", isEqualTo: randomUUDI)
        .get()
        .then((value) {
      if (value.docs.isNotEmpty) {
        _determinePosition(context);
      } else {
        log("empty");
        FirebaseFirestore.instance
            .collection("User")
            .doc(randomUUDI)
            .set(employeeDetails)
            .then((value) {
          if (exists.uid.isNotEmpty) {
            showNotification(employeeDetails["name"]);
            saveReferalWallet(
                referalcode, user.displayName, randomUUDI, exists, "gsa");
          }
          // Write UserID Store in Secure Data Store

          Navigator.of(context).pushReplacement(
            MaterialPageRoute(
              builder: (context) => AuthenticationForm(""),
            ),
          );
        });
      }
    });
  } on Exception {
    // TODO
  }
}

class ReferalCheck {
  String uid;
  bool value;
  ReferalCheck({
    required this.uid,
    required this.value,
  });
  @override
  String toString() {
    // TODO: implement toString

    return ({"uid": uid, "value": value}).toString();
  }
}

Future<ReferalCheck> checkReferalCode(String referalcode) async {
  if (referalcode.isEmptyOrNull) return ReferalCheck(uid: "", value: true);
  var doc = await FirebaseFirestore.instance
      .collection("User")
      .where("referCode", isEqualTo: referalcode)
      .get();
  if (doc.size > 0) {
    Fluttertoast.showToast(msg: "Valid referral ");
    return ReferalCheck(uid: doc.docs.first.id, value: true);
  }
  return ReferalCheck(uid: "", value: false);
}

Future<void> _determinePosition(context) async {
  bool serviceEnabled;
  LocationPermission permission;

  serviceEnabled = await Geolocator.isLocationServiceEnabled();
  if (!serviceEnabled) {
    Navigator.of(context).push(MaterialPageRoute(builder: ((context) {
      return PermissionDenied();
    })));
    // return Future.error('Location services are disabled.');
  }

  permission = await Geolocator.checkPermission();
  if (permission == LocationPermission.denied ||
      permission == LocationPermission.deniedForever) {
    Navigator.of(context).push(MaterialPageRoute(builder: ((context) {
      return PermissionDenied();
    })));
    return;
  }
  Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: ((context) {
    return MasterPage(
      currentIndex: 0,
    );
  })), (route) => false);
}

class Resource {
  final Status status;
  Resource({required this.status});
}

enum Status { Success, Error, Cancelled }

Future<Resource?> signInWithFacebook(
    BuildContext context, String referalcode) async {
  var exists = await checkReferalCode(referalcode);
  if (exists.value == false) {
    Fluttertoast.showToast(msg: "Invalid Referal");
    return null;
  }
  _fetchToken();
  try {
    final LoginResult result = await FacebookAuth.instance
        .login(permissions: ["public_profile", "email"]);
    switch (result.status) {
      case LoginStatus.success:
        final AuthCredential facebookCredential =
            FacebookAuthProvider.credential(result.accessToken!.token);
        final userCredential =
            await auth.signInWithCredential(facebookCredential);
        Map<String, dynamic> employeeDetails = {
          "phone": auth.currentUser!.phoneNumber,
          "token": token,
          "name": auth.currentUser!.displayName,
          "password": "",
          "userId": auth.currentUser!.uid.substring(0, 20),
          "type": "User",
          "wallet": 0,
          "image":
              "https://firebasestorage.googleapis.com/v0/b/neabiiapp.appspot.com/o/360_F_64678017_zUpiZFjj04cnLri7oADnyMH0XBYyQghG.jpg?alt=media&token=27052833-5800-4721-9429-d21c4a3eac1b",
          "referalcode": referalcode
        };

        FirebaseFirestore.instance
            .collection("User")
            .where("userId", isEqualTo: auth.currentUser!.uid.substring(0, 20))
            .get()
            .then((value) {
          if (value.docs.isEmpty) {
            FirebaseFirestore.instance
                .collection("User")
                .doc(auth.currentUser!.uid.substring(0, 20))
                .set(employeeDetails)
                .then((value) {
              showNotification(employeeDetails["name"]);
              saveReferalWallet(referalcode, auth.currentUser!.displayName,
                  auth.currentUser!.uid.substring(0, 20), exists, "fb");

              // Navigator.of(context).pushReplacement(
              //   MaterialPageRoute(
              //     builder: (context) => const MasterPage(),
              //   ),
              // );
              Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(
                      builder: (context) => AuthenticationForm("")),
                  (route) => true);
            });
          } else {
            Map<String, dynamic> employeeDetail = {
              "phone": auth.currentUser!.phoneNumber,
              "token": token,
              "name": auth.currentUser!.displayName,
              "password": "",
              "userId": auth.currentUser!.uid.substring(0, 20),
              "wallet": 0,
              "image":
                  "https://firebasestorage.googleapis.com/v0/b/neabiiapp.appspot.com/o/360_F_64678017_zUpiZFjj04cnLri7oADnyMH0XBYyQghG.jpg?alt=media&token=27052833-5800-4721-9429-d21c4a3eac1b",
            };
            FirebaseFirestore.instance
                .collection("User")
                .doc(auth.currentUser!.uid.substring(0, 20))
                .set(employeeDetail, SetOptions(merge: true));
            _determinePosition(context);
          }
        });

        return Resource(status: Status.Success);
      case LoginStatus.cancelled:
        return Resource(status: Status.Cancelled);
      case LoginStatus.failed:
        return Resource(status: Status.Error);
      default:
        return null;
    }
  } on FirebaseAuthException {
    rethrow;
  }
}

void saveReferalWallet(
    referalCode, name, String uiddd, ReferalCheck exists, methodname) {
  log(uiddd.length.toString());
  var referalData = {
    "referalCode": referalCode,
    "timestamp": DateTime.now().millisecondsSinceEpoch,
    "referdTo": name,
    "isVendor": false
  };
  FirebaseFirestore.instance
      .collection("User")
      .doc(exists.uid)
      .collection("referalWallet")
      .doc(uiddd)
      .set(referalData);
}

void updateReferalWallet(referalCode, uid, ReferalCheck exists) {
  log(uid.length.toString());
  var referalData = {"isVendor": true};
  FirebaseFirestore.instance
      .collection("User")
      .doc(exists.uid)
      .collection("referalWallet")
      .doc(uid)
      .set(referalData, SetOptions(merge: true));
  Notifcheck.api
      .updateUserData(exists.uid, {"referBalance": FieldValue.increment(100)});
}
