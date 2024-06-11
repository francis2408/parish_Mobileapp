import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tenkasi/private/screens/authentication/forgot_password.dart';
import 'package:tenkasi/private/screens/dashboard/dashboard.dart';
import 'package:tenkasi/private/screens/home/home_screen.dart';
import 'package:tenkasi/widget/common/common.dart';
import 'package:tenkasi/widget/common/internet_connection_checker.dart';
import 'package:tenkasi/widget/common/snackbar.dart';
import 'package:tenkasi/widget/helper/helper_function.dart';
import 'package:tenkasi/widget/theme_color/theme_color.dart';
import 'package:tenkasi/widget/widget.dart';

import 'verification_code.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final formKey = GlobalKey<FormState>();
  // Priest Login
  var userNameController = TextEditingController();
  var passwordController = TextEditingController();
  bool _obscureText = true;
  bool userNameValid = false;
  bool userPasswordValid = false;

  // Family Login
  var mobileNumberController = TextEditingController();
  bool isMobile = false;
  bool isValid = false;
  String mobile = '';

  bool isSignupScreen = false;
  bool _isLoading = false;
  bool _rememberMe = false;

  void priestLogin(String userName, password, database) async {
    database = db;
    userLogin = userName;
    if (userNameController.text.isNotEmpty &&
        passwordController.text.isNotEmpty ||
        formKey.currentState!.validate()) {

      // SharedPreferences  using save the username and password
      if(_rememberMe) {
        HelperFunctions.setNameSF(userName);
        HelperFunctions.setPasswordSF(password);
        HelperFunctions.setUserRememberSF(_rememberMe);
      } else {
        SharedPreferences prefs = await SharedPreferences.getInstance();
        await prefs.remove('setName');
        await prefs.remove('setPassword');
        HelperFunctions.setUserRememberSF(_rememberMe);
      }

      String url = '$baseUrl/auth/token';
      Map datas = {
        "params": {'login': userName, 'password': password, 'db': database}
      };
      var body = json.encode(datas);
      var response = await http.post(Uri.parse(url),
          headers: {
            'Content-type': 'application/json',
            'Accept': 'application/json'
          },
          body: body);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body)['result'];
        if (data['status'] == true) {
          HelperFunctions.setDatabaseNameSF(database);
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
          Navigator.of(context).pushReplacement(CustomRoute(widget: const DashboardScreen()));

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
        userNameValid = true;
        userPasswordValid = true;
        AnimatedSnackBar.show(
            context,
            'Please enter the Username and Password',
            Colors.red
        );
      });
    }
  }

  void familyLogin(String mobile) async {
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
      Map datas = {
        "params": {"mobile": "$mobile", "parish_id": int.parse(parishID)}
      };
      var body = json.encode(datas);
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
          Navigator.of(context).pushReplacement(CustomRoute(widget: VerificationScreen(value: mobileNumberController.text.toString(), type: true,)));

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
        isMobile = true;
        AnimatedSnackBar.show(
            context,
            'Please enter the mobile number',
            Colors.red
        );
      });
    }
  }

  getPriestSharedPreferenceData() async {
    if (loginName != '' && loginName != null && loginPassword != '' && loginPassword != null && remember != false) {
      userNameController.text = loginName;
      passwordController.text = loginPassword;
      _rememberMe = remember!;
    }
  }

  getFamilySharedPreference() async {
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
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return WillPopScope(
      onWillPop: () async { return false; },
      child: Scaffold(
        backgroundColor: Colors.white,
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
                        RichText(
                          textAlign: TextAlign.center,
                          text: TextSpan(
                              text: "Welcome to",
                              style: TextStyle(
                                fontSize: size.height * 0.022,
                                fontWeight: FontWeight.w700,
                                color: Colors.black,
                              ),
                              children: [
                                // TextSpan(
                                //   text: ' St ',
                                //   style: TextStyle(color: Colors.black, fontSize: size.height * 0.022, fontWeight: FontWeight.w700,),
                                // ),
                                // TextSpan(
                                //   text: 'Michael Shrine ',
                                //   style: TextStyle(color: Colors.black, fontSize: size.height * 0.022, fontWeight: FontWeight.w700,),
                                // ),
                                // TextSpan(
                                //   text: "Tenkasi",
                                //   style: TextStyle(color: Colors.black, fontSize: size.height * 0.022, fontWeight: FontWeight.w700,),
                                // ),
                              ]),
                        ),
                        Text(
                          ' St Michael Shrine - Tenkasi',
                          style: TextStyle(color: primaryColor,fontSize: size.height * 0.022, fontWeight: FontWeight.w700,),
                        ),
                        // Text(
                        //   text: 'Michael Shrine ',
                        //   style: TextStyle(color: Colors.black, fontSize: size.height * 0.022, fontWeight: FontWeight.w700,),
                        // ),
                        // TextSpan(
                        //   text: "Tenkasi",
                        //   style: TextStyle(color: Colors.black, fontSize: size.height * 0.022, fontWeight: FontWeight.w700,),
                        // )
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
                  top: isSignupScreen ? size.height * 0.21: size.height * 0.23,
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 500),
                    curve: Curves.easeInExpo,
                    height: isSignupScreen ? size.height * 0.38 : size.height * 0.51,
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
                          Container(
                            padding: const EdgeInsets.only(bottom: 20.0),
                            alignment: Alignment.topLeft,
                            child: Text(
                              "Login to Continue",
                              style: TextStyle(
                                letterSpacing: 1,
                                fontSize: size.height * 0.02,
                                fontWeight: FontWeight.bold,
                              ),),
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              GestureDetector(
                                onTap: () {
                                  setState(() {
                                    isSignupScreen = false;
                                    _isLoading = false;
                                    userNameValid = false;
                                    userPasswordValid = false;
                                    _rememberMe = false;
                                    userNameController.text = '';
                                    passwordController.text = '';
                                  });
                                },
                                child: Column(
                                  children: [
                                    Text(
                                      "Priest User",
                                      style: TextStyle(
                                          fontSize: size.height * 0.02,
                                          fontWeight: FontWeight.bold,
                                          color: !isSignupScreen
                                              ? textHeadColor
                                              : Colors.black),
                                    ),
                                    if (!isSignupScreen)
                                      Container(
                                        margin: const EdgeInsets.only(top: 5),
                                        height: 5,
                                        width: 100,
                                        color: secondaryColor,
                                      )
                                  ],
                                ),
                              ),
                              GestureDetector(
                                onTap: () {
                                  setState(() {
                                    isSignupScreen = true;
                                    _isLoading = false;
                                    isMobile = false;
                                    isValid = false;
                                    _rememberMe = false;
                                    mobileNumberController.text = '';
                                    mobile = '';
                                  });
                                },
                                child: Column(
                                  children: [
                                    Text(
                                      "Family User",
                                      style: TextStyle(
                                          fontSize: size.height * 0.02,
                                          fontWeight: FontWeight.bold,
                                          color: isSignupScreen
                                              ? textHeadColor
                                              : Colors.black),
                                    ),
                                    if (isSignupScreen)
                                      Container(
                                        margin: const EdgeInsets.only(top: 5),
                                        height: 5,
                                        width: 100,
                                        color: secondaryColor,
                                      )
                                  ],
                                ),
                              )
                            ],
                          ),
                          if (!isSignupScreen) buildSignInSection(),
                          if (isSignupScreen) buildSignupSection(),
                        ],
                      ),
                    ),
                  ),
                ),
                // Trick to add the submit button
                buildBottomHalfContainer(false),
                // Bottom buttons
                Positioned(
                  top: MediaQuery.of(context).size.height - 180,
                  right: 0,
                  child: GestureDetector(
                    onTap: (){
                      Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const HomeScreen()));
                    },
                    child: Container(
                      alignment: Alignment.centerRight,
                      padding: const EdgeInsets.all(8),
                      decoration: const BoxDecoration(
                        borderRadius: BorderRadius.only(topLeft: Radius.circular(10) ,bottomLeft:Radius.circular(10) ),
                        gradient: LinearGradient(
                            colors: [Colors.orange, Colors.red],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight),
                      ),
                      child: Text(
                        'Back to home page',
                        style: TextStyle(
                          fontSize: size.height * 0.018,
                          fontWeight: FontWeight.bold,
                          color:  Colors.white,
                        ),
                      ),
                    ),
                  ),
                ),
                Positioned(
                  top: MediaQuery.of(context).size.height - 100,
                  right: 0,
                  left: 0,
                  child: Column(
                    children: [
                      Text(
                        'By Continuing, you agree to the ',
                        style: TextStyle(
                          fontSize: size.height * 0.018,
                          color: Colors.black,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(
                        height: 5,
                      ),
                      Text(
                        'Terms of Services & Privacy Policy',
                        style: TextStyle(
                          fontSize: size.height * 0.018,
                          color: Colors.black,
                          fontWeight: FontWeight.bold,
                        ),
                      )
                    ],
                  ),
                ),
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
                Container(
                  padding: const EdgeInsets.only(top: 5, bottom: 10),
                  alignment: Alignment.topLeft,
                  child: Row(
                    children: [
                      Text(
                        'Username',
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
                    color: Colors.white,
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
                    controller: userNameController,
                    keyboardType: TextInputType.text,
                    autocorrect: true,
                    autovalidateMode: AutovalidateMode.onUserInteraction,
                    style: GoogleFonts.breeSerif(
                        color: Colors.black,
                        letterSpacing: 1
                    ),
                    decoration: InputDecoration(
                      hintText: "Your Username",
                      prefixIcon: Icon(
                        Icons.person,
                        color: iconColor,
                        size: size.height * 0.03,
                      ),
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10)
                      ),
                      hintStyle: GoogleFonts.breeSerif(
                        color: Colors.black54,
                        fontStyle: FontStyle.italic,
                        fontSize: size.height * 0.018,
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: const BorderSide(
                          color:  Color(0xFFF0F0F1),
                          width: 1.0,
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: const BorderSide(
                          color:  Color(0xFFF0F0F1),
                          width: 1.0,
                        ),
                      ),
                    ),
                    // check tha validation
                    validator: (val) {
                      if (val!.isEmpty) {
                        userNameValid = true;
                      } else {
                        userNameValid = false;
                      }
                      return null;
                    },
                  ),
                ),
                userNameValid ? Container(
                    alignment: Alignment.topLeft,
                    padding: const EdgeInsets.only(left: 10, top: 8),
                    child: const Text(
                      "Username is required",
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
                        'Password',
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
                    color: Colors.white,
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
                    controller: passwordController,
                    keyboardType: TextInputType.visiblePassword,
                    obscureText: _obscureText,
                    autocorrect: true,
                    autovalidateMode: AutovalidateMode.onUserInteraction,
                    style: GoogleFonts.breeSerif(
                        color: Colors.black,
                        letterSpacing: 1
                    ),
                    decoration: InputDecoration(
                        hintText: "Your Password",
                        border: InputBorder.none,
                        prefixIcon: Icon(
                          Icons.lock,
                          color: iconColor,
                          size: size.height * 0.03,
                        ),
                        hintStyle: TextStyle(
                          color:  Colors.black54,
                          fontStyle: FontStyle.italic,
                          fontSize: size.height * 0.018,
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: const BorderSide(
                            color: Color(0xFFF0F0F1),
                            width: 1.0,
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: const BorderSide(
                            color: Color(0xFFF0F0F1),
                            width: 1.0,
                          ),
                        ),
                        suffixIcon: GestureDetector(
                          onTap: () {
                            setState(() {
                              _obscureText = !_obscureText;
                            });
                          },
                          child: _obscureText ? Icon(
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
                    // check tha validation
                    validator: (val) {
                      if (val!.isEmpty) {
                        userPasswordValid = true;
                      } else {
                        userPasswordValid = false;
                      }
                      return null;
                    },
                  ),
                ),
                userPasswordValid ? Container(
                    alignment: Alignment.topLeft,
                    padding: const EdgeInsets.only(left: 10, top: 8),
                    child: const Text(
                      'Password is required',
                      style: TextStyle(
                          color: Colors.red,
                          fontWeight: FontWeight.w500
                      ),
                    )
                ) : Container(),
                const SizedBox(
                  height: 10,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Checkbox(
                          activeColor: Colors.red,
                          checkColor: Colors.white,
                          value: _rememberMe,
                          onChanged: (value) {
                            setState(() {
                              _rememberMe = value!;
                            });
                          },
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(5),
                          ),
                        ),
                        Text(
                            "Remember Me",
                            style: GoogleFonts.signika(
                              fontSize: size.height * 0.018,
                              color: Colors.red,
                              fontWeight: FontWeight.w700,
                            )
                        ),
                      ],
                    ),
                    Container(
                      alignment: Alignment.centerRight,
                      child: TextButton(
                          onPressed: () {
                            Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const ForgotPasswordScreen()));
                          },
                          child: Text(
                            'Forgot Password ?',
                            style: TextStyle(
                              fontSize: size.height * 0.018,
                              color: textHeadColor,
                              fontWeight: FontWeight.w700,
                            ),
                          )
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Container buildSignupSection() {
    Size size = MediaQuery.of(context).size;
    return Container(
      margin: const EdgeInsets.only(top: 20),
      child: Column(
        children: [
          Form(
            key: formKey,
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.only(top: 5, bottom: 10),
                  alignment: Alignment.topLeft,
                  child: Row(
                    children: [
                      Text(
                        'Mobile No',
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
                    color: inputColor,
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
                        fontSize: size.height * 0.018,
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
                const SizedBox(height: 10,),
                Padding(
                  padding: const EdgeInsets.only(left: 10, right: 10),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Checkbox(
                        activeColor: Colors.red,
                        checkColor: Colors.white,
                        value: _rememberMe,
                        onChanged: (value) {
                          setState(() {
                            _rememberMe = value!;
                          });
                        },
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(5),
                        ),
                      ),
                      Text(
                          "Remember Me",
                          style: GoogleFonts.signika(
                            fontSize: size.height * 0.018,
                            color: Colors.red,
                            fontWeight: FontWeight.w600,
                          )
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
      duration: const Duration(milliseconds: 500),
      curve: Curves.easeIn,
      top: isSignupScreen ? size.height * 0.54 : size.height * 0.69,
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
              if(isSignupScreen == false) {
                if(userNameController.text.isNotEmpty && passwordController.text.isNotEmpty) {
                  setState(() {
                    _isLoading = true;
                    priestLogin(userNameController.text.toString(), passwordController.text.toString(), db);
                  });
                } else if(userNameController.text.isNotEmpty &&
                    passwordController.text.isEmpty) {
                  setState(() {
                    userPasswordValid = true;
                    AnimatedSnackBar.show(
                        context,
                        'Please enter the Password',
                        Colors.red
                    );
                  });
                } else if(userNameController.text.isEmpty &&
                    passwordController.text.isNotEmpty) {
                  setState(() {
                    userNameValid = true;
                    AnimatedSnackBar.show(
                        context,
                        'Please enter the Username',
                        Colors.red
                    );
                  });
                } else {
                  setState(() {
                    userNameValid = true;
                    userPasswordValid = true;
                    AnimatedSnackBar.show(
                        context,
                        'Please enter the username and password',
                        Colors.red
                    );
                  });
                }
              } else {
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
                      familyLogin(
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
                    Colors.white,
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