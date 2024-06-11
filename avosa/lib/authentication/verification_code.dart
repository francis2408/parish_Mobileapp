import 'dart:async';

import 'package:avosa/widget/common/internet_connection_checker.dart';
import 'package:avosa/widget/common/snackbar.dart';
import 'package:avosa/widget/theme_color/theme_color.dart';
import 'package:avosa/widget/widget.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

import 'login.dart';

class VerificationCodeScreen extends StatefulWidget {
  final String value;
  final bool type;
  const VerificationCodeScreen({Key? key, required this.value, required this.type}) : super(key: key);

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
  bool isSignupScreen = false;

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
      onWillPop: () async { return false; },
      child: Scaffold(
        backgroundColor: screenBackgroundColor,
        body: Stack(
          children: [
            const BackgroundWidget(),
            Positioned(
              top: 0,
              right: 0,
              left: 0,
              child: Container(
                height: size.height * 0.35,
                decoration: const BoxDecoration(
                    image: DecorationImage(
                        image: AssetImage("assets/images/four.jpeg"),
                        fit: BoxFit.fill)),
                child: Container(
                  padding: const EdgeInsets.only(top: 90, left: 20),
                  color: primaryColor.withOpacity(0.8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      RichText(
                        textAlign: TextAlign.center,
                        text: TextSpan(
                            text: "Welcome to",
                            style: GoogleFonts.portLligatSans(
                              fontSize: size.height * 0.022,
                              fontWeight: FontWeight.w700,
                              color: whiteColor,
                            ),
                            children: [
                              TextSpan(
                                text: " St. Mary's ",
                                style: TextStyle(color: textColor, fontSize: size.height * 0.022, fontWeight: FontWeight.w700,),
                              ),
                              TextSpan(
                                text: 'Catholic Church ',
                                style: TextStyle(color: textColor, fontSize: size.height * 0.022, fontWeight: FontWeight.w700,),
                              ),
                              TextSpan(
                                text: "- Al Ain",
                                style: TextStyle(color: textColor, fontSize: size.height * 0.022, fontWeight: FontWeight.w700,),
                              ),
                            ]),
                      ),
                      const SizedBox(
                        height: 10,
                      ),
                      Text(
                        "Verification",
                        style: TextStyle(
                          letterSpacing: 1,
                          color: Colors.white,
                          fontSize: size.height * 0.018,
                          fontWeight: FontWeight.w400,
                        ),
                      )
                    ],
                  ),
                ),
              ),
            ),
            // Trick to add the shadow for the submit button
            buildBottomHalfContainer(true),
            //Main Container for Login and Signup
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
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(15),
                    boxShadow: [
                      BoxShadow(
                          color: Colors.black.withOpacity(0.3),
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
                                    color: textHeadColor,
                                ),
                              ),
                              Container(
                                margin: const EdgeInsets.only(top: 5),
                                height: 5,
                                width: size.height * 0.15,
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
              top: MediaQuery.of(context).size.height - 300,
              right: 0,
              child: Container(
                alignment: Alignment.centerRight,
                child: TextButton(
                    onPressed: () {
                      Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const LoginScreen()));
                    },
                    child: Text(
                      'Back to login page',
                      style: TextStyle(
                        fontSize: size.height * 0.018,
                        fontWeight: FontWeight.bold,
                        color: textHeadColor,
                      ),
                    )
                ),
              ),
            ),
            Positioned(
              top: size.height - 60,
              right: 0,
              left: 0,
              child: Column(
                children: [
                  Text(
                    "Copyright © ${DateTime.now().year}. St. Mary's Catholic Church - Al Ain. ",
                    style: GoogleFonts.roboto(
                      fontSize: size.height * 0.016,
                      color: blackColor.withOpacity(0.8),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(
                    height: 5,
                  ),
                  Text(
                    'All rights reserved',
                    style: GoogleFonts.roboto(
                      fontSize: size.height * 0.016,
                      color: blackColor,
                      fontWeight: FontWeight.bold,
                    ),
                  )
                ],
              ),
            ),
          ],
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
                          'We have sent you an mail on ${widget.value} with 5 digits Verification code.',
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
                                    color: textColor,
                                    fontWeight: FontWeight.bold,
                                    decorationColor: Colors.blue,
                                    decorationThickness: 2.0,
                                  ),
                                ),
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
                                  text: 'Seconds',
                                  style: TextStyle(
                                    fontSize: size.height * 0.018,
                                    color: textColor,
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
                                color: textColor,
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
              color: Colors.white,
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
