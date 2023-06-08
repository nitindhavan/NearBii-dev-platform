// ignore_for_file: prefer_const_constructors

import 'dart:developer';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:image_picker/image_picker.dart';
import 'package:nearbii/Model/notifStorage.dart';
import 'package:nearbii/constants.dart';
import 'package:nearbii/screens/auth/LoginSignUpScreen.dart';
import 'package:nearbii/screens/annual_plan/business_service_details_screen.dart';

import 'package:nearbii/screens/bottom_bar/home/drawer/bookmarks_screen.dart';
import 'package:nearbii/screens/bottom_bar/profile/edit_profile.dart';
import 'package:nearbii/screens/createEvent/addEvent/addEvent.dart';
import 'package:nearbii/services/sendNotification/registerToken/registerTopicNotificaion.dart';
import 'package:path/path.dart' as path;

import 'package:firebase_storage/firebase_storage.dart';
import 'package:velocity_x/velocity_x.dart';

bool isListBusiness = false;

class UserProfileScreen extends StatefulWidget {
  const UserProfileScreen({Key? key}) : super(key: key);

  @override
  State<UserProfileScreen> createState() => _UserProfileScreenState();
}

class _UserProfileScreenState extends State<UserProfileScreen> {
  FirebaseAuth auth = FirebaseAuth.instance;

  String? fileName;
  final _db = FirebaseFirestore.instance;

