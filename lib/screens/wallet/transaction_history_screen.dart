import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:nearbii/constants.dart';
import 'package:nearbii/screens/wallet/referal.dart';
import 'package:nearbii/screens/wallet/wallet_recharge_history_screen.dart';
import 'package:month_year_picker/month_year_picker.dart';
import 'package:velocity_x/velocity_x.dart';

class TransactionHistoryScreen extends StatefulWidget {
  final bool trans;
  const TransactionHistoryScreen(this.trans, {Key? key}) : super(key: key);

  @override
  State<TransactionHistoryScreen> createState() =>
      _TransactionHistoryScreenState();
}

class _TransactionHistoryScreenState extends State<TransactionHistoryScreen> {
  TextEditingController startDate = TextEditingController();
  bool isSelectorVisible=true;

  String date="";
  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
        length: 2,
        child: Scaffold(
          appBar: AppBar(
            title: Text("Transactions",style: TextStyle(color: Colors.black),),
            leading: GestureDetector(onTap:(){
              Navigator.pop(context);
            },child: Icon(Icons.arrow_back,color: Colors.black,)),
            bottom: TabBar(
              labelColor: kSignInContainerColor,
              tabs: [
                Tab(
                  text: widget.trans ? "Transaction History" : "Wallet History",
                ),
                if(widget.trans)Tab(
                  text: "Referral History",
                ),
              ],
            ),
          ),
          body: TabBarView(
            children: [
              Padding(
                padding: const EdgeInsets.only(left: 16,right: 16,top: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          widget.trans ? "Transaction History" : "Wallet History",
                          style: TextStyle(
                            fontWeight: FontWeight.w700,
                            fontSize: 16,
                            color: kLoadingScreenTextColor,
                          ),
                        ),
                        GestureDetector(onTap: (){
                          setState(() {
                            isSelectorVisible=true;
                          });
                        },child: Icon(Icons.filter_list_alt,color: Colors.black,size: 30,))
                      ],
                    ),
                    if(isSelectorVisible)const SizedBox(
                      height: 25,
                    ),
                    if(isSelectorVisible)Container(
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: kHomeScreenServicesContainerColor,
                        borderRadius: BorderRadius.circular(5),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(10, 10, 10, 20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            //start date label
                            Container(
                              margin: const EdgeInsets.only(top: 20),
                              child: TextField(
                                  controller: startDate,
                                  decoration: InputDecoration(
                                    suffixIcon: InkWell(
                                        onTap: () async {
                                          final selected = await showDatePicker(
                                            context: context,
                                            initialDate: DateTime.now(),
                                            firstDate: DateTime(2019),
                                            lastDate: DateTime.now(),
                                          );
                                          if (selected != null) {
                                            print(
                                                selected); //pickedDate output format => 2021-03-10 00:00:00.000

                                            setState(() {
                                              startDate.text = DateFormat("MMMM yyyy").format(selected);
                                              date=selected.toString();
                                            }); //formatted date output using intl package =>  2021-03-16
                                          } else {
                                            print("Date is not selected");
                                          }
                                        },
                                        child: const Icon(Icons.calendar_today)),
                                    hintText: "Event Start Date *",
                                    hintStyle: const TextStyle(
                                        color: Color.fromARGB(255, 203, 207, 207)),
                                    enabledBorder: const OutlineInputBorder(
                                        borderSide: BorderSide(
                                          color: Color.fromARGB(173, 125, 209, 248),
                                        )),
                                    focusedBorder: OutlineInputBorder(
                                      borderSide: const BorderSide(
                                          color: Color.fromARGB(173, 125, 209, 248),
                                          width: 1),
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    border: OutlineInputBorder(
                                      borderSide: const BorderSide(
                                          color: Color.fromARGB(173, 125, 209, 248),
                                          width: 1),
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                  )),
                            ),
                            const SizedBox(
                              height: 30,
                            ),

                            //button
                            Center(
                              child: GestureDetector(
                                onTap: (){
                                  setState(() {
                                    isSelectorVisible=false;
                                  });
                                },
                                child: Container(
                                  height: 40,
                                  width: 173,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(5),
                                    color: kSignInContainerColor,
                                  ),
                                  child: const Center(
                                    child: Text(
                                      "Get Statement",
                                      style: TextStyle(
                                        fontWeight: FontWeight.w400,
                                        fontSize: 16,
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
                    if(isSelectorVisible) SizedBox(height: 25,),
                    if(date.isNotEmpty)
                      Expanded(
                        child: WalletRechargeHistoryScreen(
                            startDate: DateTime.parse(date),
                            endDate: DateTime.now(),
                            fromDate: widget.trans),
                      ),
                  ],
                ),
              ),
              Referal()
            ],
          ),
        ),
      );
  }
}
