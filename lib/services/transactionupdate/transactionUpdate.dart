import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:nearbii/services/savePaymentRecipt/savePaymentRecipt.dart';
import 'package:nearbii/services/sendNotification/notificatonByCity/cityNotiication.dart';

import '../../Model/notifStorage.dart';

void updateTransatcion(uid, titlle, id, status, amount, time) {
  saveRecipt(
    amount,
    id,
    titlle,
  ).then((e) async {});
  var b = {
    "title": titlle,
    "transId": id,
    "status": status,
    "amount": amount,
    "time": time
  };
  FirebaseFirestore.instance
      .collection("User")
      .doc(uid)
      .collection("payments")
      .doc(getDate(DateTime.now().month, DateTime.now().year))
      .set({
    "payments": FieldValue.arrayUnion([b])
  }, SetOptions(merge: true));
}

String getDate(int month, int year) {
  switch (month) {
    case DateTime.april:
      return "April $year";

    case DateTime.may:
      return "may $year";
    case DateTime.june:
      return "june $year";
    case DateTime.july:
      return "july $year";
    case DateTime.august:
      return "august $year";
    case DateTime.september:
      return "september $year";
    case DateTime.october:
      return "october $year";
    case DateTime.november:
      return "november $year";
    case DateTime.december:
      return "december $year";
    case DateTime.january:
      return "january $year";
    case DateTime.february:
      return "february $year";
    case DateTime.march:
      return "march $year";
  }

  return "";
}

Future<void> updateWallet(
    uid, titlle, bool status, amount, time, currbalcne) async {
  var b = {"title": titlle, "status": status, "amount": amount, "time": time};

  if (status) {
    await FirebaseFirestore.instance
        .collection("User")
        .doc(uid)
        .collection("wallet")
        .doc("lastSummary")
        .set({"lastAmount": amount, "bill": 0, "currbalce": currbalcne});
  } else {
    await FirebaseFirestore.instance
        .collection("User")
        .doc(uid)
        .collection("wallet")
        .doc("lastSummary")
        .set({"bill": FieldValue.increment(amount)});
  }
  await FirebaseFirestore.instance
      .collection("User")
      .doc(uid)
      .collection("wallet")
      .doc(getDate(DateTime.now().month, DateTime.now().year))
      .set({
    "payments": FieldValue.arrayUnion([b])
  }, SetOptions(merge: true));
  await FirebaseFirestore.instance
      .collection("User")
      .doc(uid)
      .collection("walletTransaction")
      .doc()
      .set(b, SetOptions(merge: true));
  sendNotificationWallet(
      uid, double.parse(amount.toString()), status ? "Credited" : "Debited",titlle);
}
