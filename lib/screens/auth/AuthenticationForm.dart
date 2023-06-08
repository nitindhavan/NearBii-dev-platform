// ignore: file_names
// ignore_for_file: prefer_const_constructors

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:nearbii/constants.dart';
import 'package:nearbii/screens/bottom_bar/master_screen.dart';
import 'package:nearbii/screens/bottom_bar/permissiondenied_screen.dart';
import 'package:nearbii/services/sendNotification/notificatonByCity/cityNotiication.dart';
import 'package:nearbii/services/setUserMode.dart';

class AuthenticationForm extends StatefulWidget {
  String Phone;
  AuthenticationForm(this.Phone, {Key? key}) : super(key: key);

  @override
  State<AuthenticationForm> createState() => _AuthenticationFormState();
}

class _AuthenticationFormState extends State<AuthenticationForm> {
  final mobileController = TextEditingController();
  final nameController = TextEditingController();
  final formGlobalKey = GlobalKey<FormState>();

  _addDataInDb() async {
    FirebaseAuth.instance.currentUser!.updateDisplayName(nameController.text);
    await FirebaseFirestore.instance
        .collection('User')
        .doc(FirebaseAuth.instance.currentUser!.uid.substring(0, 20))
        .set({
      "phone": "+91" + mobileController.text,
      "name": nameController.text,
    }, SetOptions(merge: true)).then((value) {
      setUserMode();

      showNotification(nameController.text);
      _determinePosition();
    });
  }

  Future<void> _determinePosition() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      Navigator.of(context).push(MaterialPageRoute(builder: ((context) {
        return PermissionDenied();
      })));
      // return Future.error('Location services are disabled.');
    }
    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied ||
        permission == LocationPermission.deniedForever) {
      Navigator.of(context).push(MaterialPageRoute(builder: ((context) {
        return PermissionDenied();
      })));
      return;
    }
    Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: ((context) {
      return MasterPage(
        currentIndex: 0,
      );
    })), (route) => false);
  }

  @override
  void dispose() {
    mobileController.dispose();
    nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;

    return Scaffold(
      body: SingleChildScrollView(
        child: Form(
          key: formGlobalKey,
          child: Padding(
            padding: const EdgeInsets.only(top: 55, left: 16, right: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                //let's go label
                Text(
                  'Lets Go!',
                  style: TextStyle(
                    color: kLoadingScreenTextColor,
                    fontSize: 20,
                    fontWeight: FontWeight.w500,
                  ),
                  textAlign: TextAlign.center,
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 40, bottom: 50),
                  child: Column(
                    children: [
                      //name field
                      SizedBox(
                        height: 50,
                        child: TextFormField(
                          //controller: mobileController,
                          keyboardType: TextInputType.text,
                          controller: nameController,
                          validator: (name) =>
                              name == null ? 'Enter your name' : null,
                          decoration: InputDecoration(
                            hintText: 'Full Name',
                            hintStyle: TextStyle(
                                color: kHintTextColor,
                                fontSize: 18,
                                fontWeight: FontWeight.w400),
                            floatingLabelBehavior: FloatingLabelBehavior.always,
                            prefixIcon: Icon(
                              Icons.person_outline,
                              size: 20,
                            ),
                            prefixIconColor: kHintTextColor,
                            contentPadding: EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 13,
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(2),
                              borderSide:
                                  BorderSide(color: kSignInContainerColor),
                              gapPadding: 10,
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(2),
                              borderSide:
                                  BorderSide(color: kSignInContainerColor),
                              gapPadding: 10,
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(2),
                              borderSide:
                                  BorderSide(color: kSignInContainerColor),
                              gapPadding: 10,
                            ),
                          ),
                        ),
                      ),
                      //number field
                      if (widget.Phone.isEmpty)
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 25),
                          child: SizedBox(
                            height: 50,
                            child: TextFormField(
                              controller: mobileController,
                              keyboardType: TextInputType.number,
                              validator: (phone) =>
                                  phone != null && phone.length != 10
                                      ? 'Enter your correct number'
                                      : null,
                              decoration: InputDecoration(
                                hintText: 'Number',
                                hintStyle: TextStyle(
                                    color: kHintTextColor,
                                    fontSize: 18,
                                    fontWeight: FontWeight.w400),
                                floatingLabelBehavior:
                                    FloatingLabelBehavior.always,
                                prefixIcon: Icon(
                                  Icons.phone_outlined,
                                  size: 20,
                                ),
                                prefixIconColor: kHintTextColor,
                                contentPadding: EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 13,
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(2),
                                  borderSide:
                                      BorderSide(color: kSignInContainerColor),
                                  gapPadding: 10,
                                ),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(2),
                                  borderSide:
                                      BorderSide(color: kSignInContainerColor),
                                  gapPadding: 10,
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(2),
                                  borderSide:
                                      BorderSide(color: kSignInContainerColor),
                                  gapPadding: 10,
                                ),
                              ),
                            ),
                          ),
                        ),

                      GestureDetector(
                        onTap: () {
                          if (formGlobalKey.currentState!.validate()) {
                            formGlobalKey.currentState!.save();
                            _addDataInDb();
                          }
                        },
                        child: Container(
                          width: double.infinity,
                          decoration: BoxDecoration(
                            color: kSignInContainerColor,
                          ),
                          child: const Padding(
                            padding: EdgeInsets.only(top: 15, bottom: 16),
                            child: Text(
                              'Complete',
                              style: TextStyle(
                                color: Colors.white,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
