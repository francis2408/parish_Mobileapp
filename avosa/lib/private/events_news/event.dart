import 'dart:convert';

import 'package:avosa/widget/common/common.dart';
import 'package:avosa/widget/common/internet_connection_checker.dart';
import 'package:avosa/widget/theme_color/theme_color.dart';
import 'package:avosa/widget/widget.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:loading_indicator/loading_indicator.dart';

class EventScreen extends StatefulWidget {
  const EventScreen({Key? key}) : super(key: key);

  @override
  State<EventScreen> createState() => _EventScreenState();
}

class _EventScreenState extends State<EventScreen> {
  bool _isLoading = true;
  List event = [];

  getNewsData() async {
    var request = http.Request('GET', Uri.parse('$baseUrl/event_news/Event'));
    request.body = json.encode({
      "params": {
        "parish_id": int.parse(parishID),
      }
    });
    request.headers.addAll(headers);
    http.StreamedResponse response = await request.send();
    if (response.statusCode == 200) {
      var decode = json.decode(await response.stream.bytesToString())['result'];
      setState(() {
        _isLoading = false;
      });
      event = decode;
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
    getNewsData();
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Scaffold(
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
        ) : event.isNotEmpty ? SingleChildScrollView(
          child: ListView.builder(
            key: UniqueKey(),
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: event.length,
            itemBuilder: (BuildContext context, int index) {
              return Column(
                children: [
                  Card(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(10),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Container(width: size.width * 0.2, alignment: Alignment.topLeft, child: Text('Name', style: GoogleFonts.signika(fontSize: size.height * 0.02, color: labelColor),)),
                                  Text(':   ', style: GoogleFonts.signika(fontSize: size.height * 0.02, color: labelColor),)
                                ],
                              ),
                              event[index]['name'] != '' && event[index]['name'] != false ? Text(
                                event[index]['name'],
                                style: GoogleFonts.secularOne(color: valueColor, fontSize: size.height * 0.02),
                              ) : Text(
                                'NA',
                                style: GoogleFonts.secularOne(fontSize: size.height * 0.02, color: emptyColor, fontStyle: FontStyle.italic),
                              )
                            ],
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Container(width: size.width * 0.2, alignment: Alignment.topLeft, child: Text('Date', style: GoogleFonts.signika(fontSize: size.height * 0.02, color: labelColor),)),
                                  Text(':   ', style: GoogleFonts.signika(fontSize: size.height * 0.02, color: labelColor),)
                                ],
                              ),
                              event[index]['date'] != '' && event[index]['date'] != false ? Text(
                                event[index]['date'],
                                style: GoogleFonts.secularOne(color: valueColor, fontSize: size.height * 0.02),
                              ) : Text(
                                'NA',
                                style: GoogleFonts.secularOne(fontSize: size.height * 0.02, color: emptyColor, fontStyle: FontStyle.italic),
                              )
                            ],
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Container(width: size.width * 0.2, alignment: Alignment.topLeft, child: Text('Place', style: GoogleFonts.signika(fontSize: size.height * 0.02, color: labelColor),)),
                                  Text(':   ', style: GoogleFonts.signika(fontSize: size.height * 0.02, color: labelColor),)
                                ],
                              ),
                              event[index]['place'] != '' && event[index]['place'] != false ? Text(
                                event[index]['place'],
                                style: GoogleFonts.secularOne(color: valueColor, fontSize: size.height * 0.02),
                              ) : Text(
                                'NA',
                                style: GoogleFonts.secularOne(fontSize: size.height * 0.02, color: emptyColor, fontStyle: FontStyle.italic),
                              )
                            ],
                          ),
                          event[index]['description'] != '' && event[index]['description'] != false ? Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Flexible(
                                child: RichText(
                                  textAlign: TextAlign.justify,
                                  text: TextSpan(
                                      text: '',
                                      children: [
                                        WidgetSpan(
                                          child: Container(width: size.width * 0.2, alignment: Alignment.topLeft, child: Text('Note', style: GoogleFonts.signika(fontSize: size.height * 0.02, color: labelColor),)),
                                        ),
                                        TextSpan(
                                          text: ':   ',
                                          style: GoogleFonts.signika(color: valueColor, fontSize: size.height * 0.02),
                                        ),
                                        TextSpan(
                                          text: event[index]['description'],
                                          style: GoogleFonts.secularOne(color: valueColor, fontSize: size.height * 0.018),
                                        ),
                                      ]),
                                ),
                              ),
                            ],
                          ) : Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Container(width: size.width * 0.2, alignment: Alignment.topLeft, child: Text('Note', style: GoogleFonts.signika(fontSize: size.height * 0.02, color: labelColor),)),
                                  Text(':   ', style: GoogleFonts.signika(fontSize: size.height * 0.02, color: labelColor),)
                                ],
                              ),
                              Text(
                                'NA',
                                style: GoogleFonts.secularOne(fontSize: size.height * 0.02, color: emptyColor, fontStyle: FontStyle.italic),
                              )
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              );
            },
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
        ),
      ),
    );
  }
}
