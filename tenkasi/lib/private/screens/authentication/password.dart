import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:tenkasi/widget/common/common.dart';
import 'package:tenkasi/widget/common/internet_connection_checker.dart';
import 'package:tenkasi/widget/common/snackbar.dart';
import 'package:tenkasi/widget/theme_color/theme_color.dart';
import 'package:tenkasi/widget/widget.dart';

import 'login.dart';

class PasswordScreen extends StatefulWidget {
  final bool type;
  const PasswordScreen({Key? key, required this.type}) : super(key: key);

  @override
  State<PasswordScreen> createState() => _PasswordScreenState();
}

class _PasswordScreenState extends State<PasswordScreen> {
  final formKey = GlobalKey<FormState>();
  var newPasswordController = TextEditingController();
  var confirmPasswordController = TextEditingController();
  bool isSignupScreen = false;
  bool _isLoading = false;
  bool _obscurePasswordText = true;
  bool _obscureConfirmPasswordText = true;
  bool userNewPassword = false;
  bool validNewPassword = false;
  bool userConfirmPassword = false;
  bool validConfirmPassword = false;
  bool _isPasswordEightCharacters = false;
  bool _hasPasswordOneNumber = false;
  bool _hasPasswordSpecialCharter = false;
  bool _hasPasswordUpperCase = false;
  bool _isNotPasswordEightCharacters = false;
  bool _hasNotPasswordOneNumber = false;
  bool _hasNotPasswordSpecialCharter = false;
  bool _hasNotPasswordUpperCase = false;
  var reg = RegExp(r"^(?=.*?[A-Z])(?=.*?[a-z])(?=.*?[0-9])(?=.*?[!@#\$&*~]).{8,}$");

