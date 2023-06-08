// ignore_for_file: avoid_print

import 'dart:developer';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dropdown_search/dropdown_search.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:image_picker/image_picker.dart';
import 'package:nearbii/Model/notifStorage.dart';

import 'package:nearbii/screens/plans/eventPlan/eventPlan.dart';
import 'package:velocity_x/velocity_x.dart';

import '../../../constants.dart';
import '../../bottom_bar/bottomBar/bottomBar.dart';
import 'package:intl/intl.dart';

class AddMoreInfo extends StatefulWidget {
  final Map<String, dynamic> eventInfo;
  const AddMoreInfo({required this.eventInfo, Key? key}) : super(key: key);

  @override
  State<AddMoreInfo> createState() => _AddMoreInfoState();
}

class _AddMoreInfoState extends State<AddMoreInfo> {
  String selectedCat = "Sports";
  TextEditingController eventStartDate = TextEditingController();
  TextEditingController eventEndDate = TextEditingController();
  String eventTime = "";
  TextEditingController eventNotifDate = TextEditingController();
  TextEditingController eventDesc = TextEditingController();
  List<String> eventImage = [];
  final _formKey = GlobalKey<FormState>();
  String eventTargetCity = "";

  int endMili = 0;
  int startmili = 0;
  @override
  void initState() {
    // TODO: implement initState
    eventTargetCity = widget.eventInfo["city"];
    super.initState();
  }

  void saveData(BuildContext context) {
    if (selectedCat.isEmpty ||
        eventEndDate.text.isEmpty ||
        eventStartDate.text.isEmpty ||
        eventTime.isEmpty ||
        eventTargetCity.isEmpty ||
        eventDesc.text.isEmpty ||
        eventImage.isEmpty) {
      Fluttertoast.showToast(msg: "Please Enter all the Details");
      return;
    }
    log(selectedCat);
    widget.eventInfo["eventCat"] = selectedCat;
    widget.eventInfo["eventStartDate"] = startmili;
    widget.eventInfo["eventEndData"] = endMili;
    widget.eventInfo["eventTime"] = eventTime;
    widget.eventInfo["eventNotifDate"] = eventNotifDate.text;
    widget.eventInfo["eventTargetCity"] = eventTargetCity;
    widget.eventInfo["eventDesc"] = eventDesc.text;
    //widget.eventInfo["eventImage"] = eventImage;

    Navigator.of(context).push(MaterialPageRoute(builder: (context) {
      return eventPlan(
        eventInfo: widget.eventInfo,
        path: eventImage,
      );
    }));
  }

