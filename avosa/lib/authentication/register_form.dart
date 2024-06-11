import 'dart:convert';

import 'package:avosa/widget/common/common.dart';
import 'package:avosa/widget/common/internet_connection_checker.dart';
import 'package:avosa/widget/common/snackbar.dart';
import 'package:avosa/widget/theme_color/theme_color.dart';
import 'package:avosa/widget/widget.dart';
import 'package:dropdown_textfield/dropdown_textfield.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

import 'login.dart';

class UserRegisterScreen extends StatefulWidget {
  const UserRegisterScreen({Key? key}) : super(key: key);

  @override
  State<UserRegisterScreen> createState() => _UserRegisterScreenState();
}

class _UserRegisterScreenState extends State<UserRegisterScreen> {
  final formKey = GlobalKey<FormState>();
  // Priest Login
  String parishName = "St. Mary's Catholic Church - Al Ain";
  var parishController = TextEditingController();
  var nameController = TextEditingController();
  var emailController = TextEditingController();
  var mobileController = TextEditingController();
  bool userEmailValid = false;
  bool userValidEmail = false;
  String email = '';

  bool isName = false;
  bool isMobile = false;
  bool isValid = false;
  String mobile = '';

  bool _isLoading = false;

  // Language Community
  final SingleValueDropDownController _languageType = SingleValueDropDownController();
  List languageTypeData = [];
  List<DropDownValueModel> languageTypeDropDown = [];

  String languageID = '';
  String language = '';
  bool isLanguage = false;

  // Ministry
  final SingleValueDropDownController _ministryType = SingleValueDropDownController();
  List ministryTypeData = [];
  List<DropDownValueModel> ministryTypeDropDown = [];

  String ministryID = '';
  String ministry = '';

