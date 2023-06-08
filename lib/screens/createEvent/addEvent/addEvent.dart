// ignore_for_file: curly_braces_in_flow_control_structures, prefer_const_constructors

import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:nearbii/screens/annual_plan/GoogleMapScreen.dart';
import 'package:nearbii/screens/createEvent/addEvent/moreInfo.dart';
import 'package:velocity_x/velocity_x.dart';

import '../../../constants.dart';
import '../../bottom_bar/bottomBar/bottomBar.dart';

class AddEvent extends StatefulWidget {
  const AddEvent({Key? key}) : super(key: key);

  @override
  State<AddEvent> createState() => _AddEventState();
}

class _AddEventState extends State<AddEvent> {
  TextEditingController nameOfEvent = TextEditingController();
  TextEditingController ogrName = TextEditingController();
  TextEditingController addr = TextEditingController();
  TextEditingController city = TextEditingController();
  TextEditingController pin = TextEditingController();
  TextEditingController mobo = TextEditingController();
  TextEditingController addhr = TextEditingController();
  TextEditingController map = TextEditingController();

  late List<String> hintLable;
  late List<TextEditingController> inputController;

  Map<String, dynamic> eventLocation = {};

  Map<String, dynamic> eventInfo = {};

  String pinLocation = "Pin Your Location";

  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    hintLable = [
      "Name Of Event *",
      "Organizer Name *",
      "Address *",
      "Map *",
      "City * (Please Pick Location) ",
      "Pincode *(Please Pick Location)",
      "Mobile Number *",
      "Aadhar Number *"
    ];
    inputController = [nameOfEvent, ogrName, addr, map, city, pin, mobo, addhr];
  }

  @override
  Widget build(BuildContext context) {
    var x = MediaQuery.of(context).size.width;
    return SafeArea(
        top: false,
        child: Scaffold(
            bottomNavigationBar: addBottomBar(context),
            appBar: AppBar(
              leading: Column(
                children: [
                  SizedBox(
                    width: 45,
                    height: 20,
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
            body: SizedBox(
              width: MediaQuery.of(context).size.width,
              height: MediaQuery.of(context).size.height,
              child: SingleChildScrollView(
                  child: Column(
                children: [
                  Container(
                    alignment: Alignment.centerLeft,
                    padding: EdgeInsets.only(left: 20),
                    child: Text(
                      "Event Details",
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 20,
                        color: kLoadingScreenTextColor,
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  SizedBox(
                    width: MediaQuery.of(context).size.width,
                    height: MediaQuery.of(context).size.height * 0.60,
                    child: Form(
                      key: _formKey,
                      child: ListView.builder(
                          itemCount: hintLable.length,
                          itemBuilder: (context, index) {
                            if (hintLable[index] == "Map *") {
                              return GestureDetector(
                                onTap: () async {
                                  await _displayTextInputDialog(context);
                                  if (eventLocation["lat"] == null ||
                                      eventLocation["long"] == null) {
                                    return;
                                  }
                                  double lat = eventLocation["lat"];
                                  double long = eventLocation["long"];

                                  map.text =
                                      "Lattitude = ${lat.toDoubleStringAsPrecised(length: 2)} Longitude = ${long.toDoubleStringAsPrecised(length: 2)}";

                                  setState(() {});
                                },
                                child: TextFormField(
                                  enabled: false,
                                  controller: map,
                                  decoration: InputDecoration(
                                    errorStyle: TextStyle(
                                      color: Theme.of(context)
                                          .colorScheme
                                          .error, // or any other color
                                    ),
                                    icon: Icon(Icons.location_on),
                                    hintText: hintLable[index],
                                    hintStyle: TextStyle(
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
                                  validator: (value) {
                                    if (map.text.isEmptyOrNull) {
                                      return hintLable[index];
                                    }
                                    return null;
                                  },
                                ),
                              ).p16();
                            } else {
                              return Container(
                                width: MediaQuery.of(context).size.width,
                                margin: EdgeInsets.only(
                                    top: 20, left: 20, right: 20),
                                child: TextFormField(
                                    validator: (value) {
                                      if (value == null || value.isEmpty) {
                                        return hintLable[index];
                                      }
                                      return null;
                                    },
                                    enabled: hintLable[index] ==
                                                "City * (Please Pick Location) " ||
                                            hintLable[index] ==
                                                "Pincode *(Please Pick Location)"
                                        ? false
                                        : true,
                                    controller: inputController[index],
                                    decoration: InputDecoration(
                                      errorStyle: TextStyle(
                                        color: Theme.of(context)
                                            .colorScheme
                                            .error, // or any other color
                                      ),
                                      hintText: hintLable[index],
                                      hintStyle: TextStyle(
                                          color: Color.fromARGB(
                                              255, 203, 207, 207)),
                                      enabledBorder: const OutlineInputBorder(
                                          borderSide: BorderSide(
                                        color:
                                            Color.fromARGB(173, 125, 209, 248),
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
                                    )),
                              );
                            }
                          }),
                    ),
                  ),
                  InkWell(
                    onTap: () {
                      if (!_formKey.currentState!.validate()) {
                        return;
                      }

                      if (addhr.text.length != 12) {
                        Fluttertoast.showToast(
                            msg: 'Enter Valid Aadhar Number');
                      }
                      if (addhr.text.length == 12) {
                        eventInfo["name"] = nameOfEvent.text;
                        eventInfo["org"] = ogrName.text;
                        eventInfo["addhr"] = addhr.text;
                        eventInfo["city"] = city.text;
                        eventInfo["pin"] = pin.text;
                        eventInfo["mobo"] = mobo.text;
                        eventInfo["addr"] = addr.text;
                        eventInfo["eventLocation"] = eventLocation;
                        Navigator.of(context)
                            .push(MaterialPageRoute(builder: (context) {
                          return AddMoreInfo(
                            eventInfo: eventInfo,
                          );
                        }));
                      } else {
                        Fluttertoast.showToast(
                            msg: 'Please Enter Valid Details');
                      }
                    },
                    child: Container(
                        width: MediaQuery.of(context).size.width * 0.80,
                        margin: EdgeInsets.only(top: 20),
                        padding: EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: Color.fromRGBO(81, 182, 200, 1),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          "Continue",
                          style: TextStyle(color: Colors.white, fontSize: 20),
                        )),
                  ),
                  SizedBox(
                    height: 60,
                  )
                ],
              )),
            )));
  }

  var lattitude = "";
  var longitude = "";

  TextEditingController lattitudeController = TextEditingController();
  TextEditingController longitudeController = TextEditingController();
  Future<void> _displayTextInputDialog(BuildContext context) async {
    return showDialog(
        context: context,
        builder: (context) {
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
                  onPressed: () async {
                    if (longitudeController.text.isEmptyOrNull ||
                        lattitudeController.text.isEmptyOrNull) {
                      Navigator.pop(context);
                      return;
                    }
                    eventLocation["lat"] =
                        double.parse(lattitudeController.text);
                    eventLocation["long"] =
                        double.parse(longitudeController.text);
                    List<Placemark> placemarks = await placemarkFromCoordinates(
                        eventLocation["lat"], eventLocation["long"],
                        localeIdentifier: "en_IN");

                    if (placemarks[0].postalCode != null &&
                        placemarks[0].locality != null) {
                      setState(() {
                        city.text = placemarks[0].locality!;
                        pin.text = placemarks[0].postalCode!;
                      });
                    }

                    Navigator.pop(context);
                  },
                  style: ButtonStyle(
                    backgroundColor: MaterialStateProperty.all(Colors.blue),
                    textStyle: MaterialStateProperty.all(
                        TextStyle(color: Colors.white)),
                  ),
                  child: const Text('Submit '),
                ),
                ElevatedButton(
                  onPressed: (() async {
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
                    if (b == null) return;
                    lattitudeController.text = b["lat"].toString();
                    longitudeController.text = b["long"].toString();
                  }),
                  style: ButtonStyle(
                    backgroundColor: MaterialStateProperty.all(Colors.blue),
                    textStyle: MaterialStateProperty.all(
                        TextStyle(color: Colors.white)),
                  ),
                  child: const Text('Map'),
                )
              ],
            ),
          );
        });
  }
}
