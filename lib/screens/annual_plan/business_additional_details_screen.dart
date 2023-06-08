// ignore_for_file: prefer_const_constructors

import 'dart:developer';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:nearbii/constants.dart';
import 'package:nearbii/screens/annual_plan/nearbii_membership_plan.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:flutter_datetime_picker/flutter_datetime_picker.dart';
import 'package:nearbii/screens/bottom_bar/master_screen.dart';
import 'package:velocity_x/velocity_x.dart';

class BusinessAdditionalDetailsScreen extends StatefulWidget {
  bool edit;
  BusinessAdditionalDetailsScreen(
      {Key? key, required this.businessDetailData, this.edit = false})
      : super(key: key);

  final Map<String, dynamic> businessDetailData;

  @override
  State<BusinessAdditionalDetailsScreen> createState() =>
      _BusinessAdditionalDetailsScreenState();
}

class _BusinessAdditionalDetailsScreenState
    extends State<BusinessAdditionalDetailsScreen> {
  Map<String, dynamic> businessDetailData = {};

  String startTime = "";

  var controllerTimeTo = TextEditingController();

  var controllerTimeFrom = TextEditingController();

  String endTime = "";

  String? starDay = '';

  String? endDay;

  int load = 53;

  @override
  void initState() {
    businessDetailData = widget.businessDetailData;
    widget.businessDetailData["coupan"] = "12345";
    // TODO: implement initState
    log(businessDetailData["businessCat"].toString());
    super.initState();
  }

  String dropdownvalue = 'Item 1';

  var items = [
    'Item 1',
    'Item 2',
    'Item 3',
    'Item 4',
    'Item 5',
  ];

  String? mainCat = "Automobile";
  String? subCat;

  String eventImage = "";

  Widget getSubBusinessCatDrop(BuildContext context) {
    try {
      final _firestore = FirebaseFirestore.instance;

      return StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
        stream: _firestore
            .collection('Services')
            .doc(mainCat)
            .snapshots()
            .handleError((error) {
          return Container(
            child: SizedBox(
              width: 30,
              height: 30,
              child: CircularProgressIndicator(),
            ),
          );
        }),
        builder: (context, snapshot) {
          if (!snapshot.hasData || snapshot.data == null) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          var d = snapshot.data!.data()!;
          log(d.toString());

          List<dynamic> _sbcat = d["subcategory"];

          return Container(
              margin: EdgeInsets.only(top: 20),
              child: Container(
                  margin: EdgeInsets.only(top: 20),
                  child: DropdownButtonFormField(
                      value: subCat,
                      hint: Text(businessDetailData["businessSubCat"] ??
                          "Sub Category *"),
                      decoration: InputDecoration(
                        hintText: businessDetailData["businessSubCat"],
                        hintStyle: TextStyle(
                            color: Color.fromARGB(255, 203, 207, 207)),
                        enabledBorder: OutlineInputBorder(
                            borderSide: BorderSide(
                          color: Color.fromARGB(173, 125, 209, 248),
                        )),
                        focusedBorder: OutlineInputBorder(
                          borderSide: const BorderSide(
                              color: Color.fromARGB(173, 125, 209, 248),
                              width: 1),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        border: OutlineInputBorder(
                          borderSide: const BorderSide(
                              color: Color.fromARGB(173, 125, 209, 248),
                              width: 1),
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      dropdownColor: Color.fromARGB(255, 243, 243, 243),
                      onChanged: (String? newValue) {
                        _setSubCat(newValue);
                      },
                      items: _sbcat.map((ee) {
                        // final data = e.data as dynamic;

                        return DropdownMenuItem<String>(
                          value: ee["title"],
                          child: Text(ee["title"]),
                        );
                      }).toList())));
        },
      );
    } catch (Ex) {
      print("0x1Error To Get User");
      return Container(
        child: SizedBox(
          width: 30,
          height: 30,
          child: CircularProgressIndicator(),
        ),
      );
    }
  }

  Widget getBusinessCatDrop(BuildContext context) {
    try {
      final _firestore = FirebaseFirestore.instance;

      return StreamBuilder<QuerySnapshot>(
        stream:
            _firestore.collection('Services').snapshots().handleError((error) {
          return Container(
            child: SizedBox(
              width: 30,
              height: 30,
              child: CircularProgressIndicator(),
            ),
          );
        }),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          return Container(
              margin: EdgeInsets.only(top: 20),
              child: DropdownButtonFormField<String>(
                  hint: Text(
                    businessDetailData["businessCat"] ?? "Category *",
                    style: TextStyle(color: Color.fromARGB(255, 203, 207, 207)),
                  ),
                  decoration: InputDecoration(
                    hintText: "Category *",
                    hintStyle:
                        TextStyle(color: Color.fromARGB(255, 203, 207, 207)),
                    enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(
                      color: Color.fromARGB(173, 125, 209, 248),
                    )),
                    focusedBorder: OutlineInputBorder(
                      borderSide: const BorderSide(
                          color: Color.fromARGB(173, 125, 209, 248), width: 1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    border: OutlineInputBorder(
                      borderSide: const BorderSide(
                          color: Color.fromARGB(173, 125, 209, 248), width: 1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  dropdownColor: Color.fromARGB(255, 243, 243, 243),
                  onChanged: (String? newValue) {
                    subCat = null;
                    _setMainCat(newValue);
                  },
                  items: snapshot.data!.docs.map((e) {
                    final data = e.data as dynamic;

                    return DropdownMenuItem<String>(
                      value: e.id.toString(),
                      child: Text(e.id.toString()),
                    );
                  }).toList()));
        },
      );
    } catch (Ex) {
      print("0x1Error To Get User");
      return Container(
        child: SizedBox(
          width: 30,
          height: 30,
          child: CircularProgressIndicator(),
        ),
      );
    }
  }

  void _setMainCat(String? newValue) {
    setState(() {
      mainCat = newValue!;

      widget.businessDetailData["businessCat"] = newValue;
    });
  }

  void _setSubCat(String? newValue) {
    setState(() {
      subCat = newValue!;
      widget.businessDetailData["businessSubCat"] = newValue;
    });
  }

  void _setOpenTime(int? newValue) {
    setState(() {
      // subCat = newValue!;
      widget.businessDetailData["openTime"] = newValue;
    });
  }

  void _setCloseTime(int? newValue) {
    setState(() {
      // subCat = newValue!;
      widget.businessDetailData["closeTime"] = newValue;
    });
  }

  void _setWorkingDay(String? newValue) {
    print(newValue);
    setState(() {
      // subCat = newValue!;
      widget.businessDetailData["workingDay"] = newValue;
    });
  }

  _imgFromGallery() async {
    XFile? images = await ImagePicker().pickImage(source: ImageSource.gallery);
    //.getImage(source: ImageSource.gallery, imageQuality: 88);
    if (images != null) {
      setState(() {
        eventImage = images.path;
        businessDetailData["businessImage"] = images.path;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    var y = MediaQuery.of(context).size.height;
    var x = MediaQuery.of(context).size.width;
    return Scaffold(
      appBar: AppBar(
        leading: Row(
          children: [
            SizedBox(
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
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 34),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              //Advertise Your Business! label
              Text(
                "Additional Information",
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
                    getBusinessCatDrop(context),
                    getSubBusinessCatDrop(context),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        SizedBox(
                            width: x / 3.5,
                            child: TextField(
                              readOnly: true,
                              controller: controllerTimeFrom,
                              decoration: InputDecoration(
                                contentPadding:
                                    EdgeInsets.only(left: 10, right: 20),
                                label: (widget.businessDetailData["openTime"] !=
                                            null
                                        ? DateTime.fromMillisecondsSinceEpoch(
                                                    widget.businessDetailData[
                                                        "openTime"])
                                                .hour
                                                .toString() +
                                            " : " +
                                            DateTime.fromMillisecondsSinceEpoch(
                                                    widget.businessDetailData[
                                                        "openTime"])
                                                .minute
                                                .toString()
                                        : "Open Time")
                                    .text
                                    .sm
                                    .makeCentered()
                                    .px4(),
                                border: OutlineInputBorder(
                                    borderSide: BorderSide(
                                        color:
                                            Color.fromARGB(173, 125, 209, 248)),
                                    borderRadius: BorderRadius.zero),
                              ),
                              onTap: () {
                                DatePicker.showTime12hPicker(context,
                                    showTitleActions: true, onChanged: (date) {
                                  print('change $date');
                                }, onConfirm: (date) {
                                  int h = date.hour > 12
                                      ? date.hour - 12
                                      : date.hour;
                                  String ampm = date.hour > 12 ? "PM" : "AM";
                                  startTime = h.toString() +
                                      ":" +
                                      date.minute.toString() +
                                      " - " +
                                      ampm;
                                  _setOpenTime(date.millisecondsSinceEpoch);
                                  controllerTimeFrom.text = startTime;
                                  setState(() {});
                                },
                                    currentTime: DateTime.now(),
                                    locale: LocaleType.en);
                              },
                            )).pOnly(right: 20),
                        "To"
                            .text
                            .xl
                            .bold
                            .color(Color(0xff999999))
                            .make()
                            .pOnly(right: 20),
                        Container(
                          width: x / 3.5,
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(y / 18)),
                          child: TextField(
                            readOnly: true,
                            controller: controllerTimeTo,
                            decoration: InputDecoration(
                              contentPadding:
                                  EdgeInsets.only(left: 10, right: 20),
                              label: (widget.businessDetailData["closeTime"] !=
                                          null
                                      ? DateTime.fromMillisecondsSinceEpoch(
                                                  widget.businessDetailData[
                                                      "closeTime"])
                                              .hour
                                              .toString() +
                                          " : " +
                                          DateTime.fromMillisecondsSinceEpoch(
                                                  widget.businessDetailData[
                                                      "closeTime"])
                                              .minute
                                              .toString()
                                      : "Close Time")
                                  .text
                                  .sm
                                  .makeCentered()
                                  .px4(),
                              border: OutlineInputBorder(
                                  borderRadius: BorderRadius.zero),
                            ),
                            onTap: () {
                              DatePicker.showTime12hPicker(context,
                                  showTitleActions: true, onChanged: (date) {
                                print('change $date');
                              }, onConfirm: (date) {
                                int h =
                                    date.hour > 12 ? date.hour - 12 : date.hour;
                                String ampm = date.hour > 12 ? "PM" : "AM";

                                endTime = h.toString() +
                                    ":" +
                                    date.minute.toString() +
                                    " - " +
                                    ampm;
                                controllerTimeTo.text = endTime;
                                _setCloseTime(date.millisecondsSinceEpoch);
                                setState(() {});
                                print('confirm $date');
                              },
                                  currentTime: DateTime.now(),
                                  locale: LocaleType.en);
                            },
                          ).centered(),
                        ),
                      ],
                    ).pOnly(top: 20, bottom: 20),
                    Row(
                      children: [
                        Container(
                            width: x / 3.4,
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(y / 18)),
                            child: DropdownButtonFormField(
                              hint: Text(
                                (widget.businessDetailData["workingDay"] != null
                                    ? widget.businessDetailData["workingDay"]
                                        .toString()
                                        .split('-')
                                        .first
                                    : "Open Day"),
                                textScaleFactor: 0.8,
                                style: TextStyle(
                                    color: Color.fromARGB(255, 203, 207, 207)),
                              ),
                              decoration: InputDecoration(
                                hintText: "Start Day",
                                hintStyle: TextStyle(
                                    color: Color.fromARGB(255, 203, 207, 207)),
                                enabledBorder: OutlineInputBorder(
                                    borderSide: BorderSide(
                                  color: Color.fromARGB(173, 125, 209, 248),
                                )),
                                focusedBorder: OutlineInputBorder(
                                  borderSide: const BorderSide(
                                      color: Color.fromARGB(173, 125, 209, 248),
                                      width: 1),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                border: OutlineInputBorder(
                                  borderSide: const BorderSide(
                                      color: Color.fromARGB(173, 125, 209, 248),
                                      width: 1),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                              // value: starDay,
                              dropdownColor: Color.fromARGB(255, 243, 243, 243),
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
                                _setWorkingDay(work);
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
                            )).pOnly(right: 20),
                        "To"
                            .text
                            .xl
                            .bold
                            .color(Color(0xff999999))
                            .make()
                            .centered()
                            .pOnly(right: 20),
                        Container(
                            width: x / 3.5,
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(y / 18)),
                            child: DropdownButtonFormField(
                              hint: Text(
                                (widget.businessDetailData["workingDay"] != null
                                    ? widget.businessDetailData["workingDay"]
                                        .toString()
                                        .split('-')
                                        .last
                                    : "Close Day"),
                                textScaleFactor: 0.7,
                                style: TextStyle(
                                    color: Color.fromARGB(255, 203, 207, 207)),
                              ),
                              decoration: InputDecoration(
                                hintStyle: TextStyle(
                                    color: Color.fromARGB(255, 203, 207, 207)),
                                enabledBorder: OutlineInputBorder(
                                    borderSide: BorderSide(
                                  color: Color.fromARGB(173, 125, 209, 248),
                                )),
                                focusedBorder: OutlineInputBorder(
                                  borderSide: const BorderSide(
                                      color: Color.fromARGB(173, 125, 209, 248),
                                      width: 1),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                border: OutlineInputBorder(
                                  borderSide: const BorderSide(
                                      color: Color.fromARGB(173, 125, 209, 248),
                                      width: 1),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                              dropdownColor: Color.fromARGB(255, 243, 243, 243),
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
                                _setWorkingDay(work);
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
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 20),
                      child: TextFormField(
                        initialValue: widget.businessDetailData["bussinesDesc"],
                        onChanged: (text) {
                          setState(() {
                            widget.businessDetailData["bussinesDesc"] = text;
                          });
                        },
                        keyboardType: TextInputType.text,
                        decoration: InputDecoration(
                          hintText: 'Description *',
                          hintStyle: TextStyle(
                            color: kAdvertiseContainerTextColor,
                            fontSize: 18,
                            fontWeight: FontWeight.w400,
                          ),
                          floatingLabelBehavior: FloatingLabelBehavior.always,
                          prefixIconColor: kHintTextColor,
                          contentPadding: EdgeInsets.symmetric(
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
                    //Reference Code/Name *
                    TextFormField(
                      enabled: !widget.edit,
                      onChanged: (text) {
                        setState(() {
                          widget.businessDetailData["coupan"] = text;
                        });
                      },
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        hintText: 'Coupon Code (Optional)',
                        hintStyle: TextStyle(
                          color: kAdvertiseContainerTextColor,
                          fontSize: 18,
                          fontWeight: FontWeight.w400,
                        ),
                        floatingLabelBehavior: FloatingLabelBehavior.always,
                        prefixIconColor: kHintTextColor,
                        contentPadding: EdgeInsets.symmetric(
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
                    SizedBox(
                      height: 20,
                    ),
                    //add photos
                    InkWell(
                      onTap: () {
                        _imgFromGallery();
                      },
                      child: Container(
                        width: MediaQuery.of(context).size.width * 0.80,
                        height: 120,
                        margin: EdgeInsets.only(top: 20),
                        padding: EdgeInsets.all(9),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            width: 1,
                            color: Color.fromARGB(173, 125, 209, 248),
                          ),
                        ),
                        child: Row(
                          children: [
                            Container(
                              decoration: BoxDecoration(
                                image: widget.businessDetailData[
                                            "businessImage"] ==
                                        null
                                    ? eventImage != ""
                                        ? DecorationImage(
                                            fit: BoxFit.cover,
                                            image: FileImage(File(eventImage)))
                                        : null
                                    : DecorationImage(
                                        image: FileImage(File(
                                            widget.businessDetailData[
                                                "businessImage"])),
                                        fit: BoxFit.cover),
                                color: Color.fromRGBO(241, 246, 247, 1),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              width: 110,
                              height: 110,
                              child: Icon(Icons.add_outlined,
                                  size: 60,
                                  color: Color.fromRGBO(196, 196, 196, 1)),
                            ),
                            Container(
                                margin: EdgeInsets.only(left: 10),
                                child: Text(
                                  "Add Photo (Optional)",
                                  style: TextStyle(
                                      color: Color.fromARGB(255, 203, 207, 207),
                                      fontSize: 15),
                                ))
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              //make payment button
              GestureDetector(
                onTap: () async {
                  {
                    if (widget.businessDetailData["businessCat"]
                        .toString()
                        .isEmptyOrNull) {
                      Fluttertoast.showToast(
                          msg: "Please Select Business businessCat");
                      return;
                    }
                    if (widget.businessDetailData["businessSubCat"]
                        .toString()
                        .isEmptyOrNull) {
                      Fluttertoast.showToast(
                          msg: "Please Select Business SubCategory");
                      return;
                    }
                    if (widget.businessDetailData["closeTime"]
                        .toString()
                        .isEmptyOrNull) {
                      Fluttertoast.showToast(
                          msg: "Please Select Business closeTime");
                      return;
                    }

                    if (widget.businessDetailData["openTime"]
                        .toString()
                        .isEmptyOrNull) {
                      Fluttertoast.showToast(
                          msg: "Please Select Business openTime");
                      return;
                    }
                    if (widget.businessDetailData["workingDay"]
                        .toString()
                        .isEmptyOrNull) {
                      Fluttertoast.showToast(
                          msg: "Please Select Business workingDay");
                      return;
                    }
                    if (widget.businessDetailData["bussinesDesc"]
                        .toString()
                        .isEmptyOrNull) {
                      Fluttertoast.showToast(
                          msg: "Please Select Business bussinesDesc");
                      return;
                    }
                    if (widget.businessDetailData["openTime"]
                        .toString()
                        .isEmptyOrNull) {
                      Fluttertoast.showToast(
                          msg: "Please Select Business openTime");
                      return;
                    }

                    widget.businessDetailData["active"] = true;

                    print(widget.businessDetailData["openTime"]);
                    if (widget.edit) {
                      setState(() {
                        load = 1;
                      });
                      if (eventImage.isNotEmptyAndNotNull) {
                        Reference reference = FirebaseStorage.instance
                            .ref()
                            .child('businessImage/' +
                                FirebaseAuth.instance.currentUser!.uid
                                    .substring(0, 20) +
                                ".jpg");
                        UploadTask uploadTask = reference.putFile(
                            File(widget.businessDetailData["businessImage"]));
                        var snapshot = uploadTask.snapshot;
                        var imageUrl = await snapshot.ref.getDownloadURL();

                        widget.businessDetailData["businessImage"] = imageUrl;
                        Fluttertoast.showToast(
                            msg: "Image Uploaded Successfully");
                        print(imageUrl);
                      }
                      FirebaseFirestore.instance
                          .collection("vendor")
                          .doc(FirebaseAuth.instance.currentUser!.uid
                              .substring(0, 20))
                          .set(widget.businessDetailData,
                              SetOptions(merge: true))
                          .then((value) async {
                        setState(() {
                          load = 0;
                        });
                        Fluttertoast.showToast(msg: "Data Updated");
                        await Future.delayed(Duration(milliseconds: 1000));
                        Navigator.of(context).pushAndRemoveUntil(
                            MaterialPageRoute(builder: ((context) {
                          return MasterPage(
                            currentIndex: 0,
                          );
                        })), (route) => false);
                      });
                    } else {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => NearBiiMembershipPlanScreen(
                              businessDetailData: widget.businessDetailData),
                        ),
                      );
                    }
                  }

                  // businessDetailDta = widget.businessDetailData;
                  // print(businessDetailData);
                  // //TODO: same get null value
                },
                child: AnimatedContainer(
                  width: load == 53 ? 150 : 50,
                  height: 50,
                  decoration: BoxDecoration(
                    color: kSignInContainerColor,
                    borderRadius: BorderRadius.circular(5),
                  ),
                  duration: Duration(milliseconds: 500),
                  child: load == 1
                      ? SizedBox(
                              height: 30,
                              width: 30,
                              child: CircularProgressIndicator())
                          .centered()
                      : load == 0
                          ? Icon(Icons.done)
                          : Center(
                              child: Text(
                                widget.edit ? "Done" : "Make Payment",
                                style: TextStyle(
                                  fontWeight: FontWeight.w400,
                                  fontSize: 20,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                ).centered(),
              ),
              SizedBox(
                height: 61,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
