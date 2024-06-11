import 'package:avosa/private/events_news/event.dart';
import 'package:avosa/private/events_news/news.dart';
import 'package:avosa/widget/common/common.dart';
import 'package:avosa/widget/common/internet_connection_checker.dart';
import 'package:avosa/widget/theme_color/theme_color.dart';
import 'package:avosa/widget/widget.dart';
import 'package:flutter/material.dart';

class EventsAndNewsTabScreen extends StatefulWidget {
  const EventsAndNewsTabScreen({Key? key}) : super(key: key);

  @override
  State<EventsAndNewsTabScreen> createState() => _EventsAndNewsTabScreenState();
}

class _EventsAndNewsTabScreenState extends State<EventsAndNewsTabScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  List tabs = ["Event", "News"] ;
  List<Widget> tabsContent = [
    const EventScreen(),
    const NewsScreen(),
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
            'Events & News',
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
            labelStyle: TextStyle(fontWeight: FontWeight.w600, fontSize: size.height * 0.02),
            indicator: BoxDecoration(
                borderRadius: const BorderRadius.only(topRight: Radius.circular(15), topLeft: Radius.circular(15)), // Creates border
                color: menuSecondaryColor.shade600),
            tabs: const [
              Tab(text: "Event"),
              Tab(text: "News"),
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
