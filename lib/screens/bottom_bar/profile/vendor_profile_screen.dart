import 'dart:developer';
import 'dart:io';
import 'package:easy_image_viewer/easy_image_viewer.dart';
import 'package:flutter_datetime_picker/flutter_datetime_picker.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:intl/intl.dart';
import 'package:maps_launcher/maps_launcher.dart';
import 'package:nearbii/Model/notifStorage.dart';
import 'package:nearbii/screens/auth/LoginSignUpScreen.dart';
import 'package:nearbii/screens/annual_plan/business_service_details_screen.dart';
import 'package:nearbii/screens/bottom_bar/offers_screen.dart';
import 'package:nearbii/screens/plans/plans/plan_screen.dart';
import 'package:nearbii/screens/wallet/wallet_screen.dart';
import 'package:nearbii/services/sendNotification/registerToken/registerTopicNotificaion.dart';
import 'package:nearbii/services/transactionupdate/transactionUpdate.dart';
import 'package:readmore/readmore.dart';
import 'package:swipe_refresh/swipe_refresh.dart';
import 'package:wc_flutter_share/wc_flutter_share.dart';
import 'dart:async';
import 'dart:ui' as ui;
import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:geolocator/geolocator.dart';
import 'package:image_picker/image_picker.dart';
import 'package:nearbii/Model/vendormodel.dart';
import 'package:nearbii/constants.dart';
import 'package:nearbii/screens/annual_plan/GoogleMapScreen.dart';
import 'package:nearbii/screens/annual_plan/renew_annual_plan.dart';
import 'package:nearbii/screens/bottom_bar/home/drawer/advertise/post_offer_screen.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:nearbii/screens/createEvent/addEvent/addEvent.dart';
import 'package:nearbii/services/getVendorImage/getVndorImage.dart';
import 'package:nearbii/services/getVendorReview/getVendorReview.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:velocity_x/velocity_x.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../plans/adsPlan/adsPlan.dart';

class VendorProfileScreen extends StatefulWidget {
  final String id;
  bool isVisiter;
  VendorProfileScreen({required this.id, required this.isVisiter, Key? key})
      : super(key: key);

  @override
  State<VendorProfileScreen> createState() => _VendorProfileScreenState();
}

class _VendorProfileScreenState extends State<VendorProfileScreen> {
  String uid = "";

  final photosList = [];
  final reviews = [
    'All',
  ];
  int selectedIndex = 0;

  late FirebaseFirestore db;

  bool bookmarks = false;
  var memberDays = 0;

  int totalRatingCount = 0;

  var reviewcontroller = TextEditingController();

  final reviewkey = GlobalKey<FormState>();
  late DateTime joinDate, endDate;

