import 'package:nearbii/Model/notifStorage.dart';
import 'package:shared_preferences/shared_preferences.dart';

void setVendorMode() async {
  var sf = await SharedPreferences.getInstance();
  sf.setBool("User", false);
  sf.setString("type", "Vendor");
  Notifcheck.vendor = true;
}

void setUserMode() async {
  var sf = await SharedPreferences.getInstance();
  sf.setBool("User", true);
  sf.setString("type", "User");
  Notifcheck.vendor = false;
}
