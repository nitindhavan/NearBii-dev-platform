// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

class VendorModel {
  String open = "open";
  final String aadharCardNumber;
  final String businessAddress;
  final String businessCat;
  final String businessCity;
  final String businessImage;
  final double rating;
  final BusinessLocation businessLocation;
  final String businessMobileNumber;
  final String businessName;
  final String businessPinCode;
  final String businessSubCat;
  final String bussinesDesc;
  final int closeTime;
  final int adsBuyTimestamp;
  bool isAds;
  final String name;
  final int openTime;
  final String payment;
  final String paymentId;
  final String refCode;
  final String workingDay;
  String? userId;
  bool active = true;
  double distance = 0;
  List<String> bookmarks;
  final ValueNotifier<bool> book = ValueNotifier(false);
  final ValueNotifier<bool> visible = ValueNotifier(false);

  DocumentReference<Map<String, dynamic>>? ref;
  VendorModel({
    required this.open,
    required this.aadharCardNumber,
    required this.businessAddress,
    required this.businessCat,
    required this.businessCity,
    required this.businessImage,
    required this.rating,
    required this.businessLocation,
    required this.businessMobileNumber,
    required this.businessName,
    required this.businessPinCode,
    required this.businessSubCat,
    required this.bussinesDesc,
    required this.closeTime,
    required this.adsBuyTimestamp,
    required this.isAds,
    required this.name,
    required this.openTime,
    required this.payment,
    required this.paymentId,
    required this.refCode,
    required this.workingDay,
    required this.userId,
    required this.active,
    required this.distance,
    required this.bookmarks,
  });

  VendorModel copyWith({
    String? open,
    String? aadharCardNumber,
    String? businessAddress,
    String? businessCat,
    String? businessCity,
    String? businessImage,
    double? rating,
    BusinessLocation? businessLocation,
    String? businessMobileNumber,
    String? businessName,
    String? businessPinCode,
    String? businessSubCat,
    String? bussinesDesc,
    int? closeTime,
    int? adsBuyTimestamp,
    bool? isAds,
    String? name,
    int? openTime,
    String? payment,
    String? paymentId,
    String? refCode,
    String? workingDay,
    String? userId,
    bool? active,
    double? distance,
    List<String>? bookmarks,
  }) {
    return VendorModel(
      open: open ?? this.open,
      aadharCardNumber: aadharCardNumber ?? this.aadharCardNumber,
      businessAddress: businessAddress ?? this.businessAddress,
      businessCat: businessCat ?? this.businessCat,
      businessCity: businessCity ?? this.businessCity,
      businessImage: businessImage ?? this.businessImage,
      rating: rating ?? this.rating,
      businessLocation: businessLocation ?? this.businessLocation,
      businessMobileNumber: businessMobileNumber ?? this.businessMobileNumber,
      businessName: businessName ?? this.businessName,
      businessPinCode: businessPinCode ?? this.businessPinCode,
      businessSubCat: businessSubCat ?? this.businessSubCat,
      bussinesDesc: bussinesDesc ?? this.bussinesDesc,
      closeTime: closeTime ?? this.closeTime,
      adsBuyTimestamp: adsBuyTimestamp ?? this.adsBuyTimestamp,
      isAds: isAds ?? this.isAds,
      name: name ?? this.name,
      openTime: openTime ?? this.openTime,
      payment: payment ?? this.payment,
      paymentId: paymentId ?? this.paymentId,
      refCode: refCode ?? this.refCode,
      workingDay: workingDay ?? this.workingDay,
      userId: userId ?? this.userId,
      active: active ?? this.active,
      distance: distance ?? this.distance,
      bookmarks: bookmarks ?? this.bookmarks,
    );
  }

  Map<String, dynamic> toMap() {
    final result = <String, dynamic>{};

    result.addAll({'open': open});
    result.addAll({'aadharCardNumber': aadharCardNumber});
    result.addAll({'businessAddress': businessAddress});
    result.addAll({'businessCat': businessCat});
    result.addAll({'businessCity': businessCity});
    result.addAll({'businessImage': businessImage});
    result.addAll({'rating': rating});
    result.addAll({'businessLocation': businessLocation.toMap()});
    result.addAll({'businessMobileNumber': businessMobileNumber});
    result.addAll({'businessName': businessName});
    result.addAll({'businessPinCode': businessPinCode});
    result.addAll({'businessSubCat': businessSubCat});
    result.addAll({'bussinesDesc': bussinesDesc});
    result.addAll({'closeTime': closeTime});
    result.addAll({'adsBuyTimestamp': adsBuyTimestamp});
    result.addAll({'isAds': isAds});
    result.addAll({'name': name});
    result.addAll({'openTime': openTime});
    result.addAll({'payment': payment});
    result.addAll({'paymentId': paymentId});
    result.addAll({'refCode': refCode});
    result.addAll({'workingDay': workingDay});
    if (userId != null) {
      result.addAll({'userId': userId});
    }
    result.addAll({'active': active});
    result.addAll({'distance': distance});
    result.addAll({'bookmarks': bookmarks});

    return result;
  }

