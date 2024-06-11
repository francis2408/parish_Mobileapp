import 'package:flutter/material.dart';
import 'package:tenkasi/private/screens/member/basic_detail/association_details.dart';
import 'package:tenkasi/private/screens/member/basic_detail/basic_details.dart';
import 'package:tenkasi/private/screens/member/basic_detail/commission_details.dart';
import 'package:tenkasi/private/screens/member/basic_detail/education_details.dart';
import 'package:tenkasi/private/screens/member/basic_detail/sacrament_details.dart';
import 'package:tenkasi/widget/common/common.dart';
import 'package:tenkasi/widget/common/internet_connection_checker.dart';
import 'package:tenkasi/widget/theme_color/theme_color.dart';
import 'package:tenkasi/widget/widget.dart';

class MemberDetailsScreen extends StatefulWidget {
  const MemberDetailsScreen({Key? key}) : super(key: key);

  @override
  State<MemberDetailsScreen> createState() => _MemberDetailsScreenState();
}

class _MemberDetailsScreenState extends State<MemberDetailsScreen> {
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
            name,
            style: TextStyle(
              fontSize: size.height * 0.02,
              fontWeight: FontWeight.bold,
              color: whiteColor,
            ),
          ),
          centerTitle: true,
          backgroundColor: appBackgroundColor,
        ),
        body: SafeArea(
          child: DefaultTabController(
            length: 5,
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.only(top: 5, bottom: 5),
                  color: whiteColor,
                  constraints: BoxConstraints.expand(height: size.height * 0.05),
                  alignment: Alignment.topLeft,
                  child : TabBar(
                    unselectedLabelColor: tabBackColor,
                    indicatorSize: TabBarIndicatorSize.tab,
                    labelPadding: const EdgeInsets.symmetric(horizontal: 5),
                    isScrollable: true,
                    indicator: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                        color: tabBackColor
                    ),
                    tabs: [
                      Tab(
                        child: Container(
                          padding: EdgeInsets.only(left: size.width * 0.05, right: size.width * 0.05),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: tabBackColor, width: 1.5),
                          ),
                          child: const Align(
                            alignment: Alignment.center,
                            child: Text("Basic"),
                          ),
                        ),
                      ),
                      Tab(
                        child: Container(
                          padding: EdgeInsets.only(left: size.width * 0.05, right: size.width * 0.05),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: tabBackColor, width: 1.5),
                          ),
                          child: const Align(
                            alignment: Alignment.center,
                            child: Text("Sacraments"),
                          ),
                        ),
                      ),
                      Tab(
                        child: Container(
                          padding: EdgeInsets.only(left: size.width * 0.05, right: size.width * 0.05),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: tabBackColor, width: 1.5),
                          ),
                          child: const Align(
                            alignment: Alignment.center,
                            child: Text("Education"),
                          ),
                        ),
                      ),
                      Tab(
                        child: Container(
                          padding: EdgeInsets.only(left: size.width * 0.05, right: size.width * 0.05),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: tabBackColor, width: 1.5),
                          ),
                          child: const Align(
                            alignment: Alignment.center,
                            child: Text("Commission"),
                          ),
                        ),
                      ),
                      Tab(
                        child: Container(
                          padding: EdgeInsets.only(left: size.width * 0.05, right: size.width * 0.05),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: tabBackColor, width: 1.5),
                          ),
                          child: const Align(
                            alignment: Alignment.center,
                            child: Text("Association"),
                          ),
                        ),
                      )
                    ],
                  ),
                ),
                SizedBox(
                  height: size.height * 0.01,
                ),
                Expanded(
                  child: TabBarView(
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
