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

class CommissionDetailsScreen extends StatefulWidget {
  const CommissionDetailsScreen({Key? key}) : super(key: key);

  @override
  State<CommissionDetailsScreen> createState() => _CommissionDetailsScreenState();
}

class _CommissionDetailsScreenState extends State<CommissionDetailsScreen> {
  final ClearSharedPreference shared = ClearSharedPreference();
  bool _isLoading = true;
  List commission = [];
  final format = DateFormat("dd-MM-yyyy");

  getCommissionData() async {
    var request = http.Request('GET', Uri.parse('$baseUrl/member.commission.detail'));
    request.body = json.encode({
      "params": {
        "filter": "[['member_id','=',$memberId]]",
        "order": "date_from desc",
        "query": "{id,commission_id,role_id,date_from,date_to,status}",
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
        commission = data;
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
      getCommissionData();
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
        ) : commission.isNotEmpty ? Container(
          padding: const EdgeInsets.only(left: 10, right: 10),
          child: SlideFadeAnimation(
            duration: const Duration(seconds: 1),
            child: ListView.builder(
                itemCount: commission.length,
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
                                        Container(width: size.width * 0.25, alignment: Alignment.topLeft, child: Text('Commission', style: GoogleFonts.signika(fontSize: size.height * 0.02, color: labelColor),)),
                                        Text(':  ', style: GoogleFonts.signika(fontSize: size.height * 0.02, color: labelColor),)
                                      ],
                                    ),
                                    commission[index]['commission_id'] != [] ? Text("${commission[index]['commission_id']['name']}", style: GoogleFonts.secularOne(color: valueColor, fontSize: size.height * 0.02),) : Text("NA", style: GoogleFonts.secularOne(fontSize: size.height * 0.02, color: emptyColor, fontStyle: FontStyle.italic),),
                                  ],
                                ),
                                Row(
                                  children: [
                                    Row(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Container(width: size.width * 0.25, alignment: Alignment.topLeft, child: Text('Role', style: GoogleFonts.signika(fontSize: size.height * 0.02, color: labelColor),)),
                                        Text(':  ', style: GoogleFonts.signika(fontSize: size.height * 0.02, color: labelColor),)
                                      ],
                                    ),
                                    commission[index]['role_id']['name'] != '' && commission[index]['role_id']['name'] != null ? Text("${commission[index]['role_id']['name']}", style: GoogleFonts.secularOne(color: valueColor, fontSize: size.height * 0.02),) : Text("NA", style: GoogleFonts.secularOne(fontSize: size.height * 0.02, color: emptyColor, fontStyle: FontStyle.italic),),
                                  ],
                                ),
                                Row(
                                  children: [
                                    Row(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Container(width: size.width * 0.25, alignment: Alignment.topLeft, child: Text('Date', style: GoogleFonts.signika(fontSize: size.height * 0.02, color: Colors.black87),)),
                                        Text(':  ', style: GoogleFonts.signika(fontSize: size.height * 0.02, color: labelColor),)
                                      ],
                                    ),
                                    commission[index]['date_from'].isNotEmpty && commission[index]['date_from'] != null && commission[index]['date_from'] != '' ? Text(format.format(DateFormat('dd-MM-yyyy').parse(commission[index]['date_from'])), style: GoogleFonts.secularOne(color: Colors.black, fontSize: size.height * 0.02),) : Text("", style: TextStyle(fontSize: size.height * 0.018, fontWeight: FontWeight.bold),),
                                    SizedBox(width: size.width * 0.02,),
                                    Text("-", style: GoogleFonts.secularOne(color: Colors.black),),
                                    SizedBox(width: size.width * 0.02,),
                                    commission[index]['date_to'].isNotEmpty && commission[index]['date_to'] != null && commission[index]['date_to'] != '' ? Text(format.format(DateFormat('dd-MM-yyyy').parse(commission[index]['date_to'])), style: GoogleFonts.secularOne(color: Colors.black, fontSize: size.height * 0.02),) : Text(
                                      "Till Now",
                                      style: GoogleFonts.secularOne(color: Colors.black, fontSize: size.height * 0.02),
                                    ),
                                  ],
                                )
                              ],
                            ),
                            Positioned(
                              top: 0,
                              right: 0,
                              child: Container(
                                alignment: Alignment.topRight,
                                child: Row(
                                    children: [
                                      commission[index]['status'] != null && commission[index]['status'] != '' ? commission[index]['status'] == 'Completed' ? Container(
                                        padding: const EdgeInsets.all(5),
                                        decoration: BoxDecoration(
                                          borderRadius: BorderRadius.circular(5),
                                          color: statusCompleted,
                                        ),
                                        child: Text('${commission[index]['status']}',style: GoogleFonts.secularOne(color: statusTextColor),),
                                      ) : Container(
                                        padding: const EdgeInsets.all(5),
                                        decoration: BoxDecoration(
                                            borderRadius: BorderRadius.circular(5),
                                            color: statusActive
                                        ),
                                        child: Text('${commission[index]['status']}', style: GoogleFonts.secularOne(color: statusTextColor),),
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
