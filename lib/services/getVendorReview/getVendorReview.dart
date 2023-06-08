import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:velocity_x/velocity_x.dart';

import '../../Model/notifStorage.dart';
import '../../constants.dart';

Widget getVendorReview(BuildContext context, String uid) {
  try {
    final _firestore = FirebaseFirestore.instance;

    return StreamBuilder<QuerySnapshot>(
      stream: _firestore
          .collection('vendor')
          .doc(uid)
          .collection("Reviews")
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

        List<Widget> messageWidgets = snapshot.data!.docs.map<Widget>((m) {
          final data = m.data as dynamic;

          return userReview(data()["cliName"], data()["starRate"],
              data()["message"], data()["cliProfile"]);
        }).toList();

        return Padding(
          padding: const EdgeInsets.only(top: 30, bottom: 20),
          child: ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: messageWidgets.length,
            itemBuilder: (context, index) {
              return messageWidgets[index];
            },
            separatorBuilder: (context, index) => const SizedBox(
              height: 34,
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

Widget userReview(String name, dynamic rating, String msg, String profile) {
  return Column(
    children: [
      Row(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: 15,
            backgroundImage: NetworkImage(profile),
          ),
          const SizedBox(
            width: 9,
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                name,
                style: TextStyle(
                  fontWeight: FontWeight.w400,
                  fontSize: 13,
                  color: kLoadingScreenTextColor,
                ),
              ),
              if (msg.isNotEmptyAndNotNull)
                msg.toString().text.sm.color(Colors.grey).make(),
              Row(
                children: [
                  Text(
                    rating.toString(),
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 16,
                      color: kLoadingScreenTextColor,
                    ),
                  ),
                  const SizedBox(
                    width: 5,
                  ),
                  RatingBar(
                    initialRating: rating.toDouble(),
                    itemSize: 17,
                    updateOnDrag: false,
                    ignoreGestures: true,
                    tapOnlyMode: false,
                    direction: Axis.horizontal,
                    allowHalfRating: true,
                    itemCount: 5,
                    glowColor: kCreditPointScaffoldBackgroundColor,
                    ratingWidget: RatingWidget(
                      full: Icon(
                        Icons.star,
                        color: kSelectedStarColor,
                      ),
                      half: Icon(
                        Icons.star_half,
                        color: kSelectedStarColor,
                      ),
                      empty: Icon(
                        Icons.star_border_outlined,
                        color: kWalletLightTextColor,
                      ),
                    ),
                    itemPadding: const EdgeInsets.symmetric(horizontal: 0),
                    onRatingUpdate: (rating) {},
                  ),
                ],
              ),
              const SizedBox(
                height: 5,
              ),
              // Row(
              //   mainAxisAlignment: MainAxisAlignment.start,
              //   children: [
              //     Container(
              //       height: 20,
              //       width: 20,
              //       decoration: BoxDecoration(
              //         color: Colors.white,
              //         shape: BoxShape.circle,
              //         border: Border.all(
              //           color: Colors.black12,
              //         ),
              //       ),
              //       child: Icon(
              //         Icons.thumb_up_alt_outlined,
              //         color: kLoadingScreenTextColor,
              //         size: 10,
              //       ),
              //     ),
              //     Padding(
              //       padding: const EdgeInsets.symmetric(horizontal: 11.4),
              //       child: Container(
              //         height: 20,
              //         width: 20,
              //         decoration: BoxDecoration(
              //           color: Colors.white,
              //           shape: BoxShape.circle,
              //           border: Border.all(
              //             color: Colors.black12,
              //           ),
              //         ),
              //         child: Icon(
              //           Icons.messenger_outline,
              //           color: kLoadingScreenTextColor,
              //           size: 10,
              //         ),
              //       ),
              //     ),
              //     Container(
              //       height: 20,
              //       width: 20,
              //       decoration: BoxDecoration(
              //         color: Colors.white,
              //         shape: BoxShape.circle,
              //         border: Border.all(
              //           color: Colors.black12,
              //         ),
              //       ),
              //       child: Icon(
              //         Icons.share_outlined,
              //         color: kLoadingScreenTextColor,
              //         size: 10,
              //       ),
              //     ),
              //   ],
              // )
            ],
          ),
        ],
      ),
    ],
  );
}
