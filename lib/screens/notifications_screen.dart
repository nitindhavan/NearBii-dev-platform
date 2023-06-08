import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:nearbii/Model/notifStorage.dart';
import 'package:nearbii/constants.dart';
import 'package:nearbii/screens/bottom_bar/profile/vendor_profile_screen.dart';
import 'package:velocity_x/velocity_x.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({Key? key}) : super(key: key);

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  @override
  void initState() {
    getNotifData();
    super.initState();
  }

  List notifs = [];
  getNotifData() async {
    log(FirebaseAuth.instance.currentUser!.uid.substring(0, 20), name: "notif");
    var notified = await FirebaseFirestore.instance
        .collection("User")
        .doc(FirebaseAuth.instance.currentUser!.uid.substring(0, 20))
        .collection("Notifs")
        .doc("notifsIDs")
        .get();
    if (notified.data() != null) {
      List notiList = notified.data()!["id"];
      notiList.sort(
        (a, b) {
          return b["time"].compareTo(a["time"]);
        },
      );
      notifs = notiList;
      log(notifs[0]["uid"].toString());
      setState(() {});
    }
    FirebaseFirestore.instance
        .collection("User")
        .doc(FirebaseAuth.instance.currentUser!.uid.substring(0, 20))
        .set({"newNotif": false}, SetOptions(merge: true)).then(
            (value) => Notifcheck.bell.value = false);
  }

  // List notificationList = [];

  // getNotificationData() {
  //   FirebaseFirestore.instance.collection("notif").get().then((value) {
  //     notificationList.clear();
  //     for (var doc in value.docs) {
  //       notificationList.add(doc.data());
  //       log(notificationList.toString());
  //     }
  //   });
  // }

  @override
  Widget build(BuildContext context) {
    double height = MediaQuery.of(context).size.height;
    double width = MediaQuery.of(context).size.width;

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
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                //Wallet Recharge History label
                Text(
                  "Notifications",
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 20,
                    color: kLoadingScreenTextColor,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 25),
                  child: SizedBox(
                    height: height / 1.25,
                    child: ListView.separated(
                      itemCount: notifs.length,
                      itemBuilder: (context, index) {
                        String metric = "seconds";
                        /*int diff = DateTime.now()
                            .difference(DateTime.fromMillisecondsSinceEpoch(
                                notifs[index]["time"]))
                            .inSeconds;

                        log(diff.toString());
                        if ((diff / 60).toInt() > 0) {
                          metric = "minutes";
                          diff = (diff / 60).toInt();
                          log(diff.toString());
                          if ((diff / 60).toInt() > 0) {
                            metric = "hours";
                            diff = (diff / 60).toInt();
                            log(diff.toString());
                            if ((diff / 24).toInt() > 0) {
                              metric = "days";
                              diff = (diff / 24).toInt();
                              log(diff.toString());
                              if ((diff / 24).toInt() > 0) {
                                metric = "months";
                                diff = (diff / 24).toInt();
                              }
                            }
                          }
                        }*/
                        String name = "${notifs[index]["name"]} posted an Ad";
                        /* String offer = notifs[index]["isOffer"]
                            ? " posted an Offer"
                            : " posted an Ad";
                        name = name + offer;*/
                        /*  log(diff.toString());*/
                        log(metric);
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                //image section
                                CircleAvatar(
                                  backgroundImage:
                                      NetworkImage(notifs[index]["image"]),
                                ),
                                const SizedBox(
                                  width: 10,
                                ),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    //business/username
                                    Text(
                                      name,
                                      style: TextStyle(
                                        fontWeight: FontWeight.w400,
                                        fontSize: 18,
                                        color: kLoadingScreenTextColor,
                                      ),
                                    ),
                                    // Text(
                                    //   "/*{diff} {metric}*/ ago",
                                    //   style: TextStyle(
                                    //     fontWeight: FontWeight.w400,
                                    //     fontSize: 16,
                                    //     fontStyle: FontStyle.italic,
                                    //     color: kSplashScreenDescriptionColor,
                                    //   ),
                                    // ),
                                  ],
                                ),
                              ],
                            ),
                          ],
                        ).onInkTap(() {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => VendorProfileScreen(
                                      id: notifs[index]["uid"],
                                      isVisiter: true,
                                    )),
                          );
                        });
                      },
                      separatorBuilder: (context, index) =>
                          const SizedBox(height: 16),
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
