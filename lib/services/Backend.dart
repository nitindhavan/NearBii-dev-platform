import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:nearbii/Model/ServiceModel.dart';
import 'package:nearbii/Model/catModel.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:velocity_x/velocity_x.dart';

import '../Model/BannerModel.dart';
import '../Model/notifStorage.dart';

class Backend {
  final userCollection = FirebaseFirestore.instance.collection('User');

  final coupanCollection = FirebaseFirestore.instance.collection('coupans');

  SharedPreferences? _session;

  // Creating the setter method
  // to set the input in Field/Property
  set setSession(SharedPreferences currentSession) {
    _session = currentSession;
  }

  Future<SharedPreferences> get cureentSession async {
    if (_session == null) {
      setSession = await SharedPreferences.getInstance();
    }

    return _session!;
  }

  List<ServiceModel> _services = [];

  Future<List<ServiceModel>> getServices({bool refersh = false}) async {
    if (refersh) _services = [];
    if (_services.isEmpty) {
      QuerySnapshot<Map<String, dynamic>> services =
          await FirebaseFirestore.instance.collection("Services").get();
      var data = services.docs;
      List<QueryDocumentSnapshot<Map<String, dynamic>>> iconVal = [];
      for (var ele in data) {
        ele.data()["id"] = ele.id;
        var map = ele.data();
        map["id"] = ele.id;
        _services.add(ServiceModel.fromMap(map));
      }
      _services = _services.sortedByString((element) => element.id);
    }
    return _services.toList();
  }

  bool showNumber = true;
  Future<Map> fetchUserData({bool refresh = false}) async {
    final session = await cureentSession;
    Map<String, dynamic> memberData = {};
    if (refresh) {
      Notifcheck.userDAta = null;
    }
    if (Notifcheck.userDAta == null) {
      final currentUserCollection = userCollection
          .doc(FirebaseAuth.instance.currentUser!.uid.substring(0, 20));
      var b = await currentUserCollection.get();
      Notifcheck.userDAta = b.data()!;
      if (Notifcheck.userDAta["phone"] == null && showNumber) {
        showNumber = false;
        Fluttertoast.showToast(msg: "Please Update Your Phone Number");
      }
    }

    memberData = Notifcheck.userDAta!["member"];

    if (Notifcheck.userDAta!['joinDate'] != null) {
      session.setString("type", Notifcheck.userDAta!['type']);

      session.setBool("isMember", memberData["isMember"]);

      DateTime memDate =
          DateTime.fromMillisecondsSinceEpoch(memberData["endDate"]);

      session.setString("joinDate", memberData["endDate"].toString());
      var now = DateTime.now();

      if (memDate.difference(now).inMilliseconds > 0 &&
          memberData["isMember"]) {
        // Fluttertoast.showToast(msg: "Yes you are member");

        session.setBool("checkIsMember", true);
      } else {
        session.setBool("checkIsMember", false);
        //Fluttertoast.showToast(msg: "Memberhip Expied");
      }
    }
    return Notifcheck.userDAta;
  }

  List<CategoriesModel> categories = [];
  Future<List<CategoriesModel>> getCategories({bool refersh = false}) async {
    if (refersh) {
      categories = [];
    }
    if (categories.isEmpty) {
      var b = await FirebaseFirestore.instance.collection("categories").get();
      int i = 0;
      for (var elemnt in b.docs) {
        if (i > 4) break;
        var cat = CategoriesModel.fromMap(elemnt.data());
        categories.add(cat);
        i++;
      }
    }
    return categories;
  }

  Future<List<ServiceModel>> getHomeIconData({bool refersh = false}) async {
    List<ServiceModel> homeIcons = [];
    var services = await getServices();
    for (var service in services) {
      if (service.isActive) {
        homeIcons.add(service);
      }
    }
    return homeIcons;
  }

  List<BannerModel> banners = [];
  Future<List<BannerModel>> getBanners({bool refersh = false}) async {
    if (refersh) banners = [];
    if (banners.isEmpty) {
      var b = await FirebaseFirestore.instance
          .collection("generalData")
          .doc("banners")
          .collection("advertisement")
          .get();
      for (var e in b.docs) {
        banners.add(BannerModel.fromMap(e.data()));
      }
    }
    return banners;
  }

  updateCurrentUserData(Map<String, dynamic> data) async {
    final currentUserCollection = userCollection
        .doc(FirebaseAuth.instance.currentUser!.uid.substring(0, 20));
    await currentUserCollection.set(data, SetOptions(merge: true));
  }

  updateUserData(String uid, Map<String, dynamic> data) async {
    await userCollection.doc(uid).set(data, SetOptions(merge: true));
  }

  Future<bool> checkCoupan({required String coupan}) async {
    var data = await coupanCollection.doc(coupan).get();
    if (data.exists) {
      var coupan = data.data();
      if (coupan != null && coupan['enabled']) {
        return true;
      }
    }
    return false;
  }

  void disableCoupan(String coupan) {
    coupanCollection
        .doc(coupan)
        .set({"enabled": false}, SetOptions(merge: true));
  }

  Future<bool> isUser() async {
    var data = await fetchUserData(refresh: true);
    log(data.toString(), name: "checkuser");
    return data["type"] == "User";
  }

  Future<void> generateCoupan() async {
    var id = coupanCollection.doc().id;
    coupanCollection.doc(id.substring(0, 5)).set({"enabled": true});
  }
}
