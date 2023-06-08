import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:intl/intl.dart';
import 'package:nearbii/Model/notifStorage.dart';
import 'package:nearbii/screens/bottom_bar/event/viewEvent.dart';
import 'package:velocity_x/velocity_x.dart';

import '../../constants.dart';
import '../../screens/bottom_bar/event/event_screen.dart';

Widget getAllEvents(double height, String query, String city, pos) {
  try {
    Query<Map<String, dynamic>> _firestore;
    if (city != "All India") {
      _firestore = FirebaseFirestore.instance
          .collection('Events')
          .where("eventTargetCity", isEqualTo: city);
    } else {
      _firestore = FirebaseFirestore.instance.collection('Events');
    }

    return StreamBuilder<QuerySnapshot>(
      stream: _firestore.snapshots().handleError((error) {
        // ignore: prefer_const_constructors
        return SizedBox(
          width: 30,
          height: 30,
          child: const CircularProgressIndicator(),
        );
      }),
      builder: (context, snapshot) {
        if (!snapshot.hasData || pos == null) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }

        List<Widget> messageWidgets = snapshot.data!.docs.map<Widget>((m) {
          final data = m.data as dynamic;
          if (DateTime.now().millisecondsSinceEpoch > data()["eventEndData"]) {
            m.reference.delete();
          }

          if (data()["name"].toString().toLowerCase().contains(query) ||
              data()["eventCat"].toString().toLowerCase().contains(query) ||
              data()["addr"].toString().toLowerCase().contains(query) ||
              data()["city"].toString().toLowerCase().contains(query) ||
              data()["org"].toString().toLowerCase().contains(query) ||
              data()["pinLocation"].toString().toLowerCase().contains(query) ||
              data()["eventDesc"].toString().toLowerCase().contains(query)) {
            var dis = Geolocator.distanceBetween(
                  pos.latitude,
                  pos.longitude,
                  data()["eventLocation"]["lat"],
                  data()["eventLocation"]["long"],
                ) /
                1000;
            log(dis.toString());
            return InkWell(
              onTap: () {
                Navigator.of(context)
                    .push(MaterialPageRoute(builder: (context) {
                  return ViewEvent(data: data, dis: dis);
                }));
              },
              child: eventBox(
                  context,
                  data()["name"],
                  data()["eventStartDate"],
                  data()["eventTime"],
                  data()["city"],
                  data()["eventImage"][0],
                  dis),
            );
          } else {
            return Container();
          }
        }).toList();

        return Container(
          padding: const EdgeInsets.only(top: 10, left: 20, right: 10),
          child: Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: ListView.separated(
              scrollDirection: Axis.vertical,
              itemCount: messageWidgets.length,
              shrinkWrap: true,
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
    return const SizedBox(
      width: 30,
      height: 30,
      child: CircularProgressIndicator(),
    );
  }
}

// Widget eventBox(context, String title, int startDate, String time, String addr,
//     String img, double dis) {
//   return Container(
//     padding: const EdgeInsets.only(top: 25),
//     child: Material(
//       elevation: 1,
//       color: Colors.white,
//       borderRadius: BorderRadius.circular(5),
//       child: Container(
//         width: MediaQuery.of(context).size.width * 0.80,
//         height: 140,
//         decoration: BoxDecoration(
//           color: Colors.white,
//           borderRadius: BorderRadius.circular(5),
//         ),
//         child: Row(
//           mainAxisAlignment: MainAxisAlignment.start,
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Padding(
//               padding: const EdgeInsets.fromLTRB(10, 10, 0, 10),
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   Text(
//                     title,
//                     style: TextStyle(
//                       fontWeight: FontWeight.w600,
//                       fontSize: 18,
//                       color: kLoadingScreenTextColor,
//                     ),
//                   ),
//                   Padding(
//                     padding: const EdgeInsets.only(top: 8, bottom: 11),
//                     child: Row(
//                       children: [
//                         Icon(
//                           Icons.calendar_today_outlined,
//                           size: 15,
//                           color: kDividerColor,
//                         ),
//                         Padding(
//                           padding: const EdgeInsets.only(left: 8, right: 6),
//                           child: Text(
//                             DateFormat("dd-MM-yyyy").format(
//                                 DateTime.fromMillisecondsSinceEpoch(startDate)),
//                             style: TextStyle(
//                               fontWeight: FontWeight.w400,
//                               fontSize: 12,
//                               color: kDividerColor,
//                             ),
//                           ),
//                         ),
//                         Text(
//                           time,
//                           style: TextStyle(
//                             fontWeight: FontWeight.w600,
//                             fontSize: 12,
//                             color: kSignInContainerColor,
//                           ),
//                         ),
//                       ],
//                     ),
//                   ),
//                   Row(
//                     children: [
//                       Icon(
//                         Icons.location_on_outlined,
//                         size: 20,
//                         color: kDividerColor,
//                       ),
//                       const SizedBox(
//                         width: 5,
//                       ),
//                       Text(
//                         addr,
//                         style: TextStyle(
//                           fontWeight: FontWeight.w400,
//                           fontSize: 12,
//                           color: kDividerColor,
//                         ),
//                       ),
//                     ],
//                   ),
//                   Row(
//                     children: [
//                       const Icon(
//                         Icons.social_distance,
//                         color: Colors.grey,
//                         size: 15,
//                       ),
//                       (dis.toStringAsFixed(2) + " Km")
//                           .text
//                           .color(Colors.grey)
//                           .make()
//                           .px4()
//                           .px(6),
//                     ],
//                   )
//                 ],
//               ),
//             ),
//             const Spacer(),
//             Container(
//               width: 100,
//               height: 100,
//               padding: const EdgeInsets.only(right: 10),
//               decoration: const BoxDecoration(
//                 borderRadius: BorderRadius.only(
//                   topRight: Radius.circular(5),
//                   bottomRight: Radius.circular(5),
//                 ),
//               ),
//               child: Image.network(
//                 img,
//                 fit: BoxFit.fill,
//               ),
//               // child: InteractiveViewer(
//               //   boundaryMargin: const EdgeInsets.all(20.0),
//               //   minScale: 1.0,
//               //   maxScale: 1.0,
//               //   child:
//               // ),
//             ),
//           ],
//         ),
//       ),
//     ),
//   );
// }