  LoadingDialog() {
    return showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            content: Row(
              children: const [
                CircularProgressIndicator(),
                SizedBox(
                  width: 10,
                ),
                Text("Loading"),
              ],
            ),
          );
        });
  }

  bool edit = false;
  Future<void> _selectProfileImageUpload(
      String inputSource, String image) async {
    final picker = ImagePicker();
    XFile? pickedImage;
    edit = true;
    try {
      pickedImage = await picker.pickImage(
          source: inputSource == 'camera'
              ? ImageSource.camera
              : ImageSource.gallery,
          imageQuality: 70);
      // final String fileName = path.basename(pickedImage!.path);
      setState(() {
        fileName = path.basename(pickedImage!.path);
      });
      File imageFile = File(pickedImage!.path);

      try {
        TaskSnapshot uploadTask = await FirebaseStorage.instance
            .ref("user/" + fileName!)
            .putFile(imageFile);
        _db
            .collection("User")
            .doc(auth.currentUser?.uid.substring(0, 20))
            .update({image: await uploadTask.ref.getDownloadURL()});
        Fluttertoast.showToast(msg: 'Uploaded');

        setState(() {});
      } on FirebaseException {
        // if (kDebugMode) {
        //   print(error);
        // }
      }
    } catch (err) {
      // if (kDebugMode) {
      //   print(err);
      // }
    }
  }

  Future<void> logout() async {
    await unsubscribeTopicity();

    FirebaseAuth.instance
        .signOut()
        .then((value) => log("loogedout", name: "checkuser"));
    await Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(
        builder: (context) => LoginSignUpScreen(loginState: true),
      ),
      (Route route) => false,
    );
  }

  var data;
  Future<void> getUserData() async {
    data = Notifcheck.userDAta;

    var b = FirebaseFirestore.instance
        .collection('User')
        .doc(auth.currentUser?.uid.substring(0, 20))
        .snapshots()
        .listen((event) {
      if (mounted) {
        setState(() {
          Notifcheck.userDAta = event.data()!;
          data = Notifcheck.userDAta;
        });
      }
      log("fetchingdatatwiceUser");
    });
  }

  @override
  void initState() {
    // TODO: implement initState
    getUserData();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Scaffold(
      body: SingleChildScrollView(
        child: data == null
            ? CircularProgressIndicator().centered()
            : Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 34, vertical: 10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      height: size.width - 150,
                      width: size.width - 68,
                      decoration:
                          BoxDecoration(borderRadius: BorderRadius.circular(5)),
                      child: Stack(
                        children: [
                          SizedBox(
                            width: size.width - 68,
                            height: size.width - 205,
                            child: Image.network(
                              data['banner'] != null
                                  ? data["banner"]
                                  : "https://firebasestorage.googleapis.com/v0/b/neabiiapp.appspot.com/o/RWD_Why-Is-My-Shopify-Store-Not-Working_Blog_v1_Header.png?alt=media&token=c7491530-7ac5-4664-82d0-4a5978d3c481",
                              fit: BoxFit.cover,
                            ),
                          ),
                          Positioned(
                            right: 12,
                            top: 12,
                            child: GestureDetector(
                              onTap: () => _showPicker(context, "banner"),
                              child: Container(
                                width: 30,
                                height: 30,
                                decoration: BoxDecoration(
                                  color: Color(0xFFFFFEE7),
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(
                                  Icons.camera_alt_outlined,
                                  size: 16,
                                ),
                              ),
                            ),
                          ),
                          Positioned(
                            bottom: 0,
                            left: 18,
                            child: Stack(
                              children: [
                                Container(
                                  height: 110,
                                  width: 110,
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    shape: BoxShape.circle,
                                  ),
                                  child: Padding(
                                    padding: const EdgeInsets.all(4.0),
                                    child: Container(
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        image: DecorationImage(
                                          image: NetworkImage(data['image']),
                                          fit: BoxFit.fill,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                                Positioned(
                                  right: 10,
                                  bottom: 0,
                                  child: GestureDetector(
                                    onTap: () {
                                      _showPicker(context, "image");
                                    },
                                    child: Container(
                                      width: 30,
                                      height: 30,
                                      decoration: BoxDecoration(
                                        color:
                                            kUserProfileImageChangeContainerColor,
                                        shape: BoxShape.circle,
                                      ),
                                      child: Icon(
                                        Icons.camera_alt_outlined,
                                        size: 16,
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
                    // Text(userId),
                    //Test purpose

                    Padding(
                      padding: const EdgeInsets.only(top: 23, bottom: 20),
                      child: Center(
                        child: Column(
                          children: [
                            Column(
                              children: [
                                Text(
                                  data['name'] ?? "",
                                  style: TextStyle(
                                    fontWeight: FontWeight.w600,
                                    fontSize: 20,
                                    color: kLoadingScreenTextColor,
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(
                              height: 26,
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              children: [
                                // GestureDetector(
                                //   onTap: () {},
                                //   child: Container(
                                //     height: 45,
                                //     width: 45,
                                //     decoration: BoxDecoration(
                                //       color: Colors.white,
                                //       border: Border.all(color: Colors.black),
                                //       shape: BoxShape.circle,
                                //     ),
                                //     child: Icon(Icons.add),
                                //   ),
                                // ),
                                GestureDetector(
                                  onTap: () => Navigator.of(context).push(
                                    MaterialPageRoute(
                                      builder: (context) => EditProfileScreen(),
                                    ),
                                  ),
                                  child: Container(
                                    height: 45,
                                    width: 45,
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      border: Border.all(color: Colors.black),
                                      shape: BoxShape.circle,
                                    ),
                                    child: Icon(Icons.edit),
                                  ),
                                ),
                                GestureDetector(
                                  onTap: () {
                                    Navigator.of(context).push(
                                      MaterialPageRoute(
                                          builder: (context) =>
                                              const BookmarksScreen()),
                                    );
                                  },
                                  child: Container(
                                    height: 45,
                                    width: 45,
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      border: Border.all(color: Colors.black),
                                      shape: BoxShape.circle,
                                    ),
                                    child:
                                        Icon(Icons.bookmark_outline_outlined),
                                  ),
                                ),

                                GestureDetector(
                                  onTap: () => showModalBottomSheet(
                                    enableDrag: true,
                                    isDismissible: false,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.vertical(
                                        top: Radius.circular(25),
                                      ),
                                    ),
                                    context: context,
                                    builder: (BuildContext context) {
                                      return Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Center(
                                            child: Padding(
                                              padding: const EdgeInsets.only(
                                                  top: 10, bottom: 46),
                                              child: Container(
                                                width: 70,
                                                height: 3,
                                                decoration: BoxDecoration(
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          100),
                                                  color: kSignUpContainerColor,
                                                ),
                                              ),
                                            ),
                                          ),
                                          Padding(
                                            padding: const EdgeInsets.symmetric(
                                                horizontal: 15),
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                GestureDetector(
                                                  onTap: () {
                                                    Navigator.of(context).push(
                                                      MaterialPageRoute(
                                                        builder: (context) =>
                                                            BusinessServicesDetailsScreen(),
                                                      ),
                                                    );
                                                    // setState(() {
                                                    //   isListBusiness =
                                                    //       !isListBusiness;
                                                    // });
                                                    // Navigator.pop(context);
                                                  },
                                                  child: Row(
                                                    children: [
                                                      SizedBox(
                                                        width: 2,
                                                      ),
                                                      Icon(
                                                        Icons.business,
                                                        color: Colors.black54,
                                                      ),
                                                      SizedBox(
                                                        width: 12,
                                                      ),
                                                      Text(
                                                        "Register Business/Service",
                                                        style: TextStyle(
                                                          fontWeight:
                                                              FontWeight.w400,
                                                          fontSize: 14,
                                                          color:
                                                              kLoadingScreenTextColor,
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                                Padding(
                                                  padding: const EdgeInsets
                                                      .symmetric(vertical: 15),
                                                  child: Container(
                                                    height: 0.5,
                                                    color: kDrawerDividerColor,
                                                  ),
                                                ),
                                                GestureDetector(
                                                  onTap: () =>
                                                      Navigator.of(context)
                                                          .push(
                                                    MaterialPageRoute(
                                                      builder: (context) =>
                                                          AddEvent(),
                                                    ),
                                                  ),
                                                  child: Row(
                                                    children: [
                                                      SizedBox(
                                                        width: 2,
                                                      ),
                                                      Icon(
                                                        Icons.event,
                                                        color: Colors.black54,
                                                      ),
                                                      SizedBox(
                                                        width: 11,
                                                      ),
                                                      Text(
                                                        "Post an Event",
                                                        style: TextStyle(
                                                          fontWeight:
                                                              FontWeight.w400,
                                                          fontSize: 14,
                                                          color:
                                                              kLoadingScreenTextColor,
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                                Padding(
                                                  padding: const EdgeInsets
                                                      .symmetric(vertical: 15),
                                                  child: Container(
                                                    height: 0.5,
                                                    color: kDrawerDividerColor,
                                                  ),
                                                ),
                                                GestureDetector(
                                                  onTap: () async {
                                                    logout();
                                                  },
                                                  child: Row(
                                                    children: [
                                                      Icon(
                                                        Icons.logout,
                                                        color: Colors.black54,
                                                      ),
                                                      SizedBox(
                                                        width: 8,
                                                      ),
                                                      Text(
                                                        "Logout",
                                                        style: TextStyle(
                                                          fontWeight:
                                                              FontWeight.w400,
                                                          fontSize: 14,
                                                          color:
                                                              kLoadingScreenTextColor,
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                                Padding(
                                                  padding: const EdgeInsets
                                                      .symmetric(vertical: 15),
                                                  child: Container(
                                                    height: 0.5,
                                                    color: kDrawerDividerColor,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      );
                                    },
                                  ),
                                  child: Container(
                                    height: 45,
                                    width: 45,
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      border: Border.all(color: Colors.black),
                                      shape: BoxShape.circle,
                                    ),
                                    child: Icon(Icons.more_horiz),
                                  ),
                                ),
                              ],
                            ),
                            Padding(
                              padding: const EdgeInsets.only(
                                top: 20,
                              ),
                              child: Container(
                                height: 1,
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    begin: Alignment.topLeft,
                                    end: Alignment.topRight,
                                    colors: const [
                                      Color(0x116C6464),
                                      Color(0xFFE7E7E7),
                                      Color(0x116C6464),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    isListBusiness
                        ? SizedBox(
                            height: 550,
                            child: ListView.separated(
                              itemCount: 3,
                              itemBuilder: (context, index) {
                                return Column(
                                  children: [
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.start,
                                      children: [
                                        CircleAvatar(
                                          radius: 28,
                                          backgroundImage: AssetImage(
                                              'assets/images/profile/vendor_profile/vendor_profile_pic.png'),
                                        ),
                                        SizedBox(
                                          width: 9,
                                        ),
                                        Text(
                                          "Business ${index + 1}",
                                          style: TextStyle(
                                            fontWeight: FontWeight.w400,
                                            fontSize: 16,
                                            color: Colors.black,
                                          ),
                                        ),
                                      ],
                                    ),
                                    SizedBox(
                                      height: 230,
                                      child: Padding(
                                        padding: const EdgeInsets.fromLTRB(
                                            50, 20, 0, 0),
                                        child: ListView.separated(
                                          itemCount: 3,
                                          itemBuilder: (context, index) {
                                            return Column(
                                              children: [
                                                Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.start,
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    CircleAvatar(
                                                      radius: 15,
                                                      backgroundImage: AssetImage(
                                                          'assets/images/profile/user_profile/user_profile_image.png'),
                                                    ),
                                                    SizedBox(
                                                      width: 9,
                                                    ),
                                                    Column(
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .start,
                                                      children: [
                                                        Text(
                                                          "User123",
                                                          style: TextStyle(
                                                            fontWeight:
                                                                FontWeight.w400,
                                                            fontSize: 13,
                                                            color:
                                                                kLoadingScreenTextColor,
                                                          ),
                                                        ),
                                                        Padding(
                                                          padding:
                                                              const EdgeInsets
                                                                      .only(
                                                                  top: 3,
                                                                  bottom: 10),
                                                          child: Row(
                                                            children: [
                                                              Text(
                                                                "5.0",
                                                                style:
                                                                    TextStyle(
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .w700,
                                                                  fontSize: 16,
                                                                  color:
                                                                      kLoadingScreenTextColor,
                                                                ),
                                                              ),
                                                              SizedBox(
                                                                width: 5,
                                                              ),
                                                              RatingBar(
                                                                initialRating:
                                                                    5.0,
                                                                itemSize: 17,
                                                                direction: Axis
                                                                    .horizontal,
                                                                allowHalfRating:
                                                                    true,
                                                                itemCount: 5,
                                                                glowColor:
                                                                    kCreditPointScaffoldBackgroundColor,
                                                                ratingWidget:
                                                                    RatingWidget(
                                                                  full: Icon(
                                                                    Icons.star,
                                                                    color:
                                                                        kSelectedStarColor,
                                                                  ),
                                                                  half: Icon(
                                                                    Icons
                                                                        .star_half,
                                                                    color:
                                                                        kSelectedStarColor,
                                                                  ),
                                                                  empty: Icon(
                                                                    Icons
                                                                        .star_border_outlined,
                                                                    color:
                                                                        kWalletLightTextColor,
                                                                  ),
                                                                ),
                                                                itemPadding: EdgeInsets
                                                                    .symmetric(
                                                                        horizontal:
                                                                            0),
                                                                onRatingUpdate:
                                                                    (rating) {
                                                                  print(rating);
                                                                },
                                                              ),
                                                            ],
                                                          ),
                                                        ),
                                                        Text(
                                                          "Amazing work! Totally satisfied.",
                                                          style: TextStyle(
                                                            fontWeight:
                                                                FontWeight.w400,
                                                            fontSize: 13,
                                                            color:
                                                                kLoadingScreenTextColor,
                                                          ),
                                                        ),
                                                        SizedBox(
                                                          height: 12,
                                                        ),
                                                        Text(
                                                          "Edit",
                                                          style: TextStyle(
                                                            fontWeight:
                                                                FontWeight.w400,
                                                            fontSize: 12,
                                                            color:
                                                                kSplashScreenDescriptionColor,
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                    Spacer(),
                                                    Icon(
                                                      Icons.favorite_outline,
                                                      size: 10,
                                                      color:
                                                          kSplashScreenDescriptionColor,
                                                    ),
                                                  ],
                                                ),
                                              ],
                                            );
                                          },
                                          separatorBuilder: (context, index) =>
                                              SizedBox(
                                            height: 34,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                );
                              },
                              separatorBuilder: (context, index) => Padding(
                                padding:
                                    const EdgeInsets.only(top: 21, bottom: 17),
                                child: Container(
                                  height: 1,
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      begin: Alignment.topLeft,
                                      end: Alignment.topRight,
                                      colors: const [
                                        Color(0x116C6464),
                                        Color(0xFFE7E7E7),
                                        Color(0x116C6464),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          )
                        : SizedBox(
                            height: 0,
                          ),
                  ],
                ),
              ),
      ),
    );
  }

  void _showPicker(context, String image) {
    showModalBottomSheet(
        context: context,
        builder: (BuildContext bc) {
          return SafeArea(
            child: Container(
              child: Wrap(
                children: <Widget>[
                  ListTile(
                      leading: const Icon(Icons.photo_library),
                      title: const Text('Gallery'),
                      onTap: () {
                        _selectProfileImageUpload("Gallery", image);
                        Navigator.of(context).pop();
                      }),
                  ListTile(
                    leading: const Icon(Icons.photo_camera),
                    title: const Text('Camera'),
                    onTap: () {
                      _selectProfileImageUpload("camera", image);
                      Navigator.of(context).pop();
                    },
                  ),
                ],
              ),
            ),
          );
        });
  }
}
