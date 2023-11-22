import 'dart:developer';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:nearbii/Model/PlanModel.dart';
import 'package:nearbii/constants.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';
import 'package:velocity_x/velocity_x.dart';

import '../../../Model/notifStorage.dart';
import '../../../services/sendNotification/notificatonByCity/cityNotiication.dart';
import '../../../services/transactionupdate/transactionUpdate.dart';
import '../../bottom_bar/master_screen.dart';

int selectedItemPrice=0;
PlanModel? selectedPlan;

class PlanScreen extends StatefulWidget {
  const PlanScreen({Key? key,this.offerData,this.imagePath}) : super(key: key);

  final Map<String,dynamic>? offerData;
  final String? imagePath;
  @override
  State<PlanScreen> createState() => _PlanScreenState();

}

class _PlanScreenState extends State<PlanScreen> with SingleTickerProviderStateMixin{
  bool exploreMode=true;

  int balance = 0;
  String name = "";
  PlanModel? planModel;
  bool recommended=true;


  late final Razorpay _razorpay = Razorpay();

  void _handlePaymentSuccess(PaymentSuccessResponse response) async {
    setPlan(selectedPlan!,response.paymentId!);
  }

  void _handlePaymentError(PaymentFailureResponse response) {
    Fluttertoast.showToast(
        msg: "Payment Failed. Event Not Added",
        toastLength: Toast.LENGTH_SHORT);

    //saveToDB();
  }

  void _handleExternalWallet(ExternalWalletResponse response) {
    // Fluttertoast.showToast(
    //     msg: "EXTERNAL_WALLET: " + response.walletName!, toastLength: Toast.LENGTH_SHORT);
  }

  void makePayment(PlanModel model) async {

    //TODO:test key when deployment then change key
    var key='rzp_live_EaquIenmibGbWl';
    // var key = !kDebugMode || !kProfileMode
    //     ? 'rzp_test_q0FLy0FYnKC94V'
    //     : 'rzp_live_EaquIenmibGbWl';
    var options = {
      // 'key': 'rzp_test_q0FLy0FYnKC94V',
      'key': key,
      'amount': model.price! *100,
      // 'amount': 100,
      'name': 'NearBii Plan',
      'description': 'Join the large world',
      // 'retry': {'enabled': true, 'max_count': 1},
      // 'send_sms_hash': true,
      // 'prefill': {'contact': '8888888888', 'email': 'test@razorpay.com'},
      'external': {
        'wallets': ['paytm']
      }
    };

    try {
      _razorpay.open(options);
    } catch (e) {
      debugPrint('Error: e' + e.toString());
    }
  }

  loadPlan(){
    DocumentReference store=FirebaseFirestore.instance.collection('plans').doc(FirebaseAuth.instance.currentUser?.uid.substring(0,20));
    store.get().then((value){
      setState(() {
        planModel =PlanModel.fromSnapshot(value as DocumentSnapshot<Map<String,dynamic>>);
        if(planModel!=null && planModel!.validity!< DateTime.now().millisecondsSinceEpoch){
          store.delete();
          setState(() {
            planModel=null;
          });
        }
      });
    });
  }

  Future loadBalance() async {
    await FirebaseFirestore.instance
        .collection('User')
        .doc(FirebaseAuth.instance.currentUser?.uid.substring(0,20))
        .get()
        .then((value) {
      setState(() {
        balance = value.get("wallet");
        name = value.data()!["name"];
        log(name);
      });
    });
  }

