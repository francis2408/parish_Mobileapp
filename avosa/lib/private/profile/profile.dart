import 'dart:convert';

import 'package:avosa/widget/common/common.dart';
import 'package:avosa/widget/common/internet_connection_checker.dart';
import 'package:avosa/widget/common/slide_animations.dart';
import 'package:avosa/widget/common/snackbar.dart';
import 'package:avosa/widget/theme_color/theme_color.dart';
import 'package:avosa/widget/widget.dart';
import 'package:dropdown_textfield/dropdown_textfield.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:loading_indicator/loading_indicator.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final formKey = GlobalKey<FormState>();
  // Priest Login
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
  bool _isEdit = false;

  // Language Community
  List languageTypeData = [];
  List<DropDownValueModel> languageTypeDropDown = [];

  String languageID = '';
  String language = '';
  bool isLanguage = false;

  // Ministry
  List ministryTypeData = [];
  List<DropDownValueModel> ministryTypeDropDown = [];

  String ministryID = '';
  String ministry = '';

  var reg = RegExp(r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+");
  var regMobile = RegExp(r"^(?:[+0]9)?[0-9]{10,15}$");

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
        setState(() {
          _isLoading = false;
        });
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

  getSharedPreferenceData() {
    setState(() {
      nameController.text = userName;
      emailController.text = userEmail;
      email = userEmail;
      mobileController.text = userMobile;
      mobile = userMobile;
      languageID = userLanguage;
      language = userLanguageName;
      ministryID = userMinistry;
      ministry = userMinistryName;
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
    getSharedPreferenceData();
    // Check the internet connection
    internetCheck();
    super.initState();
    getLanguageCommunityData();
    getMinistryData();
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
        backgroundColor: screenBackgroundColor,
        appBar: AppBar(
          backgroundColor: primaryColor,
          title: Text('Profile', style: TextStyle(letterSpacing: 0.5, height: 1.3, fontSize: size.height * 0.02), textAlign: TextAlign.center, maxLines: 2,),
          centerTitle: true,
          // actions: [
          //   _isEdit ? Container() : IconButton(
          //     onPressed: () {
          //       setState(() {
          //         _isEdit = !_isEdit;
          //       });
          //     },
          //     icon: const Icon(Icons.edit, color: whiteColor, size: 30,),
          //   )
          // ],
        ),
        body: SafeArea(
          child: Stack(
            children: [
              const BackgroundWidget(),
              Container(
                padding: const EdgeInsets.all(10),
                child: Card(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(10),
                    child: SingleChildScrollView(
                      child: Form(
                        key: formKey,
                        child: _isLoading ? Center(
                          child: SizedBox(
                            height: size.height * 0.06,
                            child: const LoadingIndicator(
                              indicatorType: Indicator.ballSpinFadeLoader,
                              colors: [Colors.red,Colors.orange,Colors.yellow,Colors.green,Colors.blue,Colors.indigo,Colors.purple,],
                            ),
                          ),
                        ) : Column(
                          children: [
                            Container(
                              padding: _isEdit ? const EdgeInsets.only(top: 8, bottom: 5) : const EdgeInsets.only(top: 8),
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
                            _isEdit ? Container(
                              width: size.width * 0.85,
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
                            ) : TextFormField(
                              controller: nameController,
                              readOnly: true,
                              decoration: InputDecoration(
                                prefixIcon: Icon(
                                  Icons.person,
                                  color: iconColor,
                                  size: size.height * 0.03,
                                ),
                                border: const UnderlineInputBorder(),
                                enabledBorder: const UnderlineInputBorder(
                                  borderSide: BorderSide(
                                    color: disableColor,
                                    width: 1.0,
                                  ),
                                ),
                                focusedBorder: const UnderlineInputBorder(
                                  borderSide: BorderSide(
                                    color: disableColor,
                                    width: 1.0,
                                  ),
                                ),
                              ),
                              style: GoogleFonts.breeSerif(
                                  color: Colors.black,
                                  letterSpacing: 1
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
                              padding: _isEdit ? const EdgeInsets.only(top: 8, bottom: 5) : const EdgeInsets.only(top: 8),
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
                            _isEdit ? Container(
                              width: size.width * 0.85,
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
                            ) : TextFormField(
                              controller: emailController,
                              readOnly: true,
                              decoration: InputDecoration(
                                prefixIcon: Icon(
                                  Icons.email,
                                  color: iconColor,
                                  size: size.height * 0.03,
                                ),
                                border: const UnderlineInputBorder(),
                                enabledBorder: const UnderlineInputBorder(
                                  borderSide: BorderSide(
                                    color: disableColor,
                                    width: 1.0,
                                  ),
                                ),
                                focusedBorder: const UnderlineInputBorder(
                                  borderSide: BorderSide(
                                    color: disableColor,
                                    width: 1.0,
                                  ),
                                ),
                              ),
                              style: GoogleFonts.breeSerif(
                                  color: Colors.black,
                                  letterSpacing: 1
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
                              padding: _isEdit ? const EdgeInsets.only(top: 8, bottom: 5) : const EdgeInsets.only(top: 8),
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
                            _isEdit ? Container(
                              width: size.width * 0.85,
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
                                  LengthLimitingTextInputFormatter(10),
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
                            ) : TextFormField(
                              controller: mobileController,
                              readOnly: true,
                              decoration: InputDecoration(
                                prefixIcon: Icon(
                                  Icons.phone_android,
                                  color: iconColor,
                                  size: size.height * 0.03,
                                ),
                                border: const UnderlineInputBorder(),
                                enabledBorder: const UnderlineInputBorder(
                                  borderSide: BorderSide(
                                    color: disableColor,
                                    width: 1.0,
                                  ),
                                ),
                                focusedBorder: const UnderlineInputBorder(
                                  borderSide: BorderSide(
                                    color: disableColor,
                                    width: 1.0,
                                  ),
                                ),
                              ),
                              style: GoogleFonts.breeSerif(
                                  color: Colors.black,
                                  letterSpacing: 1
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
                              padding: _isEdit ? const EdgeInsets.only(top: 8, bottom: 5) : const EdgeInsets.only(top: 8),
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
                            _isEdit ? Container(
                              width: size.width * 0.85,
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
                                initialValue: language,
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
                                  hintText: language != '' ? language : "Select Language Community",
                                  hintStyle: GoogleFonts.breeSerif(
                                    color: language != '' ? valueColor : labelColor2,
                                    fontStyle: language != '' ? FontStyle.normal : FontStyle.italic,
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
                            ) : TextFormField(
                              initialValue: language,
                              readOnly: true,
                              decoration: InputDecoration(
                                prefixIcon: Icon(
                                  Icons.language,
                                  color: iconColor,
                                  size: size.height * 0.03,
                                ),
                                border: const UnderlineInputBorder(),
                                enabledBorder: const UnderlineInputBorder(
                                  borderSide: BorderSide(
                                    color: disableColor,
                                    width: 1.0,
                                  ),
                                ),
                                focusedBorder: const UnderlineInputBorder(
                                  borderSide: BorderSide(
                                    color: disableColor,
                                    width: 1.0,
                                  ),
                                ),
                              ),
                              style: GoogleFonts.breeSerif(
                                  color: Colors.black,
                                  letterSpacing: 1
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
                              padding: _isEdit ? const EdgeInsets.only(top: 8, bottom: 5) : const EdgeInsets.only(top: 8),
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
                            _isEdit ? Container(
                              width: size.width * 0.85,
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
                                initialValue: ministry,
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
                                  hintText: ministry != '' ? ministry : "Select Ministry",
                                  hintStyle: GoogleFonts.breeSerif(
                                    color: ministry != '' ? valueColor : labelColor2,
                                    fontStyle: ministry != '' ? FontStyle.normal : FontStyle.italic,
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
                            ) : TextFormField(
                              initialValue: ministry,
                              readOnly: true,
                              decoration: InputDecoration(
                                prefixIcon: Icon(
                                  Icons.house,
                                  color: iconColor,
                                  size: size.height * 0.03,
                                ),
                                border: const UnderlineInputBorder(),
                                enabledBorder: const UnderlineInputBorder(
                                  borderSide: BorderSide(
                                    color: disableColor,
                                    width: 1.0,
                                  ),
                                ),
                                focusedBorder: const UnderlineInputBorder(
                                  borderSide: BorderSide(
                                    color: disableColor,
                                    width: 1.0,
                                  ),
                                ),
                              ),
                              style: GoogleFonts.breeSerif(
                                  color: Colors.black,
                                  letterSpacing: 1
                              ),
                            ),
                            SizedBox(
                              height: size.height * 0.02,
                            )
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              )
            ],
          ),
        ),
        bottomSheet: _isEdit ? Container(
          decoration: const BoxDecoration(
              color: Colors.white,
              border: Border(
                  top: BorderSide(
                      color: Colors.grey,
                      width: 1.0
                  )
              )
          ),
          padding: EdgeInsets.only(top: size.height * 0.01, bottom: size.height * 0.01),
          child: SlideFadeAnimation(
            duration: const Duration(seconds: 1),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Container(
                  width: size.width * 0.4,
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(5),
                      color: Colors.red
                  ),
                  child: TextButton(
                      onPressed: () {
                        setState(() {
                          Navigator.pop(context, 'refresh');
                        });
                      },
                      child: Text('Cancel', style: TextStyle(color: Colors.white, fontSize: size.height * 0.02),)
                  ),
                ),
                Container(
                    width: size.width * 0.4,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(5),
                      color: greenColor,
                    ),
                    child: TextButton(
                        onPressed: () {
                          if(nameController.text.isNotEmpty && email != '' && email.isNotEmpty && mobile != '' && mobile.isNotEmpty && language.isNotEmpty && language != '') {
                            showDialog(
                              context: context,
                              barrierDismissible: false,
                              builder: (BuildContext context) {
                                return const CustomLoadingDialog();
                              },
                            );
                          } else {
                            setState(() {
                              if(userValidEmail == true) {
                                userValidEmail = true;
                              } else if(userEmailValid == true) {
                                userEmailValid = true;
                              } else {
                                if(email == '') {
                                  userEmailValid = true;
                                } else {
                                  userEmailValid = false;
                                }
                              }
                              if(isValid == true) {
                                isValid = true;
                              } else if(isMobile == true) {
                                isMobile = true;
                              } else {
                                if(mobile == '') {
                                  isMobile = true;
                                } else {
                                  isMobile = false;
                                }
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
                        child: Text('Update', style: TextStyle(color: Colors.white, fontSize: size.height * 0.02),)
                    )
                ),
              ],
            ),
          ),
        ) : null,
      ),
    );
  }
}
