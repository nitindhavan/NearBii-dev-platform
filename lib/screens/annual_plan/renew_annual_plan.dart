import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:nearbii/constants.dart';
import 'package:nearbii/screens/createEvent/paymentDone/paymentDone.dart';
import 'package:nearbii/services/savePaymentRecipt/savePaymentRecipt.dart';
import 'package:nearbii/services/transactionupdate/transactionUpdate.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';

class RenewAnnualPlanScreen extends StatefulWidget {
  bool check;
  DateTime end;
  RenewAnnualPlanScreen({Key? key, required this.check, required this.end})
      : super(key: key);

  @override
  State<RenewAnnualPlanScreen> createState() => _RenewAnnualPlanScreenState();
}

class _RenewAnnualPlanScreenState extends State<RenewAnnualPlanScreen> {
  late final Razorpay _razorpay = Razorpay();

  late FirebaseFirestore db;
  final uid = FirebaseAuth.instance.currentUser!.uid.substring(0, 20);
  saveToDB() async {
    db = FirebaseFirestore.instance;

    Map<String, dynamic> member = {};
    if (!widget.check) {
      await db.collection("User").doc(uid).set({
        "endDate": DateTime(DateTime.now().year + 1, DateTime.now().month,
                DateTime.now().day, DateTime.now().hour, DateTime.now().minute)
            .millisecondsSinceEpoch
      }, SetOptions(merge: true));
    } else {
      log((const Duration(days: 1).inMilliseconds * 365).toString());
      await db.collection("User").doc(uid).set({
        "endDate": DateTime(widget.end.year + 1, widget.end.month,
                widget.end.day, widget.end.hour, widget.end.minute)
            .millisecondsSinceEpoch
      }, SetOptions(merge: true));
    }

    Fluttertoast.showToast(msg: "Membership Updated");
  }

  void _handlePaymentSuccess(PaymentSuccessResponse response) async {
    Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (context) {
      return const paymentDone();
    }), (route) => false);
    updateTransatcion(
        FirebaseAuth.instance.currentUser!.uid.substring(0, 20),
        "Renewal Memebership plan",
        response.paymentId,
        "success",
        499,
        DateTime.now().millisecondsSinceEpoch);

    updateTransatcion(
        FirebaseAuth.instance.currentUser!.uid.substring(0, 20),
        "Renewal Memebership plan",
        response.paymentId,
        "success",
        499,
        DateTime.now().millisecondsSinceEpoch);
    Fluttertoast.showToast(
        msg: "SUCCESS: " + response.paymentId!,
        toastLength: Toast.LENGTH_SHORT);

    saveRecipt(
      499,
      response.paymentId!,
      "Renewal Memberhip",
    );
    saveToDB();
  }

  void _handlePaymentError(PaymentFailureResponse response) {
    Fluttertoast.showToast(
        msg: "Payment Failed. Event Not Added",
        toastLength: Toast.LENGTH_SHORT);

    //saveToDB();
  }

  void _handleExternalWallet(ExternalWalletResponse response) {
    // Fluttertoast.showToast(
    //     msg: "EXTERNAL_WALLET: " + response.walletName!, toastLength: Toast.LENGTH_SHORT);
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    _razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, _handlePaymentSuccess);
    _razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, _handlePaymentError);
    _razorpay.on(Razorpay.EVENT_EXTERNAL_WALLET, _handleExternalWallet);
  }

  void buyMembership() async {
    var key = kDebugMode || kProfileMode
        ? 'rzp_test_q0FLy0FYnKC94V'
        : 'rzp_live_EaquIenmibGbWl';
    var options = {
      //TODO:test key when deployment then change key
      // 'key': 'rzp_test_q0FLy0FYnKC94V',
      'key': key,
      'amount': 49900.0,
      'name': 'NearBii Update Membership Plan',
      'description': 'Join the large world',
      // 'retry': {'enabled': true, 'max_count': 1},
      // 'send_sms_hash': true,
      // 'prefill': {'contact': '8888888888', 'email': 'test@razorpay.com'},
      'external': {
        'wallets': ['paytm']
      }
    };

    try {
      _razorpay.open(options);
    } catch (e) {
      debugPrint('Error: e' + e.toString());
    }
  }

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
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 34),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              //ANNUAL PLAN  label
              Center(
                child: Text(
                  "ANNUAL PLAN",
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 20,
                    color: kLoadingScreenTextColor,
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 30, bottom: 45),
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
                              "NearBii Membership Plan",
                              style: TextStyle(
                                fontWeight: FontWeight.w700,
                                fontSize: 20,
                                color: kLoadingScreenTextColor,
                              ),
                            ),
                            const SizedBox(
                              height: 5,
                            ),
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                RichText(
                                  softWrap: true,
                                  text: TextSpan(
                                    text: '₹',
                                    style: TextStyle(
                                      fontWeight: FontWeight.w400,
                                      fontSize: 12,
                                      color: kLoadingScreenTextColor,
                                    ),
                                    children: [
                                      TextSpan(
                                        text: '499',
                                        style: TextStyle(
                                          fontWeight: FontWeight.w400,
                                          fontSize: 20,
                                          color: kLoadingScreenTextColor,
                                        ),
                                      ),
                                      TextSpan(
                                        text: '/year',
                                        style: TextStyle(
                                          fontWeight: FontWeight.w400,
                                          fontSize: 12,
                                          color: kLoadingScreenTextColor,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(
                                  width: 12,
                                ),
                                Padding(
                                  padding: const EdgeInsets.only(top: 7),
                                  child: Text(
                                    "₹1499/year",
                                    style: TextStyle(
                                      decoration: TextDecoration.lineThrough,
                                      fontWeight: FontWeight.w400,
                                      fontSize: 10,
                                      color: kSplashScreenDescriptionColor,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            Text(
                              "For Listing a Business/Service and Renewal",
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
                            'assets/images/membership_plan/nearbii_membership_plan.png'),
                      ),
                      Padding(
                        padding: const EdgeInsets.fromLTRB(30, 37, 20, 64),
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
                                    "Nearbii annual membership. ",
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
                              padding: const EdgeInsets.symmetric(vertical: 10),
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
                                      "Get 100% cashback in the form of nearbii reward points in your nearbii wallet. ",
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
                                    "Access to all the features of promotions. ",
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
                              padding: const EdgeInsets.symmetric(vertical: 10),
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
                                      "Valid for 1year",
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
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              GestureDetector(
                onTap: () {
                  buyMembership();
                },
                child: Container(
                  width: double.infinity,
                  height: 50,
                  decoration: BoxDecoration(
                    color: kSignInContainerColor,
                    borderRadius: BorderRadius.circular(5),
                  ),
                  child: const Center(
                    child: Text(
                      "Renew Plan",
                      style: TextStyle(
                        fontWeight: FontWeight.w400,
                        fontSize: 20,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(
                height: 61,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
