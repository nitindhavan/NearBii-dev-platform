// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables, prefer_conditional_assignment, unnecessary_null_comparison, avoid_print, unused_import, must_be_immutable, use_key_in_widget_constructors, avoid_init_to_null

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:nearbii/Model/catModel.dart';
import 'package:nearbii/Model/notifStorage.dart';
import 'package:nearbii/Model/vendormodel.dart';
import 'package:nearbii/components/search_bar.dart';
import 'package:nearbii/constants.dart';
import 'package:nearbii/screens/bottom_bar/profile/vendor_profile_screen.dart';
import 'package:nearbii/screens/speech_screen.dart';
import 'package:velocity_x/velocity_x.dart';

import '../../bottomBar/bottomBar.dart';

class CategoryItem extends StatefulWidget {
  CategoriesModel item;
  CategoryItem(this.item);

  @override
  State<CategoryItem> createState() => _CategoryItemState();
}

class _CategoryItemState extends State<CategoryItem> {
  @override
  void initState() {
    getCategories();
    super.initState();
  }

  int x = 0;
  @override
  Widget build(BuildContext context) {
    double height = MediaQuery.of(context).size.height;
    return Scaffold(
      bottomNavigationBar: addBottomBar(context),
      appBar: AppBar(
        leading: Row(
          children: [
            SizedBox(
              width: 35,
            ),
            GestureDetector(
              onTap: () => Navigator.pop(context),
              child: Icon(
                Icons.arrow_back_ios,
                size: 20,
                color: kLoadingScreenTextColor,
              ),
            ),
          ],
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 29),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              //Clothes label
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 5),
                child: Text(
                  widget.item.name,
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 20,
                    color: kLoadingScreenTextColor,
                  ),
                ),
              ),
              //search box

