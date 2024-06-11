import 'dart:convert';

import 'package:avosa/widget/common/common.dart';
import 'package:avosa/widget/common/internet_connection_checker.dart';
import 'package:avosa/widget/theme_color/theme_color.dart';
import 'package:avosa/widget/widget.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:loading_indicator/loading_indicator.dart';

class AdorationScreen extends StatefulWidget {
  const AdorationScreen({Key? key}) : super(key: key);

  @override
  State<AdorationScreen> createState() => _AdorationScreenState();
}

class _AdorationScreenState extends State<AdorationScreen> {
  bool _isLoading = true;
  List adoration = [];

  getAdorationData() async {
    var request = http.Request('GET', Uri.parse('$baseUrl/prayer/services/Adoration'));
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
      adoration = decode;
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
    getAdorationData();
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
        ) : adoration.isNotEmpty ? SingleChildScrollView(
          child: ListView.builder(
            key: UniqueKey(),
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: adoration.length, // Update the itemCount to 2 for two expansion tiles
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
                              adoration[index]['name'] != '' && adoration[index]['name'] != false ? Text(
                                adoration[index]['name'],
                                style: GoogleFonts.secularOne(color: valueColor, fontSize: size.height * 0.02),
                              ) : Text(
                                'NA',
                                style: GoogleFonts.secularOne(fontSize: size.height * 0.02, color: emptyColor, fontStyle: FontStyle.italic),
                              )
                            ],
                          ),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Container(width: size.width * 0.2, alignment: Alignment.topLeft, child: Text('Day', style: GoogleFonts.signika(fontSize: size.height * 0.02, color: labelColor),)),
                                  Text(':   ', style: GoogleFonts.signika(fontSize: size.height * 0.02, color: labelColor),)
                                ],
                              ),
                              adoration[index]['day'] != '' && adoration[index]['day'] != false ? Text(
                                adoration[index]['day'],
                                style: GoogleFonts.secularOne(color: valueColor, fontSize: size.height * 0.02),
                              ) : Text(
                                'NA',
                                style: GoogleFonts.secularOne(fontSize: size.height * 0.02, color: emptyColor, fontStyle: FontStyle.italic),
                              )
                            ],
                          ),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Container(width: size.width * 0.2, alignment: Alignment.topLeft, child: Text('Time', style: GoogleFonts.signika(fontSize: size.height * 0.02, color: labelColor),)),
                                  Text(':   ', style: GoogleFonts.signika(fontSize: size.height * 0.02, color: labelColor),)
                                ],
                              ),
                              adoration[index]['from_time'] != '' && adoration[index]['from_time'] != false || adoration[index]['to_time'] != '' && adoration[index]['to_time'] != false ? Row(
                                children: [
                                  if (adoration[index]['from_time'] != '' && adoration[index]['from_time'] != false) Text(
                                    adoration[index]['from_time'],
                                    style: GoogleFonts.secularOne(color: valueColor, fontSize: size.height * 0.02),
                                  ),
                                  if (adoration[index]['from_time'] != '' && adoration[index]['from_time'] != false && adoration[index]['to_time'] != '' && adoration[index]['to_time'] != false) Text(
                                    ' - ',
                                    style: GoogleFonts.secularOne(color: valueColor, fontSize: size.height * 0.02),
                                  ),
                                  if (adoration[index]['to_time'] != '' && adoration[index]['to_time'] != false) Text(
                                    adoration[index]['to_time'],
                                    style: GoogleFonts.secularOne(color: valueColor, fontSize: size.height * 0.02),
                                  ),
                                ],
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
                                  Container(width: size.width * 0.2, alignment: Alignment.topLeft, child: Text('Language & Place', style: GoogleFonts.signika(fontSize: size.height * 0.02, color: labelColor),)),
                                  Text(':   ', style: GoogleFonts.signika(fontSize: size.height * 0.02, color: labelColor),)
                                ],
                              ),
                              adoration[index]['place'] != '' && adoration[index]['place'] != false ? Row(
                                children: [
                                  if (adoration[index]['community_id'] != '' && adoration[index]['community_id'] != false) Text(
                                    adoration[index]['community_id'],
                                    style: GoogleFonts.secularOne(color: valueColor, fontSize: size.height * 0.02),
                                  ),
                                  if (adoration[index]['community_id'] != '' && adoration[index]['community_id'] != false) Text(
                                    ' - ',
                                    style: GoogleFonts.secularOne(color: valueColor, fontSize: size.height * 0.02),
                                  ),
                                  Text(
                                    adoration[index]['place'],
                                    style: GoogleFonts.secularOne(color: valueColor, fontSize: size.height * 0.02),
                                  ),
                                ],
                              ) : Text(
                                'NA',
                                style: GoogleFonts.secularOne(fontSize: size.height * 0.02, color: emptyColor, fontStyle: FontStyle.italic),
                              )
                            ],
                          ),
                          adoration[index]['note'] != '' && adoration[index]['note'] != false ? Row(
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
                                          text: adoration[index]['note'],
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
