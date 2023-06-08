import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:nearbii/screens/vendor/vendorHome.dart';

import '../../Model/notifStorage.dart';
import '../../constants.dart';

Widget getOffersByFilter(BuildContext context, String cat, int off) {
  var height = MediaQuery.of(context).size.height;
  try {
    final _firestore = FirebaseFirestore.instance;

    return StreamBuilder<QuerySnapshot>(
      stream: _firestore
          .collection('Offers')
          .where("cat", isEqualTo: cat)
          .where("off", isEqualTo: off)
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

        // if (snapshot.data?.docs.isEmpty) {
        //   return const Center(
        //     child: Text("No Offers Found"),
        //   );
        // }

        List<Widget> messageWidgets = snapshot.data!.docs.map<Widget>((m) {
          final data = m.data as dynamic;

          // Fluttertoast.showToast(
          //     msg: "Loc: " +
          //         data()["pinLocation"].toString().split(',').last.toString() +
          //         "City: " +
          //         city);

          return InkWell(
              onTap: () {
                Navigator.of(context)
                    .push(MaterialPageRoute(builder: (context) {
                  return vendorHome(id: data()["uid"]);
                }));
              },
              child: offerBox(
                context,
                data()["Title"],
                data()["subTitle"],
                data()["offerImg"],
              ));
        }).toList();

        return Container(
          padding: const EdgeInsets.only(top: 10),
          child: SizedBox(
            height: height - 200,
            child: Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: ListView.separated(
                scrollDirection: Axis.vertical,
                itemCount: messageWidgets.length,
                itemBuilder: (context, index) {
                  return messageWidgets[index];
                },
                separatorBuilder: (context, index) => const SizedBox(
                  width: 15,
                ),
              ),
            ),
          ),
        );
      },
    );
  } catch (Ex) {
    print("0x1Error To Get User");
    return Container(
      child: const SizedBox(
        width: 30,
        height: 30,
        child: CircularProgressIndicator(),
      ),
    );
  }
}

Widget offerBox(
    BuildContext context, String title, String subtitle, String img) {
  return Container(
    child: Card(
      elevation: 4,
      child: Container(
          padding: const EdgeInsets.only(top: 25),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 29),
            child: Stack(
              children: [
                Container(
                  width: MediaQuery.of(context).size.width - 58,
                  height: 312,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(5),
                  ),
                  child: img == ''
                      ? Image.asset(
                          'assets/images/offers/offers_screen_image.png',
                          fit: BoxFit.fill,
                        )
                      : Image.network(
                          img,
                          fit: BoxFit.fill,
                        ),
                ),
                Positioned(
                  top: 15,
                  left: 1,
                  child: Container(
                    width: MediaQuery.of(context).size.width - 210,
                    decoration: BoxDecoration(
                      color: kSignInContainerColor,
                      borderRadius: const BorderRadius.only(
                        topRight: Radius.circular(15),
                        bottomRight: Radius.circular(15),
                      ),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            title,
                            style: const TextStyle(
                              fontWeight: FontWeight.w900,
                              fontSize: 20,
                              color: Colors.white,
                            ),
                          ),
                          Text(
                            subtitle,
                            style: const TextStyle(
                              fontWeight: FontWeight.w900,
                              fontSize: 16,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                Positioned(
                  bottom: 0,
                  left: 0,
                  child: Container(
                    width: MediaQuery.of(context).size.width,
                    decoration: const BoxDecoration(
                      color: Colors.white,
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          vertical: 12, horizontal: 10),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Text(
                            "VIEW PROFILE",
                            style: TextStyle(
                              fontWeight: FontWeight.w900,
                              fontSize: 18,
                              color: kLoadingScreenTextColor,
                            ),
                          ),
                          const SizedBox(
                            width: 23,
                          ),
                          const Icon(
                            Icons.arrow_forward_ios,
                            size: 16,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          )),
    ),
  );
}
