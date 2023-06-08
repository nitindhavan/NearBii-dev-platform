import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fluttertoast/fluttertoast.dart';

Future<bool> saveRecipt(int amount, String id, String type) async {
  late FirebaseFirestore db;
  var status = false;

  db = FirebaseFirestore.instance;
  String? uid = FirebaseAuth.instance.currentUser!.uid.substring(0, 20);

  Map<String, dynamic> userdata = {};

  Map<String, dynamic> member = {};

  member["ProductName"] = type;
  member["Totalamount"] = amount;
  member["paymentID"] = id;
  member["status"] = "Success";
  member["timestamp"] = Timestamp.now();
  member["timestampUNIX"] = DateTime.now().microsecondsSinceEpoch ~/ 1000;
  member["type"] = type;
  member["memberId"] = uid;

  // List<dynamic> mydata = [];

  // mydata.add(member);

  // userdata["history"] = FieldValue.arrayUnion(mydata);

  db.collection("payments").add(member).then((value) {
    Fluttertoast.showToast(msg: "Recipt Saved");
    status = true;
  });

  return status;
}
