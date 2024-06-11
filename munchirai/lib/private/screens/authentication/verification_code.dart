import 'dart:async';
import 'dart:convert';

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:munchirai/private/screens/authentication/family_login.dart';
import 'package:munchirai/private/screens/family/family_detail_tab.dart';
import 'package:munchirai/widget/common/common.dart';
import 'package:munchirai/widget/common/internet_connection_checker.dart';
import 'package:munchirai/widget/common/snackbar.dart';
import 'package:munchirai/widget/custom_clipper/bezier_container.dart';
import 'package:munchirai/widget/helper/helper_function.dart';
import 'package:munchirai/widget/theme_color/theme_color.dart';
import 'package:munchirai/widget/widget.dart';
import 'package:shared_preferences/shared_preferences.dart';

class VerificationCodeScreen extends StatefulWidget {
  const VerificationCodeScreen({Key? key}) : super(key: key);

  @override
  State<VerificationCodeScreen> createState() => _VerificationCodeScreenState();
}

class _VerificationCodeScreenState extends State<VerificationCodeScreen> {
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

  void login(String otp) async {
    if (otp.isNotEmpty || formKey.currentState!.validate()) {

      String url = '$baseUrl/confirm_otp';
      Map data = {
        "params": {"login": "$loginID", "otp": "$otp"}
      };
      var body = json.encode(data);
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
          HelperFunctions.setUserRoleSF(data['level'][0]);
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
          getData();

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
    
    Navigator.of(context).pushReplacement(CustomRoute(widget: const FamilyDetailsTabScreen(title: '')));
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
        Navigator.pop(context, 'refresh');
        return false;
      },
      child: Scaffold(
          backgroundColor: screenColor,
          body: SingleChildScrollView(
            child: SizedBox(
              height: size.height,
              child: Stack(
                children: <Widget>[
                  Positioned(
                      top: -size.height * 0.20,
                      right: -size.width * 0.4,
                      child: const BezierContainer()),
                  Positioned(
                      bottom: -size.height * 0.2,
                      left: -size.width * 0.6,
                      child: const BeziersContainer()),
                  SingleChildScrollView(
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Column(
                        children: <Widget>[
                          Container(
                              alignment: Alignment.centerLeft,
                              child: Image.asset(
                                'assets/images/verification.png',
                                height: size.height * 0.4,
                                width: size.width * 0.5,
                              )
                          ),
                          Column(
                            children: [
                              Container(
                                alignment: Alignment.centerLeft,
                                decoration: const BoxDecoration(
                                    border: Border(left: BorderSide(color: secondaryColor, width: 5))
                                ),
                                child: const Padding(
                                  padding: EdgeInsets.only(left: 15),
                                  child: Text(
                                    "Verification Code",
                                    style: TextStyle(
                                      fontSize: 23,
                                      fontWeight: FontWeight.w800,
                                      color: Colors.black54,
                                    ),
                                  ),
                                ),
                              ),
                              SizedBox(
                                height: size.height * 0.02,
                              ),
                              Container(
                                alignment: Alignment.center,
                                child: Text(
                                  "Enter a one-time password and send it to your mobile number.",
                                  style: TextStyle(
                                    fontSize: size.height * 0.018,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black,
                                  ),
                                ),
                              ),
                              SizedBox(
                                height: size.height * 0.02,
                              ),
                              Form(
                                key: formKey,
                                child: Column(
                                  children: [
                                    SizedBox(height: size.height * 0.05,),
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
                                            width: 50,
                                            decoration: BoxDecoration(
                                              borderRadius: BorderRadius.circular(10),
                                              color: inputColor,
                                              boxShadow: <BoxShadow>[
                                                BoxShadow(
                                                  color: containerShadow.withOpacity(0.5),
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
                                                  style: const TextStyle(
                                                    fontSize: 16,
                                                    color: Colors.black,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                  children: [
                                                    TextSpan(
                                                      text: ' ',
                                                      style: TextStyle(
                                                        fontSize: size.height * 0.02,
                                                        color: Colors.blue,
                                                        fontWeight: FontWeight.bold,
                                                        decorationColor: Colors.blue,
                                                        decorationThickness: 2.0,
                                                      ),
                                                    ),
                                                    TextSpan(
                                                      text: '$timeValue',
                                                      style: const TextStyle(
                                                        fontSize: 16,
                                                        color: Colors.blue,
                                                        fontWeight: FontWeight.bold,
                                                        decorationColor: Colors.blue,
                                                        decorationThickness: 2.0,
                                                      ),
                                                    ),
                                                    TextSpan(
                                                      text: ' ',
                                                      style: TextStyle(
                                                        fontSize: size.height * 0.02,
                                                        color: Colors.blue,
                                                        fontWeight: FontWeight.bold,
                                                        decorationColor: Colors.blue,
                                                        decorationThickness: 2.0,
                                                      ),
                                                    ),
                                                    const TextSpan(
                                                      text: 'Seconds',
                                                      style: TextStyle(
                                                        fontSize: 16,
                                                        color: Colors.blue,
                                                        fontWeight: FontWeight.bold,
                                                        decorationColor: Colors.blue,
                                                        decorationThickness: 2.0,
                                                      ),
                                                    ),
                                                  ]),
                                            ),
                                          ) : Container(),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              SizedBox(height: size.height * 0.02,),
                              Container(
                                height: size.height * 0.05,
                                width: size.width * 0.4,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: CustomLoadingButton(
                                  text: 'Confirm',
                                  size: size.height * 0.025,
                                  onPressed: () {
                                    if (otp.isNotEmpty && otp != null && otp != '') {
                                      setState(() {
                                        _isLoading = true;
                                        login(otp);
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
                                  isLoading: _isLoading,
                                  buttonColor: backgroundColor,
                                  loadingIndicatorColor: menuSecondaryColor,
                                ),
                              ),
                              SizedBox(height: size.height * 0.02),
                              Container(
                                padding: const EdgeInsets.symmetric(vertical: 5),
                                alignment: Alignment.centerRight,
                                child: TextButton(
                                    onPressed: () {
                                      Navigator.pushReplacement(
                                          context, MaterialPageRoute(builder: (context) => const FamilyLoginScreen()));
                                    },
                                    child: Text(
                                      'Back to Sign in Page ?',
                                      style: TextStyle(
                                        fontSize: size.height * 0.018,
                                        fontWeight: FontWeight.bold,
                                        color: textHeadColor,
                                      ),
                                    )
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          )
      ),
    );
  }
}