  void buyWithPoints(BuildContext context) async {
    await loadBalance();

    if (balance <= 50) {
      Fluttertoast.showToast(
          msg: "You Don't have 50 coins", toastLength: Toast.LENGTH_LONG);
    } else {

      if(widget.offerData!=null) {
        Fluttertoast.showToast(
            msg: "Posting an offer", toastLength: Toast.LENGTH_LONG);

        Map<String, dynamic> wallet = {};

        wallet["wallet"] = balance - 50;

        await FirebaseFirestore.instance
            .collection('User')
            .doc(FirebaseAuth.instance.currentUser?.uid.substring(0, 20))
            .update(wallet)
            .then((value) async {
          updateWallet(FirebaseAuth.instance.currentUser?.uid.substring(0, 20),
              "Offer Posted", false, 50,
              DateTime
                  .now()
                  .millisecondsSinceEpoch, 0);
          var fileName = File(widget.imagePath!);

          Reference reference = FirebaseStorage.instance
              .ref()
              .child('vndor/offers/${fileName.absolute.toString()}');
          UploadTask uploadTask = reference.putFile(File(widget.imagePath!));
          TaskSnapshot snapshot = await uploadTask;

          var imageUrl = await snapshot.ref.getDownloadURL();

          var validity = DateTime.now().add(const Duration(days: 7));

          widget.offerData?["validity"] = validity.millisecondsSinceEpoch;

          widget.offerData?["offerImg"] = imageUrl;

          await FirebaseFirestore.instance
              .collection('Offers')
              .add(widget.offerData!)
              .then((value) async {
            String myid = value.id;
            Fluttertoast.showToast(msg: "OfferPosted");

            Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(builder: ((context) {
                  return const MasterPage(
                    currentIndex: 0,
                  );
                })), (route) => false);
          }).catchError((onError) async {
            Fluttertoast.showToast(
                msg: "cant take you to home page due to some error");

            Map<String, dynamic> wallet = {};

            wallet["wallet"] = balance;
            wallet["error"] = onError.toString();

            await FirebaseFirestore.instance
                .collection('User')
                .doc(FirebaseAuth.instance.currentUser?.uid.substring(0, 20))
                .update(wallet)
                .then((value) {
              Fluttertoast.showToast(msg: "Point debited");
            }).catchError((onError) {
              Fluttertoast.showToast(
                  msg: "Something went Wrong use Contact us");
            });
          });

          Fluttertoast.showToast(msg: "MySearchBar 50 point from Wallet");
          sendNotiicationByPin(
              widget.offerData?["title"],
              FirebaseAuth.instance.currentUser!.uid.substring(0, 20),
              "offer",
              name, imageUrl);
        });
      }else{
        Fluttertoast.showToast(
            msg: "Posting an Ad", toastLength: Toast.LENGTH_LONG);

        var uid=FirebaseAuth.instance.currentUser?.uid;
        Map<String, dynamic> wallet = {};

        wallet["wallet"] = balance - 50;

        await FirebaseFirestore.instance
            .collection('User')
            .doc(FirebaseAuth.instance.currentUser?.uid.substring(0, 20))
            .update(wallet)
            .then((value) async {
          updateWallet(FirebaseAuth.instance.currentUser?.uid.substring(0, 20),
              "Ad Posted", false, 50,
              DateTime
                  .now()
                  .millisecondsSinceEpoch, 0);
        });

          Map<String, dynamic> data = {};

          data["adsBuyTimestamp"] = DateTime.now().millisecondsSinceEpoch +
              const Duration(days: 1).inMilliseconds;
          data["isAds"] = true;

          await FirebaseFirestore.instance
              .collection('vendor')
              .doc(uid)
              .set(data, SetOptions(merge: true))
              .then((value) async {
            sendNotiicationAd(
                Notifcheck.currentVendor!.businessName,
                Notifcheck.currentVendor!.businessImage.isEmptyOrNull
                    ? Notifcheck.defCover
                    : Notifcheck.currentVendor!.businessImage);

            Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(builder: ((context) {
                  return const MasterPage(
                    currentIndex: 0,
                  );
                })), (route) => false);
          }).onError((error, stackTrace) async {});
      }
    }
  }

  Future<void> buyPlan(PlanModel model) async {
    // await loadBalance().then((value){
    //   // if(balance >= model.price!){
    //   //   setPlan(model);
    //   // }else{
    //   //   Fluttertoast.showToast(msg: "Insufficient Balance");
    //   // }
    //
    // });
    makePayment(model);
  }

  void setPlan(PlanModel model,String paymentID){
    updateTransatcion(FirebaseAuth.instance.currentUser?.uid.substring(0,20), model.planName, paymentID, "success",
        model.price, DateTime.now().millisecondsSinceEpoch);
    FirebaseFirestore.instance.collection('plans').doc(FirebaseAuth.instance.currentUser?.uid.substring(0,20)).set(model.toMap()).then((value) async {
      Fluttertoast.showToast(msg: "Plan purchased Successfully");
      Navigator.pop(context);
      sendPlanNotification();
    });
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, _handlePaymentSuccess);
    _razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, _handlePaymentError);
    _razorpay.on(Razorpay.EVENT_EXTERNAL_WALLET, _handleExternalWallet);
    loadPlan();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kSignInContainerColor,
      body: SafeArea(
      child: Column(
          children: [
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: kSignInContainerColor,
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  GestureDetector(onTap: (){
                    Navigator.pop(context);
                  },child: Icon(Icons.arrow_back,color: Colors.white,)),
                  SizedBox(width: 16,),
                  Text("Plans",style: TextStyle(color: Colors.white,fontSize: 24,fontWeight: FontWeight.bold),),
                ],
              ),
            ),
            if(exploreMode) Container(
              padding: const EdgeInsets.only(left: 8.0,right: 8,top: 4,bottom: 4),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  planModel==null ? Center(child: Container(child: Text("No active plan",style: TextStyle(color: Colors.white,fontWeight: FontWeight.bold,fontSize: 16),),height: 100,alignment: Alignment.center,)):Container(
                    margin: EdgeInsets.only(left: 2,right: 2,bottom: 16),
                    decoration: BoxDecoration(
                        color: Colors.white38,
                        borderRadius: BorderRadius.circular(10),
                        boxShadow: [BoxShadow(color: kSignInContainerColor,spreadRadius: selectedItemPrice!= 5999 ? 1: 3,)]
                    ),
                    padding: EdgeInsets.only(left: 16,right: 16,top: 24,bottom: 24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text("Current Plan : ${planModel?.planName}",style: TextStyle(fontWeight: FontWeight.bold,color: Colors.white,fontSize: 16),),
                          ],
                        ),
                        SizedBox(height: 24,),
                        Column(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.center,
                                    children: [
                                      Container(decoration: BoxDecoration(
                                          borderRadius: BorderRadius.circular(90),
                                          color: kSignInContainerColor
                                      ),height: 90,width: 90,alignment: Alignment.center,child: Text("${planModel!.offerPost!> 500 ? "Infinite" : planModel?.offerPost}",style: TextStyle(fontWeight: FontWeight.bold,fontSize: 16,color: Colors.white),)),
                                      SizedBox(height: 16,),
                                      Text("Offer Posts",style: TextStyle(fontWeight: FontWeight.bold,color: Colors.white),),

                                    ],
                                  ),
                                ),

                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.center,
                                    children: [
                                      Container(decoration: BoxDecoration(
                                          borderRadius: BorderRadius.circular(90),
                                          color: kSignInContainerColor
                                      ),height: 90,width: 90,alignment: Alignment.center,child: Text("${planModel!.offerPost!> 500 ? "Infinite" : planModel?.adPost}",style: TextStyle(fontWeight: FontWeight.bold,fontSize: 16,color: Colors.white),)),
                                      SizedBox(height: 16,),
                                      Text("Ad Posts",style: TextStyle(fontWeight: FontWeight.bold,color: Colors.white),),

                                    ],
                                  ),
                                ),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.center,
                                    children: [
                                      Container(decoration: BoxDecoration(
                                          borderRadius: BorderRadius.circular(90),
                                          color: kSignInContainerColor
                                      ),height: 90,width: 90,alignment: Alignment.center,child: Text("${Duration(milliseconds: planModel!.validity!-DateTime.now().millisecondsSinceEpoch).inDays}",style: TextStyle(fontWeight: FontWeight.bold,fontSize: 16,color: Colors.white),)),
                                      SizedBox(height: 16,),
                                      Text("Validity Days",style: TextStyle(fontWeight: FontWeight.bold,color: Colors.white),),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            if(exploreMode) Padding(
              padding: const EdgeInsets.all(8.0),
              child: Container(margin: EdgeInsets.only(left: 16,bottom: 8),width: double.infinity,child: Text("Buying Options",style: TextStyle(color: Colors.white),textAlign: TextAlign.start,)),
            ),
            if(exploreMode)Padding(
              padding: const EdgeInsets.only(right: 16.0,left: 16,bottom: 32),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(child: GestureDetector(onTap: (){
                    buyWithPoints(context);
                  },child: Container(padding: EdgeInsets.all(16),decoration: BoxDecoration(color: Colors.white,borderRadius: BorderRadius.circular(20)),child: Text("Redeem Points",style: TextStyle(color: Colors.black),textAlign: TextAlign.center,)))),
                  SizedBox(width: 8,),
                  Expanded(
                    child: GestureDetector(onTap:(){setState(() {
                      exploreMode=false;
                    });},child: Container(padding: EdgeInsets.all(16),decoration: BoxDecoration(color: Colors.white,borderRadius: BorderRadius.circular(20)),child: Text("Explore Plans",style: TextStyle(color: Colors.black),textAlign: TextAlign.center,),)),
                  ),
                ],
              ),
            ),

            Expanded(
              child: Container(
                width: double.infinity,
                padding: EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(topLeft: Radius.circular(30),topRight: Radius.circular(30)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if(!exploreMode)GestureDetector(
                      child: Container(
                        width: double.infinity,
                        alignment: Alignment.centerRight,
                        child: Icon(Icons.close),
                        margin: EdgeInsets.only(bottom: 16),
                      ),
                      onTap: (){
                        setState(() {
                          exploreMode=true;
                        });
                      },
                    ),
                    DefaultTabController(
                      length: 2,
                      child: TabBar(
                        onTap: (index){
                          setState(() {
                            recommended=index==0 ? true : false;
                          });
                        },
                          labelColor: const Color(0xff959595),
                          indicatorWeight: 2,
                          indicatorColor: Color(0xff00c0b0),
                          labelStyle: TextStyle(fontSize: 13),
                          tabs: [
                        Tab(text: "Recommended Plans"),
                        Tab(text: "All Plans",),
                      ]),
                    ),
                    Expanded(
                      child: SingleChildScrollView(
                        child: Column(
                          children: [
                            SizedBox(height: 16,),
                            if(!recommended)GestureDetector(onTap: (){
                              setState(() {
                                selectedItemPrice=99;
                                selectedPlan=PlanModel("STARTER PACK",5,5,99,DateTime.now().add(Duration(days: 30)).millisecondsSinceEpoch);
                              });
                            },child: Plan(offer: 5, ad: 5, validity: 30, price: 99, strikedPrice: 350, planName: "STARTER PACK")),
                            if(!recommended)GestureDetector(onTap: (){
                              setState(() {
                                selectedItemPrice=149;
                                selectedPlan=PlanModel("VALUE PACK",6,6,149,DateTime.now().add(Duration(days: 30)).millisecondsSinceEpoch);

                              });
                            },child: Plan(offer: 6, ad: 6, validity: 30, price: 149, strikedPrice: 600, planName: "VALUE PACK")),
                            if(recommended)GestureDetector(onTap: (){
                              setState(() {
                                selectedItemPrice=199;
                                selectedPlan=PlanModel("EXCLUSIVE PACK",10,6,199,DateTime.now().add(Duration(days: 30)).millisecondsSinceEpoch);
                              });
                            },child: Plan(offer: 10, ad: 6, validity: 30, price: 199, strikedPrice: 800, planName: "EXCLUSIVE PACK")),
                            if(!recommended)GestureDetector(onTap: (){
                              setState(() {
                                selectedItemPrice=499;
                                selectedPlan=PlanModel("ULTIMATE PACK",30,25,499,DateTime.now().add(Duration(days: 30)).millisecondsSinceEpoch);
                              });
                            },child: Plan(offer: 30, ad: 25, validity: 30, price: 499, strikedPrice: 2750, planName: "ULTIMATE PACK")),
                            if(!recommended)GestureDetector(onTap: (){
                              setState(() {
                                selectedItemPrice=1799;
                                selectedPlan=PlanModel("SUPER SAVING",100,50,1799,DateTime.now().add(Duration(days: 90)).millisecondsSinceEpoch);
                              });
                            },child: Plan(offer: 100, ad: 50, validity: 90, price: 1799, strikedPrice: 7500, planName: "SUPER SAVING PACK")),
                            if(!recommended)GestureDetector(onTap: (){
                              setState(() {
                                selectedItemPrice=3499;
                                selectedPlan=PlanModel("MEGA SAVER PACK",200,120,180,DateTime.now().add(Duration(days: 180)).millisecondsSinceEpoch);
                              });
                            },child: Plan(offer: 200, ad: 120, validity: 180, price: 3499, strikedPrice: 16000, planName: "MEGA SAVER PACK")),
                            if(recommended)GestureDetector(
                              onTap: (){
                                setState(() {
                                  selectedItemPrice=5999;
                                  selectedPlan=PlanModel("INFINITY PACK",9999999,999999,5999,DateTime.now().add(Duration(days: 365)).millisecondsSinceEpoch);

                                });
                              },
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  if(selectedItemPrice==5999) Container(
                                    decoration: BoxDecoration(
                                        color: kSignInContainerColor
                                    ),
                                    padding: EdgeInsets.all(8),
                                    child: Text("Selected",style: TextStyle(color: Colors.white),),
                                  ),
                                  Container(
                                    margin: EdgeInsets.only(left: 2,right: 2,bottom: 16),
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                        borderRadius: BorderRadius.circular(10),
                                        boxShadow: [BoxShadow(color: kSignInContainerColor,spreadRadius: selectedItemPrice!= 5999 ? 1: 3,)]
                                    ),
                                    padding: EdgeInsets.only(left: 16,right: 16,top: 24,bottom: 24),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                          children: [
                                            Text("INFINITY PACK",style: TextStyle(fontWeight: FontWeight.bold),),
                                            Row(
                                              children: [
                                                Text("₹5999",style: TextStyle(fontWeight: FontWeight.bold,fontSize: 20),),
                                                SizedBox(width: 8,),
                                                Text("37499",style: TextStyle(decoration: TextDecoration.lineThrough,fontSize: 16),),
                                              ],
                                            ),
                                          ],
                                        ),
                                        SizedBox(height: 24,),
                                        Column(
                                          children: [
                                            Row(
                                              mainAxisAlignment: MainAxisAlignment.center,
                                              children: [
                                                Expanded(
                                                  child: Column(
                                                    crossAxisAlignment: CrossAxisAlignment.center,
                                                    children: [
                                                      Text("Offer Posts:",),
                                                      SizedBox(height: 8,),
                                                      Text("Unlimited",style: TextStyle(fontWeight: FontWeight.bold,fontSize: 16),),
                                                    ],
                                                  ),
                                                ),

                                                Expanded(
                                                  child: Column(
                                                    crossAxisAlignment: CrossAxisAlignment.center,
                                                    children: [
                                                      Text("Ad Posts:"),
                                                      SizedBox(height: 8,),
                                                      Text("Unlimited",style: TextStyle(fontWeight: FontWeight.bold,fontSize: 16),),
                                                    ],
                                                  ),
                                                ),

                                                Expanded(
                                                  child: Column(
                                                    crossAxisAlignment: CrossAxisAlignment.center,
                                                    children: [
                                                      Text("Validity:"),
                                                      SizedBox(height: 8,),
                                                      Text("365 Days",style: TextStyle(fontWeight: FontWeight.bold,fontSize: 16),),
                                                    ],
                                                  ),
                                                ),
                                              ],
                                            ),
                                            SizedBox(height: 24,),
                                            Text("1 event post free and exciting vouchers ",style: TextStyle(fontSize: 16),textAlign: TextAlign.start,),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    SizedBox(height: 8,),
                    if(selectedItemPrice!=0)Row(
                      children: [
                        Expanded(
                          child: Container(height: 60,
                            margin: EdgeInsets.all(8),
                            alignment: Alignment.centerLeft,
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(20)
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text("Price:",textAlign: TextAlign.center,),
                                SizedBox(height: 8,),
                                Text("₹ $selectedItemPrice",textAlign: TextAlign.center,style: TextStyle(fontSize: 20,fontWeight: FontWeight.bold),),
                              ],
                            ),
                          ),
                        ),

                        Expanded(
                          flex: 2,
                          child: GestureDetector(
                            onTap: (){
                              if(planModel!=null){
                                showAlertDialog(BuildContext context) {

                                  // set up the button
                                  Widget okButton = TextButton(
                                    child: Text("OK"),
                                    onPressed: () {
                                      Fluttertoast.showToast(msg: "Purchasing plan");
                                      buyPlan(selectedPlan!);
                                      Navigator.pop(context);
                                    },
                                  );

                                  Widget cancelButton = TextButton(
                                    child: Text("Cancel"),
                                    onPressed: () {
                                      Fluttertoast.showToast(msg: "Purchasing plan");
                                      Navigator.pop(context);
                                    },
                                  );

                                  // set up the AlertDialog
                                  AlertDialog alert = AlertDialog(
                                    title: Text("Are you sure?"),
                                    content: Text("This will replace current plan."),
                                    actions: [
                                      okButton,
                                      cancelButton
                                    ],
                                  );

                                  // show the dialog
                                  showDialog(
                                    context: context,
                                    builder: (BuildContext context) {
                                      return alert;
                                    },
                                  );
                                }
                                showAlertDialog(context);
                              }else {
                                Fluttertoast.showToast(msg: "Purchasing plan");
                                buyPlan(selectedPlan!);
                              }
                            },
                            child: Container(height: 50,
                            margin: EdgeInsets.all(8),
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              color: kSignInContainerColor,
                              borderRadius: BorderRadius.circular(20)
                            ),
                              child: Text("Buy Now",textAlign: TextAlign.center,style: TextStyle(color: Colors.white),),
                            ),
                          ),
                        ),
                      ],
                    )
                  ],
                ),
              ),
            ),
          ],
        ),
    ),
    );
  }

}

