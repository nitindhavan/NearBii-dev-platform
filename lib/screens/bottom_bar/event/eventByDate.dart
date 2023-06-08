import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:intl/intl.dart';
import 'package:nearbii/Model/notifStorage.dart';
import 'package:nearbii/constants.dart';
import 'package:nearbii/screens/bottom_bar/event/event_screen.dart';
import 'package:nearbii/services/getcity.dart';
import 'package:velocity_x/velocity_x.dart';

import '../../../components/banner_ad.dart';
import '../../../services/getAllEvents/getAllEvents.dart';
import 'viewEvent.dart';

class allEventByDate extends StatefulWidget {
  final DateTime date;
  const allEventByDate({required this.date, Key? key}) : super(key: key);

  @override
  State<allEventByDate> createState() => _allEventByDateState();
}

class _allEventByDateState extends State<allEventByDate> {
  String city = "";

  @override
  void initState() {
    // TODO: implement initState
    getCity();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
        top: false,
        child: Scaffold(
          appBar: AppBar(
            title: Text(
              "Events on " +
                  DateFormat('yyyy-MM-dd').format(widget.date).toString(),
              style: TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 18,
                color: kLoadingScreenTextColor,
              ),
            ),
            iconTheme: IconThemeData(color: Colors.black),
            titleSpacing: 0,
            elevation: 1,
          ),
          body: NotificationListener<ScrollEndNotification>(
            onNotification: (scrollEnd) {
              final metrics = scrollEnd.metrics;
              if (metrics.atEdge) {
                bool isTop = metrics.pixels == 0;
                if (isTop) {
                  print('At the top');
                } else {
                  getEventsByDate();
                }
              }
              return true;
            },
            child: SingleChildScrollView(
                child: Column(
              children: [
                city.isNotEmptyAndNotNull
                    ? messageWidgets.isNotEmpty
                        ? Container(
                            padding: const EdgeInsets.only(left: 12, right: 12),
                            width: MediaQuery.of(context).size.width,
                            child: SizedBox(
                              child: Padding(
                                padding: const EdgeInsets.only(bottom: 8),
                                child: ListView.separated(
                                  physics: const NeverScrollableScrollPhysics(),
                                  scrollDirection: Axis.vertical,
                                  shrinkWrap: true,
                                  itemCount: messageWidgets.length + 1,
                                  itemBuilder: (context, i) {
                                    if (messageWidgets.length < 5) {
                                      moreData = false;
                                    }
                                    if (i < messageWidgets.length) {
                                      return Column(
                                        children: [
                                          Container(width: double.infinity,child: messageWidgets[i]),
                                          SizedBox(height: 8,),
                                          if(i % 5 ==4) Card(
                                            shadowColor: const Color.fromARGB(255, 81, 182, 200),
                                            shape: RoundedRectangleBorder(
                                              borderRadius: BorderRadius.circular(20),
                                            ),
                                            elevation: 4,
                                            child:BannerAdWidget(adSize: AdSize(width: 320, height: 100), height:MediaQuery.of(context).size.height/4.6, width: double.infinity),
                                          ),
                                        ],
                                      );
                                    } else {
                                      return (moreData
                                              ? const CircularProgressIndicator()
                                                  .centered()
                                              : "Opps !! No More Events"
                                                  .text
                                                  .make()
                                                  .centered())
                                          .py8();
                                    }
                                  },
                                  separatorBuilder: (context, index) =>
                                      const SizedBox(
                                    width: 15,
                                  ),
                                ),
                              ),
                            ),
                          )
                        : Container(
                            padding: const EdgeInsets.only(top: 120),
                            alignment: Alignment.center,
                            child: Text(
                              "No Event Found In This Date",
                              style: TextStyle(
                                fontSize: 20,
                                color: kLoadingScreenTextColor,
                              ),
                            ),
                          )
                    : Container(
                  height: 400,
                      alignment: Alignment.center,
                      child: Center(
                        child: Column(
                            children: [
                              SizedBox(height: 200,),
                              const CircularProgressIndicator(),
                              5.heightBox,
                              "Please wait,Getting your Location Info"
                                  .text
                                  .makeCentered(),
                            ],
                          ),
                      ),
                    )
              ],
            )),
          ),
        ));
  }

  var pos;
  Future<void> getCity() async {
    city = await getcurrentCityFromLocation();
    pos = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);
    await getEventsByDate();
    if (mounted) setState(() {});
  }

  List<Widget> messageWidgets = [];
  bool moreData = true;

  var lastDocument;
  getEventsByDate() async {
    Query<Map<String, dynamic>> snap = FirebaseFirestore.instance
        .collection('Events')
        .orderBy("eventEndData")
        .where("eventEndData",
            isGreaterThanOrEqualTo: widget.date.millisecondsSinceEpoch)
        .where("eventTargetCity", isEqualTo: city);
    if (lastDocument != null) {
      snap = snap.startAfterDocument(lastDocument!);
    }
    QuerySnapshot<Map<String, dynamic>> snapshot = await snap.limit(5).get();
    if (snapshot.size > 0) {
      moreData = true;
      setState(() {});
      lastDocument = snapshot.docs.last;
      var list = snapshot.docs.map<Widget>((m) {
        var data = m.data as dynamic;
        print(data()!["eventLocation"]['lat'] ?? 0.0);
        var dis = Geolocator.distanceBetween(
              pos.latitude,
              pos.longitude,
              data()!["eventLocation"]["lat"],
              data()!["eventLocation"]["long"],
            ) /
            1000;
        log(data()["name"]);
        // Fluttertoast.showToast(msg: "Loc: " + data()["eventStartDate"]);
        if (DateTime.fromMillisecondsSinceEpoch(data()["eventEndData"])
                .difference(DateTime.now())
                .inSeconds >
            0) {
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
        } else {
          m.reference.delete();
          return Container();
        }
      }).toList();
      messageWidgets.addAll(list);
    } else {
      moreData = false;
    }
    setState(() {});
  }

  // Widget eventBox(BuildContext context, String title, int startDate,
  //     String time, String addr, String img) {
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
  //                                 DateTime.fromMillisecondsSinceEpoch(
  //                                     startDate)),
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
  //                 img,
  //                 fit: BoxFit.fill,
  //               ),
  //             ),
  //           ],
  //         ),
  //       ),
  //     ),
  //   );
  // }
}
