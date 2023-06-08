// ignore_for_file: non_constant_identifier_names, unused_local_variable

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:nearbii/constants.dart';
import 'package:velocity_x/velocity_x.dart';

import '../../Model/notifStorage.dart';

Widget getVendorImage(BuildContext acontext, uid, isVisitor) {
  try {
    final _firestore = FirebaseFirestore.instance;

    return StreamBuilder<QuerySnapshot>(
      stream: _firestore
          .collection("vendor")
          .doc(uid)
          .collection("images")
          .snapshots()
          .handleError((error) {
        return Container(
          child: const SizedBox(
            width: 30,
            height: 30,
            child: CircularProgressIndicator(color: Colors.black,),
          ),
        );
      }),
      builder: (bcontext, AsyncSnapshot snapshot) {
        if (!snapshot.hasData) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }
        return SizedBox(
          height: 100,
          width: MediaQuery.of(bcontext).size.width,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: snapshot.data.docs.length,
            itemBuilder: (dcontext, index) {
              return InkWell(
                onTap: () async {
                  List qs = snapshot.data.docs;
                  print(qs.length);
                  List imageList = [];
                  for (int i = 0; i < qs.length; i++) {
                    imageList.add(qs[i]['image']);
                  }
                  showGeneralDialog(
                      barrierColor: const Color.fromARGB(103, 26, 26, 26),
                      context: dcontext,
                      pageBuilder: (BuildContext context,
                          Animation<double> animation,
                          Animation<double> secondaryAnimation) {
                        return Stack(
                          children: <Widget>[
                            Positioned(
                              top: 0,
                              left: 0,
                              bottom: 0,
                              right: 0,
                              child: Center(
                                child: SizedBox(
                                  width: MediaQuery.of(context).size.width,
                                  height: MediaQuery.of(context).size.height,
                                  child: VxSwiper(
                                      viewportFraction: 1.0,
                                      height:
                                          MediaQuery.of(context).size.height,
                                      scrollDirection: Axis.horizontal,
                                      scrollPhysics:
                                          const BouncingScrollPhysics(),
                                      enableInfiniteScroll: false,
                                      autoPlay: false,
                                      reverse: false,
                                      pauseAutoPlayOnTouch:
                                          const Duration(seconds: 3),
                                      initialPage: index,
                                      isFastScrollingEnabled: false,
                                      onPageChanged: (value) {
                                        print(value);
                                      },
                                      autoPlayCurve: Curves.elasticOut,
                                      items: imageList.map((e) {
                                        return Scaffold(
                                          body: SafeArea(
                                            child: SingleChildScrollView(
                                              child: Container(
                                                color: Colors.white,
                                                child: Column(
                                                  crossAxisAlignment: CrossAxisAlignment.end,
                                                  children: [
                                                    if(!isVisitor) GestureDetector(
                                                      onTap: () {
                                                        _firestore
                                                            .collection("vendor")
                                                            .doc(uid)
                                                            .collection("images")
                                                            .doc(snapshot.data.docs[index].id)
                                                            .delete();
                                                        Navigator.pop(context);
                                                      },
                                                      child: Container(
                                                          margin: EdgeInsets.only(left: 16,right: 16,top: 8),
                                                          alignment: Alignment.center,
                                                          width: 100,
                                                          decoration: BoxDecoration(color: Colors.pink,borderRadius: BorderRadius.circular(10)),
                                                          height: 40,child: Text("Delete",style: TextStyle(color: Colors.white),)),
                                                    ),
                                                    Container(
                                                      child: Padding(
                                                        padding: const EdgeInsets.only(left: 16.0,right: 16),
                                                        child: Card(
                                                          child: Image.network(e,loadingBuilder: (BuildContext context, Widget child,
                                                              ImageChunkEvent? loadingProgress) {
                                                            if (loadingProgress == null) return child;
                                                            return Padding(
                                                              padding: EdgeInsets.all(50),
                                                              child: Center(
                                                                child: CircularProgressIndicator(
                                                                  value: loadingProgress.expectedTotalBytes != null
                                                                      ? loadingProgress.cumulativeBytesLoaded /
                                                                      loadingProgress.expectedTotalBytes!
                                                                      : null,
                                                                ),
                                                              ),
                                                            );
                                                          },),
                                                        ),
                                                      ),
                                                    ),

                                                  ],
                                                ),
                                              ),
                                            ),
                                          ),
                                        );
                                      }).toList()),
                                ),
                              ),
                            ),
                            // if (!isVisitor)
                            //   Positioned(
                            //     right: 10,
                            //     top: MediaQuery.of(context).size.height * 0.38,
                            //     child: GestureDetector(
                            //       onTap: () {
                            //         _firestore
                            //             .collection("vendor")
                            //             .doc(uid)
                            //             .collection("images")
                            //             .doc(snapshot.data.docs[index].id)
                            //             .delete();
                            //         Navigator.pop(context);
                            //       },
                            //       child: const Icon(
                            //         Icons.delete_rounded,
                            //         size: 30,
                            //         color: Colors.red,
                            //       ),
                            //     ),
                            //   ),
                          ],
                        );
                      });
                },
                child: Container(
                  height: 100,
                  width: 100,
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      image: DecorationImage(
                          image:
                              NetworkImage(snapshot.data.docs[index]["image"]),
                          fit: BoxFit.fill)),
                ),
              );
            },
            separatorBuilder: (econtext, index) => const SizedBox(
              width: 10,
            ),
          ),
        );
      },
    );
  } catch (Ex) {
    print("0x1Error To Get User");
    return Container(
      child: const SizedBox(
        width: 30,
        height: 30,
        child: CircularProgressIndicator(),
      ),
    );
  }
}