  _fetchBookMarked() async {
    var user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      var doc = await db
          .collection("User")
          .doc(user.uid.substring(0, 20))
          .collection("bookmarks")
          .doc(widget.id)
          .get();
      if (doc.exists) {
        print('data exists');
        setState(() {
          bookmarks = true;
        });
      }
    }
    FirebaseFirestore.instance.settings.persistenceEnabled;
    FirebaseFirestore.instance.enablePersistence();
  }

  
  @override
  void initState() {
    db = FirebaseFirestore.instance;
    print(widget.id);
    _fetchBookMarked();
    loadVendorData();

    print("Timetamp Data");
    print((DateTime.now().microsecondsSinceEpoch ~/ 1000).toString());

    super.initState();
    // Fluttertoast.showToast(
    //     msg: DateTime.now().microsecondsSinceEpoch.toString());
  }

  refersh() {
    db = FirebaseFirestore.instance;
    _fetchBookMarked();
    loadVendorData(refersh: true);
  }

  bool isLoading = true;

  String userBGImage =
      "https://firebasestorage.googleapis.com/v0/b/neabiiapp.appspot.com/o/360_F_64678017_zUpiZFjj04cnLri7oADnyMH0XBYyQghG.jpg?alt=media&token=27052833-5800-4721-9429-d21c4a3eac1b";

  String userImage =
      "https://firebasestorage.googleapis.com/v0/b/neabiiapp.appspot.com/o/360_F_64678017_zUpiZFjj04cnLri7oADnyMH0XBYyQghG.jpg?alt=media&token=27052833-5800-4721-9429-d21c4a3eac1b";

  bool visibleProgress=false;
  XFile? selectedImage = XFile("");

  _imgFromGallery() async {
    XFile? images = await ImagePicker().pickImage(source: ImageSource.gallery);
    //.getImage(source: ImageSource.gallery, imageQuality: 88);
    if (images != null) {
      setState(() {
        //eventImage = images.path;
        selectedImage = images;
      });
    }else{
      selectedImage=null;
    }
  }

  updateCover() async {
    if(selectedImage!=null) {
      Reference reference = FirebaseStorage.instance.ref().child(
          'businessImage/' +
              FirebaseAuth.instance.currentUser!.uid.substring(0, 20) +
              ".jpg");
      UploadTask uploadTask = reference.putFile(File(selectedImage!.path));
      var snapshot = await uploadTask;
      var imageUrl = await snapshot.ref.getDownloadURL();

      Map<String, dynamic> update = {};
      update["businessImage"] = imageUrl;

      db.collection("vendor").doc(uid).update(update).then((value) {
        Fluttertoast.showToast(msg: "Updated Cover Image");
        loadVendorData();
      }).catchError((onError) {
        Fluttertoast.showToast(msg: "Error Updated Cover Image");
      });
    }else{
      Fluttertoast.showToast(msg: "Image is not selected");
    }
  }

  updateProfile() async {
    if(selectedImage!=null) {
      File fileName = File(selectedImage!.path);
      Reference reference = FirebaseStorage.instance.ref().child(
          'user/profile/' +
              FirebaseAuth.instance.currentUser!.uid.substring(0, 20) +
              ".jpg");
      UploadTask uploadTask = reference.putFile(fileName);
      TaskSnapshot snapshot = await uploadTask;
      var imageUrl = await snapshot.ref.getDownloadURL();

      Map<String, dynamic> update = {};
      update["image"] = imageUrl;

      db.collection("User").doc(uid).update(update).then((value) {
        Fluttertoast.showToast(msg: "Updated Cover Image");
        loadVendorData();
      }).catchError((onError) {
        Fluttertoast.showToast(msg: "Error Updated Cover Image");
      });
    }else{
      Fluttertoast.showToast(msg: "Image not selected");
    }
  }

  saveVndorImages() async {
    if(selectedImage!=null) {
      setState(() {
        visibleProgress = true;
      });
      File fileName = File(selectedImage!.path);
      var ref = db.collection("vendor").doc(uid).collection("images").doc();
      Reference reference = FirebaseStorage.instance
          .ref()
          .child('Vendor/images/' + uid + "/" + ref.id + ".jpg");
      UploadTask uploadTask = reference.putFile(fileName);
      TaskSnapshot snapshot = await uploadTask;
      var imageUrl = await snapshot.ref.getDownloadURL();

      Map<String, dynamic> update = {};
      update["image"] = imageUrl;

      ref.set(update).then((value) {
        Fluttertoast.showToast(msg: "Image Added");
        loadVendorData();
      }).catchError((onError) {
        Fluttertoast.showToast(msg: "Error to Add Image");
      });
    }else{
      Fluttertoast.showToast(msg: "Image not selected");
    }
  }

  bool showRating = true;
  double vendorRating = 0.0;
  late VendorModel currentVendor;
  loadVendorData({bool refersh = false}) async {
    setState(() {
      uid = widget.id;
    });
    print(widget.id);
    if (Notifcheck.userDAta == null) {
      var b =
          await FirebaseFirestore.instance.collection('User').doc(uid).get();
      Notifcheck.userDAta = b.data()!;
      log("fetchingdatatwice");
    }
    await FirebaseFirestore.instance
        .collection("vendor")
        .doc(uid)
        .collection("Reviews")
        .where("cliId",
            isEqualTo: FirebaseAuth.instance.currentUser!.uid.substring(0, 20))
        .get()
        .then((value) async {
      print("Response");

      if (value.docs.isEmpty) {
        showRating = true;
      } else {
        setState(() {
          showRating = false;
        });
      }
    });

    await FirebaseFirestore.instance
        .collection('User')
        .doc(FirebaseAuth.instance.currentUser!.uid.substring(0, 20))
        .get()
        .then((value) {
      setState(() {
        userImage = value.data()!['image'].toString().isEmptyOrNull
            ? "https://firebasestorage.googleapis.com/v0/b/neabiiapp.appspot.com/o/360_F_64678017_zUpiZFjj04cnLri7oADnyMH0XBYyQghG.jpg?alt=media&token=27052833-5800-4721-9429-d21c4a3eac1b"
            : value.data()!['image'].toString();
        setState(() {
          visibleProgress=false;
        });
        if (value.data()!.containsKey('member')) {
          joinDate = value.data()!['member']['joinDate'].toDate();
          endDate = DateTime.fromMillisecondsSinceEpoch(
              value.data()!['member']['endDate']);
          print('endDate ${endDate.toString()}');
          memberDays = endDate.difference(DateTime.now()).inDays;
        } else {
          memberDays = 0;
        }
      });
    });

    // if (mounted) {
    //   setState(() {
    //     userImage = Notifcheck.userDAta["image"];
    //     if (Notifcheck.userDAta['member']["joinDate"] != null) {
    //       joinDate =
    //           (Notifcheck.userDAta['member']["joinDate"] as Timestamp).toDate();
    //       endDate = DateTime.fromMillisecondsSinceEpoch(
    //           Notifcheck.userDAta['member']["endDate"]);
    //       memberDays = endDate.difference(DateTime.now()).inDays;
    //       print('endDate ${endDate.toString()}');
    //     } else {
    //       memberDays = 0;
    //     }
    //   });
    // }
    if (uid == FirebaseAuth.instance.currentUser!.uid.substring(0, 20)) {
      widget.isVisiter = false;
    }
    if (refersh) {
      Notifcheck.currentVendor = null;
    }
    if (Notifcheck.currentVendor == null && (!widget.isVisiter)) {
      var vendor =
          await FirebaseFirestore.instance.collection('vendor').doc(uid).get();

      if (vendor.data() != null) {
        Notifcheck.currentVendor = VendorModel.fromMap(vendor.data()!);
        currentVendor = Notifcheck.currentVendor!;
      }
    } else {
      var vendor =
          await FirebaseFirestore.instance.collection('vendor').doc(uid).get();

      if (vendor.data() != null) {
        currentVendor = VendorModel.fromMap(vendor.data()!);
      }
    }

    setState(() {
      isLoading = false;

      var nowMin = DateTime.now().hour * 60 + DateTime.now().minute;
      var openMin = DateTime.fromMillisecondsSinceEpoch(currentVendor.openTime)
                  .hour *
              60 +
          DateTime.fromMillisecondsSinceEpoch(currentVendor.openTime).minute;
      var closeMin =
          DateTime.fromMillisecondsSinceEpoch(currentVendor.closeTime).hour *
                  60 +
              DateTime.fromMillisecondsSinceEpoch(currentVendor.closeTime)
                  .minute;

      List<String> workday = currentVendor.workingDay.split("-");
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
          currentVendor.open = ("closed");
        } else {
          currentVendor.open = ("open");
        }
      } else {
        currentVendor.open = ("closed");
      }
    });

    print("Showing data");

    double mainRating = 0.0;

    var collection = FirebaseFirestore.instance
        .collection('vendor')
        .doc(uid)
        .collection("Reviews");
    var querySnapshot = await collection.get();
    print(querySnapshot.docs.length);
    for (var doc in querySnapshot.docs) {
      Map<String, dynamic> data = doc.data();
      var rate = data['starRate']; // <-- Retrieving the value.

      mainRating += rate;
    }

    print("Main Rating");

    if (mounted) {
      setState(() {
        totalRatingCount = querySnapshot.docs.length ?? 0;
        vendorRating = mainRating == 0
            ? mainRating
            : mainRating / querySnapshot.docs.length;
      });
      FirebaseFirestore.instance
          .collection('vendor')
          .doc(uid)
          .set({"rating": vendorRating}, SetOptions(merge: true));
    }
    _controller.sink.add(SwipeRefreshState.hidden);
  }

  var rating = 0.0;

  submitRating() async {
    reviewkey.currentState!.validate();
    if (reviewcontroller.text.isEmptyOrNull) {
      Fluttertoast.showToast(msg: "No Review Text");
      return;
    }
    final myid = FirebaseAuth.instance.currentUser!.uid.substring(0, 20);

    await FirebaseFirestore.instance
        .collection("vendor")
        .doc(uid)
        .collection("Reviews")
        .where("cliId", isEqualTo: myid)
        .get()
        .then((value) async {
      print("Response");

      if (value.docs.isEmpty) {
        await FirebaseFirestore.instance
            .collection('User')
            .doc(myid)
            .get()
            .then((value) {
          Map<String, dynamic> revData = {};

          revData["uid"] = uid;
          revData["cliId"] = myid;
          revData["starRate"] = rating;
          revData["message"] = reviewcontroller.text.toString();
          revData["cliName"] = value.get("name");
          revData["cliProfile"] = value.get("image");

          db
              .collection("vendor")
              .doc(uid)
              .collection("Reviews")
              .add(revData)
              .then((value) async {
            await FirebaseFirestore.instance
                .collection('User')
                .doc(uid)
                .update({"wallet": FieldValue.increment(10)}).then((value) {
              updateWallet(uid, "Review Points", true, 10,
                  DateTime.now().millisecondsSinceEpoch, 10);
              Fluttertoast.showToast(msg: "Rating Submitted");
            });
            Fluttertoast.showToast(msg: "Review submited");
          }).catchError((onError) {
            Fluttertoast.showToast(msg: "Error Review submite");
          });
        });
        setState(() {
          showRating = false;
        });
      } else {
        Fluttertoast.showToast(msg: "You Have Already Submited Review Before");
      }
    }).catchError((onError) {
      print("Error to get Value");
    });
  }

  Future<void> editName() async {
    String newName = '';
    await showDialog(
        barrierDismissible: false,
        context: context,
        builder: (context) {
          var x = MediaQuery.of(context).size.width / 2;
          var y = MediaQuery.of(context).size.height / 2;
          return Dialog(
            child: SizedBox(
                width: MediaQuery.of(context).size.width / 2,
                height: MediaQuery.of(context).size.height / 4,
                child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SizedBox(
                        height: y / 8,
                        child: TextField(
                          onChanged: (value) {
                            newName = value;
                          },
                          decoration: InputDecoration(
                            contentPadding:
                                const EdgeInsets.only(left: 10, right: 20),
                            label: "Enter Your Name".text.make().px8(),
                            border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(y / 20)),
                          ),
                        ),
                      ).pOnly(bottom: y / 32, left: x / 16, right: x / 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            width: 100,
                            height: y / 12,
                            child: "Cancel".text.xl.makeCentered().onInkTap(() {
                              Navigator.of(context).pop();
                            }),
                            decoration: BoxDecoration(
                                border: Border.all(
                                    color: const ui.Color.fromARGB(
                                        255, 0, 109, 82),
                                    width: 1),
                                gradient: const RadialGradient(
                                    radius: 4,
                                    colors: [
                                      ui.Color.fromARGB(255, 0, 247, 255),
                                      Color(0xffC4C4C4)
                                    ]),
                                borderRadius: BorderRadius.circular(50)),
                          ),
                          SizedBox(width: x / 14),
                          Container(
                            width: 100,
                            height: y / 12,
                            child: "Submit".text.xl.makeCentered().onInkTap(() {
                              if (!newName.isEmptyOrNull) {
                                FirebaseFirestore.instance
                                    .collection('vendor')
                                    .doc(uid)
                                    .set({"businessName": newName},
                                        SetOptions(merge: true)).then((value) {
                                  Navigator.of(context).pop();
                                  loadVendorData(refersh: true);
                                });
                              } else {
                                Fluttertoast.showToast(
                                    msg: 'Please Enter Name');
                              }
                            }),
                            decoration: BoxDecoration(
                                border: Border.all(
                                    color: const ui.Color.fromARGB(
                                        255, 0, 109, 82),
                                    width: 1),
                                gradient: const RadialGradient(
                                    radius: 4,
                                    colors: [
                                      ui.Color.fromARGB(255, 0, 247, 255),
                                      Color(0xffC4C4C4)
                                    ]),
                                borderRadius: BorderRadius.circular(50)),
                          ),
                        ],
                      ).px8()
                    ])),
          );
        });
  }

  Future<void> editTime() async {
    String? starDay = '';
    var controllerTimeTo = TextEditingController();
    var startTime = "";
    DateTime startTimeUnix = DateTime.now();
    var endTime = "";
    DateTime endTimeUnix = DateTime.now();
    var controllerTimeFrom = TextEditingController();
    String? endDay;
    await showDialog(
        barrierDismissible: false,
        context: context,
        builder: (context) {
          var x = MediaQuery.of(context).size.width;
          var y = MediaQuery.of(context).size.height / 4.5;
          return StatefulBuilder(builder: (contex, setState) {
            return Dialog(
              child: SizedBox(
                  width: MediaQuery.of(context).size.width,
                  height: MediaQuery.of(context).size.height / 3.5,
                  child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            SizedBox(
                                width: x / 3.5,
                                child: TextField(
                                  readOnly: true,
                                  controller: controllerTimeFrom,
                                  decoration: InputDecoration(
                                    contentPadding: const EdgeInsets.only(
                                        left: 10, right: 20),
                                    label: "Open Time"
                                        .text
                                        .sm
                                        .makeCentered()
                                        .px4(),
                                    border: const OutlineInputBorder(
                                        borderSide: BorderSide(
                                            color: Color.fromARGB(
                                                173, 125, 209, 248)),
                                        borderRadius: BorderRadius.zero),
                                  ),
                                  onTap: () {
                                    DatePicker.showTime12hPicker(context,
                                        showTitleActions: true,
                                        onChanged: (date) {
                                      print('change $date');
                                    }, onConfirm: (date) {
                                      int h = date.hour > 12
                                          ? date.hour - 12
                                          : date.hour;
                                      String ampm =
                                          date.hour > 12 ? "PM" : "AM";
                                      startTimeUnix = date;
                                      startTime = h.toString() +
                                          ":" +
                                          date.minute.toString() +
                                          " - " +
                                          ampm;

                                      controllerTimeFrom.text = startTime;
                                      setState(() {});
                                    },
                                        currentTime: DateTime.now(),
                                        locale: LocaleType.en);
                                  },
                                )),
                            "To"
                                .text
                                .xl
                                .bold
                                .color(const Color(0xff999999))
                                .make(),
                            Container(
                              width: x / 3.5,
                              decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(y / 18)),
                              child: TextField(
                                readOnly: true,
                                controller: controllerTimeTo,
                                decoration: InputDecoration(
                                  contentPadding: const EdgeInsets.only(
                                      left: 10, right: 20),
                                  label:
                                      "Close Time".text.sm.makeCentered().px4(),
                                  border: const OutlineInputBorder(
                                      borderRadius: BorderRadius.zero),
                                ),
                                onTap: () {
                                  DatePicker.showTimePicker(context,
                                      showTitleActions: true,
                                      showSecondsColumn: false,
                                      onChanged: (date) {
                                    print('change $date');
                                  }, onConfirm: (date) {
                                    int h = date.hour > 12
                                        ? date.hour - 12
                                        : date.hour;
                                    String ampm = date.hour > 12 ? "PM" : "AM";

                                    endTimeUnix = date;

                                    endTime = h.toString() +
                                        ":" +
                                        date.minute.toString() +
                                        " - " +
                                        ampm;
                                    controllerTimeTo.text = endTime;

                                    setState(() {});
                                    print('confirm $date');
                                  },
                                      currentTime: DateTime.now(),
                                      locale: LocaleType.en);
                                },
                              ).centered(),
                            ),
                          ],
                        ).px12().pOnly(bottom: 12),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Container(
                                width: x / 3.4,
                                decoration: BoxDecoration(
                                    borderRadius:
                                        BorderRadius.circular(y / 18)),
                                child: DropdownButtonFormField(
                                  hint: const Text(
                                    "Start Day",
                                    textScaleFactor: 0.8,
                                    style: TextStyle(
                                        color:
                                            Color.fromARGB(255, 203, 207, 207)),
                                  ),
                                  decoration: InputDecoration(
                                    hintText: "Start Day",
                                    hintStyle: const TextStyle(
                                        color:
                                            Color.fromARGB(255, 203, 207, 207)),
                                    enabledBorder: const OutlineInputBorder(
                                        borderSide: BorderSide(
                                      color: Color.fromARGB(173, 125, 209, 248),
                                    )),
                                    focusedBorder: OutlineInputBorder(
                                      borderSide: const BorderSide(
                                          color: Color.fromARGB(
                                              173, 125, 209, 248),
                                          width: 1),
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    border: OutlineInputBorder(
                                      borderSide: const BorderSide(
                                          color: Color.fromARGB(
                                              173, 125, 209, 248),
                                          width: 1),
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                  ),
                                  // value: starDay,
                                  dropdownColor:
                                      const Color.fromARGB(255, 243, 243, 243),
                                  onChanged: (String? newValue) {
                                    setState(() {
                                      starDay = newValue;
                                    });
                                    if (starDay.isEmptyOrNull ||
                                        endDay.isEmptyOrNull) {
                                      Fluttertoast.showToast(
                                          msg: "Select Start or End Day");
                                      return;
                                    }
                                    var work = starDay! + "-" + endDay!;
                                  },
                                  items: <String>[
                                    'Mon',
                                    'Tue',
                                    'Wed',
                                    'Thu',
                                    'Fri',
                                    'Sat',
                                    'Sun'
                                  ].map((String value) {
                                    return DropdownMenuItem<String>(
                                      value: value,
                                      child: Text(
                                        value,
                                        textScaleFactor: 0.8,
                                      ),
                                    );
                                  }).toList(),
                                )),
                            "To"
                                .text
                                .xl
                                .bold
                                .color(const Color(0xff999999))
                                .make()
                                .centered(),
                            Container(
                                width: x / 3.5,
                                decoration: BoxDecoration(
                                    borderRadius:
                                        BorderRadius.circular(y / 18)),
                                child: DropdownButtonFormField(
                                  hint: const Text(
                                    "Close Day",
                                    textScaleFactor: 0.7,
                                    style: TextStyle(
                                        color:
                                            Color.fromARGB(255, 203, 207, 207)),
                                  ),
                                  decoration: InputDecoration(
                                    hintStyle: const TextStyle(
                                        color:
                                            Color.fromARGB(255, 203, 207, 207)),
                                    enabledBorder: const OutlineInputBorder(
                                        borderSide: BorderSide(
                                      color: Color.fromARGB(173, 125, 209, 248),
                                    )),
                                    focusedBorder: OutlineInputBorder(
                                      borderSide: const BorderSide(
                                          color: Color.fromARGB(
                                              173, 125, 209, 248),
                                          width: 1),
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    border: OutlineInputBorder(
                                      borderSide: const BorderSide(
                                          color: Color.fromARGB(
                                              173, 125, 209, 248),
                                          width: 1),
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                  ),
                                  dropdownColor:
                                      const Color.fromARGB(255, 243, 243, 243),
                                  onChanged: (String? newValue) {
                                    print(endDay);
                                    setState(() {
                                      endDay = newValue;
                                    });
                                    if (starDay.isEmptyOrNull ||
                                        endDay.isEmptyOrNull) {
                                      Fluttertoast.showToast(
                                          msg: "Select Start or End Day");
                                      return;
                                    }
                                    var work = starDay! + "-" + endDay!;
                                  },
                                  //  value: endDay,
                                  items: <String>[
                                    'Mon',
                                    'Tue',
                                    'Wed',
                                    'Thu',
                                    'Fri',
                                    'Sat',
                                    'Sun'
                                  ].map((String value) {
                                    return DropdownMenuItem<String>(
                                      value: value,
                                      child: Text(
                                        value,
                                        textScaleFactor: 0.7,
                                      ),
                                    );
                                  }).toList(),
                                )),
                          ],
                        ).px12().pOnly(bottom: 12),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              width: 100,
                              height: y / 6,
                              child:
                                  "Cancel".text.xl.makeCentered().onInkTap(() {
                                Navigator.of(context).pop();
                              }),
                              decoration: BoxDecoration(
                                  border: Border.all(
                                      color: const ui.Color.fromARGB(
                                          255, 0, 109, 82),
                                      width: 1),
                                  gradient: const RadialGradient(
                                      radius: 4,
                                      colors: [
                                        ui.Color.fromARGB(255, 0, 247, 255),
                                        Color(0xffC4C4C4)
                                      ]),
                                  borderRadius: BorderRadius.circular(50)),
                            ),
                            SizedBox(width: x / 14),
                            Container(
                              width: 100,
                              height: y / 6,
                              child: "Submit"
                                  .text
                                  .xl
                                  .makeCentered()
                                  .onInkTap(() async {
                                if (startTime.isEmptyOrNull ||
                                    endDay.isEmptyOrNull ||
                                    endTime.isEmptyOrNull ||
                                    starDay.isEmptyOrNull) {
                                  Fluttertoast.showToast(
                                    msg: 'Enter Values',
                                    toastLength: Toast.LENGTH_SHORT,
                                    gravity: ToastGravity.BOTTOM,
                                  );
                                } else {
                                  var work = starDay! + "-" + endDay!;
                                  await FirebaseFirestore.instance
                                      .collection('vendor')
                                      .doc(uid)
                                      .set({
                                    "openTime":
                                        startTimeUnix.millisecondsSinceEpoch
                                  }, SetOptions(merge: true));

                                  await FirebaseFirestore.instance
                                      .collection('vendor')
                                      .doc(uid)
                                      .set({
                                    "closeTime":
                                        endTimeUnix.millisecondsSinceEpoch
                                  }, SetOptions(merge: true));

                                  await FirebaseFirestore.instance
                                      .collection('vendor')
                                      .doc(uid)
                                      .set({
                                    "workingDay": work
                                  }, SetOptions(merge: true)).then((value) {
                                    Navigator.of(context).pop();
                                    loadVendorData(refersh: true);
                                  });
                                }
                              }),
                              decoration: BoxDecoration(
                                  border: Border.all(
                                      color: const ui.Color.fromARGB(
                                          255, 0, 109, 82),
                                      width: 1),
                                  gradient: const RadialGradient(
                                      radius: 4,
                                      colors: [
                                        ui.Color.fromARGB(255, 0, 247, 255),
                                        Color(0xffC4C4C4)
                                      ]),
                                  borderRadius: BorderRadius.circular(50)),
                            ),
                          ],
                        ).px8()
                      ])),
            );
          });
        });
  }

  Future<void> editLocation() async {
    var loc = await GeolocatorPlatform.instance
        .getCurrentPosition(locationSettings: const LocationSettings());
    Map<String, dynamic> location = {
      "lat": loc.latitude,
      "long": loc.longitude
    };

    await showDialog(
        barrierDismissible: false,
        context: context,
        builder: (context) {
          var x = MediaQuery.of(context).size.width / 2;
          var y = MediaQuery.of(context).size.height / 2;
          return StatefulBuilder(builder: (context, setState) {
            return Dialog(
              child: SizedBox(
                  width: MediaQuery.of(context).size.width / 2,
                  height: MediaQuery.of(context).size.height / 4,
                  child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        GestureDetector(
                          onTap: () async {
                            showDialog(
                                context: context,
                                builder: (context) {
                                  return const SizedBox(
                                          height: 50,
                                          width: 50,
                                          child: CircularProgressIndicator())
                                      .centered();
                                });

                            Navigator.of(context).pop();

                            location = await Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (context) => GoogleMapScreen(
                                  lat: loc.latitude,
                                  long: loc.longitude,
                                ),
                              ),
                            );
                            setState(() {});
                          },
                          child: Container(
                            width: double.infinity,
                            decoration: BoxDecoration(
                              border:
                                  Border.all(color: kAdvertiseContainerColor),
                              borderRadius: BorderRadius.circular(8.6),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 9, vertical: 10),
                              child: (location.toString().isEmptyOrNull)
                                  ? Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.start,
                                      children: [
                                        Container(
                                          height: 100,
                                          width: x / 3,
                                          decoration: BoxDecoration(
                                            color:
                                                kHomeScreenServicesContainerColor,
                                            borderRadius:
                                                BorderRadius.circular(8.69),
                                          ),
                                          child: Icon(
                                            Icons.location_on_outlined,
                                            size: x / 4,
                                            color: Colors.white,
                                          ),
                                        ),
                                        Text(
                                          "Pin your Location *",
                                          style: TextStyle(
                                            fontWeight: FontWeight.w400,
                                            fontSize: 18,
                                            color: kAdvertiseContainerTextColor,
                                          ),
                                        ),
                                      ],
                                    )
                                  : Row(
                                      children: [
                                        Container(
                                          height: x / 10,
                                          width: x / 10,
                                          decoration: BoxDecoration(
                                            color:
                                                kHomeScreenServicesContainerColor,
                                            borderRadius:
                                                BorderRadius.circular(8.69),
                                          ),
                                          child: const Icon(
                                            Icons.location_on_outlined,
                                            color: Colors.white,
                                          ),
                                        ),
                                        Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.center,
                                          children: [
                                            "Lattitude = ${location["lat"].toString()}"
                                                .text
                                                .make(),
                                            "Longitude = ${location["long"].toString()}"
                                                .toString()
                                                .text
                                                .make()
                                          ],
                                        ).expand(),
                                      ],
                                    ),
                            ),
                          ),
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              width: 100,
                              height: y / 12,
                              child:
                                  "Cancel".text.xl.makeCentered().onInkTap(() {
                                Navigator.of(context).pop();
                              }),
                              decoration: BoxDecoration(
                                  border: Border.all(
                                      color: const ui.Color.fromARGB(
                                          255, 0, 109, 82),
                                      width: 1),
                                  gradient: const RadialGradient(
                                      radius: 4,
                                      colors: [
                                        ui.Color.fromARGB(255, 0, 247, 255),
                                        Color(0xffC4C4C4)
                                      ]),
                                  borderRadius: BorderRadius.circular(50)),
                            ),
                            SizedBox(width: x / 14),
                            Container(
                              width: 100,
                              height: y / 12,
                              child:
                                  "Submit".text.xl.makeCentered().onInkTap(() {
                                Fluttertoast.showToast(msg: "Updating");
                                log(location.toString());
                                FirebaseFirestore.instance
                                    .collection('vendor')
                                    .doc(uid)
                                    .set({"businessLocation": location},
                                        SetOptions(merge: true)).then((value) {
                                  Navigator.of(context).pop();
                                  loadVendorData(refersh: true);
                                });
                              }),
                              decoration: BoxDecoration(
                                  border: Border.all(
                                      color: const ui.Color.fromARGB(
                                          255, 0, 109, 82),
                                      width: 1),
                                  gradient: const RadialGradient(
                                      radius: 4,
                                      colors: [
                                        ui.Color.fromARGB(255, 0, 247, 255),
                                        Color(0xffC4C4C4)
                                      ]),
                                  borderRadius: BorderRadius.circular(50)),
                            ),
                          ],
                        ).px8()
                      ])),
            );
          });
        });
  }

  final _controller = StreamController<SwipeRefreshState>.broadcast();

  Stream<SwipeRefreshState> get _stream => _controller.stream;

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;
     return Scaffold(
      appBar: AppBar(
        toolbarHeight: 60,
        iconTheme: IconThemeData(color: Colors.black),
        // elevation: 2,
        title: Text("Profile",style: TextStyle(color: Colors.black),),
      ),
        body: SafeArea(
      child: !isLoading
          ? SwipeRefresh.builder(
              onRefresh: () {
                refersh();
              },
              stateStream: _stream,
              itemCount: 1,
              itemBuilder: (context, i) {
                return SingleChildScrollView(
                  child: Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Column(
                            children: [
                              Container(
                                height: width - 150,
                                decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(5)),
                                child: Stack(
                                  children: [
                                    InkWell(
                                      onTap: () {
                                        final imageProvider = Image.network(
                                                currentVendor
                                                        .businessImage.isEmptyOrNull
                                                    ? Notifcheck.defCover
                                                    : currentVendor.businessImage)
                                            .image;
                                        showImageViewer(context, imageProvider,
                                            onViewerDismissed: () {
                                          print("dismissed");
                                        });
                                        // showDialog(
                                        //     barrierColor:
                                        //         ui.Color.fromARGB(103, 26, 26, 26),
                                        //     context: (context),
                                        //     builder: (BuildContextcontext) {
                                        //       return Center(
                                        //         child: SizedBox(
                                        //           width: 300,
                                        //           height: 300,
                                        //           child: Image.network(currentVendor
                                        //                   .businessImage.isEmptyOrNull
                                        //               ? Notifcheck.defCover
                                        //               : currentVendor.businessImage),
                                        //         ),
                                        //       );
                                        //     });
                                      },
                                      child: Container(
                                        height: width - 205,
                                        decoration: BoxDecoration(
                                          borderRadius: BorderRadius.circular(5),
                                          image: DecorationImage(
                                            image: NetworkImage(currentVendor
                                                    .businessImage.isEmptyOrNull
                                                ? Notifcheck.defCover
                                                : currentVendor.businessImage),
                                            fit: BoxFit.fitWidth,
                                          ),
                                        ),
                                      ),
                                    ),
                                    if (widget.isVisiter == false)
                                      Positioned(
                                        right: 12,
                                        top: 12,
                                        child: GestureDetector(
                                          onTap: () {
                                            _imgFromGallery().then((e) {
                                              updateCover();
                                            });
                                          },
                                          child: Container(
                                            width: 30,
                                            height: 30,
                                            decoration: const BoxDecoration(
                                              color: Color(0xFFFFFEE7),
                                              shape: BoxShape.circle,
                                            ),
                                            child: const Icon(
                                              Icons.camera_alt_outlined,
                                              size: 16,
                                            ),
                                          ),
                                        ),
                                      ),
                                    Positioned(
                                      bottom: 0,
                                      left: 8,
                                      child: Stack(
                                        children: [
                                          InkWell(
                                            onTap: () {
                                              final imageProvider =
                                                  Image.network(userImage).image;
                                              showImageViewer(
                                                  context, imageProvider,
                                                  onViewerDismissed: () {
                                                print("dismissed");
                                              });
                                              // showDialog(
                                              //     barrierColor: ui.Color.fromARGB(
                                              //         103, 26, 26, 26),
                                              //     context: (context),
                                              //     builder: (BuildContextcontext) {
                                              //       return Center(
                                              //         child: Container(
                                              //           width: 300,
                                              //           height: 300,
                                              //           child: Image.network(userImage),
                                              //         ),
                                              //       );
                                              //     });
                                            },
                                            child: Container(
                                              height: 110,
                                              width: 110,
                                              decoration: const BoxDecoration(
                                                color: Colors.white,
                                                shape: BoxShape.circle,
                                              ),
                                              child: Padding(
                                                padding: const EdgeInsets.all(4.0),
                                                child: Container(
                                                  decoration: BoxDecoration(
                                                    shape: BoxShape.circle,
                                                    image: DecorationImage(
                                                      image:
                                                          NetworkImage(userImage),
                                                      fit: BoxFit.fill,
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ),
                                          if (widget.isVisiter == false)
                                            Positioned(
                                              right: 10,
                                              bottom: 0,
                                              child: GestureDetector(
                                                onTap: () {
                                                  _imgFromGallery().then((e) {
                                                    updateProfile();
                                                  });
                                                },
                                                child: Container(
                                                  width: 30,
                                                  height: 30,
                                                  decoration: BoxDecoration(
                                                    color:
                                                        kUserProfileImageChangeContainerColor,
                                                    shape: BoxShape.circle,
                                                  ),
                                                  child: const Icon(
                                                    Icons.camera_alt_outlined,
                                                    size: 16,
                                                  ),
                                                ),
                                              ),
                                            ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          Padding(
                            padding: const EdgeInsets.only(bottom: 20,top: 8),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Text(
                                      currentVendor.businessName,
                                      style: TextStyle(
                                        fontWeight: FontWeight.w600,
                                        fontSize: 20,
                                        color: kLoadingScreenTextColor,
                                      ),
                                    ),
                                    SizedBox(width: 8,),
                                    if (!widget.isVisiter)
                                      GestureDetector(
                                        onTap: () {
                                          editName();
                                        },
                                        child: const Icon(
                                          Icons.edit,
                                          size: 19,
                                        ),
                                      )
                                  ],
                                ),
                                Padding(
                                  padding:
                                      const EdgeInsets.only(top: 5, bottom: 7),
                                  child: Text(
                                    currentVendor.name,
                                    style: TextStyle(
                                      fontWeight: FontWeight.w400,
                                      fontSize: 16,
                                      color: kPlansDescriptionTextColor,
                                    ),
                                  ),
                                ),
                                Padding(
                                    padding: const EdgeInsets.only(
                                        top: 5, bottom: 7),
                                    child: ReadMoreText(
                                      currentVendor.bussinesDesc,
                                      trimLines: 2,
                                      colorClickableText: Colors.pink,
                                      trimMode: TrimMode.Line,
                                      trimCollapsedText: 'Show more',
                                      trimExpandedText: 'Show less',
                                      moreStyle: const TextStyle(
                                          color: Colors.lightBlue,
                                          fontSize: 14,
                                          fontWeight: FontWeight.bold),
                                      lessStyle: const TextStyle(
                                          color: Colors.lightBlue,
                                          fontSize: 14,
                                          fontWeight: FontWeight.bold),
                                    )),
                                Row(
                                  children: [
                                    Text(
                                      vendorRating.toStringAsFixed(2),
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
                                      initialRating: vendorRating,
                                      itemSize: 17,
                                      direction: Axis.horizontal,
                                      allowHalfRating: true,
                                      ignoreGestures: true,
                                      tapOnlyMode: false,
                                      itemCount: 5,
                                      glowColor:
                                          kCreditPointScaffoldBackgroundColor,
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
                                      itemPadding: const EdgeInsets.symmetric(
                                          horizontal: 0),
                                      onRatingUpdate: (rating) {
                                        print(rating);
                                      },
                                    ),
                                    const SizedBox(
                                      width: 5,
                                    ),
                                    Text(
                                      "$totalRatingCount. Ratings ",
                                      style: TextStyle(
                                        fontWeight: FontWeight.w300,
                                        fontSize: 12,
                                        color: kLoadingScreenTextColor,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(
                                  height: 26,
                                ),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceAround,
                                  children: [
                                    if(widget.isVisiter)
                                      GestureDetector(
                                      onTap: () async {
                                        var mobbbb =
                                            currentVendor.businessMobileNumber;
                                        var url = "tel:$mobbbb";
                                        if (await canLaunch(url)) {
                                          await launch(url);
                                        } else {
                                          throw 'Could not launch $url';
                                        }
                                        Clipboard.setData(ClipboardData(
                                            text: currentVendor
                                                .businessMobileNumber));

                                        Fluttertoast.showToast(
                                            msg: "Mobile Copied to Clipboard");
                                      },
                                      child: Stack(
                                        children: [
                                          Container(
                                            height: 45,
                                            width: 45,
                                            decoration: BoxDecoration(
                                              color: Colors.white,
                                              border: Border.all(
                                                  color: Colors.black),
                                              shape: BoxShape.circle,
                                            ),
                                            child: const Icon(Icons.call),
                                          ),
                                        ],
                                      ),
                                    ),

                                    // if(widget.isVisiter)
                                    //   GestureDetector(
                                    //     onTap: () async {
                                    //       var mobbbb =
                                    //           currentVendor.businessMobileNumber;
                                    //       var url = "tel:$mobbbb";
                                    //       if (await canLaunch(url)) {
                                    //         await launch(url);
                                    //       } else {
                                    //         throw 'Could not launch $url';
                                    //       }
                                    //       Clipboard.setData(ClipboardData(
                                    //           text: currentVendor
                                    //               .businessMobileNumber));
                                    //
                                    //       Fluttertoast.showToast(
                                    //           msg: "Mobile Copied to Clipboard");
                                    //     },
                                    //     child: Stack(
                                    //       children: [
                                    //         Container(
                                    //           height: 45,
                                    //           width: 45,
                                    //           decoration: BoxDecoration(
                                    //             color: Colors.white,
                                    //             border: Border.all(
                                    //                 color: Colors.black),
                                    //             shape: BoxShape.circle,
                                    //           ),
                                    //           child: const Icon(Icons.percent),
                                    //         ),
                                    //       ],
                                    //     ),
                                    //   ),

                                    if (!widget.isVisiter)
                                      GestureDetector(
                                        onTap: () async {
                                          Navigator.of(context).push(
                                            MaterialPageRoute(
                                              builder: (context) =>
                                                  const WalletScreen(),
                                            ),
                                          );
                                        },
                                        child: Container(
                                            height: 45,
                                            width: 45,
                                            decoration: BoxDecoration(
                                              color: Colors.white,
                                              border: Border.all(
                                                  color: Colors.black),
                                              shape: BoxShape.circle,
                                            ),
                                            child: const Icon(Icons.wallet)),
                                      ),
                                    if(widget.isVisiter)
                                    GestureDetector(
                                      onTap: () async {
                                        showDialog(
                                            context: context,
                                            builder: (context) {
                                              return const SizedBox(
                                                      height: 50,
                                                      width: 50,
                                                      child:
                                                          CircularProgressIndicator())
                                                  .centered();
                                            });

                                        var lat =
                                            currentVendor.businessLocation.lat;
                                        var long =
                                            currentVendor.businessLocation.long;
                                        // var loc = await GeolocatorPlatform.instance
                                        //     .getCurrentPosition(
                                        //         locationSettings:
                                        //             LocationSettings());
                                        Navigator.of(context).pop();
                                        MapsLauncher.launchCoordinates(
                                            lat, long);
                                        //map edit
                                        // Navigator.of(context).push(
                                        //     MaterialPageRoute(builder: (context) {
                                        //   return GoogleMapScreen(
                                        //       lat: loc.latitude,
                                        //       long: loc.longitude,
                                        //       show: false);
                                        // }));
                                      },
                                      child: Stack(
                                        children: [
                                          Container(
                                              height: 45,
                                              width: 45,
                                              decoration: BoxDecoration(
                                                color: Colors.white,
                                                border: Border.all(
                                                    color: Colors.black),
                                                shape: BoxShape.circle,
                                              ),
                                              child: const Icon(
                                                  Icons.location_on)),
                                          if (!widget.isVisiter)
                                            GestureDetector(
                                              onTap: () {
                                                editLocation();
                                              },
                                              child: Padding(
                                                padding: const EdgeInsets.only(
                                                    left: 30, bottom: 20),
                                                child: Container(
                                                  child: const Icon(
                                                    Icons.edit,
                                                    size: 20,
                                                  ),
                                                ),
                                              ),
                                            )
                                        ],
                                      ),
                                    ),
                                    if (widget.isVisiter)
                                      GestureDetector(
                                        onTap: () {
                                          log(FirebaseAuth
                                              .instance.currentUser!.uid
                                              .substring(0, 20));
                                          FirebaseFirestore.instance
                                              .collection("User")
                                              .doc(FirebaseAuth
                                                  .instance.currentUser!.uid
                                                  .substring(0, 20))
                                              .collection("bookmarks")
                                              .doc(widget.id)
                                              .set({widget.id: widget.id}).then(
                                                  (value) {
                                            Fluttertoast.showToast(
                                                msg: "Added To BookMarks");
                                            setState(() {
                                              bookmarks = true;
                                            });
                                          });
                                        },
                                        child: Container(
                                            height: 45,
                                            width: 45,
                                            decoration: BoxDecoration(
                                              color: Colors.white,
                                              border: Border.all(
                                                  color: Colors.black),
                                              shape: BoxShape.circle,
                                            ),
                                            child: Icon(
                                              Icons.bookmark_add,
                                              color: bookmarks
                                                  ? Colors.blue
                                                  : Colors.black,
                                            )),
                                      ),
                                    if (widget.isVisiter)
                                      GestureDetector(
                                        onTap: () {
                                          capturePng();
                                        },
                                        child: Container(
                                          height: 45,
                                          width: 45,
                                          decoration: BoxDecoration(
                                            color: Colors.white,
                                            border:
                                                Border.all(color: Colors.black),
                                            shape: BoxShape.circle,
                                          ),
                                          child: const Icon(Icons.share),
                                        ),
                                      ),
                                    if (!widget.isVisiter)
                                      GestureDetector(
                                        onTap: () => showModalBottomSheet(
                                          enableDrag: true,
                                          isDismissible: false,
                                          isScrollControlled: true,
                                          shape: const RoundedRectangleBorder(
                                            borderRadius: BorderRadius.vertical(
                                              top: Radius.circular(25),
                                            ),
                                          ),
                                          context: context,
                                          builder: (BuildContext context) {
                                            return StatefulBuilder(builder:
                                                (BuildContext context,
                                                    setStat) {
                                              return Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                mainAxisSize: MainAxisSize.min,
                                                children: [
                                                  Center(
                                                    child: Padding(
                                                      padding:
                                                          const EdgeInsets.only(
                                                              top: 10,
                                                              bottom: 46),
                                                      child: Container(
                                                        width: 70,
                                                        height: 3,
                                                        decoration:
                                                            BoxDecoration(
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(
                                                                      100),
                                                          color:
                                                              kSignUpContainerColor,
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                  Padding(
                                                    padding: const EdgeInsets
                                                            .symmetric(
                                                        horizontal: 15),
                                                    child: Column(
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .start,
                                                      children: [
                                                        GestureDetector(
                                                          onTap: () =>
                                                              Navigator.of(
                                                                      context)
                                                                  .push(
                                                            MaterialPageRoute(
                                                              builder: (context) =>
                                                                  BusinessServicesDetailsScreen(
                                                                      edit:
                                                                          true,
                                                                      data:
                                                                          currentVendor),
                                                            ),
                                                          ),
                                                          child: Row(
                                                            children: [
                                                              const SizedBox(
                                                                width: 2,
                                                              ),
                                                              const Icon(
                                                                Icons.edit,
                                                                color:
                                                                    Colors.grey,
                                                              ),
                                                              const SizedBox(
                                                                width: 11,
                                                              ),
                                                              Text(
                                                                "Edit Profile",
                                                                style:
                                                                    TextStyle(
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .w400,
                                                                  fontSize: 14,
                                                                  color:
                                                                      kLoadingScreenTextColor,
                                                                ),
                                                              ),
                                                            ],
                                                          ),
                                                        ),
                                                        Padding(
                                                          padding:
                                                              const EdgeInsets
                                                                      .symmetric(
                                                                  vertical: 15),
                                                          child: Container(
                                                            height: 0.5,
                                                            color:
                                                                kDrawerDividerColor,
                                                          ),
                                                        ),
                                                        //advertise
                                                        // GestureDetector(
                                                        //   onTap: () =>
                                                        //       Navigator.of(context)
                                                        //           .push(
                                                        //     MaterialPageRoute(
                                                        //       builder: (context) =>
                                                        //           AdvertiseScreen(),
                                                        //     ),
                                                        //   ),
                                                        //   child: Row(
                                                        //     children: [
                                                        //       SizedBox(
                                                        //         width: 2,
                                                        //       ),
                                                        //       Icon(Icons.ads_click),
                                                        //       SizedBox(
                                                        //         width: 12,
                                                        //       ),
                                                        //       Text(
                                                        //         "Advertise",
                                                        //         style: TextStyle(
                                                        //           fontWeight:
                                                        //               FontWeight
                                                        //                   .w400,
                                                        //           fontSize: 14,
                                                        //           color:
                                                        //               kLoadingScreenTextColor,
                                                        //         ),
                                                        //       ),
                                                        //     ],
                                                        //   ),
                                                        // ),
                                                        // Padding(
                                                        //   padding: const EdgeInsets
                                                        //           .symmetric(
                                                        //       vertical: 15),
                                                        //   child: Container(
                                                        //     height: 0.5,
                                                        //     color:
                                                        //         kDrawerDividerColor,
                                                        //   ),
                                                        // ),
                                                        //status
                                                        Row(
                                                          children: [
                                                            const Icon(
                                                              Icons
                                                                  .check_circle_outline,
                                                              color: Colors
                                                                  .black54,
                                                              size: 20,
                                                            ),
                                                            const SizedBox(
                                                              width: 11,
                                                            ),
                                                            Text(
                                                              "Status: ${currentVendor.active ? "Active" : "Inactive"}",
                                                              style: TextStyle(
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w400,
                                                                fontSize: 14,
                                                                color:
                                                                    kLoadingScreenTextColor,
                                                              ),
                                                            ),
                                                            const Spacer(),
                                                            Switch(
                                                              onChanged:
                                                                  (bool value) {
                                                                Fluttertoast
                                                                    .showToast(
                                                                        msg:
                                                                            "Status: ${value ? "Active" : "Inactive"}");
                                                                setStat(() {
                                                                  currentVendor
                                                                          .active =
                                                                      value;
                                                                });
                                                                FirebaseFirestore
                                                                    .instance
                                                                    .collection(
                                                                        'vendor')
                                                                    .doc(uid)
                                                                    .set({
                                                                  "active":
                                                                      value
                                                                }, SetOptions(merge: true));
                                                              },
                                                              value:
                                                                  currentVendor
                                                                      .active,
                                                            )
                                                          ],
                                                        ),
                                                        Padding(
                                                          padding:
                                                              const EdgeInsets
                                                                      .symmetric(
                                                                  vertical: 3),
                                                          child: Container(
                                                            height: 0.5,
                                                            color:
                                                                kDrawerDividerColor,
                                                          ),
                                                        ),
                                                        //my transaction
                                                        // GestureDetector(
                                                        //   onTap: () =>
                                                        //       Navigator.of(context)
                                                        //           .push(
                                                        //     MaterialPageRoute(
                                                        //       builder: (context) =>
                                                        //           TransactionHistoryScreen(
                                                        //               true),
                                                        //     ),
                                                        //   ),
                                                        //   child: Row(
                                                        //     children: [
                                                        //       Icon(
                                                        //         Icons.change_circle,
                                                        //         color:
                                                        //             Colors.black54,
                                                        //         size: 20,
                                                        //       ),
                                                        //       SizedBox(
                                                        //         width: 11,
                                                        //       ),
                                                        //       Text(
                                                        //         "My Transaction",
                                                        //         style: TextStyle(
                                                        //           fontWeight:
                                                        //               FontWeight
                                                        //                   .w400,
                                                        //           fontSize: 14,
                                                        //           color:
                                                        //               kLoadingScreenTextColor,
                                                        //         ),
                                                        //       ),
                                                        //     ],
                                                        //   ),
                                                        // ),
                                                        // Padding(
                                                        //   padding: const EdgeInsets
                                                        //           .symmetric(
                                                        //       vertical: 15),
                                                        //   child: Container(
                                                        //     height: 0.5,
                                                        //     color:
                                                        //         kDrawerDividerColor,
                                                        //   ),
                                                        // ),
                                                        //Check Plans

                                                        //renew validity

                                                        //post event
                                                        GestureDetector(
                                                          onTap: () {
                                                            Navigator.push(context, MaterialPageRoute(builder: (context)=> PlanScreen()));
                                                          },
                                                          child: Column(
                                                            children: [
                                                              Padding(
                                                                padding:
                                                                const EdgeInsets
                                                                    .symmetric(
                                                                    vertical: 13),
                                                              ),
                                                              Row(
                                                                children: [
                                                                  const Icon(
                                                                    Icons
                                                                        .lock_outline,
                                                                    color: Colors
                                                                        .black54,
                                                                    size: 20,
                                                                  ),
                                                                  const SizedBox(
                                                                    width: 11,
                                                                  ),
                                                                  Text(
                                                                    "Plans",
                                                                    style:
                                                                        TextStyle(
                                                                      fontWeight:
                                                                          FontWeight
                                                                              .w400,
                                                                      fontSize: 14,
                                                                      color:
                                                                          kLoadingScreenTextColor,
                                                                    ),
                                                                  ),
                                                                  const Spacer(),
                                                                  // "Validity Left"
                                                                  //     .text
                                                                  //     .bold
                                                                  //     .make(),
                                                                  // Container(
                                                                  //   child: ((memberDays)
                                                                  //               .toString() +
                                                                  //           " Days ")
                                                                  //       .text
                                                                  //       .sm
                                                                  //       .make()
                                                                  //       .pOnly(
                                                                  //           left:
                                                                  //               10,
                                                                  //           right:
                                                                  //               10),
                                                                  // ),
                                                                  // Stack(
                                                                  //   alignment:
                                                                  //       Alignment
                                                                  //           .center,
                                                                  //   children: [
                                                                  //     CircularProgressIndicator(
                                                                  //       backgroundColor:
                                                                  //           Colors
                                                                  //               .red,
                                                                  //       value:
                                                                  //           (memberDays /
                                                                  //               365),
                                                                  //     ),
                                                                  //   ],
                                                                  // )
                                                                ],
                                                              ),
                                                            ],
                                                          ),
                                                        ),
                                                        Padding(
                                                          padding:
                                                              const EdgeInsets
                                                                      .symmetric(
                                                                  vertical: 15),
                                                          child: Container(
                                                            height: 0.5,
                                                            color:
                                                                kDrawerDividerColor,
                                                          ),
                                                        ),
                                                        //post add
                                                        //logout
                                                        GestureDetector(
                                                          onTap: () async {
                                                            unsubscribeTopicity()
                                                                .then((value) =>
                                                                    FirebaseAuth
                                                                        .instance
                                                                        .signOut());

                                                            await Navigator.of(
                                                                    context)
                                                                .pushAndRemoveUntil(
                                                              MaterialPageRoute(
                                                                builder: (context) =>
                                                                    const LoginSignUpScreen(
                                                                        loginState:
                                                                            true),
                                                              ),
                                                              (Route route) =>
                                                                  false,
                                                            );
                                                          },
                                                          child: Row(
                                                            children: [
                                                              const Icon(
                                                                Icons.logout,
                                                                color: Colors
                                                                    .black54,
                                                              ),
                                                              const SizedBox(
                                                                width: 8,
                                                              ),
                                                              Text(
                                                                "Logout",
                                                                style:
                                                                    TextStyle(
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .w400,
                                                                  fontSize: 14,
                                                                  color:
                                                                      kLoadingScreenTextColor,
                                                                ),
                                                              ),
                                                            ],
                                                          ),
                                                        ),
                                                        const SizedBox(
                                                          height: 20,
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                ],
                                              );
                                            });
                                          },
                                        ),
                                        child: Container(
                                            height: 45,
                                            width: 45,
                                            decoration: BoxDecoration(
                                              color: Colors.white,
                                              border: Border.all(
                                                  color: Colors.black12),
                                              shape: BoxShape.circle,
                                            ),
                                            child: const Icon(
                                                Icons.more_horiz_rounded)),
                                      )
                                  ],
                                ),
                                Padding(
                                  padding: const EdgeInsets.only(
                                    top: 20,
                                  ),
                                  child: Container(
                                    height: 1,
                                    decoration: const BoxDecoration(
                                      gradient: LinearGradient(
                                        begin: Alignment.topLeft,
                                        end: Alignment.topRight,
                                        colors: [
                                          Color(0x116C6464),
                                          Color(0xFFE7E7E7),
                                          Color(0x116C6464),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                                //rate

                                if(widget.isVisiter)
                                  Padding(
                                    padding: const EdgeInsets.only(top: 8.0),
                                    child: GestureDetector(
                                      onTap: (){
                                        Navigator.push(context, MaterialPageRoute(builder: (context)=> Scaffold(body: OffersScreen(onlyCurrentVendor: true,uid: uid,))));
                                      },
                                      child: Card(
                                        color: kSignInContainerColor,
                                        child: Row(
                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                          children:  [
                                            Padding(
                                              padding: EdgeInsets.only(top: 16.0,bottom: 16,left: 8),
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
                                                  Text("View offers",style: TextStyle(color: Colors.white),),
                                                ],
                                              ),
                                            ),
                                            Padding(
                                              padding: EdgeInsets.only(right: 8.0),
                                              child: Icon(Icons.chevron_right,color: Colors.white,),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                widget.isVisiter && showRating?
                                     Padding(
                                        padding: const EdgeInsets.symmetric(
                                            vertical: 20),
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              "Rate This",
                                              style: TextStyle(
                                                fontWeight: FontWeight.w600,
                                                fontSize: 20,
                                                color: kLoadingScreenTextColor,
                                              ),
                                            ),
                                            const SizedBox(
                                              height: 15,
                                            ),
                                            RatingBar(
                                              initialRating: 0.0,
                                              itemSize: 40,
                                              direction: Axis.horizontal,
                                              allowHalfRating: true,
                                              itemCount: 5,
                                              glowColor:
                                                  kCreditPointScaffoldBackgroundColor,
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
                                                  color:
                                                      kWalletLightTextColor,
                                                ),
                                              ),
                                              itemPadding:
                                                  const EdgeInsets.symmetric(
                                                      horizontal: 5),
                                              onRatingUpdate: (rat) {
                                                setState(() {
                                                  rating = rat;
                                                });
                                              },
                                            ),
                                            // if (widget.isVisiter)
                                            SizedBox(height: 32,),
                                            // if (widget.isVisiter)
                                              Stack(
                                                children: [
                                                  Form(
                                                    key: reviewkey,
                                                    child: TextFormField(

                                                      focusNode: FocusNode(
                                                          canRequestFocus:
                                                              false),
                                                      validator: (value) {
                                                        if (value == null ||
                                                            value.isEmpty) {
                                                          return 'Please enter some text';
                                                        }
                                                        return null;
                                                      },
                                                      controller:
                                                          reviewcontroller,
                                                      keyboardType:
                                                          TextInputType.multiline,
                                                      minLines: 4,
                                                      maxLines: 5,
                                                      decoration:
                                                          InputDecoration(
                                                            label: Text("Write an review"),                                                        hintText:
                                                            'Add Review...',
                                                        hintStyle: TextStyle(
                                                          color:
                                                              kPlansDescriptionTextColor,
                                                          fontSize: 13,
                                                          fontWeight:
                                                              FontWeight.w400,
                                                        ),
                                                        floatingLabelBehavior:
                                                            FloatingLabelBehavior
                                                                .always,
                                                        prefixIconColor:
                                                            kHintTextColor,
                                                        enabledBorder:
                                                            OutlineInputBorder(
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(
                                                                      5),
                                                          borderSide: BorderSide(
                                                              color:
                                                                  kPlansDescriptionTextColor),
                                                        ),
                                                        border:
                                                            OutlineInputBorder(
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(
                                                                      5),
                                                          borderSide: BorderSide(
                                                              color:
                                                                  kPlansDescriptionTextColor),
                                                          gapPadding: 10,
                                                        ),
                                                        focusedBorder:
                                                            OutlineInputBorder(
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(
                                                                      5),
                                                          borderSide: BorderSide(
                                                              color:
                                                                  kPlansDescriptionTextColor),
                                                          gapPadding: 10,
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              ),

                                            InkWell(
                                              onTap: () {
                                                submitRating();
                                              },
                                              child: Container(
                                                  alignment: Alignment.center,
                                                  margin: EdgeInsets.only(top: 16),
                                                  padding:
                                                      const EdgeInsets.all(15),
                                                  decoration: BoxDecoration(
                                                    color: kSignInContainerColor,
                                                    border: Border.all(
                                                        color: kSignInContainerColor,
                                                        width: 1),
                                                  ),
                                                  child: Container(
                                                      child: const Text(
                                                          "Submit",
                                                          style: TextStyle(
                                                              color: Colors.white)))),
                                            ),
                                          ],
                                        ),
                                      )
                                    :Container(),
                                Container(
                                  height: 1,
                                  decoration: const BoxDecoration(
                                    gradient: LinearGradient(
                                      begin: Alignment.topLeft,
                                      end: Alignment.topRight,
                                      colors: [
                                        Color(0x116C6464),
                                        Color(0xFFE7E7E7),
                                        Color(0x116C6464),
                                      ],
                                    ),
                                  ),
                                ),
                                SizedBox(height: 16,),
                                if(!widget.isVisiter)
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Padding(
                                        padding: const EdgeInsets.only(left: 8.0),
                                        child: Text("Post",style: TextStyle(color: Colors.black,fontSize: 16,fontWeight: FontWeight.bold),),
                                      ),
                                      Container(
                                        margin: EdgeInsets.only(top: 16),
                                        padding: EdgeInsets.all(16),
                                        decoration: BoxDecoration(
                                          color: kSignInContainerColor,
                                          borderRadius: BorderRadius.circular(20)
                                        ),
                                        child: Row(
                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Expanded(
                                              child: TextButton(
                                                onPressed: (){
                                                  Navigator.of(
                                                      context)
                                                      .push(
                                                    MaterialPageRoute(
                                                      builder: (context) =>
                                                      const AddEvent(),
                                                    ),
                                                  );
                                                },

                                                child: Column(
                                                  crossAxisAlignment: CrossAxisAlignment.center,
                                                  children: [
                                                    Container(height: 50,width: 50,decoration: BoxDecoration(color: Colors.white,borderRadius: BorderRadius.circular(50)),child: Icon(Icons.add_business),),
                                                    SizedBox(height: 8,),
                                                    Text("Post Event",style: TextStyle(fontSize: 12,color: Colors.white),textAlign: TextAlign.center,),
                                                  ],
                                                ),
                                              ),
                                            ),
                                            Expanded(
                                              child: TextButton(
                                                onPressed: (){
                                                  Navigator.of(
                                                      context)
                                                      .push(
                                                    MaterialPageRoute(
                                                      builder: (context) =>
                                                      const adsPlan(),
                                                    ),
                                                  );
                                                },
                                                child: Column(
                                                  children: [
                                                    Container(height: 50,width: 50,decoration: BoxDecoration(color: Colors.white,borderRadius: BorderRadius.circular(50)),child: Icon(Icons.speaker_notes_outlined),),
                                                    SizedBox(height: 8,),
                                                    Text("Post Ad",style: TextStyle(fontSize: 12,color: Colors.white),textAlign: TextAlign.center,),
                                                  ],
                                                ),
                                              ),
                                            ),
                                            Expanded(
                                              child: TextButton(
                                                onPressed: (){
                                                  Navigator.of(
                                                      context)
                                                      .push(
                                                    MaterialPageRoute(
                                                      builder: (context) =>
                                                      const PostOfferScreen(),
                                                    ),
                                                  );
                                                },
                                                child: Column(
                                                  children: [
                                                    Container(height: 50,width: 50,decoration: BoxDecoration(color: Colors.white,borderRadius: BorderRadius.circular(50)),child: Icon(Icons.local_offer_sharp),),
                                                    SizedBox(height: 8,),
                                                    Text("Post Offer",style: TextStyle(fontSize: 12,color: Colors.white),),
                                                  ],
                                                ),
                                              ),
                                            ),
                                          ],
                                        )
                                        ,
                                      ),
                                    ],
                                  ),
                                Padding(
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 16),
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          const Icon(Icons.location_pin)
                                              .onInkTap(() {}),
                                          SizedBox(width: 8,),
                                          Text("Location")
                                        ],
                                      ),
                                      Container(
                                        height: 200,
                                        margin: EdgeInsets.only(top: 16,bottom: 16),
                                        width: double.infinity,
                                        child: GoogleMap(
                                          onTap: (LatLng) {
                                            MapsLauncher.launchCoordinates(
                                              currentVendor
                                                  .businessLocation.lat,
                                              currentVendor
                                                  .businessLocation.long,
                                            );
                                          },
                                          zoomControlsEnabled: false,
                                          compassEnabled: false,
                                          initialCameraPosition: CameraPosition(
                                              bearing: 1,
                                              zoom: 10.0,
                                              target: LatLng(
                                                currentVendor
                                                    .businessLocation.lat,
                                                currentVendor
                                                    .businessLocation.long,
                                              )),markers: {Marker(markerId: MarkerId("main"),position: LatLng(currentVendor
                                            .businessLocation.lat,
                                          currentVendor
                                              .businessLocation.long,))}
                                        ),
                                        decoration: BoxDecoration(
                                          borderRadius:
                                          BorderRadius.circular(10),
                                          image: const DecorationImage(
                                            image: AssetImage(
                                              'assets/images/profile/vendor_profile/address.png',
                                            ),
                                          ),
                                        ),
                                      ),
                                      Text(
                                        currentVendor.businessAddress,
                                        style: TextStyle(
                                          fontWeight: FontWeight.w400,
                                          fontSize: 16,
                                          color: kLoadingScreenTextColor,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Container(
                                  height: 1,
                                  decoration: const BoxDecoration(
                                    gradient: LinearGradient(
                                      begin: Alignment.topLeft,
                                      end: Alignment.topRight,
                                      colors: [
                                        Color(0x116C6464),
                                        Color(0xFFE7E7E7),
                                        Color(0x116C6464),
                                      ],
                                    ),
                                  ),
                                ),
                                Padding(
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 23),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Row(
                                        children: [
                                          const Icon(Icons.access_time),
                                          SizedBox(width: 16,),
                                          Column(
                                            crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                (DateTime.now().hour * 60 +
                                                    DateTime.now()
                                                        .minute >=
                                                    (DateTime.fromMillisecondsSinceEpoch(currentVendor.openTime)
                                                        .hour *
                                                        60 +
                                                        DateTime.fromMillisecondsSinceEpoch(
                                                            currentVendor
                                                                .openTime)
                                                            .minute) &&
                                                    DateTime.now().hour *
                                                        60 +
                                                        DateTime.now()
                                                            .minute <=
                                                        DateTime.fromMillisecondsSinceEpoch(currentVendor.closeTime)
                                                            .hour *
                                                            60 +
                                                            DateTime.fromMillisecondsSinceEpoch(
                                                                currentVendor.closeTime)
                                                                .minute)
                                                    ? "Open"
                                                    : "Closed",
                                                style: TextStyle(
                                                  fontWeight: FontWeight.w700,
                                                  fontSize: 15,
                                                  color: kSignInContainerColor,
                                                ),
                                              ).px2(),
                                              SizedBox(height: 4,),
                                              Row(
                                                mainAxisAlignment:
                                                MainAxisAlignment.start,
                                                children: [
                                                  SizedBox(width: 2,),
                                                  Text(
                                                    (DateFormat('hh:mm a').format(
                                                        DateTime
                                                            .fromMillisecondsSinceEpoch(
                                                            currentVendor
                                                                .openTime)))
                                                        .toString(),
                                                    style: TextStyle(
                                                      fontWeight: FontWeight.w400,
                                                      fontSize: 16,
                                                      color:
                                                      kLoadingScreenTextColor,
                                                    ),
                                                  ),
                                                  " - ".text.make(),
                                                  Text(
                                                    (DateFormat('hh:mm a').format(
                                                        DateTime
                                                            .fromMillisecondsSinceEpoch(
                                                            currentVendor
                                                                .closeTime)))
                                                        .toString(),
                                                    style: TextStyle(
                                                      fontWeight: FontWeight.w400,
                                                      fontSize: 16,
                                                      color:
                                                      kLoadingScreenTextColor,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                              SizedBox(height: 4,),
                                              Row(
                                                mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                                children: [
                                                  SizedBox(width: 3,),
                                                  Text(
                                                    currentVendor.workingDay,
                                                    style: const TextStyle(
                                                      fontWeight: FontWeight.w600,
                                                      fontSize: 16,
                                                      color: Colors.black,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ],
                                          ),

                                        ],
                                      ),
                                      (!widget.isVisiter)
                                          ? Padding(
                                            padding: const EdgeInsets.all(16.0),
                                            child: InkWell(
                                                onTap: () {
                                                  editTime();
                                                },
                                                child: const Icon(Icons.edit)),
                                          )
                                          : const Icon(Icons.calendar_month),
                                    ],
                                  ),
                                ),
                                Container(
                                  height: 1,
                                  decoration: const BoxDecoration(
                                    gradient: LinearGradient(
                                      begin: Alignment.topLeft,
                                      end: Alignment.topRight,
                                      colors: [
                                        Color(0x116C6464),
                                        Color(0xFFE7E7E7),
                                        Color(0x116C6464),
                                      ],
                                    ),
                                  ),
                                ),
                                SizedBox(height: 12,),
                                Padding(
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 16),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.start,
                                      children: [
                                        const Icon(Icons.call),
                                        const SizedBox(
                                          width: 22,
                                        ),
                                        Text(
                                          "Vendor Phone Number",
                                          style: TextStyle(
                                            fontWeight: FontWeight.w400,
                                            fontSize: 16,
                                            color: kLoadingScreenTextColor,
                                          ),
                                        ).onInkTap(() async {
                                          var mobbbb = currentVendor
                                              .businessMobileNumber
                                              .toString();
                                          var url = "tel:$mobbbb";
                                          if (await canLaunch(url)) {
                                            await launch(url);
                                          } else {
                                            throw 'Could not launch $url';
                                          }
                                        }),
                                      ],
                                    )),
                              ],
                            ),
                          ),
                          Container(
                              height: 1,
                              decoration: const BoxDecoration(
                                  gradient: LinearGradient(
                                begin: Alignment.topLeft,
                                end: Alignment.topRight,
                                colors: [
                                  Color(0x116C6464),
                                  Color(0xFFE7E7E7),
                                  Color(0x116C6464),
                                ],
                              ))),
                          Container(
                            height: 1,
                            decoration: const BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.topLeft,
                                end: Alignment.topRight,
                                colors: [
                                  Color(0x116C6464),
                                  Color(0xFFE7E7E7),
                                  Color(0x116C6464),
                                ],
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 20),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "Photos",
                                  style: TextStyle(
                                    fontWeight: FontWeight.w600,
                                    fontSize: 20,
                                    color: kLoadingScreenTextColor,
                                  ),
                                ),
                                const SizedBox(
                                  height: 16,
                                ),
                                Column(
                                  children: [
                                    getVendorImage(context, uid, widget.isVisiter),
                                    SizedBox(height: 8,),
                                    if(visibleProgress)Center(child: LinearProgressIndicator(color: kSignInContainerColor,))
                                  ],
                                ), 
                                !widget.isVisiter
                                    ? InkWell(
                                        onTap: () {
                                          _imgFromGallery().then((e) async {
                                            saveVndorImages();
                                          });
                                        },
                                        child: Container(
                                          decoration: BoxDecoration(
                                            color: kSignInContainerColor,
                                            borderRadius: BorderRadius.circular(10)
                                          ),
                                            margin: EdgeInsets.only(top: 16),
                                            alignment: Alignment.center,
                                            height: 50,
                                            child: const Text(
                                                "Upload Image",
                                                style: TextStyle(
                                                    color: Colors.white))),
                                      )
                                    : Container(),
                              ],
                            ),
                          ),
                          Container(
                            height: 1,
                            decoration: const BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.topLeft,
                                end: Alignment.topRight,
                                colors: [
                                  Color(0x116C6464),
                                  Color(0xFFE7E7E7),
                                  Color(0x116C6464),
                                ],
                              ),
                            ),
                          ),
                          widget.isVisiter
                              ? Column(children: [
                                  Container(
                                    alignment: Alignment.centerLeft,
                                    child: Padding(
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 20),
                                      child: Text(
                                        "Reviews & Ratings",
                                        style: TextStyle(
                                          fontWeight: FontWeight.w600,
                                          fontSize: 20,
                                          color: kLoadingScreenTextColor,
                                        ),
                                      ),
                                    ),
                                  ),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    children: [
                                      Container(
                                        height: 40,
                                        width: 40,
                                        decoration: BoxDecoration(
                                          borderRadius:
                                              BorderRadius.circular(5),
                                          color:
                                              kHomeScreenServicesContainerColor,
                                        ),
                                        child: Center(
                                          child: Text(
                                            vendorRating.toString(),
                                            style: TextStyle(
                                              fontWeight: FontWeight.w800,
                                              fontSize: 18,
                                              color: kLoadingScreenTextColor,
                                            ),
                                          ),
                                        ),
                                      ),
                                      const SizedBox(
                                        width: 10,
                                      ),
                                      Flexible(
                                        child: Text(
                                          "$totalRatingCount Ratings\nRating index based on $totalRatingCount ratings across the web",
                                          style: TextStyle(
                                            fontWeight: FontWeight.w400,
                                            fontSize: 14,
                                            color: kLoadingScreenTextColor,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(
                                    height: 21,
                                  ),
                                  Container(
                                    height: 1,
                                    decoration: const BoxDecoration(
                                      gradient: LinearGradient(
                                        begin: Alignment.topLeft,
                                        end: Alignment.topRight,
                                        colors: [
                                          Color(0x116C6464),
                                          Color(0xFFE7E7E7),
                                          Color(0x116C6464),
                                        ],
                                      ),
                                    ),
                                  ),
                                ])
                              : Container(),
                          Padding(
                            padding: const EdgeInsets.only(top: 25, bottom: 19),
                            child: Text(
                              "QR Code",
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: 20,
                                color: kLoadingScreenTextColor,
                              ),
                            ),
                          ),
                          Center(
                              child: RepaintBoundary(
                            key: _globalKey,
                            child: Container(
                              child: QrImage(
                                data: uid,
                                version: QrVersions.auto,
                                size: 200.0,
                              ),
                              color: Colors.white,
                            ),
                          )),
                          Center(
                            child: Text(
                              currentVendor.businessName,
                              style: TextStyle(
                                fontWeight: FontWeight.w400,
                                fontSize: 16,
                                color: kLoadingScreenTextColor,
                              ),
                            ),
                          ),
                          const SizedBox(
                            height: 26,
                          ),
                          // Center(
                          //   child: GestureDetector(
                          //     // onTap: () => Navigator.of(context).push(
                          //     //   MaterialPageRoute(
                          //     //     builder: (context) => StatementScreen(),
                          //     //   ),
                          //     // ),
                          //     child: Container(
                          //       height: 50,
                          //       width: width - 68,
                          //       decoration: BoxDecoration(
                          //         borderRadius: BorderRadius.circular(5),
                          //         color: kSignInContainerColor,
                          //       ),
                          //       child: Center(
                          //         child: Text(
                          //           "Download QR Code",
                          //           style: TextStyle(
                          //             fontWeight: FontWeight.w400,
                          //             fontSize: 20,
                          //             color: Colors.white,
                          //           ),
                          //         ),
                          //       ),
                          //     ),
                          //   ),
                          // ),
                          const SizedBox(
                            height: 25,
                          ),
                          Container(
                            height: 1,
                            decoration: const BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.topLeft,
                                end: Alignment.topRight,
                                colors: [
                                  Color(0x116C6464),
                                  Color(0xFFE7E7E7),
                                  Color(0x116C6464),
                                ],
                              ),
                            ),
                          ),
                          widget.isVisiter
                              ? Column(
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.only(
                                          top: 25, bottom: 19),
                                      child: Text(
                                        "User Reviews",
                                        style: TextStyle(
                                          fontWeight: FontWeight.w600,
                                          fontSize: 20,
                                          color: kLoadingScreenTextColor,
                                        ),
                                      ),
                                    ),
                                    SizedBox(
                                      height: 25,
                                      child: ListView.separated(
                                        scrollDirection: Axis.horizontal,
                                        itemCount: 1,
                                        itemBuilder: (context, index) {
                                          return GestureDetector(
                                            onTap: () {
                                              setState(() {
                                                selectedIndex = index;
                                              });
                                            },
                                            child: Container(
                                              height: 25,
                                              width: 100,
                                              decoration: BoxDecoration(
                                                color: selectedIndex == index
                                                    ? kHomeScreenServicesContainerColor
                                                    : Colors.white,
                                                borderRadius:
                                                    BorderRadius.circular(100),
                                                border: Border.all(
                                                  color: selectedIndex == index
                                                      ? const Color(0xFF67BFCF)
                                                      : const Color(0xFFDADADA),
                                                ),
                                              ),
                                              child: Center(
                                                child: Text(
                                                  reviews[index],
                                                  style: TextStyle(
                                                    fontWeight: FontWeight.w400,
                                                    fontSize: 14,
                                                    color: selectedIndex ==
                                                            index
                                                        ? kSignInContainerColor
                                                        : const Color(
                                                            0xFFDADADA),
                                                  ),
                                                ),
                                              ),
                                            ),
                                          );
                                        },
                                        separatorBuilder: (context, index) =>
                                            const SizedBox(
                                          width: 16,
                                        ),
                                      ),
                                    ),
                                  ],
                                )
                              : Container(),

                          getVendorReview(context, uid),
                        ],
                      )),
                );
              })
          : Container(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  "Please Wait Loading Vendor Details"
                      .text
                      .makeCentered()
                      .py8(),
                  const CircularProgressIndicator().centered(),
                ],
              ),
            ).centered(),
    ));
  }

  final _globalKey = GlobalKey();
  capturePng() async {
    try {
      print('inside');
      RenderRepaintBoundary? boundary = _globalKey.currentContext
          ?.findRenderObject() as RenderRepaintBoundary?;
      ui.Image image = await boundary!.toImage(pixelRatio: 3.0);
      ByteData? byteData =
          await image.toByteData(format: ui.ImageByteFormat.png);
      var pngBytes = byteData?.buffer.asUint8List();
      var bs64 = base64Encode(pngBytes!);
      print(pngBytes);
      print(bs64);
      await Permission.storage.request();
      var x = await getTemporaryDirectory();
      String r = x.absolute.path + "/qr.png";

      print(r);
      File f = await File(r).writeAsBytes(pngBytes);
      await WcFlutterShare.share(
          text: "Scan with NearBii App",
          subject: "Install from PlayStore",
          sharePopupTitle: currentVendor.name,
          fileName: currentVendor.name + '.png',
          mimeType: 'image/jpg',
          bytesOfFile: pngBytes);
      pngBytes;
    } catch (e) {
      print(e);
    }
  }
}
