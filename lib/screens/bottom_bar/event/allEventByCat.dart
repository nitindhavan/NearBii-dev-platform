import 'package:flutter/material.dart';
import 'package:nearbii/constants.dart';
import 'package:nearbii/services/getEventByCat/getEventByCat.dart';

class allEventByCat extends StatefulWidget {
  final String cat;
  var pos;
  String city;
  allEventByCat(
      {required this.cat, required this.pos, Key? key, required this.city})
      : super(key: key);

  @override
  State<allEventByCat> createState() => _allEventByCatState();
}

class _allEventByCatState extends State<allEventByCat> {
  @override
  Widget build(BuildContext context) {
    return SafeArea(
        top: false,
        child: Scaffold(
          appBar: AppBar(
            title:Text(
              "Events in " + widget.cat.toString(),
              style: TextStyle(
                fontWeight: FontWeight.w700,
                fontSize: 20,
                color: kLoadingScreenTextColor,
              ),
            ),iconTheme: IconThemeData(color: Colors.black),),
          body: SizedBox(
            width: MediaQuery.of(context).size.width,
            height: MediaQuery.of(context).size.height,
            child: SingleChildScrollView(
                child: Column(
              children: [
                getEventByCat(context, MediaQuery.of(context).size.height,
                    widget.cat, widget.pos, widget.city),
              ],
            )),
          ),
        ));
  }
}
