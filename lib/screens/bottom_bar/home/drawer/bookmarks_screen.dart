// ignore_for_file: prefer_const_constructors

import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:nearbii/Model/notifStorage.dart';
import 'package:nearbii/Model/vendormodel.dart';
import 'package:nearbii/constants.dart';
import 'package:nearbii/screens/bottom_bar/home/drawer/settings/privacy_settings_screen.dart';
import 'package:nearbii/screens/bottom_bar/profile/vendor_profile_screen.dart';
import 'package:swipe_refresh/swipe_refresh.dart';
import 'package:velocity_x/velocity_x.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../components/banner_ad.dart';

class BookmarksScreen extends StatefulWidget {
  const BookmarksScreen({Key? key}) : super(key: key);

  @override
  State<BookmarksScreen> createState() => _BookmarksScreenState();
}

class _BookmarksScreenState extends State<BookmarksScreen> {
  List<VendorModel> bookmarks = [];
  bool show = true;
  @override
  void initState() {
    // TODO: implement initState
    _getBookMarks(refersh: true);
    super.initState();
  }

  final _controller = StreamController<SwipeRefreshState>.broadcast();

  bool float=true;

  Stream<SwipeRefreshState> get _stream => _controller.stream;
  List<Widget> bookMarksWidget=[];

  var controller = ScrollController();

