import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:munchirai/private/screens/dashboard/dashboard.dart';
import 'package:munchirai/widget/common/common.dart';
import 'package:munchirai/widget/common/internet_connection_checker.dart';
import 'package:munchirai/widget/common/snackbar.dart';
import 'package:munchirai/widget/custom_clipper/bezier_container.dart';
import 'package:munchirai/widget/helper/helper_function.dart';
import 'package:munchirai/widget/theme_color/theme_color.dart';
import 'package:munchirai/widget/widget.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PriestLoginScreen extends StatefulWidget {
  const PriestLoginScreen({Key? key}) : super(key: key);

  @override
  State<PriestLoginScreen> createState() => _PriestLoginScreenState();
}

class _PriestLoginScreenState extends State<PriestLoginScreen> {
  final formKey = GlobalKey<FormState>();
  var userNameController = TextEditingController();
  var passwordController = TextEditingController();
  bool _obscureText = true;
  bool _isLoading = false;
  bool userNameValid = false;
  bool userPasswordValid = false;
  bool _rememberMe = false;

  void login(String userName, password, database) async {
    database = db;
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
      Map data = {
        "params": {'login': userName, 'password': password, 'db': database}
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

  getSharedPreferenceData() async {
    if (loginName != '' && loginName != null && loginPassword != '' && loginPassword != null && remember != false) {
      userNameController.text = loginName;
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
                                'assets/images/login2.png',
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
                                    "Priest Login",
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
                                            'Username',
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
                                    SizedBox(height: size.height * 0.01,),
                                    Container(
                                      padding: const EdgeInsets.only(top: 10, bottom: 15),
                                      alignment: Alignment.topLeft,
                                      child: Row(
                                        children: [
                                          Text(
                                            'Password',
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
                                    SizedBox(
                                      height: size.height * 0.02,
                                    ),
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
                                    if(userNameController.text.isNotEmpty && passwordController.text.isNotEmpty) {
                                      setState(() {
                                        _isLoading = true;
                                        login(userNameController.text.toString(), passwordController.text.toString(), db);
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
