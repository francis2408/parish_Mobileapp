import 'package:flutter/material.dart';
import 'package:perambur/widget/common/common.dart';
import 'package:perambur/widget/common/internet_connection_checker.dart';
import 'package:perambur/widget/theme_color/theme_color.dart';
import 'package:perambur/widget/widget.dart';

import 'basic_detail/association_details.dart';
import 'basic_detail/basic_details.dart';
import 'basic_detail/commission_details.dart';
import 'basic_detail/education_details.dart';
import 'basic_detail/sacrament_details.dart';

class MemberDetailsScreen extends StatefulWidget {
  const MemberDetailsScreen({Key? key}) : super(key: key);

  @override
  State<MemberDetailsScreen> createState() => _MemberDetailsScreenState();
}

class _MemberDetailsScreenState extends State<MemberDetailsScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  List tabs = ["Basic", "Sacraments", "Education", "Commission", "Association"];
  List<Widget> tabsContent = [
    const BasicDetailsScreen(),
    const SacramentDetailsScreen(),
    const EducationDetailsScreen(),
    const CommissionDetailsScreen(),
    const AssociationDetailsScreen()
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
            name,
            style: TextStyle(
              fontSize: size.height * 0.02,
              fontWeight: FontWeight.bold,
              color: whiteColor,
            ),
          ),
          centerTitle: true,
          bottom: TabBar(
            controller: _tabController,
            isScrollable: true,
            unselectedLabelColor: whiteColor,
            labelStyle: TextStyle(fontWeight: FontWeight.w600, fontSize: size.height * 0.02),
            indicator: BoxDecoration(
                borderRadius: const BorderRadius.only(topRight: Radius.circular(15), topLeft: Radius.circular(15)), // Creates border
                color: menuSecondaryColor.shade600),
            tabs: const [
              Tab(text: "Basic"),
              Tab(text: "Sacraments"),
              Tab(text: "Education"),
              Tab(text: "Commission"),
              Tab(text: "Association"),
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
            )
        )
      ),
    );
  }
}