  @override
  Widget build(BuildContext context) {
    double y = MediaQuery.of(context).size.height;
    double x = MediaQuery.of(context).size.width;


    return Scaffold(
      appBar: AppBar(
        title: Text("Bookmarks",style: TextStyle(color: Colors.black),textAlign: TextAlign.start,),
        iconTheme: IconThemeData(color: Colors.black),
        titleSpacing: 0,
      ),
      body: SafeArea(
          child: NotificationListener<ScrollEndNotification>(
            onNotification: (scrollEnd) {
              final metrics = scrollEnd.metrics;
              if (metrics.atEdge) {
                bool isTop = metrics.pixels == 0;
                if (isTop) {
                } else {
                  _getBookMarks();
                }
              }
              return true;
            },
            child: Column(
        children: [
            show == true
                ? Center(
                    child: CircularProgressIndicator(),
                  )
                : bookMarksWidget.isEmpty
                    ? "Nothing to Show".text.makeCentered()
                    : ListView.builder(
                            controller: controller,
                            itemBuilder: ((context, i) {
                              // var item = bookmarks[i];
                              // print('Time ${item.distance.toString()}');
                              //
                              // var nowMin = DateTime.now().hour * 60 +
                              //     DateTime.now().minute;
                              //
                              // var openMin = DateTime.fromMillisecondsSinceEpoch(
                              //                 item.openTime)
                              //             .hour *
                              //         60 +
                              //     DateTime.fromMillisecondsSinceEpoch(
                              //             item.openTime)
                              //         .minute;
                              //
                              // var closeMin = DateTime.fromMillisecondsSinceEpoch(
                              //                 item.closeTime)
                              //             .hour *
                              //         60 +
                              //     DateTime.fromMillisecondsSinceEpoch(
                              //             item.closeTime)
                              //         .minute;

                              // List<String> workday = item.workingDay.split("-");
                              // Map<String, int> work = {
                              //   "mon": 1,
                              //   "tue": 2,
                              //   "wed": 3,
                              //   "thu": 4,
                              //   "fri": 5,
                              //   "sat": 6,
                              //   "sun": 7
                              // };
                              // int today = DateTime.now().weekday;
                              // if (today >= work[workday.first.toLowerCase()]! &&
                              //     today <= work[workday.last.toLowerCase()]!) {
                              //   if (nowMin < openMin || nowMin > closeMin) {
                              //     item.open = ("closed");
                              //   } else {
                              //     item.open = ("open");
                              //   }
                              // } else {
                              //   item.open = ("closed");
                              // }

                              // return SizedBox(
                              //   height: y / 5,
                              //   child: Row(
                              //     children: [
                              //       SizedBox(
                              //           width: 100,
                              //           height: 100,
                              //           child: Image.network(
                              //                   item.businessImage.isEmptyOrNull
                              //                       ? Notifcheck.defCover
                              //                       : item.businessImage)
                              //               .p8()),
                              //       Column(
                              //         mainAxisAlignment: MainAxisAlignment.start,
                              //         children: [
                              //           Row(
                              //             children: [
                              //               item.businessName.text
                              //                   .make()
                              //                   .pOnly(right: 5),
                              //               Spacer(),
                              //               ValueListenableBuilder(
                              //                 builder: (contex, value, c) {
                              //                   return Icon(
                              //                     item.book.value
                              //                         ? Icons.bookmark
                              //                         : Icons.bookmark_outline,
                              //                     color: const Color(0xff51B6C8),
                              //                   ).onInkTap(() async {
                              //                     if (item.book.value) {
                              //                       item.ref!.set({
                              //                         "bookmarks":
                              //                             FieldValue.arrayRemove([
                              //                           FirebaseAuth.instance
                              //                               .currentUser!.uid
                              //                               .substring(0, 20)
                              //                         ])
                              //                       }, SetOptions(merge: true));
                              //                       FirebaseFirestore.instance
                              //                           .collection("User")
                              //                           .doc(FirebaseAuth.instance
                              //                               .currentUser!.uid
                              //                               .substring(0, 20))
                              //                           .set(
                              //                               {
                              //                             "bookmarks": FieldValue
                              //                                 .arrayRemove([
                              //                               item.userId.toString()
                              //                             ])
                              //                           },
                              //                               SetOptions(
                              //                                   merge:
                              //                                       true)).then(
                              //                               (value) {
                              //                         item.book.value = false;
                              //                       });
                              //                     } else {
                              //                       item.ref!.set({
                              //                         "bookmarks":
                              //                             FieldValue.arrayUnion([
                              //                           FirebaseAuth.instance
                              //                               .currentUser!.uid
                              //                               .substring(0, 20)
                              //                         ])
                              //                       }, SetOptions(merge: true));
                              //                       FirebaseFirestore.instance
                              //                           .collection("User")
                              //                           .doc(FirebaseAuth.instance
                              //                               .currentUser!.uid
                              //                               .substring(0, 20))
                              //                           .set(
                              //                               {
                              //                             "bookmarks": FieldValue
                              //                                 .arrayUnion([
                              //                               item.userId.toString()
                              //                             ])
                              //                           },
                              //                               SetOptions(
                              //                                   merge:
                              //                                       true)).then(
                              //                               (value) {
                              //                         item.book.value = true;
                              //                       });
                              //                     }
                              //                   });
                              //                 },
                              //                 valueListenable: item.book,
                              //               )
                              //             ],
                              //           ).pOnly(top: 5, right: 10),
                              //           Row(
                              //             children: [
                              //               item.rating.text
                              //                   .make()
                              //                   .pOnly(right: 5),
                              //               RatingBar.builder(
                              //                 initialRating: 3,
                              //                 ignoreGestures: true,
                              //                 minRating: 1,
                              //                 direction: Axis.horizontal,
                              //                 allowHalfRating: true,
                              //                 itemCount: 5,
                              //                 itemSize: 20,
                              //                 itemBuilder: (context, _) => Icon(
                              //                   Icons.star,
                              //                   color: Colors.amber,
                              //                   size: 1,
                              //                 ),
                              //                 onRatingUpdate: (rating) {
                              //                   print(rating);
                              //                 },
                              //               ),
                              //               item.rating.text
                              //                   .make()
                              //                   .pOnly(left: 5, right: 1),
                              //               "Ratings"
                              //                   .text
                              //                   .make()
                              //                   .pOnly(left: 5, right: 5),
                              //             ],
                              //           ).pOnly(top: 5, right: 10),
                              //           Row(
                              //             children: [
                              //               "${(item.distance / 1000).toStringAsFixed(2)} km "
                              //                   .text
                              //                   .color(
                              //                       Color.fromARGB(96, 0, 0, 0))
                              //                   .make(),
                              //               Icon(Icons.location_on)
                              //                   .pOnly(right: 5),
                              //               item.open
                              //                   .toUpperCase()
                              //                   .text
                              //                   .bold
                              //                   .color(Color(0xff51B6C8))
                              //                   .make()
                              //                   .pOnly(right: 5),
                              //             ],
                              //           ).pOnly(top: 5, right: 10, bottom: 10),
                              //           Row(
                              //             mainAxisAlignment:
                              //                 MainAxisAlignment.center,
                              //             children: [
                              //               Container(
                              //                 width: x / 2,
                              //                 height: y / 23,
                              //                 child: Row(
                              //                   mainAxisAlignment:
                              //                       MainAxisAlignment.center,
                              //                   children: [
                              //                     Icon(
                              //                       Icons.phone,
                              //                       color: Color(0xff51B6C8),
                              //                     ),
                              //                     "Call Now "
                              //                         .text
                              //                         .color(Color(0xff51B6C8))
                              //                         .lg
                              //                         .make()
                              //                   ],
                              //                 ),
                              //                 decoration: BoxDecoration(
                              //                     border: Border.all(
                              //                         color: Color(0xff51B6C8))),
                              //               ),
                              //             ],
                              //           ).onInkTap(() async {
                              //             var url =
                              //                 "tel:${item.businessMobileNumber}";
                              //             if (await canLaunch(url)) {
                              //               await launch(url);
                              //             } else {
                              //               throw 'Could not launch $url';
                              //             }
                              //           })
                              //         ],
                              //       ).expand(),
                              //     ],
                              //   ),
                              // ).onInkTap(() {
                              //   Navigator.push(
                              //       context,
                              //       MaterialPageRoute(
                              //           builder: (context) => VendorProfileScreen(
                              //                 id: item.userId!,
                              //                 isVisiter: true,
                              //               )));
                              // });

                              if (bookMarksWidget.length < 2) more = false;

                              return i < bookMarksWidget.length
                                  ? Column(
                                    children: [
                                      bookMarksWidget[i],
                                      if(i % 5 ==4) Card(
                                        shadowColor: const Color.fromARGB(255, 81, 182, 200),
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(20),
                                        ),
                                        elevation: 4,
                                        child:BannerAdWidget(adSize: AdSize(width: 320, height: 100), height:MediaQuery.of(context).size.height/4.6, width: double.infinity),
                                      ),
                                    ],
                                  )
                                  : (more
                                  ? CircularProgressIndicator()
                                  : "No More Bookmarks".text.make())
                                  .centered()
                                  .py8();
                            }),
                            itemCount: bookMarksWidget.length+1)
                        .px8()
                        .expand()
        ],
      ),
          )),
    );
  }

  var pos;
  // getBookmarks() async {
  //   bookmarks = [];
  //   pos = await Geolocator.getCurrentPosition(
  //       desiredAccuracy: LocationAccuracy.high);
  //   var b = await FirebaseFirestore.instance
  //       .collection("vendor")
  //       .where("bookmarks", arrayContains: FirebaseAuth.instance.currentUser!.uid.substring(0, 20))
  //       .get();
  //   for (var elt in b.docs) {
  //     var vend = VendorModel.fromMap(elt.data());
  //
  //     vend.ref = elt.reference;
  //     vend.userId = elt.id;
  //     vend.book.value = true;
  //     vend.distance = Geolocator.distanceBetween(vend.businessLocation.lat,
  //         vend.businessLocation.long, pos.latitude, pos.longitude);
  //     bookmarks.add(vend);
  //   }
  //   if (mounted) {
  //     setState(() {
  //       show = false;
  //     });
  //   }
  // }


  var lastDocument;

  int current=0;
  _getBookMarks({bool refersh = false}) async {
    _controller.sink.add(SwipeRefreshState.loading);
    setState(() {});
    if (refersh) {
      bookMarksWidget = [];
      lastDocument = null;
      more = true;
    }

    Query<Map<String, dynamic>> snap =
    FirebaseFirestore.instance
        .collection("vendor")
        .where("bookmarks", arrayContains: FirebaseAuth.instance.currentUser!.uid.substring(0, 20));

    if (lastDocument != null) {
      snap = snap.startAfterDocument(lastDocument);
    }
    QuerySnapshot<Map<String, dynamic>> snapshot = await snap.limit(5).get();


    var dmta = snapshot.docs;

    if (snapshot.docs.isNotEmpty) {
      lastDocument = snapshot.docs.last;
      more = true;
    } else {
      more = false;
    }

    pos=await Geolocator.getCurrentPosition();

    bookmarks=[];

    for (var elt in dmta) {
      var vend = VendorModel.fromMap(elt.data());
      vend.ref = elt.reference;
      vend.userId = elt.id;
      vend.book.value = true;

      print("Size : ${dmta.length}");

      vend.distance = Geolocator.distanceBetween(vend.businessLocation.lat,
          vend.businessLocation.long, pos.latitude, pos.longitude);
      bookmarks.add(vend);
    }
    // bookmarks.sort((a, b) => (b.distance.compareTo(a.distance)));

    List<Widget> widgets = bookmarks.map<Widget>((m) {
      final VendorModel data = m ;

      // if(bookmarks.indexOf(m) < current) return SizedBox();
        return Padding(
          padding: const EdgeInsets.all(4.0),
          child: Column(
            children: [
              SizedBox(height: 8,),
              SizedBox(
                // height: MediaQuery.of(context).size.height / 4,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: SizedBox(
                              width: 100,
                              height: 100,
                              child: Image.network(
                                  data.businessImage.isEmptyOrNull
                                      ? Notifcheck.defCover
                                      : data.businessImage,)),
                        ),
                      ],
                    ),
                    SizedBox(width: 16,),
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Row(
                          children: [
                            data.businessName.text
                                .make()
                                .pOnly(right: 5),
                            Spacer(),
                            ValueListenableBuilder(
                              builder: (contex, value, c) {
                                return Icon(
                                  data.book.value
                                      ? Icons.bookmark
                                      : Icons.bookmark_outline,
                                  color: const Color(0xff51B6C8),
                                ).onInkTap(() async {
                                  if (data.book.value) {
                                    data.ref!.set({
                                      "bookmarks":
                                      FieldValue.arrayRemove([
                                        FirebaseAuth.instance
                                            .currentUser!.uid
                                            .substring(0, 20)
                                      ])
                                    }, SetOptions(merge: true));
                                    FirebaseFirestore.instance
                                        .collection("User")
                                        .doc(FirebaseAuth.instance
                                        .currentUser!.uid
                                        .substring(0, 20))
                                        .set(
                                        {
                                          "bookmarks": FieldValue
                                              .arrayRemove([
                                            data.userId.toString()
                                          ])
                                        },
                                        SetOptions(
                                            merge:
                                            true)).then(
                                            (value) {
                                          data.book.value = false;
                                        });
                                  } else {
                                    data.ref!.set({
                                      "bookmarks":
                                      FieldValue.arrayUnion([
                                        FirebaseAuth.instance
                                            .currentUser!.uid
                                            .substring(0, 20)
                                      ])
                                    }, SetOptions(merge: true));
                                    FirebaseFirestore.instance
                                        .collection("User")
                                        .doc(FirebaseAuth.instance
                                        .currentUser!.uid
                                        .substring(0, 20))
                                        .set(
                                        {
                                          "bookmarks": FieldValue
                                              .arrayUnion([
                                            data.userId.toString()
                                          ])
                                        },
                                        SetOptions(
                                            merge:
                                            true)).then(
                                            (value) {
                                          data.book.value = true;
                                        });
                                  }
                                });
                              },
                              valueListenable: data.book,
                            )
                          ],
                        ).pOnly(top: 5, right: 10),
                        Row(
                          children: [
                            RatingBar.builder(
                              initialRating: 3,
                              ignoreGestures: true,
                              minRating: 1,
                              direction: Axis.horizontal,
                              allowHalfRating: true,
                              itemCount: 5,
                              itemSize: 20,
                              itemBuilder: (context, _) => Icon(
                                Icons.star,
                                color: Colors.amber,
                                size: 1,
                              ),
                              onRatingUpdate: (rating) {
                              },
                            ),
                            data.rating.text
                                .make()
                                .pOnly(left: 5, right: 1),
                            "Ratings"
                                .text
                                .make()
                                .pOnly(left: 5, right: 5),
                          ],
                        ).pOnly(top: 5, right: 10),
                        data.rating.text.size(12)
                            .make()
                            .pOnly(right: 5),
                        Row(
                          children: [
                            "${(data.distance / 1000).toStringAsFixed(2)} km "
                                .text
                                .color(
                                Color.fromARGB(96, 0, 0, 0))
                                .make(),
                            Icon(Icons.location_on)
                                .pOnly(right: 5),
                            data.open
                                .toUpperCase()
                                .text
                                .bold
                                .color(Color(0xff51B6C8))
                                .make()
                                .pOnly(right: 5),
                          ],
                        ).pOnly(top: 5, right: 10, bottom: 10),
                      ],
                    ).expand(),
                  ],
                ),
              ).onInkTap(() {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => VendorProfileScreen(
                          id: data.userId!,
                          isVisiter: true,
                        )));
              }),
              SizedBox(height: 8,),

              Container(
                decoration: BoxDecoration(
                    color: kSignInContainerColor,
                    borderRadius: BorderRadius.circular(10)
                ),
                height: 40,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      // width: double.infinity,
                      padding: EdgeInsets.all(4),
                      child: Row(
                        mainAxisAlignment:
                        MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.phone,
                            color: Colors.white,
                          ),
                          "Call Now "
                              .text
                              .color(Colors.white)
                              .lg
                              .make()
                        ],
                      ),
                    ),
                  ],
                ).onInkTap(() async {
                  var url =
                      "tel:${data.businessMobileNumber}";
                  if (await canLaunch(url)) {
                    await launch(url);
                  } else {
                    throw 'Could not launch $url';
                  }
                }),
              ),

              SizedBox(height: 8,),
              Divider( color: kSignInContainerColor,height: 10,)
            ],
          ),
        );

      return Container();
    }).toList();
    bookMarksWidget.addAll(widgets);
    _controller.sink.add(SwipeRefreshState.hidden);
    current+=snapshot.size;

    setState(() {
      show=false;
    });
  }
  bool more=true;
}
