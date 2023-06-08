import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:nearbii/constants.dart';
import 'package:nearbii/screens/bottom_bar/offers_screen.dart';
import 'package:nearbii/screens/wallet/referal.dart';
import 'package:nearbii/screens/wallet/transaction_history_screen.dart';
import 'package:nearbii/services/transactionupdate/transactionUpdate.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';
import 'package:velocity_x/velocity_x.dart';

import '../../Model/notifStorage.dart';
import '../../Model/referal_transaction_model.dart';
import '../plans/plans/plan_screen.dart';

class WalletScreen extends StatefulWidget {
  const WalletScreen({Key? key}) : super(key: key);

  @override
  State<WalletScreen> createState() => _WalletScreenState();
}

class _WalletScreenState extends State<WalletScreen> {
  int addBalance = 0;

  int myBalance = 0;

  int beforeBalance = 0;

  TextEditingController inpBalance = TextEditingController();

  List<int> balanceAmount = [100, 200, 500, 1000];

  late FirebaseFirestore db;

  final uid = FirebaseAuth.instance.currentUser!.uid.substring(0, 20);

  late final Razorpay _razorpay = Razorpay();

  Map<String, dynamic> walletData = {};

  var referalBalance = 0;

  var lastDocument;

  bool more = true;

  String referCode = "";
  int referBalance = 0;

  checkAndCreateReferal() async {
    if (!Notifcheck.userDAta.containsKey("referCode") ||
        Notifcheck.userDAta["referCode"].toString().isEmptyOrNull) {
      referCode = FirebaseAuth.instance.currentUser!.uid.substring(5, 10);
      await Notifcheck.api.updateUserData(uid, {"referCode": referCode});
    } else {
      referCode = Notifcheck.userDAta["referCode"];
    }
    var userData = await Notifcheck.api.fetchUserData(refresh: true);
    if (!userData.containsKey("referBalance") ||
        userData["referBalance"].toString().isEmptyOrNull) {
      referBalance = 0;
      await Notifcheck.api.updateUserData(uid, {"referBalance": referBalance});
    } else {
      referBalance = userData["referBalance"];
    }
    log(referCode);
    setState(() {});
  }

