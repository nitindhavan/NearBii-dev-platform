import 'package:cloud_firestore/cloud_firestore.dart';

class offerModel {
  late String title;
  late int off;
  late String bgimg;
  late String cat;

  offerModel(this.title, this.off, this.bgimg, this.cat);

  offerModel.fromSnapshot(
      QueryDocumentSnapshot<Map<String, dynamic>> snapshot) {
    title = snapshot["title"];
    off = snapshot["off"];
    bgimg = snapshot["bgimg"];
    cat = snapshot["cat"];
  }

  // offerModel.fromJson(Map<String, dynamic> json) {
  //   title = json["title"];
  //   off = json["off"];
  //   bgimg = json["bgimg"];
  //   cat = json["cat"];
  // }
}
