import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:loading_indicator/loading_indicator.dart';
import 'package:perambur/authentication/password.dart';
import 'package:perambur/private/family/family_detail_tab.dart';
import 'package:perambur/widget/common/common.dart';
import 'package:perambur/widget/common/internet_connection_checker.dart';
import 'package:perambur/widget/common/snackbar.dart';
import 'package:perambur/widget/helper/helper_function.dart';
import 'package:perambur/widget/navigation/navigation_bar.dart';
import 'package:perambur/widget/theme_color/theme_color.dart';
import 'package:perambur/widget/widget.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

import 'about.dart';

class AccountScreen extends StatefulWidget {
  const AccountScreen({Key? key}) : super(key: key);

  @override
  State<AccountScreen> createState() => _AccountScreenState();
}

class _AccountScreenState extends State<AccountScreen> {
  final bool _canPop = false;
  bool _isLoading = true;
  bool load = true;
  List member = [];

  // Member Details
  String memberName = '';
  String memberImage = '';
  String memberRole = '';

  getParishData() async {
    var request = http.Request('GET', Uri.parse('$baseUrl/public/$parishID/parish_details'));
    request.body = json.encode({});
    request.headers.addAll(headers);
    http.StreamedResponse response = await request.send();
    if (response.statusCode == 200) {
      var decode = json.decode(await response.stream.bytesToString())['result'];
      if(decode['status'] == 'success') {
        List data = decode['result'];
        setState(() {
          _isLoading = false;
        });
        for (var priest in data) {
          memberImage = priest['priest_id']['image_1920'] != null && priest['priest_id']['image_1920'] != '' ? priest['priest_id']['image_1920'] : '';
          memberName = priest['priest_id']['member_name'] != null && priest['priest_id']['member_name'] != '' ? priest['priest_id']['member_name'] : '';
          memberRole = priest['priest_id']['member_name'] != null && priest['priest_id']['member_name'] != '' ? 'Parish Priest' : '';
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

  Future<void> webAction(String web) async {
    try {
      await launch(
        web,
        forceWebView: false, // Set this to false for Android devices
        enableJavaScript: true, // Add this line to enable JavaScript if needed
      );
    } catch (e) {
      throw 'Could not launch $web: $e';
    }
  }

  userDeviceTokenDelete() async {
    String url = '$baseUrl/device/delete/token';
    Map data = {
      "params": {
        "token": deviceToken,
        "user_id": userId
      }
    };
    var body = jsonEncode(data);
    var response = await http.post(Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json'
        },
        body: body);

    if(response.statusCode == 200) {
      final data = jsonDecode(response.body)['result'];
    } else {
      final message = jsonDecode(response.body)['result'];
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
    getParishData();
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return WillPopScope(
      onWillPop: () async {
        if (_canPop) {
          return true;
        } else {
          return false;
        }
      },
      child: Scaffold(
        backgroundColor: screenColor,
        appBar: AppBar(
          automaticallyImplyLeading: false,
          title: const Text('Account Settings'),
          centerTitle: true,
          backgroundColor: primaryColor,
          flexibleSpace: Container(
            decoration: const BoxDecoration(
                borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(25),
                    bottomRight: Radius.circular(25)
                ),
            ),
          ),
          shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(25),
                  bottomRight: Radius.circular(25)
              )
          ),
          bottom: _isLoading ? PreferredSize(
            preferredSize: Size.fromHeight(size.height * 0.01), child: Container(),
          ) : PreferredSize(
            preferredSize: Size.fromHeight(size.height * 0.12), // Set the preferred height
            child: Padding(
              padding: const EdgeInsets.only(left: 10, right: 10, bottom: 5),
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  color: Colors.white,
                ),
                child: userRole == 'Parish Family' ? Row(
                  children: [
                    GestureDetector(
                      onTap: () {
                        userImage != '' ? showDialog(
                          context: context,
                          builder: (BuildContext context) {
                            return Dialog(
                              child: Image.network(userImage, fit: BoxFit.cover,),
                            );
                          },
                        ) : showDialog(
                          context: context,
                          builder: (BuildContext context) {
                            return Dialog(
                              child: Image.asset('assets/images/profile.png', fit: BoxFit.cover,),
                            );
                          },
                        );
                      },
                      child: SizedBox(
                        height: 95,
                        width: 75,
                        child: Container(
                          decoration: BoxDecoration(
                            shape: BoxShape.rectangle,
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                              width: 2,
                              color: Colors.white,
                            ),
                            image: DecorationImage(
                              fit: BoxFit.cover,
                              image: userImage != '' && userImage.isNotEmpty ? NetworkImage(userImage) : const AssetImage('assets/images/profile.png') as ImageProvider,
                            ),
                          ),
                        ),
                      ),
                    ),
                    Flexible(
                      child: Padding(
                        padding: EdgeInsets.only(left: size.width * 0.03),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              userName,
                              style: GoogleFonts.robotoSlab(
                                fontSize: size.height * 0.02,
                                color: textColor,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              userRole,
                              style: GoogleFonts.maitree(
                                fontSize: size.height * 0.018,
                                color: valueColor,
                                fontWeight: FontWeight.bold,
                              ),
                            )
                          ],
                        ),
                      ),
                    ),
                  ],
                ) : Row(
                  children: [
                    GestureDetector(
                      onTap: () {
                        memberImage != '' ? showDialog(
                          context: context,
                          builder: (BuildContext context) {
                            return Dialog(
                              child: Image.network(memberImage, fit: BoxFit.cover,),
                            );
                          },
                        ) : showDialog(
                          context: context,
                          builder: (BuildContext context) {
                            return Dialog(
                              child: Image.asset('assets/images/profile.png', fit: BoxFit.cover,),
                            );
                          },
                        );
                      },
                      child: SizedBox(
                        height: 95,
                        width: 75,
                        child: Container(
                          decoration: BoxDecoration(
                            shape: BoxShape.rectangle,
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                              width: 2,
                              color: Colors.white,
                            ),
                            image: DecorationImage(
                              fit: BoxFit.cover,
                              image: memberImage != '' && memberImage.isNotEmpty ? NetworkImage(memberImage) : const AssetImage('assets/images/profile.png') as ImageProvider,
                            ),
                          ),
                        ),
                      ),
                    ),
                    Flexible(
                      child: Padding(
                        padding: EdgeInsets.only(left: size.width * 0.03),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              memberName,
                              style: GoogleFonts.robotoSlab(
                                fontSize: size.height * 0.02,
                                color: textColor,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              memberRole,
                              style: GoogleFonts.maitree(
                                fontSize: size.height * 0.018,
                                color: valueColor,
                                fontWeight: FontWeight.bold,
                              ),
                            )
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
        body: SafeArea(
          child: Stack(
            children: [
              const BackgroundWidget(),
              _isLoading ? Center(
                child: SizedBox(
                  height: size.height * 0.06,
                  child: const LoadingIndicator(
                    indicatorType: Indicator.ballSpinFadeLoader,
                    colors: [Colors.red,Colors.orange,Colors.yellow,Colors.green,Colors.blue,Colors.indigo,Colors.purple,],
                  ),
                ),
              ) : Padding(
                padding: const EdgeInsets.all(10.0),
                child: Column(
                  children: [
                    SizedBox(
                      height: size.height * 0.01,
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (userRole == 'Parish Family') Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(15),
                            color: Colors.white,
                            boxShadow: const <BoxShadow>[
                              BoxShadow(
                                color: Colors.grey,
                                offset: Offset(
                                  2.0,
                                  2.0,
                                ),
                                blurRadius: 3.0,
                                spreadRadius: 1.0,
                              ),
                            ],
                          ),
                          child: TextButton(
                            style: TextButton.styleFrom(
                                foregroundColor: navIconColor,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                                backgroundColor: Colors.transparent
                            ),
                            onPressed: () {
                              Navigator.push(context, CustomRoute(widget: const FamilyDetailsTabScreen(title: '')));
                            },
                            child: Row(
                              children: [
                                Container(
                                    padding: const EdgeInsets.all(12),
                                    alignment: Alignment.center,
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(10),
                                      color: Colors.orange.shade700.withOpacity(0.8),
                                    ),
                                    child: SvgPicture.asset('assets/icons/user.svg', color: buttonIconColor, height: 20, width: 20)
                                ),
                                SizedBox(width: size.width * 0.05),
                                Expanded(child: Text('Profile', style: TextStyle(fontSize: size.height * 0.019, color: valueColor, fontWeight: FontWeight.w600),)),
                                Icon(Icons.arrow_forward_ios, color: valueColor, size: size.height * 0.02,),
                              ],
                            ),
                          ),
                        ),
                        if (userRole == 'Parish Family') SizedBox(
                          height: size.height * 0.01,
                        ),
                        Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(15),
                            color: Colors.white,
                            boxShadow: const <BoxShadow>[
                              BoxShadow(
                                color: Colors.grey,
                                offset: Offset(
                                  2.0,
                                  2.0,
                                ),
                                blurRadius: 3.0,
                                spreadRadius: 1.0,
                              ),
                            ],
                          ),
                          child: TextButton(
                            style: TextButton.styleFrom(
                                foregroundColor: navIconColor,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                                backgroundColor: Colors.transparent
                            ),
                            onPressed: () {
                              Navigator.of(context).push(CustomRoute(widget: const AboutScreen()));
                            },
                            child: Row(
                              children: [
                                Container(
                                    padding: const EdgeInsets.all(12),
                                    alignment: Alignment.center,
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(10),
                                      color: Colors.indigo.shade700.withOpacity(0.8),
                                    ),
                                    child: SvgPicture.asset('assets/icons/info.svg', color: buttonIconColor, height: 20, width: 20)
                                ),
                                SizedBox(width: size.width * 0.05),
                                Expanded(child: Text('About', style: TextStyle(fontSize: size.height * 0.019, color: valueColor, fontWeight: FontWeight.w600),)),
                                Icon(Icons.arrow_forward_ios, color: valueColor, size: size.height * 0.02,),
                              ],
                            ),
                          ),
                        ),
                        SizedBox(
                          height: size.height * 0.01,
                        ),
                        Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(15),
                            color: Colors.white,
                            boxShadow: const <BoxShadow>[
                              BoxShadow(
                                color: Colors.grey,
                                offset: Offset(
                                  2.0,
                                  2.0,
                                ),
                                blurRadius: 3.0,
                                spreadRadius: 1.0,
                              ),
                            ],
                          ),
                          child: TextButton(
                            style: TextButton.styleFrom(
                                foregroundColor: navIconColor,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                                backgroundColor: Colors.transparent
                            ),
                            onPressed: () {
                              webAction('https://www.boscosofttech.com/about');
                            },
                            child: Row(
                              children: [
                                Container(
                                    padding: const EdgeInsets.all(12),
                                    alignment: Alignment.center,
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(10),
                                      color: Colors.purple.shade700.withOpacity(0.8),
                                    ),
                                    child: SvgPicture.asset('assets/icons/shield.svg', color: buttonIconColor, height: 20, width: 20)
                                ),
                                SizedBox(width: size.width * 0.05),
                                Expanded(child: Text('Privacy', style: TextStyle(fontSize: size.height * 0.019, color: valueColor, fontWeight: FontWeight.w600),)),
                                Icon(Icons.arrow_forward_ios, color: valueColor, size: size.height * 0.02,),
                              ],
                            ),
                          ),
                        ),
                        SizedBox(
                          height: size.height * 0.015,
                        ),
                        Text(
                          'Account',
                          style: TextStyle(
                              fontSize: size.height * 0.022,
                              fontWeight: FontWeight.bold
                          ),
                          textAlign: TextAlign.left,
                        ),
                        if (userRole != 'Parish Family') SizedBox(
                          height: size.height * 0.015,
                        ),
                        if (userRole != 'Parish Family') Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(15),
                            color: Colors.white,
                            boxShadow: const <BoxShadow>[
                              BoxShadow(
                                color: Colors.grey,
                                offset: Offset(
                                  2.0,
                                  2.0,
                                ),
                                blurRadius: 3.0,
                                spreadRadius: 1.0,
                              ),
                            ],
                          ),
                          child: TextButton(
                            style: TextButton.styleFrom(
                                foregroundColor: navIconColor,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                                backgroundColor: Colors.transparent
                            ),
                            onPressed: () {
                              Navigator.of(context).push(CustomRoute(widget: const PasswordScreen(type: false)));
                            },
                            child: Row(
                              children: [
                                Container(
                                    padding: const EdgeInsets.all(12),
                                    alignment: Alignment.center,
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(10),
                                      color: Colors.teal.shade700.withOpacity(0.8),
                                    ),
                                    child: SvgPicture.asset('assets/icons/key.svg', color: buttonIconColor, height: 20, width: 20)
                                ),
                                SizedBox(width: size.width * 0.05),
                                Expanded(child: Text('Change Password', style: TextStyle(fontSize: size.height * 0.019, color: valueColor, fontWeight: FontWeight.w600),)),
                                Icon(Icons.arrow_forward_ios, color: valueColor, size: size.height * 0.02,),
                              ],
                            ),
                          ),
                        ),
                        SizedBox(
                          height: size.height * 0.01,
                        ),
                        Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(15),
                            color: Colors.white,
                            boxShadow: const <BoxShadow>[
                              BoxShadow(
                                color: Colors.grey,
                                offset: Offset(
                                  2.0,
                                  2.0,
                                ),
                                blurRadius: 3.0,
                                spreadRadius: 1.0,
                              ),
                            ],
                          ),
                          child: TextButton(
                            style: TextButton.styleFrom(
                                foregroundColor: navIconColor,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                                backgroundColor: Colors.transparent
                            ),
                            onPressed: () {
                              showDialog(
                                context: context,
                                builder: (BuildContext context) {
                                  return ConfirmAlertDialog(
                                    message: 'Are you sure want to exit.',
                                    onYesPressed: () {
                                      exit(0);
                                    },
                                    onCancelPressed: () {
                                      Navigator.pop(context);
                                    },
                                  );
                                },
                              );
                            },
                            child: Row(
                              children: [
                                Container(
                                    padding: const EdgeInsets.all(12),
                                    alignment: Alignment.center,
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(10),
                                      color: Colors.redAccent.shade700.withOpacity(0.8),
                                    ),
                                    child: Icon(Icons.cancel, size: size.height * 0.025, color: buttonIconColor,)
                                ),
                                SizedBox(width: size.width * 0.05),
                                Expanded(child: Text('Exit', style: TextStyle(fontSize: size.height * 0.019, color: valueColor, fontWeight: FontWeight.w600),)),
                              ],
                            ),
                          ),
                        ),
                        SizedBox(
                          height: size.height * 0.01,
                        ),
                        Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(15),
                            color: Colors.white,
                            boxShadow: const <BoxShadow>[
                              BoxShadow(
                                color: Colors.grey,
                                offset: Offset(
                                  2.0,
                                  2.0,
                                ),
                                blurRadius: 3.0,
                                spreadRadius: 1.0,
                              ),
                            ],
                          ),
                          child: TextButton(
                            style: TextButton.styleFrom(
                                foregroundColor: navIconColor,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                                backgroundColor: Colors.transparent
                            ),
                            onPressed: () async {
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
                                        await Future.delayed(const Duration(seconds: 1));
                                        setState(() {
                                          load = false; // Set loading flag to false
                                        });
                                        await Navigator.pushReplacement(context, CustomRoute(widget: const NavigationBarScreen()));
                                        _flush();
                                      }
                                    },
                                  );
                                },
                              );
                            },
                            child: Row(
                              children: [
                                Container(
                                    padding: const EdgeInsets.all(12),
                                    alignment: Alignment.center,
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(10),
                                      color: Colors.redAccent.shade700.withOpacity(0.8),
                                    ),
                                    child: SvgPicture.asset('assets/icons/logout.svg', color: buttonIconColor, height: 20, width: 20)
                                ),
                                SizedBox(width: size.width * 0.05),
                                Expanded(child: Text('Logout', style: TextStyle(fontSize: size.height * 0.019, color: Colors.black, fontWeight: FontWeight.w600),)),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
