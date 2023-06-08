import 'dart:convert';
import 'dart:developer';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:geolocator/geolocator.dart';
import 'package:nearbii/Model/notifStorage.dart';
import 'package:nearbii/Model/vendormodel.dart';
import 'package:nearbii/main.dart';
import 'package:nearbii/screens/bottom_bar/event/event_screen.dart';
import 'package:nearbii/screens/bottom_bar/event/viewEvent.dart';
import 'package:nearbii/screens/bottom_bar/home/home_screen.dart';
import 'package:nearbii/screens/bottom_bar/offers_screen.dart';
import 'package:nearbii/screens/bottom_bar/profile/profile_screen.dart';
import 'package:nearbii/screens/bottom_bar/scan_screen.dart';
import 'package:nearbii/services/sendNotification/registerToken/registerTopicNotificaion.dart';
import 'package:nearbii/services/setUserMode.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

String? offerKey;
int selectedIndex = 0;

Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  SharedPreferences session = await SharedPreferences.getInstance();
  RemoteNotification? notification = message.notification;
  AndroidNotification? android = message.notification?.android;
  log(android.toString(), name: "notifications");
  log(notification.toString(), name: "notifications");
  if (notification != null && android != null) {
    if (message.data["type"].toString() == "event") {

      print("Event ID: ${message.data.toString()}");
      final http.Response response = await http.get(Uri.parse(message.data["url"]));
      BigPictureStyleInformation bigPictureStyleInformation =
      BigPictureStyleInformation(
        ByteArrayAndroidBitmap.fromBase64String(base64Encode(response.bodyBytes)),
        // largeIcon: ByteArrayAndroidBitmap.fromBase64String(base64Encode(response.bodyBytes)),
      );
      flutterLocalNotificationsPlugin.show(
        message.hashCode,
        message.notification!.title,
        "Posted an Event",
        NotificationDetails(
          android: AndroidNotificationDetails(
              channel.id,
              channel.name,
              channelDescription: channel.description,
              color: Colors.blue,
              playSound: true,
              styleInformation: bigPictureStyleInformation
          ),
        ),payload: message.data["evenId"],
      );

      FirebaseFirestore.instance
          .collection("User")
          .doc(FirebaseAuth.instance.currentUser!.uid.substring(0, 20))
          .set({"eventNotif": true}, SetOptions(merge: true));
    } else if (message.data["type"].toString() == "offer") {
      var c = BusinessLocation.fromJson(message.data["pin"]!);
      log(c.toString(), name: "notifications");
      var pos = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high);
      double distance = Geolocator.distanceBetween(
        pos.latitude,
        pos.longitude,
        c.lat,
        c.long,
      );
      final http.Response response = await http.get(Uri.parse(message.data["url"]));
      BigPictureStyleInformation bigPictureStyleInformation =
      BigPictureStyleInformation(
        ByteArrayAndroidBitmap.fromBase64String(base64Encode(response.bodyBytes)),
        // largeIcon: ByteArrayAndroidBitmap.fromBase64String(base64Encode(response.bodyBytes)),
      );
      flutterLocalNotificationsPlugin.show(
          message.hashCode,
          message.notification!.title! +" % off",
          message.data["title"],
          NotificationDetails(
            android: AndroidNotificationDetails(
                channel.id,
                channel.name,
                channelDescription: channel.description,
                color: Colors.blue,
                playSound: true,
                styleInformation: bigPictureStyleInformation
            ),
          ),payload: "offer"
      );
      log(message.data["type"], name: "notifications");
      String notiftype = message.data["type"].toString() == "event"
          ? "eventNotif"
          : "offerNotif";
      FirebaseFirestore.instance
          .collection("User")
          .doc(FirebaseAuth.instance.currentUser!.uid.substring(0, 20))
          .set({notiftype: true}, SetOptions(merge: true));
    } else if (message.data["type"].toString() == "wallet") {
      flutterLocalNotificationsPlugin.show(
        message.hashCode,
        message.data["isAd"] == "true"? "Ad Debited" : message.notification!.title,
        "${message.data["amount"]!=1.0 ? (message.data ["isAd"]=="false" ? "1 Offer debited from plan" : "1 Ad Debited from plan") : " ${message.data["amount"]} points"}",
        NotificationDetails(
          android: AndroidNotificationDetails(
            channel.id,
            channel.name,
            channelDescription: channel.description,
            color: Colors.blue,
            playSound: true,
          ),
        ),
      );
    } else {
      var c = BusinessLocation.fromJson(message.data["location"]!);

      log(c.toString(), name: "notifications");

      await Geolocator.checkPermission();
      var pos = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high);
      double distance = Geolocator.distanceBetween(
        pos.latitude,
        pos.longitude,
        c.lat,
        c.long,
      );
      if (distance < 5000) {
        FirebaseFirestore.instance
            .collection("User")
            .doc(FirebaseAuth.instance.currentUser!.uid.substring(0, 20))
            .collection("Notifs")
            .doc("notifsIDs")
            .set({
          "id": FieldValue.arrayUnion([
            {
              "id": "22",
              "isOffer": message.data["type"],
              "uid": message.data["vendorUID"],
              "name": message.notification!.title,
              "image": message.data["image"],
              "time": DateTime.now().millisecondsSinceEpoch
            }
          ])
        }).whenComplete(() => FirebaseFirestore.instance
            .collection("User")
            .doc(
            FirebaseAuth.instance.currentUser!.uid.substring(0, 20))
            .set({"newNotif": true}, SetOptions(merge: true)));
      }
    }
  }
}


