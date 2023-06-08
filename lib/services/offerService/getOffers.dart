import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

import '../../Model/notifStorage.dart';
import '../../constants.dart';

Widget getOfferPlates(PageController controller, BuildContext context) {
  try {
    final _firestore = FirebaseFirestore.instance;

    return StreamBuilder<QuerySnapshot>(
      stream: _firestore
          .collection('Banner')
          .orderBy("discount")
          .snapshots()
          .handleError((error) {
        return Container(
          child: const SizedBox(
            width: 30,
            height: 30,
            child: CircularProgressIndicator(),
          ),
        );
      }),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }

        List<Widget> messageWidgets = snapshot.data!.docs.map<Widget>((m) {
          final data = m.data as dynamic;

          return InkWell(
            onTap: () {},
            child: offerCard(data()['title'], data()["discount"],
                data()["image"], data()["category"]),
          );
        }).toList();

        return SizedBox(
          width: MediaQuery.of(context).size.width,
          height: 200,
          child: Column(
            children: [
              SizedBox(
                height: 170,
                child: PageView(
                  controller: controller,
                  children: messageWidgets,
                ),
              ),
              SizedBox(
                height: 10,
                child: Padding(
                  padding: const EdgeInsets.only(top: 12, bottom: 17),
                  child: Center(
                    child: messageWidgets.isNotEmpty
                        ? SmoothPageIndicator(
                            controller: controller,
                            count: messageWidgets.length,
                            effect: WormEffect(
                              spacing: 10,
                              dotColor: kAdvertiseContainerTextColor,
                              activeDotColor: kSignInContainerColor,
                              dotHeight: 7,
                              dotWidth: 7,
                            ),
                            onDotClicked: (index) => controller.animateToPage(
                              index,
                              duration: const Duration(milliseconds: 500),
                              curve: Curves.easeInOut,
                            ),
                          )
                        : const SizedBox(
                            width: 7,
                            height: 7,
                          ),
                  ),
                ),
              ),
            ],
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

Widget offerCard(String title, int off, String bgimg, String cat) {
  return bgimg == ''
      ? Container(
          decoration: BoxDecoration(
            // image: bgimg != ""
            //     ? CachedNetworkImage(imageUrl: bgimg)
            //     : null,
            borderRadius: BorderRadius.circular(10),
            gradient: bgimg == ""
                ? const LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Color(0x553C828F),
                      Color(0x4475A1AA),
                      Color(0x11D8D8D8),
                    ],
                  )
                : null,
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 23),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: const [
                // Text(
                //   title,
                //   style: TextStyle(
                //     fontWeight: FontWeight.w700,
                //     fontSize: 20,
                //     color: kBookmarksAdTextColor,
                //   ),
                // ),
                // Text(
                //   cat,
                //   style: TextStyle(
                //     fontWeight: FontWeight.w500,
                //     fontSize: 12,
                //     color: kBookmarksAdTextColor,
                //   ),
                // ),
                // SizedBox(
                //   height: 10,
                // ),
                // Container(
                //   width: 109,
                //   height: 32,
                //   decoration: BoxDecoration(
                //     color: kSignInContainerColor,
                //     borderRadius: BorderRadius.circular(4),
                //   ),
                //   child: Center(
                //     child: Row(
                //       mainAxisAlignment: MainAxisAlignment.center,
                //       children: [
                //         Text(
                //           "Book Now",
                //           style: TextStyle(
                //             fontWeight: FontWeight.w600,
                //             fontSize: 14,
                //             color: Colors.white,
                //           ),
                //         ),
                //         SizedBox(
                //           width: 3,
                //         ),
                //         Icon(
                //           Icons.arrow_forward,
                //           size: 15,
                //           color: Colors.white,
                //         )
                //       ],
                //     ),
                //   ),
                // )
              ],
            ),
          ),
        )
      : CachedNetworkImage(
          imageUrl: bgimg,
          fit: BoxFit.fill,
          filterQuality: FilterQuality.high,
          errorWidget: (context, url, error) => const Icon(Icons.error),
        );
}
