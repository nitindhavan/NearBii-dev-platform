// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables

import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'package:avatar_glow/avatar_glow.dart';
import 'package:flutter/foundation.dart';
import 'package:nearbii/Model/ServiceModel.dart';
import 'package:nearbii/components/shimmer.dart';
import 'package:nearbii/services/GenerateCoupan.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:animate_icons/animate_icons.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:nearbii/Model/catModel.dart';
import 'package:nearbii/Model/notifStorage.dart';
import 'package:nearbii/constants.dart';
import 'package:nearbii/screens/annual_plan/renew_annual_plan.dart';
import 'package:nearbii/screens/bottom_bar/home/drawer/about_us_screen.dart';
import 'package:nearbii/screens/bottom_bar/home/drawer/advertise/advertise_screen.dart';
import 'package:nearbii/screens/bottom_bar/home/drawer/bookmarks_screen.dart';
import 'package:nearbii/screens/bottom_bar/home/drawer/privacy_policy_screen.dart';
import 'package:nearbii/screens/bottom_bar/home/drawer/settings/settings_screen.dart';
import 'package:nearbii/screens/bottom_bar/home/drawer/terms_and_conditions_screen.dart';
import 'package:nearbii/screens/bottom_bar/master_screen.dart';
import 'package:nearbii/screens/notifications_screen.dart';
import 'package:nearbii/screens/service_slider/more_services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:velocity_x/velocity_x.dart';
import 'package:swipe_refresh/swipe_refresh.dart';
import '../../../Model/BannerModel.dart';
import '../../../components/search_bar.dart';
import '../../../services/offerService/getOffers.dart';
import '../../service_slider/searchvendor.dart';
import '../../service_slider/services_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int currentPage = 0;
  final controller = PageController();
  String name = '';
  String image = '';
  String number = '';
  String address = '';

  final uid = FirebaseAuth.instance.currentUser!.uid.substring(0, 20);

  bool isMember = false;

  var anime = AnimateIconController();
  final _controller = StreamController<SwipeRefreshState>.broadcast();

  Stream<SwipeRefreshState> get _stream => _controller.stream;
  @override
  void initState() {
    refersh();
    super.initState();
  }

  refersh({bool refersh = true}) async {
    _controller.sink.add(SwipeRefreshState.loading);
    log("init");
    await _fetchUserData(refersh: refersh);
    await getServices(refersh: refersh);
    getAddressFromLatLong();
    //await getCategories(refersh: refersh);

    await getHomeIcons(refersh: refersh);
    await getBanners(refersh: refersh);
    _controller.sink.add(SwipeRefreshState.hidden);

    setState(() {});
  }

  swipe() {
    refersh();
  }

  late DateTime end;

  List<BannerModel> banners = [];

  List<ServiceModel> services = [];

  List<ServiceModel> homeIcons = [];

  List<CategoriesModel> categories = [];

  Future<void> getAddressFromLatLong() async {
    Position position = await Geolocator.getCurrentPosition();
    List<Placemark> placemarks = await placemarkFromCoordinates(
        position.latitude, position.longitude,
        localeIdentifier: "en_US");

    Placemark place = placemarks[0];
    address = '${place.subLocality}, ${place.locality}';

    SharedPreferences session = await SharedPreferences.getInstance();
    var loc = {"lat": position.latitude, "long": position.longitude};
    session.setString("userLocation", place.locality.toString());
    session.setString("pincode", place.postalCode.toString());
    session.setString("LastLocation", jsonEncode(loc));
    setState(() {});
  }

  _fetchUserData({bool refersh = false}) async {
    Notifcheck.userDAta = await Notifcheck.api.fetchUserData(refresh: refersh);

    print('name ${Notifcheck.userDAta!['name']}');
    name = Notifcheck.userDAta!['name'];
    image = Notifcheck.userDAta!['image'];
    number = Notifcheck.userDAta!['phone'];

    if (Notifcheck.userDAta!['joinDate'] != null) {
      Map<String, dynamic> memberData = Notifcheck.userDAta!["member"];

      DateTime memDate =
          DateTime.fromMillisecondsSinceEpoch(memberData["endDate"]);
      // DateTime endDate = memberData["endDate"].toDate();

      var now = DateTime.now();
      end = memDate;
      if (memDate.difference(now).inMilliseconds > 0 &&
          memberData["isMember"]) {
        // Fluttertoast.showToast(msg: "Yes you are member");

        isMember = true;
      } else {
        changeToUser();
        goToUpdateMemberhip();
        Fluttertoast.showToast(msg: "Memberhip Expied");
      }
    }
  }

  getBanners({bool refersh = false}) async {
    banners = await Notifcheck.api.getBanners(refersh: refersh);
  }

  getServices({bool refersh = false}) async {
    services = await Notifcheck.api.getServices(refersh: refersh);
  }

  Future<void> getHomeIcons({bool refersh = false}) async {
    homeIcons = await Notifcheck.api.getHomeIconData(refersh: refersh);
  }

  getCategories({bool refersh = false}) async {
    categories = await Notifcheck.api.getCategories(refersh: refersh);
  }

  _gotoService(ServiceModel data) {
    Navigator.push(context,
        MaterialPageRoute(builder: (context) => MoreServices(index: data)));
  }

  _sendMail() async {
    // Android and iOS
    const uri = 'mailto:connect@neabii.com?subject=Greetings&body=Hello%20User';
    if (await canLaunch(uri)) {
      await launch(uri);
    } else {
      throw 'Could not launch $uri';
    }
  }

  changeToUser() async {
    late FirebaseFirestore db;
    db = FirebaseFirestore.instance;

    Map<String, dynamic> userdata = {};

    userdata["type"] = "User";

    Map<String, dynamic> member = {};

    member["isMember"] = false;
    member["joinDate"] = Timestamp.now();

    userdata["member"] = member;

    db
        .collection("User")
        .doc(uid)
        .set(userdata, SetOptions(merge: true))
        .then((value) {
      Fluttertoast.showToast(msg: "Membership Removed");
    });
  }

  goToUpdateMemberhip() {
    Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (context) {
      return RenewAnnualPlanScreen(
        check: false,
        end: end,
      );
    }), (route) => false);
  }

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;

    bool _allow = true;
    String category = "";
    return Material(
      child: WillPopScope(
        onWillPop: () async {
          return Future.value(_allow);
        },
        child: SafeArea(
          child: Scaffold(
              appBar: AppBar(
                elevation: 0,
                backgroundColor: Colors.white,
                foregroundColor: Colors.black,
                actions: [
                  Spacer(),
                  SizedBox(
                    width: 65,
                  ),
                  Center(
                      child: Image.asset(
                    'assets/images/authentication/logo.png',
                    color: Colors.black,
                    height: 80,
                  )).onInkTap(() async {
                    if (kDebugMode) {
                      Navigator.of(context).push(MaterialPageRoute(
                          builder: (context) => GenerateCoupan()));
                    }
                    // await sendNotificationWallet(uid, 20, "50");
                    // await Future.delayed(Duration(seconds: 5));
                    // await sendNotiicationAd("headline6", image);
                    // await Future.delayed(Duration(seconds: 5));
                    // await sendNotiicationByCity(
                    //     "test Event", "Jhansi", uid, "event");
                    // await Future.delayed(Duration(seconds: 5));
                    // await sendNotiicationByPin(
                    //     "test Offer",
                    //     FirebaseAuth.instance.currentUser!.uid.substring(0, 20),
                    //     "offer",
                    //     name);
                  }),
                  Spacer(),
                  GestureDetector(
                      onTap: () => Navigator.of(context).push(MaterialPageRoute(
                          builder: (context) => NotificationsScreen())),
                      child: ValueListenableBuilder(
                        builder:
                            (BuildContext context, bool value, Widget? child) {
                          return Image.asset(
                            value ? "assets/notif.gif" : "assets/notif.png",
                            height: 25,
                            width: 25,
                          );
                        },
                        valueListenable: Notifcheck.bell,
                      )),
                  SizedBox(
                    width: 25,
                  ),
                ],
              ),
              drawer: Drawer(
                child: Column(
                  children: [
                    Container(
                      color: kSignUpContainerColor,
                      child: Padding(
                        padding: const EdgeInsets.only(top: 30.5, bottom: 30),
                        child: Row(
                          children: [
                            SizedBox(
                              width: 28,
                            ),
                            InkWell(
                              onTap: () {
                                Navigator.of(context).pushAndRemoveUntil(
                                    MaterialPageRoute(builder: ((context) {
                                  return MasterPage(
                                    currentIndex: 4,
                                  );
                                })), (route) => false);
                              },
                              child: CircleAvatar(
                                radius: 24,
                                backgroundImage: NetworkImage(
                                  image.isNotEmptyAndNotNull
                                      ? image
                                      : ' https://firebasestorage.googleapis.com/v0/b/neabiiapp.appspot.com/o/360_F_64678017_zUpiZFjj04cnLri7oADnyMH0XBYyQghG.jpg?alt=media&token=27052833-5800-4721-9429-d21c4a3eac1b',
                                ),
                              ),
                            ),
                            SizedBox(
                              width: 10,
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                InkWell(
                                  onTap: () {
                                    Navigator.of(context).pushAndRemoveUntil(
                                        MaterialPageRoute(builder: ((context) {
                                      return MasterPage(
                                        currentIndex: 0,
                                      );
                                    })), (route) => false);
                                  },
                                  child: Text(
                                    name.isNotEmptyAndNotNull ? name : "Guest",
                                    style: TextStyle(
                                      fontWeight: FontWeight.w600,
                                      fontSize: 16,
                                      color: kLoadingScreenTextColor,
                                    ),
                                  ),
                                ),
                                Text(
                                  number.isEmptyOrNull
                                      ? "<Guest>"
                                      : number.toString(),
                                  style: TextStyle(
                                    fontWeight: FontWeight.w400,
                                    fontSize: 14,
                                    color: Color(0xFF777777),
                                  ),
                                )
                              ],
                            ),
                            SizedBox(
                              width: width - 292,
                            ),
                          ],
                        ),
                      ),
                    ),
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.only(left: 20, right: 33),
                        height: double.infinity,
                        width: double.infinity,
                        color: Colors.white,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            //advertise
                            if (Notifcheck.vendor)
                              Row(
                                children: [
                                  SizedBox(
                                    width: 2,
                                  ),
                                  Icon(
                                    Icons.ads_click,
                                    color: Colors.grey,
                                    size: 20,
                                  ).pOnly(right: 10),
                                  TextButton(
                                    onPressed: () {
                                      Navigator.of(context).push(
                                        MaterialPageRoute(
                                          builder: (context) =>
                                              const AdvertiseScreen(),
                                        ),
                                      );
                                    },
                                    child: Text(
                                      "Advertise",
                                      style: TextStyle(
                                        fontWeight: FontWeight.w400,
                                        fontSize: 14,
                                        color: kLoadingScreenTextColor,
                                      ),
                                    ),
                                  ),
                                ],
                              ),

                            //Bookmarks
                            Row(
                              children: [
                                SizedBox(
                                  width: 2,
                                ),
                                Icon(
                                  Icons.bookmark,
                                  color: Colors.grey,
                                  size: 20,
                                ).pOnly(right: 10),
                                TextButton(
                                  onPressed: () {
                                    Navigator.of(context).push(
                                      MaterialPageRoute(
                                          builder: (context) =>
                                              const BookmarksScreen()),
                                    );
                                  },
                                  child: Text(
                                    "Bookmarks",
                                    style: TextStyle(
                                      fontWeight: FontWeight.w400,
                                      fontSize: 14,
                                      color: kLoadingScreenTextColor,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            //Settings
                            Row(
                              children: [
                                SizedBox(
                                  width: 2,
                                ),
                                Icon(
                                  Icons.settings,
                                  size: 20,
                                  color: Color(0x9932363D),
                                ).pOnly(right: 10),
                                TextButton(
                                  onPressed: () {
                                    Navigator.of(context).push(
                                      MaterialPageRoute(
                                          builder: (context) =>
                                              const SettingsScreen()),
                                    );
                                  },
                                  child: Text(
                                    "Settings",
                                    style: TextStyle(
                                      fontWeight: FontWeight.w400,
                                      fontSize: 14,
                                      color: kLoadingScreenTextColor,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            //Privacy
                            if (false)
                              Row(
                                children: [
                                  SizedBox(
                                    width: 2,
                                  ),
                                  Icon(
                                    Icons.verified_user_outlined,
                                    size: 20,
                                    color: Color(0x9932363D),
                                  ).pOnly(right: 10),
                                  TextButton(
                                    onPressed: () {
                                      Navigator.of(context).push(
                                        MaterialPageRoute(
                                            builder: (context) =>
                                                const PrivacyPolicyScreen()),
                                      );
                                    },
                                    child: Text(
                                      "Privacy",
                                      style: TextStyle(
                                        fontWeight: FontWeight.w400,
                                        fontSize: 14,
                                        color: kLoadingScreenTextColor,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            //Terms & Conditions
                            if (false)
                              Row(
                                children: [
                                  SizedBox(
                                    width: 2,
                                  ),
                                  Icon(
                                    Icons.padding_rounded,
                                    size: 20,
                                    color: Colors.grey,
                                  ).pOnly(right: 10),
                                  TextButton(
                                    onPressed: () {
                                      Navigator.of(context).push(
                                        MaterialPageRoute(
                                            builder: (context) =>
                                                const TermsAndConditionsScreen()),
                                      );
                                    },
                                    child: Text(
                                      "Terms & Conditions",
                                      style: TextStyle(
                                        fontWeight: FontWeight.w400,
                                        fontSize: 14,
                                        color: kLoadingScreenTextColor,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            //Rate us
                            Row(
                              children: [
                                SizedBox(
                                  width: 2,
                                ),
                                Icon(
                                  Icons.star_border,
                                  size: 20,
                                  color: Colors.grey,
                                ).pOnly(right: 10),
                                TextButton(
                                  onPressed: () {
                                    //navigate to playstore
                                    launchUrl(Uri.parse(
                                        "https://play.google.com/store/apps/details?id=com.shellcode.nearbii"));
                                  },
                                  child: Text(
                                    "Rate us",
                                    style: TextStyle(
                                      fontWeight: FontWeight.w400,
                                      fontSize: 14,
                                      color: kLoadingScreenTextColor,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            //About us
                            Row(
                              children: [
                                SizedBox(
                                  width: 2,
                                ),
                                Icon(
                                  Icons.error_outline,
                                  size: 20,
                                  color: Color(0x9932363D),
                                ).pOnly(right: 10),
                                TextButton(
                                  onPressed: () {
                                    Navigator.of(context).push(
                                      MaterialPageRoute(
                                          builder: (context) =>
                                              const AboutUsScreen()),
                                    );
                                  },
                                  child: Text(
                                    "About us",
                                    style: TextStyle(
                                      fontWeight: FontWeight.w400,
                                      fontSize: 14,
                                      color: kLoadingScreenTextColor,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                    Column(
                      children: [
                        "Contact Us At".text.make().py2(),
                        "connect@nearbii.com"
                            .text
                            .underline
                            .color(Colors.lightBlue)
                            .make()
                            .onInkTap(() {
                          _sendMail();
                        })
                      ],
                    ).py16()
                  ],
                ),
              ),
              body: SwipeRefresh.builder(
                itemCount: 1,
                stateStream: _stream,
                onRefresh: swipe,
                shrinkWrap: true,
                padding: const EdgeInsets.symmetric(vertical: 10),
                itemBuilder: (BuildContext context, int index) {
                  return Container(
                    color: Colors.white,
                    child: SingleChildScrollView(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Padding(
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    "Hi, ${name ?? "Guest"}!",
                                    style: TextStyle(
                                      fontWeight: FontWeight.w400,
                                      fontSize: 20,
                                      color: kLoadingScreenTextColor,
                                    ),
                                  ),
                                  Text(
                                    address,
                                    style: TextStyle(
                                      fontWeight: FontWeight.w400,
                                      fontSize: 12,
                                      color: Color(0xFF929292),
                                    ),
                                  ),
                                  GestureDetector(
                                    onTap: () {
                                      Navigator.of(context).push(
                                          MaterialPageRoute(
                                              builder: (context) =>
                                                  SearchVendor(category)));
                                    },
                                    child: Stack(
                                      alignment: Alignment.center,
                                      children: [
                                        const Align(
                                          alignment: Alignment.centerLeft,
                                          child: Hero(
                                            tag: "searchIcon",
                                            child: Icon(
                                              Icons.search,
                                              color: Colors.black,
                                            ),
                                          ),
                                        ).pOnly(left: 5, right: 5),
                                        TextField(
                                          enabled: false,
                                          decoration:
                                              kTextFieldDecoration.copyWith(
                                                  contentPadding:
                                                      EdgeInsets.only(left: 30),
                                                  hintText:
                                                      'Get Your Vendors NearBii',
                                                  hintStyle: const TextStyle(
                                                      fontSize: 14)),
                                          onChanged: (value) {},
                                          onEditingComplete: () {},
                                        ),
                                        Align(
                                          alignment: Alignment.bottomRight,
                                          child: SizedBox(
                                            height: 30,
                                            width: 50,
                                            child: AvatarGlow(
                                                glowColor: Colors.amber,
                                                duration: const Duration(
                                                    milliseconds: 2000),
                                                repeat: true,
                                                repeatPauseDuration:
                                                    const Duration(
                                                        milliseconds: 100),
                                                endRadius: 100,
                                                child: Icon(Icons.mic_off)),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ).pOnly(top: 10),

                                  //services
                                  Padding(
                                    padding: const EdgeInsets.only(
                                        top: 25, bottom: 18),
                                    child: Row(
                                      children: [
                                        Text(
                                          "Services",
                                          style: TextStyle(
                                            fontWeight: FontWeight.w600,
                                            fontSize: 20,
                                            color: kLoadingScreenTextColor,
                                          ),
                                        ),
                                        Spacer(),
                                        Row(
                                          children: [
                                            Text(
                                              "See All",
                                              style: TextStyle(
                                                fontWeight: FontWeight.w600,
                                                fontSize: 13,
                                                color: kLoadingScreenTextColor,
                                              ),
                                            ),
                                            SizedBox(
                                              width: 10,
                                            ),
                                            Icon(
                                              Icons.arrow_forward_ios,
                                              size: 12,
                                            )
                                          ],
                                        ).onInkTap(() {
                                          Navigator.of(context).push(
                                              MaterialPageRoute(
                                                  builder: (context) =>
                                                      ServiceScreen()));
                                        })
                                      ],
                                    ),
                                  ),
                                  homeIcons.isNotEmpty
                                      ? Column(
                                          children: [
                                            Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.spaceEvenly,
                                              children: [
                                                SizedBox(
                                                  width: width - 40,
                                                  height: 80,
                                                  child: ListView.separated(
                                                    scrollDirection:
                                                        Axis.horizontal,
                                                    itemCount:
                                                        homeIcons.length ~/ 2,
                                                    shrinkWrap: true,
                                                    itemBuilder:
                                                        (context, index) {
                                                      var iconData =
                                                          homeIcons[index];
                                                      var img = iconData.image;

                                                      return InkWell(
                                                        onTap: () {
                                                          _gotoService(
                                                              iconData);
                                                        },
                                                        child: Column(
                                                          crossAxisAlignment:
                                                              CrossAxisAlignment
                                                                  .center,
                                                          children: [
                                                            CircleAvatar(
                                                              backgroundColor:
                                                                  kHomeScreenServicesContainerColor,
                                                              radius:
                                                                  width / 13.06,
                                                              child:
                                                                  Image.network(
                                                                img,
                                                                fit: BoxFit
                                                                    .cover,
                                                              ),
                                                            ),
                                                            SizedBox(
                                                              width: 70,
                                                              child: Text(
                                                                iconData.id,
                                                                textAlign:
                                                                    TextAlign
                                                                        .center,
                                                                overflow:
                                                                    TextOverflow
                                                                        .ellipsis,
                                                                style:
                                                                    TextStyle(
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .w400,
                                                                  fontSize: 14,
                                                                  color:
                                                                      kLoadingScreenTextColor,
                                                                ),
                                                              ),
                                                            ),
                                                          ],
                                                        ),
                                                      );
                                                    },
                                                    separatorBuilder:
                                                        (context, index) =>
                                                            SizedBox(
                                                      width: 15,
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                            Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.spaceEvenly,
                                              children: [
                                                SizedBox(
                                                  width: width - 40,
                                                  height: 80,
                                                  child: ListView.separated(
                                                    scrollDirection:
                                                        Axis.horizontal,
                                                    itemCount: homeIcons
                                                            .length -
                                                        (homeIcons.length ~/ 2),
                                                    shrinkWrap: true,
                                                    itemBuilder:
                                                        (context, index) {
                                                      var iconData = homeIcons[
                                                          index +
                                                              (homeIcons
                                                                      .length ~/
                                                                  2)];
                                                      var img = iconData.image;
                                                      log((index +
                                                              (homeIcons
                                                                      .length ~/
                                                                  2))
                                                          .toString());

                                                      return InkWell(
                                                        onTap: () {
                                                          {
                                                            _gotoService(
                                                                iconData);
                                                          }
                                                        },
                                                        child: Column(
                                                          crossAxisAlignment:
                                                              CrossAxisAlignment
                                                                  .center,
                                                          children: [
                                                            CircleAvatar(
                                                              backgroundColor:
                                                                  kHomeScreenServicesContainerColor,
                                                              radius:
                                                                  width / 13.06,
                                                              child:
                                                                  Image.network(
                                                                img,
                                                                fit:
                                                                    BoxFit.fill,
                                                              ),
                                                            ),
                                                            SizedBox(
                                                              width: 70,
                                                              child: Text(
                                                                iconData.id,
                                                                textAlign:
                                                                    TextAlign
                                                                        .center,
                                                                overflow:
                                                                    TextOverflow
                                                                        .ellipsis,
                                                                style:
                                                                    TextStyle(
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .w400,
                                                                  fontSize: 14,
                                                                  color:
                                                                      kLoadingScreenTextColor,
                                                                ),
                                                              ),
                                                            ),
                                                          ],
                                                        ),
                                                      );
                                                    },
                                                    separatorBuilder:
                                                        (context, index) =>
                                                            SizedBox(
                                                      width: 15,
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ],
                                        )
                                      : ShimmerWidgetServices().centered()
                                ],
                              ),
                            ),
                            SizedBox(
                              height: 200,
                              child: getOfferPlates(controller, context),
                            ),
                            // Row(
                            //   children: [
                            //     Text(
                            //       "Categories",
                            //       style: TextStyle(
                            //         fontWeight: FontWeight.w600,
                            //         fontSize: 20,
                            //         color: kLoadingScreenTextColor,
                            //       ),
                            //     ),
                            //     Spacer(),
                            //     GestureDetector(
                            //       onTap: () => Navigator.of(context).push(
                            //           MaterialPageRoute(
                            //               builder: (context) =>
                            //                   CategoriesScreen())),
                            //       child: Row(
                            //         children: [
                            //           Text(
                            //             "See All",
                            //             style: TextStyle(
                            //               fontWeight: FontWeight.w600,
                            //               fontSize: 13,
                            //               color: kLoadingScreenTextColor,
                            //             ),
                            //           ),
                            //           SizedBox(
                            //             width: 10,
                            //           ),
                            //           Icon(
                            //             Icons.arrow_forward_ios,
                            //             size: 12,
                            //           )
                            //         ],
                            //       ),
                            //     )
                            //   ],
                            // ),
                            // SizedBox(
                            //   height: 16,
                            // ),
                            // categories.isNotEmpty
                            //     ? SizedBox(
                            //         height: 150,
                            //         child: Row(
                            //           children: [
                            //             ListView.builder(
                            //               controller: ScrollController(),
                            //               shrinkWrap: true,
                            //               scrollDirection: Axis.horizontal,
                            //               itemBuilder: (context, index) {
                            //                 var item = categories[index];
                            //                 return Container(
                            //                   width: 90,
                            //                   height: 120,
                            //                   decoration: BoxDecoration(
                            //                     boxShadow: [
                            //                       BoxShadow(
                            //                         color: Colors.black26,
                            //                         offset: Offset(1, 1),
                            //                         blurRadius: 2,
                            //                       ),
                            //                     ],
                            //                     image: DecorationImage(
                            //                         image: NetworkImage(
                            //                             item.image),
                            //                         fit: BoxFit.fill),
                            //                     borderRadius:
                            //                         BorderRadius.circular(10),
                            //                     gradient: LinearGradient(
                            //                       begin: Alignment.topLeft,
                            //                       end: Alignment.bottomRight,
                            //                       colors: [
                            //                         Color(0xffffeb3b),
                            //                         Color(0xffF57F17),
                            //                         Color(0xfff9a825),
                            //                         Color(0xff403A3A),
                            //                       ],
                            //                     ),
                            //                   ),
                            //                   child: Column(
                            //                     mainAxisAlignment:
                            //                         MainAxisAlignment.end,
                            //                     crossAxisAlignment:
                            //                         CrossAxisAlignment.center,
                            //                     children: [
                            //                       Container(
                            //                         height: 14,
                            //                         width: 90,
                            //                         color: Colors.white,
                            //                         child: Center(
                            //                           child: Text(
                            //                             item.name,
                            //                             style: TextStyle(
                            //                                 color: Colors.black,
                            //                                 fontSize: 12,
                            //                                 fontWeight:
                            //                                     FontWeight
                            //                                         .w600),
                            //                           ),
                            //                         ),
                            //                       ),
                            //                     ],
                            //                   ),
                            //                 ).onInkTap(() {
                            //                   Navigator.of(context).push(
                            //                     MaterialPageRoute(
                            //                         builder: (context) =>
                            //                             SearchVendor(
                            //                                 item.name)),
                            //                   );
                            //                 }).pOnly(bottom: 2, left: 10);
                            //               },
                            //               itemCount: categories.length,
                            //             ).expand(),
                            //           ],
                            //         ),
                            //       )
                            //     : ShimmerWidgetCategories().centered(),
                            // SizedBox(
                            //   height: 28,
                            // ),
                            services.isNotEmpty
                                ? ListView.builder(
                                        physics: NeverScrollableScrollPhysics(),
                                        shrinkWrap: true,
                                        itemBuilder: ((context, index) {
                                          var service = services[index];
                                          if (service.order == -1) {
                                            return Container();
                                          }

                                          List<Subcategory> sub = [];
                                          for (var ele in service.subcategory) {
                                            if (ele.order != -1) {
                                              sub.add(ele);
                                            }
                                          }
                                          if (sub.isEmpty) {
                                            return Container();
                                          }

                                          return Column(
                                            children: [
                                              Row(
                                                children: [
                                                  service.id.text
                                                      .fontWeight(
                                                          FontWeight.w600)
                                                      .xl2
                                                      .make(),
                                                  Spacer(),
                                                  "See All".text.bold.make(),
                                                  Icon(
                                                    Icons
                                                        .arrow_forward_ios_rounded,
                                                    size: 10,
                                                  )
                                                ],
                                              ).onInkTap(() {
                                                _gotoService(service);
                                              }),
                                              GridView.builder(
                                                  itemCount: sub.length > 4
                                                      ? 4
                                                      : sub.length,
                                                  shrinkWrap: true,
                                                  physics:
                                                      NeverScrollableScrollPhysics(),
                                                  gridDelegate:
                                                      SliverGridDelegateWithFixedCrossAxisCount(
                                                          crossAxisCount: 2),
                                                  itemBuilder:
                                                      ((context, index) {
                                                    print("carding");
                                                    Subcategory subcat =
                                                        sub[index];
                                                    return Container(
                                                      decoration: BoxDecoration(
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(10),
                                                          boxShadow: [
                                                            BoxShadow(
                                                              color:
                                                                  Colors.grey,
                                                              offset: Offset(
                                                                  0.0,
                                                                  1.0), //(x,y)
                                                              blurRadius: 6.0,
                                                            ),
                                                          ],
                                                          image: DecorationImage(
                                                              fit: BoxFit.cover,
                                                              image:
                                                                  NetworkImage(
                                                                      subcat
                                                                          .bg))),
                                                      child: Column(
                                                        mainAxisAlignment:
                                                            MainAxisAlignment
                                                                .end,
                                                        children: [
                                                          Container(
                                                            color: Colors.white,
                                                            child: Row(
                                                              mainAxisAlignment:
                                                                  MainAxisAlignment
                                                                      .start,
                                                              children: [
                                                                SizedBox(
                                                                  width: 140,
                                                                  child: subcat
                                                                      .title
                                                                      .toString()
                                                                      .text
                                                                      .ellipsis
                                                                      .lg
                                                                      .color(Colors
                                                                          .black)
                                                                      .bold
                                                                      .make()
                                                                      .pOnly(
                                                                          bottom:
                                                                              6,
                                                                          left:
                                                                              6),
                                                                ),
                                                              ],
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                    ).onInkTap(() {
                                                      Navigator.of(context).push(
                                                          MaterialPageRoute(
                                                              builder: (context) =>
                                                                  SearchVendor(
                                                                      subcat
                                                                          .title)));
                                                    }).p8();
                                                  })),
                                            ],
                                          ).centered();
                                        }),
                                        itemCount: services.length)
                                    .pOnly(bottom: 40)
                                : ShimmerServices().centered(),
                            banners.isNotEmpty
                                ? ListView.builder(
                                    shrinkWrap: true,
                                    physics: NeverScrollableScrollPhysics(),
                                    itemBuilder: ((context, index) {
                                      var res = banners[index];
                                      return Container(
                                        height: 132,
                                        width:
                                            MediaQuery.of(context).size.width,
                                        decoration: BoxDecoration(
                                            image: DecorationImage(
                                                image:
                                                    NetworkImage(res.imageUrl),
                                                fit: BoxFit.fill),
                                            borderRadius: BorderRadius.all(
                                                Radius.circular(8))),
                                        child: Container().p16(),
                                      ).centered();
                                    }),
                                    itemCount: banners.isEmpty ? 0 : 1)
                                : BannerShimmer().centered(),
                            SizedBox(
                              height: 15,
                            ),
                            Center(
                              child: SizedBox(
                                height: 87,
                                width: 1000,
                                child: Image.asset(
                                    'assets/images/authentication/logo.png'),
                              ),
                            ),
                            SizedBox(
                              height: 24,
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              )),
        ),
      ),
    );
  }
}