class MasterPage extends StatefulWidget {
  final int currentIndex;


  const MasterPage({Key? key, required this.currentIndex}) : super(key: key);

  @override
  _MasterPageState createState() => _MasterPageState();
}

class _MasterPageState extends State<MasterPage> {
  final firestore = FirebaseFirestore.instance;
  final uid = FirebaseAuth.instance.currentUser!.uid.substring(0, 20);
  loadUser() async {
    bool user = await Notifcheck.api.isUser();
    if (!user) {
      var b =
          await FirebaseFirestore.instance.collection('vendor').doc(uid).get();
      if (b.data() != null) {
        Notifcheck.currentVendor = VendorModel.fromMap(b.data()!);
      }
    }
  }

  getcity() async {
    await CityList.getCities();
    setState(() {});
  }

  @override
  void initState() {
    selectedIndex = widget.currentIndex;
    getcity();
    loadUser();
    subscribeTopicCity();

    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

    const AndroidInitializationSettings initializationSettingsAndroid =
    AndroidInitializationSettings('@mipmap/ic_launcher');


    final InitializationSettings initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid,
    );

    flutterLocalNotificationsPlugin.initialize(initializationSettings,onDidReceiveNotificationResponse: (response){
      if(response.payload=="offer"){
        setState(() async {
          selectedIndex=2;
        });
      }else{
        setState(() {
          selectedIndex=1;
          Navigator.of(context).push(MaterialPageRoute(builder: (context)=> ViewEvent(eventID: response.payload,)));
        });
      }
    });

    flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(channel);

    FirebaseMessaging.instance.setForegroundNotificationPresentationOptions(
      alert: true,
      badge: true,
      sound: true,
    );
    flutterLocalNotificationsPlugin.getNotificationAppLaunchDetails().then((value) async {
      if (value!.didNotificationLaunchApp) {
        offerKey=value.notificationResponse?.payload;
        if(offerKey=="offer"){
          selectedIndex=2;
        }else{
          selectedIndex=1;
          Navigator.of(context).push(MaterialPageRoute(builder: (context)=> ViewEvent(eventID: value.notificationResponse?.payload,)));
        }
      }
    });

