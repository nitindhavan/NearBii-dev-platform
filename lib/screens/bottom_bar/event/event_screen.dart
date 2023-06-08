// ignore_for_file: unused_local_variable, avoid_print, unused_import

import 'dart:async';
import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:intl/intl.dart';
import 'package:nearbii/Model/notifStorage.dart';
import 'package:nearbii/constants.dart';
import 'package:nearbii/screens/bottom_bar/event/all_nearby_events_screen.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:nearbii/screens/bottom_bar/event/eventByDate.dart';
import 'package:nearbii/screens/bottom_bar/event/viewEvent.dart';
import 'package:nearbii/services/getEventCat/eventCat.dart';
import 'package:nearbii/services/getNearEvent/getNearEvent.dart';
import 'package:nearbii/services/getcity.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:swipe_refresh/swipe_refresh.dart';
import 'package:velocity_x/velocity_x.dart';

import '../../../components/banner_ad.dart';

class EventScreen extends StatefulWidget {
  const EventScreen({Key? key}) : super(key: key);

  @override
  State<EventScreen> createState() => _EventScreenState();
}

class _EventScreenState extends State<EventScreen> {
  int selectedIndex = 0;
  final days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
  final events = ['Concert', 'Art', 'Sports', 'Education', 'Food'];

  int dateStartIndex = 0;
  int dateWeekDay = 0;

  List<int> weekDateList = [];
  List<String> weekDayList = [];
  List<DateTime> weekFullDate = [];

  String city = "";

  var controller = ScrollController();
  var pos;
  @override
  void initState() {
    super.initState();
    getLocation();

    getDates();
  }