              Padding(
                  padding: const EdgeInsets.only(top: 18, left: 8, right: 8),
                  child: SearchBar(search: search, val: "")),
              SizedBox(
                height: height - 196,
                child: Padding(
                  padding: const EdgeInsets.only(top: 25),
                  child: cat.isEmpty
                      ? x == 0
                          ? CircularProgressIndicator().centered()
                          : "Nothing to Shfgfow".text.makeCentered()
                      : ListView.separated(
                          itemCount: cat.length,
                          itemBuilder: (context, index) {
                            var item = cat[index];
                            return GestureDetector(
                              onTap: () => Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (context) => VendorProfileScreen(
                                    id: item.userId!,
                                    isVisiter: true,
                                  ),
                                ),
                              ),
                              child: Material(
                                elevation: 1,
                                borderRadius: BorderRadius.circular(5),
                                child: Container(
                                  height: 290,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(5),
                                  ),
                                  child: Stack(
                                    children: [
                                      Container(
                                        decoration: BoxDecoration(
                                          image: DecorationImage(
                                            image: NetworkImage(
                                              item.businessImage.isEmptyOrNull
                                                  ? Notifcheck.defCover
                                                  : item.businessImage,
                                            ),
                                            fit: BoxFit.fill,
                                          ),
                                        ),
                                      ),
                                      Positioned(
                                        bottom: 0,
                                        right: 5,
                                        left: 5,
                                        child: Container(
                                          height: 104,
                                          decoration: BoxDecoration(
                                            color: Colors.white,
                                            borderRadius: BorderRadius.only(
                                              bottomLeft: Radius.circular(5),
                                              bottomRight: Radius.circular(5),
                                            ),
                                          ),
                                          child: Padding(
                                            padding: const EdgeInsets.all(10.0),
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Row(
                                                  children: [
                                                    Text(
                                                      item.businessName,
                                                      style: TextStyle(
                                                        fontWeight:
                                                            FontWeight.w700,
                                                        fontSize: 20,
                                                        color: Colors.black,
                                                      ),
                                                    ),
                                                    Spacer(),
                                                    Container(
                                                      height: 18,
                                                      width: 36,
                                                      decoration: BoxDecoration(
                                                        color:
                                                            kSignInContainerColor,
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(5),
                                                      ),
                                                      child: Row(
                                                        mainAxisAlignment:
                                                            MainAxisAlignment
                                                                .center,
                                                        children: [
                                                          Text(
                                                            "4.0",
                                                            style: TextStyle(
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w700,
                                                              fontSize: 12,
                                                              color:
                                                                  Colors.white,
                                                            ),
                                                          ),
                                                          Icon(
                                                            Icons.star,
                                                            size: 12,
                                                            color: Colors.white,
                                                          )
                                                        ],
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                                Row(
                                                  children: [
                                                    Text(
                                                      item.bussinesDesc,
                                                      style: TextStyle(
                                                        fontWeight:
                                                            FontWeight.w400,
                                                        fontSize: 14,
                                                        color: kHintTextColor,
                                                      ),
                                                    ),
                                                    Spacer(),
                                                    Text(
                                                      "₹300 for one",
                                                      style: TextStyle(
                                                        fontWeight:
                                                            FontWeight.w400,
                                                        fontSize: 10,
                                                        color: kHintTextColor,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                                Padding(
                                                  padding:
                                                      const EdgeInsets.only(
                                                          top: 5, bottom: 8),
                                                  child: Container(
                                                    height: 1,
                                                    width: double.infinity,
                                                    color:
                                                        kHomeScreenServicesContainerColor,
                                                  ),
                                                ),
                                                Row(
                                                  children: [
                                                    Text(
                                                      "Open Now",
                                                      style: TextStyle(
                                                        fontWeight:
                                                            FontWeight.w700,
                                                        fontSize: 12,
                                                        color:
                                                            kSignInContainerColor,
                                                      ),
                                                    ),
                                                    Spacer(),
                                                    Text(
                                                      item.distance.toString(),
                                                      style: TextStyle(
                                                        fontWeight:
                                                            FontWeight.w400,
                                                        fontSize: 10,
                                                        color: kHintTextColor,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                                SizedBox(
                                                  height: 3,
                                                ),
                                                Text(
                                                  "${item.openTime} - ${item.closeTime}",
                                                  style: TextStyle(
                                                    fontWeight: FontWeight.w400,
                                                    fontSize: 10,
                                                    color: kHintTextColor,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ),
                                      Positioned(
                                        top: 20,
                                        right: 20,
                                        child: GestureDetector(
                                          onTap: () {},
                                          child: Container(
                                            width: 30,
                                            height: 30,
                                            decoration: BoxDecoration(
                                              shape: BoxShape.circle,
                                              color: Colors.white,
                                            ),
                                            child: Icon(
                                              Icons.favorite_border_outlined,
                                              size: 20,
                                              color: kLoadingScreenTextColor,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            );
                          },
                          separatorBuilder: (context, index) => SizedBox(
                            height: 30,
                          ),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  List<VendorModel> catAll = [];
  List<VendorModel> cat = [];
  var pos = null;
  getCategories() async {
    if (pos == null) {
      pos = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high);
    }
    var b = await FirebaseFirestore.instance.collection("vendor").get();
    for (var elemtn in b.docs) {
      if (elemtn != null) {
        print(elemtn.data());
        var b = VendorModel.fromMap(elemtn.data());
        if (b.businessCat
                .toLowerCase()
                .contains(widget.item.name.toLowerCase()) ||
            b.bussinesDesc
                .toLowerCase()
                .contains(widget.item.name.toLowerCase()) ||
            b.businessSubCat
                .toLowerCase()
                .contains(widget.item.name.toLowerCase())) {
          b.distance = Geolocator.distanceBetween(pos.latitude, pos.longitude,
              b.businessLocation.lat, b.businessLocation.long);
          catAll.add(b);
        }
      }
    }
    if (mounted) {
      setState(() {
        x = 1;
        cat = catAll;
      });
    }
  }

  search(String val) {
    cat = [];
    for (var elemn in catAll) {
      if (elemn.businessName.toLowerCase().contains(val.toLowerCase()) ||
          elemn.bussinesDesc.toLowerCase().contains(val.toLowerCase()) ||
          elemn.businessSubCat.toLowerCase().contains(val.toLowerCase())) {
        cat.add(elemn);
      }
    }
    setState(() {});
  }
}