  Widget getTimeSlotDrop(BuildContext context) {
    try {
      final _firestore = FirebaseFirestore.instance;

      return StreamBuilder<QuerySnapshot>(
        stream: _firestore
            .collection('EventTimeSlots')
            .snapshots()
            .handleError((error) {
          return Container(
            child: const SizedBox(
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
          var first = snapshot.data!.docs.first.data() as Map;
          return Container(
              margin: const EdgeInsets.only(top: 20, left: 20, right: 20),
              child: DropdownButtonFormField(
                  hint: const Text(
                    "Time Slot *",
                    style: TextStyle(color: Color.fromARGB(255, 203, 207, 207)),
                  ),
                  decoration: InputDecoration(
                    hintText: "Time Slot *",
                    hintStyle: const TextStyle(
                        color: Color.fromARGB(255, 203, 207, 207)),
                    enabledBorder: const OutlineInputBorder(
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
                  dropdownColor: const Color.fromARGB(255, 243, 243, 243),
                  onChanged: (String? newValue) {
                    updatedTime(newValue);
                  },
                  items: snapshot.data!.docs.map((e) {
                    final data = e.data as dynamic;

                    return DropdownMenuItem<String>(
                      value: data()["Time"],
                      child: Text(data()["Time"]),
                    );
                  }).toList()));
        },
      );
    } catch (Ex) {
      print("0x1Error To Get User");
      return Container(
        child: const SizedBox(
          width: 30,
          height: 30,
          child: CircularProgressIndicator(),
        ),
      );
    }
  }

  Widget getCatDrop(BuildContext context) {
    try {
      final _firestore = FirebaseFirestore.instance;

      return StreamBuilder<QuerySnapshot>(
        stream: _firestore
            .collection('EventCategory')
            .snapshots()
            .handleError((error) {
          return const SizedBox(
            width: 30,
            height: 30,
            child: CircularProgressIndicator(),
          );
        }),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }
          var first = snapshot.data!.docs.first.data() as Map;
          // selectedCat = (first!["Title"].toString());
          return Container(
              margin: const EdgeInsets.only(top: 20, left: 20, right: 20),
              child: DropdownButtonFormField(
                  hint: const Text(
                    "Category *",
                    style: TextStyle(color: Color.fromARGB(255, 203, 207, 207)),
                  ),
                  decoration: InputDecoration(
                    hintText: "Category *",
                    hintStyle: const TextStyle(
                        color: Color.fromARGB(255, 203, 207, 207)),
                    enabledBorder: const OutlineInputBorder(
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
                  dropdownColor: const Color.fromARGB(255, 243, 243, 243),
                  value: first["Title"].toString(),
                  onChanged: (String? newValue) {
                    _onShopDropItemSelected(newValue);
                  },
                  items: snapshot.data!.docs.map((e) {
                    final data = e.data as dynamic;
                    print("Showing Menu Index Valuie");
                    print(data()["Title"]);
                    return DropdownMenuItem<String>(
                      value: data()["Title"],
                      child: Text(data()["Title"]),
                    );
                  }).toList()));
        },
      );
    } catch (Ex) {
      print("0x1Error To Get User");
      return Container(
        child: const SizedBox(
          width: 30,
          height: 30,
          child: CircularProgressIndicator(),
        ),
      );
    }
  }

  void _onShopDropItemSelected(String? newValue) {
    print("Value Updated");
    print(newValue);
    log(newValue.toString());

    setState(() {
      selectedCat = newValue!;
    });
  }

  _imgFromGallery() async {
    List<XFile>? images = await ImagePicker().pickMultiImage();
    //.getImage(source: ImageSource.gallery, imageQuality: 88);
    int i = 0;
    for (var img in images) {
      eventImage.add(img.path);
      i++;
    }
    setState(() {});
  }

  void updatedTime(String? value) {
    setState(() {
      eventTime = value!;
    });
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
        top: false,
        child: Scaffold(
            bottomNavigationBar: addBottomBar(context),
            appBar: AppBar(
              leading: Column(
                children: [
                  const SizedBox(
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
                  child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    Container(
                      alignment: Alignment.centerLeft,
                      padding: const EdgeInsets.only(left: 20),
                      child: Text(
                        "Event Details",
                        style: TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 20,
                          color: kLoadingScreenTextColor,
                        ),
                      ),
                    ),
                    getCatDrop(context),
                    // Container(
                    //   margin: EdgeInsets.only(top: 20, left: 20, right: 20),
                    //   child: DropdownButtonFormField(
                    //       hint: Text(
                    //         "Category *",
                    //         style: TextStyle(
                    //             color: Color.fromARGB(255, 203, 207, 207)),
                    //       ),
                    //       decoration: InputDecoration(
                    //         hintText: "Category *",
                    //         hintStyle: TextStyle(
                    //             color: Color.fromARGB(255, 203, 207, 207)),
                    //         enabledBorder: OutlineInputBorder(
                    //             borderSide: BorderSide(
                    //           color: Color.fromARGB(173, 125, 209, 248),
                    //         )),
                    //         focusedBorder: OutlineInputBorder(
                    //           borderSide: const BorderSide(
                    //               color: Color.fromARGB(173, 125, 209, 248),
                    //               width: 1),
                    //           borderRadius: BorderRadius.circular(10),
                    //         ),
                    //         border: OutlineInputBorder(
                    //           borderSide: const BorderSide(
                    //               color: Color.fromARGB(173, 125, 209, 248),
                    //               width: 1),
                    //           borderRadius: BorderRadius.circular(10),
                    //         ),
                    //       ),
                    //       dropdownColor: Color.fromARGB(255, 204, 204, 204),
                    //       value: selectedValue,
                    //       onChanged: (String? newValue) {
                    //         setState(() {
                    //           selectedValue = newValue!;
                    //         });
                    //       },
                    //       items: dropdownItems),
                    // ),
                    Container(
                      margin:
                          const EdgeInsets.only(top: 20, left: 20, right: 20),
                      child: TextFormField(
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter some text';
                            }
                            return null;
                          },
                          controller: eventStartDate,
                          decoration: InputDecoration(
                            suffixIcon: InkWell(
                                onTap: () async {
                                  DateTime? pickedDate = await showDatePicker(
                                      context:
                                          context, //context of current state
                                      initialDate: DateTime.now(),
                                      firstDate: DateTime(
                                          2000), //DateTime.now() - not to allow to choose before today.
                                      lastDate: DateTime(2101));

                                  if (pickedDate != null) {
                                    print(
                                        pickedDate); //pickedDate output format => 2021-03-10 00:00:00.000
                                    String formattedDate =
                                        DateFormat('yyyy-MM-dd')
                                            .format(pickedDate);
                                    print(formattedDate);

                                    setState(() {
                                      eventStartDate.text = formattedDate;
                                      startmili =
                                          pickedDate.millisecondsSinceEpoch;
                                    }); //formatted date output using intl package =>  2021-03-16
                                  } else {
                                    print("Date is not selected");
                                  }
                                },
                                child: const Icon(Icons.calendar_today)),
                            hintText: "Event Start Date *",
                            hintStyle: const TextStyle(
                                color: Color.fromARGB(255, 203, 207, 207)),
                            enabledBorder: const OutlineInputBorder(
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
                          )),
                    ),
                    Container(
                      margin:
                          const EdgeInsets.only(top: 20, left: 20, right: 20),
                      child: TextFormField(
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter some text';
                            }
                            return null;
                          },
                          controller: eventEndDate,
                          decoration: InputDecoration(
                            suffixIcon: InkWell(
                                onTap: () async {
                                  DateTime? pickedDate = await showDatePicker(
                                      context:
                                          context, //context of current state
                                      initialDate: DateTime.now(),
                                      firstDate: DateTime(
                                          2000), //DateTime.now() - not to allow to choose before today.
                                      lastDate: DateTime(2101));

                                  if (pickedDate != null) {
                                    print(
                                        pickedDate); //pickedDate output format => 2021-03-10 00:00:00.000
                                    String formattedDate =
                                        DateFormat('yyyy-MM-dd')
                                            .format(pickedDate);
                                    print(formattedDate);

                                    setState(() {
                                      eventEndDate.text = formattedDate;
                                      endMili = pickedDate
                                          .add(const Duration(hours: 23))
                                          .millisecondsSinceEpoch;
                                    }); //formatted date output using intl package =>  2021-03-16
                                  } else {
                                    print("Date is not selected");
                                  }
                                },
                                child: const Icon(Icons.calendar_today)),
                            hintText: "Event End Date *",
                            hintStyle: const TextStyle(
                                color: Color.fromARGB(255, 203, 207, 207)),
                            enabledBorder: const OutlineInputBorder(
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
                          )),
                    ),

                    getTimeSlotDrop(context),
                    Container(
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(5),
                          border: Border.all(
                              color: const Color.fromARGB(173, 125, 209, 248))),
                      child: DropdownSearch<String>(
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
                                hintText: "Search Category",
                                border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(20))),
                          ),
                          bottomSheetProps: BottomSheetProps(
                              backgroundColor:
                                  const Color.fromARGB(255, 232, 244, 247),
                              elevation: 10,
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(20))),
                          showSearchBox: true,
                        ),
                        dropdownDecoratorProps: const DropDownDecoratorProps(
                            baseStyle:
                                TextStyle(overflow: TextOverflow.ellipsis),
                            textAlignVertical: TextAlignVertical.center,
                            textAlign: TextAlign.start,
                            dropdownSearchDecoration: InputDecoration.collapsed(
                                floatingLabelAlignment:
                                    FloatingLabelAlignment.start,
                                floatingLabelBehavior:
                                    FloatingLabelBehavior.auto,
                                focusColor: Colors.lightBlue,
                                hintText: 'City')),
                        items: CityList.eventCity.map((e) {
                          return e.name;
                        }).toList(),
                        onChanged: ((value) {
                          setState(() {
                            if (value == null) return;
                            eventTargetCity = value;
                          });
                        }),
                        //show selected item
                        selectedItem: eventTargetCity,
                      ).px(10),
                    ).px(20).pOnly(top: 20),
                    Container(
                      margin:
                          const EdgeInsets.only(top: 20, left: 20, right: 20),
                      child: TextFormField(
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter some text';
                            }
                            return null;
                          },
                          controller: eventDesc,
                          decoration: InputDecoration(
                            hintText: "Description *",
                            hintStyle: const TextStyle(
                                color: Color.fromARGB(255, 203, 207, 207)),
                            enabledBorder: const OutlineInputBorder(
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
                          )),
                    ),
                    Container(padding: EdgeInsets.only(left: 24,top: 16,bottom: 8),width: double.infinity,child: Text("Add Images",style: TextStyle(color: kSignInContainerColor,fontSize: 18,fontWeight: FontWeight.bold),)),
                    if(eventImage.length>0) Container(
                      alignment: Alignment.topLeft,
                      height: 300,
                      margin: EdgeInsets.all(16),
                      child: Column(
                        children: [
                          SizedBox(
                            width: double.infinity,
                            height: 290,
                            child: ListView.builder(
                              itemCount: eventImage.length+1,
                              scrollDirection: Axis.horizontal,
                              itemBuilder: (context, index) {
                                if(index==eventImage.length){
                                  return Container(
                                    margin: EdgeInsets.only(top: 100,bottom: 140,left: 32,right: 64),
                                    child: GestureDetector(
                                      onTap: () {
                                        _imgFromGallery();
                                      },
                                      child: const Icon(Icons.add_a_photo),
                                    ),
                                  );
                                }
                                return Container(
                                  margin: EdgeInsets.all(8),
                                  child: Column(
                                    children: [
                                      SizedBox(height: 16,),
                                      Image.file(
                                        File(eventImage[index]),
                                        height: 200,
                                      ),
                                      InkWell(
                                        onTap: () {
                                          setState(() {
                                            eventImage.removeAt(
                                                index);
                                          });
                                        },
                                        child: Container(
                                          height: 50,
                                          width: 50,
                                          child: const Center(
                                              child: Icon(Icons.remove_circle)),
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              },
                            ),
                          ),
                          const Spacer(),
                          //add btn
                        ],
                      ),
                    ),
                    if(eventImage.length==0)InkWell(
                      onTap: () {
                        if (eventImage.isEmpty) {
                          _imgFromGallery();
                        } else {
                          showDialog(
                              context: context,
                              builder: (context) {
                                return StatefulBuilder(
                                    builder: (context, state) {
                                  return Dialog(
                                    child: SizedBox(
                                      height: 300,
                                      child: Column(
                                        children: [
                                          SizedBox(
                                            height: 200,
                                            child: GridView.builder(
                                              gridDelegate:
                                                  const SliverGridDelegateWithFixedCrossAxisCount(
                                                crossAxisCount: 3,
                                                crossAxisSpacing: 10,
                                                mainAxisSpacing: 10,
                                              ),
                                              itemCount: eventImage.length,
                                              itemBuilder: (context, index) {
                                                return SizedBox(
                                                  width: 70,
                                                  height: 70,
                                                  child: Column(
                                                    children: [
                                                      Image.file(
                                                        File(eventImage[index]),
                                                        height: 50,
                                                        width: 70,
                                                        fit: BoxFit.fill,
                                                      ),
                                                      InkWell(
                                                        onTap: () {
                                                          state(() {
                                                            eventImage.removeAt(
                                                                index);
                                                          });
                                                        },
                                                        child: Container(
                                                          height: 20,
                                                          width: 70,
                                                          color: Colors.red,
                                                          child: const Center(
                                                              child: Text(
                                                            'Remove',
                                                            style: TextStyle(
                                                                color: Colors
                                                                    .white),
                                                          )),
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                );
                                              },
                                            ),
                                          ),
                                          const Spacer(),
                                          //add btn
                                          Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: [
                                              SizedBox(
                                                height: 50,
                                                child: ElevatedButton(
                                                  onPressed: () {
                                                    Navigator.pop(context);
                                                  },
                                                  child: const Text("Cancel"),
                                                ),
                                              ),
                                              const SizedBox(
                                                width: 10,
                                              ),
                                              SizedBox(
                                                height: 50,
                                                child: ElevatedButton(
                                                  onPressed: () {
                                                    _imgFromGallery();
                                                    Navigator.pop(context);
                                                  },
                                                  child: const Text("Add"),
                                                ),
                                              ),
                                            ],
                                          ),
                                          const SizedBox(
                                            height: 10,
                                          )
                                        ],
                                      ),
                                    ),
                                  );
                                });
                              });
                        }
                      },
                      child: Container(
                        width: MediaQuery.of(context).size.width * 0.80,
                        height: 120,
                        margin: const EdgeInsets.only(top: 20),
                        padding: const EdgeInsets.all(9),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            width: 1,
                            color: const Color.fromARGB(173, 125, 209, 248),
                          ),
                        ),
                        child: Row(
                          children: [
                            Container(
                              decoration: BoxDecoration(
                                image: eventImage.isNotEmpty
                                    ? DecorationImage(
                                        fit: BoxFit.cover,
                                        image: FileImage(File(eventImage[0])))
                                    : null,
                                color: const Color.fromRGBO(241, 246, 247, 1),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              width: 110,
                              height: 110,
                              child: const Icon(Icons.add_outlined,
                                  size: 60,
                                  color: Color.fromRGBO(196, 196, 196, 1)),
                            ),
                            Container(
                                margin: const EdgeInsets.only(left: 10),
                                child: const Text(
                                  "Add Photo",
                                  style: TextStyle(
                                      color: Color.fromARGB(255, 203, 207, 207),
                                      fontSize: 18),
                                ))
                          ],
                        ),
                      ),
                    ),
                    InkWell(
                      onTap: () {
                        if (!_formKey.currentState!.validate()) return;
                        saveData(context);
                      },
                      child: Container(
                          width: MediaQuery.of(context).size.width * 0.80,
                          margin: const EdgeInsets.only(top: 20),
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: const Color.fromRGBO(81, 182, 200, 1),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          alignment: Alignment.center,
                          child: const Text(
                            "Make Payment",
                            style: TextStyle(color: Colors.white, fontSize: 20),
                          )),
                    ),
                    const SizedBox(
                      height: 60,
                    )
                  ],
                ),
              )),
            )));
  }
}
