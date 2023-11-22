import 'dart:developer';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:nearbii/Model/notifStorage.dart';
import 'package:nearbii/screens/auth/auth_services.dart';
import 'package:nearbii/services/case_search_generator.dart';
import 'package:nearbii/services/sendNotification/notificatonByCity/cityNotiication.dart';
import 'package:nearbii/services/setUserMode.dart';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:nearbii/constants.dart';
import 'package:nearbii/screens/createEvent/paymentDone/paymentDone.dart';
import 'package:nearbii/services/transactionupdate/transactionUpdate.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';
import 'package:velocity_x/velocity_x.dart';

class NearBiiMembershipPlanScreen extends StatefulWidget {
  final Map<String, dynamic> businessDetailData;
  final bool renew;
  const NearBiiMembershipPlanScreen(
      {required this.businessDetailData, this.renew = false, Key? key})
      : super(key: key);

  @override
  State<NearBiiMembershipPlanScreen> createState() =>
      _NearBiiMembershipPlanScreenState();
}

class _NearBiiMembershipPlanScreenState
    extends State<NearBiiMembershipPlanScreen> {
  String? uid = FirebaseAuth.instance.currentUser!.uid.substring(0, 20);

  late final Razorpay _razorpay = Razorpay();

  int balance = 0;

  String referalCode = "";

  loadBalance() async {
    log(uid.toString());
    await FirebaseFirestore.instance
        .collection('User')
        .doc(uid)
        .get()
        .then((value) {
      setState(() {
        balance = value.get("wallet");
        referalCode = value.get("referalcode");
      });
    });
  }

  saveToDB(String? path, String paymentID, String orderId, String sig) async {
    FirebaseFirestore db = FirebaseFirestore.instance;

    if (!widget.renew) {
      print('runnnn');
      // var fileName = File(path);
      if (path.isNotEmptyAndNotNull) {
        Reference reference = FirebaseStorage.instance.ref().child(
            'businessImage/' +
                FirebaseAuth.instance.currentUser!.uid.substring(0, 20) +
                ".jpg");
        TaskSnapshot snapshot = await reference.putFile(File(path!));

        var imageUrl = await snapshot.ref.getDownloadURL();

        widget.businessDetailData["businessImage"] = imageUrl;
      }
      List<String> cases = [];
      cases.add(widget.businessDetailData["businessPinCode"]);
      cases.add(widget.businessDetailData["name"]);
      cases.add(widget.businessDetailData["bussinesDesc"]);
      cases.add(widget.businessDetailData["businessName"]);
      cases.add(widget.businessDetailData["businessMobileNumber"]);
      cases.add(widget.businessDetailData["businessCity"]);
      cases.add(widget.businessDetailData["businessCat"]);
      cases.add(widget.businessDetailData["businessAddress"]);
      var generateCases = generateCaseSearches(cases);
      widget.businessDetailData["caseSearch"] = generateCases;
      widget.businessDetailData["isImported"] = false;
      widget.businessDetailData["importedFrom"] = "Paid User";
      widget.businessDetailData["bookmarks"] = [];

      await db
          .collection("vendor")
          .doc(uid.toString())
          .collection("Notifs")
          .doc("notifsIDs")
          .set({"id": []});
    }
    print('runnnn2');
    widget.businessDetailData["rating"] = 0.0;
    await db
        .collection("vendor")
        .doc(uid)
        .set(widget.businessDetailData)
        .then((value) async {
      Fluttertoast.showToast(msg: "Saved");
      var referalCheck = await checkReferalCode(referalCode);
      if (referalCheck.uid.isNotEmptyAndNotNull) {
        updateReferalWallet(referalCode, uid, referalCheck);
      }
      Map<String, dynamic> userdata = {};
      Map<String, dynamic> memberData = {};
      userdata["type"] = "Vendor";

      Map<String, dynamic> member = {};

      member["isMember"] = true;
      member["joinDate"] = Timestamp.now();
      member["endDate"] = Timestamp.now().millisecondsSinceEpoch +
          const Duration(days: 3650).inMilliseconds;

      userdata["member"] = member;
      userdata["joinDate"] = Timestamp.now().millisecondsSinceEpoch;
      userdata["endDate"] = Timestamp.now().millisecondsSinceEpoch +
          const Duration(days: 3650).inMilliseconds;

      await db
          .collection("User")
          .doc(uid)
          .set(userdata, SetOptions(merge: true))
          .then((value) async {
        Fluttertoast.showToast(msg: "Membership Updated");

        Map<String, dynamic> wallet = {};

        wallet["wallet"] = balance + 499;

        await FirebaseFirestore.instance
            .collection('User')
            .doc(uid)
            .update(wallet)
            .then((e) {
          Fluttertoast.showToast(msg: "Cashback Added");
          setVendorMode();
          updateWallet(uid, "MemberShip Plan Cashback", true, 499,
              DateTime.now().millisecondsSinceEpoch, balance);
        });
      });
      Notifcheck.api.disableCoupan(widget.businessDetailData["coupan"]);
      sendNotificationForVendor(widget.businessDetailData["name"]);
      return true;
    }).onError((error, stackTrace) {
      Fluttertoast.showToast(msg: "Error to Save model");
      return false;
    });
  }

  bool paymen = false;
  void _handlePaymentSuccess(PaymentSuccessResponse response) async {
    setState(() {
      paymen = true;
    });
    updateTransatcion(uid, "Memebership plan", response.paymentId, "success",
        499, DateTime.now().millisecondsSinceEpoch);
    widget.businessDetailData["paymentId"] = response.paymentId;
    widget.businessDetailData["payment"] = "Success";
    widget.businessDetailData["isAds"] = false;
    widget.businessDetailData["timestamp"] = Timestamp.now();
    widget.businessDetailData["adsBuyTimestamp"] = 0;

    await saveToDB(
        widget.businessDetailData["businessImage"],
        response.paymentId.toString(),
        response.orderId.toString(),
        response.signature.toString());
    var referalCheck = await checkReferalCode(referalCode);
    if (referalCheck.uid.isNotEmptyAndNotNull) {
      updateReferalWallet(referalCode, uid, referalCheck);
    }
    Fluttertoast.showToast(
        msg: "SUCCESS: " + response.paymentId!,
        toastLength: Toast.LENGTH_SHORT);
    print('image ${widget.businessDetailData["businessImage"]}');
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

    loadBalance();

    _razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, _handlePaymentSuccess);
    _razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, _handlePaymentError);
    _razorpay.on(Razorpay.EVENT_EXTERNAL_WALLET, _handleExternalWallet);
  }

  void buyMembership() async {
    var key ='rzp_live_EaquIenmibGbWl';
        // : 'rzp_live_EaquIenmibGbWl';
    var options = {
      //TODO:test key when deployment then change key
      // 'key': 'rzp_test_q0FLy0FYnKC94V',
      'key': key,
      'amount': 49900.0,
      'name': 'NearBii Membership Plan',
      'description': 'Join the large world',
      // 'retry': {'enabled': true, 'max_count': 1},
      // 'send_sms_hash': true,
      // 'prefill': {'contact': '8888888888', 'email': 'test@razorpay.com'},
      'external': {
        'wallets': ['paytm']
      }
    };
    bool isCoupan = await Notifcheck.api
        .checkCoupan(coupan: widget.businessDetailData["coupan"]);

    try {
      if (isCoupan) {
        Fluttertoast.showToast(msg: "Coupon Applied !!");
        PaymentSuccessResponse response = PaymentSuccessResponse(
            widget.businessDetailData["coupan"], "orderId", "signature");
        _handlePaymentSuccess(response);
        Fluttertoast.showToast(msg: "Coupan Applied");
      } else {
        _razorpay.open(options);
      }
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
      body: paymen
          ? const paymentDone()
          : SingleChildScrollView(
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
                              padding:
                                  const EdgeInsets.fromLTRB(10, 10, 10, 26),
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
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
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
                                            decoration:
                                                TextDecoration.lineThrough,
                                            fontWeight: FontWeight.w400,
                                            fontSize: 10,
                                            color:
                                                kSplashScreenDescriptionColor,
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
                              padding:
                                  const EdgeInsets.fromLTRB(30, 37, 20, 64),
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
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 10),
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
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 10),
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
                        if (paymen) return;
                        buyMembership();
                      },
                      child: Container(
                        width: double.infinity,
                        height: 50,
                        decoration: BoxDecoration(
                          color: paymen ? Colors.grey : kSignInContainerColor,
                          borderRadius: BorderRadius.circular(5),
                        ),
                        child: const Center(
                          child: Text(
                            "Make Payment",
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
