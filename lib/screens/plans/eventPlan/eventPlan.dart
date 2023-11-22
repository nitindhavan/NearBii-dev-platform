import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:nearbii/constants.dart';
import 'package:nearbii/screens/createEvent/paymentDone/paymentDone.dart';
import 'package:nearbii/services/case_search_generator.dart';
import 'package:nearbii/services/savePaymentRecipt/savePaymentRecipt.dart';
import 'package:nearbii/services/sendNotification/notificatonByCity/cityNotiication.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';
import 'package:fluttertoast/fluttertoast.dart';
import '../../../services/transactionupdate/transactionUpdate.dart';


class eventPlan extends StatefulWidget {
  final Map<String, dynamic> eventInfo;
  final List<String> path;
  const eventPlan({required this.eventInfo, required this.path, Key? key})
      : super(key: key);

  @override
  State<eventPlan> createState() => _eventPlanState();
}

class _eventPlanState extends State<eventPlan> {

  late FirebaseFirestore db;

  late final Razorpay _razorpay = Razorpay();

  saveToDB(List<String> path) async {
    int i = 0;
    List imageUrl = [];
    for (var img in path) {
      var fileName = File(path[i]);

      Reference reference = FirebaseStorage.instance
          .ref()
          .child('profileImage/${fileName.absolute.toString()}');
      UploadTask uploadTask = reference.putFile(File(path[i]));
      TaskSnapshot snapshot = await uploadTask;
      String temp = await snapshot.ref.getDownloadURL();
      imageUrl.add(temp);
      i++;
    }

    widget.eventInfo["eventImage"] = imageUrl;
    print(imageUrl);
    List<String> cases = [];
    cases.add(widget.eventInfo["eventDesc"]!);
    cases.add(widget.eventInfo["pin"]!);
    cases.add(widget.eventInfo["org"]);
    cases.add(widget.eventInfo["city"]!);
    cases.add(widget.eventInfo["addr"]!);
    cases.add(widget.eventInfo["eventCat"]!);
    cases.add(widget.eventInfo["name"]!);
    List<String> caseSearches = generateCaseSearches(cases);
    widget.eventInfo["caseSearch"] = caseSearches;

    db = FirebaseFirestore.instance;

    await db.collection("Events").add(widget.eventInfo).then((value) {
      Fluttertoast.showToast(msg: "Event Saved");
      sendNotiicationByCity(widget.eventInfo["name"],
          widget.eventInfo["eventTargetCity"], value.id, "event",imageUrl.first);
    }).onError((error, stackTrace) {
      Fluttertoast.showToast(msg: "Error to Save model");
    });
  }

  void _handlePaymentSuccess(PaymentSuccessResponse response) async {
    Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: ((context) {
      return const paymentDone();
    })), (route) => false);
    updateTransatcion(
        FirebaseAuth.instance.currentUser!.uid.substring(0, 20),
        "NearBii Add Event Price",
        response.paymentId,
        "success",
        999,
        DateTime.now().millisecondsSinceEpoch);

    widget.eventInfo["payment_id"] = response.paymentId;
    widget.eventInfo["payment"] = "Success";

    Fluttertoast.showToast(
        msg: "SUCCESS: " + response.paymentId!,
        toastLength: Toast.LENGTH_SHORT);

    Fluttertoast.showToast(
        msg: "Event Name is:" + widget.eventInfo["eventDesc"]);

    saveRecipt(999, response.paymentId!, "Event Added");

    await saveToDB(widget.path);
  }

  void _handlePaymentError(PaymentFailureResponse response) {
    widget.eventInfo["payment_id"] = "null";
    widget.eventInfo["payment"] = "Failed";
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

  @override
  void dispose() {
    super.dispose();
    _razorpay.clear();
  }

  void buyPlane() async {
    //TODO changes are must here while releasing
    var key='rzp_live_EaquIenmibGbWl';
    // var key = kDebugMode || kProfileMode
    //     ? 'rzp_test_q0FLy0FYnKC94V'
    //     : 'rzp_live_EaquIenmibGbWl';
    var options = {
      //TODO:test key when deployment then change key
      // 'key': 'rzp_test_q0FLy0FYnKC94V',
      'key': key,
      'amount': 99900.0,
      'name': 'NearBii Add Event Price',
      'description': 'Pay for events and enjoy with croud',
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
                    padding: const EdgeInsets.only(top: 30, bottom: 0),
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
                            padding: const EdgeInsets.fromLTRB(10, 10, 10, 0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "NearBii Events",
                                  style: TextStyle(
                                    fontWeight: FontWeight.w700,
                                    fontSize: 20,
                                    color: kLoadingScreenTextColor,
                                  ),
                                ),
                                const SizedBox(
                                  height: 5,
                                ),
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
                                        text: '999',
                                        style: TextStyle(
                                          fontWeight: FontWeight.w400,
                                          fontSize: 20,
                                          color: kLoadingScreenTextColor,
                                        ),
                                      ),
                                      TextSpan(
                                        text: '/event',
                                        style: TextStyle(
                                          fontWeight: FontWeight.w400,
                                          fontSize: 12,
                                          color: kLoadingScreenTextColor,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Text(
                                  "Make yourself visible to every user in the target city",
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
                                'assets/images/advertise/plans/nearbii_events_image.png'),
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
                                        "Event visible to every user in the target city.",
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
                                          "Push notification to every user in the target city.",
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
                                        "Event visible in events window and category of event.",
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
                                          "Pay via payment gateway.",
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
                                        "Valid till end day of the event. ",
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
                      buyPlane();
                    },
                    child: Container(
                        width: MediaQuery.of(context).size.width * 0.80,
                        margin: const EdgeInsets.only(top: 20),
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: const Color.fromRGBO(81, 182, 200, 1),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        alignment: Alignment.center,
                        child: const Text(
                          "Make Payment",
                          style: TextStyle(color: Colors.white, fontSize: 20),
                        )),
                  ),
                ],
              ),
            ),
          ),
        ));
  }
}
