import 'package:flutter/material.dart';
import 'package:perambur/widget/common/common.dart';
import 'package:perambur/widget/theme_color/theme_color.dart';

import 'all_event.dart';

class EventTabScreen extends StatefulWidget {
  const EventTabScreen({Key? key}) : super(key: key);

  @override
  State<EventTabScreen> createState() => _EventTabScreenState();
}

class _EventTabScreenState extends State<EventTabScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  List tabs = ["This Week", "This Month", "All"];
  List<Widget> tabsContent = [
    const AllEventScreen(),
    const AllEventScreen(),
    const AllEventScreen(),
  ];

  @override
  void initState() {
    super.initState();
    selectedTab = "This Week";
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
            'Calendar Event',
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
              Tab(text: "This Week",),
              Tab(text: "This Month",),
              Tab(text: "All",),
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
            physics: const NeverScrollableScrollPhysics(),
            children: tabsContent,
          ),
        ),
      ),
    );
  }
}
