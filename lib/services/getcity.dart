import 'dart:developer';

import 'package:flutter/foundation.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<String> getcurrentCityFromLocation() async {
  try {
    Position position = await _determinePosition();
    List<Placemark> placemarks = await placemarkFromCoordinates(
        position.latitude, position.longitude,
        localeIdentifier: "en_US");

    Placemark place = placemarks[0];
    var address = '${place.subLocality}, ${place.locality}';

    SharedPreferences session = await SharedPreferences.getInstance();
    log(place.locality.toString());
    if (kDebugMode) {
      return "Pune";
    }
    return place.locality.toString();
    session.setString("userLocation", place.locality.toString());
    session.setString("pincode", place.postalCode.toString());
  }catch(e){
    return "Pune";
  }
}

Future<Position> _determinePosition() async {
  bool serviceEnabled;
  LocationPermission permission;

  serviceEnabled = await Geolocator.isLocationServiceEnabled();
  if (!serviceEnabled) {
    await Geolocator.openLocationSettings();
    // return Future.error('Location services are disabled.');
  }

  permission = await Geolocator.checkPermission();
  if (permission == LocationPermission.denied) {
    permission = await Geolocator.requestPermission();
    if (permission == LocationPermission.denied) {
      return Future.error('Location permissions are denied');
    }
  }

  if (permission == LocationPermission.deniedForever) {
    return Future.error(
        'Location permissions are permanently denied, we cannot request permissions.');
  }

  return await Geolocator.getCurrentPosition();
}
