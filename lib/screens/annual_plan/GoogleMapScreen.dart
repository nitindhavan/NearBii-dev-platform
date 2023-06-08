
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:geocoding/geocoding.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class GoogleMapScreen extends StatefulWidget {
  double lat;
  double long;
  bool show;
  GoogleMapScreen(
      {Key? key, this.lat = 20.5937, this.long = 78.9629, this.show = true})
      : super(key: key);

  @override
  State<GoogleMapScreen> createState() => _GoogleMapScreenState();
}

class _GoogleMapScreenState extends State<GoogleMapScreen> {
  Map<String, dynamic> latlong = {};

  late GoogleMapController myController;
  LatLng _center = const LatLng(20.5937, 78.9629);
  @override
  void initState() {
    // TODO: implement initState
    _center = LatLng(widget.lat, widget.long);
    cameraPosition = CameraPosition(target: _center);
    super.initState();
  }

  void _onMapCreated(GoogleMapController controller) {
    myController = controller;
  }

  CameraPosition? cameraPosition;
  String location = "Location Name:";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Stack(
          children: [
            GoogleMap(
              buildingsEnabled: true,
              markers: const {},
              myLocationEnabled: true,
              zoomControlsEnabled: false,
              onCameraMove: (CameraPosition cameraPositiona) {
                cameraPosition = cameraPositiona; //when map is dragging
              },
              onCameraIdle: () async {
                //when map drag stops
                List<Placemark> placemarks = await placemarkFromCoordinates(
                    cameraPosition!.target.latitude,
                    cameraPosition!.target.longitude);
                latlong['lat'] = cameraPosition!.target.latitude;
                latlong['long'] = cameraPosition!.target.longitude;
                setState(() {
                  //get place name from lat and lang
                  location = placemarks.first.administrativeArea.toString() +
                      ", " +
                      placemarks.toString();
                });
              },
              onMapCreated: _onMapCreated,
              initialCameraPosition: CameraPosition(
                target: _center,
                zoom: 4.0,
              ),
            ),
            const Center(
              //picker image on google map
              child: Icon(Icons.center_focus_strong_outlined),
            ),
            widget.show
                ? Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      GestureDetector(
                        onTap: () {
                          if (latlong["lat"] == null ||
                              latlong["long"] == null) {
                            Fluttertoast.showToast(
                                msg: "Please Select Correct location");
                            return;
                          }
                          // print(latlong);
                          var b = {
                            "lat": latlong["lat"],
                            "long": latlong["long"]
                          };

                          print(b);
                          Navigator.pop(context, latlong);
                        },
                        child: Container(
                          width: double.infinity,
                          height: 60,
                          decoration: const BoxDecoration(
                            color: Colors.blue,
                            borderRadius: BorderRadius.only(
                                topLeft: Radius.circular(16),
                                topRight: Radius.circular(16)),
                          ),
                          child: const Center(
                              child: Text(
                            "Select Location",
                            style: TextStyle(color: Colors.white),
                          )),
                        ),
                      )
                    ],
                  )
                : Container()
          ],
        ),
      ),
    );
  }
}
