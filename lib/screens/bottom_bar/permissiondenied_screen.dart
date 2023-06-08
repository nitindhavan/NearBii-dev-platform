import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:nearbii/screens/bottom_bar/master_screen.dart';
import 'package:velocity_x/velocity_x.dart';

class PermissionDenied extends StatelessWidget {
  const PermissionDenied({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext ctx) {
    // Geolocator.requestPermission();R
    return SafeArea(
        child: Scaffold(
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          "You have denied The Location Permission".text.make(),
          "Please Enable Location To Continue Using this APP"
              .text
              .make()
              .pOnly(bottom: 30),
          Container(
            width: 200,
            height: 40,
            decoration: BoxDecoration(
                color: Colors.blue, borderRadius: BorderRadius.circular(50)),
            child: "Enable Permission".text.makeCentered(),
          ).onInkTap(() {
            _determinePosition(ctx);
          }).pOnly(bottom: 30),
          "Neabii Uses You current Location To fetch You best Vendors To your Feed"
              .text
              .make()
        ],
      ).px16(),
    ));
  }

  Future<void> _determinePosition(context) async {

    bool serviceEnabled;
    LocationPermission permission;

    checkPermission(context);

    serviceEnabled = await Geolocator.isLocationServiceEnabled();

    if (!serviceEnabled) {
      await Geolocator.openLocationSettings();
      await Navigator.of(context).push(MaterialPageRoute(builder: ((context) {
        return const PermissionDenied();
      }),),);
      // return Future.error('Location services are disabled.');
    }
    permission = await Geolocator.checkPermission();

    if (permission == LocationPermission.denied ||
        permission == LocationPermission.deniedForever) {
      permission = await Geolocator.requestPermission();
    }
    if (permission == LocationPermission.always ||
        permission == LocationPermission.whileInUse) {
      await Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: ((context) {
        return const MasterPage(
          currentIndex: 0,
        );
      })), (route) => false);
    }
  }

  void checkPermission(BuildContext context) async{
    await Future.delayed(Duration(seconds: 1)).then((value) async {
      bool serviceEnabled;
      LocationPermission permission;

      serviceEnabled = await Geolocator.isLocationServiceEnabled();

      permission = await Geolocator.checkPermission();

      if(serviceEnabled==true && (permission == LocationPermission.always ||
          permission == LocationPermission.whileInUse)){
        await Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(builder: ((context) {
              return const MasterPage(
                currentIndex: 0,
              );
            })), (route) => false);
      }
    });
    checkPermission(context);
  }
}