    FirebaseMessaging.onMessage.listen((RemoteMessage message) async {
      RemoteNotification? notification = message.notification;
      AndroidNotification? android = message.notification?.android;
      log(android.toString(), name: "notifications");
      log(notification.toString(), name: "notifications");
      if (notification != null && android != null) {
        if (message.data["type"].toString() == "event") {
          final http.Response response = await http.get(Uri.parse(message.data["url"]));
          BigPictureStyleInformation bigPictureStyleInformation =
          BigPictureStyleInformation(
            ByteArrayAndroidBitmap.fromBase64String(base64Encode(response.bodyBytes)),
            // largeIcon: ByteArrayAndroidBitmap.fromBase64String(base64Encode(response.bodyBytes)),
          );
          flutterLocalNotificationsPlugin.show(
            message.hashCode,
            message.notification!.title,
            "Posted an Event",
            NotificationDetails(
              android: AndroidNotificationDetails(
                channel.id,
                channel.name,
                channelDescription: channel.description,
                color: Colors.blue,
                playSound: true,
                  styleInformation: bigPictureStyleInformation
              ),
            ),payload:message.data["evenId"],
          );

          FirebaseFirestore.instance
              .collection("User")
              .doc(FirebaseAuth.instance.currentUser!.uid.substring(0, 20))
              .set({"eventNotif": true}, SetOptions(merge: true));
        } else if (message.data["type"].toString() == "offer") {
          var c = BusinessLocation.fromJson(message.data["pin"]!);
          log(c.toString(), name: "notifications");
          var pos = await Geolocator.getCurrentPosition(
              desiredAccuracy: LocationAccuracy.high);
          double distance = Geolocator.distanceBetween(
            pos.latitude,
            pos.longitude,
            c.lat,
            c.long,
          );
          final http.Response response = await http.get(Uri.parse(message.data["url"]));
          BigPictureStyleInformation bigPictureStyleInformation =
          BigPictureStyleInformation(
            ByteArrayAndroidBitmap.fromBase64String(base64Encode(response.bodyBytes)),
            // largeIcon: ByteArrayAndroidBitmap.fromBase64String(base64Encode(response.bodyBytes)),
          );
            flutterLocalNotificationsPlugin.show(
              message.hashCode,
              message.notification!.title! +" % off",
              message.data["title"],
              NotificationDetails(
                android: AndroidNotificationDetails(
                  channel.id,
                  channel.name,
                  channelDescription: channel.description,
                  color: Colors.blue,
                  playSound: true,
                  styleInformation: bigPictureStyleInformation
                ),
              ),payload: "offer"
            );
            log(message.data["type"], name: "notifications");
            String notiftype = message.data["type"].toString() == "event"
                ? "eventNotif"
                : "offerNotif";
            FirebaseFirestore.instance
                .collection("User")
                .doc(FirebaseAuth.instance.currentUser!.uid.substring(0, 20))
                .set({notiftype: true}, SetOptions(merge: true));
        } else if (message.data["type"].toString() == "wallet") {
          flutterLocalNotificationsPlugin.show(
            message.hashCode,
            message.data["isAd"] == "true"? "Ad Debited" : message.notification!.title,
            "${message.data["amount"]!=1.0 ? (message.data ["isAd"]=="false" ? "1 Offer debited from plan" : "1 Ad Debited from plan") : " ${message.data["amount"]} points"}",
            NotificationDetails(
              android: AndroidNotificationDetails(
                channel.id,
                channel.name,
                channelDescription: channel.description,
                color: Colors.blue,
                playSound: true,
              ),
            ),
          );
        } else {
          var c = BusinessLocation.fromJson(message.data["location"]!);

          log(c.toString(), name: "notifications");

          await Geolocator.checkPermission();
          var pos = await Geolocator.getCurrentPosition(
              desiredAccuracy: LocationAccuracy.high);
          double distance = Geolocator.distanceBetween(
            pos.latitude,
            pos.longitude,
            c.lat,
            c.long,
          );
          if (distance < 5000) {
            FirebaseFirestore.instance
                .collection("User")
                .doc(FirebaseAuth.instance.currentUser!.uid.substring(0, 20))
                .collection("Notifs")
                .doc("notifsIDs")
                .set({
              "id": FieldValue.arrayUnion([
                {
                  "id": "22",
                  "isOffer": message.data["type"],
                  "uid": message.data["vendorUID"],
                  "name": message.notification!.title,
                  "image": message.data["image"],
                  "time": DateTime.now().millisecondsSinceEpoch
                }
              ])
            }).whenComplete(() => FirebaseFirestore.instance
                    .collection("User")
                    .doc(
                        FirebaseAuth.instance.currentUser!.uid.substring(0, 20))
                    .set({"newNotif": true}, SetOptions(merge: true)));
          }
        }
      }
    });

