import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:nearbii/Model/PlanModel.dart';
import 'package:nearbii/Model/notifStorage.dart';
import 'package:nearbii/constants.dart';
import 'package:nearbii/screens/bottom_bar/master_screen.dart';
import 'package:nearbii/screens/plans/plans/plan_screen.dart';
import 'package:nearbii/services/sendNotification/notificatonByCity/cityNotiication.dart';
import 'package:nearbii/services/transactionupdate/transactionUpdate.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:velocity_x/velocity_x.dart';

class adsPlan extends StatefulWidget {
  const adsPlan({super.key});

  @override
  State<adsPlan> createState() => _adsPlanState();
}

class _adsPlanState extends State<adsPlan> {
  late FirebaseFirestore db;

  late FirebaseStorage storage;

  late final Razorpay _razorpay = Razorpay();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    loadBalance();
  }

  int balance = 0;

  loadBalance() async {
    await FirebaseFirestore.instance
        .collection('User')
        .doc(uid)
        .get()
        .then((value) {
      setState(() {
        balance = value.get("wallet");
      });
    });
    await FirebaseFirestore.instance
        .collection('vendor')
        .doc(uid)
        .get()
        .then((value) {
      try {
        setState(() {
          lefthours =
              DateTime.fromMillisecondsSinceEpoch(value.get("adsBuyTimestamp"))
                  .difference(DateTime.now())
                  .inHours;
        });
      } catch (e) {
        setState(() {
          lefthours = -1;
        });
      }
    });
  }

  @override
  void dispose() {
    super.dispose();
  }

  int lefthours = 0;
  final uid = FirebaseAuth.instance.currentUser!.uid.substring(0, 20);

  PlanModel? plan;
  Future<void> loadPlan() async {
    DocumentReference store=FirebaseFirestore.instance.collection('plans').doc(FirebaseAuth.instance.currentUser?.uid.substring(0,20));
    await store.get().then((value){
      if(value.exists) {
        plan = PlanModel.fromSnapshot(
            value as DocumentSnapshot<Map<String, dynamic>>);
        print("plan" + plan.toString());
        if (plan != null && plan!.validity! < DateTime
            .now()
            .millisecondsSinceEpoch) {
          store.delete();
          plan = null;
        }
      }else{
        plan=null;
      }
    });
  }
  void buyPlane(context) async {
    // await loadBalance();
    await loadPlan();
    print(lefthours);

    if (lefthours <= 0) {
      if (plan == null || plan!.adPost! < 1) {
        Navigator.push(context, MaterialPageRoute(builder: (context)=> PlanScreen()));
      } else {
        Fluttertoast.showToast(
            msg: "Posting an Ad", toastLength: Toast.LENGTH_LONG);
        plan!.adPost = plan!.adPost!-1;

        log(uid);
        print('user id is $uid');

        await FirebaseFirestore.instance
            .collection('plans')
            .doc(uid)
            .set(plan!.toMap())
            .then((value) async {
              //update wallet
            updateWallet(uid, "Ads Plan", false, 1, DateTime.now().millisecondsSinceEpoch, 0);
          Fluttertoast.showToast(msg: "Debited 1 Ad offer from wallet");

          Map<String, dynamic> data = {};

          data["adsBuyTimestamp"] = DateTime.now().millisecondsSinceEpoch +
              const Duration(days: 1).inMilliseconds;
          data["isAds"] = true;

          await FirebaseFirestore.instance
              .collection('vendor')
              .doc(uid)
              .set(data, SetOptions(merge: true))
              .then((value) async {
            sendNotiicationAd(
                Notifcheck.currentVendor!.businessName,
                Notifcheck.currentVendor!.businessImage.isEmptyOrNull
                    ? Notifcheck.defCover
                    : Notifcheck.currentVendor!.businessImage);

            Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(builder: ((context) {
              return const MasterPage(
                currentIndex: 0,
              );
            })), (route) => false);
          }).onError((error, stackTrace) async {});
        });
      }
    } else {
      print(lefthours);
      Fluttertoast.showToast(
          msg:
              "$lefthours Hours are Still Left.You cannot Post Ads Till $lefthours Hours");
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
        top: false,
        child: Scaffold(
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
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 34),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  //Plans  label
                  Text(
                    "Plans ",
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 20,
                      color: kLoadingScreenTextColor,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 30, bottom: 25),
                    child: Container(
                      width: double.infinity,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(5),
                        color: Colors.white,
                        boxShadow: [
                          BoxShadow(
                            color: kPlansDescriptionTextColor,
                            offset: Offset.zero,
                            spreadRadius: 0.1,
                            blurRadius: 6,
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: const EdgeInsets.fromLTRB(10, 10, 10, 26),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "NearBii Ads",
                                  style: TextStyle(
                                    fontWeight: FontWeight.w700,
                                    fontSize: 20,
                                    color: kLoadingScreenTextColor,
                                  ),
                                ),
                                Padding(
                                  padding:
                                      const EdgeInsets.only(top: 5, bottom: 2),
                                  child: Text(
                                    "Redeem 50 points",
                                    style: TextStyle(
                                      fontWeight: FontWeight.w400,
                                      fontSize: 18,
                                      color: kLoadingScreenTextColor,
                                    ),
                                  ),
                                ),
                                Text(
                                  "Appear on the top  of our list in our category ",
                                  style: TextStyle(
                                    fontWeight: FontWeight.w400,
                                    fontSize: 11,
                                    color: kPlansDescriptionTextColor,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Container(
                            height: 190,
                            width: double.infinity,
                            color: kHomeScreenServicesContainerColor,
                            child: Image.asset(
                                'assets/images/advertise/plans/nearbii_ads_image.png'),
                          ),
                          Padding(
                            padding: const EdgeInsets.fromLTRB(30, 37, 20, 30),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Icon(
                                      Icons.check_circle,
                                      color: kSignUpContainerColor,
                                      size: 20,
                                    ),
                                    const SizedBox(
                                      width: 20,
                                    ),
                                    const Flexible(
                                      child: Text(
                                        "Appear on the top of list in your category. ",
                                        style: TextStyle(
                                          fontWeight: FontWeight.w400,
                                          fontSize: 16,
                                          color: Colors.black,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                Padding(
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 10),
                                  child: Row(
                                    children: [
                                      Icon(
                                        Icons.check_circle,
                                        color: kSignUpContainerColor,
                                        size: 20,
                                      ),
                                      const SizedBox(
                                        width: 20,
                                      ),
                                      const Flexible(
                                        child: Text(
                                          "Users around your area will get notified in notification bell. ",
                                          style: TextStyle(
                                            fontWeight: FontWeight.w400,
                                            fontSize: 16,
                                            color: Colors.black,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Row(
                                  children: [
                                    Icon(
                                      Icons.check_circle,
                                      color: kSignUpContainerColor,
                                      size: 20,
                                    ),
                                    const SizedBox(
                                      width: 20,
                                    ),
                                    const Flexible(
                                      child: Text(
                                        "Ad Visible for every user around you in your category.",
                                        style: TextStyle(
                                          fontWeight: FontWeight.w400,
                                          fontSize: 16,
                                          color: Colors.black,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                Padding(
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 10),
                                  child: Row(
                                    children: [
                                      Icon(
                                        Icons.check_circle,
                                        color: kSignUpContainerColor,
                                        size: 20,
                                      ),
                                      const SizedBox(
                                        width: 20,
                                      ),
                                      const Flexible(
                                        child: Text(
                                          "Redeem your Nearbii points to advertise or buy more points via Nearbii wallet.",
                                          style: TextStyle(
                                            fontWeight: FontWeight.w400,
                                            fontSize: 16,
                                            color: Colors.black,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Row(
                                  children: [
                                    Icon(
                                      Icons.check_circle,
                                      color: kSignUpContainerColor,
                                      size: 20,
                                    ),
                                    const SizedBox(
                                      width: 20,
                                    ),
                                    const Flexible(
                                      child: Text(
                                        "Valid for 1day.",
                                        style: TextStyle(
                                          fontWeight: FontWeight.w400,
                                          fontSize: 16,
                                          color: Colors.black,
                                        ),
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
                  ),
                  InkWell(
                    onTap: () {
                      buyPlane(context);
                    },
                    child: Container(
                        width: MediaQuery.of(context).size.width * 0.80,
                        margin: const EdgeInsets.only(top: 10),
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: const Color.fromRGBO(81, 182, 200, 1),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        alignment: Alignment.center,
                        child: const Text(
                          "Done",
                          style: TextStyle(color: Colors.white, fontSize: 20),
                        )),
                  ),
                  const SizedBox(
                    height: 30,
                  ),
                ],
              ),
            ),
          ),
        ));
  }
}