  Future<void> getLocation() async {
    city = await getcurrentCityFromLocation();
    pos = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);
    getEventsFromCity(city: city, refresh: true);
  }

  void getDates() {
    final _currentDate = DateTime(DateTime.now().year, DateTime.now().month,
        DateTime.now().day, 0, 0, 0, 0, 0);
    final _dayFormatter = DateFormat('d');
    final _monthFormatter = DateFormat('MMM');

    for (int i = 0; i < 7; i++) {
      final date =
          _currentDate.add(Duration(days: i, hours: 0, minutes: 0, seconds: 0));

      weekDayList.add(days[(date.weekday) - 1]);
      weekDateList.add(date.day);
      weekFullDate.add(date);

      print(weekDayList);
      print(weekDateList);
    }
  }

  makeDateList() {}

  @override
  Widget build(BuildContext context) {
    double height = MediaQuery.of(context).size.height;

    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          elevation: 1,
          title: Text(
            "Events",
            style: TextStyle(
              fontSize: 20,
              color: kLoadingScreenTextColor,
            ),
          ),
        ),
        body: NotificationListener<ScrollEndNotification>(
          onNotification: (scrollEnd) {
            final metrics = scrollEnd.metrics;
            if (metrics.atEdge) {
              bool isTop = metrics.pixels == 0;
              if (isTop) {
                print('At the top');
              } else {
                print("botom");
                getEventsFromCity(city: city);
              }
            }
            return true;
          },
          child: SwipeRefresh.builder(
              scrollController: controller,
              itemCount: 1,
              stateStream: _stream,
              onRefresh: swipe,
              shrinkWrap: true,
              itemBuilder: (BuildContext context, int index) {
                return SingleChildScrollView(
                  controller: controller,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        //Events label
                        //dates
                        SizedBox(
                          height: 100,
                          child: Padding(
                            padding: const EdgeInsets.only(bottom: 8),
                            child: ListView.separated(
                              scrollDirection: Axis.horizontal,
                              itemCount: weekDateList.length,
                              itemBuilder: (context, index) {
                                return GestureDetector(
                                  onTap: () {
                                    setState(() {
                                      selectedIndex = index;

                                      Navigator.of(context).push(
                                          MaterialPageRoute(builder: (context) {
                                        return allEventByDate(
                                            date: weekFullDate[index]);
                                      }));
                                    });
                                  },
                                  child: Container(
                                    decoration: BoxDecoration(
                                      color: selectedIndex == index
                                          ? kSignInContainerColor
                                          : Colors.white,
                                      borderRadius: BorderRadius.circular(5),
                                    ),
                                    child: Padding(
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 9, horizontal: 7),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.center,
                                        children: [
                                          Text(
                                            weekDayList[index].toString(),
                                            style: TextStyle(
                                              fontWeight: selectedIndex == index
                                                  ? FontWeight.w600
                                                  : FontWeight.w400,
                                              fontSize: 18,
                                              color: selectedIndex == index
                                                  ? Colors.white
                                                  : kLoadingScreenTextColor,
                                            ),
                                          ),
                                          const SizedBox(
                                            height: 20,
                                          ),
                                          Text(
                                            weekDateList[index].toString(),
                                            style: TextStyle(
                                              fontWeight: selectedIndex == index
                                                  ? FontWeight.w600
                                                  : FontWeight.w400,
                                              fontSize: 18,
                                              color: selectedIndex == index
                                                  ? Colors.white
                                                  : kLoadingScreenTextColor,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                );
                              },
                              separatorBuilder: (context, index) =>
                                  const SizedBox(
                                width: 10,
                              ),
                            ),
                          ),
                        ),
                        //Divider
                        Container(
                          color: kDrawerDividerColor,
                          height: 0.5,
                          width: double.infinity,
                        ),
                        //All Events label
                        Padding(
                          padding: const EdgeInsets.only(top: 20, bottom: 19),
                          child: GestureDetector(
                            onTap: () {},
                            child: Text(
                              "All Events",
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: 16,
                                color: kLoadingScreenTextColor,
                              ),
                            ),
                          ),
                        ),
                        //all events
                        getEventCatList(context, pos, city),
                        Row(
                          children: [
                            Text(
                              "Events Nearby",
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: 16,
                                color: kLoadingScreenTextColor,
                              ),
                            ),
                            const Spacer(),
                            GestureDetector(
                              onTap: () => Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (context) =>
                                      const AllNearbyEventsScreen(),
                                ),
                              ),
                              child: Row(
                                children: [
                                  Text(
                                    "See All",
                                    style: TextStyle(
                                      fontWeight: FontWeight.w600,
                                      fontSize: 13,
                                      color: kLoadingScreenTextColor,
                                    ),
                                  ),
                                  const SizedBox(
                                    width: 8,
                                  ),
                                  Icon(
                                    Icons.arrow_forward_ios,
                                    color: kLoadingScreenTextColor,
                                    size: 13,
                                  )
                                ],
                              ),
                            ),
                          ],
                        ),

                        if (pos != null)
                          messageWidgets.isNotEmpty
                              ? Container(
                                  padding: const EdgeInsets.only(top: 10),
                                  child: Padding(
                                    padding: const EdgeInsets.only(bottom: 8),
                                    child: ListView.separated(
                                      controller: controller,
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
                                              if(i % 5 ==4) Container(
                                                width: double.infinity,
                                                child: Card(
                                                  shadowColor: const Color.fromARGB(255, 81, 182, 200),
                                                  shape: RoundedRectangleBorder(
                                                    borderRadius: BorderRadius.circular(20),
                                                  ),
                                                  elevation: 4,
                                                  child:BannerAdWidget(adSize: AdSize(width: 320, height: 100), height:MediaQuery.of(context).size.height/4.5, width: double.infinity),
                                                ),
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
                                )
                              : //   return Padding(
                              const Padding(
                                  padding: EdgeInsets.only(top: 150),
                                  child: Center(
                                    child: SizedBox(
                                      height: 50,
                                      child: Text("No Nearby Events to show "),
                                    ),
                                  ),
                                )
                        else
                          Column(
                            children: [
                              const CircularProgressIndicator(),
                              5.heightBox,
                              "Please wait,Getting your Location Info"
                                  .text
                                  .makeCentered(),
                            ],
                          )
                      ],
                    ),
                  ).pOnly(top: 20),
                );
              }),
        ),
      ),
    );
  }



  var lastDocument;
  bool moreData = true;
  List<Widget> messageWidgets = [];
  void getEventsFromCity({required String city, bool refresh = false}) async {
    if (refresh) {
      messageWidgets = [];
      lastDocument = null;
    }
    final _firestore = FirebaseFirestore.instance;
    Query<Map<String, dynamic>> snap = _firestore
        .collection('Events')
        .where("eventTargetCity", isEqualTo: city)
        .orderBy("eventStartDate", descending: true);
    if (lastDocument != null) {
      snap = snap.startAfterDocument(lastDocument!);
    }
    QuerySnapshot<Map<String, dynamic>> snapshot = await snap.limit(5).get();
    print(snapshot.size);
    if (snapshot.size > 0) {
      lastDocument = snapshot.docs.last;
      for (var ele in snapshot.docs) {
        moreData = true;

        final data = ele.data as dynamic;

        {
          log(data()['eventLocation']["lat"].toString(), name: "event");
          var dis = Geolocator.distanceBetween(
                pos.latitude,
                pos.longitude,
                data()["eventLocation"]["lat"],
                data()["eventLocation"]["long"],
              ) /
              1000;
          DateTime dt =
              DateTime.fromMillisecondsSinceEpoch(data()['eventEndData']);
          print(dt);

          final difference = dt.difference(DateTime.now()).inSeconds;
          print(difference);
          if (difference >= 0) {
            messageWidgets.add(InkWell(
                onTap: () {
                  Navigator.of(context)
                      .push(MaterialPageRoute(builder: (context) {
                    return ViewEvent(
                      data: data,
                      dis: dis,
                    );
                  }));
                },
                child: eventBox(
                    context,
                    data()["name"],
                    data()["eventStartDate"],
                    data()["eventTime"],
                    data()["addr"],
                    data()["eventImage"][0],
                    dis)));
          } else {
            print("time over");
            ele.reference.delete();
          }
        }
      }
    } else {
      moreData = false;
    }
    _controller.sink.add(SwipeRefreshState.hidden);
    if (mounted) {
      setState(() {});
    }
  }

  final _controller = StreamController<SwipeRefreshState>.broadcast();

  Stream<SwipeRefreshState> get _stream => _controller.stream;
  swipe() {
    getEventsFromCity(city: city, refresh: true);
  }
}


