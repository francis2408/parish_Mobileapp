import 'dart:convert';
import 'dart:io';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:avosa/authentication/register_form.dart';
import 'package:avosa/widget/common/common.dart';
import 'package:avosa/widget/common/internet_connection_checker.dart';
import 'package:avosa/widget/common/snackbar.dart';
import 'package:avosa/widget/helper/helper_function.dart';
import 'package:avosa/widget/navigation/navigation_bar.dart';
import 'package:avosa/widget/theme_color/theme_color.dart';
import 'package:avosa/widget/widget.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'forgot_password.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final formKey = GlobalKey<FormState>();
  // Priest Login
  String parishName = "St. Mary's Catholic Church - Al Ain";
  var parishController = TextEditingController();
  var emailController = TextEditingController();
  var passwordController = TextEditingController();
  bool _obscureText = true;
  bool userEmailValid = false;
  bool userValidEmail = false;
  bool userPasswordValid = false;
  String email = '';

  bool _isLoading = false;
  bool _rememberMe = false;

  var reg = RegExp(r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+");

  Future<void> getDeviceToken() async {
    final FirebaseMessaging fcm = FirebaseMessaging.instance;
    final token = await fcm.getToken();
    deviceToken = token.toString();
    getDeviceName();
  }

  void getDeviceName() async {
    DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
    String name = '';
    String? model = '';
    String osVersion = '';
    if(Platform.isAndroid) {
      AndroidDeviceInfo androidInfo = await deviceInfo.androidInfo;
      name = androidInfo.manufacturer;
      model = 'Android';
      osVersion = androidInfo.version.release;
    } else if(Platform.isIOS) {
      IosDeviceInfo iosInfo = await deviceInfo.iosInfo;
      name = iosInfo.name!;
      model = iosInfo.systemName!;
      osVersion = iosInfo.systemVersion!;
    } else {
      deviceName = 'Unknown Device';
    }
    deviceName = '$name ($model $osVersion)';
    // Store device token against the user
    login(email, passwordController.text);
  }

  void login(String email, password) async {
    if (email != '' && email.isNotEmpty && passwordController.text.isNotEmpty || formKey.currentState!.validate()) {
      // SharedPreferences  using save the username and password
      if(_rememberMe) {
        HelperFunctions.setUserEmailSF(email);
        HelperFunctions.setPasswordSF(password);
        HelperFunctions.setUserRememberSF(_rememberMe);
      } else {
        SharedPreferences prefs = await SharedPreferences.getInstance();
        await prefs.remove('userEmailKey');
        await prefs.remove('setPassword');
        HelperFunctions.setUserRememberSF(_rememberMe);
      }
      String url = '$baseUrl/mobile/authenticate';
      Map datas = {
        "params":{
          "email": email, "password": password, "parish_id": int.parse(parishID), "device_name": deviceName, "device_token": deviceToken
        }
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
        if (data['success'] == true) {
          HelperFunctions.setUserLoginSF(data['success']);
          HelperFunctions.setAuthTokenSF(data['token']);
          HelperFunctions.setUserNameSF(data['name']);
          HelperFunctions.setUserEmailSF(data['email']);
          HelperFunctions.setUserMobileSF(data['mobile']);
          HelperFunctions.setUserLanguageSF(data['language_id']['id']);
          HelperFunctions.setUserLanguagesSF(data['language_id']['name']);
          HelperFunctions.setMinistryIdSF(data['ministry_id']['id']);
          HelperFunctions.setMinistryIdsSF(data['ministry_id']['name']);
          HelperFunctions.saveUserLoggedInStatus(true);
          setState(() {
            _isLoading = false;
          });
          Navigator.of(context).pushReplacement(CustomRoute(widget: const NavigationBarScreen()));

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
        if(response.statusCode == 500) {
          setState(() {
            _isLoading = false;
            AnimatedSnackBar.show(
                context,
                'Internal Server Error',
                Colors.red
            );
          });
        } else {
          final data = jsonDecode(response.body)['message'];
          setState(() {
            _isLoading = false;
            AnimatedSnackBar.show(
                context,
                data["message"],
                Colors.red
            );
          });
        }
      }
    } else {
      setState(() {
        userEmailValid = true;
        userPasswordValid = true;
        AnimatedSnackBar.show(
            context,
            'Please enter the Email Address and Password',
            Colors.red
        );
      });
    }
  }

  getSharedPreferenceData() async {
    if (loginEmail != '' && loginEmail != null && loginPassword != '' && loginPassword != null && remember != false) {
      emailController.text = loginEmail;
      email = loginEmail;
      passwordController.text = loginPassword;
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
    getSharedPreferenceData();
    // Check the internet connection
    internetCheck();
    super.initState();
    parishController.text = parishName;
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return WillPopScope(
      onWillPop: () async {
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
        return false; },
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
                        image: AssetImage("assets/images/two.jpg"),
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
                        "Login to Continue",
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
              duration: const Duration(milliseconds: 500),
              curve: Curves.easeInExpo,
              top: size.height * 0.20,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 500),
                curve: Curves.easeInExpo,
                height: size.height * 0.58,
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
                                "Login",
                                style: TextStyle(
                                    fontSize: size.height * 0.02,
                                    fontWeight: FontWeight.bold,
                                    color: textHeadColor,
                                )
                              ),
                              Container(
                                margin: const EdgeInsets.only(top: 5),
                                height: 5,
                                width: 100,
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
              top: size.height - size.height * 0.16,
              child: SizedBox(
                width: MediaQuery.of(context).size.width,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Flexible(
                      child: Container(
                        width: size.width * 0.4,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(30),
                          color: whiteColor,
                          boxShadow: [
                            BoxShadow(
                                color: Colors.black.withOpacity(0.3),
                                blurRadius: 15,
                                spreadRadius: 5),
                          ],
                        ),
                        child: TextButton(
                          onPressed: () {
                            Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const UserRegisterScreen()));
                          },
                          child: Text(
                            'Register',
                            style: TextStyle(
                              fontSize: size.height * 0.018,
                              fontWeight: FontWeight.bold,
                              color: textHeadColor,
                            ),
                          ),
                        ),
                      ),
                    ),
                    const VerticalDivider(
                      thickness: 3,
                      color: secondaryColor,
                    ),
                    Flexible(
                      child: Container(
                        width: size.width * 0.4,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(30),
                          color: whiteColor,
                          boxShadow: [
                            BoxShadow(
                                color: Colors.black.withOpacity(0.3),
                                blurRadius: 15,
                                spreadRadius: 5),
                          ],
                        ),
                        child: TextButton(
                          onPressed: () {
                            Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const NavigationBarScreen()));
                          },
                          child: Text(
                            'Guest User',
                            style: TextStyle(
                              fontSize: size.height * 0.018,
                              fontWeight: FontWeight.bold,
                              color: textHeadColor,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
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
                Container(
                  padding: const EdgeInsets.only(top: 5, bottom: 10),
                  alignment: Alignment.topLeft,
                  child: Row(
                    children: [
                      Text(
                        'Parish Name',
                        style: GoogleFonts.signika(
                          fontSize: size.height * 0.018,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  width: size.width * 0.75,
                  alignment: Alignment.center,
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
                  child: TextFormField(
                    readOnly: true,
                    decoration: InputDecoration(
                      hintText: parishName,
                      hintStyle: GoogleFonts.breeSerif(
                        color: Colors.black,
                      ),
                      prefixIcon: Icon(
                        Icons.church,
                        color: iconColor,
                        size: size.height * 0.03,
                      ),
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10)
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
                  ),
                ),
                Container(
                  padding: const EdgeInsets.only(top: 10, bottom: 10),
                  alignment: Alignment.topLeft,
                  child: Row(
                    children: [
                      Text(
                        'Email ID',
                        style: GoogleFonts.signika(
                          fontSize: size.height * 0.018,
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
                  width: size.width * 0.75,
                  alignment: Alignment.center,
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
                  child: TextFormField(
                    controller: emailController,
                    keyboardType: TextInputType.emailAddress,
                    autocorrect: true,
                    autovalidateMode: AutovalidateMode.onUserInteraction,
                    style: GoogleFonts.breeSerif(
                        color: Colors.black,
                        letterSpacing: 1
                    ),
                    decoration: InputDecoration(
                      hintText: "Your Email Address",
                      border: InputBorder.none,
                      prefixIcon: Icon(
                        Icons.mail,
                        color: iconColor,
                        size: size.height * 0.03,
                      ),
                      hintStyle: const TextStyle(
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
                    // check tha validation
                    validator: (val) {
                      if (val!.isEmpty) {
                        userEmailValid = true;
                        userValidEmail = false;
                        email = '';
                      } else {
                        if(val.isNotEmpty) {
                          if(reg.hasMatch(val)) {
                            userEmailValid = false;
                            userValidEmail = false;
                            email = emailController.text.toString();
                          } else {
                            userValidEmail = true;
                            userEmailValid = false;
                            email = '';
                          }
                        }
                      }
                    },
                  ),
                ),
                userEmailValid ? Container(
                    alignment: Alignment.topLeft,
                    padding: const EdgeInsets.only(left: 10, top: 8),
                    child: const Text(
                      'Email Address is required',
                      style: TextStyle(
                          color: Colors.red,
                          fontWeight: FontWeight.w500
                      ),
                    )
                ) : Container(),
                userValidEmail ? Container(
                    alignment: Alignment.topLeft,
                    padding: const EdgeInsets.only(left: 10, top: 8),
                    child: const Text(
                      "Please enter a valid email address",
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
                          fontSize: size.height * 0.018,
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
                  width: size.width * 0.75,
                  alignment: Alignment.center,
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
                          activeColor: secondaryColor,
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
                              color: textColor,
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

  Widget buildBottomHalfContainer(bool showShadow) {
    Size size = MediaQuery.of(context).size;
    return AnimatedPositioned(
      duration: const Duration(milliseconds: 500),
      curve: Curves.easeIn,
      top: size.height * 0.73,
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
              if(email != '' && email.isNotEmpty && passwordController.text.isNotEmpty) {
                setState(() {
                  _isLoading = true;
                });
                getDeviceToken();
              } else {
                setState(() {
                  if(userValidEmail == true) {
                    userValidEmail = true;
                  } else if(userEmailValid == true) {
                    userEmailValid = true;
                  } else {
                    userEmailValid = true;
                  }
                  if(passwordController.text.isEmpty) {
                    userPasswordValid = true;
                  }
                  AnimatedSnackBar.show(
                      context,
                      'Please fill the required fields.',
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
