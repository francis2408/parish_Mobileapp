import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:tenkasi/private/screens/family/family_members.dart';
import 'package:tenkasi/private/screens/home/home_screen.dart';
import 'package:tenkasi/widget/common/common.dart';
import 'package:tenkasi/widget/common/internet_connection_checker.dart';
import 'package:tenkasi/widget/common/snackbar.dart';
import 'package:tenkasi/widget/helper/helper_function.dart';
import 'package:tenkasi/widget/theme_color/theme_color.dart';
import 'package:tenkasi/widget/widget.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'family_detail.dart';

class FamilyDetailsTabScreen extends StatefulWidget {
  final String title;
  const FamilyDetailsTabScreen({Key? key, required this.title}) : super(key: key);

  @override
  State<FamilyDetailsTabScreen> createState() => _FamilyDetailsTabScreenState();
}

class _FamilyDetailsTabScreenState extends State<FamilyDetailsTabScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool load = true;

  List tabs = ["Basic", "Family Members"] ;
  List<Widget> tabsContent = [
    const FamilyDetailsScreen(),
    const FamilyMembersScreen(title: '',),
  ];

  _flush() {
    AnimatedSnackBar.show(
        context,
        'Logout successfully',
        Colors.green
    );
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
          title: userRole == 'Parish Family' ? Text(
            "Family Detail",
            style: TextStyle(
              fontSize: size.height * 0.02,
              fontWeight: FontWeight.bold,
              color: whiteColor,
            ),
          ) : Text(
            "${widget.title}'s Family",
            style: TextStyle(
              fontSize: size.height * 0.02,
              fontWeight: FontWeight.bold,
              color: whiteColor,
            ),
          ),
          centerTitle: true,
          backgroundColor: appBackgroundColor,
          actions: [
            if (userRole == 'Parish Family') IconButton(
              icon: SvgPicture.asset("assets/icons/logout.svg", color: whiteColor, height: 25,),
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return ConfirmAlertDialog(
                      message: 'Are you sure you want to logout?',
                      onCancelPressed: () {
                        Navigator.pop(context);
                      },
                      onYesPressed: () async {
                        if(load) {
                          showDialog(
                            context: context,
                            barrierDismissible: false,
                            builder: (BuildContext context) {
                              return const CustomLoadingDialog();
                            },
                          );
                          SharedPreferences prefs = await SharedPreferences.getInstance();
                          await prefs.remove('userLoggedInkey');
                          await prefs.remove('userAuthTokenKey');
                          await prefs.remove('userIdKey');
                          await prefs.remove('userIdsKey');
                          await prefs.remove('userNameKey');
                          await prefs.remove('userRoleKey');
                          await prefs.remove('userEmailKey');
                          await prefs.remove('userImageKey');
                          await prefs.remove('userDioceseKey');
                          await prefs.remove('userParishKey');
                          await prefs.remove('userMemberKey');
                          authToken = '';
                          tokenExpire = '';
                          userRole = '';
                          isSignedIn = false;
                          await HelperFunctions.setUserLoginSF(false);
                          await Future.delayed(const Duration(seconds: 1));
                          await Navigator.pushReplacement(context, CustomRoute(widget: const HomeScreen()));
                          _flush();
                        }
                      },
                    );
                  },
                );
              },
            )
          ],
        ),
        body: SafeArea(
          child: DefaultTabController(
            length: tabs.length,
            child: Column(
              children: [
                SizedBox(height: size.height * 0.01,),
                CustomTabBar(
                  tabController: _tabController, // Pass your TabController here
                  tabs: const ["Basic", "Family Members"], // Pass your selected tab value here
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
