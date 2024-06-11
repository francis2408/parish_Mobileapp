import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:munchirai/private/screens/bcc/bcc.dart';
import 'package:munchirai/private/screens/feedback/feedback_list.dart';
import 'package:munchirai/private/screens/home/home_screen.dart';
import 'package:munchirai/private/screens/notification/send_notification.dart';
import 'package:munchirai/private/screens/notification/send_notification_list.dart';
import 'package:munchirai/private/screens/prayer/prayer_request.dart';
import 'package:munchirai/widget/common/common.dart';
import 'package:munchirai/widget/common/internet_connection_checker.dart';
import 'package:munchirai/widget/common/snackbar.dart';
import 'package:munchirai/widget/helper/helper_function.dart';
import 'package:munchirai/widget/theme_color/theme_color.dart';
import 'package:munchirai/widget/widget.dart';
import 'package:shared_preferences/shared_preferences.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({Key? key}) : super(key: key);

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  bool load = true;

  _flush() {
    AnimatedSnackBar.show(
        context,
        'Logout successfully',
        Colors.green
    );
  }

  getData() async {
    var pref = await SharedPreferences.getInstance();
    if(pref.containsKey('userLoggedInkey')) {
      isSignedIn = (pref.getBool('userLoggedInkey'))!;
    }

    if(pref.containsKey('setName')) {
      loginName = (pref.getString('setName'))!;
    }

    if(pref.containsKey('setDatabaseName')) {
      databaseName = (pref.getString('setDatabaseName'));
    }

    if(pref.containsKey('setPassword')) {
      loginPassword = (pref.getString('setPassword'))!;
    }

    if(pref.containsKey('userRememberKey')) {
      remember = (pref.getBool('userRememberKey'))!;
    }

    if(pref.containsKey('userAuthTokenKey')) {
      authToken = (pref.getString('userAuthTokenKey'))!;
    }

    if(pref.containsKey('userTokenExpires')) {
      tokenExpire = (pref.getString('userTokenExpires'))!;
    }

    if(pref.containsKey('userIdKey')) {
      userId = (pref.getInt('userIdKey'))!;
    }

    if(pref.containsKey('userIdsKey')) {
      userId = (pref.getString('userIdsKey'))!;
    }

    if(pref.containsKey('userNameKey')) {
      userName = (pref.getString('userNameKey'))!;
    }

    if(pref.containsKey('userRoleKey')) {
      userRole = (pref.getString('userRoleKey'))!;
    }

    if(pref.containsKey('userEmailKey')) {
      userEmail = (pref.getString('userEmailKey'))!;
    }

    if(pref.containsKey('userImageKey')) {
      userImage = (pref.getString('userImageKey'))!;
    }

    if(pref.containsKey('userDioceseKey')) {
      DioceseId = (pref.getInt('userDioceseKey'))!;
    }

    if(pref.containsKey('userDiocesesKey')) {
      DioceseId = (pref.getString('userDiocesesKey'))!;
    }

    if(pref.containsKey('userMemberIdKey')) {
      memberId = (pref.getInt('userMemberIdKey'))!;
    }

    if(pref.containsKey('userMemberIdsKey')) {
      memberId = (pref.getString('userMemberIdsKey'))!;
    }

    expiryDateTime = DateTime.parse(tokenExpire);
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
    getData();
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return WillPopScope(
      onWillPop: () async {
        Navigator.pushReplacement(context, CustomRoute(widget: const HomeScreen()));
        return false;
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text("Admin Dashboard"),
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
          actions: [
            IconButton(
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
                          await HelperFunctions.setUserLoginSF(false);
                          authToken = '';
                          tokenExpire = '';
                          userRole = '';
                          isSignedIn = false;
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
          child: Container(
            height: size.height,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [whiteColor, menuFourthColor], // Your gradient colors here
              ),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(5.0),
                  child: Center(
                    child: Wrap(
                      spacing: 20,
                      runSpacing: 20,
                      children: [
                        DashboardCard(
                          onPressed: () async {
                            await Navigator.push(context, CustomRoute(widget: const BCCScreen()));
                          },
                          icon: "assets/icons/church.svg",
                          title: "Anbiyam",
                          homeIconSize: 40,
                        ),
                        DashboardCard(
                          onPressed: () async {
                            await Navigator.push(context, CustomRoute(widget: const SendNotificationListScreen()));
                          },
                          icon: "assets/icons/notification.svg",
                          title: "Send Notification",
                          homeIconSize: 40,
                        ),
                        DashboardCard(
                          onPressed: () async {
                            await Navigator.push(context, CustomRoute(widget: const PrayerRequest()));
                          },
                          icon: "assets/icons/rosary.svg",
                          title: "Prayer Requests",
                          homeIconSize: 40,
                        ),
                        DashboardCard(
                          onPressed: () async {
                            await Navigator.push(context, CustomRoute(widget: const FeedbackListScreen()));
                          },
                          icon: "assets/icons/feedback.svg",
                          title: "Feedback",
                          homeIconSize: 40,
                        ),
                      ],
                    ),
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

class DashboardCard extends StatelessWidget {
  const DashboardCard(
      {Key? key,
        required this.onPressed,
        required this.icon,
        required this.title,
        required this. homeIconSize,
      })
      : super(key: key);
  final VoidCallback onPressed;
  final String icon;
  final String title;
  final double homeIconSize;

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return InkWell(
      onTap: () {},
      child: SizedBox(
        height: size.height / 8,
        width: size.width / 4,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              height: size.height * 0.07,
              width: size.width * 0.15,
              decoration: BoxDecoration(
                color: menuPrimaryColor,
                shape: BoxShape.rectangle,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Center(
                  child: IconButton(
                    icon: SvgPicture.asset(icon, color: whiteColor),
                    iconSize: homeIconSize,
                    onPressed: onPressed,
                  )
              ),
            ),
            Text(
              title,
              textAlign: TextAlign.center,
              style: GoogleFonts.robotoSlab(
                  color: menuTextColor,
                  fontWeight: FontWeight.bold,
                  fontSize: size.height * 0.016
              ),
            ),
          ],
        ),
      ),
    );
  }
}