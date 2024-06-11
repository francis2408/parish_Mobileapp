import 'package:avosa/private/blessings_prayers/adoration.dart';
import 'package:avosa/private/blessings_prayers/blessing.dart';
import 'package:avosa/private/blessings_prayers/novena.dart';
import 'package:avosa/private/blessings_prayers/rosary.dart';
import 'package:avosa/widget/common/common.dart';
import 'package:avosa/widget/common/internet_connection_checker.dart';
import 'package:avosa/widget/theme_color/theme_color.dart';
import 'package:avosa/widget/widget.dart';
import 'package:flutter/material.dart';

class BlessingsAndPrayersScreen extends StatefulWidget {
  const BlessingsAndPrayersScreen({Key? key}) : super(key: key);

  @override
  State<BlessingsAndPrayersScreen> createState() => _BlessingsAndPrayersScreenState();
}

class _BlessingsAndPrayersScreenState extends State<BlessingsAndPrayersScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  List tabs = ["Rosary", "Adoration", "Novena", "Vehicle Blessings"] ;
  List<Widget> tabsContent = [
    const RosaryScreen(),
    const AdorationScreen(),
    const NovenaScreen(),
    const VehicleBlessingsScreen()
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
          backgroundColor: primaryColor,
          title: Text(
            'Blessings & Prayers',
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
              Tab(text: "Rosary"),
              Tab(text: "Adoration"),
              Tab(text: "Novena"),
              Tab(text: "Vehicle Blessings")
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
