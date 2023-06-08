import 'package:cloud_firestore/cloud_firestore.dart';

class PlanModel {
  String? planName;
  int? offerPost;
  int? adPost;
  int? price;
  int? validity;
  int? purchasedDate;

  PlanModel(this.planName, this.offerPost,this.adPost, this.price, this.validity,);

  PlanModel.fromSnapshot(
      DocumentSnapshot<Map<String, dynamic>> snapshot) {
    planName = snapshot["planName"];
    offerPost = snapshot["offerPost"];
    adPost=snapshot["adPost"];
    price = snapshot["price"];
    validity = snapshot["validity"];
    purchasedDate=snapshot["purchasedDate"];
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'planName': planName,
      'offerPost': offerPost,
      'adPost': adPost,
      'price': price,
      'validity': validity,
      'purchasedDate': purchasedDate,
    };
  }
// offerModel.fromJson(Map<String, dynamic> json) {
//   title = json["title"];
//   off = json["off"];
//   bgimg = json["bgimg"];
//   cat = json["cat"];
// }
}