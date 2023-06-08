// ignore_for_file: deprecated_member_use

import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:intl/intl.dart';
import 'package:maps_launcher/maps_launcher.dart';
import 'package:nearbii/constants.dart';
import 'package:nearbii/screens/bottom_bar/bottomBar/bottomBar.dart';
import 'package:nearbii/services/getEventByDate/getEventByDate.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:velocity_x/velocity_x.dart';

class ViewEvent extends StatefulWidget {
  dynamic? data;
  double? dis;

  String? eventID;
  ViewEvent({this.data, Key? key, this.dis,this.eventID})
      : super(key: key);

  @override
  State<ViewEvent> createState() => _ViewEventState();
}

class _ViewEventState extends State<ViewEvent> {
  List imageList = [];
  @override
  void initState() {
    // TODO: implement initState
    if(widget.data!=null) {
      imageList = widget.data()["eventImage"];
    }else{
      getEventsFromCity();
    }
    super.initState();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: Key(widget.data.toString()),
        // bottomNavigationBar: addBottomBar(context),
        appBar: AppBar(
          iconTheme: IconThemeData(color: Colors.black),
          elevation: 1,
          titleSpacing: 0,
          title: Text(
            "Event Info",
            style: TextStyle(
              fontSize: 20,
              color: kLoadingScreenTextColor,
            ),
          ),

        ),
        body: widget.data!=null ? SafeArea(
          child: SingleChildScrollView(
            child: Column(children: [
              Container(
                // width: MediaQuery.of(context).size.width,
                color: Colors.transparent,
                child: widget.data()["eventImage"] != ""
                    ? VxSwiper(
                        scrollDirection: Axis.horizontal,
                        enableInfiniteScroll: false,
                        autoPlay: false,
                        enlargeCenterPage: true,
                        reverse: false,
                        isFastScrollingEnabled: false,
                        onPageChanged: (value) {
                          print(value);
                        },autoPlayInterval: Duration(seconds: 2),viewportFraction: 1.0,
                        autoPlayCurve: Curves.elasticOut,
                        items: imageList.map((e) {
                          return Container(

                            child: InteractiveViewer(
                              child: Image.network(
                                e,
                                width: MediaQuery.of(context).size.width,
                              ),
                            ).onTap(() {
                              showGeneralDialog(
                                  barrierColor:
                                      const Color.fromARGB(180, 0, 0, 0),
                                  context: context,
                                  pageBuilder: (BuildContext context,
                                      Animation<double> animation,
                                      Animation<double> secondaryAnimation) {
                                    return Center(
                                      child: Card(
                                        child: Container(
                                          padding: EdgeInsets.all(8),
                                          width: MediaQuery.of(context).size.width,
                                          height:
                                              MediaQuery.of(context).size.height*0.5,
                                          child: VxSwiper(
                                              viewportFraction: 1.0,
                                              height: MediaQuery.of(context)
                                                  .size
                                                  .height*0.5,
                                              scrollDirection: Axis.horizontal,
                                              scrollPhysics:
                                                  const BouncingScrollPhysics(),
                                              enableInfiniteScroll: false,
                                              autoPlay: false,
                                              reverse: false,
                                              pauseAutoPlayOnTouch:
                                                  const Duration(seconds: 3),
                                              isFastScrollingEnabled: false,
                                              onPageChanged: (value) {
                                                print(value);
                                              },
                                              autoPlayCurve: Curves.elasticOut,
                                              items: imageList.map((e) {
                                                return InteractiveViewer(
                                                    child: Image.network(e));
                                              }).toList()),
                                        ),
                                      ),
                                    );
                                  });
                            }),
                          );
                        }).toList())
                    : Image.network(
                        "https://thumbs.dreamstime.com/b/event-planning-working-desk-notebook-events-word-computer-pencil-notepad-clock-concept-98612010.jpg"),
              ),
              const SizedBox(
                height: 20,
              ),
              Container(
                alignment: Alignment.centerLeft,
                child: Text(
                  widget.data()["name"].toString(),
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 20,
                    color: kLoadingScreenTextColor,
                  ),
                ),
              ),
              const SizedBox(
                height: 20,
              ),
              eventBox(context,  widget.data()["name"],
                  widget.data()["eventStartDate"],
                  widget.data()["eventTime"],
                  widget.data()["addr"],
                  widget.data()["eventImage"][0],
              ),
              //end date
              const SizedBox(
                height: 20,
              ),
              Container(
                alignment: Alignment.centerLeft,
                child: Text(
                  "About",
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 20,
                    color: kLoadingScreenTextColor,
                  ),
                ),
              ),
              const SizedBox(
                height: 20,
              ),
              Container(
                alignment: Alignment.centerLeft,
                child: Text(
                  widget.data()["eventDesc"],
                  style: TextStyle(
                    fontSize: 15,
                    color: kLoadingScreenTextColor,
                  ),
                ),
              ),
              const SizedBox(
                height: 20,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      "Location",
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 20,
                        color: kLoadingScreenTextColor,
                      ),
                    ),
                  ),
                  Container(
                    alignment: Alignment.centerLeft,
                    padding: EdgeInsets.only(right: 2),
                    child: Text(
                      widget.data()["city"],
                      style: TextStyle(
                        fontSize: 15,
                        color: kSignInContainerColor,
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(
                height: 20,
              ),

              Container(
                child: Column(children: [
                  SizedBox(
                    // width: 120,
                    height: 300,
                    width: double.infinity,
                    child: GoogleMap(onTap: (val){
                      MapsLauncher.launchCoordinates(
                          widget.data()["eventLocation"]["lat"], widget.data()["eventLocation"]["long"]
                      );
                    },initialCameraPosition: CameraPosition(target: LatLng(widget.data()["eventLocation"]["lat"], widget.data()["eventLocation"]["long"]),zoom: 12),markers: {Marker(markerId: MarkerId("main"),position: LatLng(widget.data()["eventLocation"]["lat"], widget.data()["eventLocation"]["long"]))},),
                  ),
                  const SizedBox(
                    width: 10,
                  ),

                ]),
              ),
              const SizedBox(
                height: 30,
              ),
            ]).px12().py16(),
          ),
        ) : FutureBuilder(builder: (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
          return Center(child: CircularProgressIndicator(),);
        },future: getEventsFromCity(),)
    );
  }
  getEventsFromCity() async {
    final _firestore = FirebaseFirestore.instance;

    print("Data ${widget.eventID}");
    print("Data key ${widget.eventID}");
    var reference = _firestore
        .collection('Events')
        .doc(widget.eventID);
    var snapshot = await reference.get();
    if (snapshot.exists) {

      final data = snapshot.data as dynamic;

      print("DataView ${data()['eventLocation']["lat"].toString()}");
          log(data()['eventLocation']["lat"].toString(), name: "event");
          var pos=await Geolocator.getCurrentPosition();
          var distance = Geolocator.distanceBetween(
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

          setState(() {
            widget.data=data;
            widget.dis=distance;
            imageList = widget.data()["eventImage"];
            print("Data ${widget.data}");
          });

          return data;
      }
  }
  Widget eventBox(BuildContext context, String title, int startDate, String time,
      String addr, String img) {
    return Container(
      padding: const EdgeInsets.only(bottom: 8),
      child: Material(
        elevation: 1,
        color: Colors.white,
        borderRadius: BorderRadius.circular(5),
        shadowColor: kSignInContainerColor,
        child: Container(
          decoration: BoxDecoration(
            color: kSignInContainerColor,
            borderRadius: BorderRadius.circular(5),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(10, 10, 0, 10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(top: 8, bottom: 11),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Icon(
                                Icons.calendar_today_outlined,
                                size: 16,
                                color: Colors.white,
                              ),
                              Padding(
                                padding: const EdgeInsets.only(left: 8, right: 6),
                                child: Text(
                                  "From ${DateFormat("dd MMM yyyy").format(
                                      DateTime.fromMillisecondsSinceEpoch(startDate))} to ${DateFormat("dd MMM yyyy").format(
                                      DateTime.fromMillisecondsSinceEpoch(
                                          widget.data()["eventEndData"]))}",textAlign: TextAlign.justify,
                                  style: TextStyle(
                                    fontWeight: FontWeight.w400,
                                    fontSize: 12,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          Text(
                            time,
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 12,
                              color: Colors.amber,
                            ),textAlign: TextAlign.right,
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 6,),
                    Container(
                      alignment: Alignment.centerLeft,
                      child: Row(children: [
                        Icon(
                          Icons.location_on_outlined,
                          color: Colors.white,
                          size: 16,
                        ),
                        const SizedBox(
                          width: 10,
                        ),
                        Text(
                          widget.data()["addr"],
                          style: TextStyle(
                              color: Colors.white,fontSize: 14),
                        ),
                        ("${widget.dis?.toDoubleStringAsFixed(digit: 2)} Km")
                            .text.size(10)
                            .color(Colors.amber)
                            .make()
                            .px4()
                            .px(6),
                      ]),
                    ).onInkTap(() {
                      print(widget.data()["eventLocation"]["long"]);
                      MapsLauncher.launchCoordinates(
                          widget.data()["eventLocation"]["lat"],
                          widget.data()["eventLocation"]["long"]);
                    }),
                    SizedBox(height: 16,),
                    InkWell(
                      onTap: () async {
                        var mobbbb = widget.data()["mobo"].toString();
                        var url = "tel:$mobbbb";
                        if (await canLaunch(url)) {
                          await launch(url);
                        } else {
                          throw 'Could not launch $url';
                        }
                      },
                      child: Container(
                        alignment: Alignment.centerLeft,
                        child: Row(children: [
                          Icon(
                            Icons.call_outlined,
                            color: Colors.white,
                            size: 14,
                          ),
                          const SizedBox(
                            width: 10,
                          ),
                          InkWell(
                            onTap: () async {
                              var mobbbb = widget.data()["mobo"].toString();
                              var url = "tel:$mobbbb";
                              if (await canLaunch(url)) {
                                await launch(url);
                              } else {
                                throw 'Could not launch $url';
                              }
                            },
                            child: Text(
                              widget.data()["mobo"],
                              style: const TextStyle(
                                  color: Colors.white,fontSize: 14),
                            ),
                          ),
                        ]),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
