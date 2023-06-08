// ignore_for_file: unnecessary_new

import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:nearbii/screens/bottom_bar/master_screen.dart';
import 'package:nearbii/screens/bottom_bar/permissiondenied_screen.dart';

import '../Model/notifStorage.dart';
import 'auth/LoginSignUpScreen.dart';

class LoadingScreen extends StatefulWidget {
  const LoadingScreen({Key? key}) : super(key: key);

  @override
  State<LoadingScreen> createState() => _LoadingScreenState();
}

class _LoadingScreenState extends State<LoadingScreen> {
  final auth = FirebaseAuth.instance;
  @override
  void initState() {
    Notifcheck.api.getServices();
    Notifcheck.api.getBanners();
    Notifcheck.api.getCategories();
    Notifcheck.api.getHomeIconData();

    super.initState();
    if (auth.currentUser != null) {
      _determinePosition();
    } else {
      new Future.delayed(
          const Duration(seconds: 3),
          () => Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                    builder: (context) =>
                        const LoginSignUpScreen(loginState: true)),
              ));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Container(
            child: Image.asset(
              'assets/splashScreen.png',
              scale: 1,
            ),
            alignment: Alignment.center,
          ),
        ],
      ),
    );
  }

  Future<void> _determinePosition() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      try {
        Navigator.of(context).push(MaterialPageRoute(builder: ((context) {
          return const PermissionDenied();
        })));
      } on Error {
        Navigator.of(context).push(MaterialPageRoute(builder: ((context) {
          return const PermissionDenied();
        })));
        // TODO
      }

      // return Future.error('Location services are disabled.');
    } else {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        return;
      }
      if (permission == LocationPermission.always ||
          permission == LocationPermission.whileInUse) {
        await Future.delayed(const Duration(seconds: 3));
        await Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(builder: ((context) {
          return const MasterPage(
            currentIndex: 0,
          );
        })), (route) => false);
      }
    }
  }
}
