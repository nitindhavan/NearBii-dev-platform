import 'dart:async';
import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dropdown_search/dropdown_search.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:nearbii/Model/notifStorage.dart';
import 'package:nearbii/components/banner_ad.dart';
import 'package:nearbii/constants.dart';
import 'package:nearbii/screens/bottom_bar/home/drawer/advertise/post_offer_screen.dart';
import 'package:nearbii/screens/bottom_bar/profile/vendor_profile_screen.dart';
import 'package:nearbii/services/getOffers/getOffers.dart';
import 'package:nearbii/services/getcity.dart';
import 'package:swipe_refresh/swipe_refresh.dart';
import 'package:velocity_x/velocity_x.dart';

import '../../Model/ServiceModel.dart';

bool isUserProfile = true;

class OffersScreen extends StatefulWidget {
  OffersScreen({Key? key,required this.onlyCurrentVendor,this.uid, this.offerKey}) : super(key: key);
  final bool onlyCurrentVendor;
  String? offerKey;
  final String? uid;
  @override
  State<OffersScreen> createState() => _OffersScreenState();
}

class _OffersScreenState extends State<OffersScreen> {
  Position? pos;
  bool isLoading = true;

  var selectedcat = "All Category";

  var controller = ScrollController();
  @override
  void initState() {

    refersh();
    loadUser();
    super.initState();
  }

  swipe() {
    refersh();
  }

  void refersh() async {
    await load();
    await getCity();
    await getCat();
    await _getOffers(refersh: true);
  }

  load() async {
    Position poss = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);

