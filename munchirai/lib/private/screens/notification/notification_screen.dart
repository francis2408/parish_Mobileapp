import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:loading_indicator/loading_indicator.dart';
import 'package:munchirai/widget/common/common.dart';
import 'package:munchirai/widget/common/internet_connection_checker.dart';
import 'package:munchirai/widget/common/slide_animations.dart';
import 'package:munchirai/widget/theme_color/theme_color.dart';
import 'package:munchirai/widget/widget.dart';

class NotificationScreen extends StatefulWidget {
  const NotificationScreen({Key? key}) : super(key: key);

  @override
  State<NotificationScreen> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> {
  bool _isLoading  = true;
  List notificationData = [];
  int selected = -1;

  RegExp exp = RegExp(r"<[^>]*>",multiLine: true,caseSensitive: true);
  final format = DateFormat("dd-MM-yyyy");

  getNotificationData() async {
    var request = http.Request('GET', Uri.parse('$baseUrl/public/$parishID/common_notification'));
    request.body = json.encode({});
    request.headers.addAll(headers);
    http.StreamedResponse response = await request.send();
    if (response.statusCode == 200) {
      var decode = json.decode(await response.stream.bytesToString())['result'];
      if(decode['status'] == 'success') {
        List data = decode['result'];
        setState(() {
          _isLoading = false;
        });
        notificationData = data;
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
    getNotificationData();
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
            'Notifications',
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
          // backgroundColor: appBackgroundColor,
        ),
        body: SafeArea(
          child: Center(
            child: _isLoading ? Center(
              child: SizedBox(
                height: size.height * 0.06,
                child: const LoadingIndicator(
                  indicatorType: Indicator.ballSpinFadeLoader,
                  colors: [Colors.red,Colors.orange,Colors.yellow,Colors.green,Colors.blue,Colors.indigo,Colors.purple,],
                ),
              ),
            ) : Container(
              padding: const EdgeInsets.only(left: 10, right: 10),
              child: notificationData.isNotEmpty ? Column(
                children: [
                  SizedBox(
                    height: size.height * 0.01,
                  ),
                  Expanded(
                    child: SlideFadeAnimation(
                      duration: const Duration(seconds: 1),
                      child: SingleChildScrollView(
                        child: ListView.builder(
                            key: Key('builder ${selected.toString()}'),
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: notificationData.length,
                            itemBuilder: (BuildContext context, int index) {
                              bool isSameDate = true;
                              final String dateString = notificationData[index]['date'];
                              final DateTime date = DateFormat('dd-MM-yyyy').parse(dateString);

                              if (index == 0) {
                                isSameDate = false;
                              } else {
                                final String prevDateString = notificationData[index - 1]['date'];
                                final DateTime prevDate = DateFormat('dd-MM-yyyy').parse(prevDateString);
                                isSameDate = date.isSameDate(prevDate);
                              }
                              if (!(isSameDate)) {
                                return Column(
                                  children: [
                                    Container(
                                      alignment: Alignment.topRight,
                                      padding: const EdgeInsets.only(right: 10),
                                      child: Text(
                                        date.formatDate(),
                                        style: GoogleFonts.roboto(
                                            color: hiLightColor,
                                            fontWeight: FontWeight.bold,
                                            fontSize: size.height * 0.018
                                        ),
                                      ),
                                    ),
                                    SizedBox(height: size.height * 0.005,),
                                    Stack(
                                      children: [
                                        Container(
                                          decoration: BoxDecoration(
                                            borderRadius: BorderRadius.circular(15.0),
                                          ),
                                          child: Card(
                                            shape: RoundedRectangleBorder(
                                              borderRadius: BorderRadius.circular(15.0),
                                            ),
                                            child: ListTile(
                                              leading: const CircleAvatar(
                                                backgroundColor: iconBackColor,
                                                child: Icon(Icons.notifications, color: Colors.white,),
                                              ),
                                              title: Text(notificationData[index]['name'], style: GoogleFonts.roboto(fontWeight: FontWeight.bold, fontSize: size.height * 0.02, color: labelColor),),
                                              subtitle: Text(notificationData[index]['description'],maxLines: 1, overflow: TextOverflow.ellipsis,),
                                              trailing: Text(DateFormat.jm().format(DateFormat("dd-MM-yyyy hh:mm a").parse(notificationData[index]['date'])), style: TextStyle(fontWeight: FontWeight.bold, fontSize: size.height * 0.016, color: blackColor),),
                                              onTap: () {
                                                showModalBottomSheet<void>(
                                                  context: context,
                                                  backgroundColor: screenBackgroundColor,
                                                  transitionAnimationController: AnimationController(
                                                    vsync: Navigator.of(context),
                                                    duration: const Duration(seconds: 1),
                                                  ),
                                                  shape: const RoundedRectangleBorder(
                                                    borderRadius: BorderRadius.vertical(top: Radius.circular(20.0)),
                                                  ),
                                                  builder: (BuildContext context) {
                                                    return CustomContentBottomSheet(
                                                        size: size,
                                                        title: "Description",
                                                        content: notificationData[index]['description']
                                                    );
                                                  },
                                                );
                                              },
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    SizedBox(height: size.height * 0.005,),
                                  ],
                                );
                              } else {
                                return Column(
                                  children: [
                                    SizedBox(height: size.height * 0.005,),
                                    Stack(
                                      children: [
                                        Container(
                                          decoration: BoxDecoration(
                                            borderRadius: BorderRadius.circular(15.0),
                                          ),
                                          child: Card(
                                            shape: RoundedRectangleBorder(
                                              borderRadius: BorderRadius.circular(15.0),
                                            ),
                                            child: ListTile(
                                              leading: const CircleAvatar(
                                                backgroundColor: iconBackColor,
                                                child: Icon(Icons.notifications, color: Colors.white,),
                                              ),
                                              title: Text(notificationData[index]['name'], style: GoogleFonts.roboto(fontWeight: FontWeight.bold, fontSize: size.height * 0.02, color: labelColor),),
                                              subtitle: Text(notificationData[index]['description'],maxLines: 1, overflow: TextOverflow.ellipsis,),
                                              trailing: Text(DateFormat.jm().format(DateFormat("dd-MM-yyyy hh:mm a").parse(notificationData[index]['date'])), style: TextStyle(fontWeight: FontWeight.bold, fontSize: size.height * 0.016, color: blackColor),),
                                              onTap: () {
                                                showModalBottomSheet<void>(
                                                  context: context,
                                                  backgroundColor: screenBackgroundColor,
                                                  transitionAnimationController: AnimationController(
                                                    vsync: Navigator.of(context),
                                                    duration: const Duration(seconds: 1),
                                                  ),
                                                  shape: const RoundedRectangleBorder(
                                                    borderRadius: BorderRadius.vertical(top: Radius.circular(20.0)),
                                                  ),
                                                  builder: (BuildContext context) {
                                                    return CustomContentBottomSheet(
                                                        size: size,
                                                        title: "Description",
                                                        content: notificationData[index]['description']
                                                    );
                                                  },
                                                );
                                              },
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    SizedBox(height: size.height * 0.005,),
                                  ],
                                );
                              }
                            }
                        ),
                      ),
                    ),
                  ),
                ],
              ) : Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.only(left: 30, right: 30),
                    child: NoResult(
                      onPressed: () {
                        setState(() {
                          Navigator.pop(context);
                        });
                      },
                      text: 'No Data available',
                    ),
                  )
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

const String dateFormatter = 'MMMM dd, y';

extension DateHelper on DateTime {

  String formatDate() {
    final formatter = DateFormat(dateFormatter);
    return formatter.format(this);
  }
  bool isSameDate(DateTime other) {
    return year == other.year &&
        month == other.month &&
        day == other.day;
  }

  int getDifferenceInDaysWithNow() {
    final now = DateTime.now();
    return now.difference(this).inDays;
  }
}