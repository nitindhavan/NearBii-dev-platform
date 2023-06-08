import 'dart:developer';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:nearbii/Model/notifStorage.dart';
import 'package:nearbii/screens/bottom_bar/profile/user_profile_screen.dart';
import 'package:nearbii/screens/bottom_bar/profile/vendor_profile_screen.dart';
import 'package:velocity_x/velocity_x.dart';

bool isUserProfile = true;

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  bool isLoading = true;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    loadUser();
  }

  loadUser() async {
    bool user = await Notifcheck.api.isUser();
    log(user.toString(), name: "checkuser");
    isUserProfile = user;
    setState(() {
      log("loaded");
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    log(isLoading.toString(), name: "loaded");
    return !isLoading
        ? SafeArea(
            child: Scaffold(
              body: isUserProfile
                  ? const UserProfileScreen()
                  : VendorProfileScreen(
                      id: FirebaseAuth.instance.currentUser!.uid
                          .substring(0, 20),
                      isVisiter: false,
                    ),
            )
          )
        : Container().pOnly(top: 20);
  }
}