  var reg = RegExp(r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+");
  var regMobile = RegExp(r"^(?:[+0]9)?[0-9]{10,15}$");

  void registerUser(String name, email, contact, language) async {
    if (email != '' && email.isNotEmpty && email != '' && mobile.isNotEmpty && language != '' && language.isNotEmpty ||
        formKey.currentState!.validate()) {

      String url = '$baseUrl/mobile/user_registration';
      Map data = {
        "params":{
          "name": name, "email": email, "mobile": mobile, "parish_id": int.parse(parishID), "language_community_id": int.parse(languageID), "ministry_id": int.parse(ministryID)
        }
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
        if (data['success'] == true) {
          Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const LoginScreen()));
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
    }
  }

  getLanguageCommunityData() async {
    var request = http.Request('GET', Uri.parse("$baseUrl/mobile/community_data"));
    request.body = json.encode({
      "params": {
        "parish_id": int.parse(parishID)
      }
    });
    request.headers.addAll(headers);
    http.StreamedResponse response = await request.send();
    if (response.statusCode == 200) {
      final decode = json.decode(await response.stream.bytesToString())['result'];
      if(decode['success'] == true) {
        List data = decode['data'];
        languageTypeData = data;
        for(int i = 0; i < languageTypeData.length; i++) {
          languageTypeDropDown.add(DropDownValueModel(name: languageTypeData[i]['name'], value: languageTypeData[i]['id']));
        }
        return languageTypeDropDown;
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

  getMinistryData() async {
    var request = http.Request('GET', Uri.parse("$baseUrl/mobile/ministry_data"));
    request.body = json.encode({
      "params": {
        "parish_id": int.parse(parishID)
      }
    });
    request.headers.addAll(headers);
    http.StreamedResponse response = await request.send();
    if (response.statusCode == 200) {
      final decode = json.decode(await response.stream.bytesToString())['result'];
      if(decode['success'] == true) {
        List data = decode['data'];
        ministryTypeData = data;
        for(int i = 0; i < ministryTypeData.length; i++) {
          ministryTypeDropDown.add(DropDownValueModel(name: ministryTypeData[i]['name'], value: ministryTypeData[i]['id']));
        }
        return ministryTypeDropDown;
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
    parishController.text = parishName;
    getLanguageCommunityData();
    getMinistryData();
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
                        image: AssetImage("assets/images/two.jpg"),
                        fit: BoxFit.fill
                    )
                ),
                child: Container(
                  color: primaryColor.withOpacity(0.8),
                ),
              ),
            ),
            // Trick to add the shadow for the submit button
            buildBottomHalfContainer(true),
            //Main Container for Login and Signup
            AnimatedPositioned(
              duration: const Duration(milliseconds: 500),
              curve: Curves.easeInExpo,
              top: size.height * 0.07,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 500),
                curve: Curves.easeInExpo,
                height: size.height * 0.85,
                padding: const EdgeInsets.all(15),
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
                                  "User Register",
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
              top: MediaQuery.of(context).size.height - 70,
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
          ],
        ),
      ),
    );
  }

  Container buildSignInSection() {
    Size size = MediaQuery.of(context).size;
    return Container(
      margin: const EdgeInsets.only(top: 5),
      child: Column(
        children: [
          Form(
            key: formKey,
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.only(top: 2, bottom: 5),
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
                  // height: size.height * 0.06,
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
                  padding: const EdgeInsets.only(top: 8, bottom: 5),
                  alignment: Alignment.topLeft,
                  child: Row(
                    children: [
                      Text(
                        'Your Name',
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
                  // height: size.height * 0.06,
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
                    controller: nameController,
                    keyboardType: TextInputType.text,
                    autocorrect: true,
                    autovalidateMode: AutovalidateMode.onUserInteraction,
                    style: GoogleFonts.breeSerif(
                        color: Colors.black,
                        letterSpacing: 1
                    ),
                    decoration: InputDecoration(
                      hintText: "Your Name",
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
                    // check tha validation
                    validator: (val) {
                      if (val!.isEmpty && val == '') {
                        isName = true;
                      } else {
                        isName = false;
                      }
                    },
                  ),
                ),
                isName ? Container(
                    alignment: Alignment.topLeft,
                    padding: const EdgeInsets.only(left: 10, top: 8),
                    child: const Text(
                      "Name is required",
                      style: TextStyle(
                          color: Colors.red,
                          fontWeight: FontWeight.w500
                      ),
                    )
                ) : Container(),
                Container(
                  padding: const EdgeInsets.only(top: 8, bottom: 5),
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
                  // height: size.height * 0.06,
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
                    padding: const EdgeInsets.only(left: 10, top: 5),
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
                    padding: const EdgeInsets.only(left: 10, top: 5),
                    child: const Text(
                      "Please enter a valid email address",
                      style: TextStyle(
                          color: Colors.red,
                          fontWeight: FontWeight.w500
                      ),
                    )
                ) : Container(),
                Container(
                  padding: const EdgeInsets.only(top: 8, bottom: 5),
                  alignment: Alignment.topLeft,
                  child: Row(
                    children: [
                      Text(
                        'Mobile No',
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
                  // height: size.height * 0.06,
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
                    controller: mobileController,
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
                        if(regMobile.hasMatch(val)) {
                          isMobile = false;
                          isValid = false;
                          mobile = mobileController.text.toString();
                        } else {
                          isMobile = false;
                          isValid = true;
                          mobile = '';
                        }
                      } else {
                        isMobile = true;
                        isValid = false;
                        mobile = '';
                      }
                    },
                  ),
                ),
                isMobile ? Container(
                    alignment: Alignment.topLeft,
                    padding: const EdgeInsets.only(left: 10, top: 5),
                    child: const Text(
                      "Mobile number is required",
                      style: TextStyle(
                          color: Colors.red,
                          fontWeight: FontWeight.w500
                      ),
                    )
                ) : isValid ? Container(
                    alignment: Alignment.topLeft,
                    padding: const EdgeInsets.only(left: 10, top: 5),
                    child: const Text(
                      "Please enter the valid mobile number",
                      style: TextStyle(
                          color: Colors.red,
                          fontWeight: FontWeight.w500
                      ),
                    )
                ) : Container(),
                Container(
                  padding: const EdgeInsets.only(top: 8, bottom: 5),
                  alignment: Alignment.topLeft,
                  child: Row(
                    children: [
                      Text(
                        'Language',
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
                  // height: size.height * 0.06,
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
                  child: DropDownTextField(
                    controller: _languageType,
                    listSpace: 20,
                    listPadding: ListPadding(top: 20),
                    searchShowCursor: true,
                    searchAutofocus: true,
                    enableSearch: true,
                    listTextStyle: GoogleFonts.breeSerif(color: Colors.black, fontSize: size.height * 0.02),
                    textStyle: GoogleFonts.breeSerif(color: Colors.black, letterSpacing: 0.2),
                    dropDownItemCount: 6,
                    dropDownList: languageTypeDropDown,
                    textFieldDecoration: InputDecoration(
                      prefixIcon: Icon(
                        Icons.language,
                        color: iconColor,
                        size: size.height * 0.03,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      hintText: "Select Language Community",
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
                          width: 0.5,
                        ),
                      ),
                    ),
                    onChanged: (val) {
                      if (val != null && val != "") {
                        language = val.name;
                        languageID = val.value.toString();
                        if(language.isNotEmpty && language != '') {
                          setState(() {
                            isLanguage = false;
                          });
                        }
                      } else {
                        setState(() {
                          isLanguage = true;
                          language = '';
                          languageID = '';
                        });
                      }
                    },
                  ),
                ),
                isLanguage ? Container(
                    alignment: Alignment.topLeft,
                    padding: const EdgeInsets.only(left: 10, top: 5),
                    child: const Text(
                      "Language is required",
                      style: TextStyle(
                          color: Colors.red,
                          fontWeight: FontWeight.w500
                      ),
                    )
                ) : Container(),
                Container(
                  padding: const EdgeInsets.only(top: 8, bottom: 5),
                  alignment: Alignment.topLeft,
                  child: Text(
                    'Ministry',
                    style: GoogleFonts.signika(
                      fontSize: size.height * 0.018,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
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
                  child: DropDownTextField(
                    controller: _ministryType,
                    listSpace: 20,
                    listPadding: ListPadding(top: 20),
                    searchShowCursor: true,
                    searchAutofocus: true,
                    enableSearch: true,
                    listTextStyle: GoogleFonts.breeSerif(color: Colors.black, fontSize: size.height * 0.02),
                    textStyle: GoogleFonts.breeSerif(color: Colors.black),
                    dropDownItemCount: 6,
                    dropDownList: ministryTypeDropDown,
                    textFieldDecoration: InputDecoration(
                      prefixIcon: Icon(
                        Icons.house,
                        color: iconColor,
                        size: size.height * 0.03,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      hintText: "Select Ministry",
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
                          width: 0.5,
                        ),
                      ),
                    ),
                    onChanged: (val) {
                      if (val != null && val != "") {
                        ministry = val.name;
                        ministryID = val.value.toString();
                      } else {
                        setState(() {
                          ministry = '';
                          ministryID = '';
                        });
                      }
                    },
                  ),
                )
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
      top: size.height * 0.89,
      right: 0,
      left: 0,
      child: Center(
        child: Container(
          height: 65,
          width: 65,
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
              if(nameController.text.toString().isNotEmpty && email != '' && email.isNotEmpty && mobile != '' && mobile.isNotEmpty && language != '' && language != null) {
                setState(() {
                  _isLoading = true;
                });
                registerUser(nameController.text.toString(), email, mobile, language);
              } else {
                setState(() {
                  if(userValidEmail == true) {
                    userValidEmail = true;
                  } else if(userEmailValid == true) {
                    userEmailValid = true;
                  } else {
                    userEmailValid = true;
                  }
                  if(isValid == true) {
                    isValid = true;
                  } else if(isMobile == true) {
                    isMobile = true;
                  } else {
                    isMobile = true;
                  }
                  if(nameController.text.isEmpty) isName = true;
                  if(language == '') isLanguage = true;
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