    FirebaseFirestore.instance
        .collection("User")
        .doc(uid)
        .snapshots()
        .listen((value) {
      if (value.data() != null) {
        if (value.data()!.containsKey("newNotif")) {
          Notifcheck.bell.value = value.data()!["newNotif"];
        }

        if (value.data()!.containsKey("eventNotif")) {
          Notifcheck.event.value = value.data()!["eventNotif"];
        }

        if (value.data()!.containsKey("offerNotif")) {
          Notifcheck.offer.value = value.data()!["offerNotif"];
        }

        if (value.data()!.containsKey("type")) {
          value.data()!["type"] == "User" ? setUserMode() : setVendorMode();
        }
      }
    });
    super.initState();
  }

  final screens = [
    const HomeScreen(),
    const EventScreen(),
    OffersScreen(
      onlyCurrentVendor: false,
      offerKey: offerKey,
    ),
    const ScanScreen(),
    const ProfileScreen(),
  ];
  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        if (selectedIndex == 0) return true;

        setState(() {
          selectedIndex=0;
        });

        return false;
      },
      child: Scaffold(
        backgroundColor: Colors.white,
        body: IndexedStack(
          index: selectedIndex,
          children: screens,
        ),
        bottomNavigationBar: BottomNavigationBar(
          type: BottomNavigationBarType.fixed,
          currentIndex:selectedIndex,
          items: <BottomNavigationBarItem>[
            const BottomNavigationBarItem(
              icon: Icon(Icons.home_outlined),
              label: 'Home',
            ),
            BottomNavigationBarItem(
              icon: ValueListenableBuilder(
                builder: (context, bool value, Widget? child) {
                  return Stack(
                    children: [
                      Icon(
                        Icons.event_note_outlined,
                      ),
                      if (Notifcheck.event.value)
                        Container(
                          width: 10,
                          height: 10,
                          decoration: BoxDecoration(
                              color: Notifcheck.event.value
                                  ? Colors.amber
                                  : Colors.grey,
                              borderRadius: BorderRadius.circular(10)),
                        )
                    ],
                  );
                },
                valueListenable: Notifcheck.event,
              ),
              label: 'Events',
            ),
            BottomNavigationBarItem(
              activeIcon:Container(
                padding: const EdgeInsets.all(3),
                decoration: BoxDecoration(
                    border: Border.all(color: Colors.black),
                    borderRadius: BorderRadius.circular(50)),
                child: Icon(
                  Icons.percent,
                  color: Colors.black,
                  size: 18,
                ),
              ),
              icon: ValueListenableBuilder(
                builder: (context, bool value, Widget? child) {
                  return Stack(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(3),
                        decoration: BoxDecoration(
                            border: Border.all(color: Colors.black26),
                            borderRadius: BorderRadius.circular(50)),
                        child: Icon(
                          Icons.percent,
                          size: 18,
                        ),
                      ),
                      if (Notifcheck.offer.value)
                        Container(
                          alignment: Alignment.center,
                          width: 10,
                          height: 10,
                          decoration: BoxDecoration(
                              color: !Notifcheck.event.value
                                  ? Colors.amber
                                  : Colors.grey,
                              borderRadius: BorderRadius.circular(10),
                          ),
                        )
                    ],
                  );
                },
                valueListenable: Notifcheck.offer,
              ),
              label: 'Offers',
            ),
            const BottomNavigationBarItem(
              icon: Icon(Icons.qr_code_scanner_outlined),
              label: 'Scan',
            ),
            const BottomNavigationBarItem(
              icon: Icon(Icons.person_outline_outlined),
              label: 'Profile',
            ),
          ],
          onTap: (index) {
            if (index == 2) {
              FirebaseFirestore.instance
                  .collection("User")
                  .doc(FirebaseAuth.instance.currentUser!.uid.substring(0, 20))
                  .set({"offerNotif": false}, SetOptions(merge: true));
            }
            if (index == 1) {
              FirebaseFirestore.instance
                  .collection("User")
                  .doc(FirebaseAuth.instance.currentUser!.uid.substring(0, 20))
                  .set({"eventNotif": false}, SetOptions(merge: true));
            }
            setState(() {
              selectedIndex = index;
            });
          },
        ),
      ),
    );
  }
}
