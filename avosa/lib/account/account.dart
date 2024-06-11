import 'dart:convert';
import 'dart:io';

import 'package:avosa/authentication/login.dart';
import 'package:avosa/private/profile/profile.dart';
import 'package:avosa/widget/common/common.dart';
import 'package:avosa/widget/common/internet_connection_checker.dart';
import 'package:avosa/widget/common/snackbar.dart';
import 'package:avosa/widget/helper/helper_function.dart';
import 'package:avosa/widget/theme_color/theme_color.dart';
import 'package:avosa/widget/widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:loading_indicator/loading_indicator.dart';
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
  bool _isDelete = false;
  bool load = true;
  List member = [];
  String receive = '';

  // Member Details
  String memberName = '';
  String memberImage = '';
  String memberRole = '';

  Future<void> webAction(String web) async {
    try {
      await launch(
        web,
        forceWebView: false,
        enableJavaScript: true,
      );
    } catch (e) {
      throw 'Could not launch $web: $e';
    }
  }

  deleteUser() async {
    var request = http.Request('GET', Uri.parse('$baseUrl/mobile/account_delete'));
    request.body = json.encode({
      "params": {
        "parish_id": int.parse(parishID),
        "token": authToken,
      }
    });
    request.headers.addAll(headers);
    http.StreamedResponse response = await request.send();
    if (response.statusCode == 200) {
      var decode = json.decode(await response.stream.bytesToString())['result'];
      receive = decode['message'];
      logout();
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

  logout() async {
    var request = http.Request('GET', Uri.parse('$baseUrl/mobile/logout'));
    request.body = json.encode({
      "params": {
        "token": authToken,
        "parish_id": int.parse(parishID),
      }
    });
    request.headers.addAll(headers);
    http.StreamedResponse response = await request.send();
    if (response.statusCode == 200) {
      var decode = json.decode(await response.stream.bytesToString())['result'];
      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.remove('userLoggedInkey');
      await prefs.remove('userAuthTokenKey');
      await HelperFunctions.setUserLoginSF(false);
      await Future.delayed(const Duration(seconds: 1));
      _isDelete ? _deleteUser(receive) : _flush();
      await Navigator.pushReplacement(context, CustomRoute(widget: const LoginScreen()));
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

  _flush() {
    AnimatedSnackBar.show(
        context,
        'Logout successfully',
        Colors.green
    );
  }

  _deleteUser(var message) {
    AnimatedSnackBar.show(
        context,
        message,
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
    _isLoading = false;
    // getParishData();
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
          title: Text(
              'Account Settings',
              style: TextStyle(
                fontSize: size.height * 0.02,
                fontWeight: FontWeight.bold,
                color: whiteColor,
              )
          ),
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
                child: Row(
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
                        height: 85,
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
                              userName,
                              style: GoogleFonts.robotoSlab(
                                fontSize: size.height * 0.02,
                                color: Colors.teal,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              userEmail,
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
                              Navigator.of(context).push(CustomRoute(widget: const ProfileScreen()));
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
                              webAction('https://www.boscosofttech.com/privacy-policy');
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
                        SizedBox(
                          height: size.height * 0.015,
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
                                  return ConfirmDeleteAlertDialog(
                                    message: 'Are you sure want to delete account?',
                                    onYesPressed: () {
                                      showDialog(
                                        context: context,
                                        barrierDismissible: false,
                                        builder: (BuildContext context) {
                                          return const CustomLoadingDialog();
                                        },
                                      );
                                      _isDelete = true;
                                      deleteUser();
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
                                    child: Icon(Icons.delete_forever, size: size.height * 0.025, color: buttonIconColor,)
                                ),
                                SizedBox(width: size.width * 0.05),
                                Expanded(child: Text('Delete Account', style: TextStyle(fontSize: size.height * 0.019, color: valueColor, fontWeight: FontWeight.w600),)),
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
                                    message: 'Are you sure want to exit?',
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
                                    onYesPressed: () {
                                      showDialog(
                                        context: context,
                                        barrierDismissible: false,
                                        builder: (BuildContext context) {
                                          return const CustomLoadingDialog();
                                        },
                                      );
                                      logout();
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
