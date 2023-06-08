import 'package:flutter/material.dart';
import 'package:nearbii/constants.dart';
import 'package:nearbii/screens/bottom_bar/home/drawer/advertise/post_offer_screen.dart';
import 'package:nearbii/screens/createEvent/addEvent/addEvent.dart';
import 'package:nearbii/screens/plans/adsPlan/adsPlan.dart';

class AdvertiseScreen extends StatefulWidget {
  const AdvertiseScreen({Key? key}) : super(key: key);

  @override
  State<AdvertiseScreen> createState() => _AdvertiseScreenState();
}

class _AdvertiseScreenState extends State<AdvertiseScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 34),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              //Advertise Your Business! label
              Text(
                "Advertise Your Business!",
                style: TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 20,
                  color: kLoadingScreenTextColor,
                ),
              ),
              Image.asset(
                'assets/images/advertise/advertise_main_screen.png',
              ),
              GestureDetector(
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => const AddEvent(),
                  ),
                ),
                child: Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    border: Border.all(color: kAdvertiseContainerColor),
                    borderRadius: BorderRadius.circular(8.6),
                  ),
                  child: Padding(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 9, vertical: 10),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Container(
                          height: 87,
                          width: 87,
                          decoration: BoxDecoration(
                            color: kHomeScreenServicesContainerColor,
                            borderRadius: BorderRadius.circular(8.69),
                          ),
                          child: Icon(
                            Icons.add_sharp,
                            size: 80,
                            color: kAdvertiseContainerTextColor,
                          ),
                        ),
                        const SizedBox(
                          width: 8.69,
                        ),
                        Text(
                          "Create Event",
                          style: TextStyle(
                            fontWeight: FontWeight.w400,
                            fontSize: 15.64,
                            color: kAdvertiseContainerTextColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 20),
                child: GestureDetector(
                  onTap: () => Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => const adsPlan(),
                    ),
                  ),
                  child: Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      border: Border.all(color: kAdvertiseContainerColor),
                      borderRadius: BorderRadius.circular(8.6),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 9, vertical: 10),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Container(
                            height: 87,
                            width: 87,
                            decoration: BoxDecoration(
                              color: kHomeScreenServicesContainerColor,
                              borderRadius: BorderRadius.circular(8.69),
                            ),
                            child: Icon(
                              Icons.add_sharp,
                              size: 80,
                              color: kAdvertiseContainerTextColor,
                            ),
                          ),
                          const SizedBox(
                            width: 8.69,
                          ),
                          Text(
                            "Post Ad",
                            style: TextStyle(
                              fontWeight: FontWeight.w400,
                              fontSize: 15.64,
                              color: kAdvertiseContainerTextColor,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              GestureDetector(
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => const PostOfferScreen(),
                  ),
                ),
                child: Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    border: Border.all(color: kAdvertiseContainerColor),
                    borderRadius: BorderRadius.circular(8.6),
                  ),
                  child: Padding(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 9, vertical: 10),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Container(
                          height: 87,
                          width: 87,
                          decoration: BoxDecoration(
                            color: kHomeScreenServicesContainerColor,
                            borderRadius: BorderRadius.circular(8.69),
                          ),
                          child: Icon(
                            Icons.add_sharp,
                            size: 80,
                            color: kAdvertiseContainerTextColor,
                          ),
                        ),
                        const SizedBox(
                          width: 8.69,
                        ),
                        Text(
                          "Post Offer",
                          style: TextStyle(
                            fontWeight: FontWeight.w400,
                            fontSize: 15.64,
                            color: kAdvertiseContainerTextColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(
                height: 61,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
