import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:shimmer/shimmer.dart';

class BannerAdWidget extends StatefulWidget {

  AdSize adSize;

  double height;

  double width;

  BannerAdWidget({required this.adSize, required this.height, required this.width});


  @override
  _BannerAdWidgetState createState() => _BannerAdWidgetState();
}

class _BannerAdWidgetState extends State<BannerAdWidget> {
  late BannerAd _bannerAd;

  bool loaded=false;
  @override
  void initState() {
    super.initState();
    _bannerAd = BannerAd(
      adUnitId: "ca-app-pub-3940256099942544/6300978111", // Replace with your ad unit ID  //TODO
    size: widget.adSize,
      request: AdRequest(),
      listener: BannerAdListener(),
    );

    _bannerAd.load().then((value){
      setState(() {
        loaded=true;
      });
    });
  }

  @override
  void dispose() {
    _bannerAd.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {

    return loaded ? Container(
      margin: EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: Colors.white,
      ),
      alignment: Alignment.center,
      child: AdWidget(ad: _bannerAd),
      width: double.infinity,
      // height: MediaQuery.of(context).size.height/3,
      height: widget.height,
    ) : Container(height:widget.height,width: double.infinity,child: Shimmer.fromColors(enabled: true,child: SizedBox(height: 200,width: 200,child: Container(color: Colors.red,),), baseColor: Colors.black12, highlightColor: Colors.white10,));
  }
}
