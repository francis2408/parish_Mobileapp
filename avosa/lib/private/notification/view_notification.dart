import 'dart:convert';
import 'dart:io';

import 'package:avosa/widget/common/internet_connection_checker.dart';
import 'package:avosa/widget/theme_color/theme_color.dart';
import 'package:avosa/widget/widget.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:loading_indicator/loading_indicator.dart';
import 'package:url_launcher/url_launcher.dart';

class NotificationViewScreen extends StatefulWidget {
  final String title;
  final String date;
  final String description;
  const NotificationViewScreen({Key? key, required this.title, required this.date, required this.description}) : super(key: key);

  @override
  State<NotificationViewScreen> createState() => _NotificationViewScreenState();
}

class _NotificationViewScreenState extends State<NotificationViewScreen> {
  final bool _canPop = false;
  bool _isLoading  = true;
  List data = [];
  List notificationData = [];
  int selected = -1;
  int index = 0;

  void _webLaunchURL(String url) async {
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
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
    // Check Internet connection
    internetCheck();
    // TODO: implement initState
    super.initState();
    Future.delayed(const Duration(milliseconds: 200), () {
      setState(() {
        _isLoading = false;
      });
    });
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
        body: SafeArea(
          child: _isLoading ? Center(
            child: SizedBox(
              height: size.height * 0.06,
              child: const LoadingIndicator(
                indicatorType: Indicator.ballSpinFadeLoader,
                colors: [Colors.red,Colors.orange,Colors.yellow,Colors.green,Colors.blue,Colors.indigo,Colors.purple,],
              ),
            ),
          ) : CustomScrollView(
            slivers: [
              SliverAppBar(
                backgroundColor: primaryColor,
                shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(30.0),
                    bottomRight: Radius.circular(30.0),
                  ),
                ),
                automaticallyImplyLeading: false,
                expandedHeight: size.height * 0.3,
                pinned: true,
                floating: true,
                leading: IconButton(
                  onPressed: () {
                    Navigator.pop(context, 'refresh');
                  },
                  icon: Icon(Platform.isIOS ? Icons.arrow_back_ios : Icons.arrow_back, color: Colors.white,size: size.height * 0.03,),
                ),
                flexibleSpace: FlexibleSpaceBar(
                  titlePadding: EdgeInsetsDirectional.only(start: size.width * 0.1, end: size.width * 0.1, bottom: 5.0),
                  centerTitle: true,
                  title: Container(
                    padding: const EdgeInsets.all(5),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      color: primaryColor,
                    ),
                    child: Text(
                        'Notification',
                        textScaleFactor: 1.0,
                        style: GoogleFonts.kavoon(
                            letterSpacing: 1,
                            color: Colors.white,
                            fontSize: size.height * 0.02
                        )
                    ),
                  ),
                  expandedTitleScale: 1,
                  background: ClipRRect(
                    borderRadius: const BorderRadius.only(
                      bottomLeft: Radius.circular(30.0),
                      bottomRight: Radius.circular(30.0),
                    ),
                    child: Image.asset(
                        'assets/images/notification.jpg',
                        fit: BoxFit.fill
                    ),
                  ),
                ),
              ),
              SliverFillRemaining(
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      SizedBox(height: size.height * 0.02,),
                      Container(
                        alignment: Alignment.topRight,
                        padding: const EdgeInsets.only(right: 10),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            const Icon(Icons.access_time_rounded, color: Colors.indigo,),
                            const SizedBox(width: 3,),
                            Text(widget.date, style: TextStyle(fontWeight: FontWeight.bold, fontSize: size.height * 0.016, color: Colors.indigo, fontStyle: FontStyle.italic),),
                          ],
                        ),
                      ),
                      SizedBox(height: size.height * 0.01,),
                      Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(15.0),
                        ),
                        child: Card(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15.0),
                          ),
                          child: ListTile(
                            title: Container(padding: const EdgeInsets.only(top: 5, bottom: 5),child: Text(widget.title, style: GoogleFonts.roboto(fontWeight: FontWeight.bold, fontSize: size.height * 0.02, color: Colors.black87),)),
                            subtitle: Column(
                              children: [
                                const SizedBox(height: 3,),
                                Row(
                                  children: [
                                    Flexible(child: buildRichTextWithLink(widget.description)),
                                  ],
                                ),
                                const SizedBox(height: 5,),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget buildRichTextWithLink(String apiResponse) {
    Size size = MediaQuery.of(context).size;
    String description = apiResponse;
    // Regular expression to find website links in the description
    RegExp urlRegex = RegExp(r'https?://(?:www\.)?[^\s]+');

    List<InlineSpan> textSpans = [];
    int startIndex = 0;
    for (RegExpMatch match in urlRegex.allMatches(description)) {
      // Add the non-link text
      textSpans.add(TextSpan(text: description.substring(startIndex, match.start)));
      // Add the link text
      String? url = match.group(0);
      textSpans.add(
        TextSpan(
          text: url,
          style: const TextStyle(
            color: Colors.blue,
            decoration: TextDecoration.underline,
          ),
          recognizer: TapGestureRecognizer()
            ..onTap = () {
              _webLaunchURL(url!);
            },
        ),
      );
      startIndex = match.end;
    }
    // Add the remaining non-link text
    textSpans.add(TextSpan(text: description.substring(startIndex)));
    return RichText(
      text: TextSpan(children: textSpans, style: TextStyle(fontSize: size.height * 0.018, color: Colors.grey),),
    );
  }
}