  Future<void> _handlePaymentSuccess(PaymentSuccessResponse response) async {
    updateTransatcion(
        FirebaseAuth.instance.currentUser!.uid.substring(0, 20),
        "Wallet Money Added",
        response.paymentId,
        "success",
        addBalance,
        DateTime.now().millisecondsSinceEpoch);
    setState(() {
      myBalance += addBalance;
    });

    Map<String, dynamic> data = {};

    data["wallet"] = myBalance;

    await FirebaseFirestore.instance
        .collection('User')
        .doc(uid)
        .update(data)
        .then((value) {
      Fluttertoast.showToast(msg: "Point Added");
    });

    Fluttertoast.showToast(msg: addBalance.toString() + " Point is Added");

    updateWallet(uid, "Points Added", true, addBalance,
        DateTime.now().millisecondsSinceEpoch, myBalance);
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

    checkAndCreateReferal();
    getReferalHistory();

    _razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, _handlePaymentSuccess);
    _razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, _handlePaymentError);
    _razorpay.on(Razorpay.EVENT_EXTERNAL_WALLET, _handleExternalWallet);
  }

  List<ReferalTransactionModel> referalTransactions = [];
  getReferalHistory() async {
    var snap = FirebaseFirestore.instance
        .collection('User')
        .doc(uid)
        .collection("referalWallet")
        .orderBy("timestamp", descending: true);
    if (lastDocument != null) {
      snap = snap.startAfterDocument(lastDocument);
    }
    QuerySnapshot<Map<String, dynamic>> snapshot = await snap.limit(10).get();
    if (snapshot.docs.isNotEmpty) {
      more = true;
      lastDocument = snapshot.docs.last;
      for (var referal in snapshot.docs) {
        referalTransactions
            .add(ReferalTransactionModel.fromMap(referal.data()));
      }
      setState(() {});
    } else {
      more = false;
      setState(() {});
    }
  }
  loadBalance() async {
    await FirebaseFirestore.instance
        .collection('User')
        .doc(uid)
        .get()
        .then((value) {
      setState(() {
        myBalance = value.get("wallet");
        beforeBalance = myBalance;
        referalBalance = value.data()!.containsKey("referBalance")
            ? value.data()!["referBalance"]
            : 0;
      });
    });

    var collection = await FirebaseFirestore.instance
        .collection("User")
        .doc(uid)
        .collection("wallet")
        .doc("lastSummary")
        .get();

    try {
      var data = collection.data();

      if (data != null) {
        setState(() {
          walletData["lastRecharge"] = data["lastAmount"];
          walletData["afterRecharge"] = data["currbalce"];
          walletData["beforeRecharge"] = data["bill"];

          print(walletData.toString());
        });
      }
    } catch (e) {
      print("Something is wrong to get last recharge: " + e.toString());
    }

    // for (var doc in querySnapshot.docs) {
    //   Map<String, dynamic> data = doc.data();
    //   var rate = data['starRate']; // <-- Retrieving the value.

    // }

    // await FirebaseFirestore.instance
    //     .collection('vendor')
    //     .doc(uid)
    //     .collection("wallet")
    //     .get()
    //     .then((value) {
    //   setState(() {
    //     print(value);
    //   });
    // });
  }

  addNewBalance() {
    var amount = addBalance * 100.0;
    var key = kDebugMode || kProfileMode
        ? 'rzp_test_q0FLy0FYnKC94V'
        : 'rzp_live_EaquIenmibGbWl';
    var options = {
      //TODO:test key when deployment then change key
      // 'key': 'rzp_test_q0FLy0FYnKC94V',
      'key': key,
      'amount': amount,
      'name': 'NearBii Add to Wallet',
      'description': 'Add points',
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
    double width = MediaQuery.of(context).size.width;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: kSignInContainerColor,
        leading: Row(
          children: [
            const SizedBox(
              width: 16,
            ),
            GestureDetector(
              onTap: () => Navigator.pop(context),
              child: Icon(
                Icons.arrow_back_ios,
                size: 20,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            Container(padding: EdgeInsets.only(top: 32,bottom: 32),
            decoration: BoxDecoration(
              color: kSignInContainerColor,
              borderRadius: BorderRadius.only(bottomLeft: Radius.circular(32),bottomRight: Radius.circular(32))
            ),
            width: double.infinity,
            child: Column(
              children: [
                Text("Balance",style: TextStyle(fontWeight: FontWeight.bold,fontSize: 20,color: Colors.white),),
                SizedBox(height: 16,),
                Text(myBalance.toString(),style: TextStyle(fontSize: 32,fontWeight: FontWeight.bold,color: Colors.white),),
                SizedBox(height: 24,),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: TextButton(
                        onPressed: (){
                          Navigator.push(context, MaterialPageRoute(builder: (context)=> PlanScreen()));
                        },
                        child: Column(
                          children: [
                            Container(height: 50,width: 50,decoration: BoxDecoration(color: Colors.white,borderRadius: BorderRadius.circular(50)),child: Icon(Icons.subscriptions_outlined),),
                            SizedBox(height: 8,),
                            Text("View Plans",style: TextStyle(fontSize: 12,color: Colors.white),),
                          ],
                        ),
                      ),
                    ),
                    Expanded(
                      child: TextButton(
                        onPressed: (){
                          Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (context) => const TransactionHistoryScreen(false),
                              ));
                        },

                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Container(height: 50,width: 50,decoration: BoxDecoration(color: Colors.white,borderRadius: BorderRadius.circular(50)),child: Icon(Icons.payments),),
                            SizedBox(height: 8,),
                            Text("Wallet History",style: TextStyle(fontSize: 12,color: Colors.white),textAlign: TextAlign.center,),
                          ],
                        ),
                      ),
                    ),
                    Expanded(
                      child: TextButton(
                        onPressed: (){
                          Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (context) => const TransactionHistoryScreen(true),
                              ));
                        },
                        child: Column(
                          children: [
                            Container(height: 50,width: 50,decoration: BoxDecoration(color: Colors.white,borderRadius: BorderRadius.circular(50)),child: Icon(Icons.history),),
                            SizedBox(height: 8,),
                            Text("Transaction History",style: TextStyle(fontSize: 12,color: Colors.white),textAlign: TextAlign.center,),
                          ],
                        ),
                      ),
                    ),
                    Expanded(
                      child: TextButton(
                        onPressed: (){},
                        child: Column(
                          children: [
                            Container(height: 50,width: 50,decoration: BoxDecoration(color: Colors.white,borderRadius: BorderRadius.circular(50)),child: Icon(Icons.compare_arrows_outlined),),
                            SizedBox(height: 8,),
                            Text("Transfer",style: TextStyle(fontSize: 12,color: Colors.white),),
                          ],
                        ),
                      ),
                    ),
                  ],
                )
              ],
            ),),

            //my wallet label
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Invite and earn",
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 16,
                      color: kLoadingScreenTextColor,
                    ),
                  ),
                  //add money container
                  Padding(
                    padding: const EdgeInsets.only(top: 20),
                    child: Container(
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: kHomeScreenServicesContainerColor,
                        borderRadius: BorderRadius.circular(5),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.only(top: 24.0,bottom: 24,left: 8,right: 8),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                "Your Referal Code : ".text.lg.make(),
                                referCode.text.lg.cyan500.underline.make().onInkTap(() {
                                  final data = ClipboardData(text: referCode);
                                  Clipboard.setData(data);
                                })
                              ],
                            )
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(
                    width: 16,
                  ),
                  //wallet summary label
                  Padding(
                    padding: const EdgeInsets.only(top: 18, bottom: 20),
                    child: Text(
                      "Wallet Summary",
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 16,
                        color: kLoadingScreenTextColor,
                      ),
                    ),
                  ),
                  //wallet summary container
                  Padding(
                    padding: const EdgeInsets.only(bottom: 155),
                    child: Container(
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: kHomeScreenServicesContainerColor,
                        borderRadius: BorderRadius.circular(5),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(11, 13, 13, 14),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Text(
                                  "Last recharge amount",
                                  style: TextStyle(
                                    fontWeight: FontWeight.w400,
                                    fontSize: 16,
                                    color: kLoadingScreenTextColor,
                                  ),
                                ),
                                const Spacer(),
                                Text(
                                  "₹ " +
                                      (walletData["lastRecharge"]==null
                                          ? "0"
                                          : walletData["lastRecharge"].toString()),
                                  style: TextStyle(
                                    fontWeight: FontWeight.w600,
                                    fontSize: 16,
                                    color: kLoadingScreenTextColor,
                                  ),
                                ),
                              ],
                            ),
                            Padding(
                              padding: const EdgeInsets.symmetric(vertical: 8),
                              child: Row(
                                children: [
                                  Text(
                                    "Balance after last recharge",
                                    style: TextStyle(
                                      fontWeight: FontWeight.w400,
                                      fontSize: 16,
                                      color: kLoadingScreenTextColor,
                                    ),
                                  ),
                                  const Spacer(),
                                  Text(
                                        (walletData["afterRecharge"]==null
                                            ? "0"
                                            : walletData["afterRecharge"]
                                            .toString()),
                                    style: TextStyle(
                                      fontWeight: FontWeight.w600,
                                      fontSize: 16,
                                      color: kLoadingScreenTextColor,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Row(
                              children: [
                                Text(
                                  "Bill before last reacharge",
                                  style: TextStyle(
                                    fontWeight: FontWeight.w400,
                                    fontSize: 16,
                                    color: kLoadingScreenTextColor,
                                  ),
                                ),
                                const Spacer(),
                                Text(
                                      (walletData["beforeRecharge"]==null
                                          ? "0"
                                          : walletData["beforeRecharge"]
                                          .toString()),
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w600,
                                    fontSize: 16,
                                    color: Colors.red,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            //wallet balance

          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(onPressed: () {
        Navigator.push(context, MaterialPageRoute(builder: (context)=> PlanScreen()));
      },label: Container(
        height: 60,
        child: Row(
          children: [
            Icon(Icons.subscriptions_outlined),
            SizedBox(width: 16,),
            Text("View Plans",style: TextStyle(color: Colors.white),),
          ],
        ),
      ),backgroundColor: kSignInContainerColor,),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }
}