Widget eventBox(BuildContext context, String title, int startDate,
    String time, String addr, String img, double dis) {
  return Container(
    padding: const EdgeInsets.only(top: 25),
    child: Material(
      elevation: 5,
      color: Colors.white,
      shadowColor: kSignInContainerColor,
      borderRadius: BorderRadius.circular(10),
      child: Container(
        width: MediaQuery.of(context).size.width * 0.80,
        height: 140,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(5),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(10, 10, 0, 10),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 18,
                      color: kLoadingScreenTextColor,
                    ),
                  ),
                  Row(
                    children: [
                      Icon(
                        Icons.calendar_today_outlined,
                        size: 15,
                        color: kDividerColor,
                      ),
                      Padding(
                        padding: const EdgeInsets.only(left: 8, right: 6),
                        child: Text(
                          DateFormat("dd-MM-yyyy").format(
                              DateTime.fromMillisecondsSinceEpoch(startDate)),
                          style: TextStyle(
                            fontWeight: FontWeight.w400,
                            fontSize: 12,
                            color: kDividerColor,
                          ),
                        ),
                      ),
                      Text(
                        time,
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 12,
                          color: kSignInContainerColor,
                        ),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      Icon(
                        Icons.location_on_outlined,
                        size: 20,
                        color: kDividerColor,
                      ),
                      Text(
                        addr,
                        style: TextStyle(
                          fontWeight: FontWeight.w400,
                          fontSize: 12,
                          color: kDividerColor,
                        ),
                      ).scrollHorizontal().px(6),
                    ],
                  ),
                  Row(
                    children: [
                      const Icon(
                        Icons.social_distance,
                        color: Colors.grey,
                        size: 15,
                      ),
                      (dis.toStringAsPrecision(3) + " Km")
                          .text
                          .color(Colors.grey)
                          .make()
                          .px4()
                          .px(6),
                    ],
                  )
                ],
              ),
            ),
            const Spacer(),
            Container(
              width: 120,
              height: 120,
              decoration: const BoxDecoration(
                borderRadius: BorderRadius.only(
                  topRight: Radius.circular(5),
                  bottomRight: Radius.circular(5),
                ),
              ),
              child: Image.network(
                img,
              ),
            ),
          ],
        ),
      ),
    ),
  );
}