import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:perambur/widget/common/common.dart';
import 'package:perambur/widget/common/internet_connection_checker.dart';
import 'package:perambur/widget/theme_color/theme_color.dart';
import 'package:perambur/widget/widget.dart';

import 'english/new_testament.dart';
import 'english/old_testament.dart';

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
          backgroundColor: primaryColor,
          title: Text(
            'Holy Bible',
            style: TextStyle(
              fontSize: size.height * 0.02,
              fontWeight: FontWeight.bold,
              color: whiteColor,
            ),
          ),
          centerTitle: true,
          bottom: TabBar(
            controller: _tabController,
            unselectedLabelColor: whiteColor,
            labelStyle: const TextStyle(fontWeight: FontWeight.w600, fontSize: 18),
            indicator: BoxDecoration(
                borderRadius: const BorderRadius.only(topRight: Radius.circular(15), topLeft: Radius.circular(15)), // Creates border
                color: menuSecondaryColor.shade600),
            tabs: const [
              Tab(text: "Old Testament",),
              Tab(text: "New Testament",),
            ],
            onTap: (index) {
              setState(() {
                selectedTab = tabs[index];
              });
            },
          ),
        ),
        body: SafeArea(
          child: TabBarView(
            controller: _tabController,
            children: tabsContent,
          ),
        ),
      ),
    );
  }
}
