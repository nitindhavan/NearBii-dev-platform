import 'dart:developer';

import 'package:geoflutterfire/geoflutterfire.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dropdown_search/dropdown_search.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:nearbii/Model/notifStorage.dart';
import 'package:nearbii/Model/vendormodel.dart';
import 'package:nearbii/components/banner_ad.dart';
import 'package:nearbii/components/search_bar.dart';
import 'package:nearbii/constants.dart';
import 'package:nearbii/screens/bottom_bar/profile/vendor_profile_screen.dart';
import 'package:nearbii/services/distance.dart';
import 'package:nearbii/services/getcity.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:velocity_x/velocity_x.dart';

class SearchVendor extends StatefulWidget {
  String category;
  SearchVendor(this.category, {Key? key}) : super(key: key);
  // double lat;
  // double long;
  @override
  State<SearchVendor> createState() => _SearchVendorState();
}

class _SearchVendorState extends State<SearchVendor> {
  List<String> filter = ["Ratings", "Distance"];
  String applied = "Distance";

  QueryDocumentSnapshot<Map<String, dynamic>>? lastDocument;

  bool moreData = true;

  bool searching = false;

  @override
  void initState() {
    getCity();
    super.initState();
  }

  String city = "";
  getCity() async {
    city = await getcurrentCityFromLocation();

    pos ??= await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);
    if (mounted) setState(() {});

