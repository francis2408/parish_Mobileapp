import 'package:flutter/material.dart';
import 'package:perambur/widget/common/common.dart';
import 'package:perambur/widget/theme_color/theme_color.dart';

import 'prayer_list_screen.dart';

class TabScreen extends StatefulWidget {
  const TabScreen({Key? key}) : super(key: key);

  @override
  State<TabScreen> createState() => _TabScreenState();
}

class _TabScreenState extends State<TabScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  List tabs = ["Requested", "Approved"] ;
  List<Widget> tabsContent = [
    const PrayerListScreen(),
    const PrayerListScreen(),
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: tabs.length, vsync: this);
    selectedTab = "Requested";
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Scaffold(
      backgroundColor: screenBackgroundColor,
      body: SafeArea(
        child: DefaultTabController(
          length: tabs.length,
          child: Column(
            children: [
              SizedBox(height: size.height * 0.01,),
              SizedBox(
                height: size.height * 0.04,
                child: TabBar(
                  controller: _tabController,
                  unselectedLabelColor: textHeadColor,
                  indicatorSize: TabBarIndicatorSize.tab,
                  isScrollable: true,
                  labelPadding: const EdgeInsets.symmetric(horizontal: 5),
                  indicator: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    color: primaryColor,
                    border: Border.all(
                      color: primaryColor,
                      width: 1.5,
                    ),
                  ),
                  tabs: [
                    Tab(
                      child: Container(
                        padding: EdgeInsets.only(left: size.width * 0.05, right: size.width * 0.05),
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: primaryColor, width: 1.5)),
                        child: const Align(
                          alignment: Alignment.center,
                          child: Text("Request"),
                        ),
                      ),
                    ),
                    Tab(
                      child: Container(
                        padding: EdgeInsets.only(left: size.width * 0.05, right: size.width * 0.05),
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: primaryColor, width: 1.5)),
                        child: const Align(
                          alignment: Alignment.center,
                          child: Text("Approve"),
                        ),
                      ),
                    ),
                  ],
                  onTap: (index) {
                    setState(() {
                      selectedTab = tabs[index];
                    });
                  },
                ),
              ),
              Expanded(
                child: TabBarView(
                  controller: _tabController,
                  physics: const NeverScrollableScrollPhysics(),
                  children: tabsContent,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
