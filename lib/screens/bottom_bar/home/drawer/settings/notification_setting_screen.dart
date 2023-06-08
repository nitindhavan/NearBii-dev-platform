import 'package:flutter/material.dart';
import 'package:nearbii/components/custom_switch.dart';
import 'package:nearbii/constants.dart';

class NotificationSettingsScreen extends StatefulWidget {
  const NotificationSettingsScreen({Key? key}) : super(key: key);

  @override
  State<NotificationSettingsScreen> createState() =>
      _NotificationSettingsScreenState();
}

class _NotificationSettingsScreenState
    extends State<NotificationSettingsScreen> {
  bool radio = false;

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
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 34),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            //notification settings label
            Text(
              "Notification Settings",
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
                  //new business
                  Row(
                    children: [
                      const Text(
                        "New Businesses",
                        style: TextStyle(
                          fontWeight: FontWeight.w400,
                          fontSize: 18,
                          color: Colors.black,
                        ),
                      ),
                      const Spacer(),
                      CustomSwitch(
                        onTap: () {},
                        isActive: true,
                        activeColor: const Color(0xFF59B2C6),
                        inActiveColor: const Color(0xFF909090),
                      ),
                    ],
                  ),
                  //new features
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 20),
                    child: Row(
                      children: [
                        const Text(
                          "New Features of NearBii",
                          style: TextStyle(
                            fontWeight: FontWeight.w400,
                            fontSize: 18,
                            color: Colors.black,
                          ),
                        ),
                        const Spacer(),
                        CustomSwitch(
                          onTap: () {},
                          isActive: true,
                          activeColor: const Color(0xFF59B2C6),
                          inActiveColor: const Color(0xFF909090),
                        ),
                      ],
                    ),
                  ),
                  //trending
                  Row(
                    children: [
                      const Text(
                        "Trending on NearBii",
                        style: TextStyle(
                          fontWeight: FontWeight.w400,
                          fontSize: 18,
                          color: Colors.black,
                        ),
                      ),
                      const Spacer(),
                      CustomSwitch(
                        onTap: () {},
                        isActive: true,
                        activeColor: const Color(0xFF59B2C6),
                        inActiveColor: const Color(0xFF909090),
                      ),
                    ],
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  //similar businesses
                  Row(
                    children: [
                      const Text(
                        "Similar Businesses",
                        style: TextStyle(
                          fontWeight: FontWeight.w400,
                          fontSize: 18,
                          color: Colors.black,
                        ),
                      ),
                      const Spacer(),
                      InkWell(
                        onTap: () {
                          setState(() {
                            radio = !radio;
                          });
                        },
                        child: Icon(
                          radio
                              ? Icons.radio_button_off_outlined
                              : Icons.radio_button_on_outlined,
                          size: 20,
                          color: kWalletLightTextColor,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