class Plan extends StatefulWidget {
  const Plan({Key? key,required this.offer,required this.ad,required this.validity,required this.price,required this.strikedPrice,required this.planName}) : super(key: key);

  final String planName;
  final int offer;
  final int ad;
  final int validity;
  final int price;
  final int strikedPrice;

  @override
  State<Plan> createState() => _PlanState();
}

class _PlanState extends State<Plan> {

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      key: Key(selectedItemPrice.toString()),
      child: Padding(
        padding: const EdgeInsets.all(4.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if(selectedItemPrice==widget.price) Container(
              decoration: BoxDecoration(
                color: kSignInContainerColor
              ),
                padding: EdgeInsets.all(8),
                child: Text("Selected",style: TextStyle(color: Colors.white),),
            ),
            Container(
              margin: EdgeInsets.only(left: 2,right: 2,bottom: 16),
              decoration: BoxDecoration(
                color: Colors.white,
                  borderRadius: selectedItemPrice!=widget.price ? BorderRadius.circular(10) : BorderRadius.only(bottomLeft: Radius.circular(10),bottomRight: Radius.circular(10)),
                  boxShadow: [BoxShadow(color: kSignInContainerColor,spreadRadius: selectedItemPrice!=widget.price ? 1 : 3)]
              ),
              padding: EdgeInsets.only(left: 16,right: 16,top: 24,bottom: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text("${widget.planName}",style: TextStyle(fontWeight: FontWeight.bold),),
                      Row(
                        children: [
                          Text("₹${widget.price}",style: TextStyle(fontWeight: FontWeight.bold,fontSize: 20),),
                          SizedBox(width: 8,),
                          Text("${widget.strikedPrice}",style: TextStyle(decoration: TextDecoration.lineThrough,fontSize: 16),),
                        ],
                      ),
                    ],
                  ),
                  SizedBox(height: 24,),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Text("Offer Posts:"),
                            SizedBox(height: 8,),
                            Text("${widget.offer}",style: TextStyle(fontWeight: FontWeight.bold,fontSize: 16),),
                          ],
                        ),
                      ),

                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Text("Ad Posts:"),
                            SizedBox(height: 8,),
                            Text("${widget.ad}",style: TextStyle(fontWeight: FontWeight.bold,fontSize: 16),),
                          ],
                        ),
                      ),

                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Text("Validity:"),
                            SizedBox(height: 8,),
                            Text("${widget.validity} Days",style: TextStyle(fontWeight: FontWeight.bold,fontSize: 16),),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}


