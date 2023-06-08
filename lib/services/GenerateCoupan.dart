import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:nearbii/Model/notifStorage.dart';
import 'package:velocity_x/velocity_x.dart';

class GenerateCoupan extends StatefulWidget {
  const GenerateCoupan({super.key});

  @override
  State<GenerateCoupan> createState() => _GenerateCoupanState();
}

class _GenerateCoupanState extends State<GenerateCoupan> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text("Coupan Generate"),
        ),
        body: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
            stream:
                FirebaseFirestore.instance.collection('coupans').snapshots(),
            builder: (context, snapshot) {
              if (snapshot.data == null) {
                return const CircularProgressIndicator().centered();
              }
              var data = snapshot.data!.docs;
              return Center(
                  child: ListView.builder(
                      itemBuilder: (context, index) {
                        var snap = data[index];
                        if (!snap.data()["enabled"]) {
                          snap.reference.delete();
                        }
                        return Card(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              snap.id.text.bold.xl.make(),
                              snap.data()["enabled"].toString().text.make()
                            ],
                          ).p(10),
                        ).onInkTap(() {
                          var clip = ClipboardData(text: snap.id);
                          Clipboard.setData(clip);
                          Fluttertoast.showToast(msg: "Copied Coupan");
                        });
                      },
                      itemCount: data.length));
            }),
        floatingActionButton: FloatingActionButton(
          onPressed: _incrementCounter,
          tooltip: 'Increment',
          child: const Icon(Icons.add),
        ));
  }

  void _incrementCounter() {
    Notifcheck.api.generateCoupan();
  }
}
