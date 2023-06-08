import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:nearbii/screens/bottom_bar/event/allEventByCat.dart';

import '../../Model/notifStorage.dart';
import '../../constants.dart';

Widget getEventCatList(BuildContext context, pos, String userLocation) {
  try {
    final _firestore = FirebaseFirestore.instance;

    return StreamBuilder<QuerySnapshot>(
      stream: _firestore
          .collection('EventCategory')
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

          if (data()["Icon"] != " ") {
            return catbox(
                data()["Icon"], data()["Title"], context, pos, userLocation);
          } else {
            return catbox("https://i.imgur.com/kFLU9Pn.gif", data()["Title"],
                context, pos, userLocation);
          }
        }).toList();

        return SizedBox(
          height: 112,
          child: Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: messageWidgets.length,
              itemBuilder: (context, index) {
                return messageWidgets[index];
              },
              separatorBuilder: (context, index) => const SizedBox(
                width: 15,
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

Widget catbox(
    String iconUrl, String cat, BuildContext context, pos, userLocation) {
  return InkWell(
    onTap: () {
      Navigator.of(context).push(MaterialPageRoute(builder: (context) {
        return allEventByCat(cat: cat, pos: pos, city: userLocation);
      }));
    },
    child: Padding(
      padding: const EdgeInsets.symmetric(vertical: 9),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            height: 60,
            width: 60,
            decoration: BoxDecoration(
              color: kHomeScreenServicesContainerColor,
              shape: BoxShape.circle,
            ),
            child: CircleAvatar(
              backgroundImage: NetworkImage(iconUrl),
            ),
          ),
          const SizedBox(
            height: 7,
          ),
          Text(
            cat,
            style: TextStyle(
              fontWeight: FontWeight.w400,
              fontSize: 12,
              color: kLoadingScreenTextColor,
            ),
          ),
        ],
      ),
    ),
  );
}
