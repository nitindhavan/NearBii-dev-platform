import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:nearbii/Model/notifStorage.dart';
import 'package:nearbii/constants.dart';

class AboutUsScreen extends StatefulWidget {
  const AboutUsScreen({Key? key}) : super(key: key);

  @override
  State<AboutUsScreen> createState() => _AboutUsScreenState();
}

class _AboutUsScreenState extends State<AboutUsScreen> {
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
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 34),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  //Terms and Conditions label
                  Text(
                    "About Us",
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 20,
                      color: kLoadingScreenTextColor,
                    ),
                  ),
                  Padding(
                      padding: const EdgeInsets.symmetric(vertical: 25),
                      child: Center(
                          child: SingleChildScrollView(
                        child: StreamBuilder(
                          stream: FirebaseFirestore.instance
                              .collection("BusinessSettings")
                              .doc("about")
                              .snapshots(),
                          builder: ((BuildContext context,
                              AsyncSnapshot<
                                      DocumentSnapshot<Map<String, dynamic>>>
                                  snapshot) {
                            if (!snapshot.hasData) {
                              return const CircularProgressIndicator();
                            }
                            var data = snapshot.data!.data();
                            return Html(data: data!["about"]);
                          }),
                        ),
                      ))),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
