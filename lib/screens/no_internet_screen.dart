import 'package:flutter/material.dart';
import 'package:nearbii/constants.dart';

class NoInternetScreen extends StatefulWidget {
  const NoInternetScreen({Key? key}) : super(key: key);

  @override
  State<NoInternetScreen> createState() => _NoInternetScreenState();
}

class _NoInternetScreenState extends State<NoInternetScreen> {
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
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 58),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              //no internet label
              Text(
                "No internet connection",
                style: TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 20,
                  color: kLoadingScreenTextColor,
                ),
              ),
              //image
              Image.asset(
                'assets/images/no_internet/no_connection.png',
              ),
              //description
              Text(
                "We’re sorry, looks like your internet connection is off. Make sure to turn it on and refresh the page.",
                style: TextStyle(
                  fontWeight: FontWeight.w200,
                  fontSize: 16,
                  color: kLoadingScreenTextColor,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(
                height: 50,
              ),
              //refresh button
              Center(
                child: GestureDetector(
                  onTap: () {},
                  child: Container(
                    height: 50,
                    width: 128,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(5),
                      color: kSignInContainerColor,
                    ),
                    child: const Center(
                      child: Text(
                        "Refresh",
                        style: TextStyle(
                          fontWeight: FontWeight.w400,
                          fontSize: 20,
                          color: Colors.white,
                        ),
                      ),
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
}
