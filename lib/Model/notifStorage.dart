import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:nearbii/Model/cityModel.dart';
import 'package:nearbii/Model/vendormodel.dart';
import 'package:http/http.dart' as http;

import 'package:nearbii/services/Backend.dart';

class Notifcheck {
  static final ValueNotifier<bool> bell = ValueNotifier(false);
  static final ValueNotifier<bool> event = ValueNotifier(false);
  static final ValueNotifier<bool> offer = ValueNotifier(false);
  static VendorModel? currentVendor;
  static String defCover =
      "https://firebasestorage.googleapis.com/v0/b/neabiiapp.appspot.com/o/RWD_Why-Is-My-Shopify-Store-Not-Working_Blog_v1_Header.png?alt=media&token=c7491530-7ac5-4664-82d0-4a5978d3c481";

  static bool vendor = false;

  static var userDAta;
  static Backend api = Backend();
}

class CityList {
  static List<Cities> ListCity = [];
  static List<Cities> eventCity = [];
  static Future<void> getCities() async {
    ListCity = [];
    var headers = {
      'X-CSCAPI-KEY': 'VU9Wbm5mYW9CN3F0WWZnNGsyNjNFMkJVSGZmNnBweUpqczI5bkVESA=='
    };

    var request = await http.get(
        Uri.parse('https://api.countrystatecity.in/v1/countries/IN/cities'),
        headers: headers);

    if (request.statusCode == 200) {
      var x = request.body;
      var b = jsonDecode(x);
      for (var ele in b) {
        ListCity.add(Cities.fromMap(ele));
        eventCity.add(Cities.fromMap(ele));
      }
      ListCity.insert(0, Cities(id: 0, name: "All India"));
    } else {}
  }
}
