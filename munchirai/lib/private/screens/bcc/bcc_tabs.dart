import 'package:flutter/material.dart';
import 'package:munchirai/widget/common/common.dart';
import 'package:munchirai/widget/common/internet_connection_checker.dart';
import 'package:munchirai/widget/theme_color/theme_color.dart';
import 'package:munchirai/widget/widget.dart';

import 'bcc_familys.dart';
import 'bcc_heads.dart';
import 'bcc_members.dart';

class BCCTabsScreen extends StatefulWidget {
  final String title;
  const BCCTabsScreen({Key? key, required this.title}) : super(key: key);

  @override
  State<BCCTabsScreen> createState() => _BCCTabsScreenState();
}

class _BCCTabsScreenState extends State<BCCTabsScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  List tabs = ["Heads", "Families", "Members"] ;
  List<Widget> tabsContent = [
    const BCCHeadsScreen(),
    const BccFamilyScreen(),
    const BCCMembersScreen(title: '',),
  ];

  internetCheck() {
    CheckInternetConnection.checkInternet().then((value) {
      if(value) {
        return null;
      } else {
        showDialogBox();
      }
    });
  }

  showDialogBox() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return WarningAlertDialog(
          message: 'Please check your internet connection.',
          onOkPressed: () {
            Navigator.pop(context);
            CheckInternetConnection.checkInternet().then((value) {
              if (value) {
                return null;
              } else {
                showDialogBox();
              }
            });
          },
        );
      },
    );
  }

  @override
  void initState() {
    // Check the internet connection
    internetCheck();
    // TODO: implement initState
    super.initState();
    _tabController = TabController(length: tabs.length, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return WillPopScope(
      onWillPop: () async {
        Navigator.pop(context, 'refresh');
        return false;
      },
      child: Scaffold(
        backgroundColor: screenBackgroundColor,
        appBar: AppBar(
          title: Text(
            '${widget.title} Anbiyam',
            style: TextStyle(
              fontSize: size.height * 0.02,
              fontWeight: FontWeight.bold,
              color: whiteColor,
            ),
          ),
          centerTitle: true,
          flexibleSpace: Container(
            decoration: const BoxDecoration(
                gradient: LinearGradient(
                    colors: [
                      primaryColor,
                      secondaryColor
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight
                )
            ),
          ),
          // backgroundColor: backgroundColor,
        ),
        body: SafeArea(
          child: DefaultTabController(
            length: tabs.length,
            child: Column(
              children: [
                SizedBox(height: size.height * 0.01,),
                CustomTabBar(
                  tabController: _tabController, // Pass your TabController here
                  tabs: const ["Heads", "Families", "Members"], // Pass your selected tab value here
                  onTabTap: (index) {
                    setState(() {
                      selectedTab = tabs[index];
                    });
                  },
                ),
                SizedBox(height: size.height * 0.01,),
                Expanded(
                  child: TabBarView(
                    controller: _tabController,
                    children: tabsContent,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
