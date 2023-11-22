import 'dart:convert';
import 'dart:developer';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;
import 'package:nearbii/Model/notifStorage.dart';
import 'package:nearbii/main.dart';

sendNotiicationByCity(String title, String city, String id, String type,String imageUrl) async {
  const postUrl = 'https://fcm.googleapis.com/fcm/send';
  const token =
      'AAAACt0GUvs:APA91bGNgTvPF7QExy-2kgfQlC2ghq1MwC4n2mq4EAgwc1NJtXghvhsQN63_xLaUP3SfHiSVyev3VTbyFwJRV9_gVhmjhKoyo-LmfF_Zat7nDKDHTS4SdCm98aEq9tb2WHPLVI8C4cES';
  String toParams = "/topics/city_" + city;

  final uid = FirebaseAuth.instance.currentUser!.uid.substring(0, 20);

  final data = {
    "notification": {
      "body": "New Event In Your City By $title",
      "title": title
    },
    "priority": "high",
    "data": {
      "click_action": "FLUTTER_NOTIFICATION_CLICK",
      "title": title,
      "city": city,
      "vendorUID": uid,
      "type": type,
      "evenId": id,
      "url": imageUrl
    },
    "to": toParams
  };

  final headers = {
    'content-type': 'application/json',
    'Authorization': 'key=' + token
  };

  final response = await http.post(Uri.parse(postUrl),
      body: json.encode(data),
      encoding: Encoding.getByName('utf-8'),
      headers: headers);

  if (response.statusCode == 200) {
// on success do
    Fluttertoast.showToast(msg: "Notification Sent to tageted city");
  } else {
// on failure do
    Fluttertoast.showToast(msg: "Notification Not Sent");
  }
}

sendNotiicationByPin(String title, String id, String type, String name,String imageUrl) async {
  print("sending notification");
  const postUrl = 'https://fcm.googleapis.com/fcm/send';
  const token =
      'AAAACt0GUvs:APA91bGNgTvPF7QExy-2kgfQlC2ghq1MwC4n2mq4EAgwc1NJtXghvhsQN63_xLaUP3SfHiSVyev3VTbyFwJRV9_gVhmjhKoyo-LmfF_Zat7nDKDHTS4SdCm98aEq9tb2WHPLVI8C4cES';
  String toParams = "/topics/Offer";

  final uid = FirebaseAuth.instance.currentUser!.uid.substring(0, 20);

  final data = {
    "notification": {"body": "New Offer By " + name, "title": title},
    "priority": "high",
    "data": {
      "click_action": "FLUTTER_NOTIFICATION_CLICK",
      "title": "New Offer By " + name,
      "pin": Notifcheck.currentVendor!.businessLocation.toJson(),
      "vendorUID": uid,
      "type": type,
      "evenId": id,
      "url": imageUrl
    },
    "to": toParams
  };

  final headers = {
    'content-type': 'application/json',
    'Authorization': 'key=' + token
  };

  final response = await http.post(Uri.parse(postUrl),
      body: json.encode(data),
      encoding: Encoding.getByName('utf-8'),
      headers: headers);

  if (response.statusCode == 200) {
// on success do
    Fluttertoast.showToast(msg: "Notification Sent to tageted city");
  } else {
// on failure do
    Fluttertoast.showToast(msg: "Notification Not Sent");
  }
}