    getVendors();
  }

  getVendors() async {
    MinMaxModel model =calculateBounds(pos!.latitude, pos!.longitude, 30);

    FieldPath orderByField = FieldPath(['adsBuyTimestamp']);
    FieldPath businessNameField = FieldPath(['businessName']);
    FieldPath whereField = FieldPath(['businessLocation', 'lat']);


    if (vendorList.isEmpty) {
      if (mounted) {
        setState(() {
          searching = true;
        });
      }
    }
    String finalCity = city;

    Query<Map<String, dynamic>> snap = FirebaseFirestore.instance
        .collection("vendor")
        .orderBy(orderByField, descending: true)
        .orderBy(businessNameField, descending: false);
    if (finalCity == "All India") {
      if (widget.category.isEmptyOrNull) {
      } else {
        snap = snap.where("businessSubCat", isEqualTo: widget.category);
      }
    } else {
      snap = snap.where("businessCity", isEqualTo: finalCity);
      log(finalCity.toString(), name: "snap");

      if (widget.category.isEmptyOrNull) {
      } else {
        snap = snap.where("businessSubCat", isEqualTo: widget.category);
      }
    }
    if (searchval.isNotEmptyAndNotNull) {
      snap = snap.where("caseSearch",
          arrayContains: searchval.trim().toLowerCase());
    }
    if (lastDocument != null) {
      snap = snap.startAfterDocument(lastDocument!);
    }

    QuerySnapshot<Map<String, dynamic>> snapshot = await snap.limit(5).get();
    List<VendorModel> tempList = [];
    if (snapshot.size > 0) {
      lastDocument = snapshot.docs.last;
      for (var ele in snapshot.docs) {
        moreData = true;
        var vendor = VendorModel.fromMap(ele.data());
        vendor.ref = ele.reference;
        {
          pos ??= await Geolocator.getCurrentPosition(
              desiredAccuracy: LocationAccuracy.high);
          vendor.userId = ele.id;
          vendor.distance = Geolocator.distanceBetween(
              pos!.latitude,
              pos!.longitude,
              vendor.businessLocation.lat,
              vendor.businessLocation.long);

          vendor.book.value = false;
          var nowMin = DateTime.now().hour * 60 + DateTime.now().minute;
          var openMin =
              DateTime.fromMillisecondsSinceEpoch(vendor.openTime).hour * 60 +
                  DateTime.fromMillisecondsSinceEpoch(vendor.openTime).minute;
          var closeMin =
              DateTime.fromMillisecondsSinceEpoch(vendor.closeTime).hour * 60 +
                  DateTime.fromMillisecondsSinceEpoch(vendor.closeTime).minute;

          List<String> workday = vendor.workingDay.split("-");
          Map<String, int> work = {
            "mon": 1,
            "tue": 2,
            "wed": 3,
            "thu": 4,
            "fri": 5,
            "sat": 6,
            "sun": 7
          };
          int today = DateTime.now().weekday;
          if (today >= work[workday.first.toLowerCase()]! &&
              today <= work[workday.last.toLowerCase()]!) {
            if (nowMin < openMin || nowMin > closeMin) {
              vendor.open = ("closed");
            } else {
              vendor.open = ("open");
            }
          } else {
            vendor.open = ("closed");
          }
          if (vendor.bookmarks.contains(
              FirebaseAuth.instance.currentUser!.uid.substring(0, 20))) {
            vendor.book.value = true;
          }
          vendor.isAds = false;

          if (vendor.adsBuyTimestamp > DateTime.now().millisecondsSinceEpoch) {
            vendor.isAds = true;
          }
          if (vendor.active) tempList.add(vendor);
        }
      }

      tempList.sort((a, b) {
        if (b.isAds) {
          return 1;
        }
        return -1;
      });
      vendorList.addAll(tempList);
      sort();
    } else {
      moreData = false;
    }
    if (snapshot.size == 5 &&
        moreData &&
        vendorList.length < 5 &&
        lastDocument != null) {
      getVendors();
    } else if (mounted) {
      setState(() {
        searching = false;
      });
    }
  }

  sort() {
    if (applied == "Distance") {

    } else {
      vendorList.sort((a, b) {
        return b.rating.compareTo(a.rating);
      });
    }
    vendorList.sort((a, b) {
      if (b.isAds) {
        return 1;
      }
      return -1;
    });
    setState(() {});
  }

  int loading = 0;
  @override
  Widget build(BuildContext context) {
    var x = MediaQuery.of(context).size.width;
    var y = MediaQuery.of(context).size.height;

    return Material(
      child: Scaffold(
        appBar: AppBar(
          title: widget.category.text.color(Colors.black).make(),
          leading: GestureDetector(
              onTap: () => Navigator.pop(context),
              child: const Icon(
                Icons.arrow_back,
                color: Colors.black,
              )),
        ),
        body: SafeArea(
            child: Container(
          child: Column(
            children: [
              SearchBar(
                search: search,
                val: "",
              ).px16().pOnly(top: y / 64),
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Container(
                    width: 120,
                    height: 30,
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                            color: const Color.fromARGB(255, 81, 182, 200))),
                    child: Center(
                      child: DropdownSearch<String>(
                        dropdownButtonProps: const DropdownButtonProps(
                          padding: EdgeInsets.all(0),
                        ),
                        //mode of dropdown
                        //list of dropdown items
                        popupProps: PopupProps.bottomSheet(
                          title: const Divider(
                            height: 10,
                            thickness: 2,
                            color: Color.fromARGB(255, 81, 182, 200),
                          ).px(128).py2(),
                          interceptCallBacks: true,
                          showSelectedItems: true,
                          searchDelay: Duration.zero,
                          searchFieldProps: TextFieldProps(
                            decoration: InputDecoration(
                                icon: const Icon(Icons.search),
                                hintText: "Search City",
                                border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(20))),
                          ),
                          bottomSheetProps: BottomSheetProps(
                              backgroundColor:
                                  const Color.fromARGB(255, 232, 244, 247),
                              elevation: 10,
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(20))),
                          showSearchBox: true,
                        ),
                        dropdownDecoratorProps: const DropDownDecoratorProps(
                            baseStyle:
                                TextStyle(overflow: TextOverflow.ellipsis),
                            textAlignVertical: TextAlignVertical.center,
                            textAlign: TextAlign.center,
                            dropdownSearchDecoration: InputDecoration.collapsed(
                                floatingLabelAlignment:
                                    FloatingLabelAlignment.center,
                                floatingLabelBehavior:
                                    FloatingLabelBehavior.auto,
                                focusColor: Colors.lightBlue,
                                hintText: 'City')),
                        items: CityList.ListCity.map((e) {
                          return e.name;
                        }).toList(),
                        onChanged: ((value) async {
                          if (value == null) return;
                          // if (value == city) {
                          log(vendorList.length.toString(), name: "snap");
                          log(value.toString(), name: "snap");
                          log(city.toString(), name: "snap");
                          log(lastDocument.toString(), name: "snap");

                          setState(() {
                            lastDocument = null;
                            city = value;
                            vendorList = [];
                          });
                          getVendors();
                        }),
                        //show selected item\
                        selectedItem: city,
                      ),
                    ),
                  ),
                  // SizedBox(
                  //   width: 120,
                  //   height: 30,
                  //   child:  DropdownSearch<String>(
                  //       dropdownDecoratorProps: DropDownDecoratorProps(
                  //           textAlignVertical: TextAlignVertical.center,
                  //           textAlign: TextAlign.end,
                  //           dropdownSearchDecoration: InputDecoration.collapsed(
                  //               focusColor: Colors.lightBlue,
                  //               hintText: 'City')),
                  //       selectedItem: applied,
                  //       items: filter.map((e) => e).toList(),
                  //       onChanged: ((value) {
                  //         if (value == null) return;
                  //         applied = value.toString();
                  //         sort();
                  //       })),
                  // )
                ],
              ).px16().pOnly(top: 8).pOnly(bottom: y / 32),
              result()
            ],
          ),
        )),
      ),
    );
  }

  List<VendorModel> vendorList = [];
  Widget result() {
    var x = MediaQuery.of(context).size.width;
    var y = MediaQuery.of(context).size.height;

    return city == ""
        ? Column(
            children: [
              const CircularProgressIndicator(),
              5.heightBox,
              "Please wait,Getting your Location Info".text.makeCentered(),
            ],
          )
        : searching
            ? Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  "Searching for $searchval".text.make(),
                  5.widthBox,
                  const CircularProgressIndicator()
                ],
              )
            : vendorList.isNotEmpty
                ? Expanded(
                    child: NotificationListener<ScrollEndNotification>(
                    onNotification: (scrollEnd) {
                      final metrics = scrollEnd.metrics;
                      if (metrics.atEdge) {
                        bool isTop = metrics.pixels == 0;
                        if (isTop) {
                          print('At the top');
                        } else {
                          getVendors();
                        }
                      }
                      return true;
                    },
                    child: ListView.separated(
                        shrinkWrap: true,
                        padding: const EdgeInsets.only(bottom: 20),
                        itemBuilder: ((context, i) {
                          if (vendorList.length < 5) moreData = false;
                          if (i < vendorList.length) {
                            var item = vendorList[i];
                            return ValueListenableBuilder(
                                valueListenable: item.visible,
                                builder: ((context, bool value, child) {
                                  return Column(
                                    children: [
                                      Padding(
                                        padding: const EdgeInsets.only(left: 8.0,right: 8.0),
                                        child: Card(
                                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
                                          elevation: 5,
                                          child: Column(
                                            children: [
                                              Row(
                                                children: [
                                                  Image.network(
                                                    item.businessImage.isEmptyOrNull
                                                        ? Notifcheck.defCover
                                                        : item.businessImage,
                                                    width: x / 4,
                                                    height: y / 6,
                                                  ).p8(),
                                                  SizedBox(width: 8,),
                                                  Column(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment.start,
                                                    children: [
                                                      Row(
                                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                        children: [
                                                          item.businessName.text
                                                              .make()
                                                              .pOnly(right: 5),
                                                          item.isAds
                                                              ? "Ad"
                                                                  .text
                                                                  .bold
                                                                  .color(const Color(
                                                                      0xff51B6C8))
                                                                  .make()
                                                              : "".text.make(),
                                                          const Spacer(),
                                                          ValueListenableBuilder(
                                                            builder: (contex, value, c) {
                                                              return Icon(
                                                                item.book.value
                                                                    ? Icons.bookmark
                                                                    : Icons
                                                                        .bookmark_outline,
                                                                color:
                                                                    const Color(0xff51B6C8),
                                                              ).onInkTap(() async {
                                                                if (item.book.value) {
                                                                  item.ref!.set(
                                                                      {
                                                                        "bookmarks":
                                                                            FieldValue
                                                                                .arrayRemove([
                                                                          FirebaseAuth
                                                                              .instance
                                                                              .currentUser!
                                                                              .uid
                                                                              .substring(
                                                                                  0, 20)
                                                                        ])
                                                                      },
                                                                      SetOptions(
                                                                          merge: true));
                                                                  FirebaseFirestore.instance
                                                                      .collection("User")
                                                                      .doc(FirebaseAuth
                                                                          .instance
                                                                          .currentUser!
                                                                          .uid
                                                                          .substring(0, 20))
                                                                      .set(
                                                                          {
                                                                        "bookmarks":
                                                                            FieldValue
                                                                                .arrayRemove([
                                                                          item.userId
                                                                              .toString()
                                                                        ])
                                                                      },
                                                                          SetOptions(
                                                                              merge:
                                                                                  true)).then(
                                                                          (value) {
                                                                    item.book.value = false;
                                                                  });
                                                                } else {
                                                                  item.ref!.set(
                                                                      {
                                                                        "bookmarks":
                                                                            FieldValue
                                                                                .arrayUnion([
                                                                          FirebaseAuth
                                                                              .instance
                                                                              .currentUser!
                                                                              .uid
                                                                              .substring(
                                                                                  0, 20)
                                                                        ])
                                                                      },
                                                                      SetOptions(
                                                                          merge: true));
                                                                  FirebaseFirestore.instance
                                                                      .collection("User")
                                                                      .doc(FirebaseAuth
                                                                          .instance
                                                                          .currentUser!
                                                                          .uid
                                                                          .substring(0, 20))
                                                                      .set(
                                                                          {
                                                                        "bookmarks":
                                                                            FieldValue
                                                                                .arrayUnion([
                                                                          item.userId
                                                                              .toString()
                                                                        ])
                                                                      },
                                                                          SetOptions(
                                                                              merge:
                                                                                  true)).then(
                                                                          (value) {
                                                                    item.book.value = true;
                                                                  });
                                                                }
                                                              });
                                                            },
                                                            valueListenable: item.book,
                                                          )
                                                        ],
                                                      ).pOnly(top: 5, right: 10,left: 16),
                                                      Wrap(
                                                        children: [
                                                          RatingBar.builder(
                                                            initialRating:
                                                                vendorList[i].rating,
                                                            minRating: 1,
                                                            ignoreGestures: true,
                                                            direction: Axis.horizontal,
                                                            allowHalfRating: true,
                                                            itemCount: 5,
                                                            itemSize: 20,
                                                            itemBuilder: (context, _) =>
                                                                const Icon(
                                                              Icons.star,
                                                              color: Colors.amber,
                                                              size: 1,
                                                            ),
                                                            onRatingUpdate: (rating) {},
                                                          ),
                                                          vendorList[i]
                                                              .rating
                                                              .toString()
                                                              .text
                                                              .make()
                                                              .pOnly(left: 5, right: 1),
                                                          "Ratings"
                                                              .text
                                                              .make()
                                                              .pOnly(left: 5, right: 5),
                                                        ],
                                                      ).pOnly(top: 5, right: 10),
                                                      Row(
                                                        children: [
                                                          const Icon(
                                                            Icons.location_on,
                                                            color: Colors.grey,
                                                          ),
                                                          "${(item.distance / 1000).toDoubleStringAsPrecised(length: 2)} km"
                                                              .text
                                                              .color(const Color.fromARGB(
                                                                  96, 0, 0, 0))
                                                              .make()
                                                              .pOnly(right: 5),
                                                          item.open
                                                              .toUpperCase()
                                                              .text
                                                              .bold
                                                              .color(
                                                                  const Color(0xff51B6C8))
                                                              .make()
                                                              .pOnly(right: 5),
                                                        ],
                                                      ).pOnly(
                                                          top: 5, right: 10, bottom: 10,left: 8),
                                                      Row(
                                                        mainAxisAlignment:
                                                            MainAxisAlignment.center,
                                                        children: [
                                                          Container(
                                                            width: x / 2,
                                                            height: y / 23,
                                                            child: Row(
                                                              mainAxisAlignment:
                                                                  MainAxisAlignment.center,
                                                              children: [
                                                                const Icon(
                                                                  Icons.phone,
                                                                  color: Color(0xff51B6C8),
                                                                ),
                                                                "Call Now "
                                                                    .text
                                                                    .color(const Color(
                                                                        0xff51B6C8))
                                                                    .lg
                                                                    .make()
                                                              ],
                                                            ),
                                                            decoration: BoxDecoration(
                                                                border: Border.all(
                                                                    color: const Color(
                                                                        0xff51B6C8))),
                                                          ),
                                                        ],
                                                      ).onInkTap(() async {
                                                        var url =
                                                            "tel:${item.businessMobileNumber}";
                                                        if (await canLaunch(url)) {
                                                          await launch(url);
                                                        } else {
                                                          throw 'Could not launch $url';
                                                        }
                                                      }),
                                                    ],
                                                  ).expand(),
                                                ],
                                              ).onInkTap(() {
                                                Navigator.push(
                                                    context,
                                                    MaterialPageRoute(
                                                        builder: (context) =>
                                                            VendorProfileScreen(
                                                              id: item.userId!,
                                                              isVisiter: true,
                                                            )));
                                              }),
                                              FutureBuilder(builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
                                                if(!snapshot.hasData){
                                                  return SizedBox();
                                                }else if(snapshot.data!.size<=0){
                                                  return SizedBox();
                                                }else{
                                                  return Container(
                                                      width: double.infinity,
                                                      height: 40,
                                                      alignment: Alignment.center,
                                                      padding: EdgeInsets.all(8),
                                                      decoration: BoxDecoration(
                                                          color: kSignInContainerColor,
                                                          borderRadius: BorderRadius.only(bottomLeft:Radius.circular(8),bottomRight:Radius.circular( 8))
                                                      ),
                                                      child: Row(
                                                        children: [
                                                          Container(
                                                            padding: const EdgeInsets.all(3),
                                                            decoration: BoxDecoration(
                                                                border: Border.all(color: Colors.white),
                                                                borderRadius: BorderRadius.circular(50)),
                                                            child: Icon(
                                                              Icons.percent,
                                                              color: Colors.white,
                                                              size: 18,
                                                            ),
                                                          ),
                                                          SizedBox(width: 8,),
                                                          Text("Contains Offers",style: TextStyle(color: Colors.white),),
                                                        ],
                                                      ));
                                                }
                                              },future: FirebaseFirestore.instance.collection("Offers").where("uid",isEqualTo: vendorList[i].userId).get(),),
                                            ],
                                          ),
                                        ),
                                      ),
                                      if(i%5 ==4) Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: Card(
                                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
                                            elevation: 5,
                                            child: BannerAdWidget(adSize: AdSize(width: 320, height: 100),height: MediaQuery.of(context).size.height/4,width: double.infinity)),
                                      )
                                    ],
                                  );
                                }));
                          } else {
                            return moreData
                                ? const CircularProgressIndicator().centered()
                                : "Opps !! No More Vendors"
                                    .text
                                    .make()
                                    .centered();
                          }
                        }),
                        separatorBuilder: ((context, i) {
                          return Container();
                          // return const Divider(color: Color(0xff51B6C8));
                        }),
                        itemCount: vendorList.length + 1),
                  ))
                : "Nothing to Show".text.make();
  }

  Position? pos;
  String searchval = "";
  search(String val) {
    searchval = val;
    searching = true;
    if (searchval.isNotEmptyAndNotNull) {
      vendorList = [];
      lastDocument = null;
    }
    getVendors();
  }

  Future<void> getBookmarkData() async {
    // for (var item in vendorList) {
    //   var b = await FirebaseFirestore.instance
    //       .collection("User")
    //       .doc(item.userId)
    //       .get();
    //   if (b.data()!.containsKey('member')) {
    //     DateTime memDate =
    //         DateTime.fromMillisecondsSinceEpoch(b.data()!['member']["endDate"]);
    //     // DateTime endDate = memberData["endDate"].toDate();

    //     var now = DateTime.now();
    //     if (memDate.difference(now).inMilliseconds > 0 &&
    //         b.data()!['member']["isMember"]) {
    //       item.visible.value = true;
    //     } else {
    //       item.visible.value = false;
    //     }
    //   }

    //   var c = await FirebaseFirestore.instance
    //       .collection("User")
    //       .doc(FirebaseAuth.instance.currentUser!.uid.substring(0, 20))
    //       .collection("bookmarks")
    //       .doc(item.userId)
    //       .get();

    //   if (c.exists) {
    //     item.book.value = true;
    //   }
    // }
  }
}
