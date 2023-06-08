import 'package:flutter/material.dart';
import 'package:nearbii/constants.dart';
import 'package:shimmer/shimmer.dart';
import 'package:velocity_x/velocity_x.dart';

class ShimmerWidgetServices extends StatelessWidget {
  const ShimmerWidgetServices({super.key});

  @override
  Widget build(BuildContext context) {
    var width = MediaQuery.of(context).size.width;
    return Container(
      child: Shimmer.fromColors(
        baseColor: const Color.fromARGB(255, 78, 78, 78),
        highlightColor: Colors.grey,
        enabled: true,
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                SizedBox(
                  width: width - 40,
                  height: 80,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    itemCount: 4,
                    shrinkWrap: true,
                    itemBuilder: (context, index) {
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          CircleAvatar(
                            backgroundColor: kHomeScreenServicesContainerColor,
                            radius: width / 13.06,
                            child: const Icon(Icons.image),
                          ),
                          SizedBox(
                            width: 70,
                            child: Text(
                              "Loading ...",
                              textAlign: TextAlign.center,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontWeight: FontWeight.w400,
                                fontSize: 14,
                                color: kLoadingScreenTextColor,
                              ),
                            ),
                          ),
                        ],
                      );
                    },
                    separatorBuilder: (context, index) => const SizedBox(
                      width: 15,
                    ),
                  ),
                ),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                SizedBox(
                  width: width - 40,
                  height: 80,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    itemCount: 4,
                    shrinkWrap: true,
                    itemBuilder: (context, index) {
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          CircleAvatar(
                            backgroundColor: kHomeScreenServicesContainerColor,
                            radius: width / 13.06,
                            child: const Icon(Icons.image),
                          ),
                          SizedBox(
                            width: 70,
                            child: Text(
                              "Loading .. ",
                              textAlign: TextAlign.center,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontWeight: FontWeight.w400,
                                fontSize: 14,
                                color: kLoadingScreenTextColor,
                              ),
                            ),
                          ),
                        ],
                      );
                    },
                    separatorBuilder: (context, index) => const SizedBox(
                      width: 15,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class ShimmerWidgetCategories extends StatelessWidget {
  const ShimmerWidgetCategories({super.key});

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: const Color.fromARGB(255, 78, 78, 78),
      highlightColor: Colors.grey,
      enabled: true,
      child: SizedBox(
        height: 150,
        child: Row(
          children: [
            Container(
              child: ListView.builder(
                controller: ScrollController(),
                shrinkWrap: true,
                scrollDirection: Axis.horizontal,
                itemBuilder: (context, index) {
                  return Container(
                    width: 90,
                    height: 120,
                    decoration: BoxDecoration(
                      boxShadow: const [
                        BoxShadow(
                          color: Colors.black26,
                          offset: Offset(1, 1),
                          blurRadius: 2,
                        ),
                      ],
                      borderRadius: BorderRadius.circular(10),
                      gradient: const LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          Color(0xffffeb3b),
                          Color(0xffF57F17),
                          Color(0xfff9a825),
                          Color(0xff403A3A),
                        ],
                      ),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Container(
                          height: 14,
                          width: 90,
                          color: Colors.white,
                          child: const Center(
                            child: Text(
                              "Loading...",
                              style: TextStyle(
                                  color: Colors.black,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ).pOnly(bottom: 2, left: 10);
                },
                itemCount: 4,
              ).expand(),
            ),
          ],
        ),
      ),
    );
  }
}

class ShimmerServices extends StatelessWidget {
  const ShimmerServices({super.key});

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: const Color.fromARGB(255, 78, 78, 78),
      highlightColor: Colors.grey,
      enabled: true,
      child: ListView.builder(
              physics: const NeverScrollableScrollPhysics(),
              shrinkWrap: true,
              itemBuilder: ((context, index) {
                return Column(
                  children: [
                    Row(
                      children: [
                        "Loading ..."
                            .text
                            .fontWeight(FontWeight.w600)
                            .xl2
                            .make(),
                        const Spacer(),
                        "See All".text.bold.make(),
                        const Icon(
                          Icons.arrow_forward_ios_rounded,
                          size: 10,
                        )
                      ],
                    ).onInkTap(() {
                      //_gotoService(res.id);
                    }),
                    GridView.builder(
                        itemCount: 4,
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 2),
                        itemBuilder: ((context, index) {
                          return Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(10),
                              boxShadow: const [
                                BoxShadow(
                                  color: Colors.grey,
                                  offset: Offset(0.0, 1.0), //(x,y)
                                  blurRadius: 6.0,
                                ),
                              ],
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                Container(
                                  color: Colors.white,
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    children: const [],
                                  ),
                                ),
                              ],
                            ),
                          ).p8();
                        })),
                  ],
                ).centered();
              }),
              itemCount: 2)
          .pOnly(bottom: 40),
    );
  }
}

class BannerShimmer extends StatelessWidget {
  const BannerShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: const Color.fromARGB(255, 78, 78, 78),
      highlightColor: Colors.grey,
      enabled: true,
      child: ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemBuilder: ((context, index) {
            return Container(
              height: 132,
              width: MediaQuery.of(context).size.width,
              decoration: const BoxDecoration(boxShadow: [
                BoxShadow(
                  color: Colors.grey,
                  offset: Offset(0.0, 1.0), //(x,y)
                  blurRadius: 6.0,
                ),
              ], borderRadius: BorderRadius.all(Radius.circular(8))),
              child: Container(),
            ).p16().centered();
          }),
          itemCount: 2),
    );
  }
}
