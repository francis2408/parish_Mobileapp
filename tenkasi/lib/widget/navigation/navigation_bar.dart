// import 'package:flutter/material.dart';
// import 'package:google_nav_bar/google_nav_bar.dart';
// import 'package:sdbchennai/private/screens/account/account.dart';
// import 'package:sdbchennai/private/screens/home/home.dart';
// import 'package:sdbchennai/widget/theme_color/theme_color.dart';
//
// class NavigationBarScreen extends StatefulWidget {
//   const NavigationBarScreen({Key? key}) : super(key: key);
//
//   @override
//   State<NavigationBarScreen> createState() => _NavigationBarScreenState();
// }
//
// class _NavigationBarScreenState extends State<NavigationBarScreen> {
//   int _selectedIndex = 0;
//   final bool _canPop = true;
//
//   final page = [
//     const HomeScreen(),
//     const AccountScreen()
//   ];
//
//   @override
//   void initState() {
//     super.initState();
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return WillPopScope(
//       onWillPop: () async {
//         if(_canPop) {
//           setState(() {
//             _selectedIndex = 0;
//           });
//           return true;
//         } else {
//           return false;
//         }
//       },
//       child: Scaffold(
//         backgroundColor: screenColor,
//         body: Center(
//           child: page.elementAt(_selectedIndex),
//         ),
//         bottomNavigationBar: Container(
//           decoration: const BoxDecoration(
//             borderRadius: BorderRadius.only(
//               topRight: Radius.circular(30),
//               topLeft: Radius.circular(30),
//             ),
//             color: whiteColor,
//             boxShadow: [
//               BoxShadow(
//                 blurRadius: 10,
//                 spreadRadius: 0.5,
//                 color: Colors.grey,
//               )
//             ],
//           ),
//           child: SafeArea(
//             child: Padding(
//               padding: const EdgeInsets.symmetric(horizontal: 45, vertical: 8),
//               child: GNav(
//                 rippleColor: Colors.grey[300]!,
//                 hoverColor: Colors.grey[100]!,
//                 gap: 8,
//                 activeColor: Colors.black,
//                 iconSize: 30,
//                 padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
//                 duration: const Duration(milliseconds: 400),
//                 tabBackgroundColor: Colors.grey[100]!,
//                 color: Colors.black,
//                 tabs: const [
//                   GButton(
//                     icon: Icons.home,
//                     iconColor: navIconColor,
//                     iconActiveColor: iconActiveColor,
//                     text: 'Home',
//                     textColor: navTextColor,
//                     backgroundColor: navBackgroundColor,
//                   ),
//                   GButton(
//                     icon: Icons.person,
//                     iconColor: navIconColor,
//                     iconActiveColor: iconActiveColor,
//                     text: 'Profile',
//                     textColor: navTextColor,
//                     backgroundColor: navBackgroundColor,
//                   ),
//                 ],
//                 selectedIndex: _selectedIndex,
//                 onTabChange: (index) {
//                   setState(() {
//                     _selectedIndex = index;
//                   });
//                 },
//               ),
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// }
