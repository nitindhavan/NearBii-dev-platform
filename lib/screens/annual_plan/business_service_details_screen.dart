// ignore_for_file: deprecated_member_use

import 'dart:developer';

import 'package:dropdown_search/dropdown_search.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:nearbii/Model/vendormodel.dart';
import 'package:nearbii/constants.dart';
import 'package:nearbii/screens/annual_plan/GoogleMapScreen.dart';
import 'package:nearbii/screens/annual_plan/business_additional_details_screen.dart';
import 'package:velocity_x/velocity_x.dart';

import '../../Model/notifStorage.dart';

class BusinessServicesDetailsScreen extends StatefulWidget {
  final bool edit;
  VendorModel? data;
  BusinessServicesDetailsScreen({Key? key, this.edit = false, this.data})
      : super(key: key);

  @override
  State<BusinessServicesDetailsScreen> createState() =>
      _BusinessServicesDetailsScreenState();
}

class _BusinessServicesDetailsScreenState
    extends State<BusinessServicesDetailsScreen> {
  final _formKey = GlobalKey<FormState>();
  Map<String, dynamic> businessDetailData = {};

  String pinLocation = "Pin Location";
  var lattitude = "";
  var longitude = "";

  TextEditingController lattitudeController = TextEditingController();
  TextEditingController longitudeController = TextEditingController();

  @override
  void dispose() {
    lattitudeController.dispose();
    longitudeController.dispose();
    super.dispose();
  }

  Future<void> _displayTextInputDialog(BuildContext context) async {
    return showDialog(
        context: context,
        builder: (context) {
          var loc = {};
          return AlertDialog(
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  onChanged: (value) {
                    setState(() {
                      lattitude = value;
                    });
                  },
                  controller: lattitudeController,
                  decoration:
                      const InputDecoration(hintText: "Enter Lattitude"),
                ),
                TextField(
                  onChanged: (value) {
                    setState(() {
                      longitude = value;
                    });
                  },
                  controller: longitudeController,
                  decoration:
                      const InputDecoration(hintText: "Enter Longitude"),
                ),
                ElevatedButton(
                  style: ButtonStyle(
                    backgroundColor: MaterialStateProperty.all(Colors.blue),
                    textStyle: MaterialStateProperty.all(
                        const TextStyle(color: Colors.white)),
                  ),
                  onPressed: () async {
                    if (lattitudeController.text.isEmptyOrNull ||
                        longitudeController.text.isEmptyOrNull) return;
                    loc["lat"] = double.parse(lattitudeController.text);
                    loc["long"] = double.parse(longitudeController.text);

                    businessDetailData['businessLocation'] = loc;
                    Navigator.pop(context);
                  },
                  child: const Text('Submit '),
                ),
                ElevatedButton(
                  style: ButtonStyle(
                    backgroundColor: MaterialStateProperty.all(Colors.blue),
                    textStyle: MaterialStateProperty.all(
                        const TextStyle(color: Colors.white)),
                  ),
                  onPressed: () async {
                    showDialog(
                        context: context,
                        builder: (context) {
                          return const SizedBox(
                                  height: 50,
                                  width: 50,
                                  child: CircularProgressIndicator())
                              .centered();
                        });

                    var loc = await GeolocatorPlatform.instance
                        .getCurrentPosition(
                            locationSettings: const LocationSettings());
                    Navigator.of(context).pop();

                    var b = await Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => GoogleMapScreen(
                          lat: loc.latitude,
                          long: loc.longitude,
                        ),
                      ),
                    );
                    lattitudeController.text = b["lat"].toString();

                    longitudeController.text = b["long"].toString();
                  },
                  child: const Text('Map'),
                ),
              ],
            ),
          );
        });
  }

  @override
  void initState() {
    if (widget.edit) {
      businessDetailData = widget.data!.toMap();
    }
    log(businessDetailData.toString(), name: "edit");
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    var x = MediaQuery.of(context).size.width;
    return Scaffold(
      appBar: AppBar(
        leading: Row(
          children: [
            const SizedBox(
              width: 35,
            ),
            GestureDetector(
              onTap: () => Navigator.pop(context),
              child: Icon(
                Icons.arrow_back_ios,
                size: 20,
                color: kLoadingScreenTextColor,
              ),
            ),
          ],
        ),
      ),
      body: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 34),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                //Advertise Your Business! label
                Text(
                  "Business/Service Details",
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 20,
                    color: kLoadingScreenTextColor,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 15, bottom: 20),
                  child: Column(
                    children: [
                      //name
                      TextFormField(
                        keyboardType: TextInputType.text,
                        initialValue: businessDetailData['name'],
                        // controller: TextEditingController myController = TextEditingController(),
                        onChanged: (val) => businessDetailData['name'] = val,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter some text';
                          }
                          return null;
                        },
                        decoration: InputDecoration(
                          hintText: 'Name *',
                          hintStyle: TextStyle(
                            color: kAdvertiseContainerTextColor,
                            fontSize: 18,
                            fontWeight: FontWeight.w400,
                          ),
                          floatingLabelBehavior: FloatingLabelBehavior.always,
                          prefixIconColor: kHintTextColor,
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 13,
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide:
                                BorderSide(color: kAdvertiseContainerColor),
                            gapPadding: 10,
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide:
                                BorderSide(color: kAdvertiseContainerColor),
                            gapPadding: 10,
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide:
                                BorderSide(color: kAdvertiseContainerColor),
                            gapPadding: 10,
                          ),
                        ),
                      ),
                      //Business  name
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 20),
                        child: TextFormField(
                          initialValue: businessDetailData['businessName'],
                          onChanged: (val) =>
                              businessDetailData['businessName'] = val,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter some text';
                            }
                            return null;
                          },
                          keyboardType: TextInputType.text,
                          decoration: InputDecoration(
                            hintText: 'Business Name *',
                            hintStyle: TextStyle(
                              color: kAdvertiseContainerTextColor,
                              fontSize: 18,
                              fontWeight: FontWeight.w400,
                            ),
                            floatingLabelBehavior: FloatingLabelBehavior.always,
                            prefixIconColor: kHintTextColor,
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 13,
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide:
                                  BorderSide(color: kAdvertiseContainerColor),
                              gapPadding: 10,
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide:
                                  BorderSide(color: kAdvertiseContainerColor),
                              gapPadding: 10,
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide:
                                  BorderSide(color: kAdvertiseContainerColor),
                              gapPadding: 10,
                            ),
                          ),
                        ),
                      ),
                      //Address
                      TextFormField(
                        initialValue: businessDetailData['businessAddress'],
                        onChanged: (val) =>
                            businessDetailData['businessAddress'] = val,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter some text';
                          }
                          return null;
                        },
                        keyboardType: TextInputType.text,
                        decoration: InputDecoration(
                          hintText: 'Address *',
                          hintStyle: TextStyle(
                            color: kAdvertiseContainerTextColor,
                            fontSize: 18,
                            fontWeight: FontWeight.w400,
                          ),
                          floatingLabelBehavior: FloatingLabelBehavior.always,
                          prefixIconColor: kHintTextColor,
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 13,
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide:
                                BorderSide(color: kAdvertiseContainerColor),
                            gapPadding: 10,
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide:
                                BorderSide(color: kAdvertiseContainerColor),
                            gapPadding: 10,
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide:
                                BorderSide(color: kAdvertiseContainerColor),
                            gapPadding: 10,
                          ),
                        ),
                      ),
                      //City
                      Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 0, vertical: 10),
                        child: Container(
                          width: double.infinity,
                          decoration: BoxDecoration(
                              border:
                                  Border.all(color: kAdvertiseContainerColor),
                              borderRadius: BorderRadius.circular(8.6)),
                          child: Center(
                            child: DropdownSearch<String>(
                              selectedItem: businessDetailData['businessCity'],
                              enabled: !widget.edit,
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
                                          borderRadius:
                                              BorderRadius.circular(20))),
                                ),
                                bottomSheetProps: BottomSheetProps(
                                    backgroundColor: const Color.fromARGB(
                                        255, 232, 244, 247),
                                    elevation: 10,
                                    shape: RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(20))),
                                showSearchBox: true,
                              ),
                              dropdownDecoratorProps:
                                  const DropDownDecoratorProps(
                                      textAlignVertical:
                                          TextAlignVertical.center,
                                      textAlign: TextAlign.start,
                                      dropdownSearchDecoration:
                                          InputDecoration.collapsed(
                                              hintTextDirection:
                                                  TextDirection.ltr,
                                              focusColor: Colors.lightBlue,
                                              hintText: 'City')),
                              items: CityList.ListCity.map((e) {
                                return e.name;
                              }).toList(),
                              onChanged: (val) =>
                                  businessDetailData['businessCity'] = val,
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Please enter some text';
                                }
                                return null;
                              },
                            ),
                          ).px12(),
                        ),
                      ),
                      //Pincode
                      TextFormField(
                        initialValue: businessDetailData['businessPinCode'],
                        onChanged: (val) =>
                            businessDetailData['businessPinCode'] = val,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter some text';
                          }
                          return null;
                        },
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                          hintText: 'Pincode *',
                          hintStyle: TextStyle(
                            color: kAdvertiseContainerTextColor,
                            fontSize: 18,
                            fontWeight: FontWeight.w400,
                          ),
                          floatingLabelBehavior: FloatingLabelBehavior.always,
                          prefixIconColor: kHintTextColor,
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 13,
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide:
                                BorderSide(color: kAdvertiseContainerColor),
                            gapPadding: 10,
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide:
                                BorderSide(color: kAdvertiseContainerColor),
                            gapPadding: 10,
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide:
                                BorderSide(color: kAdvertiseContainerColor),
                            gapPadding: 10,
                          ),
                        ),
                      ),
                      //Mobile Number
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 20),
                        child: TextFormField(
                          enabled: !widget.edit,
                          initialValue:
                              businessDetailData['businessMobileNumber'],
                          onChanged: (val) =>
                              businessDetailData['businessMobileNumber'] = val,
                          validator: (value) {
                            if (value == null ||
                                value.isEmpty ||
                                value.length < 10) {
                              return 'Please enter Correct Mobile Number';
                            }
                            return null;
                          },
                          keyboardType: TextInputType.number,
                          decoration: InputDecoration(
                            hintText: 'Mobile Number *',
                            hintStyle: TextStyle(
                              color: kAdvertiseContainerTextColor,
                              fontSize: 18,
                              fontWeight: FontWeight.w400,
                            ),
                            floatingLabelBehavior: FloatingLabelBehavior.always,
                            prefixIconColor: kHintTextColor,
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 13,
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide:
                                  BorderSide(color: kAdvertiseContainerColor),
                              gapPadding: 10,
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide:
                                  BorderSide(color: kAdvertiseContainerColor),
                              gapPadding: 10,
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide:
                                  BorderSide(color: kAdvertiseContainerColor),
                              gapPadding: 10,
                            ),
                          ),
                        ),
                      ),
                      //Aadhar Number
                      if (false)
                        TextFormField(
                          enabled: !widget.edit,
                          initialValue: businessDetailData['aadharCardNumber'],
                          onChanged: (val) =>
                              businessDetailData['aadharCardNumber'] = val,
                          validator: (value) {
                            if (value == null ||
                                value.isEmpty ||
                                value.length < 12) {
                              return 'Please enter Correct Aadhar Number';
                            }
                            return null;
                          },
                          keyboardType: TextInputType.number,
                          decoration: InputDecoration(
                            hintText: 'Aadhar Number *',
                            hintStyle: TextStyle(
                              color: kAdvertiseContainerTextColor,
                              fontSize: 18,
                              fontWeight: FontWeight.w400,
                            ),
                            floatingLabelBehavior: FloatingLabelBehavior.always,
                            prefixIconColor: kHintTextColor,
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 13,
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide:
                                  BorderSide(color: kAdvertiseContainerColor),
                              gapPadding: 10,
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide:
                                  BorderSide(color: kAdvertiseContainerColor),
                              gapPadding: 10,
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide:
                                  BorderSide(color: kAdvertiseContainerColor),
                              gapPadding: 10,
                            ),
                          ),
                        ),
                      const SizedBox(
                        height: 20,
                      ),
                      //location
                      GestureDetector(
                        onTap: () async {
                          await _displayTextInputDialog(context);
                          setState(() {});
                        },
                        child: Container(
                          width: double.infinity,
                          decoration: BoxDecoration(
                            border: Border.all(color: kAdvertiseContainerColor),
                            borderRadius: BorderRadius.circular(8.6),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 9, vertical: 10),
                            child: (businessDetailData['businessLocation']
                                    .toString()
                                    .isEmptyOrNull)
                                ? Row(
                                    mainAxisAlignment: MainAxisAlignment.start,
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
                                            CrossAxisAlignment.end,
                                        children: [
                                          "Lattitude = ${businessDetailData['businessLocation'] == null ? "" : businessDetailData['businessLocation']["lat"].toString()}"
                                              .text
                                              .make(),
                                          "Longitude = ${businessDetailData['businessLocation'] == null ? "" : businessDetailData['businessLocation']["long"].toString()}"
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
                    ],
                  ),
                ),
                GestureDetector(
                  onTap: () {
                    if (_formKey.currentState!.validate() &&
                            businessDetailData['businessLocation']["lat"] !=
                                null &&
                            businessDetailData['businessLocation']["long"] !=
                                null
                        // businessDetailData['aadharCardNumber'].length == 12 &&
                        ) {
                      // ScaffoldMessenger.of(context).showSnackBar(
                      //     const SnackBar(content: Text("error"))
                      // );
                      print(businessDetailData);
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => BusinessAdditionalDetailsScreen(
                            businessDetailData: businessDetailData,
                            edit: widget.edit,
                          ),
                        ),
                      );
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                          content: Text("please provide all details")));
                    }
                  },
                  child: Container(
                    width: double.infinity,
                    height: 50,
                    decoration: BoxDecoration(
                      color: kSignInContainerColor,
                      borderRadius: BorderRadius.circular(5),
                    ),
                    child: const Center(
                      child: Text(
                        "Continue",
                        style: TextStyle(
                          fontWeight: FontWeight.w400,
                          fontSize: 20,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(
                  height: 61,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
