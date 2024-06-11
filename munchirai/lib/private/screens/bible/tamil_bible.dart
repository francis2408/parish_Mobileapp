import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:munchirai/widget/common/common.dart';
import 'package:munchirai/widget/common/internet_connection_checker.dart';
import 'package:munchirai/widget/theme_color/theme_color.dart';
import 'package:munchirai/widget/widget.dart';

import 'tamil/new_tamil_testament.dart';
import 'tamil/old_tamil_testament.dart';

class TamilBibleScreen extends StatefulWidget {
  const TamilBibleScreen({Key? key}) : super(key: key);

  @override
  State<TamilBibleScreen> createState() => _TamilBibleScreenState();
}

class _TamilBibleScreenState extends State<TamilBibleScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  List tabs = ["பழைய ஏற்பாடு", "புதிய ஏற்பாடு"];
  List<Widget> tabsContent = [
    const OldTamilTestamentScreen(),
    const NewTamilTestamentScreen(),
  ];

  getOldChaptersData() async {
    final text = await rootBundle.loadString('assets/bible/t_verses.json');
    List data = json.decode(text);
    for (var bibleItem in data) {
      String bibleId = bibleItem['id']!;

      // Separate the values
      String bookId = bibleId.substring(0, 2);
      String chapterId = bibleId.substring(2, 5);
      String verseId = bibleId.substring(5);

      // Create a new map with separated values
      separatedValues.add({
        'book': int.parse(bookId),
        'chapter': int.parse(chapterId),
        'verse': int.parse(verseId),
        'verses': bibleItem['verse']!
      });
    }
    return separatedValues;
  }

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
    getOldChaptersData();
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
          title: Text(
            'திருவிவிலியம்',
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
                  tabController: _tabController,
                  tabs: const ["பழைய ஏற்பாடு", "புதிய ஏற்பாடு"],
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
