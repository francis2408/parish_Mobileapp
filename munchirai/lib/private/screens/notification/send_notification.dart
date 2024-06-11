import 'dart:convert';

import 'package:dropdown_textfield/dropdown_textfield.dart';
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

class SendNotification extends StatefulWidget {
  const SendNotification({Key? key}) : super(key: key);

  @override
  State<SendNotification> createState() => _SendNotificationState();
}

class _SendNotificationState extends State<SendNotification> {
  final formKey = GlobalKey<FormState>();
  var titleController = TextEditingController();
  var dateController = TextEditingController();
  var descriptionController = TextEditingController();
  String date = '';

  bool _isLoading = false;
  bool isTitle = false;
  bool isType = false;
  bool isUsers = false;
  bool isDate = false;

  final SingleValueDropDownController _type = SingleValueDropDownController();
  final MultiValueDropDownController _users = MultiValueDropDownController();
  List typeData = [
    {'id': '1', 'name': 'Common'},
    {'id': '2', 'name': 'Users'},
    // {'id': '3', 'name': 'Events'},
    // {'id': '4', 'name': 'Announcements'},
    // {'id': '5', 'name': 'Push Notification'},
    // {'id': '6', 'name': 'Parish News'}
  ];
  List<DropDownValueModel> typeDropDown = [];
  String typeID = '';
  String type = 'Common';
  List<DropDownValueModel> usersDropDown = [];
  List userIds = [];
  List userNames  = [];

  final format = DateFormat("dd-MM-yyyy");
  final reverse = DateFormat("yyyy-MM-dd");

