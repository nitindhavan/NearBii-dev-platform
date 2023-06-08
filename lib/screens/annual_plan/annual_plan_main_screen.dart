import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:nearbii/constants.dart';
import 'package:nearbii/screens/annual_plan/nearbii_membership_plan.dart';

import '../../Model/notifStorage.dart';

class AnnualPlanMainScreen extends StatefulWidget {
  const AnnualPlanMainScreen({Key? key}) : super(key: key);

  @override
  State<AnnualPlanMainScreen> createState() => _AnnualPlanMainScreenState();
}

class _AnnualPlanMainScreenState extends State<AnnualPlanMainScreen> {
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
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              //ANNUAL PLAN label
              Text(
                "ANNUAL PLAN",
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 20,
                  color: kLoadingScreenTextColor,
                ),
              ),
              Image.asset(
                'assets/images/membership_plan/nearbii_membership_plan.png',
              ),
              Text(
                "For listing your Business/\nService and Renewal",
                style: TextStyle(
                  fontWeight: FontWeight.w400,
                  fontSize: 18,
                  color: kLoadingScreenTextColor,
                ),
                textAlign: TextAlign.center,
              ),
              Padding(
                padding: const EdgeInsets.only(bottom: 61, top: 80),
                child: GestureDetector(
                  onTap: () async {
                    var b = await FirebaseFirestore.instance
                        .collection("vendor")
                        .doc(FirebaseAuth.instance.currentUser!.uid
                            .substring(0, 20))
                        .get();
                    var details = b.data()!;
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => NearBiiMembershipPlanScreen(
                          businessDetailData: details,
                          renew: true,
                        ),
                      ),
                    );
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
                        "Continue",
                        style: TextStyle(
                          fontWeight: FontWeight.w400,
                          fontSize: 20,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
