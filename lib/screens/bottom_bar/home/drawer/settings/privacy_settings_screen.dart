import 'package:flutter/material.dart';
import 'package:nearbii/constants.dart';

class PrivacySettingsScreen extends StatefulWidget {
  const PrivacySettingsScreen({Key? key}) : super(key: key);

  @override
  State<PrivacySettingsScreen> createState() => _PrivacySettingsScreenState();
}

int index = 0;

class _PrivacySettingsScreenState extends State<PrivacySettingsScreen> {
  int selectedIndex = index;
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
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 34),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                //Privacy Settings label
                Text(
                  "Privacy Settings",
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 20,
                    color: kLoadingScreenTextColor,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 26),
                  child: Column(
                    children: [
                      //Everyone
                      Row(
                        children: [
                          Row(
                            children: [
                              Image.asset(
                                'assets/icons/privacy_settings/friends 1.png',
                              ),
                              const SizedBox(
                                width: 10,
                              ),
                              const Text(
                                "Everyone",
                                style: TextStyle(
                                  fontWeight: FontWeight.w400,
                                  fontSize: 18,
                                  color: Colors.black,
                                ),
                              ),
                            ],
                          ),
                          const Spacer(),
                          GestureDetector(
                            onTap: () {
                              setState(() {
                                selectedIndex = 0;
                              });
                            },
                            child: Icon(
                              selectedIndex == 0
                                  ? Icons.check_circle
                                  : Icons.radio_button_off_outlined,
                              size: 20,
                              color: selectedIndex == 0
                                  ? kSignInContainerColor
                                  : kWalletLightTextColor,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(
                        height: 20,
                      ),
                      //only me
                      Row(
                        children: [
                          Row(
                            children: [
                              Image.asset(
                                'assets/icons/privacy_settings/profile 1.png',
                              ),
                              const SizedBox(
                                width: 10,
                              ),
                              const Text(
                                "Only Me",
                                style: TextStyle(
                                  fontWeight: FontWeight.w400,
                                  fontSize: 18,
                                  color: Colors.black,
                                ),
                              ),
                            ],
                          ),
                          const Spacer(),
                          GestureDetector(
                            onTap: () {
                              setState(() {
                                selectedIndex = 1;
                              });
                            },
                            child: Icon(
                              selectedIndex == 1
                                  ? Icons.check_circle
                                  : Icons.radio_button_off_outlined,
                              size: 20,
                              color: selectedIndex == 1
                                  ? kSignInContainerColor
                                  : kWalletLightTextColor,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                //button
                Center(
                  child: GestureDetector(
                    onTap: () {
                      setState(() {
                        index = selectedIndex;
                      });
                      Navigator.pop(context);
                    },
                    child: Padding(
                      padding: const EdgeInsets.only(top: 24),
                      child: Container(
                        height: 40,
                        width: 173,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(5),
                          color: kSignInContainerColor,
                        ),
                        child: const Center(
                          child: Text(
                            "Save Changes",
                            style: TextStyle(
                              fontWeight: FontWeight.w400,
                              fontSize: 16,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
