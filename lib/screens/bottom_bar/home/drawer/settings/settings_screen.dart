import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:nearbii/constants.dart';
import 'package:nearbii/screens/bottom_bar/home/drawer/privacy_policy_screen.dart';
import 'package:nearbii/screens/bottom_bar/home/drawer/settings/privacy_settings_screen.dart';
import 'package:nearbii/screens/bottom_bar/home/drawer/terms_and_conditions_screen.dart';
import 'package:nearbii/services/sendNotification/registerToken/registerTopicNotificaion.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({Key? key}) : super(key: key);

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool switch1 = true;
  bool switch2 = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: Row(
          children: [
            const SizedBox(
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
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            //settings label
            Padding(
              padding: const EdgeInsets.fromLTRB(34, 0, 34, 5),
              child: Text(
                "Settings",
                style: TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 20,
                  color: kLoadingScreenTextColor,
                ),
              ),
            ),
            //user settings
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                //user settings label
                Padding(
                  padding: const EdgeInsets.only(
                      top: 20, bottom: 10, left: 34, right: 34),
                  child: Text(
                    "User Settings",
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 18,
                      color: kLoadingScreenTextColor,
                    ),
                  ),
                ),
                Container(
                  width: double.infinity,
                  color: kHomeScreenServicesContainerColor,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 34, vertical: 10),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Display Name",
                          style: TextStyle(
                            fontWeight: FontWeight.w500,
                            fontSize: 16,
                            color: kSettingsScreenLightContainerHeadingColor,
                          ),
                        ),
                        const SizedBox(
                          height: 10,
                        ),
                        Text(
                          FirebaseAuth.instance.currentUser!.displayName!,
                          style: TextStyle(
                            fontWeight: FontWeight.w400,
                            fontSize: 14,
                            color: kWalletLightTextColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            //Local Contacts
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                //user settings label
                Padding(
                  padding: const EdgeInsets.only(
                      top: 20, bottom: 10, left: 34, right: 34),
                  child: Text(
                    "Local Contacts",
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 18,
                      color: kLoadingScreenTextColor,
                    ),
                  ),
                ),
                Container(
                  width: double.infinity,
                  color: kHomeScreenServicesContainerColor,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 34, vertical: 10),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Phonebook Country",
                          style: TextStyle(
                            fontWeight: FontWeight.w500,
                            fontSize: 16,
                            color: kSettingsScreenLightContainerHeadingColor,
                          ),
                        ),
                        const SizedBox(
                          height: 10,
                        ),
                        Text(
                          "India",
                          style: TextStyle(
                            fontWeight: FontWeight.w400,
                            fontSize: 14,
                            color: kWalletLightTextColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            //Notifications
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                //user settings label
                Padding(
                  padding: const EdgeInsets.only(
                      top: 20, bottom: 10, left: 34, right: 34),
                  child: Text(
                    "Notifications",
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 18,
                      color: kLoadingScreenTextColor,
                    ),
                  ),
                ),
                Container(
                  width: double.infinity,
                  color: kHomeScreenServicesContainerColor,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 34, vertical: 10),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(
                              "Enable notification for this account",
                              style: TextStyle(
                                fontWeight: FontWeight.w500,
                                fontSize: 14,
                                color:
                                    kSettingsScreenLightContainerHeadingColor,
                              ),
                            ),
                            const Spacer(),
                            Switch(
                              onChanged: (value) async {
                                switch1 = value;
                                setState(() {});
                                if (value) {
                                  subscribeTopicCity();
                                } else {
                                  await unsubscribeTopicity();
                                }
                              },
                              activeColor: const Color(0xFF59B2C6),
                              inactiveTrackColor: const Color(0xFF909090),
                              value: switch1,
                            ),
                          ],
                        ),
                        // Padding(
                        //   padding: const EdgeInsets.symmetric(vertical: 10),
                        //   child: Row(
                        //     children: [
                        //       Text(
                        //         "Enable full page notification",
                        //         style: TextStyle(
                        //           fontWeight: FontWeight.w500,
                        //           fontSize: 16,
                        //           color:
                        //               kSettingsScreenLightContainerHeadingColor,
                        //         ),
                        //       ),
                        //       Spacer(),
                        //       Switch(
                        //         onChanged: (value) {
                        //           switch2 = value;
                        //         },
                        //         activeColor: const Color(0xFF59B2C6),
                        //         inactiveTrackColor: const Color(0xFF909090),
                        //         value: switch2,
                        //       ),
                        //     ],
                        //   ),
                        // ),
                        // GestureDetector(
                        //   onTap: () => Navigator.of(context).push(
                        //     MaterialPageRoute(
                        //       builder: (context) =>
                        //           NotificationSettingsScreen(),
                        //     ),
                        //   ),
                        //   child: Text(
                        //     "Notification settings",
                        //     style: TextStyle(
                        //       fontWeight: FontWeight.w500,
                        //       fontSize: 16,
                        //       color: kSettingsScreenLightContainerHeadingColor,
                        //     ),
                        //   ),
                        // ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            //Others
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                //user settings label
                Padding(
                  padding: const EdgeInsets.only(
                      top: 20, bottom: 10, left: 34, right: 34),
                  child: Text(
                    "Others",
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 18,
                      color: kLoadingScreenTextColor,
                    ),
                  ),
                ),
                Container(
                  width: double.infinity,
                  color: kHomeScreenServicesContainerColor,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 34, vertical: 10),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Version",
                          style: TextStyle(
                            fontWeight: FontWeight.w500,
                            fontSize: 16,
                            color: kSettingsScreenLightContainerHeadingColor,
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(top: 5, bottom: 10),
                          child: Text(
                            "1.0.0",
                            style: TextStyle(
                              fontWeight: FontWeight.w400,
                              fontSize: 14,
                              color: kWalletLightTextColor,
                            ),
                          ),
                        ),
                        GestureDetector(
                          onTap: () => Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (context) =>
                                  const PrivacySettingsScreen(),
                            ),
                          ),
                          child: Text(
                            "Privacy settings",
                            style: TextStyle(
                              fontWeight: FontWeight.w500,
                              fontSize: 16,
                              color: kSettingsScreenLightContainerHeadingColor,
                            ),
                          ),
                        ),
                        GestureDetector(
                          onTap: () => Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (context) =>
                                  const TermsAndConditionsScreen(),
                            ),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(vertical: 10),
                            child: Text(
                              "Terms and Conditions",
                              style: TextStyle(
                                fontWeight: FontWeight.w500,
                                fontSize: 16,
                                color:
                                    kSettingsScreenLightContainerHeadingColor,
                              ),
                            ),
                          ),
                        ),
                        GestureDetector(
                          onTap: () => Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (context) => const PrivacyPolicyScreen(),
                            ),
                          ),
                          child: Text(
                            "Privacy Policy",
                            style: TextStyle(
                              fontWeight: FontWeight.w500,
                              fontSize: 16,
                              color: kSettingsScreenLightContainerHeadingColor,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(
                  height: 50,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
