import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:tenkasi/private/screens/bible/english/new_testament.dart';
import 'package:tenkasi/private/screens/bible/english/old_testament.dart';
import 'package:tenkasi/widget/common/common.dart';
import 'package:tenkasi/widget/common/internet_connection_checker.dart';
import 'package:tenkasi/widget/theme_color/theme_color.dart';
import 'package:tenkasi/widget/widget.dart';

class EnglishBibleScreen extends StatefulWidget {
  const EnglishBibleScreen({Key? key}) : super(key: key);

  @override
  State<EnglishBibleScreen> createState() => _EnglishBibleScreenState();
}

class _EnglishBibleScreenState extends State<EnglishBibleScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  List tabs = ["Old Testament", "New Testament"];
  List<Widget> tabsContent = [
    const OldTestamentScreen(),
    const NewTestamentScreen(),
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
          backgroundColor: appBackgroundColor,
          title: Text(
            'Holy Bible',
            style: TextStyle(
              fontSize: size.height * 0.02,
              fontWeight: FontWeight.bold,
              color: whiteColor,
            ),
          ),
          centerTitle: true,
        ),
        body: SafeArea(
          child: DefaultTabController(
            length: tabs.length,
            child: Column(
              children: [
                SizedBox(height: size.height * 0.01,),
                CustomTabBar(
                  tabController: _tabController,
                  tabs: const ["Old Testament", "New Testament"],
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
