import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:loading_indicator/loading_indicator.dart';
import 'package:perambur/widget/common/common.dart';
import 'package:perambur/widget/common/internet_connection_checker.dart';
import 'package:perambur/widget/common/slide_animations.dart';
import 'package:perambur/widget/theme_color/theme_color.dart';
import 'package:perambur/widget/widget.dart';

class PublicMassTimingScreen extends StatefulWidget {
  const PublicMassTimingScreen({Key? key}) : super(key: key);

  @override
  State<PublicMassTimingScreen> createState() => _PublicMassTimingScreenState();
}

class _PublicMassTimingScreenState extends State<PublicMassTimingScreen> {
  bool _isLoading = true;
  List mass = [];

  int selected = -1;
  int selected2 = -1;
  bool isCategoryExpanded = false;

  getMassTimingData() async {
    var request = http.Request('GET', Uri.parse('$baseUrl/public/$parishID/parish_mass_timing'));
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
        mass = data;
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
    getMassTimingData();
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
          title: Text(
            'Mass Timings',
            style: TextStyle(
              fontSize: size.height * 0.02,
              fontWeight: FontWeight.bold,
              color: whiteColor,
            ),
          ),
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
          ) : mass.isNotEmpty ? SlideFadeAnimation(
            duration: const Duration(seconds: 1),
            child: ListView.builder(
              key: Key('builder ${selected.toString()}'),
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: mass.length, // Update the itemCount to 2 for two expansion tiles
              itemBuilder: (BuildContext context, int index) {
                final isTileExpanded = index == selected;
                final textExpandColor = isTileExpanded ? expandColor : blackColor;
                return Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Card(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15.0),
                      ),
                      child: Container(
                        decoration: BoxDecoration(
                            color: menuSecondaryColor,
                            borderRadius: BorderRadius.circular(15.0)
                        ),
                        child: ExpansionTile(
                          key: Key(index.toString()),
                          initiallyExpanded: index == selected,
                          backgroundColor: Colors.white,
                          iconColor: iconColor,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15.0),
                          ),
                          onExpansionChanged: (newState) {
                            if (newState) {
                              setState(() {
                                selected = index;
                                selected2 = -1;
                                isCategoryExpanded = true;
                              });
                            } else {
                              setState(() {
                                selected = -1;
                                isCategoryExpanded = false;
                              });
                            }
                          },
                          title: Container(
                            padding: const EdgeInsets.only(top: 10, bottom: 10),
                            child: Text(
                              '${mass[index]['day']}',
                              style: GoogleFonts.roboto(
                                fontSize: size.height * 0.02,
                                color: textExpandColor,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          children: [
                            mass[index]['mass'].isNotEmpty ? ListView.builder(
                              key: Key('builder ${selected2.toString()}'),
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              itemCount: isCategoryExpanded ? mass[index]['mass'].length : 0, // Update the itemCount to 2 for two expansion tiles
                              itemBuilder: (BuildContext context, int indexs) {
                                return Column(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.only(left: 10, top: 5, bottom: 5, right: 10),
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          // Row(
                                          //   crossAxisAlignment: CrossAxisAlignment.start,
                                          //   children: [
                                          //     Row(
                                          //       children: [
                                          //         Container(width: size.width * 0.2, alignment: Alignment.topLeft, child: Text('Title', style: GoogleFonts.signika(fontSize: size.height * 0.02, color: labelColor),)),
                                          //         Text(':   ', style: GoogleFonts.signika(fontSize: size.height * 0.02, color: labelColor),)
                                          //       ],
                                          //     ),
                                          //     mass[index]['mass'][indexs]['name'] != '' && mass[index]['mass'][indexs]['name'] != null ? Text(
                                          //       mass[index]['mass'][indexs]['name'],
                                          //       style: GoogleFonts.secularOne(color: valueColor, fontSize: size.height * 0.02),
                                          //     ) : Text(
                                          //       'NA',
                                          //       style: GoogleFonts.secularOne(fontSize: size.height * 0.02, color: emptyColor, fontStyle: FontStyle.italic),
                                          //     )
                                          //   ],
                                          // ),
                                          Row(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Row(
                                                children: [
                                                  Container(width: size.width * 0.2, alignment: Alignment.topLeft, child: Text('Time', style: GoogleFonts.signika(fontSize: size.height * 0.02, color: labelColor),)),
                                                  Text(':   ', style: GoogleFonts.signika(fontSize: size.height * 0.02, color: labelColor),)
                                                ],
                                              ),
                                              mass[index]['mass'][indexs]['time'] != '' && mass[index]['mass'][indexs]['time'] != null ? Text(
                                                mass[index]['mass'][indexs]['time'],
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
                                                  Container(width: size.width * 0.2, alignment: Alignment.topLeft, child: Text('Place', style: GoogleFonts.signika(fontSize: size.height * 0.02, color: labelColor),)),
                                                  Text(':   ', style: GoogleFonts.signika(fontSize: size.height * 0.02, color: labelColor),)
                                                ],
                                              ),
                                              mass[index]['mass'][indexs]['location'] != '' && mass[index]['mass'][indexs]['location'] != null ? Text(
                                                mass[index]['mass'][indexs]['location'],
                                                style: GoogleFonts.secularOne(color: valueColor, fontSize: size.height * 0.02),
                                              ) : Text(
                                                'NA',
                                                style: GoogleFonts.secularOne(fontSize: size.height * 0.02, color: emptyColor, fontStyle: FontStyle.italic),
                                              )
                                            ],
                                          ),
                                          mass[index]['mass'][indexs]['description'] != '' && mass[index]['mass'][indexs]['description'] != null ? Row(
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
                                                          text: mass[index]['mass'][indexs]['description'],
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
                                    if(indexs < mass[index]['mass'].length - 1) const Divider(
                                      thickness: 2,
                                    ),
                                  ],
                                );
                              },
                            ) : Center(
                              child: Container(
                                alignment: Alignment.center,
                                padding: const EdgeInsets.only(left: 30, right: 30, bottom: 10),
                                child: const Text(
                                  'No Data available',
                                  style: TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.black
                                  ),
                                ),
                              ),
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
                    Navigator.pop(context);
                  });
                },
                text: 'No Data available',
              ),
            ),
          ),
        ),
      ),
    );
  }
}
