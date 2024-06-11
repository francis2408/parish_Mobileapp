import 'dart:convert';

import 'package:avosa/private/notification/view_notification.dart';
import 'package:avosa/widget/common/common.dart';
import 'package:avosa/widget/common/internet_connection_checker.dart';
import 'package:avosa/widget/common/slide_animations.dart';
import 'package:avosa/widget/helper/helper_function.dart';
import 'package:avosa/widget/theme_color/theme_color.dart';
import 'package:avosa/widget/widget.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:loading_indicator/loading_indicator.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Notifications {
  final String id;
  final String title;
  final String body;
  final String timestamp;
  bool read;
  bool isRead;

  Notifications({required this.id, required this.title, required this.body, required this.timestamp, this.isRead = false, this.read = false});
}

class NotificationScreen extends StatefulWidget {
  const NotificationScreen({Key? key}) : super(key: key);

  @override
  State<NotificationScreen> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> {
  bool _isLoading  = true;
  bool isReadAll = false;
  bool isNotRead = false;
  List data = [];
  List notification = [];
  List readIds = [];
  List allReadIds = [];
  late List<Notifications> notificationsData;
  int selected = -1;
  bool isSelectItem = false;

  RegExp exp = RegExp(r"<[^>]*>",multiLine: true,caseSensitive: true);
  final format = DateFormat("dd-MM-yyyy");

  Future<void> _loadNotifications() async {
    final prefs = await SharedPreferences.getInstance();
    final readNotificationIds = prefs.getStringList('read_notification_ids') ?? [];

    // Load the notifications from your API or database
    final newNotifications = await _fetchNotifications();

    // Set the background color of each notification item based on whether it has been read
    notificationsData = newNotifications.map((notificationData) {
      final isRead = readNotificationIds.contains(notificationData.id);
      return Notifications(id: notificationData.id, title: notificationData.title, body: notificationData.body, timestamp: notificationData.timestamp, isRead: notificationData.isRead, read: isRead);
    }).toList();

    setState(() {});
  }

  Future<List<Notifications>> _fetchNotifications() async {
    var request = http.Request('GET', Uri.parse("$baseUrl/user_notification"));
    request.body = json.encode({
      "params": {
        "parish_id": int.parse(parishID),
        "token": authToken
      }
    });
    request.headers.addAll(headers);
    http.StreamedResponse response = await request.send();
    if (response.statusCode == 200) {
      var decode = json.decode(await response.stream.bytesToString())['result'];
      if(decode['success'] == true) {
        data = decode['data'];
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
        }
        for (var item in data) {
          item['date'] = DateTime.parse(item['date']);
        }
        data.sort((a, b) => b['date'].compareTo(a['date']));
        notification = data;
      }
      for(int i = 0; i < notification.length; i++) {
        if(notification[i]['msg_read'] == false) {
          readIds.add(notification[i]['id']);
        } else {
          allReadIds.add(notification[i]['id']);
        }
      }
      if(readIds.isEmpty) {
        setState(() {
          isNotRead = false;
          HelperFunctions.setNotificationReadSF(true);
        });
      } else {
        setState(() {
          isNotRead = true;
          HelperFunctions.setNotificationReadSF(false);
        });
      }
      return notification.map((notification) => Notifications(
        id: notification['id'].toString(),
        title: notification['name'],
        body: notification['description'],
        timestamp: notification['date'].toString(),
        isRead: notification['msg_read'],
      )).toList();
    } else {
      var message = json.decode(await response.stream.bytesToString())['message'];
      setState(() {
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
    return [];
  }

  Future<void> _markNotificationAsRead(String id) async {
    final prefs = await SharedPreferences.getInstance();
    final readNotificationIds = prefs.getStringList('read_notification_ids') ?? [];
    readNotificationIds.add(id);
    prefs.setStringList('read_notification_ids', readNotificationIds);
    if(readNotificationIds.length == notificationsData.length) {
      if(allReadIds.length == notificationsData.length) {
        HelperFunctions.setNotificationReadSF(true);
      } else {
        HelperFunctions.setNotificationReadSF(false);
      }
    } else {
      HelperFunctions.setNotificationReadSF(false);
    }
  }

  readNotification() async {
    var request = http.Request('POST',  Uri.parse('$baseUrl/read_user_notification'));
    request.body = isReadAll ? json.encode({
      "params": {
        "parish_id": int.parse(parishID),
        "token": authToken,
        "notification_ids": readIds
      }
    }) : json.encode({
      "params": {
        "parish_id": int.parse(parishID),
        "token": authToken,
        "notification_ids": [notificationId]
      }
    });
    request.headers.addAll(headers);
    http.StreamedResponse response = await request.send();
    if(response.statusCode == 200) {
      var decode = json.decode(await response.stream.bytesToString())['result'];
      readIds.clear();
      if(isReadAll == true) {
        HelperFunctions.setNotificationReadSF(true);
        isReadAll = false;
        changeData();
      } else {
        if(decode['success'] == true) {
          String refresh = await Navigator.push(context, CustomRoute(widget: NotificationViewScreen(title: notificationName, date: notificationDate, description: notificationMessage)));
          if(refresh == 'refresh') {
            changeData();
          }
        }
      }
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

  void changeData() {
    setState(() {
      _isLoading = true;
      _loadNotifications();
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
    // Check the internet connection
    internetCheck();
    // TODO: implement initState
    super.initState();
    _loadNotifications();
    notificationCount = 0;
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
                  if(isNotRead != false) Align(
                    alignment: Alignment.topRight,
                    child: GestureDetector(
                      onTap: () {
                        isReadAll = true;
                        if(isReadAll == true) {
                          readNotification();
                        } else {
                          isReadAll  = false;
                        }
                      },
                      child: Container(
                          height: size.height * 0.03,
                          width: size.width * 0.23,
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(5),
                            color: Colors.teal,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.teal.shade800,
                                blurRadius: 8,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Text(
                            'Read All',
                            style: TextStyle(
                                fontSize: size.height * 0.018,
                                color: Colors.white
                            ),
                          )
                      ),
                    ),
                  ),
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
                            itemCount: notificationsData.length,
                            itemBuilder: (BuildContext context, int index) {
                              final notification = notificationsData[index];
                              bool isSameDate = true;
                              final String dateString = notificationsData[index].timestamp;
                              final DateTime date = DateFormat('yyyy-MM-dd').parse(dateString);

                              if (index == 0) {
                                isSameDate = false;
                              } else {
                                final String prevDateString = notificationsData[index - 1].timestamp;
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
                                                backgroundColor: secondaryColor,
                                                child: Icon(Icons.notifications, color: blackColor,),
                                              ),
                                              title: Text(notificationsData[index].title, style: GoogleFonts.roboto(fontWeight: FontWeight.bold, fontSize: size.height * 0.02, color: labelColor),),
                                              subtitle: Text(notificationsData[index].body,maxLines: 1, overflow: TextOverflow.ellipsis,),
                                              trailing: Text(DateFormat("hh:mm a").format(DateFormat("yyyy-MM-dd HH:mm:ss").parse(notificationsData[index].timestamp)), style: TextStyle(fontWeight: FontWeight.bold, fontSize: size.height * 0.016, color: Colors.black87),),
                                              onLongPress: () {},
                                              onTap: () async {
                                                if (!notification.read) {
                                                  await _markNotificationAsRead(notification.id);
                                                  notification.read = true;
                                                }
                                                notificationId = int.tryParse(notificationsData[index].id);
                                                notificationName = notificationsData[index].title;
                                                notificationDate = notificationsData[index].timestamp;
                                                notificationMessage = notificationsData[index].body;
                                                readNotification();
                                              },
                                            ),
                                          ),
                                        ),
                                        notificationsData[index].isRead == true ? Container() : Positioned(
                                          top: 35,
                                          left: 0,
                                          child: Container(
                                            padding: const EdgeInsets.all(2),
                                            decoration: BoxDecoration(
                                                borderRadius: BorderRadius.circular(10),
                                                gradient: const LinearGradient(
                                                    colors: [
                                                      primaryColor,
                                                      primaryColor,
                                                    ],
                                                    begin: Alignment.topLeft,
                                                    end: Alignment.bottomRight
                                                )
                                            ),
                                            constraints: const BoxConstraints(
                                              minWidth: 13,
                                              minHeight: 13,
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
                                                backgroundColor: secondaryColor,
                                                child: Icon(Icons.notifications, color: blackColor,),
                                              ),
                                              title: Text(notificationsData[index].title, style: GoogleFonts.roboto(fontWeight: FontWeight.bold, fontSize: size.height * 0.02, color: labelColor),),
                                              subtitle: Text(notificationsData[index].body,maxLines: 1, overflow: TextOverflow.ellipsis,),
                                              trailing: Text(DateFormat("hh:mm a").format(DateFormat("yyyy-MM-dd HH:mm:ss").parse(notificationsData[index].timestamp)), style: TextStyle(fontWeight: FontWeight.bold, fontSize: size.height * 0.016, color: Colors.black87),),
                                              onTap: () async {
                                                if (!notification.read) {
                                                  await _markNotificationAsRead(notification.id);
                                                  notification.read = true;
                                                }
                                                notificationId = int.tryParse(notificationsData[index].id);
                                                notificationName = notificationsData[index].title;
                                                notificationDate = notificationsData[index].timestamp;
                                                notificationMessage = notificationsData[index].body;
                                                readNotification();
                                              },
                                            ),
                                          ),
                                        ),
                                        notificationsData[index].isRead == true ? Container() : Positioned(
                                          top: 35,
                                          left: 0,
                                          child: Container(
                                            padding: const EdgeInsets.all(2),
                                            decoration: BoxDecoration(
                                                borderRadius: BorderRadius.circular(10),
                                                gradient: const LinearGradient(
                                                    colors: [
                                                      primaryColor,
                                                      primaryColor
                                                    ],
                                                    begin: Alignment.topLeft,
                                                    end: Alignment.bottomRight
                                                )
                                            ),
                                            constraints: const BoxConstraints(
                                              minWidth: 13,
                                              minHeight: 13,
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