    if (mounted) {
      setState(() {
        pos = poss;
        isLoading = false;
      });
    }
  }

  loadUser() async {
    bool user = await Notifcheck.api.isUser();
    log(user.toString(), name: "checkuser");
    isUserProfile = user;
    setState(() {
      log("loaded");
      isLoading = false;
    });
  }

  String city = "";
  getCity() async {
    getCat();
    city = await getcurrentCityFromLocation();
  }

  List<String> filter = ["High", "Low", "Latest"];
  String applied = "High";
  List<ServiceModel> cat = [];
  Future<void> getCat() async {
    cat = await Notifcheck.api.getServices();
    cat.insert(
        0,
        ServiceModel(
            id: "All Category",
            image: "image",
            subcategory: [],
            isActive: true,
            order: 0));
  }

  var lastDocument;
  List<Widget> messageWidgets = [];

  _getOffers({bool refersh = false}) async {
    _controller.sink.add(SwipeRefreshState.loading);
    setState(() {});
    if (refersh) {
      messageWidgets = [];
      lastDocument = null;
      widget.offerKey=null;
      more = true;
    }
    log((applied == "High" ? true : false).toString(), name: "discount");
    log((applied).toString(), name: "discount");
    Query<Map<String, dynamic>> snap =
        FirebaseFirestore.instance.collection('Offers');
    switch (applied) {
      case "High":
        snap = snap.orderBy("off", descending: true);
        break;
      case "Latest":
        snap = snap.orderBy("date", descending: true);
        break;
      case "Low":
        snap = snap.orderBy("off", descending: false);
        break;
    }

    if(widget.offerKey!=null){
      snap.where('__name__' ,isEqualTo:widget.offerKey);
    }

    if (city != 'All India') {
      snap = snap.where("city", isEqualTo: city);

    }
    if (selectedcat != "All Category") {
      snap = snap.where("category", isEqualTo: selectedcat);
    }

    List ndmta = [];
    if (lastDocument != null) {
      snap = snap.startAfterDocument(lastDocument);
    }
    QuerySnapshot<Map<String, dynamic>> snapshot = await snap.limit(5).get();

    var dmta = snapshot.docs;
    if (snapshot.docs.isNotEmpty) {
      lastDocument = snapshot.docs.last;
      more = true;
    } else {
      more = false;
    }
    for (var ele in dmta) {
      Map deta = ele.data();

      if(ele.data()["validity"]==null || ele.data()["validity"] < DateTime.now().millisecondsSinceEpoch){
        await FirebaseFirestore.instance.collection('Offers').doc(ele.id).delete();
        continue;
      }
      var dis = Geolocator.distanceBetween(
            pos!.latitude,
            pos!.longitude,
            ele.data()["location"]["lat"],
            ele.data()["location"]["long"],
          ) /
          1000;
      deta.addEntries({"dis": dis.toDoubleStringAsFixed(digit: 3)}.entries);

      deta.addEntries({"ref": ele.reference}.entries);
      log(ele.reference.toString());
      if(widget.onlyCurrentVendor){
        if(deta['uid']==widget.uid) {
          ndmta.add(deta);
        }
      }else{
        ndmta.add(deta);
      }
      log(deta.toString());
    }

    ndmta.sort((a, b) => (double.tryParse(a["dis"]!)?.compareTo(double.tryParse(a["dis"])!))!);
    List<Widget> widgets = ndmta.map<Widget>((m) {
      final data = m as dynamic;
      var dis = 5;
      var ts = data['date'];
      DateTime dt = DateTime.fromMillisecondsSinceEpoch(ts);
      final difference = DateTime.now().difference(dt).inMinutes;
      double limit = 43800;
      print(difference);
      if (difference <= limit) {
        return InkWell(
            onTap: () async {
              Future.delayed(const Duration(milliseconds: 5));
              await Navigator.of(context)
                  .push(MaterialPageRoute(builder: (context) {
                return VendorProfileScreen(
                  id: data["uid"],
                  isVisiter: true,
                );
              }));
            },
            child: offerBox(
              data: data,
            ));
      } else {
        m["ref"].delete();
      }

      return Container();
    }).toList();
    messageWidgets.addAll(widgets);
    _controller.sink.add(SwipeRefreshState.hidden);
    setState(() {});
  }

  final _controller = StreamController<SwipeRefreshState>.broadcast();

  bool float=true;

  Stream<SwipeRefreshState> get _stream => _controller.stream;
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: NotificationListener<ScrollEndNotification>(
          onNotification: (scrollEnd) {
            final metrics = scrollEnd.metrics;
            if (metrics.atEdge) {
              bool isTop = metrics.pixels == 0;
              if (isTop) {
                print('At the top');
              } else {
                print("botom");
                _getOffers();
              }
            }
            return true;
          },
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 16,),
              // Padding(
              //   padding: const EdgeInsets.symmetric(horizontal: 16),
              //   child: Text(
              //     "Offers",
              //     style: TextStyle(
              //       fontWeight: FontWeight.w700,
              //       fontSize: 20,
              //       color: kLoadingScreenTextColor,letterSpacing: 2
              //     ),
              //   ),
              // ),

              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(left: 8.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Icon(Icons.location_on,size: 32,color: kSignInContainerColor,),
                        SizedBox(width: 8,),
                        Container(
                          height: 40,
                          width: 100,
                          // decoration: BoxDecoration(
                          //     borderRadius: BorderRadius.circular(10),
                          //     border: Border.all(
                          //         color:
                          //         Color.fromARGB(255, 81, 182, 200))),
                          child: Center(
                            child: DropdownSearch<String>(
                              dropdownButtonProps: DropdownButtonProps(
                                padding: EdgeInsets.all(0),
                              ),
                              onBeforePopupOpening: (v) async {
                                setState(() {
                                  float=false;
                                });
                                return true;
                              },
                              //mode of dropdown
                              //list of dropdown items
                              popupProps: PopupProps.bottomSheet(
                                onDismissed: (){
                                  setState(() {
                                    float=true;
                                  });
                                },
                                title: Divider(
                                  height: 10,
                                  thickness: 2,
                                  color:
                                  Color.fromARGB(255, 81, 182, 200),
                                ).px(128).py1(),
                                interceptCallBacks: true,
                                showSelectedItems: true,
                                searchDelay: Duration.zero,
                                searchFieldProps: TextFieldProps(
                                  decoration: InputDecoration(
                                      icon: Icon(Icons.search),
                                      hintText: "Search City",
                                      border: OutlineInputBorder(
                                          borderRadius:
                                          BorderRadius.circular(20))),
                                ),
                                bottomSheetProps: BottomSheetProps(
                                    backgroundColor: Color.fromARGB(
                                        255, 232, 244, 247),
                                    elevation: 10,
                                    shape: RoundedRectangleBorder(
                                        borderRadius:
                                        BorderRadius.circular(20))),
                                showSearchBox: true,
                              ),
                              dropdownDecoratorProps:
                              DropDownDecoratorProps(
                                  baseStyle:
                                  TextStyle(
                                      overflow: TextOverflow
                                          .ellipsis,fontSize: 20,fontWeight: FontWeight.bold),
                                  textAlignVertical: TextAlignVertical
                                      .center,
                                  textAlign: TextAlign.center,
                                  dropdownSearchDecoration:
                                  InputDecoration.collapsed(
                                      floatingLabelAlignment:
                                      FloatingLabelAlignment
                                          .center,
                                      floatingLabelBehavior:
                                      FloatingLabelBehavior
                                          .auto,
                                      focusColor:
                                      Colors.lightBlue,
                                      hintText: 'City')),
                              items: CityList.ListCity.map((e) {
                                return e.name;
                              }).toList(),
                              onChanged: ((value) {
                                if (value == null) return;
                                city = value;
                                _getOffers(refersh: true);
                              }),
                              //show selected item\
                              selectedItem: city,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ).px4(),

              SizedBox(height: 8,),
              //Offers label
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(left: 16.0),
                        child: Text("Sort By:",style: TextStyle(color: Colors.black45),),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(left: 16.0),
                        child: Container(
                          height: 40,
                          // decoration: BoxDecoration(
                          //     borderRadius: BorderRadius.circular(10),
                          //     border: Border.all(
                          //         color:
                          //         Color.fromARGB(255, 81, 182, 200))),
                          child: DropdownSearch<String>(
                              dropdownButtonProps: DropdownButtonProps(
                                padding: EdgeInsets.all(0),
                              ),
                              popupProps: PopupProps.menu(
                                fit: FlexFit.loose,
                                onDismissed: (){
                                  setState(() {
                                    float=true;
                                  });
                                }
                              ),

                              // onBeforeChange: (v,v1)async {
                              //   setState(() {
                              //     float=true;
                              //     print(v);
                              //   });
                              //   return true;
                              // },

                              dropdownDecoratorProps:
                              DropDownDecoratorProps(
                                  baseStyle:
                                  TextStyle(
                                      overflow: TextOverflow
                                          .ellipsis),
                                  textAlignVertical:
                                  TextAlignVertical.center,
                                  textAlign: TextAlign.start,
                                  dropdownSearchDecoration:
                                  InputDecoration.collapsed(
                                      floatingLabelAlignment:
                                      FloatingLabelAlignment
                                          .center,
                                      floatingLabelBehavior:
                                      FloatingLabelBehavior
                                          .auto,
                                      focusColor:
                                      Colors.lightBlue,
                                      hintText: 'City')),
                              selectedItem: applied,
                              items: filter.map((e) => e).toList(),
                              onChanged: ((value) {
                                if (value == null) return;
                                applied = value.toString();
                                _getOffers(refersh: true);
                              }),),
                        ),
                      ),
                    ],
                  ).px4().expand(),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Text("Categories:",style: TextStyle(color: Colors.black45),),
                      Container(
                        height: 40,
                        child: DropdownSearch<String>(
                            dropdownButtonProps: DropdownButtonProps(
                              padding: EdgeInsets.all(0),
                            ),
                            onBeforePopupOpening: (v) async{
                              setState(() {
                                float=false;
                              });
                              return true;
                            },
                            //mode of dropdown
                            //list of dropdown items
                            popupProps: PopupProps.bottomSheet(
                              title: Divider(
                                height: 10,
                                thickness: 2,
                                color:
                                Color.fromARGB(255, 81, 182, 200),
                              ).px(128).py2(),
                              onDismissed: (){
                                setState(() {
                                  float=true;
                                });
                              },
                              interceptCallBacks: true,
                              showSelectedItems: true,
                              searchDelay: Duration.zero,
                              searchFieldProps: TextFieldProps(
                                decoration: InputDecoration(
                                    icon: Icon(Icons.search),
                                    hintText: "Search Category",
                                    border: OutlineInputBorder(
                                        borderRadius:
                                        BorderRadius.circular(
                                            20))),
                              ),
                              bottomSheetProps: BottomSheetProps(
                                  backgroundColor: Color.fromARGB(
                                      255, 232, 244, 247),
                                  elevation: 10,
                                  shape: RoundedRectangleBorder(
                                      borderRadius:
                                      BorderRadius.circular(20)),
                              ),
                              showSearchBox: true,
                            ),
                            dropdownDecoratorProps:
                            DropDownDecoratorProps(
                                baseStyle:
                                TextStyle(
                                    overflow: TextOverflow
                                        .ellipsis),
                                textAlignVertical:
                                TextAlignVertical.center,
                                textAlign: TextAlign.start,
                                dropdownSearchDecoration:
                                InputDecoration.collapsed(
                                    floatingLabelAlignment:
                                    FloatingLabelAlignment
                                        .center,
                                    floatingLabelBehavior:
                                    FloatingLabelBehavior
                                        .auto,
                                    focusColor:
                                    Colors.lightBlue,
                                    hintText: 'City')),
                            selectedItem: selectedcat,
                            items: cat.map((e) => e.id).toList(),
                            onChanged: ((value) {
                              if (value == null) return;
                              selectedcat = value.toString();

                              _getOffers(refersh: true);
                            })),
                      ),
                    ],
                  ).px4().expand(),
                ],
              ).pOnly( top: 10, left: 8, right: 8),
              SizedBox(height: 8,),
              Divider(color: Colors.black26,),
              Expanded(
                child: SwipeRefresh.builder(
                    scrollController: controller,
                    itemCount: 1,
                    stateStream: _stream,
                    onRefresh: swipe,
                    itemBuilder: (BuildContext context, int index) {
                      return Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                            !isLoading && pos!=null
                                ? getOffers(context, pos!, city, applied, selectedcat)
                                : Center(child: CircularProgressIndicator()),
                        ],
                      ).pOnly(top: 20);
                    }),
              ),
            ],
          ),
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
        floatingActionButton: float ? Padding(
          padding: const EdgeInsets.all(16.0),
          child: !isUserProfile ? FloatingActionButton.extended(onPressed: (){
            Navigator.push(context, MaterialPageRoute(builder: (context)=> PostOfferScreen()));
          }, label: Text("Add Offers"),icon: Container(
            padding: EdgeInsets.all(4),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(50),
                border: Border.all(color: Colors.white)
              ),child: Icon(Icons.percent,size: 16,)),backgroundColor: kSignInContainerColor,) : SizedBox(),
        ) : Container(),
      ),
    );
  }

  Widget getOffers(BuildContext context, Position pos, String city,
      String applied, String selectedcat) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.only(top: 10),
          child: SizedBox(
            child: Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: ListView.separated(
                  controller: controller,
                  // physics: NeverScrollableScrollPhysics(),
                  shrinkWrap: true,
                  itemCount: messageWidgets.length + 1,
                  itemBuilder: (context, index) {
                    if (messageWidgets.length < 2) more = false;
                    return index < messageWidgets.length
                        ? Column(
                          children: [
                            messageWidgets[index],
                            if(index % 5 ==4) Card(
                              margin: EdgeInsets.only(left: 16,right: 16,bottom: 16),
                              shadowColor: const Color.fromARGB(255, 81, 182, 200),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20),
                              ),
                              elevation: 4,
                              child:BannerAdWidget(adSize: AdSize(width: 300, height: 250), height:MediaQuery.of(context).size.height/2, width: double.infinity),
                            )
                          ],
                        )
                        : (more
                                ? CircularProgressIndicator()
                                : "No More Offers".text.make())
                            .centered()
                            .py8();
                  },
                  separatorBuilder: (context, index) => const SizedBox(
                    height: 15,
                  ),
                )),
          ),
        ),
      ],
    );
  }
  bool more = true;
}