  createNotification(String name, type) async {
    String description = descriptionController.text.toString();
    if(name != null && name != "" && type != null && type != "") {
      String url = '$baseUrl/create/push.notification';
      Map data = {
        "params": {
          "data":{"name": "$name","send_by": "$type","description": "$description"}
        }
      };
      var body = jsonEncode(data);
      var response = await http.post(Uri.parse(url),
          headers: {
            'Authorization': authToken,
            'Content-Type': 'application/json',
            'Accept': 'application/json'
          },
          body: body);
      if(response.statusCode == 200) {
        final datas = json.decode(response.body)['result'];
        if(datas['state'] == 'success') {
          setState(() {
            sendNotification(datas['data']);
          });
        }
      } else {
        final data = json.decode(response.body)['result'];
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
        isTitle = true;
        isType = true;
        type.isNotEmpty && type == 'Users' && userIds.isNotEmpty ? isUsers = false : isUsers = true;
      });
      AnimatedSnackBar.show(
          context,
          'Please fill the required fields',
          Colors.red
      );
    }
  }

  sendNotification(int value) async {
    String url = '$baseUrl/push.notification/$value/send_notification';
    Map data = {};
    var body = jsonEncode(data);
    var response = await http.post(Uri.parse(url),
        headers: {
          'Authorization': authToken,
          'Content-Type': 'application/json',
          'Accept': 'application/json'
        },
        body: body);
    if(response.statusCode == 200) {
      final data = json.decode(response.body)['result'];
      if(data['state'] == 'success') {
        setState(() {
          AnimatedSnackBar.show(
              context,
              "$type Notification send successfully",
              Colors.green
          );
          Navigator.pop(context);
          Navigator.pop(context, 'refresh');
        });
      }
    } else {
      final data = json.decode(response.body)['result'];
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

  getTypeValue() {
    for(int i = 0; i < typeData.length; i++) {
      typeDropDown.add(DropDownValueModel(name: typeData[i]['name'], value: typeData[i]['id']));
    }
    return typeDropDown;
  }

  @override
  void initState() {
    // Check the internet connection
    internetCheck();
    // TODO: implement initState
    super.initState();
    getTypeValue();
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
            'Send Push Notification',
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
                                  'Title',
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
                                hintText: "Enter your title",
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
                          // SizedBox(
                          //   height: size.height * 0.01,
                          // ),
                          // Container(
                          //   padding: const EdgeInsets.only(top: 5, bottom: 10),
                          //   alignment: Alignment.topLeft,
                          //   child: Row(
                          //     children: [
                          //       Text(
                          //         'Date',
                          //         style: GoogleFonts.poppins(
                          //           fontSize: size.height * 0.018,
                          //           fontWeight: FontWeight.bold,
                          //           color: Colors.black54,
                          //         ),
                          //       ),
                          //       SizedBox(width: size.width * 0.02,),
                          //       Text('*', style: GoogleFonts.poppins(fontSize: size.height * 0.02, fontWeight: FontWeight.bold, color: Colors.red,),)
                          //     ],
                          //   ),
                          // ),
                          // Container(
                          //   decoration: BoxDecoration(
                          //       borderRadius: BorderRadius.circular(10),
                          //       color: inputColors
                          //   ),
                          //   child: TextFormField(
                          //     controller: dateController,
                          //     keyboardType: TextInputType.datetime,
                          //     autocorrect: true,
                          //     autovalidateMode: AutovalidateMode.onUserInteraction,
                          //     style: GoogleFonts.breeSerif(
                          //         color: Colors.black,
                          //         letterSpacing: 0.2
                          //     ),
                          //     decoration: InputDecoration(
                          //       suffixIcon: const Icon(
                          //         Icons.calendar_month,
                          //         color: Colors.indigo,
                          //       ),
                          //       hintText: "Choose the date",
                          //       border: OutlineInputBorder(
                          //           borderRadius: BorderRadius.circular(10)
                          //       ),
                          //       hintStyle: GoogleFonts.breeSerif(
                          //         color: labelColor2,
                          //         fontStyle: FontStyle.italic,
                          //       ),
                          //       enabledBorder: OutlineInputBorder(
                          //         borderRadius: BorderRadius.circular(10),
                          //         borderSide: const BorderSide(
                          //           color: disableColor,
                          //           width: 1.0,
                          //         ),
                          //       ),
                          //       focusedBorder: OutlineInputBorder(
                          //         borderRadius: BorderRadius.circular(10),
                          //         borderSide: const BorderSide(
                          //           color: enableColor,
                          //           width: 1.0,
                          //         ),
                          //       ),
                          //     ),
                          //     // check the validation
                          //     validator: (val) {
                          //       if (val!.isEmpty && val == '') {
                          //         isDate = true;
                          //       } else {
                          //         isDate = false;
                          //       }
                          //     },
                          //     onChanged: (val) {
                          //       if(val.isEmpty) {
                          //         setState(() {
                          //           dateController.text = '';
                          //           date = '';
                          //           isDate = true;
                          //         });
                          //       }
                          //     },
                          //     onTap: () async {
                          //       DateTime? datePick = await showDatePicker(
                          //         context: context,
                          //         initialDate: dateController.text.isNotEmpty ? format.parse(dateController.text) :DateTime.now(),
                          //         firstDate: DateTime(1900),
                          //         lastDate: DateTime.now().add(const Duration(days: 365 * 1)),
                          //         builder: (context, child) {
                          //           return Theme(
                          //             data: Theme.of(context).copyWith(
                          //               colorScheme: const ColorScheme.light(
                          //                 primary: primaryColor,
                          //                 onPrimary: Colors.white,
                          //                 onSurface: Colors.black,
                          //               ),
                          //               textButtonTheme: TextButtonThemeData(
                          //                 style: TextButton.styleFrom(
                          //                   foregroundColor: backgroundColor,
                          //                 ),
                          //               ),
                          //             ),
                          //             child: child!,
                          //           );
                          //         },
                          //       );
                          //       if (datePick != null) {
                          //         setState(() {
                          //           var dateNow = DateTime.now();
                          //           var diff = dateNow.difference(datePick);
                          //           var year = ((diff.inDays)/365).round();
                          //           dateController.text = format.format(datePick);
                          //           date = reverse.format(datePick);
                          //         });
                          //       }
                          //     },
                          //   ),
                          // ),
                          // isDate ? Container(
                          //     alignment: Alignment.topLeft,
                          //     padding: const EdgeInsets.only(left: 10, top: 8),
                          //     child: const Text(
                          //       "Date is required",
                          //       style: TextStyle(
                          //           color: Colors.red,
                          //           fontWeight: FontWeight.w500
                          //       ),
                          //     )
                          // ) : Container(),
                          // SizedBox(
                          //   height: size.height * 0.01,
                          // ),
                          // Container(
                          //   padding: const EdgeInsets.only(top: 5, bottom: 10),
                          //   alignment: Alignment.topLeft,
                          //   child: Row(
                          //     children: [
                          //       Text(
                          //         'Type',
                          //         style: GoogleFonts.poppins(
                          //           fontSize: size.height * 0.018,
                          //           fontWeight: FontWeight.bold,
                          //           color: Colors.black54,
                          //         ),
                          //       ),
                          //       SizedBox(width: size.width * 0.02,),
                          //       Text('*', style: GoogleFonts.poppins(fontSize: size.height * 0.02, fontWeight: FontWeight.bold, color: Colors.red,),)
                          //     ],
                          //   ),
                          // ),
                          // Container(
                          //   decoration: BoxDecoration(
                          //       borderRadius: BorderRadius.circular(10),
                          //       color: inputColors
                          //   ),
                          //   child: DropDownTextField(
                          //     initialValue: type,
                          //     listSpace: 20,
                          //     listPadding: ListPadding(top: 20),
                          //     searchShowCursor: true,
                          //     searchAutofocus: true,
                          //     enableSearch: true,
                          //     listTextStyle: GoogleFonts.breeSerif(color: Colors.black, fontSize: size.height * 0.02),
                          //     textStyle: GoogleFonts.breeSerif(color: Colors.black, letterSpacing: 0.2),
                          //     dropDownItemCount: 6,
                          //     dropDownList: typeDropDown,
                          //     textFieldDecoration: InputDecoration(
                          //       border: OutlineInputBorder(
                          //         borderRadius: BorderRadius.circular(10),
                          //       ),
                          //       hintText: "Select type",
                          //       hintStyle: GoogleFonts.breeSerif(
                          //         color: labelColor2,
                          //         fontStyle: FontStyle.italic,
                          //       ),
                          //       enabledBorder: OutlineInputBorder(
                          //         borderRadius: BorderRadius.circular(10),
                          //         borderSide: const BorderSide(
                          //           color: disableColor,
                          //           width: 1.0,
                          //         ),
                          //       ),
                          //       focusedBorder: OutlineInputBorder(
                          //         borderRadius: BorderRadius.circular(10),
                          //         borderSide: const BorderSide(
                          //           color: enableColor,
                          //           width: 0.5,
                          //         ),
                          //       ),
                          //     ),
                          //     onChanged: (val) {
                          //       if (val != null && val != "") {
                          //         setState(() {
                          //           isType = false;
                          //           type = val.name;
                          //           typeID = val.value.toString();
                          //         });
                          //       } else {
                          //         setState(() {
                          //           isType = true;
                          //           type = '';
                          //           typeID = '';
                          //         });
                          //       }
                          //     },
                          //     // check the validation
                          //     validator: (val) {
                          //       if (val!.isEmpty && val == "") {
                          //         isType = true;
                          //       } else {
                          //         isType = false;
                          //       }
                          //     },
                          //   ),
                          // ),
                          // isType ? Container(
                          //     alignment: Alignment.topLeft,
                          //     padding: const EdgeInsets.only(left: 10, top: 8),
                          //     child: const Text(
                          //       "Type is required",
                          //       style: TextStyle(
                          //           color: Colors.red,
                          //           fontWeight: FontWeight.w500
                          //       ),
                          //     )
                          // ) : Container(),
                          // if (type == "Users") SizedBox(
                          //   height: size.height * 0.01,
                          // ),
                          // if (type == "Users") Container(
                          //   padding: const EdgeInsets.only(top: 5, bottom: 10),
                          //   alignment: Alignment.topLeft,
                          //   child: Row(
                          //     children: [
                          //       Text(
                          //         'Users',
                          //         style: GoogleFonts.poppins(
                          //           fontSize: size.height * 0.018,
                          //           fontWeight: FontWeight.bold,
                          //           color: Colors.black54,
                          //         ),
                          //       ),
                          //       SizedBox(width: size.width * 0.02,),
                          //       Text('*', style: GoogleFonts.poppins(fontSize: size.height * 0.02, fontWeight: FontWeight.bold, color: Colors.red,),)
                          //     ],
                          //   ),
                          // ),
                          // if (type == "Users") Container(
                          //   decoration: BoxDecoration(
                          //       borderRadius: BorderRadius.circular(10),
                          //       color: inputColors
                          //   ),
                          //   child: DropDownTextField.multiSelection(
                          //     controller: _users,
                          //     displayCompleteItem: true,
                          //     listSpace: 20,
                          //     listPadding: ListPadding(top: 20),
                          //     listTextStyle: GoogleFonts.breeSerif(color: Colors.black, fontSize: size.height * 0.02),
                          //     textStyle: GoogleFonts.breeSerif(color: Colors.black, letterSpacing: 0.2),
                          //     dropDownItemCount: 6,
                          //     dropDownList: usersDropDown,
                          //     textFieldDecoration: InputDecoration(
                          //       border: OutlineInputBorder(
                          //         borderRadius: BorderRadius.circular(10),
                          //       ),
                          //       hintText: "Select Users",
                          //       hintStyle: GoogleFonts.breeSerif(
                          //         color: labelColor2,
                          //         fontStyle: FontStyle.italic,
                          //       ),
                          //       enabledBorder: OutlineInputBorder(
                          //         borderRadius: BorderRadius.circular(10),
                          //         borderSide: const BorderSide(
                          //           color: disableColor,
                          //           width: 1.0,
                          //         ),
                          //       ),
                          //       focusedBorder: OutlineInputBorder(
                          //         borderRadius: BorderRadius.circular(10),
                          //         borderSide: const BorderSide(
                          //           color: enableColor,
                          //           width: 0.5,
                          //         ),
                          //       ),
                          //     ),
                          //     onChanged: (val) {
                          //       if(val.isNotEmpty) {
                          //         List ids = [];
                          //         List names = [];
                          //         String userName = "";
                          //         for(int i = 0; i < val.length; i++) {
                          //           setState(() {
                          //             userName = val[i].name;
                          //             ids.add(val[i].value);
                          //             names.add(userName);
                          //           });
                          //         }
                          //         userIds = ids;
                          //         userNames = names;
                          //         isUsers = false;
                          //       } else {
                          //         isUsers = true;
                          //         userIds.clear();
                          //         userNames.clear();
                          //       }
                          //     },
                          //   ),
                          // ),
                          // if (type == "Users") isUsers ? Container(
                          //     alignment: Alignment.topLeft,
                          //     padding: const EdgeInsets.only(left: 10, top: 8),
                          //     child: const Text(
                          //       "User is required",
                          //       style: TextStyle(
                          //           color: Colors.red,
                          //           fontWeight: FontWeight.w500
                          //       ),
                          //     )
                          // ) : Container(),
                          SizedBox(
                            height: size.height * 0.01,
                          ),
                          Container(
                            padding: const EdgeInsets.only(top: 5, bottom: 10),
                            alignment: Alignment.topLeft,
                            child: Text(
                              'Description',
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
                            ),
                          ),
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
                        if(titleController.text.isNotEmpty && type.isNotEmpty && type != 'Users') {
                          setState(() {
                            _isLoading = true;
                            showDialog(
                              context: context,
                              barrierDismissible: false,
                              builder: (BuildContext context) {
                                return const CustomLoadingDialog();
                              },
                            );
                            createNotification(titleController.text.toString(), type);
                          });
                        } else if(titleController.text.isNotEmpty && type.isNotEmpty && type == 'Users') {
                          setState(() {
                            _isLoading = true;
                            // login(userNameController.text.toString(), passwordController.text.toString(), db);
                          });
                        } else {
                          setState(() {
                            titleController.text.isNotEmpty ? isTitle = false : isTitle = true;
                            type.isNotEmpty ? isType = false : isType = true;
                            type.isNotEmpty && type == 'Users' && userIds.isNotEmpty ? isUsers = false : isUsers = true;
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
