import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:month_year_picker/month_year_picker.dart';
import 'package:nearbii/Model/vendormodel.dart';
import 'package:nearbii/constants.dart';
import 'package:nearbii/screens/bottom_bar/master_screen.dart';
import 'package:nearbii/screens/createEvent/addEvent/addEvent.dart';
import 'package:nearbii/screens/loading_screen.dart';

import 'package:flutter_localizations/flutter_localizations.dart';
// import 'package:notification_permissions/notification_permissions.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'screens/annual_plan/business_service_details_screen.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';


const AndroidNotificationChannel channel = AndroidNotificationChannel(
  'high_importance_channel', // id
  'High Importance Notifications', // title
  // description
  description: 'This channel is used for important notifications.',
  importance: Importance.max,
  playSound: true,
);

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =  FlutterLocalNotificationsPlugin();

InterstitialAd? _interstitialAd;
bool _isAdLoaded = false;



void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  await MobileAds.instance.initialize();

  FirebaseFirestore.instance.settings = const Settings(persistenceEnabled: true);

  print("PStatus ${FirebaseFirestore.instance.settings.persistenceEnabled}");
  PermissionStatus status = await Permission.notification.request();
  if(!(await Permission.locationWhenInUse.isGranted || await Permission.locationAlways.isGranted|| await Permission.location.isGranted)){
    PermissionStatus status2 =await Permission.location.request();
  }
  _loadInterstitialAd();
  runApp(const NearBii());
}

class NearBii extends StatelessWidget {
  const NearBii({Key? key}) : super(key: key);


  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    bool _allow = true;
    return MaterialApp(
        localizationsDelegates: const [
          GlobalMaterialLocalizations.delegate,
          MonthYearPickerLocalizations.delegate,
        ],
        debugShowCheckedModeBanner: false,
        title: 'NearBii',
        theme: ThemeData(
          primarySwatch: Colors.blueGrey,
          appBarTheme: AppBarTheme(
            elevation: 0.0,
            backgroundColor: Colors.white,
          ),
          scaffoldBackgroundColor: Colors.white,
          bottomNavigationBarTheme: BottomNavigationBarThemeData(
            elevation: 0,
            selectedIconTheme: IconThemeData(color: Colors.black),
            unselectedIconTheme: IconThemeData(color: kWalletLightTextColor),
            selectedLabelStyle: TextStyle(color: Colors.black),
            unselectedLabelStyle: TextStyle(color: kWalletLightTextColor),
          ),
          visualDensity: VisualDensity.adaptivePlatformDensity,
        ),
        home: Material(
          child: WillPopScope(
              onWillPop: () {
                return Future.value(_allow);
              },
              child: LoadingScreen()),
        ),);
  }
}

void _loadInterstitialAd() async {
  final interstitialAdUnitId = 'ca-app-pub-5233193736247595/6212123934';

  InterstitialAd.load(
    adUnitId: interstitialAdUnitId,
    request: AdRequest(),
    adLoadCallback: InterstitialAdLoadCallback(
      onAdLoaded: (ad) {
          _interstitialAd = ad;
          _isAdLoaded = true;
          _showInterstitialAd();
      },
      onAdFailedToLoad: (error) {
        print('Interstitial Ad failed to load: $error');
      },
    ),
  );
}

void _showInterstitialAd() {
  if (_isAdLoaded) {
    _interstitialAd?.show();
  } else {
    print('Interstitial Ad is not yet loaded.');
  }
}
