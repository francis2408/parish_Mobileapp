import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/services.dart';
import 'package:flutter_svg/svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:munchirai/private/screens/authentication/priest_login.dart';
import 'package:munchirai/private/screens/authentication/verification_code.dart';
import 'package:munchirai/widget/common/common.dart';
import 'package:munchirai/widget/common/internet_connection_checker.dart';
import 'package:munchirai/widget/common/snackbar.dart';
import 'package:munchirai/widget/custom_clipper/bezier_container.dart';
import 'package:munchirai/widget/helper/helper_function.dart';
import 'package:munchirai/widget/theme_color/theme_color.dart';
import 'package:munchirai/widget/widget.dart';
import 'package:shared_preferences/shared_preferences.dart';

class FamilyLoginScreen extends StatefulWidget {
  const FamilyLoginScreen({Key? key}) : super(key: key);

  @override
  State<FamilyLoginScreen> createState() => _FamilyLoginScreenState();
}

class _FamilyLoginScreenState extends State<FamilyLoginScreen> {
  final formKey = GlobalKey<FormState>();
  var mobileNumberController = TextEditingController();
  bool _isLoading = false;
  bool isMobile = false;
  bool isValid = false;
  bool _rememberMe = false;
  String mobile = '';

  void login(String mobile) async {
    if (mobileNumberController.text.isNotEmpty || formKey.currentState!.validate()) {
      // SharedPreferences  using save the mobile number
      if(_rememberMe) {
        HelperFunctions.setNameSF(mobile);
        HelperFunctions.setUserRememberSF(_rememberMe);
      } else {
        SharedPreferences prefs = await SharedPreferences.getInstance();
        await prefs.remove('setMobileNumber');
        HelperFunctions.setUserRememberSF(_rememberMe);
      }

      String url = '$baseUrl/signup';
      Map data = {
        "params": {"mobile": "$mobile", "parish_id": int.parse(parishID)}
      };
      var body = json.encode(data);
      var response = await http.post(Uri.parse(url),
          headers: {
            'Content-type': 'application/json',
            'Accept': 'application/json'
          },
          body: body);
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body)['result'];
        if (data['status'] == true) {
          if(data['data']['family_id'] != false) {
            HelperFunctions.setFamilyIdSF(data['data']['family_id']);
          } else {
            var family = "";
            HelperFunctions.setFamilyIdsSF(family);
          }
          if(data['data']['login'] != false) {
            HelperFunctions.setLoginIdSF(data['data']['login']);
          }
          Navigator.of(context).pushReplacement(CustomRoute(widget: const VerificationCodeScreen()));

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
        isMobile = true;
        AnimatedSnackBar.show(
            context,
            'Please enter the mobile number',
            Colors.red
        );
      });
    }
  }

  getSharedPreferenceData() async {
    if (mobileNumber != '' && mobileNumber != null && remember != false) {
      mobileNumberController.text = mobileNumber;
      _rememberMe = remember!;
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
    super.initState();
    getSharedPreferenceData();
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
                                'assets/images/login1.png',
                                height: size.height * 0.4,
                                width: size.width * 0.55,
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
                                    "User Login",
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
                                  "We will send you the 6 digit verification code.",
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
                                    SizedBox(height: size.height * 0.02,),
                                    Container(
                                      padding: const EdgeInsets.only(top: 5, bottom: 15),
                                      alignment: Alignment.topLeft,
                                      child: Row(
                                        children: [
                                          Text(
                                            'Mobile No',
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
                                      child: TextFormField(
                                        controller: mobileNumberController,
                                        keyboardType: TextInputType.number,
                                        autocorrect: true,
                                        autovalidateMode: AutovalidateMode.onUserInteraction,
                                        inputFormatters: [
                                          LengthLimitingTextInputFormatter(10), // Limit to 10 characters
                                        ],
                                        style: GoogleFonts.breeSerif(
                                            color: Colors.black,
                                            letterSpacing: 1,
                                          fontSize: size.height * 0.02
                                        ),
                                        decoration: InputDecoration(
                                          hintText: "Your Mobile Number",
                                          prefixIcon: Icon(
                                            Icons.phone_android,
                                            color: iconColor,
                                            size: size.height * 0.03,
                                          ),
                                          border: OutlineInputBorder(
                                              borderRadius: BorderRadius.circular(10)
                                          ),
                                          hintStyle: GoogleFonts.breeSerif(
                                            color: labelColor2,
                                            fontStyle: FontStyle.italic,
                                          ),
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
                                        // check tha validationValidator
                                        validator: (val) {
                                          if(val!.isNotEmpty) {
                                            var reg = RegExp(r"^(?:[+0]9)?[0-9]{10,15}$");
                                            if(reg.hasMatch(val)) {
                                              isMobile = false;
                                              isValid = false;
                                              mobile = mobileNumberController.text.toString();
                                            } else {
                                              isMobile = false;
                                              isValid = true;
                                              mobile = '';
                                            }
                                          } else {
                                            isMobile = false;
                                            isValid = false;
                                            mobile = '';
                                          }
                                        },
                                      ),
                                    ),
                                    isMobile ? Container(
                                        alignment: Alignment.topLeft,
                                        padding: const EdgeInsets.only(left: 10, top: 8),
                                        child: const Text(
                                          "Mobile number is required",
                                          style: TextStyle(
                                              color: Colors.red,
                                              fontWeight: FontWeight.w500
                                          ),
                                        )
                                    ) : isValid ? Container(
                                        alignment: Alignment.topLeft,
                                        padding: const EdgeInsets.only(left: 10, top: 8),
                                        child: const Text(
                                          "Please enter the valid mobile number",
                                          style: TextStyle(
                                              color: Colors.red,
                                              fontWeight: FontWeight.w500
                                          ),
                                        )
                                    ) : Container(),
                                    SizedBox(height: size.height * 0.03,),
                                    GestureDetector(
                                      onTap: () async {
                                        await Navigator.pushReplacement(context, CustomRoute(widget: const PriestLoginScreen()));
                                      },
                                      child: Row(
                                        mainAxisAlignment: MainAxisAlignment.end,
                                        crossAxisAlignment: CrossAxisAlignment.end,
                                        children: [
                                          SvgPicture.asset('assets/icons/priest.svg', color: iconBackColor, height: 25, width: 25,),
                                          SizedBox(width: size.width * 0.01,),
                                          Text(
                                            'Priest Login',
                                            style: TextStyle(
                                              fontSize: size.height * 0.018,
                                              fontWeight: FontWeight.bold,
                                              color: hiLightColor,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    SizedBox(height: size.height * 0.01,),
                                    Padding(
                                      padding: const EdgeInsets.only(left: 10, right: 10),
                                      child: Row(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          Checkbox(
                                            activeColor: backgroundColor,
                                            checkColor: Colors.white,
                                            value: _rememberMe,
                                            onChanged: (value) {
                                              setState(() {
                                                _rememberMe = value!;
                                              });
                                            },
                                          ),
                                          Text(
                                              "Remember Me",
                                              style: GoogleFonts.signika(
                                                fontSize: size.height * 0.02,
                                                color: backgroundColor,
                                              )
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              SizedBox(height: size.height * 0.015,),
                              Container(
                                height: size.height * 0.05,
                                width: size.width * 0.4,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: CustomLoadingButton(
                                  text: 'Login',
                                  size: size.height * 0.025,
                                  onPressed: () {
                                    if (mobileNumberController.text.isNotEmpty && isMobile != true) {
                                      if (isValid == true) {
                                        setState(() {
                                          AnimatedSnackBar.show(
                                              context,
                                              'Please enter the valid mobile number',
                                              Colors.red
                                          );
                                        });
                                      } else {
                                        setState(() {
                                          _isLoading = true;
                                          login(
                                            mobileNumberController.text.toString(),
                                          );
                                        });
                                      }
                                    } else {
                                      if(isValid != true) {
                                        setState(() {
                                          isMobile = true;
                                          AnimatedSnackBar.show(
                                              context,
                                              'Please enter the mobile number',
                                              Colors.red
                                          );
                                        });
                                      } else {
                                        setState(() {
                                          isMobile = true;
                                          AnimatedSnackBar.show(
                                              context,
                                              'Please enter the valid mobile number',
                                              Colors.red
                                          );
                                        });
                                      }
                                    }
                                  },
                                  isLoading: _isLoading,
                                  buttonColor: backgroundColor,
                                  loadingIndicatorColor: menuSecondaryColor,
                                ),
                              ),
                              SizedBox(height: size.height * 0.01),
                              Container(
                                padding: const EdgeInsets.symmetric(vertical: 5),
                                alignment: Alignment.centerRight,
                                child: TextButton(
                                    onPressed: () {
                                      Navigator.pop(context, 'refresh');
                                    },
                                    child: Text(
                                      'Back to Home Page ?',
                                      style: TextStyle(
                                        fontSize: size.height * 0.018,
                                        fontWeight: FontWeight.bold,
                                        color: hiLightColor,
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
