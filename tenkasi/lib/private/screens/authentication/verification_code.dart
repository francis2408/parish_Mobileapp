import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tenkasi/private/screens/home/home_screen.dart';
import 'package:tenkasi/widget/common/common.dart';
import 'package:tenkasi/widget/common/internet_connection_checker.dart';
import 'package:tenkasi/widget/common/snackbar.dart';
import 'package:tenkasi/widget/helper/helper_function.dart';
import 'package:tenkasi/widget/theme_color/theme_color.dart';
import 'package:tenkasi/widget/widget.dart';

import 'login.dart';
import 'password.dart';

class VerificationScreen extends StatefulWidget {
  final String value;
  final bool type;
  const VerificationScreen({super.key, required this.value, required this.type});

  @override
  State<VerificationScreen> createState() => _VerificationScreenState();
}

class _VerificationScreenState extends State<VerificationScreen> {
  final formKey = GlobalKey<FormState>();
  late List<FocusNode> _focusNodes;
  late List<TextEditingController> _controllers;
  final int length = 5;
  bool  isOTP = false;
  bool _isLoading = false;
  String otp = '';
  String timerText = '';

  // Timer
  int _timeLeftInSeconds = 60;
  var timeValue;
  bool isSignupScreen = false;

  void otpVerification(String otp) async {
    if (otp.isNotEmpty || formKey.currentState!.validate()) {
      String code = loginID.replaceAll(' ', '');
      String url = '$baseUrl/confirm_otp';
      Map datas = {
        "params": {"login": "$code", "otp": "$otp"}
      };
      var body = json.encode(datas);
      var response = await http.post(Uri.parse(url),
          headers: {
            'Content-type': 'application/json',
            'Accept': 'application/json'
          },
          body: body);
      if (response.statusCode == 200) {
        _isLoading = false;
        final data = jsonDecode(response.body)['result'];
        if (data['status'] == true) {
          HelperFunctions.setUserLoginSF(data['status']);
          HelperFunctions.setAuthTokenSF(data['access_token']);
          String dateStr = "${data['expires']}";
          DateTime date = DateFormat("dd-MM-yyyy HH:mm:ss").parse(dateStr);
          String formattedDate = DateFormat("yyyy-MM-dd HH:mm:ss").format(date);
          HelperFunctions.setTokenExpiresSF(formattedDate);
          HelperFunctions.setUserNameSF(data['name']);
          HelperFunctions.setUserImageSF(data['image']);
          for (var rec in data['level']) {
            if(rec == 'Parish Family') HelperFunctions.setUserRoleSF(rec);
          }
          if(data['email'] != false) {
            HelperFunctions.setUserEmailSF(data['email']);
          } else {
            var emails = "";
            HelperFunctions.setUserEmailSF(emails);
          }
          if(data['diocese_id'] != false) {
            HelperFunctions.setUserDioceseSF(data['diocese_id']);
          } else {
            var dioceses = "";
            HelperFunctions.setUserDiocesesSF(dioceses);
          }
          if(data['parish_id'] != false) {
            HelperFunctions.setUserParishSF(data['parish_id']);
          } else {
            HelperFunctions.setUserParishSF(parishID);
          }
          if(data['parish_bcc_id'] != false) {
            HelperFunctions.setBCCIdSF(data['parish_bcc_id']);
          } else {
            String bcc = "";
            HelperFunctions.setBCCIdsSF(bcc);
          }
          if(data['family_id'] != false) {
            HelperFunctions.setFamilyIdSF(data['family_id']);
          } else {
            var familys = "";
            HelperFunctions.setFamilyIdsSF(familys);
          }
          if(data['member_id'] != false) {
            HelperFunctions.setMemberIdSF(data['member_id']);
          } else {
            var members = "";
            HelperFunctions.setMemberIdsSF(members);
          }
          if(data['uid'] != false) {
            HelperFunctions.setUserIdSF(data['uid']);
          } else {
            var userId = "";
            HelperFunctions.setUserIdsSF(userId);
          }
          HelperFunctions.saveUserLoggedInStatus(true);
          isSignupScreen ? getData() : Navigator.of(context).pushReplacement(CustomRoute(widget: const PasswordScreen(type: true)));

          AnimatedSnackBar.show(
              context,
              data["message"],
              Colors.green
          );
        } else {
          setState(() {
            _isLoading = false;
            showDialog(
              context: context,
              builder: (BuildContext context) {
                return ErrorAlertDialog(
                  message: data['message'],
                  onOkPressed: () async {
                    Navigator.pop(context);
                  },
                );
              },
            );
          });
        }
      } else {
        final data = jsonDecode(response.body)['result'];
        setState(() {
          _isLoading = false;
          AnimatedSnackBar.show(
              context,
              data["message"],
              Colors.red
          );
        });
      }
    } else {
      setState(() {
        isOTP = true;
        AnimatedSnackBar.show(
            context,
            'Please enter the OTP',
            Colors.red
        );
      });
    }
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

    if(pref.containsKey('userBCCIdKey')) {
      bccId = (pref.getInt('userBCCIdKey'))!;
    }

    if(pref.containsKey('userBCCIdsKey')) {
      bccId = (pref.getString('userBCCIdsKey'))!;
    }

    if(pref.containsKey('userMemberIdKey')) {
      memberId = (pref.getInt('userMemberIdKey'))!;
    }

    if(pref.containsKey('userMemberIdsKey')) {
      memberId = (pref.getString('userMemberIdsKey'))!;
    }

    if(pref.containsKey('userFamilyIdKey')) {
      familyId = (pref.getInt('userFamilyIdKey'))!;
    }

    if(pref.containsKey('userFamilyIdsKey')) {
      familyId = (pref.getString('userFamilyIdsKey'))!;
    }

    expiryDateTime = DateTime.parse(tokenExpire);

    Navigator.of(context).pushReplacement(CustomRoute(widget: const HomeScreen()));
  }

