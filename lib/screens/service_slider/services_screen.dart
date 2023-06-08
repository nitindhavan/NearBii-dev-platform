// ignore_for_file: prefer_const_constructors

import 'package:flutter/material.dart';
import 'package:nearbii/Model/notifStorage.dart';
import 'package:nearbii/components/search_bar.dart';
import 'package:nearbii/components/service_custom_card.dart';

import 'package:nearbii/screens/service_slider/more_services.dart';

import 'package:nearbii/screens/service_slider/searchvendor.dart';

import '../../Model/ServiceModel.dart';
import '../../constants.dart';
import "package:velocity_x/velocity_x.dart";

class ServiceScreen extends StatefulWidget {
  const ServiceScreen({Key? key}) : super(key: key);

  @override
  State<ServiceScreen> createState() => _ServiceScreenState();
}

class _ServiceScreenState extends State<ServiceScreen> {
  var val = "";
  List<ServiceModel> services = [];
  List<ServiceModel> allServices = [];
  getServices() async {
    services = await Notifcheck.api.getServices();
    allServices = await Notifcheck.api.getServices();
    setState(() {});
  }

  @override
  void initState() {
    // TODO: implement initState
    getServices();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;
    return Material(
      child: Scaffold(
        appBar: AppBar(
          leading: Row(
            children: [
              const SizedBox(
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
        body: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SearchBar(
                  onTypeSearch: true,
                  search: (val) async {
                    services = [];
                    if (val.toString().isEmptyOrNull) {
                      services = allServices;
                    } else {
                      for (var sevice in allServices) {
                        for (var subcat in sevice.subcategory) {
                          if (subcat.title
                              .toString()
                              .toLowerCase()
                              .contains(val.toString().toLowerCase())) {
                            services.add(sevice);
                          }
                        }
                      }
                    }
                    setState(() {});
                  },
                  val: "",
                ),
                const SizedBox(
                  height: 23,
                ),
                SizedBox(
                  height: 15,
                  width: double.infinity,
                  child: ListView.builder(
                    itemCount: services.length,
                    shrinkWrap: true,
                    scrollDirection: Axis.horizontal,
                    itemBuilder: (context, index) {
                      var data = services[index];
                      return Row(
                        children: [
                          GestureDetector(
                              onTap: () {
                                Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) =>
                                            MoreServices(index: data)));
                              },
                              child: Text(data.id)),
                          const SizedBox(
                            width: 16,
                          ),
                        ],
                      );
                    },
                  ),
                ),
                const SizedBox(
                  height: 28,
                ),
                SizedBox(
                    width: double.infinity,
                    child: ListView.builder(
                      itemCount: services.length,
                      shrinkWrap: true,
                      physics: NeverScrollableScrollPhysics(),
                      itemBuilder: (context, index) {
                        var service = services[index];
                        return true
                            ? Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  GestureDetector(
                                    onTap: () {
                                      Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                              builder: (context) =>
                                                  MoreServices(
                                                      index: service)));
                                    },
                                    child: Text(
                                        service.id == "ZZMore"
                                            ? service.id.substring(2)
                                            : service.id,
                                        style: TextStyle(
                                          fontSize: 18,
                                        )),
                                  ),
                                  const SizedBox(
                                    height: 12,
                                  ),
                                  GridView.builder(
                                    gridDelegate:
                                        SliverGridDelegateWithMaxCrossAxisExtent(
                                            maxCrossAxisExtent: 200,
                                            childAspectRatio: 2.5,
                                            crossAxisSpacing: 20,
                                            mainAxisSpacing: 20),
                                    shrinkWrap: true,
                                    physics: NeverScrollableScrollPhysics(),
                                    itemCount: service.subcategory.length >= 6
                                        ? 6
                                        : service.subcategory.length,
                                    itemBuilder: (context, indx) {
                                      return indx < 5
                                          ? ServiceCustomCard(
                                              title: service
                                                  .subcategory[indx].title,
                                              image: service.subcategory[indx]
                                                      .image ??
                                                  '',
                                            ).onInkTap(() {
                                              Navigator.push(
                                                  context,
                                                  MaterialPageRoute(
                                                      builder: (context) =>
                                                          SearchVendor(service
                                                              .subcategory[indx]
                                                              .title)));
                                            })
                                          : ServiceCustomCard(
                                              dot: true,
                                            ).onInkTap(() {
                                              Navigator.push(
                                                  context,
                                                  MaterialPageRoute(
                                                      builder: (context) =>
                                                          MoreServices(
                                                              index: service)));
                                            });
                                    },
                                  ),
                                  const SizedBox(
                                    height: 12,
                                  ),
                                ],
                              )
                            : SizedBox(height: 0);
                      },
                    )),
                const SizedBox(
                  height: 12,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
