import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:tenkasi/widget/common/common.dart';
import 'package:tenkasi/widget/common/internet_connection_checker.dart';
import 'package:tenkasi/widget/common/snackbar.dart';
import 'package:tenkasi/widget/theme_color/theme_color.dart';
import 'package:tenkasi/widget/widget.dart';

class AddFeedbackForm extends StatefulWidget {
  const AddFeedbackForm({Key? key}) : super(key: key);

  @override
  State<AddFeedbackForm> createState() => _AddFeedbackFormState();
}

class _AddFeedbackFormState extends State<AddFeedbackForm> {
  final formKey = GlobalKey<FormState>();
  var nameController = TextEditingController();
  var mobileController = TextEditingController();
  var emailController = TextEditingController();
  var placeController = TextEditingController();
  var feedbackController = TextEditingController();
  String mobile = '';
  String email = '';

  bool _isLoading = false;
  bool isName = false;
  bool isMobile = false;
  bool isEmail = false;
  bool isFeedback = false;

  send(String name, description) async {
    String place = placeController.text.toString();
    var request = http.Request('POST',  Uri.parse('$baseUrl/public/custom/$parishID/create_feedback'));
    request.body = json.encode({
      "params": {"name": "$name", "mobile": "$mobile", "email": "$email", "place": "$place", "feedback": "$description"}
    });
    request.headers.addAll(sendHeader);
    http.StreamedResponse response = await request.send();
    if(response.statusCode == 200) {
      final message = json.decode(await response.stream.bytesToString())['result']['message'];
      setState(() {
        _isLoading = false;
        AnimatedSnackBar.show(
            context,
            'Feedback send successfully.',
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
            'Feedback',
            style: TextStyle(
              fontSize: size.height * 0.02,
              fontWeight: FontWeight.bold,
              color: whiteColor,
            ),
          ),
          centerTitle: true,
          backgroundColor: appBackgroundColor,
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
                                  'Name',
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
                              controller: nameController,
                              keyboardType: TextInputType.text,
                              autocorrect: true,
                              autovalidateMode: AutovalidateMode.onUserInteraction,
                              style: GoogleFonts.breeSerif(
                                  color: Colors.black,
                                  letterSpacing: 0.2
                              ),
                              decoration: InputDecoration(
                                hintText: "Enter your name",
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
                          SizedBox(
                            height: size.height * 0.01,
                          ),
                          Container(
                            padding: const EdgeInsets.only(top: 5, bottom: 10),
                            alignment: Alignment.topLeft,
                            child: Text(
                              'Mobile',
                              style: GoogleFonts.poppins(
                                fontSize: size.height * 0.018,
                                fontWeight: FontWeight.bold,
                                color: Colors.black54,
                              ),
                            ),
                          ),
                          Container(
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(10),
                                color: inputColors
                            ),
                            child: TextFormField(
                              controller: mobileController,
                              keyboardType: TextInputType.phone,
                              autocorrect: true,
                              autovalidateMode: AutovalidateMode.onUserInteraction,
                              inputFormatters: [
                                LengthLimitingTextInputFormatter(13),
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
                              // check tha validationValidator
                              validator: (val) {
                                if(val!.isNotEmpty) {
                                  var reg = RegExp(r"^(?:[+0]9)?[0-9]{10,15}$");
                                  if(reg.hasMatch(val)) {
                                    isMobile = false;
                                    mobile = mobileController.text.toString();
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
                                "Enter the valid mobile number",
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
                            child: Text(
                              'Email',
                              style: GoogleFonts.poppins(
                                fontSize: size.height * 0.018,
                                fontWeight: FontWeight.bold,
                                color: Colors.black54,
                              ),
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
                              // check tha validationValidator
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
                                "Enter the valid email address",
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
                            child: Text(
                              'Place',
                              style: GoogleFonts.poppins(
                                fontSize: size.height * 0.018,
                                fontWeight: FontWeight.bold,
                                color: Colors.black54,
                              ),
                            ),
                          ),
                          Container(
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(10),
                                color: inputColors
                            ),
                            child: TextFormField(
                              controller: placeController,
                              keyboardType: TextInputType.text,
                              autocorrect: true,
                              autovalidateMode: AutovalidateMode.onUserInteraction,
                              inputFormatters: [
                                LengthLimitingTextInputFormatter(100),
                              ],
                              style: GoogleFonts.breeSerif(
                                  color: Colors.black,
                                  letterSpacing: 0.2
                              ),
                              decoration: InputDecoration(
                                hintText: "Enter your place",
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
                            ),
                          ),
                          SizedBox(
                            height: size.height * 0.01,
                          ),
                          Container(
                            padding: const EdgeInsets.only(top: 5, bottom: 10),
                            alignment: Alignment.topLeft,
                            child: Row(
                              children: [
                                Text(
                                  'Feedback',
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
                              controller: feedbackController,
                              keyboardType: TextInputType.text,
                              autocorrect: true,
                              autovalidateMode: AutovalidateMode.onUserInteraction,
                              inputFormatters: [
                                LengthLimitingTextInputFormatter(5000),
                              ],
                              maxLines: 15,
                              style: GoogleFonts.breeSerif(
                                  color: Colors.black,
                                  letterSpacing: 0.2
                              ),
                              decoration: InputDecoration(
                                hintText: "Enter your feedback",
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
                                  isFeedback = true;
                                } else {
                                  isFeedback = false;
                                }
                              },
                            ),
                          ),
                          isFeedback ? Container(
                              alignment: Alignment.topLeft,
                              padding: const EdgeInsets.only(left: 10, top: 8),
                              child: const Text(
                                "Feedback is required",
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
                        if(nameController.text.isNotEmpty && feedbackController.text.isNotEmpty) {
                          if(isMobile != true && isEmail != true) {
                            setState(() {
                              _isLoading = true;
                              showDialog(
                                context: context,
                                barrierDismissible: false,
                                builder: (BuildContext context) {
                                  return const CustomLoadingDialog();
                                },
                              );
                              send(nameController.text.toString(), feedbackController.text.toString());
                            });
                          } else {
                            if (isMobile == true && isEmail == true) {
                              setState(() {
                                AnimatedSnackBar.show(
                                    context,
                                    'Please enter the valid mobile number and email address',
                                    Colors.red
                                );
                              });
                            } else {
                              setState(() {
                                isMobile == true ? AnimatedSnackBar.show(
                                    context,
                                    'Please enter the valid mobile number',
                                    Colors.red
                                ) : isMobile == true ? AnimatedSnackBar.show(
                                    context,
                                    'Please enter the valid email address',
                                    Colors.red
                                ) : null;
                              });
                            }
                          }
                        } else {
                          setState(() {
                            nameController.text.isNotEmpty ? isName = false : isName = true;
                            feedbackController.text.isNotEmpty ? isFeedback = false : isFeedback = true;
                            AnimatedSnackBar.show(
                                context,
                                'Please fill the required fields',
                                Colors.red
                            );
                          });
                        }
                      },
                      child: Text('Send', style: TextStyle(color: Colors.white, fontSize: size.height * 0.02),)
                  )
              ),
            ],
          ),
        ),
      ),
    );
  }
}
