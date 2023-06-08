// ignore_for_file: prefer_const_constructors

import 'package:flutter/material.dart';
import 'package:nearbii/constants.dart';
import 'package:nearbii/screens/bottom_bar/bottomBar/bottomBar.dart';
import 'package:nearbii/screens/bottom_bar/profile/vendor_profile_screen.dart';

class vendorHome extends StatefulWidget {
  final String id;
  const vendorHome({Key? key, required this.id}) : super(key: key);

  @override
  State<vendorHome> createState() => _vendorHomeState();
}

class _vendorHomeState extends State<vendorHome> {
  @override
  Widget build(BuildContext context) {
    return SafeArea(
        top: false,
        child: Scaffold(
            bottomNavigationBar: addBottomBar(context),
            appBar: AppBar(
              leading: Row(
                children: [
                  SizedBox(
                    width: 35,
                  ),
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Icon(
                      Icons.arrow_back_ios,
                      size: 20,
                      color: kLoadingScreenTextColor,
                    ),
                  ),
                ],
              ),
            ),
            body: VendorProfileScreen(id: widget.id, isVisiter: true)));
  }
}
