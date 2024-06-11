import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:loading_indicator/loading_indicator.dart';
import 'package:tenkasi/widget/common/common.dart';
import 'package:tenkasi/widget/common/internet_connection_checker.dart';
import 'package:tenkasi/widget/common/slide_animations.dart';
import 'package:tenkasi/widget/theme_color/theme_color.dart';
import 'package:tenkasi/widget/widget.dart';

class FeedbackListScreen extends StatefulWidget {
  const FeedbackListScreen({Key? key}) : super(key: key);

  @override
  State<FeedbackListScreen> createState() => _FeedbackListScreenState();
}

class _FeedbackListScreenState extends State<FeedbackListScreen> {
  bool _isLoading = true;
  List feedbackData = [];
  int selected = -1;
  String days = '';

  DateTime currentDate = DateTime.now();

  getFeedbackData() async {
    var request = http.Request('GET', Uri.parse('$baseUrl/res.feedback'));
    request.body = json.encode({
      "params":{
        "filter": "[['parish_id','=',$parishID]]",
        "order": "date desc",
        "query": "{name,date,mobile,email,place,feedback}"
      }
    });
    request.headers.addAll(header);
    http.StreamedResponse response = await request.send();
    if (response.statusCode == 200) {
      var decode = json.decode(await response.stream.bytesToString())['result']['data'];
      if(decode['status'] == 'success') {
        List data = decode['result'];
        setState(() {
          _isLoading = false;
        });
        feedbackData = data;
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
    getFeedbackData();
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
          child: _isLoading ? Center(
            child: SizedBox(
              height: size.height * 0.06,
              child: const LoadingIndicator(
                indicatorType: Indicator.ballSpinFadeLoader,
                colors: [Colors.red,Colors.orange,Colors.yellow,Colors.green,Colors.blue,Colors.indigo,Colors.purple,],
              ),
            ),
          ) : Container(
            padding: const EdgeInsets.only(left: 5, right: 5),
            child: feedbackData.isNotEmpty ? Column(
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
                          itemCount: feedbackData.length,
                          itemBuilder: (BuildContext context, int index) {
                            DateTime targetDate = DateFormat('dd-MM-yyyy').parse(feedbackData[index]['date']);
                            int differenceInDays = currentDate.difference(targetDate).inDays.abs();
                            if (differenceInDays >= 365) {
                              int years = (differenceInDays / 365).floor();
                              days = years > 1 ? '$years years ago' : '1 year ago';
                            } else if (differenceInDays >= 30) {
                              int months = (differenceInDays / 30).floor();
                              days = months > 1 ? '$months months ago' : '1 month ago';
                            } else if (differenceInDays >= 1) {
                              days = differenceInDays > 1 ? '$differenceInDays days ago' : '1 day ago';
                            } else {
                              days = 'Today';
                            }
                            int rating = 5;
                            // Unicode character for a solid star
                            String starSymbol = '\u2605';
                            // Create a string with the desired number of stars
                            String stars = starSymbol * rating;
                            return GestureDetector(
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
                                        title: "Feedback",
                                        content: feedbackData[index]['feedback'],
                                    );
                                  },
                                );
                              },
                              child: Card(
                                elevation: 2,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.only(left: 10, right: 10, top: 10, bottom: 2),
                                      child: Row(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          GestureDetector(
                                            onTap: () {
                                              showDialog(
                                                context: context,
                                                builder: (BuildContext context) {
                                                  return Dialog(
                                                    child: Image.asset('assets/images/profile.png', fit: BoxFit.cover,),
                                                  );
                                                },
                                              );
                                            },
                                            child: Container(
                                              height: size.height * 0.06,
                                              width: size.width * 0.12,
                                              decoration: BoxDecoration(
                                                borderRadius: BorderRadius.circular(5),
                                                shape: BoxShape.rectangle,
                                                image: const DecorationImage(
                                                  fit: BoxFit.cover,
                                                  image: AssetImage('assets/images/profile.png'),
                                                ),
                                              ),
                                            ),
                                          ),
                                          SizedBox(
                                            width: size.width * 0.02,
                                          ),
                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                Text(feedbackData[index]['name'], style: GoogleFonts.roboto(fontWeight: FontWeight.bold, fontSize: size.height * 0.02, color: labelColor),),
                                                Text(stars, style: TextStyle(fontSize: size.height * 0.02, color: Colors.orangeAccent)),
                                              ],
                                            ),
                                          ),
                                          SizedBox(
                                            width: size.width * 0.02,
                                          ),
                                          Text(days, style: TextStyle(fontWeight: FontWeight.bold, fontSize: size.height * 0.016, color: emptyColor),),
                                        ],
                                      ),
                                    ),
                                    const Padding(
                                      padding: EdgeInsets.only(left: 10, right: 10,),
                                      child: Divider(
                                        thickness: 1,
                                      ),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.only(left: 10, right: 10, top: 2, bottom: 10),
                                      child: Row(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Flexible(
                                              child: Text(
                                                feedbackData[index]['feedback'],
                                                style: const TextStyle(
                                                    color: emptyColor
                                                ),
                                                maxLines: 3,
                                                overflow: TextOverflow.ellipsis,
                                              )
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          }
                      ),
                    ),
                  ),
                ),
              ],
            ) : Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
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
