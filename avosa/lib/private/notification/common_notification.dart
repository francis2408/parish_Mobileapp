import 'dart:convert';

import 'package:avosa/widget/common/common.dart';
import 'package:avosa/widget/common/internet_connection_checker.dart';
import 'package:avosa/widget/common/slide_animations.dart';
import 'package:avosa/widget/theme_color/theme_color.dart';
import 'package:avosa/widget/widget.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:loading_indicator/loading_indicator.dart';

class CommonNotificationScreen extends StatefulWidget {
  const CommonNotificationScreen({Key? key}) : super(key: key);

  @override
  State<CommonNotificationScreen> createState() => _CommonNotificationScreenState();
}

class _CommonNotificationScreenState extends State<CommonNotificationScreen> {
  bool _isLoading = true;
  List notification = [];

  getNotificationData() async {
    var request = http.Request('GET', Uri.parse('$baseUrl/public/common_notification'));
    request.body = json.encode({
      "params": {
        "parish_id": int.parse(parishID),
      }
    });
    request.headers.addAll(headers);
    http.StreamedResponse response = await request.send();
    if (response.statusCode == 200) {
      var decode = json.decode(await response.stream.bytesToString())['result'];
      if(decode['success'] == true) {
        var data = decode['data'];
        setState(() {
          _isLoading = false;
        });
        notification = data;
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
    // TODO: implement initState
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
          backgroundColor: primaryColor,
          title: Text('Notification', style: TextStyle(letterSpacing: 0.5, height: 1.3, fontSize: size.height * 0.02), textAlign: TextAlign.center, maxLines: 2,),
          centerTitle: true,
        ),
        body: SafeArea(
            child: _isLoading ? Center(
              child: SizedBox(
                height: size.height * 0.06,
                child: const LoadingIndicator(
                  indicatorType: Indicator.ballSpinFadeLoader,
                  colors: [Colors.red,Colors.orange,Colors.yellow,Colors.green,Colors.blue,Colors.indigo,Colors.purple,],
                ),
              ),
            ) : notification.isNotEmpty ? Container(
              padding: const EdgeInsets.only(left: 10, right: 10),
              child: Column(
                children: [
                  SizedBox(
                    height: size.height * 0.01,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      const Text('Total Count :', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.black),),
                      const SizedBox(width: 3,),
                      Text('${notification.length}', style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.black),)
                    ],
                  ),
                  SizedBox(
                    height: size.height * 0.01,
                  ),
                  Expanded(
                    child: SlideFadeAnimation(
                      duration: const Duration(seconds: 1),
                      child: SingleChildScrollView(
                        child: ListView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: notification.length,
                          itemBuilder: (BuildContext context, int index) {
                            // final notifications = notification[index];
                            bool isSameDate = true;
                            final String dateString = notification[index]['date'];
                            final DateTime date = DateFormat('yyyy-MM-dd').parse(dateString);
                            if (index == 0) {
                              isSameDate = false;
                            } else {
                              final String prevDateString = notification[index - 1]['date'];
                              final DateTime prevDate = DateFormat('yyyy-MM-dd').parse(prevDateString);
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
                                  CustomNotificationCard(
                                    name: notification[index]['name'],
                                    description: notification[index]['description'],
                                    time: notification[index]['date'],
                                    onPressed: () {
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
                                            title: notification[index]['name'],
                                            content: _highlightHttpLink(notification[index]['description']),
                                          );
                                        },
                                      );
                                    },
                                  ),
                                  SizedBox(height: size.height * 0.005,),
                                ],
                              );
                            } else {
                              return Column(
                                children: [
                                  SizedBox(height: size.height * 0.005,),
                                  CustomNotificationCard(
                                    name: notification[index]['name'],
                                    description: notification[index]['description'],
                                    time: notification[index]['date'],
                                    onPressed: () {
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
                                            title: notification[index]['name'],
                                            content: _highlightHttpLink(notification[index]['description']),
                                          );
                                        },
                                      );
                                    },
                                  ),
                                  SizedBox(height: size.height * 0.005,),
                                ],
                              );
                            }
                          },
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ) : Center(
              child: Container(
                alignment: Alignment.center,
                padding: const EdgeInsets.only(left: 30, right: 30),
                child: NoResult(
                  onPressed: () {
                    setState(() {
                      Navigator.pop(context, 'refresh');
                    });
                  },
                  text: 'No Data available',
                ),
              ),
            )
        ),
      ),
    );
  }
}

class CustomNotificationCard extends StatelessWidget {
  final String name;
  final String description;
  final String time;
  final VoidCallback onPressed;

  const CustomNotificationCard({
    Key? key,
    required this.name,
    required this.description,
    required this.time,
    required this.onPressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(15.0),
        ),
        child: Card(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15.0),
          ),
          child: ListTile(
            leading: const CircleAvatar(
              backgroundColor: secondaryColor,
              child: Icon(Icons.notifications, color: blackColor,),
            ),
            title: Text(
              name,
              style: GoogleFonts.roboto(
                fontWeight: FontWeight.bold,
                fontSize: size.height * 0.02,
                color: Colors.black87,
              ),
            ),
            subtitle: Text(
              description,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            trailing: Text(DateFormat("hh:mm a").format(DateFormat("yyyy-MM-dd HH:mm:ss").parse(time)), style: TextStyle(fontWeight: FontWeight.bold, fontSize: size.height * 0.016, color: Colors.black87),),
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

String _highlightHttpLink(String content) {
  // Regular expression to find URLs
  RegExp urlRegex = RegExp(
      r'(https?://\S+)');

  // Replace URLs with anchor tags
  String highlightedContent =
  content.replaceAllMapped(urlRegex, (match) {
    String url = match.group(0)!;
    return '<a href="$url">$url</a>';
  });

  return highlightedContent;
}