  factory VendorModel.fromMap(Map<String, dynamic> map) {
    return VendorModel(
      open: map['open'] ?? '',
      aadharCardNumber: map['aadharCardNumber'] ?? '',
      businessAddress: map['businessAddress'] ?? '',
      businessCat: map['businessCat'] ?? '',
      businessCity: map['businessCity'] ?? '',
      businessImage: map['businessImage'] ?? '',
      rating: map['rating']?.toDouble() ?? 0.0,
      businessLocation: BusinessLocation.fromMap(map['businessLocation']),
      businessMobileNumber: map['businessMobileNumber'] ?? '',
      businessName: map['businessName'] ?? '',
      businessPinCode: map['businessPinCode'] ?? '',
      businessSubCat: map['businessSubCat'] ?? '',
      bussinesDesc: map['bussinesDesc'] ?? '',
      closeTime: map['closeTime']?.toInt() ?? 0,
      adsBuyTimestamp: map['adsBuyTimestamp']?.toInt() ?? 0,
      isAds: map['isAds'] ?? false,
      name: map['name'] ?? '',
      openTime: map['openTime']?.toInt() ?? 0,
      payment: map['payment'] ?? '',
      paymentId: map['paymentId'] ?? '',
      refCode: map['refCode'] ?? '',
      workingDay: map['workingDay'] ?? '',
      userId: map['userId'],
      active: map['active'] ?? false,
      distance: map['distance']?.toDouble() ?? 0.0,
      bookmarks: List<String>.from(map['bookmarks']),
    );
  }

  String toJson() => json.encode(toMap());

  factory VendorModel.fromJson(String source) =>
      VendorModel.fromMap(json.decode(source));

  @override
  String toString() {
    return 'VendorModel(open: $open, aadharCardNumber: $aadharCardNumber, businessAddress: $businessAddress, businessCat: $businessCat, businessCity: $businessCity, businessImage: $businessImage, rating: $rating, businessLocation: $businessLocation, businessMobileNumber: $businessMobileNumber, businessName: $businessName, businessPinCode: $businessPinCode, businessSubCat: $businessSubCat, bussinesDesc: $bussinesDesc, closeTime: $closeTime, adsBuyTimestamp: $adsBuyTimestamp, isAds: $isAds, name: $name, openTime: $openTime, payment: $payment, paymentId: $paymentId, refCode: $refCode, workingDay: $workingDay, userId: $userId, active: $active, distance: $distance, bookmarks: $bookmarks)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is VendorModel &&
        other.open == open &&
        other.aadharCardNumber == aadharCardNumber &&
        other.businessAddress == businessAddress &&
        other.businessCat == businessCat &&
        other.businessCity == businessCity &&
        other.businessImage == businessImage &&
        other.rating == rating &&
        other.businessLocation == businessLocation &&
        other.businessMobileNumber == businessMobileNumber &&
        other.businessName == businessName &&
        other.businessPinCode == businessPinCode &&
        other.businessSubCat == businessSubCat &&
        other.bussinesDesc == bussinesDesc &&
        other.closeTime == closeTime &&
        other.adsBuyTimestamp == adsBuyTimestamp &&
        other.isAds == isAds &&
        other.name == name &&
        other.openTime == openTime &&
        other.payment == payment &&
        other.paymentId == paymentId &&
        other.refCode == refCode &&
        other.workingDay == workingDay &&
        other.userId == userId &&
        other.active == active &&
        other.distance == distance &&
        listEquals(other.bookmarks, bookmarks);
  }

  @override
  int get hashCode {
    return open.hashCode ^
        aadharCardNumber.hashCode ^
        businessAddress.hashCode ^
        businessCat.hashCode ^
        businessCity.hashCode ^
        businessImage.hashCode ^
        rating.hashCode ^
        businessLocation.hashCode ^
        businessMobileNumber.hashCode ^
        businessName.hashCode ^
        businessPinCode.hashCode ^
        businessSubCat.hashCode ^
        bussinesDesc.hashCode ^
        closeTime.hashCode ^
        adsBuyTimestamp.hashCode ^
        isAds.hashCode ^
        name.hashCode ^
        openTime.hashCode ^
        payment.hashCode ^
        paymentId.hashCode ^
        refCode.hashCode ^
        workingDay.hashCode ^
        userId.hashCode ^
        active.hashCode ^
        distance.hashCode ^
        bookmarks.hashCode;
  }
}

class BusinessLocation {
  final double lat;
  final double long;
  BusinessLocation({
    required this.lat,
    required this.long,
  });

  BusinessLocation copyWith({
    double? lat,
    double? long,
  }) {
    return BusinessLocation(
      lat: lat ?? this.lat,
      long: long ?? this.long,
    );
  }

  Map<String, dynamic> toMap() {
    final result = <String, dynamic>{};

    result.addAll({'lat': lat});
    result.addAll({'long': long});

    return result;
  }

  factory BusinessLocation.fromMap(Map<String, dynamic> map) {
    return BusinessLocation(
      lat: map['lat']?.toDouble() ?? 0.0,
      long: map['long']?.toDouble() ?? 0.0,
    );
  }

  String toJson() => json.encode(toMap());

  factory BusinessLocation.fromJson(String source) =>
      BusinessLocation.fromMap(json.decode(source));

  @override
  String toString() => 'BusinessLocation(lat: $lat, long: $long)';

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is BusinessLocation && other.lat == lat && other.long == long;
  }

  @override
  int get hashCode => lat.hashCode ^ long.hashCode;
}
