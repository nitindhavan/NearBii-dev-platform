import 'package:flutter/material.dart';
import 'package:nearbii/screens/bottom_bar/master_screen.dart';

class paymentDone extends StatefulWidget {
  const paymentDone({Key? key}) : super(key: key);

  @override
  State<paymentDone> createState() => _paymentDoneState();
}

class _paymentDoneState extends State<paymentDone> {
  @override
  Widget build(BuildContext context) {
    Future.delayed(const Duration(seconds: 10), () {
      Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: ((context) {
        return const MasterPage(
          currentIndex: 0,
        );
      })), (route) => false);
    });

    return WillPopScope(
      onWillPop: () async {
        return false;
      },
      child: SafeArea(
          top: false,
          child: Scaffold(
            body: Container(
              alignment: Alignment.center,
              width: MediaQuery.of(context).size.width,
              height: MediaQuery.of(context).size.height,
              child: SingleChildScrollView(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Card(
                        elevation: 6,
                        child: Container(
                          padding: const EdgeInsets.all(30),
                          child: Column(children: const [
                            Icon(Icons.check_circle,
                                size: 154, color: Colors.green),
                            SizedBox(
                              height: 50,
                            ),
                            Text("Thank you.! Payment Done",
                                style: TextStyle(
                                    fontSize: 25, color: Colors.black)),
                            SizedBox(
                              height: 20,
                            ),
                            Text("Redirect to homepage in 2s")
                          ]),
                        ))
                  ],
                ),
              ),
            ),
          )),
    );
  }
}
