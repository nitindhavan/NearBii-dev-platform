import 'package:flutter/material.dart';

addBottomBar(BuildContext context) {
  var selectedIndex = 0;

  return BottomNavigationBar(
    type: BottomNavigationBarType.fixed,
    items: const <BottomNavigationBarItem>[
      BottomNavigationBarItem(
        icon: Icon(Icons.home_outlined),
        label: 'Home',
      ),
      BottomNavigationBarItem(
        icon: Icon(Icons.event_note_outlined),
        label: 'Events',
      ),
      BottomNavigationBarItem(
        icon: Icon(Icons.local_offer_outlined),
        label: 'Offers',
      ),
      BottomNavigationBarItem(
        icon: Icon(Icons.qr_code_scanner_outlined),
        label: 'Scan',
      ),
      BottomNavigationBarItem(
        icon: Icon(Icons.person_outline_outlined),
        label: 'Profile',
      ),
    ],
    currentIndex: selectedIndex,
    onTap: (index) {
      selectedIndex = index;

      // Navigator.of(context).pushAndRemoveUntil(
      //     MaterialPageRoute(builder: ((context) {
      //   return const MasterPage(
      //     currentIndex: 0,
      //   );
      // })), (route) => false);
    },
  );
}
