import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:nearbii/constants.dart';
import 'package:nearbii/services/transactionupdate/transactionUpdate.dart';
import 'package:velocity_x/velocity_x.dart';

class WalletRechargeHistoryScreen extends StatefulWidget {
  final DateTime startDate;
  final DateTime endDate;
  final bool fromDate;
  const WalletRechargeHistoryScreen({
    Key? key,
    required this.startDate,
    required this.endDate,
    required this.fromDate,
  }) : super(key: key);

  @override
  State<WalletRechargeHistoryScreen> createState() =>
      _WalletRechargeHistoryScreenState();
}

class _WalletRechargeHistoryScreenState
    extends State<WalletRechargeHistoryScreen> {
  final months = ['March 2022', 'February 2022', 'January 2022'];

  final uid = FirebaseAuth.instance.currentUser!.uid.substring(0, 20);

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          //Wallet Recharge History label
          Text(
            DateFormat("dd-MMMM-yyyy").format(widget.startDate).toString().split(" ").first +
                " to " +
                DateFormat("dd-MMMM-yyyy").format(widget.endDate).split(" ").first,
            style: TextStyle(
              fontWeight: FontWeight.w400,
              fontSize: 14,
              color: kLoadingScreenTextColor,
            ),
          ),

          !widget.fromDate
              ? getPaymentHistory(
                  context, uid, widget.startDate, widget.endDate)
              : getPaymentHistoryByDate(
                  context, uid, widget.startDate, widget.endDate),
        ],
      ),
    );
  }

  Widget getPaymentHistory(
      BuildContext context, String uid, DateTime startDate, DateTime endDate) {
    try {
      final _firestore = FirebaseFirestore.instance;

      return StreamBuilder<DocumentSnapshot>(
        stream: _firestore
            .collection('User')
            .doc(uid)
            .collection("wallet")
            .doc(getDate(startDate.month, startDate.year))
            .snapshots()
            .handleError((error) {
          return Container(
            child: const SizedBox(
              width: 30,
              height: 30,
              child: CircularProgressIndicator(),
            ),
          );
        }),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }
          if (!snapshot.hasData) {
            return "Nothing to Show".text.make().centered().py32();
          }
          log(snapshot.data.toString());

          List matter = snapshot.data!.get("payments");
          matter.sort((a, b) => b["time"].compareTo(a["time"]));
          print(matter.length);

          return Padding(
            padding: const EdgeInsets.only(top: 30, bottom: 20),
            child: SizedBox(
              child: ListView.builder(
                  itemCount: matter.length,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemBuilder: (context, index) {
                    return Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        SizedBox(height: 12,),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                matter[index]["title"]
                                    .toString()
                                    .text
                                    .lg
                                    .bold
                                    .make(),
                                DateTime.fromMillisecondsSinceEpoch(
                                        matter[index]["time"])
                                    .toString()
                                    .text
                                    .make(),
                              ],
                            ),
                            Column(
                              children: [
                                (matter[index]["status"]
                                        ? "Credited"
                                        : "Debited")
                                    .text
                                    .color(matter[index]["status"]
                                        ? Colors.green
                                        : Colors.red)
                                    .bold
                                    .lg
                                    .make()
                                    .pOnly(bottom: 5),
                                (matter[index]["amount"]!=1 ? "Rs.${matter[index]["amount"]}" : "Plan offer")
                                    .toString()
                                    .text
                                    .bold
                                    .lg
                                    .make(),
                              ],
                            ),
                          ],
                        ),
                        SizedBox(height: 12,),
                        Container(height: 1,color: kSignInContainerColor,width: double.infinity,),
                      ],
                    );
                  },
            ),
            ));
        },
      );
    } catch (Ex) {
      print("0x1Error To Get User");
      return Container(
        child: const SizedBox(
          child: Center(
            child: Text('Nothing to Show'),
          ),
        ),
      );
    }
  }

  Widget getPaymentHistoryByDate(
      BuildContext context, String uid, DateTime startDate, DateTime endDate) {
    log("patymentdara");
    try {
      final _firestore = FirebaseFirestore.instance;

      // print("Temp Date");
      // print(DateFormat("yyyy-MM-dd").parse("2022-07-10").microsecondsSinceEpoch ~/
      //     1000);

      return StreamBuilder<DocumentSnapshot>(
        stream: _firestore
            .collection('User')
            .doc(uid)
            .collection("payments")
            .doc(getDate(startDate.month, startDate.year))
            .snapshots()
            .handleError((error) {
          return Container(
            child: const SizedBox(
              width: 30,
              height: 30,
              child: CircularProgressIndicator(),
            ),
          );
        }),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }
          if (snapshot.data!.data() == null) {
            return Center(
              child: "Nothing to Show".text.make().centered().py32(),
            );
          }
          if (!snapshot.hasData) {
            return Center(
              child: "Nothing to Show".text.make().centered().py32(),
            );
          }
          List matter = snapshot.data!.get("payments");
          matter.sort((a, b) => b["time"].compareTo(a["time"]));
          print(matter.length);

          return Padding(
            padding: const EdgeInsets.only(top: 16, bottom: 8),
            child: SizedBox(
              child: ListView.builder(
                  itemCount: matter.length,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemBuilder: (context, index) {
                    return Card(
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10),side: BorderSide(color: kSignInContainerColor)),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Column(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    matter[index]["title"]
                                        .toString()
                                        .text
                                        .medium
                                        .make(),
                                    DateTime.fromMillisecondsSinceEpoch(
                                            matter[index]["time"])
                                        .toString()
                                        .text
                                        .make(),
                                    "Transaction id : ${matter[index]["id"]}"
                                        .toString()
                                        .text
                                        .color(Colors.grey)
                                        .make(),
                                  ],
                                ),
                                Column(
                                  children: [
                                    matter[index]["status"]
                                        .toString()
                                        .toUpperCase()
                                        .text
                                        .color(Colors.green)
                                        .bold
                                        .lg
                                        .make()
                                        .pOnly(bottom: 5),
                                    "Rs.${matter[index]["amount"]}"
                                        .toString()
                                        .text
                                        .bold
                                        .lg
                                        .make(),
                                  ],
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    );
                  },
              )
            ),
          );
        },
      );
    } catch (Ex) {
      print("0x1Error To Get User");
      return Container(
        child: SizedBox(
          child: Center(
            child: "Nothing to Show".text.make().centered().py32(),
          ),
        ),
      );
    }
  }

  Widget historyBox(
      BuildContext context, String date, String reciptId, int amount) {
    return Container(
      width: MediaQuery.of(context).size.width,
      padding: const EdgeInsets.all(20),
      color: const Color.fromARGB(255, 190, 220, 245),
      child: Column(
        children: [
          Row(
            children: [
              Text(
                "Initiated on " + date.toString(),
                style: TextStyle(
                  fontWeight: FontWeight.w400,
                  fontSize: 14,
                  color: kLoadingScreenTextColor,
                ),
              ),
              const Spacer(),
              Text(
                "done",
                style: TextStyle(
                  fontWeight: FontWeight.w400,
                  fontSize: 14,
                  color: kSignInContainerColor,
                ),
              ),
            ],
          ),
          const SizedBox(
            height: 3,
          ),
          Row(
            children: [
              Text(
                "Transaction ID: " + reciptId.toString(),
                style: TextStyle(
                  fontWeight: FontWeight.w400,
                  fontSize: 14,
                  color: kWalletLightTextColor,
                ),
              ),
              const Spacer(),
              Text(
                "₹" + amount.toString(),
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                  color: kLoadingScreenTextColor,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
