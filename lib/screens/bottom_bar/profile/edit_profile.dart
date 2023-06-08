// ignore_for_file: await_only_futures, unused_local_variable, unnecessary_const, prefer_typing_uninitialized_variables, unused_element, prefer_const_constructors, unnecessary_string_interpolations, unnecessary_null_comparison

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:nearbii/Model/notifStorage.dart';
import 'package:nearbii/constants.dart';
import 'package:velocity_x/velocity_x.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({Key? key}) : super(key: key);

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _db = FirebaseFirestore.instance;
  FirebaseAuth auth = FirebaseAuth.instance;

  @override
  void setState(VoidCallback fn) {
    super.setState(fn);
  }

  final docRef = FirebaseFirestore.instance
      .collection("cities")
      .doc(FirebaseAuth.instance.currentUser?.uid.substring(0, 20));

  Map<String, dynamic> updateProfileData = {};
  var dropDownValue = gender[0];
  var _chosenValue;
  String? genderDropDown = "Male";

  @override
  void initState() {
    super.initState();
    try {
      newEmail = FirebaseAuth.instance.currentUser!.email!;
    } catch (e) {
      print(e);
    }
  }

  updateProfile() {
    // print(auth.currentUser?.uid.substring(0, 20));
    // updateProfileData["hi"] = 1;
    print(updateProfileData);
    print(FirebaseAuth.instance.currentUser!.uid);
    if (updateProfileData['name'] != null) {
      FirebaseAuth.instance.currentUser!
          .updateDisplayName(updateProfileData['name']);
    }

    print(FirebaseAuth.instance.currentUser!.displayName);
    _db
        .collection("User")
        .doc(auth.currentUser?.uid.substring(0, 20))
        .update(updateProfileData);
    setState(() {});
  }

  DateTime selectedDate = DateTime.now();

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
        context: context,
        initialDate: DateTime(
            DateTime.now().year, DateTime.now().month, DateTime.now().day - 1),
        firstDate: DateTime(
            DateTime.now().year - 80, DateTime.now().month, DateTime.now().day),
        lastDate: DateTime(
            DateTime.now().year, DateTime.now().month, DateTime.now().day));
    if (picked != null && picked != selectedDate) {
      setState(() {
        selectedDate = picked;
        updateProfileData["bod"] = picked;
      });
    }
  }

  _displayDialog(BuildContext context, String title, String mapValue) async {
    return showDialog(
        context: context,
        builder: (context) {
          var temp;
          return AlertDialog(
            // title: Text(title),
            content: DropdownButton<String>(
              focusColor: Colors.white,
              value: temp ?? items[0],
              style: const TextStyle(color: Colors.white),
              iconEnabledColor: Colors.black,
              items: items.map<DropdownMenuItem<String>>((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(
                    value,
                    style: const TextStyle(color: Colors.black),
                  ),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  temp = value;
                  print(value);
                });
              },
            ),
            actions: <Widget>[
              // ignore: deprecated_member_use
              ElevatedButton(
                child: const Text('Submit'),
                onPressed: () {
                  setState(() {
                    updateProfileData[mapValue] = temp.toString();
                  });
                  Navigator.of(context).pop();
                },
              )
            ],
          );
        });
  }

  String newEmail = '';

  final TextEditingController numberController = TextEditingController();
  final TextEditingController newEmailController = TextEditingController();

  Future resetEmail(String newEmail) async {
    var message;
    var firebaseUser = await FirebaseAuth.instance.currentUser!;
    FirebaseFirestore.instance
        .collection("User")
        .doc(firebaseUser.uid)
        .set({"email": newEmail}, SetOptions(merge: true));
    firebaseUser
        .updateEmail(newEmail)
        .then(
          (value) => message = 'Success',
        )
        .catchError((onError) => message = 'error');
    return message;
  }

  Future<void> _resetEmailDialog() async {
    return showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            // title: Text('Email Id'),
            content: TextField(
              onChanged: (value) {
                if (value == null) return;
                setState(() {
                  newEmail = value;
                });
              },
              textInputAction: TextInputAction.go,
              keyboardType: TextInputType.emailAddress,
              controller: newEmailController,
              decoration: InputDecoration(hintText: "Enter your email id"),
            ),
            actions: <Widget>[
              // ignore: deprecated_member_use
              ElevatedButton(
                style: ButtonStyle(
                  backgroundColor: MaterialStateProperty.all(Colors.green),
                  textStyle:
                      MaterialStateProperty.all(TextStyle(color: Colors.white)),
                ),
                child: Text('submit'),
                onPressed: () async {
                  if (newEmailController.text.isEmptyOrNull) {
                    Navigator.pop(context);
                    return;
                  }
                  setState(() {
                    newEmail = newEmailController.text;
                  });
                  resetEmail(newEmail);
                  Navigator.pop(context);
                  setState(() {});
                },
              ),
            ],
          );
        });
  }

  Future<void> _displayTextInputDialog(
      BuildContext context,
      String title,
      TextEditingController controller,
      String mapValue,
      bool numberKeyboardNeed) async {
    var temp;
    return showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            content: TextFormField(
              decoration: InputDecoration(
                hintText: title,
              ),
              keyboardType: numberKeyboardNeed
                  ? TextInputType.number
                  : TextInputType.text,
              onChanged: (value) {
                temp = value.toString();
              },
              controller: controller,
            ),
            actions: <Widget>[
              // ignore: deprecated_member_use
              ElevatedButton(
                style: ButtonStyle(
                  backgroundColor: MaterialStateProperty.all(Colors.blue),
                  textStyle:
                      MaterialStateProperty.all(TextStyle(color: Colors.white)),
                ),
                child: const Text('Submit'),
                onPressed: () {
                  setState(() {
                    updateProfileData[mapValue] = temp;
                    controller.text = temp;
                    Navigator.pop(context);
                  });
                },
              ),
            ],
          );
        });
  }

  void openDialogBox(String title, TextEditingController controller,
      String mapValue, bool numberKeyboardNeed) {
    _displayTextInputDialog(
        context, title, controller, mapValue, numberKeyboardNeed);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false, //new line
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

      body: FutureBuilder<DocumentSnapshot>(
        future: _db
            .collection('User')
            .doc(auth.currentUser?.uid.substring(0, 20))
            .get(),
        builder: (context, snapshot) {
          Map<String, dynamic> data =
              snapshot.data?.data() as Map<String, dynamic>;
          if (data != null) {
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14),
              child: Stack(
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      //Edit Profile label
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: Text(
                          "Edit Profile",
                          style: TextStyle(
                            fontWeight: FontWeight.w700,
                            fontSize: 20,
                            color: kLoadingScreenTextColor,
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(20),
                        child: Row(
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "Name",
                                  style: TextStyle(
                                    fontWeight: FontWeight.w600,
                                    fontSize: 16,
                                    color: kSplashScreenDescriptionColor,
                                  ),
                                ),
                                GestureDetector(
                                  onTap: () => openDialogBox("Enter Name",
                                      numberController, "name", false),
                                  child: Text(
                                    updateProfileData['name'] ??
                                        data['name'] ??
                                        auth.currentUser?.displayName,
                                    style: TextStyle(
                                      fontWeight: FontWeight.w400,
                                      fontSize: 18,
                                      color: kLoadingScreenTextColor,
                                    ),
                                  ).onInkTap(() {
                                    openDialogBox("Enter Name",
                                        numberController, "name", false);
                                  }),
                                ),
                              ],
                            ),
                            const Spacer(),
                            SizedBox(
                              height: 64,
                              width: 64,
                              child: CircleAvatar(
                                radius: 28,
                                backgroundImage: NetworkImage(data['image'] ??
                                    "https://firebasestorage.googleapis.com/v0/b/neabiiapp.appspot.com/o/360_F_64678017_zUpiZFjj04cnLri7oADnyMH0XBYyQghG.jpg?alt=media&token=27052833-5800-4721-9429-d21c4a3eac1b"),
                              ),
                            )
                          ],
                        ),
                      ),
                      Container(
                        height: 0.5,
                        color: kDrawerDividerColor,
                      ),
                      Padding(
                        padding: const EdgeInsets.all(20),
                        child: Row(
                          children: [
                            Text(
                              "Mobile Number",
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: 16,
                                color: kSplashScreenDescriptionColor,
                              ),
                            ),
                            const Spacer(),
                            GestureDetector(
                              onTap: () => openDialogBox("Enter Number",
                                  numberController, "phone", true),
                              child: Text(
                                updateProfileData['phone'] ??
                                    data['phone'] ??
                                    "Add Number",
                              ).onInkTap(() {
                                openDialogBox("Enter Number", numberController,
                                    "phone", true);
                              }),
                            )
                          ],
                        ),
                      ),
                      Container(
                        height: 0.5,
                        color: kDrawerDividerColor,
                      ),
                      Padding(
                        padding: const EdgeInsets.all(20),
                        child: Row(
                          children: [
                            Text(
                              "Gender",
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: 16,
                                color: kSplashScreenDescriptionColor,
                              ),
                            ),
                            const Spacer(),
                            DropdownButton<String>(
                              // Initial Value
                              value: genderDropDown ??
                                  data['gender'] ??
                                  genderDropDown,

                              // Down Arrow Icon
                              icon: const Icon(Icons.keyboard_arrow_down),

                              // Array list of items
                              items: ["Male", "Female"].map((String items) {
                                return DropdownMenuItem(
                                  value: items,
                                  child: Text(items),
                                );
                              }).toList(),
                              // After selecting the desired option,it will
                              // change button value to selected value
                              onChanged: (String? newValue) {
                                setState(() {
                                  genderDropDown = newValue!;
                                  updateProfileData['gender'] = genderDropDown;
                                });
                              },
                            ),
                            // Text(
                            //   "Male",
                            //   style: TextStyle(
                            //     fontWeight: FontWeight.w400,
                            //     fontSize: 16,
                            //     color: kLoadingScreenTextColor,
                            //   ),
                            // ),
                          ],
                        ),
                      ),
                      Container(
                        height: 0.5,
                        color: kDrawerDividerColor,
                      ),
                      Padding(
                        padding: const EdgeInsets.all(20),
                        child: Row(
                          children: [
                            Text(
                              "Birthday",
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: 16,
                                color: kSplashScreenDescriptionColor,
                              ),
                            ),
                            const Spacer(),
                            GestureDetector(
                              onTap: () => _selectDate(context),
                              child: Text(
                                data['bod'] != null
                                    ? data['bod']
                                        .toDate()
                                        .toString()
                                        .substring(0, 10)
                                    : updateProfileData["bod"] == null
                                        ? "Add Birthday"
                                        : updateProfileData["bod"]
                                            .toString()
                                            .substring(0, 10),
                                style: TextStyle(
                                  fontWeight: FontWeight.w400,
                                  fontSize: 16,
                                  color: kLoadingScreenTextColor,
                                ),
                              ),
                            )
                          ],
                        ),
                      ),
                      Container(
                        height: 0.5,
                        color: kDrawerDividerColor,
                      ),
                      Padding(
                        padding: const EdgeInsets.all(20),
                        child: Row(
                          children: [
                            Text(
                              "Email Id",
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: 16,
                                color: kSplashScreenDescriptionColor,
                              ),
                            ),
                            const Spacer(),
                            GestureDetector(
                              onTap: () {
                                print("hello");
                                _resetEmailDialog();
                              },
                              child: SizedBox(
                                width: 200,
                                child: RichText(
                                    text: TextSpan(
                                  text: newEmail ?? "",
                                  style: TextStyle(
                                    fontWeight: FontWeight.w400,
                                    fontSize: 16,
                                    color: kLoadingScreenTextColor,
                                  ),
                                )).onInkTap(
                                  () {
                                    _resetEmailDialog();
                                  },
                                ),
                              ),
                            )
                          ],
                        ),
                      ),

                      Container(
                        height: 0.5,
                        color: kDrawerDividerColor,
                      ),
                    ],
                  ),
                  Positioned(
                    bottom: 44,
                    right: 20,
                    left: 20,
                    child: GestureDetector(
                      onTap: () {
                        updateProfile();
                        Navigator.pop(context);
                        setState(() {});
                      },
                      child: Container(
                        height: 50,
                        decoration: BoxDecoration(
                          color: kSignInContainerColor,
                          borderRadius: BorderRadius.circular(5),
                        ),
                        child: const Center(
                          child: const Text(
                            "Save",
                            style: TextStyle(
                              fontWeight: FontWeight.w400,
                              fontSize: 20,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ),
                  )
                ],
              ),
            );
          }
          return const Center(child: CircularProgressIndicator());
        },
      ),
    );
  }
}
