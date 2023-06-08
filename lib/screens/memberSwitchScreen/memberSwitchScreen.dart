import 'package:flutter/material.dart';
import 'package:nearbii/constants.dart';
import 'package:nearbii/screens/bottom_bar/bottomBar/bottomBar.dart';

class memberSwitchScreen extends StatefulWidget {
  const memberSwitchScreen({Key? key}) : super(key: key);

  @override
  State<memberSwitchScreen> createState() => _memberSwitchScreenState();
}

class _memberSwitchScreenState extends State<memberSwitchScreen> {
  @override
  Widget build(BuildContext context) {
    return SafeArea(
        top: false,
        child: Scaffold(
          bottomNavigationBar: addBottomBar(context),
          appBar: AppBar(
            leading: Column(
              children: [
                const SizedBox(
                  width: 45,
                  height: 20,
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
          body: SizedBox(
              width: MediaQuery.of(context).size.width,
              height: MediaQuery.of(context).size.height,
              child: Column(
                children: [
                  Container(
                    alignment: Alignment.centerLeft,
                    padding: const EdgeInsets.only(left: 20),
                    child: Text(
                      "Update Membership",
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 20,
                        color: kLoadingScreenTextColor,
                      ),
                    ),
                  ),
                  Container(),
                ],
              )),
        ));
  }
}