  setPassword(String newPassword, confirmPassword) async {
    if (newPasswordController.text.isNotEmpty && newPasswordController.text != '' &&
        confirmPasswordController.text.isNotEmpty && confirmPasswordController.text != '') {
      if(reg.hasMatch(newPasswordController.text) && reg.hasMatch(confirmPasswordController.text)) {
        if(newPasswordController.text == confirmPasswordController.text) {
          String url = '$baseUrl/set_password';
          Map datas = {
            "params":{
              "login": userLogin,
              "password": newPassword,
              "confirm_password": confirmPassword
            }
          };
          var body = jsonEncode(datas);
          var response = await http.post(Uri.parse(url),
              headers: {
                'Content-type': 'application/json',
                'Accept': 'application/json'
              },
              body: body);
          if (response.statusCode == 200) {
            final data = jsonDecode(response.body)['result'];
            if (data["status"] == true) {
              setState(() {
                _isLoading = false;
                Navigator.of(context).pushReplacement(CustomRoute(widget: const LoginScreen()));
                AnimatedSnackBar.show(
                    context,
                    data["message"],
                    Colors.green
                );
              });
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
                'Your password is mismatch.',
                Colors.red
            );
          });
        }
      } else {
        setState(() {
          _isLoading = false;
          AnimatedSnackBar.show(
              context,
              'Please enter the valid password',
              Colors.red
          );
        });
      }
    } else {
      setState(() {
        userNewPassword = true;
        userConfirmPassword = true;
        AnimatedSnackBar.show(
            context,
            'Please enter the New Password and Confirm Password',
            Colors.red
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
    super.initState();
    isSignupScreen = widget.type;
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return WillPopScope(
      onWillPop: () async { return false; },
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
                      children: [
                        // RichText(
                        //   textAlign: TextAlign.center,
                        //   text: TextSpan(
                        //       text: "Welcome to",
                        //       style: TextStyle(
                        //         fontSize: size.height * 0.022,
                        //         fontWeight: FontWeight.w700,
                        //         color: Colors.white,
                        //       ),
                        //       children: [
                        //         TextSpan(
                        //           text: ' St ',
                        //           style: TextStyle(color: Colors.white, fontSize: size.height * 0.022, fontWeight: FontWeight.w700,),
                        //         ),
                        //         TextSpan(
                        //           text: 'Michael Shrine ',
                        //           style: TextStyle(color: Colors.white, fontSize: size.height * 0.022, fontWeight: FontWeight.w700,),
                        //         ),
                        //         TextSpan(
                        //           text: "Tenkasi",
                        //           style: TextStyle(color: Colors.white, fontSize: size.height * 0.022, fontWeight: FontWeight.w700,),
                        //         ),
                        //       ]),
                        // ),
                      ],
                    ),
                  ),
                ),
                // Trick to add the shadow for the submit button
                buildBottomHalfContainer(true),
                //Main Container for Login and Signup
                AnimatedPositioned(
                  duration: const Duration(milliseconds: 500),
                  curve: Curves.easeInExpo,
                  top: isSignupScreen ? size.height * 0.20 : size.height * 0.20,
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 500),
                    curve: Curves.easeInExpo,
                    height: isSignupScreen ? size.height * 0.60 : size.height * 0.60,
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
                                  isSignupScreen ? Text(
                                    "Set Password",
                                    style: TextStyle(
                                        fontSize: size.height * 0.02,
                                        fontWeight: FontWeight.bold,
                                        color: !isSignupScreen
                                            ? textHeadColor
                                            : blackColor),
                                  ) : Text(
                                    "Change Password",
                                    style: TextStyle(
                                        fontSize: size.height * 0.02,
                                        fontWeight: FontWeight.bold,
                                        color: !isSignupScreen
                                            ? textHeadColor
                                            : blackColor),
                                  ),
                                  Container(
                                    margin: const EdgeInsets.only(top: 5),
                                    height: 5,
                                    width: size.width * 0.3,
                                    color: secondaryColor,
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
                // Trick to add the submit button
                buildBottomHalfContainer(false),
                // Bottom buttons
                Positioned(
                  top: MediaQuery.of(context).size.height - 140,
                  right: 0,
                  child: isSignupScreen ? GestureDetector(
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
                  ) : GestureDetector(
                    onTap: () {
                      Navigator.pop(context);
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
                        'Back to screen ?',
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
                //   top: MediaQuery.of(context).size.height - 80,
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
                Padding(
                  padding: const EdgeInsets.all(5),
                  child: Column(
                    children: [
                      Container(
                        alignment: Alignment.topCenter,
                        child: Text(
                          "Please create a secure password including the following criteria below.",
                          style: TextStyle(
                            fontSize: size.height * 0.018,
                            color: Colors.black,
                          ),
                        ),
                      ),
                      SizedBox(height: size.height * 0.02),
                      Row(
                        children: [
                          AnimatedContainer(
                            duration: const Duration(milliseconds: 500),
                            width: 20,
                            height: 20,
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(50)
                            ),
                            child: Center(child: Icon(_isPasswordEightCharacters ? Icons.check : _isNotPasswordEightCharacters ? Icons.close : Icons.circle, color: _isPasswordEightCharacters ? Colors.green : _isNotPasswordEightCharacters ? Colors.red : Colors.grey, size: 15,),),
                          ),
                          const SizedBox(width: 10,),
                          Text(
                            "Contains at least 8 characters",
                            style: TextStyle(
                              fontSize: size.height * 0.018,
                              fontWeight: FontWeight.bold,
                              color: Colors.grey,
                            ),
                          )
                        ],
                      ),
                      SizedBox(height: size.height * 0.005,),
                      Row(
                        children: [
                          AnimatedContainer(
                            duration: const Duration(milliseconds: 500),
                            width: 20,
                            height: 20,
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(50)
                            ),
                            child: Center(child: Icon(_hasPasswordUpperCase ? Icons.check : _hasNotPasswordUpperCase ? Icons.close : Icons.circle, color: _hasPasswordUpperCase ? Colors.green : _hasNotPasswordUpperCase ? Colors.red : Colors.grey, size: 15,),),
                          ),
                          const SizedBox(width: 10,),
                          Text(
                            "Contains at least 1 uppercase",
                            style: TextStyle(
                              fontSize: size.height * 0.018,
                              fontWeight: FontWeight.bold,
                              color: Colors.grey,
                            ),
                          )
                        ],
                      ),
                      SizedBox(height: size.height * 0.005,),
                      Row(
                        children: [
                          AnimatedContainer(
                            duration: const Duration(milliseconds: 500),
                            width: 20,
                            height: 20,
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(50)
                            ),
                            child: Center(child: Icon(_hasPasswordSpecialCharter ? Icons.check : _hasNotPasswordSpecialCharter ? Icons.close : Icons.circle, color: _hasPasswordSpecialCharter ? Colors.green : _hasNotPasswordSpecialCharter ? Colors.red : Colors.grey, size: 15,),),
                          ),
                          const SizedBox(width: 10,),
                          Text(
                            "Contains at least 1 special character",
                            style: TextStyle(
                              fontSize: size.height * 0.018,
                              fontWeight: FontWeight.bold,
                              color: Colors.grey,
                            ),
                          )
                        ],
                      ),
                      SizedBox(height: size.height * 0.005,),
                      Row(
                        children: [
                          AnimatedContainer(
                            duration: const Duration(milliseconds: 500),
                            width: 20,
                            height: 20,
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(50)
                            ),
                            child: Center(child: Icon(_hasPasswordOneNumber ? Icons.check : _hasNotPasswordOneNumber ? Icons.close : Icons.circle, color: _hasPasswordOneNumber ? Colors.green : _hasNotPasswordOneNumber ? Colors.red : Colors.grey, size: 15,),),
                          ),
                          const SizedBox(width: 10,),
                          Text(
                            "Contains at least 1 number",
                            style: TextStyle(
                              fontSize: size.height * 0.018,
                              fontWeight: FontWeight.bold,
                              color: Colors.grey,
                            ),
                          )
                        ],
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.only(top: 5, bottom: 10),
                  alignment: Alignment.topLeft,
                  child: Row(
                    children: [
                      Text(
                        'New Password',
                        style: GoogleFonts.signika(
                          fontSize: size.height * 0.02,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                      const SizedBox(width: 10,),
                      Text('*', style: GoogleFonts.signika(fontSize: size.height * 0.02, fontWeight: FontWeight.bold, color: Colors.red,),)
                    ],
                  ),
                ),
                Container(
                  height: size.height * 0.06,
                  width: size.width * 0.75,
                  alignment: Alignment.center,
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
                  child: TextFormField(
                    controller: newPasswordController,
                    obscureText: _obscurePasswordText,
                    autocorrect: true,
                    textAlign: TextAlign.start,
                    autovalidateMode: AutovalidateMode.onUserInteraction,
                    style: GoogleFonts.breeSerif(
                        color: Colors.black,
                        letterSpacing: 1
                    ),
                    decoration: InputDecoration(
                        hintText: "Your New Password",
                        border: InputBorder.none,
                        prefixIcon: Icon(
                          Icons.lock,
                          color: iconColor,
                          size: size.height * 0.03,
                        ),
                        hintStyle: const TextStyle(
                          color: labelColor2,
                          fontStyle: FontStyle.italic,
                        ),
                        suffixIcon: GestureDetector(
                          onTap: () {
                            setState(() {
                              _obscurePasswordText = !_obscurePasswordText;
                            });
                          },
                          child: _obscurePasswordText ? Icon(
                            Icons.visibility_off,
                            size: size.height * 0.03,
                            color: Colors.black54,
                          ) :  Icon(
                              Icons.visibility,
                              size: size.height * 0.03,
                              color: iconColor
                          ),
                        )
                    ),
                    onChanged: (val) {
                      final numericRegex = RegExp(r'[0-9]');
                      final specialRegex = RegExp(r'[!@#\$&*~]');
                      final upperRegex = RegExp(r'[A-Z]');
                      setState(() {
                        if(val.length >= 8) {
                          _isPasswordEightCharacters = true;
                          _isNotPasswordEightCharacters = false;
                        } else {
                          _isPasswordEightCharacters = false;
                          _isNotPasswordEightCharacters = true;
                        }
                        if(numericRegex.hasMatch(val)) {
                          _hasPasswordOneNumber = true;
                          _hasNotPasswordOneNumber = false;
                        } else {
                          _hasPasswordOneNumber = false;
                          _hasNotPasswordOneNumber = true;
                        }
                        if(specialRegex.hasMatch(val)) {
                          _hasPasswordSpecialCharter = true;
                          _hasNotPasswordSpecialCharter = false;
                        } else {
                          _hasPasswordSpecialCharter = false;
                          _hasNotPasswordSpecialCharter = true;
                        }
                        if(upperRegex.hasMatch(val)) {
                          _hasPasswordUpperCase = true;
                          _hasNotPasswordUpperCase = false;
                        } else {
                          _hasPasswordUpperCase = false;
                          _hasNotPasswordUpperCase = true;
                        }
                      });
                      if (val.isEmpty) {
                        userNewPassword = true;
                        validNewPassword = false;
                      } else {
                        if(val.isNotEmpty) {
                          if(reg.hasMatch(val)) {
                            userNewPassword = false;
                            validNewPassword = false;
                          } else {
                            userNewPassword = false;
                            validNewPassword = true;
                          }
                        }
                      }
                    },
                    // check tha validation
                    validator: (val) {
                      if (val!.isEmpty) {
                        userNewPassword = true;
                        validNewPassword = false;
                      } else {
                        if(val.isNotEmpty) {
                          if(reg.hasMatch(val)) {
                            userNewPassword = false;
                            validNewPassword = false;
                          } else {
                            userNewPassword = false;
                            validNewPassword = true;
                          }
                        }
                      }
                      return null;
                    },
                  ),
                ),
                userNewPassword ? Container(
                    alignment: Alignment.topLeft,
                    padding: const EdgeInsets.only(left: 10, top: 8),
                    child: const Text(
                      "New password is required",
                      style: TextStyle(
                          color: Colors.red,
                          fontWeight: FontWeight.w500
                      ),
                    )
                ) : Container(),
                validNewPassword ? Container(
                    alignment: Alignment.topLeft,
                    padding: const EdgeInsets.only(left: 10, top: 8),
                    child: const Text(
                      "Please enter a valid password",
                      style: TextStyle(
                          color: Colors.red,
                          fontWeight: FontWeight.w500
                      ),
                    )
                ) : Container(),
                Container(
                  padding: const EdgeInsets.only(top: 10, bottom: 10),
                  alignment: Alignment.topLeft,
                  child: Row(
                    children: [
                      Text(
                        'Confirm Password',
                        style: GoogleFonts.signika(
                          fontSize: size.height * 0.02,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                      const SizedBox(width: 10,),
                      Text('*', style: GoogleFonts.signika(fontSize: size.height * 0.02, fontWeight: FontWeight.bold, color: Colors.red,),)
                    ],
                  ),
                ),
                Container(
                  height: size.height * 0.06,
                  width: size.width * 0.75,
                  alignment: Alignment.center,
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
                  child: TextFormField(
                    controller: confirmPasswordController,
                    obscureText: _obscureConfirmPasswordText,
                    autocorrect: true,
                    textAlign: TextAlign.start,
                    autovalidateMode: AutovalidateMode.onUserInteraction,
                    style: GoogleFonts.breeSerif(
                        color: Colors.black,
                        letterSpacing: 1
                    ),
                    decoration: InputDecoration(
                        hintText: "Your Confirm Password",
                        border: InputBorder.none,
                        prefixIcon: Icon(
                          Icons.verified_user_rounded,
                          color: iconColor,
                          size: size.height * 0.03,
                        ),
                        hintStyle: const TextStyle(
                          color: labelColor2,
                          fontStyle: FontStyle.italic,
                        ),
                        suffixIcon: GestureDetector(
                          onTap: () {
                            setState(() {
                              _obscureConfirmPasswordText = !_obscureConfirmPasswordText;
                            });
                          },
                          child: _obscureConfirmPasswordText ? Icon(
                            Icons.visibility_off,
                            size: size.height * 0.03,
                            color: Colors.black54,
                          ) :  Icon(
                              Icons.visibility,
                              size: size.height * 0.03,
                              color: iconColor
                          ),
                        )
                    ),
                    onChanged: (val) {
                      _isPasswordEightCharacters = false;
                      _hasPasswordOneNumber = false;
                      _hasPasswordSpecialCharter = false;
                      _hasPasswordUpperCase = false;
                      _isNotPasswordEightCharacters = false;
                      _hasNotPasswordOneNumber = false;
                      _hasNotPasswordSpecialCharter = false;
                      _hasNotPasswordUpperCase = false;
                      final numericRegex = RegExp(r'[0-9]');
                      final specialRegex = RegExp(r'[!@#\$&*~]');
                      final upperRegex = RegExp(r'[A-Z]');
                      setState(() {
                        if(val.length >= 8) {
                          _isPasswordEightCharacters = true;
                          _isNotPasswordEightCharacters = false;
                        } else {
                          _isPasswordEightCharacters = false;
                          _isNotPasswordEightCharacters = true;
                        }
                        if(numericRegex.hasMatch(val)) {
                          _hasPasswordOneNumber = true;
                          _hasNotPasswordOneNumber = false;
                        } else {
                          _hasPasswordOneNumber = false;
                          _hasNotPasswordOneNumber = true;
                        }
                        if(specialRegex.hasMatch(val)) {
                          _hasPasswordSpecialCharter = true;
                          _hasNotPasswordSpecialCharter = false;
                        } else {
                          _hasPasswordSpecialCharter = false;
                          _hasNotPasswordSpecialCharter = true;
                        }
                        if(upperRegex.hasMatch(val)) {
                          _hasPasswordUpperCase = true;
                          _hasNotPasswordUpperCase = false;
                        } else {
                          _hasPasswordUpperCase = false;
                          _hasNotPasswordUpperCase = true;
                        }
                      });
                      if (val.isEmpty) {
                        userConfirmPassword = true;
                        validConfirmPassword = false;
                      } else {
                        if(val.isNotEmpty) {
                          if(reg.hasMatch(val)) {
                            userConfirmPassword = false;
                            validConfirmPassword = false;
                          } else {
                            validConfirmPassword = true;
                            userConfirmPassword = false;
                          }
                        }
                      }
                    },
                    // check tha validation
                    validator: (val) {
                      if (val!.isEmpty) {
                        userConfirmPassword = true;
                        validConfirmPassword = false;
                      } else {
                        if(val.isNotEmpty) {
                          if(reg.hasMatch(val)) {
                            userConfirmPassword = false;
                            validConfirmPassword = false;
                          } else {
                            validConfirmPassword = true;
                            userConfirmPassword = false;
                          }
                        }
                      }
                      return null;
                    },
                  ),
                ),
                userConfirmPassword ? Container(
                    alignment: Alignment.topLeft,
                    padding: const EdgeInsets.only(left: 10, top: 8),
                    child: const Text(
                      "Confirm password is required",
                      style: TextStyle(
                          color: Colors.red,
                          fontWeight: FontWeight.w500
                      ),
                    )
                ) : Container(),
                validConfirmPassword ? Container(
                    alignment: Alignment.topLeft,
                    padding: const EdgeInsets.only(left: 10, top: 8),
                    child: const Text(
                      "Please enter a valid confirm password",
                      style: TextStyle(
                          color: Colors.red,
                          fontWeight: FontWeight.w500
                      ),
                    )
                ) : Container(),
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
      duration: const Duration(milliseconds: 500),
      curve: Curves.easeIn,
      top: isSignupScreen ? size.height * 0.75 : size.height * 0.75,
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
              if(newPasswordController.text.isNotEmpty && confirmPasswordController.text.isNotEmpty) {
                setState(() {
                  _isLoading = true;
                  setPassword(
                    newPasswordController.text.toString(),
                    confirmPasswordController.text.toString(),
                  );
                });
              } else if(newPasswordController.text.isNotEmpty &&
                  confirmPasswordController.text.isEmpty) {
                setState(() {
                  userConfirmPassword = true;
                  AnimatedSnackBar.show(
                      context,
                      'Please enter the confirm password',
                      Colors.red
                  );
                });
              } else if(newPasswordController.text.isEmpty &&
                  confirmPasswordController.text.isNotEmpty) {
                setState(() {
                  userNewPassword = true;
                  AnimatedSnackBar.show(
                      context,
                      'Please enter the password',
                      Colors.red
                  );
                });
              } else {
                setState(() {
                  userConfirmPassword = true;
                  userNewPassword = true;
                  AnimatedSnackBar.show(
                      context,
                      'Please enter the new password and confirm password',
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