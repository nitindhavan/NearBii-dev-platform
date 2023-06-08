import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:nearbii/Model/notifStorage.dart';
import 'package:nearbii/Model/vendormodel.dart';
import 'package:nearbii/constants.dart';
import 'package:nearbii/screens/bottom_bar/profile/vendor_profile_screen.dart';
import 'package:nearbii/screens/vendor/vendorHome.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:velocity_x/velocity_x.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ScanScreen extends StatefulWidget {
  const ScanScreen({Key? key}) : super(key: key);

  @override
  State<ScanScreen> createState() => _ScanScreenState();
}

class _ScanScreenState extends State<ScanScreen> {
  FirebaseAuth auth = FirebaseAuth.instance;
  final GlobalKey qrKey = GlobalKey(debugLabel: 'QR');
  var result;
  QRViewController? controller;

  bool qrScanState = false;

  String name = "";

  bool showQR = false;

  @override
  void initState() {
    checkVendor();

    super.initState();
  }
  // @override
  // void reassemble() {
  //   super.reassemble();
  //   if (Platform.isAndroid) {
  //     controller?.pauseCamera();
  //   } else if (Platform.isIOS) {
  //     controller?.resumeCamera();
  //   }
  // }

  void _onQRViewCreated(QRViewController controller) {
    this.controller = controller;
    controller = controller;

    controller.pauseCamera();
    controller.resumeCamera();
    controller.scannedDataStream.listen((scanData) {
      setState(() {
        result = scanData.code;
        qrScanState = false;
        //getVendor(scanData.code);

        Navigator.of(context).push(MaterialPageRoute(builder: (context) {
          return vendorHome(id: result);
        }));
      });
    });
  }

  @override
  void dispose() {
    if (controller != null) controller!.dispose();
    super.dispose();
  }

  Widget QRCodeScaner(context) {
    return Container(
      color: const Color.fromARGB(132, 0, 0, 0),
      width: MediaQuery.of(context).size.width,
      height: MediaQuery.of(context).size.height,
      child: Center(
        child: Stack(
          children: [
            QRView(
              overlay: QrScannerOverlayShape(
                  borderColor: Colors.lightBlue,
                  borderRadius: 3,
                  borderWidth: 10),
              key: qrKey,
              onQRViewCreated: _onQRViewCreated,
            ),
            Container(
              margin: const EdgeInsets.only(top: 150),
              child: InkWell(
                  onTap: () {
                    setState(() {
                      qrScanState = false;
                    });
                  },
                  child: const Icon(
                    Icons.close,
                    color: Colors.white,
                    size: 30,
                  )),
            )
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: qrScanState == true
          ? QRCodeScaner(context)
          : Scaffold(
              body: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    !vendor
                        ? Column(
                            children: [
                              //     : 'Scan a code'),
                              Text(
                                name,
                                style: TextStyle(
                                  fontWeight: FontWeight.w700,
                                  fontSize: 20,
                                  color: kLoadingScreenTextColor,
                                ),
                              ),
                              showQR == true
                                  ? Padding(
                                      padding: const EdgeInsets.only(
                                          top: 45, bottom: 60),
                                      child: QrImage(
                                        data:
                                            "${auth.currentUser?.uid.substring(0, 20)}",
                                        version: QrVersions.auto,
                                        size: 200.0,
                                      ),
                                    )
                                  : Container(),
                            ],
                          )
                        : Container(),
                    Text(result ?? ""),
                    GestureDetector(
                      onTap: () => setState(() {
                        qrScanState = true;
                      }),
                      child: Container(
                        height: 40,
                        width: 250,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(5),
                          color: kSignInContainerColor,
                        ),
                        child: Center(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: const [
                              Icon(
                                Icons.qr_code_outlined,
                                size: 18,
                                color: Colors.white,
                              ),
                              SizedBox(
                                width: 8,
                              ),
                              Text(
                                "Open Code Scanner",
                                style: TextStyle(
                                  fontWeight: FontWeight.w400,
                                  fontSize: 20,
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(
                      height: 30,
                    ),
                  ],
                ),
              ),
            ).pOnly(top: 20),
    );
  }

  Future<void> getVendor(result) async {
    print(result);
    var b =
        await FirebaseFirestore.instance.collection("vendor").doc(result).get();
    print(b.data());
    if (b.data() != null) {
      var x = VendorModel.fromMap(b.data()!);
      Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => VendorProfileScreen(
                  id: result,
                  isVisiter: true,
                )),
      );
    }
  }

  bool vendor = false;
  checkVendor() async {
    SharedPreferences session = await SharedPreferences.getInstance();
    print(vendor);
    vendor = session.getString("type") == "Vendor" ? false : true;
    if (!vendor) {
      var b = await FirebaseFirestore.instance
          .collection("vendor")
          .doc(FirebaseAuth.instance.currentUser!.uid
              .toString()
              .substring(0, 20))
          .get()
          .then((value) {
        setState(() {
          showQR = true;
          name = value.get("businessName");
        });
      }).catchError((onError) {});
    } else {}
  }
}
