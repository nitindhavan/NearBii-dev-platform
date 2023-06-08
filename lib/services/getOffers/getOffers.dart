import 'package:flutter/material.dart';
import 'package:velocity_x/velocity_x.dart';

import '../../constants.dart';

class offerBox extends StatefulWidget {
  final data;

  const offerBox({Key? key, required this.data}) : super(key: key);

  @override
  State<offerBox> createState() => _offerBoxState();
}

class _offerBoxState extends State<offerBox> {
  @override
  Widget build(BuildContext context) {
    print(widget.data);
    return Card(
      margin: EdgeInsets.only(left: 16,right: 16,bottom: 16),
      shadowColor: const Color.fromARGB(255, 81, 182, 200),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      elevation: 4,
      child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Stack(
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [

                    Container(
                      alignment: Alignment.center,
                      height: 312,
                      margin: EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(5),
                      ),
                      child: widget.data["offerImg"] == ''
                          ? Image.asset(
                              'assets/images/offers/offers_screen_image.png',
                              fit: BoxFit.fill,
                            )
                          : Image.network(
                              widget.data["offerImg"],
                              fit: BoxFit.fill,
                            ),
                    ),
                  ],
                ),
                Positioned(
                  top: 15,
                  left: 1,
                  child: Container(
                    decoration: const BoxDecoration(
                      color: Color(0xFF51B6C8),
                      borderRadius: BorderRadius.all(Radius.circular(10))
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 10,horizontal: 10),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "${widget.data["title"]}  % Off",
                            style: const TextStyle(
                              fontWeight: FontWeight.w900,
                              fontSize: 18,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ).px4(),
                    ),
                  ),
                ),
                Positioned(
                  bottom: 0,
                  left: 0,
                  child: Container(
                    width: MediaQuery.of(context).size.width-64,
                    alignment: Alignment.center,
                    decoration: const BoxDecoration(
                      color: Colors.white,
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          vertical: 12, horizontal: 10),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              SizedBox(height: 8,),
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Text(
                                  widget.data["subTitle"],
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w600,
                                    fontSize: 14,
                                    color: Colors.black,
                                  ),
                                ),
                              ),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  Container(
                                    child: const Icon(
                                      Icons.location_on,
                                      color: Color.fromARGB(133, 230, 32, 18),size: 20,
                                    ),
                                  ),
                                  (widget.data["dis"].toString() + " Km")
                                      .text
                                      .color(Colors.black)
                                      .make(),
                                ],
                              ),
                            ],
                          ),
                          Padding(
                            padding: const EdgeInsets.only(top: 16.0),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Text(
                                  "VIEW PROFILE",
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: kLoadingScreenTextColor,
                                  ),
                                ),
                                SizedBox(width: 16,),
                                const Icon(
                                  Icons.arrow_forward_ios,
                                  size: 16,
                                  color: Colors.black,
                                ),
                              ],
                            ),
                          ),

                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          )),
    );
  }
}
