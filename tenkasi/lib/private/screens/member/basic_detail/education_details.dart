import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:loading_indicator/loading_indicator.dart';
import 'package:tenkasi/widget/common/common.dart';
import 'package:tenkasi/widget/common/internet_connection_checker.dart';
import 'package:tenkasi/widget/common/slide_animations.dart';
import 'package:tenkasi/widget/theme_color/theme_color.dart';
import 'package:tenkasi/widget/widget.dart';

class EducationDetailsScreen extends StatefulWidget {
  const EducationDetailsScreen({Key? key}) : super(key: key);

  @override
  State<EducationDetailsScreen> createState() => _EducationDetailsScreenState();
}

class _EducationDetailsScreenState extends State<EducationDetailsScreen> {
  final ClearSharedPreference shared = ClearSharedPreference();
  bool _isLoading = true;
  List education = [];

  getEducationData() async {
    var request = http.Request('GET', Uri.parse('$baseUrl/member.education'));
    request.body = json.encode({
      "params": {
        "filter": "[['member_id','=',$memberId]]",
        "order": "year_of_passing desc",
        "query": "{id,study_level_id,program_id,particulars,year_of_passing,institution,mode,status}",
      }
    });
    request.headers.addAll(header);
    http.StreamedResponse response = await request.send();
    if(response.statusCode == 200) {
      var decode = json.decode(await response.stream.bytesToString())['result']['data'];
      if(decode['status'] == 'success') {
        List data = decode['result'];
        setState(() {
          _isLoading = false;
        });
        education = data;
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
    if(expiryDateTime!.isAfter(currentDateTime)) {
      getEducationData();
    } else {
      setState(() {
        shared.clearSharedPreferenceData(context);
      });
    }
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
        ) : education.isNotEmpty ? Container(
          padding: const EdgeInsets.only(left: 10, right: 10),
          child: SlideFadeAnimation(
            duration: const Duration(seconds: 1),
            child: ListView.builder(
                itemCount: education.length,
                itemBuilder: (BuildContext context, int index) {
                  return Card(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                      child: Container(
                        padding: const EdgeInsets.all(10),
                        child: Stack(
                          children: [
                            Column(
                              children: [
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Container(width: size.width * 0.25, alignment: Alignment.topLeft, child: Text('Study Level', style: GoogleFonts.signika(fontSize: size.height * 0.02, color: labelColor),)),
                                        Text(':  ', style: GoogleFonts.signika(fontSize: size.height * 0.02, color: labelColor),)
                                      ],
                                    ),
                                    education[index]['study_level_id']['name'] != null && education[index]['study_level_id']['name'] != '' ? Text("${education[index]['study_level_id']['name']}", style: GoogleFonts.secularOne(color: valueColor, fontSize: size.height * 0.02),) : Text("NA", style: GoogleFonts.secularOne(fontSize: size.height * 0.02, color: emptyColor, fontStyle: FontStyle.italic),),
                                  ],
                                ),
                                Row(
                                  children: [
                                    Row(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Container(width: size.width * 0.25, alignment: Alignment.topLeft, child: Text('Program', style: GoogleFonts.signika(fontSize: size.height * 0.02, color: labelColor),)),
                                        Text(':  ', style: GoogleFonts.signika(fontSize: size.height * 0.02, color: labelColor),)
                                      ],
                                    ),
                                    education[index]['program_id']['name'] != null && education[index]['program_id']['name'] != '' ? Text("${education[index]['program_id']['name']}", style: GoogleFonts.secularOne(color: valueColor, fontSize: size.height * 0.02),) : Text("NA", style: GoogleFonts.secularOne(fontSize: size.height * 0.02, color: emptyColor, fontStyle: FontStyle.italic),),
                                  ],
                                ),
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Container(width: size.width * 0.25, alignment: Alignment.topLeft, child: Text('Institution', style: GoogleFonts.signika(fontSize: size.height * 0.02, color: labelColor),)),
                                        Text(':  ', style: GoogleFonts.signika(fontSize: size.height * 0.02, color: labelColor),)
                                      ],
                                    ),
                                    education[index]['institution'] != '' && education[index]['institution'] != null ? Flexible(child: Text('${education[index]['institution']}', style: GoogleFonts.secularOne(color: valueColor, fontSize: size.height * 0.02),)) : Text("NA", style: GoogleFonts.secularOne(fontSize: size.height * 0.02, color: emptyColor, fontStyle: FontStyle.italic),),
                                  ],
                                ),
                                Row(
                                  children: [
                                    Row(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Container(width: size.width * 0.25, alignment: Alignment.topLeft, child: Text('Mode', style: GoogleFonts.signika(fontSize: size.height * 0.02, color: labelColor),)),
                                        Text(':  ', style: GoogleFonts.signika(fontSize: size.height * 0.02, color: labelColor),)
                                      ],
                                    ),
                                    education[index]['mode'] != '' && education[index]['mode'] != null ? Text('${education[index]['mode']}', style: GoogleFonts.secularOne(color: valueColor, fontSize: size.height * 0.02),) : Text("NA", style: GoogleFonts.secularOne(fontSize: size.height * 0.02, color: emptyColor, fontStyle: FontStyle.italic),),
                                  ],
                                ),
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Container(width: size.width * 0.25, alignment: Alignment.topLeft, child: Text('Year of Passing', style: GoogleFonts.signika(fontSize: size.height * 0.02, color: labelColor),)),
                                        Text(':  ', style: GoogleFonts.signika(fontSize: size.height * 0.02, color: labelColor),)
                                      ],
                                    ),
                                    education[index]['year_of_passing'] != '' && education[index]['year_of_passing'] != null ? Text('${education[index]['year_of_passing']}', style: GoogleFonts.secularOne(color: valueColor, fontSize: size.height * 0.02),) : Text("NA", style: GoogleFonts.secularOne(fontSize: size.height * 0.02, color: emptyColor, fontStyle: FontStyle.italic),),
                                  ],
                                ),
                              ],
                            ),
                            Positioned(
                              top: 0,
                              right: 0,
                              child: Container(
                                alignment: Alignment.topRight,
                                child: Row(
                                    children: [
                                      education[index]['status'] != null && education[index]['status'] != '' ? education[index]['status'] == 'Completed' ? Container(
                                        padding: const EdgeInsets.all(5),
                                        decoration: BoxDecoration(
                                          borderRadius: BorderRadius.circular(5),
                                          color: statusCompleted,
                                        ),
                                        child: Text('${education[index]['status']}',style: GoogleFonts.secularOne(color: statusTextColor),),
                                      ) : Container(
                                        padding: const EdgeInsets.all(5),
                                        decoration: BoxDecoration(
                                            borderRadius: BorderRadius.circular(5),
                                            color: statusActive
                                        ),
                                        child: Text('${education[index]['status']}', style: GoogleFonts.secularOne(color: statusTextColor),),
                                      ) : Container(),
                                    ]
                                ),
                              ),
                            ),
                          ],
                        ),
                      )
                  );
                }
            ),
          ),
        ) : Center(
          child: Container(
            padding: const EdgeInsets.only(left: 30, right: 30),
            child: NoResult(
              onPressed: () {
                setState(() {
                  Navigator.pop(context);
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