sendNotiicationAd(String title, String image) async {
  log("message", name: "notifications");

  const postUrl = 'https://fcm.googleapis.com/fcm/send';
  const token =
      'AAAACt0GUvs:APA91bGNgTvPF7QExy-2kgfQlC2ghq1MwC4n2mq4EAgwc1NJtXghvhsQN63_xLaUP3SfHiSVyev3VTbyFwJRV9_gVhmjhKoyo-LmfF_Zat7nDKDHTS4SdCm98aEq9tb2WHPLVI8C4cES';
  String toParams = "/topics/city_".toString() + "ADS";

  final uid = FirebaseAuth.instance.currentUser!.uid.substring(0, 20);
  final data = {
    "notification": {"body": "New Event in Your City", "title": title},
    "priority": "high",
    "data": {
      "click_action": "FLUTTER_NOTIFICATION_CLICK",
      "title": title,
      "location": Notifcheck.currentVendor!.businessLocation.toJson(),
      "vendorUID": uid,
      "type": "ad",
      "image": image
    },
    "to": toParams
  };

  final headers = {
    'content-type': 'application/json',
    'Authorization': 'key=' + token
  };

  final response = await http.post(Uri.parse(postUrl),
      body: json.encode(data),
      encoding: Encoding.getByName('utf-8'),
      headers: headers);

  if (response.statusCode == 200) {
// on success do
    Fluttertoast.showToast(msg: "AD posted Successfull");
  } else {
// on failure do
    Fluttertoast.showToast(msg: "AD posted Successfull");
  }
}

sendNotificationWallet(String uidd, double amount, String s,String adoffer) async {
  log("message", name: "notifications");

  const postUrl = 'https://fcm.googleapis.com/fcm/send';
  const token =
      'AAAACt0GUvs:APA91bGNgTvPF7QExy-2kgfQlC2ghq1MwC4n2mq4EAgwc1NJtXghvhsQN63_xLaUP3SfHiSVyev3VTbyFwJRV9_gVhmjhKoyo-LmfF_Zat7nDKDHTS4SdCm98aEq9tb2WHPLVI8C4cES';
  String toParams = "/topics/" + uidd;

  final uid = FirebaseAuth.instance.currentUser!.uid.substring(0, 20);
  final data = {
    "notification": {
      "body": amount==1 ? "1 offer $s from plan" : "$amount Wallet Points $s",
      "title": amount==1 ?  "Offer Debited" : "$amount Wallet Points $s"
    },
    "priority": "high",
    "data": {
      "click_action": "FLUTTER_NOTIFICATION_CLICK",
      "title": "Temp Title",
      "amount": amount,
      "vendorUID": uid,
      "type": "wallet",
      "isAd": adoffer=='Ads Plan'? "true": "false"
    },
    "to": toParams
  };

  final headers = {
    'content-type': 'application/json',
    'Authorization': 'key=' + token
  };

  final response = await http.post(Uri.parse(postUrl),
      body: json.encode(data),
      encoding: Encoding.getByName('utf-8'),
      headers: headers);

  if (response.statusCode == 200) {
// on success do
    // Fluttertoast.showToast(msg: "Notification Sent to tageted city");
  } else {
// on failure do
    Fluttertoast.showToast(msg: "Notification Not Sent");
  }
}

sendNotificationForVendor(String name) {
  flutterLocalNotificationsPlugin.show(
    0,
    "You are now Registered as Vendor",
    "Thank you $name, for choosing NEARBII ❤",
    NotificationDetails(
      android: AndroidNotificationDetails(
        channel.id,
        channel.name,
        channelDescription: channel.description,
        color: Colors.blue,
        playSound: true,
        styleInformation: const BigTextStyleInformation(''),
      ),
    ),
  );
}

sendPlanNotification(){
  flutterLocalNotificationsPlugin.show(
    0,
    "Plan purchased",
    "Thank you for choosing NEARBII ❤",
    NotificationDetails(
      android: AndroidNotificationDetails(
        channel.id,
        channel.name,
        channelDescription: channel.description,
        color: Colors.blue,
        playSound: true,
        styleInformation: const BigTextStyleInformation(''),
      ),
    ),
  );
}


showNotification(String name) {
  flutterLocalNotificationsPlugin.show(
    0,
    "Welcome To Nearbii",
    "Thank you $name, for choosing NEARBII ❤",
    NotificationDetails(
      android: AndroidNotificationDetails(
        channel.id,
        channel.name,
        channelDescription: channel.description,
        color: Colors.blue,
        playSound: true,
        styleInformation: const BigTextStyleInformation(''),
      ),
    ),
  );
}
