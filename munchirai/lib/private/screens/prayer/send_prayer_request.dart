import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:munchirai/widget/common/common.dart';
import 'package:munchirai/widget/common/internet_connection_checker.dart';
import 'package:munchirai/widget/common/snackbar.dart';
import 'package:munchirai/widget/theme_color/theme_color.dart';
import 'package:munchirai/widget/widget.dart';

class SendPrayerRequest extends StatefulWidget {
  const SendPrayerRequest({Key? key}) : super(key: key);

  @override
  State<SendPrayerRequest> createState() => _SendPrayerRequestState();
}

class _SendPrayerRequestState extends State<SendPrayerRequest> {
  final formKey = GlobalKey<FormState>();
  var titleController = TextEditingController();
  var mobileNumberController = TextEditingController();
  var emailController = TextEditingController();
  var dateController = TextEditingController();
  var descriptionController = TextEditingController();
  String dates = '';
  String mobile = '';
  String email = '';

  bool _isLoading = true;
  bool load = true;
  bool isTitle = false;
  bool isDescription = false;
  bool isMobile = false;
  bool isEmail = false;
  bool isDate = false;

  final format = DateFormat("dd-MM-yyyy");
  final reverse = DateFormat("yyyy-MM-dd");

  save(String name, date, description) async {
    var request = http.Request('POST',  Uri.parse('$baseUrl/public/$parishID/parish_prayer_request'));
    request.body = json.encode({
      "params": {"name": name, "date": dates, "mobile": mobile, "email": email, "note": description}
    });
    request.headers.addAll(sendHeader);
    http.StreamedResponse response = await request.send();
    if(response.statusCode == 200) {
      final message = json.decode(await response.stream.bytesToString())['result']['message'];
      setState(() {
        _isLoading = false;
        AnimatedSnackBar.show(
            context,
            'Prayer Request created successfully.',
            Colors.green
        );
        Navigator.pop(context);
        Navigator.pop(context, 'refresh');
      });
    } else {
      final message = json.decode(await response.stream.bytesToString())['message'];
      setState(() {
        Navigator.pop(context);
        _isLoading = false;
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
    // TODO: implement initState
    super.initState();
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
          title: Text(
            'Prayer Request',
            style: TextStyle(
              fontSize: size.height * 0.02,
              fontWeight: FontWeight.bold,
              color: whiteColor,
            ),
          ),
          centerTitle: true,
          flexibleSpace: Container(
            decoration: const BoxDecoration(
                gradient: LinearGradient(
                    colors: [
                      primaryColor,
                      secondaryColor
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight
                )
            ),
          ),
          // backgroundColor: backgroundColor,
        ),
        body: SafeArea(
          child: Container(
            padding: EdgeInsets.only(left: size.width * 0.01, right: size.width * 0.01),
            alignment: Alignment.topLeft,
            child: Form(
              key: formKey,
              child: ListView(
                children: [
                  SizedBox(height: size.height * 0.02,),
                  Card(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10)
                    ),
                    child: Container(
                      padding: const EdgeInsets.all(10),
                      child: Column(
                        children: [
                          Container(
                            padding: const EdgeInsets.only(top: 5, bottom: 10),
                            alignment: Alignment.topLeft,
                            child: Row(
                              children: [
                                Text(
                                  'Requester Name',
                                  style: GoogleFonts.poppins(
                                    fontSize: size.height * 0.018,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black54,
                                  ),
                                ),
                                SizedBox(width: size.width * 0.02,),
                                Text('*', style: GoogleFonts.poppins(fontSize: size.height * 0.02, fontWeight: FontWeight.bold, color: Colors.red,),)
                              ],
                            ),
                          ),
                          Container(
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(10),
                                color: inputColors
                            ),
                            child: TextFormField(
                              controller: titleController,
                              keyboardType: TextInputType.text,
                              autocorrect: true,
                              autovalidateMode: AutovalidateMode.onUserInteraction,
                              style: GoogleFonts.breeSerif(
                                  color: Colors.black,
                                  letterSpacing: 0.2
                              ),
                              decoration: InputDecoration(
                                hintText: "Enter person name",
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
                                    color: enableColor,
                                    width: 1.0,
                                  ),
                                ),
                              ),
                              // check tha validation
                              validator: (val) {
                                if (val!.isEmpty && val == '') {
                                  isTitle = true;
                                } else {
                                  isTitle = false;
                                }
                              },
                            ),
                          ),
                          isTitle ? Container(
                              alignment: Alignment.topLeft,
                              padding: const EdgeInsets.only(left: 10, top: 8),
                              child: const Text(
                                "Title is required",
                                style: TextStyle(
                                    color: Colors.red,
                                    fontWeight: FontWeight.w500
                                ),
                              )
                          ) : Container(),
                          SizedBox(
                            height: size.height * 0.01,
                          ),
                          Container(
                            padding: const EdgeInsets.only(top: 5, bottom: 10),
                            alignment: Alignment.topLeft,
                            child: Row(
                              children: [
                                Text(
                                  'Mobile Number',
                                  style: GoogleFonts.poppins(
                                    fontSize: size.height * 0.018,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black54,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Container(
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(10),
                                color: inputColors
                            ),
                            child: TextFormField(
                              controller: mobileNumberController,
                              keyboardType: TextInputType.phone,
                              autocorrect: true,
                              autovalidateMode: AutovalidateMode.onUserInteraction,
                              inputFormatters: [
                                LengthLimitingTextInputFormatter(13), // Limit to 10 characters
                              ],
                              style: GoogleFonts.breeSerif(
                                  color: Colors.black,
                                  letterSpacing: 0.2
                              ),
                              decoration: InputDecoration(
                                hintText: "Enter your mobile number",
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
                                    color: enableColor,
                                    width: 1.0,
                                  ),
                                ),
                              ),
                              // check tha validation
                              validator: (val) {
                                if(val!.isNotEmpty) {
                                  var reg = RegExp(r"^(?:[+0]9)?[0-9]{10,15}$");
                                  if(reg.hasMatch(val)) {
                                    isMobile = false;
                                    mobile = mobileNumberController.text.toString();
                                  } else {
                                    isMobile = true;
                                  }
                                } else {
                                  isMobile = false;
                                  mobile = '';
                                }
                              },
                            ),
                          ),
                          isMobile ? Container(
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
                          SizedBox(
                            height: size.height * 0.01,
                          ),
                          Container(
                            padding: const EdgeInsets.only(top: 5, bottom: 10),
                            alignment: Alignment.topLeft,
                            child: Row(
                              children: [
                                Text(
                                  'Date',
                                  style: GoogleFonts.poppins(
                                    fontSize: size.height * 0.018,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black54,
                                  ),
                                ),
                                SizedBox(width: size.width * 0.02,),
                                Text('*', style: GoogleFonts.poppins(fontSize: size.height * 0.02, fontWeight: FontWeight.bold, color: Colors.red,),)
                              ],
                            ),
                          ),
                          Container(
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(10),
                                color: inputColors
                            ),
                            child: TextFormField(
                              controller: dateController,
                              keyboardType: TextInputType.datetime,
                              autocorrect: true,
                              autovalidateMode: AutovalidateMode.onUserInteraction,
                              style: GoogleFonts.breeSerif(
                                  color: Colors.black,
                                  letterSpacing: 0.2
                              ),
                              decoration: InputDecoration(
                                suffixIcon: const Icon(
                                  Icons.calendar_month,
                                  color: Colors.indigo,
                                ),
                                hintText: "Choose the date",
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
                                    color: enableColor,
                                    width: 1.0,
                                  ),
                                ),
                              ),
                              // check the validation
                              validator: (val) {
                                if (val!.isEmpty && val == '') {
                                  isDate = true;
                                } else {
                                  isDate = false;
                                }
                              },
                              onChanged: (val) {
                                if(val.isEmpty) {
                                  setState(() {
                                    dateController.text = '';
                                    dates = '';
                                    isDate = true;
                                  });
                                }
                              },
                              onFieldSubmitted: (val) {
                                if(val.isEmpty) {
                                  dateController.text = '';
                                  dates = '';
                                  isDate = true;
                                }
                              },
                              onTap: () async {
                                DateTime? datePick = await showDatePicker(
                                  context: context,
                                  initialDate: dateController.text.isNotEmpty ? format.parse(dateController.text) :DateTime.now(),
                                  firstDate: DateTime(1900),
                                  lastDate: DateTime.now().add(const Duration(days: 365 * 1)),
                                  builder: (context, child) {
                                    return Theme(
                                      data: Theme.of(context).copyWith(
                                        colorScheme: const ColorScheme.light(
                                          primary: primaryColor,
                                          onPrimary: Colors.white,
                                          onSurface: Colors.black,
                                        ),
                                        textButtonTheme: TextButtonThemeData(
                                          style: TextButton.styleFrom(
                                            foregroundColor: backgroundColor,
                                          ),
                                        ),
                                      ),
                                      child: child!,
                                    );
                                  },
                                );
                                if (datePick != null) {
                                  setState(() {
                                    var dateNow = DateTime.now();
                                    var diff = dateNow.difference(datePick);
                                    var year = ((diff.inDays)/365).round();
                                    dateController.text = format.format(datePick);
                                    dates = reverse.format(datePick);
                                  });
                                }
                              },
                            ),
                          ),
                          isDate ? Container(
                              alignment: Alignment.topLeft,
                              padding: const EdgeInsets.only(left: 10, top: 8),
                              child: const Text(
                                "Date is required",
                                style: TextStyle(
                                    color: Colors.red,
                                    fontWeight: FontWeight.w500
                                ),
                              )
                          ) : Container(),
                          SizedBox(
                            height: size.height * 0.01,
                          ),
                          Container(
                            padding: const EdgeInsets.only(top: 5, bottom: 10),
                            alignment: Alignment.topLeft,
                            child: Row(
                              children: [
                                Text(
                                  'Email',
                                  style: GoogleFonts.poppins(
                                    fontSize: size.height * 0.018,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black54,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Container(
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(10),
                                color: inputColors
                            ),
                            child: TextFormField(
                              controller: emailController,
                              keyboardType: TextInputType.emailAddress,
                              autocorrect: true,
                              autovalidateMode: AutovalidateMode.onUserInteraction,
                              style: GoogleFonts.breeSerif(
                                  color: Colors.black,
                                  letterSpacing: 0.2
                              ),
                              decoration: InputDecoration(
                                hintText: "Enter your email address",
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
                                    color: enableColor,
                                    width: 1.0,
                                  ),
                                ),
                              ),
                              // check tha validation
                              validator: (val) {
                                if(val!.isNotEmpty && val != '') {
                                  var reg = RegExp(r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+");
                                  if(reg.hasMatch(val)) {
                                    email = emailController.text.toString();
                                    isEmail = false;
                                  } else {
                                    isEmail = true;
                                  }
                                } else {
                                  isEmail = false;
                                  email = '';
                                }
                              },
                            ),
                          ),
                          isEmail ? Container(
                              alignment: Alignment.topLeft,
                              padding: const EdgeInsets.only(left: 10, top: 8),
                              child: const Text(
                                "Please enter the valid email address",
                                style: TextStyle(
                                    color: Colors.red,
                                    fontWeight: FontWeight.w500
                                ),
                              )
                          ) : Container(),
                          SizedBox(
                            height: size.height * 0.01,
                          ),
                          Container(
                            padding: const EdgeInsets.only(top: 5, bottom: 10),
                            alignment: Alignment.topLeft,
                            child: Row(
                              children: [
                                Text(
                                  'Description',
                                  style: GoogleFonts.poppins(
                                    fontSize: size.height * 0.018,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black54,
                                  ),
                                ),
                                SizedBox(width: size.width * 0.02,),
                                Text('*', style: GoogleFonts.poppins(fontSize: size.height * 0.02, fontWeight: FontWeight.bold, color: Colors.red,),)
                              ],
                            ),
                          ),
                          Container(
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(10),
                                color: inputColors
                            ),
                            child: TextFormField(
                              controller: descriptionController,
                              keyboardType: TextInputType.text,
                              autocorrect: true,
                              autovalidateMode: AutovalidateMode.onUserInteraction,
                              inputFormatters: [
                                LengthLimitingTextInputFormatter(2000), // Limit to 10 characters
                              ],
                              maxLines: 15,
                              style: GoogleFonts.breeSerif(
                                  color: Colors.black,
                                  letterSpacing: 0.2
                              ),
                              decoration: InputDecoration(
                                hintText: "Enter the description",
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
                                    color: enableColor,
                                    width: 1.0,
                                  ),
                                ),
                              ),
                              // check the validation
                              validator: (val) {
                                if (val!.isEmpty && val == '') {
                                  isDescription = true;
                                } else {
                                  isDescription = false;
                                }
                              },
                            ),
                          ),
                          isDescription ? Container(
                              alignment: Alignment.topLeft,
                              padding: const EdgeInsets.only(left: 10, top: 8),
                              child: const Text(
                                "Description is required",
                                style: TextStyle(
                                    color: Colors.red,
                                    fontWeight: FontWeight.w500
                                ),
                              )
                          ) : Container(),
                          SizedBox(
                            height: size.height * 0.01,
                          ),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(height: size.height * 0.1,),
                ],
              ),
            ),
          ),
        ),
        bottomSheet: Container(
          decoration: const BoxDecoration(
              color: whiteColor,
              border: Border(
                  top: BorderSide(
                      color: Colors.grey,
                      width: 1.0
                  )
              )
          ),
          padding: EdgeInsets.only(top: size.height * 0.01, bottom: size.height * 0.01),
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
                        if(titleController.text.isNotEmpty && dateController.text.isNotEmpty && descriptionController.text.isNotEmpty) {
                          if(isMobile == true && isEmail == true) {
                            AnimatedSnackBar.show(
                                context,
                                'Please enter the valid mobile number and email address',
                                Colors.red
                            );
                          } else if(isMobile == true && isEmail == false) {
                            AnimatedSnackBar.show(
                                context,
                                'Please enter the valid mobile number',
                                Colors.red
                            );
                          } else if(isMobile == false && isEmail == true) {
                            AnimatedSnackBar.show(
                                context,
                                'Please enter the valid email number',
                                Colors.red
                            );
                          } else {
                            if(load) {
                              showDialog(
                                context: context,
                                barrierDismissible: false,
                                builder: (BuildContext context) {
                                  return const CustomLoadingDialog();
                                },
                              );
                              save(titleController.text.toString(), dateController.text.toString(), descriptionController.text.toString());
                            }
                          }
                        } else {
                          setState(() {
                            if (titleController.text.isEmpty) isTitle = true;
                            if (dateController.text.isEmpty) isDate = true;
                            if (descriptionController.text.isEmpty) isDescription = true;
                            AnimatedSnackBar.show(
                                context,
                                'Please fill the required fields',
                                Colors.red
                            );
                          });
                        }
                      },
                      child: Text('Save', style: TextStyle(color: Colors.white, fontSize: size.height * 0.02),)
                  )
              ),
            ],
          ),
        ),
      ),
    );
  }
}