  void startTimer() {
    Timer.periodic(const Duration(seconds: 1), (Timer timer) {
      setState(() {
        if (_timeLeftInSeconds > 0) {
          _timeLeftInSeconds--;
          timeValue = _timeLeftInSeconds;
        } else {
          timer.cancel();
        }
      });
    });
  }

  getSharedValue() async {
    var pref = await SharedPreferences.getInstance();
    if(pref.containsKey('userLoginIdkey')) {
      loginID = (pref.getString('userLoginIdkey'))!;
    }
    if(pref.containsKey('userFamilyIdKey')) {
      familyId = (pref.getInt('userFamilyIdKey'))!;
    }
  }

  void updateOTPValue() {
    setState(() {
      otp = _controllers
          .map<String>((controller) => controller.text)
          .join();
    });
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
    super.initState();
    isSignupScreen = widget.type;
    getSharedValue();
    _focusNodes = List.generate(length, (index) => FocusNode());
    _controllers = List.generate(
      length, (index) => TextEditingController(),
    );
    startTimer();
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return WillPopScope(
      onWillPop: () async {
        return false;
      },
      child: Scaffold(
        backgroundColor: screenBackgroundColor,
        body: Container(
          height: size.height,
          // decoration: const BoxDecoration(
          //     image: DecorationImage(
          //         image: AssetImage("assets/images/church.jpg"),
          //         fit: BoxFit.fill
          //     )
          // ),
          child: Container(
            color: Colors.black.withOpacity(0.1),
            child: Stack(
              children: [
                Positioned(
                  top: 0,
                  right: 0,
                  left: 0,
                  child: Container(
                    padding: const EdgeInsets.only(top: 90, left: 20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      // children: [
                      //   RichText(
                      //     textAlign: TextAlign.center,
                      //     text: TextSpan(
                      //         // text: "Welcome to",
                      //         // style: TextStyle(
                      //         //   fontSize: size.height * 0.022,
                      //         //   fontWeight: FontWeight.w700,
                      //         //   color: Colors.white,
                      //         // ),
                      //         // children: [
                      //         //   TextSpan(
                      //         //     text: ' St ',
                      //         //     style: TextStyle(color: Colors.white, fontSize: size.height * 0.022, fontWeight: FontWeight.w700,),
                      //         //   ),
                      //         //   TextSpan(
                      //         //     text: 'Michael Shrine ',
                      //         //     style: TextStyle(color: Colors.white, fontSize: size.height * 0.022, fontWeight: FontWeight.w700,),
                      //         //   ),
                      //         //   TextSpan(
                      //         //     text: "Tenkasi",
                      //         //     style: TextStyle(color: Colors.white, fontSize: size.height * 0.022, fontWeight: FontWeight.w700,),
                      //         //   ),
                      //         // ]),
                      //   ),
                      // ],
                    ),
                  ),
                ),
                buildBottomHalfContainer(true),
                AnimatedPositioned(
                  duration: const Duration(milliseconds: 700),
                  curve: Curves.easeInExpo,
                  top: size.height * 0.26,
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 700),
                    curve: Curves.bounceInOut,
                    height: size.height * 0.38,
                    padding: const EdgeInsets.all(20),
                    width: MediaQuery.of(context).size.width - 40,
                    margin: const EdgeInsets.symmetric(horizontal: 20),
                    decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.8),
                        borderRadius: BorderRadius.circular(15),
                        boxShadow: [
                          BoxShadow(
                              color: Colors.black.withOpacity(0.2),
                              blurRadius: 15,
                              spreadRadius: 5),
                        ]),
                    child: SingleChildScrollView(
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              Column(
                                children: [
                                  Text(
                                    "OTP Verification",
                                    style: TextStyle(
                                      fontSize: size.height * 0.02,
                                      fontWeight: FontWeight.bold,
                                      color: primaryColor,
                                    ),
                                  ),
                                  Container(
                                    margin: const EdgeInsets.only(top: 5),
                                    height: 5,
                                    width: size.height * 0.15,
                                    color: textColor,
                                  )
                                ],
                              ),
                            ],
                          ),
                          buildSignInSection(),
                        ],
                      ),
                    ),
                  ),
                ),
                buildBottomHalfContainer(false),
                Positioned(
                  top: MediaQuery.of(context).size.height - 180,
                  right: 0,
                  child: GestureDetector(
                    onTap: () {
                      Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const LoginScreen()));
                    },
                    child: Container(
                      alignment: Alignment.centerRight,
                      padding: const EdgeInsets.all(8),
                      decoration: const BoxDecoration(
                        borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(10.0),
                            bottomLeft: Radius.circular(10.0)),
                        gradient: LinearGradient(
                            colors: [Colors.orange, Colors.red],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight),
                      ),
                      child: Text(
                        'Back to login page',
                        style: TextStyle(
                          fontSize: size.height * 0.018,
                          fontWeight: FontWeight.bold,
                          color: whiteColor,
                        ),
                      ),
                    ),
                  ),
                ),
                // Positioned(
                //   top: MediaQuery.of(context).size.height - 100,
                //   right: 0,
                //   left: 0,
                //   child: Column(
                //     children: [
                //       Text(
                //         'By Continuing, you agree to the ',
                //         style: TextStyle(
                //           fontSize: size.height * 0.018,
                //           color: whiteColor,
                //           fontWeight: FontWeight.bold,
                //         ),
                //       ),
                //       const SizedBox(
                //         height: 5,
                //       ),
                //       Text(
                //         'Terms of Services & Privacy Policy',
                //         style: TextStyle(
                //           fontSize: size.height * 0.018,
                //           color: whiteColor,
                //           fontWeight: FontWeight.bold,
                //         ),
                //       )
                //     ],
                //   ),
                // ),
              ],
            ),
          ),
        ),
      ),
    );
  }
  Container buildSignInSection() {
    Size size = MediaQuery.of(context).size;
    return Container(
      margin: const EdgeInsets.only(top: 20),
      child: Column(
        children: [
          Form(
            key: formKey,
            child: Column(
              children: [
                isSignupScreen ? Container(
                  padding: const EdgeInsets.all(5),
                  alignment: Alignment.topLeft,
                  child: Row(
                    children: [
                      Flexible(
                        child: Text(
                          'We have sent you an sms on ${widget.value} with 5 digits Verification code.',
                          style: GoogleFonts.signika(
                            fontSize: size.height * 0.018,
                            color: Colors.black,
                          ),
                        ),
                      ),
                    ],
                  ),
                ) : Container(
                  padding: const EdgeInsets.all(5),
                  alignment: Alignment.topLeft,
                  child: Row(
                    children: [
                      Flexible(
                        child: Text(
                          'We have sent you an mail on  with 5 digits Verification code.',
                          style: GoogleFonts.signika(
                            fontSize: size.height * 0.018,
                            color: Colors.black,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.only(left: 20,top: 5),
                  alignment: Alignment.topLeft,
                  child: Row(
                    children: [
                      Text(
                        'OTP',
                        style: GoogleFonts.signika(
                          fontSize: size.height * 0.021,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                      SizedBox(width: size.width * 0.02,),
                      Text('*', style: GoogleFonts.signika(fontSize: size.height * 0.02, fontWeight: FontWeight.bold, color: Colors.red,),)
                    ],
                  ),
                ),
                Container(
                  alignment: Alignment.center,
                  padding: const EdgeInsets.only(top: 10, bottom: 10),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(length, (index) {
                      return Container(
                        height: size.height * 0.05,
                        width: size.width * 0.11,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          color: whiteColor,
                          boxShadow: <BoxShadow>[
                            BoxShadow(
                              color: primaryColor.withOpacity(0.5),
                              spreadRadius: 0.3,
                              blurRadius: 3,
                              offset: const Offset(2, 2),
                            ),
                          ],
                        ),
                        margin: const EdgeInsets.symmetric(horizontal: 5),
                        child: TextFormField(
                          controller: _controllers[index],
                          focusNode: _focusNodes[index],
                          textAlign: TextAlign.center,
                          keyboardType: TextInputType.number,
                          maxLength: 1,
                          style: const TextStyle(fontSize: 20),
                          decoration: InputDecoration(
                            counterText: '',
                            contentPadding: EdgeInsets.zero,
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: const BorderSide(
                                color: disableColor,
                                width: 1.0,
                              ),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: const BorderSide(
                                color: disableColor,
                                width: 1.0,
                              ),
                            ),
                          ),
                          onChanged: (value) {
                            if (value.isNotEmpty && index < length - 1) {
                              _focusNodes[index].unfocus();
                              _focusNodes[index + 1].requestFocus();
                              isOTP = false;
                            } else if (value.isEmpty && index > 0) {
                              _focusNodes[index].unfocus();
                              _focusNodes[index - 1].requestFocus();
                              isOTP = false;
                            } else {
                              isOTP = false;
                            }
                            updateOTPValue();
                          },
                        ),
                      );
                    }),
                  ),
                ),
                isOTP ? Container(
                    alignment: Alignment.topLeft,
                    padding: const EdgeInsets.only(left: 15, top: 8),
                    child: const Text(
                      "OTP is required",
                      style: TextStyle(
                          color: Colors.red,
                          fontWeight: FontWeight.w500
                      ),
                    )
                ) : Container(),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 5),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      timeValue != 0 && timeValue != null ? TextButton(
                        onPressed: () {},
                        child: RichText(
                          text: TextSpan(
                              text: 'OTP Expires in :',
                              style: TextStyle(
                                fontSize: size.height * 0.018,
                                color: Colors.black,
                                fontWeight: FontWeight.bold,
                              ),
                              children: [
                                TextSpan(
                                  text: ' ',
                                  style: TextStyle(
                                    fontSize: size.height * 0.018,
                                    color: textColor,
                                    fontWeight: FontWeight.bold,
                                    decorationColor: Colors.blue,
                                    decorationThickness: 2.0,
                                  ),
                                ),
                                TextSpan(
                                  text: '$timeValue',
                                  style: TextStyle(
                                    fontSize: size.height * 0.018,
                                    color: textHeadColor,
                                    fontWeight: FontWeight.bold,
                                    decorationColor: Colors.blue,
                                    decorationThickness: 2.0,
                                  ),
                                ),
                                TextSpan(
                                  text: ' ',
                                  style: TextStyle(
                                    fontSize: size.height * 0.018,
                                    color: textHeadColor,
                                    fontWeight: FontWeight.bold,
                                    decorationColor: Colors.blue,
                                    decorationThickness: 2.0,
                                  ),
                                ),
                                TextSpan(
                                  text: 'Seconds',
                                  style: TextStyle(
                                    fontSize: size.height * 0.018,
                                    color: textHeadColor,
                                    fontWeight: FontWeight.bold,
                                    decorationColor: Colors.blue,
                                    decorationThickness: 2.0,
                                  ),
                                ),
                              ]),
                        ),
                      ) : TextButton(
                        onPressed: () {
                          _timeLeftInSeconds = 60;
                          startTimer();
                        },
                        child: RichText(
                          text: TextSpan(
                            text: 'Resend OTP',
                            style: TextStyle(
                              fontSize: size.height * 0.018,
                              color: textHeadColor,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget buildBottomHalfContainer(bool showShadow) {
    Size size = MediaQuery.of(context).size;
    return AnimatedPositioned(
      duration: const Duration(milliseconds: 700),
      curve: Curves.bounceInOut,
      top: size.height * 0.59,
      right: 0,
      left: 0,
      child: Center(
        child: Container(
          height: 80,
          width: 80,
          padding: const EdgeInsets.all(15),
          decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.5),
              borderRadius: BorderRadius.circular(50),
              boxShadow: [
                if (showShadow)
                  BoxShadow(
                    color: Colors.black.withOpacity(.3),
                    spreadRadius: 1.5,
                    blurRadius: 10,
                  )
              ]),
          child: !showShadow ? GestureDetector(
            onTap: () {
              if (otp.isNotEmpty && otp != null && otp != '') {
                setState(() {
                  _isLoading = true;
                  isSignupScreen ? otpVerification(otp) : Navigator.of(context).pushReplacement(CustomRoute(widget: const PasswordScreen(type: true)));
                });
              } else {
                setState(() {
                  isOTP = true;
                  AnimatedSnackBar.show(
                      context,
                      'Please fill the required fields',
                      Colors.red
                  );
                });
              }
            },
            child: Container(
              alignment: Alignment.center,
              decoration: BoxDecoration(
                  gradient: const LinearGradient(
                      colors: [Colors.orange, Colors.red],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight),
                  borderRadius: BorderRadius.circular(30),
                  boxShadow: [
                    BoxShadow(
                        color: Colors.black.withOpacity(.3),
                        spreadRadius: 1,
                        blurRadius: 2,
                        offset: const Offset(0, 1))
                  ]),
              child: _isLoading ? const SizedBox(
                height: 20,
                width: 20,
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(
                    whiteColor,
                  ),
                  strokeWidth: 2,
                ),
              ) : const Icon(
                Icons.arrow_forward,
                color: Colors.white,
              ),
            ),
          ) : const Center(),
        ),
      ),
    );
  }
}