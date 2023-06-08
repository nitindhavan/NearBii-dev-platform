// ignore_for_file: prefer_const_constructors, unused_import, unnecessary_null_comparison

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:nearbii/Model/catModel.dart';
import 'package:nearbii/Model/notifStorage.dart';
import 'package:nearbii/components/search_bar.dart';
import 'package:nearbii/constants.dart';
import 'package:nearbii/screens/bottom_bar/home/categories/category_list.dart';
import 'package:nearbii/screens/bottom_bar/home/categories/furniture_screen.dart';
import 'package:nearbii/screens/bottom_bar/home/categories/glasses_screen.dart';
import 'package:nearbii/screens/bottom_bar/home/categories/restaurants_screen.dart';
import 'package:nearbii/screens/bottom_bar/home/categories/shoes_screen.dart';
import 'package:nearbii/screens/service_slider/searchvendor.dart';
import 'package:nearbii/screens/speech_screen.dart';
import 'package:velocity_x/velocity_x.dart';

import '../../bottomBar/bottomBar.dart';

class CategoriesScreen extends StatefulWidget {
  const CategoriesScreen({Key? key}) : super(key: key);

  @override
  State<CategoriesScreen> createState() => _CategoriesScreenState();
}

class _CategoriesScreenState extends State<CategoriesScreen> {
  @override
  void initState() {
    getCategories();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    double height = MediaQuery.of(context).size.height;
    double width = MediaQuery.of(context).size.width;

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
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            //Categories label
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 34),
              child: Text(
                "Categories",
                style: TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 20,
                  color: kLoadingScreenTextColor,
                ),
              ),
            ),
            //search box
            Padding(
                padding: const EdgeInsets.only(top: 18, left: 34, right: 34),
                child: SearchBar(
                    onTypeSearch: true,
                    search: ((val) {
                      search(val);
                    }),
                    val: "")),
            SizedBox(
              height: height - 196,
              child: Padding(
                padding: const EdgeInsets.only(top: 25, bottom: 25),
                child: categories.isEmpty
                    ? CircularProgressIndicator().centered()
                    : ListView.separated(
                        itemCount: categories.length,
                        itemBuilder: (context, index) {
                          var item = categories[index];
                          return GestureDetector(
                            onTap: () {
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                    builder: (context) =>
                                        SearchVendor(item.name)),
                              );
                              print(item);
                            },
                            child: SizedBox(
                              height: 150,
                              child: Stack(
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.only(left: 20),
                                    child: Container(
                                      width: width,
                                      height: 130,
                                      decoration: BoxDecoration(
                                        color: kSignUpContainerColor,
                                        borderRadius: BorderRadius.only(
                                          topLeft: Radius.circular(20),
                                          bottomLeft: Radius.circular(20),
                                        ),
                                      ),
                                      child: Padding(
                                        padding: const EdgeInsets.only(
                                            left: 159, top: 20),
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              item.name.toString(),
                                              style: TextStyle(
                                                fontWeight: FontWeight.w700,
                                                fontSize: 24,
                                                color: Colors.white,
                                              ),
                                            ),
                                            Padding(
                                              padding: const EdgeInsets.only(
                                                  right: 40),
                                              child: RichText(
                                                text: TextSpan(
                                                  text: item.desc.toString(),
                                                  style: TextStyle(
                                                    fontWeight: FontWeight.w400,
                                                    fontSize: 13,
                                                    color: Colors.white,
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                  Positioned(
                                    bottom: -14,
                                    child: CircleAvatar(
                                      radius: 70,
                                      backgroundColor: Colors.white,
                                    ),
                                  ),
                                  Positioned(
                                    bottom: 20,
                                    left: 20,
                                    child: Container(
                                      width: 100,
                                      height: 80,
                                      decoration: BoxDecoration(
                                          borderRadius: BorderRadius.only(
                                            bottomLeft: Radius.circular(20),
                                          ),
                                          color: Colors.white),
                                      child: Image.network(
                                        item.image,
                                        fit: BoxFit.cover,
                                      ),
                                    ),
                                  ),
                                  Positioned(
                                    bottom: 34,
                                    right: 52,
                                    child: Container(
                                      width: 27,
                                      height: 27,
                                      decoration: BoxDecoration(
                                          borderRadius:
                                              BorderRadius.circular(5),
                                          color: Colors.white),
                                      child: Icon(
                                        Icons.arrow_forward_ios,
                                        size: 15,
                                        color: kLoadingScreenTextColor,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                        separatorBuilder: (context, index) => SizedBox(
                          height: 10,
                        ),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<CategoriesModel> categories = [];
  List<CategoriesModel> allCategories = [];
  getCategories() async {
    var b = await FirebaseFirestore.instance.collection("categories").get();
    for (var elemnt in b.docs) {
      if (elemnt != null) {
        var cat = CategoriesModel.fromMap(elemnt.data());
        categories.add(cat);
      }
    }
    allCategories = categories;
    setState(() {});
  }

  void search(val) {
    categories = [];
    for (var cat in allCategories) {
      if (cat.desc
              .toLowerCase()
              .contains(val.toString().trim().toLowerCase()) ||
          cat.name
              .toLowerCase()
              .contains(val.toString().trim().toLowerCase())) {
        categories.add(cat);
      }
    }
    setState(() {});
  }
}
