import 'dart:developer';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:nearbii/services/getcity.dart';
import 'package:shared_preferences/shared_preferences.dart';

void subscribeTopicCity() async {
  SharedPreferences session = await SharedPreferences.getInstance();
  String city = "";
  while (city.isEmpty) {
    city = await getcurrentCityFromLocation();
    log("nocity");
  }
  await FirebaseMessaging.instance.subscribeToTopic("city_" + city.toString());
  await FirebaseMessaging.instance.subscribeToTopic("city_" + "ADS".toString());
  await FirebaseMessaging.instance.subscribeToTopic("Offer");
  await FirebaseMessaging.instance.subscribeToTopic(
      FirebaseAuth.instance.currentUser!.uid.substring(0, 20));

  //Fluttertoast.showToast(msg: "Notifications On");
}

Future unsubscribeTopicity() async {
  SharedPreferences session = await SharedPreferences.getInstance();

  String? city = session.getString("userLocation");

  await FirebaseMessaging.instance
      .unsubscribeFromTopic("city_" + city.toString());

  await FirebaseMessaging.instance
      .unsubscribeFromTopic("city_" + city.toString());
  await FirebaseMessaging.instance
      .unsubscribeFromTopic("city_" + "ADS".toString());
  await FirebaseMessaging.instance.unsubscribeFromTopic("Offer");
  await FirebaseMessaging.instance.unsubscribeFromTopic(
      FirebaseAuth.instance.currentUser!.uid.substring(0, 20));
}
