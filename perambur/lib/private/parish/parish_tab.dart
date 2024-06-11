import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:loading_indicator/loading_indicator.dart';
import 'package:perambur/widget/common/common.dart';
import 'package:perambur/widget/common/internet_connection_checker.dart';
import 'package:perambur/widget/theme_color/theme_color.dart';
import 'package:perambur/widget/widget.dart';

import 'parish_details_screen.dart';
import 'parish_history_screen.dart';

class ParishTabScreen extends StatefulWidget {
  const ParishTabScreen({Key? key}) : super(key: key);

  @override
  State<ParishTabScreen> createState() => _ParishTabScreenState();
}

class _ParishTabScreenState extends State<ParishTabScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool _isLoading = true;
  List parish = [];
  String parishName = '';
  String parishImage = '';

  List tabs = ["Basic", "History"];

  List<Widget> tabsContent = [
    const ParishDetailsScreen(),
    const ParishHistoryScreen(),
  ];

  getParishData() async {
    var request = http.Request('GET', Uri.parse('$baseUrl/res.parish'));
    request.body = json.encode({
      "params": {
        "filter": "[['id','=',$parishID]]",
        "query": "{name,image_1920}"
      }
    });
    request.headers.addAll(header);
    http.StreamedResponse response = await request.send();
    if (response.statusCode == 200) {
      var decode = json.decode(await response.stream.bytesToString())['result'];
      if(decode['status'] == true) {
        List data = decode['data']['result'];
        setState(() {
          _isLoading = false;
        });
        parish = data;
        for(int i = 0; i < parish.length; i++) {
          parishName = parish[i]['name'];
          parishImage = parish[i]['image_1920'];
        }
      }
    } else {
      var message = json.decode(await response.stream.bytesToString())['message'];
      setState(() {
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return ErrorAlertDialog(
              message: message,
              onOkPressed: () async {
                Navigator.pop(context);
              },
            );
          },
        );
      });
    }
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
    getParishData();
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
          title: Text('Parish', style: TextStyle(letterSpacing: 0.5, height: 1.3, fontSize: size.height * 0.02), textAlign: TextAlign.center, maxLines: 2,),
          centerTitle: true,
        ),
        body: SafeArea(
          child: _isLoading ? Center(
            child: SizedBox(
              height: size.height * 0.06,
              child: const LoadingIndicator(
                indicatorType: Indicator.ballSpinFadeLoader,
                colors: [Colors.red,Colors.orange,Colors.yellow,Colors.green,Colors.blue,Colors.indigo,Colors.purple,],
              ),
            ),
          ) : parish.isNotEmpty ? DefaultTabController(
            length: tabs.length,
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                  child: Container(
                    width: size.width,
                    height: size.height * 0.25,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(15),
                      color: Colors.white,
                      image: DecorationImage(
                        fit: parishImage != null && parishImage != '' ? BoxFit.cover : BoxFit.contain,
                        image: parishImage != null && parishImage != ''
                            ? NetworkImage(parishImage)
                            : const AssetImage('assets/images/logo.png') as ImageProvider,
                      ),
                    ),
                  ),
                ),
                CustomTabBar(
                  tabController: _tabController,
                  tabs: const ["Parish Profile", "Parish History"],
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
          ) : Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Center(
                  child: Container(
                    padding: const EdgeInsets.only(left: 30, right: 30),
                    child: NoResult(
                      onPressed: () {
                        setState(() {
                          Navigator.pop(context, 'refresh');
                        });
                      }, text: 'No Data available',
                    ),
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
