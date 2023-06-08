import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:intl/intl.dart';
import 'package:nearbii/screens/bottom_bar/event/viewEvent.dart';

import '../../Model/notifStorage.dart';
import '../../components/banner_ad.dart';
import '../../constants.dart';
import '../../screens/bottom_bar/event/event_screen.dart';

Widget getEventByCat(
    BuildContext context, double height, String cat, var pos, String city) {
  try {
    final _firestore = FirebaseFirestore.instance;

    return StreamBuilder<QuerySnapshot>(
      stream: _firestore
          .collection('Events')
          .where("eventCat", isEqualTo: cat)
          .where("eventTargetCity", whereIn: [city, 'All India'])
          .snapshots()
          .handleError((error) {
            return Container(
              child: const SizedBox(
                width: 30,
                height: 30,
                child: Text("Error Occured"),
              ),
            );
          }),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }
        if (snapshot.hasData && snapshot.data!.docs.isEmpty) {
          return Container(
            child: const SizedBox(
              child: Text("Nothing to Show"),
            ),
          );
        }
        List<Widget> messageWidgets = snapshot.data!.docs.map<Widget>((m) {
          final data = m.data as dynamic;
          var dis = Geolocator.distanceBetween(
                pos.latitude,
                pos.longitude,
                data()["eventLocation"]["lat"],
                data()["eventLocation"]["long"],
              ) /
              1000;
          return InkWell(
            onTap: () {
              Navigator.of(context).push(MaterialPageRoute(builder: (context) {
                return ViewEvent(
                  data: data,
                  dis: dis,
                );
              }));
            },
            child: eventBox(context, data()["name"], data()["eventStartDate"],
                data()["eventTime"], data()["addr"], data()["eventImage"][0],dis),
          );
        }).toList();

        return Container(
          padding: const EdgeInsets.only(top: 10, left: 20, right: 10),
          child: SizedBox(
            height: height,
            child: Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: ListView.separated(
                scrollDirection: Axis.vertical,
                itemCount: messageWidgets.length,
                itemBuilder: (context, index) {
                  return SizedBox(
                    width: double.infinity,
                    child: Column(
                      children: [
                        Container(width: double.infinity,child: messageWidgets[index]),
                        SizedBox(height: 8,),
                        if(index % 5 ==4) Card(
                          shadowColor: const Color.fromARGB(255, 81, 182, 200),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                          elevation: 4,
                          child:BannerAdWidget(adSize: AdSize(width: 320, height: 100), height:MediaQuery.of(context).size.height/4.6, width: double.infinity),
                        ),
                      ],
                    ),
                  );
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
//
// Widget eventBox(BuildContext context, String title, int startDate, String time,
//     String addr, List img) {
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
//                 ],
//               ),
//             ),
//             const Spacer(),
//             Container(
//               width: 100,
//               height: 100,
//               decoration: const BoxDecoration(
//                 borderRadius: BorderRadius.only(
//                   topRight: Radius.circular(5),
//                   bottomRight: Radius.circular(5),
//                 ),
//               ),
//               child: Image.network(
//                 img[0],
//                 fit: BoxFit.fill,
//               ),
//             ),
//           ],
//         ),
//       ),
//     ),
//   );
// }
