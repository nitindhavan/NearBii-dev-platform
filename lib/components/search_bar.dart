import 'dart:developer';

import 'package:avatar_glow/avatar_glow.dart';
import 'package:flutter/material.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:velocity_x/velocity_x.dart';

const kTextFieldDecoration = InputDecoration(
  hintText: 'Enter the value',
  hintStyle: TextStyle(color: Color(0xffCECECE), fontSize: 16),
  contentPadding: EdgeInsets.symmetric(vertical: 8.0, horizontal: 20.0),
  border: OutlineInputBorder(
    borderRadius: BorderRadius.all(Radius.circular(10.0)),
  ),
  enabledBorder: OutlineInputBorder(
    borderSide: BorderSide(color: Color(0xff9B9B9B), width: 1.0),
    borderRadius: BorderRadius.all(Radius.circular(10.0)),
  ),
  focusedBorder: OutlineInputBorder(
    borderSide: BorderSide(color: Color(0xff9B9B9B), width: 2.0),
    borderRadius: BorderRadius.all(Radius.circular(10.0)),
  ),
);

class SearchBar extends StatefulWidget {
  String val;
  SearchBar(
      {Key? key,
      required this.search,
      this.onTypeSearch = false,
      required this.val})
      : super(key: key);

  final Function search;
  final bool onTypeSearch;

  @override
  State<SearchBar> createState() => _SearchBarState();
}

class _SearchBarState extends State<SearchBar> {
  final TextEditingController searchController = TextEditingController();
  String searchQuery = '';
  late stt.SpeechToText speech;
  bool listening = false;
  String text = "";
  double confidence = 1.0;
  @override
  void initState() {
    speech = stt.SpeechToText();
    searchController.addListener(() {
      // setState(() {
      //   searchQuery = searchController.text;
      //   widget.search(searchQuery);
      // });
    });
    if (widget.val.isNotEmpty) {
      searchQuery = widget.val;
      searchController.text = widget.val;
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      child: Stack(
        alignment: Alignment.center,
        children: [
          const Align(
            alignment: Alignment.centerLeft,
            child: Hero(
              tag: "searchIcon",
              child: Icon(
                Icons.search,
                color: Colors.black,
              ),
            ),
          ).pOnly(left: 5, right: 5),
          TextField(
            controller: searchController,
            decoration: kTextFieldDecoration.copyWith(
                contentPadding: const EdgeInsets.only(left: 30),
                hintText: 'Search',
                hintStyle: const TextStyle(fontSize: 14)),
            onChanged: (value) {
              if (widget.onTypeSearch) {
                searchQuery = searchController.text;
                widget.search(searchQuery);
              }
            },
            onEditingComplete: () {
              searchQuery = searchController.text;
              widget.search(searchQuery);
              FocusScope.of(context).requestFocus(FocusNode());
            },
          ),
          Align(
            alignment: Alignment.centerRight,
            child: SizedBox(
              height: 30,
              width: 50,
              child: AvatarGlow(
                animate: listening,
                glowColor: Colors.amber,
                duration: const Duration(milliseconds: 2000),
                repeat: true,
                repeatPauseDuration: const Duration(milliseconds: 100),
                endRadius: 100,
                child: Hero(
                  tag: "searchMic",
                  child:
                      Icon(listening ? Icons.mic : Icons.mic_off).onInkTap(() {
                    listening = !listening;
                    print(listening);
                    listen();
                  }),
                ),
              ),
            ),
          )
        ],
      ),
    );
  }

  listen() async {
    if (listening) {
      bool avaliable = await speech.initialize(
          onStatus: (val) => print(val), onError: (val) => print(val));
      if (avaliable) {
        setState(() {
          listening = true;
        });
        speech.errorListener = (error) {
          setState(() {
            listening = speech.isListening;
          });
        };
        speech.listen(onResult: ((result) {
          setState(() {
            print(true);
            searchQuery = (result.recognizedWords);
            searchController.text = (result.recognizedWords);
            listening = speech.isListening;
            log(speech.isListening.toString(), name: "Speech");
            if (result.hasConfidenceRating && result.confidence > 0) {
              confidence = result.confidence;
            }
            if (!listening) {
              widget.search(searchQuery);
            }
          });
        }));
      } else {
        setState(() {
          listening = speech.isListening;
        });
        log(listening.toString(), name: "speech");
        speech.stop();
        widget.search(searchQuery);
      }
    }
  }
}
