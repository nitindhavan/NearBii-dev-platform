// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:flutter/material.dart';
// import 'package:smooth_page_indicator/smooth_page_indicator.dart';

// Widget getCatDrop(BuildContext context) {
//   try {
//     final _firestore = FirebaseFirestore.instance;

//     return StreamBuilder<QuerySnapshot>(
//       stream: _firestore
//           .collection('EventCategory')
//           .snapshots()
//           .handleError((error) {
//         return Container(
//           child: SizedBox(
//             width: 30,
//             height: 30,
//             child: CircularProgressIndicator(),
//           ),
//         );
//       }),
//       builder: (context, snapshot) {
//         if (!snapshot.hasData) {
//           return const Center(
//             child: CircularProgressIndicator(),
//           );
//         }

//         return Container(
//             margin: EdgeInsets.only(top: 20, left: 20, right: 20),
//             child: DropdownButtonFormField(
//                 hint: Text(
//                   "Category *",
//                   style: TextStyle(color: Color.fromARGB(255, 203, 207, 207)),
//                 ),
//                 decoration: InputDecoration(
//                   hintText: "Category *",
//                   hintStyle:
//                       TextStyle(color: Color.fromARGB(255, 203, 207, 207)),
//                   enabledBorder: OutlineInputBorder(
//                       borderSide: BorderSide(
//                     color: Color.fromARGB(173, 125, 209, 248),
//                   )),
//                   focusedBorder: OutlineInputBorder(
//                     borderSide: const BorderSide(
//                         color: Color.fromARGB(173, 125, 209, 248), width: 1),
//                     borderRadius: BorderRadius.circular(10),
//                   ),
//                   border: OutlineInputBorder(
//                     borderSide: const BorderSide(
//                         color: Color.fromARGB(173, 125, 209, 248), width: 1),
//                     borderRadius: BorderRadius.circular(10),
//                   ),
//                 ),
//                 dropdownColor: Color.fromARGB(255, 243, 243, 243),
//                 value: 'Sports',
//                 onChanged: (String? newValue) {

//                  _onShopDropItemSelected(newValue);

//                 },
//                 items: snapshot.data!.docs.map((e) {
//                   final data = e.data as dynamic;
//                   print("Showing Menu Index Valuie");
//                   print(data()["Title"]);
//                   return DropdownMenuItem<String>(
//                     value: data()["Title"],
//                     child: Text(data()["Title"]),
//                   );
//                 }).toList()));
//       },
//     );
//   } catch (Ex) {
//     print("0x1Error To Get User");
//     return Container(
//       child: SizedBox(
//         width: 30,
//         height: 30,
//         child: CircularProgressIndicator(),
//       ),
//     );
//   }
// }
