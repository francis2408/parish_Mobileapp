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

class SacramentDetailsScreen extends StatefulWidget {
  const SacramentDetailsScreen({Key? key}) : super(key: key);

  @override
  State<SacramentDetailsScreen> createState() => _SacramentDetailsScreenState();
}

class _SacramentDetailsScreenState extends State<SacramentDetailsScreen> {
  final ClearSharedPreference shared = ClearSharedPreference();
  bool _isLoading = true;
  var membersDetail;

  getMemberDetailData() async {
    var request = http.Request('GET', Uri.parse('$baseUrl/res.member/$memberId'));
    request.body = json.encode({
      "params": {
        "query": "{age,bapt_date,bapt_parish_id,bapt_minister,fhc_date,fhc_parish_id,fhc_minister,cnf_date,cnf_parish_id,cnf_minister,mrg_date,mrg_parish_id,mrg_minister}",
      }
    });
    request.headers.addAll(header);
    http.StreamedResponse response = await request.send();
    if(response.statusCode == 200) {
      var decode = json.decode(await response.stream.bytesToString())['result'];
      var data = decode['data'];
      setState(() {
        _isLoading = false;
      });
      membersDetail = data;
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
      getMemberDetailData();
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
        ) : membersDetail.isNotEmpty && membersDetail != {} ? Container(
          padding: const EdgeInsets.symmetric(vertical: 5),
          child: SlideFadeAnimation(
            duration: const Duration(seconds: 1),
            child: Column(
              children: [
                Card(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15.0),
                  ),
                  child: Container(
                    padding: const EdgeInsets.all(10),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Baptism', style: GoogleFonts.roboto(fontSize: size.height * 0.022, color: hiLightColor, fontWeight: FontWeight.w600),),
                        SizedBox(height: size.height * 0.01,),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(width: size.width * 0.25, alignment: Alignment.topLeft, child: Text('Date', style: GoogleFonts.signika(fontSize: size.height * 0.02, color: labelColor),)),
                                Text(':  ', style: GoogleFonts.signika(fontSize: size.height * 0.02, color: labelColor),)
                              ],
                            ),
                            membersDetail['bapt_date'] != '' && membersDetail['bapt_date'] != null ? Text(
                              membersDetail['bapt_date'],
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
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(width: size.width * 0.25, alignment: Alignment.topLeft, child: Text('Parish', style: GoogleFonts.signika(fontSize: size.height * 0.02, color: labelColor),)),
                                Text(':  ', style: GoogleFonts.signika(fontSize: size.height * 0.02, color: labelColor),)
                              ],
                            ),
                            membersDetail['bapt_parish_id']['name'] != '' && membersDetail['bapt_parish_id']['name'] != null ? Flexible(
                              child: Text(
                                membersDetail['bapt_parish_id']['name'],
                                style: GoogleFonts.secularOne(color: valueColor, fontSize: size.height * 0.02),
                              ),
                            ) : Text(
                              'NA',
                              style: GoogleFonts.secularOne(fontSize: size.height * 0.02, color: emptyColor, fontStyle: FontStyle.italic),
                            )
                          ],
                        ),
                        membersDetail['bapt_minister'] != '' && membersDetail['bapt_minister'] != null ? Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Flexible(
                              child: RichText(
                                textAlign: TextAlign.justify,
                                text: TextSpan(
                                    text: '',
                                    children: [
                                      WidgetSpan(
                                        child: Container(width: size.width * 0.25, alignment: Alignment.topLeft, child: Text('Minister', style: GoogleFonts.signika(fontSize: size.height * 0.02, color: labelColor),)),
                                      ),
                                      TextSpan(
                                        text: ':  ',
                                        style: GoogleFonts.signika(color: valueColor, fontSize: size.height * 0.02),
                                      ),
                                      TextSpan(
                                        text: membersDetail['bapt_minister'],
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
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(width: size.width * 0.25, alignment: Alignment.topLeft, child: Text('Minister', style: GoogleFonts.signika(fontSize: size.height * 0.02, color: labelColor),)),
                                Text(':  ', style: GoogleFonts.signika(fontSize: size.height * 0.02, color: labelColor),)
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
                Card(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15.0),
                  ),
                  child: Container(
                    padding: const EdgeInsets.all(10),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('First Holy Communion', style: GoogleFonts.roboto(fontSize: size.height * 0.022, color: hiLightColor, fontWeight: FontWeight.w600),),
                        SizedBox(height: size.height * 0.01,),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(width: size.width * 0.25, alignment: Alignment.topLeft, child: Text('Date', style: GoogleFonts.signika(fontSize: size.height * 0.02, color: labelColor),)),
                                Text(':  ', style: GoogleFonts.signika(fontSize: size.height * 0.02, color: labelColor),)
                              ],
                            ),
                            membersDetail['fhc_date'] != '' && membersDetail['fhc_date'] != null ? Text(
                              membersDetail['fhc_date'],
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
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(width: size.width * 0.25, alignment: Alignment.topLeft, child: Text('Parish', style: GoogleFonts.signika(fontSize: size.height * 0.02, color: labelColor),)),
                                Text(':  ', style: GoogleFonts.signika(fontSize: size.height * 0.02, color: labelColor),)
                              ],
                            ),
                            membersDetail['fhc_parish_id']['name'] != '' && membersDetail['fhc_parish_id']['name'] != null ? Flexible(
                              child: Text(
                                membersDetail['fhc_parish_id']['name'],
                                style: GoogleFonts.secularOne(color: valueColor, fontSize: size.height * 0.02),
                              ),
                            ) : Text(
                              'NA',
                              style: GoogleFonts.secularOne(fontSize: size.height * 0.02, color: emptyColor, fontStyle: FontStyle.italic),
                            )
                          ],
                        ),
                        membersDetail['fhc_minister'] != '' && membersDetail['fhc_minister'] != null ? Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Flexible(
                              child: RichText(
                                textAlign: TextAlign.justify,
                                text: TextSpan(
                                    text: '',
                                    children: [
                                      WidgetSpan(
                                        child: Container(width: size.width * 0.25, alignment: Alignment.topLeft, child: Text('Minister', style: GoogleFonts.signika(fontSize: size.height * 0.02, color: labelColor),)),
                                      ),
                                      TextSpan(
                                        text: ':  ',
                                        style: GoogleFonts.signika(color: valueColor, fontSize: size.height * 0.02),
                                      ),
                                      TextSpan(
                                        text: membersDetail['fhc_minister'],
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
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(width: size.width * 0.25, alignment: Alignment.topLeft, child: Text('Minister', style: GoogleFonts.signika(fontSize: size.height * 0.02, color: labelColor),)),
                                Text(':  ', style: GoogleFonts.signika(fontSize: size.height * 0.02, color: labelColor),)
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
                Card(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15.0),
                  ),
                  child: Container(
                    padding: const EdgeInsets.all(10),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Confirmation', style: GoogleFonts.roboto(fontSize: size.height * 0.022, color: hiLightColor, fontWeight: FontWeight.w600),),
                        SizedBox(height: size.height * 0.01,),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(width: size.width * 0.25, alignment: Alignment.topLeft, child: Text('Date', style: GoogleFonts.signika(fontSize: size.height * 0.02, color: labelColor),)),
                                Text(':  ', style: GoogleFonts.signika(fontSize: size.height * 0.02, color: labelColor),)
                              ],
                            ),
                            membersDetail['cnf_date'] != '' && membersDetail['cnf_date'] != null ? Text(
                              membersDetail['cnf_date'],
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
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(width: size.width * 0.25, alignment: Alignment.topLeft, child: Text('Parish', style: GoogleFonts.signika(fontSize: size.height * 0.02, color: labelColor),)),
                                Text(':  ', style: GoogleFonts.signika(fontSize: size.height * 0.02, color: labelColor),)
                              ],
                            ),
                            membersDetail['cnf_parish_id']['name'] != '' && membersDetail['cnf_parish_id']['name'] != null ? Flexible(
                              child: Text(
                                membersDetail['cnf_parish_id']['name'],
                                style: GoogleFonts.secularOne(color: valueColor, fontSize: size.height * 0.02),
                              ),
                            ) : Text(
                              'NA',
                              style: GoogleFonts.secularOne(fontSize: size.height * 0.02, color: emptyColor, fontStyle: FontStyle.italic),
                            )
                          ],
                        ),
                        membersDetail['cnf_minister'] != '' && membersDetail['cnf_minister'] != null ? Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Flexible(
                              child: RichText(
                                textAlign: TextAlign.justify,
                                text: TextSpan(
                                    text: '',
                                    children: [
                                      WidgetSpan(
                                        child: Container(width: size.width * 0.25, alignment: Alignment.topLeft, child: Text('Minister', style: GoogleFonts.signika(fontSize: size.height * 0.02, color: labelColor),)),
                                      ),
                                      TextSpan(
                                        text: ':  ',
                                        style: GoogleFonts.signika(color: valueColor, fontSize: size.height * 0.02),
                                      ),
                                      TextSpan(
                                        text: membersDetail['cnf_minister'],
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
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(width: size.width * 0.25, alignment: Alignment.topLeft, child: Text('Minister', style: GoogleFonts.signika(fontSize: size.height * 0.02, color: labelColor),)),
                                Text(':  ', style: GoogleFonts.signika(fontSize: size.height * 0.02, color: labelColor),)
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
                membersDetail['age'] != null && membersDetail['age'] != '' && membersDetail['age'] > 18 ? Card(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15.0),
                  ),
                  child: Container(
                    padding: const EdgeInsets.all(10),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Marriage', style: GoogleFonts.roboto(fontSize: size.height * 0.022, color: hiLightColor, fontWeight: FontWeight.w600),),
                        SizedBox(height: size.height * 0.01,),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(width: size.width * 0.25, alignment: Alignment.topLeft, child: Text('Date', style: GoogleFonts.signika(fontSize: size.height * 0.02, color: labelColor),)),
                                Text(':  ', style: GoogleFonts.signika(fontSize: size.height * 0.02, color: labelColor),)
                              ],
                            ),
                            membersDetail['mrg_date'] != '' && membersDetail['mrg_date'] != null ? Text(
                              membersDetail['mrg_date'],
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
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(width: size.width * 0.25, alignment: Alignment.topLeft, child: Text('Parish', style: GoogleFonts.signika(fontSize: size.height * 0.02, color: labelColor),)),
                                Text(':  ', style: GoogleFonts.signika(fontSize: size.height * 0.02, color: labelColor),)
                              ],
                            ),
                            membersDetail['mrg_parish_id']['name'] != '' && membersDetail['mrg_parish_id']['name'] != null ? Text(
                              membersDetail['mrg_parish_id']['name'],
                              style: GoogleFonts.secularOne(color: valueColor, fontSize: size.height * 0.02),
                            ) : Text(
                              'NA',
                              style: GoogleFonts.secularOne(fontSize: size.height * 0.02, color: emptyColor, fontStyle: FontStyle.italic),
                            )
                          ],
                        ),
                        membersDetail['mrg_minister'] != '' && membersDetail['mrg_minister'] != null ? Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Flexible(
                              child: RichText(
                                textAlign: TextAlign.justify,
                                text: TextSpan(
                                    text: '',
                                    children: [
                                      WidgetSpan(
                                        child: Container(width: size.width * 0.25, alignment: Alignment.topLeft, child: Text('Minister', style: GoogleFonts.signika(fontSize: size.height * 0.02, color: labelColor),)),
                                      ),
                                      TextSpan(
                                        text: ':  ',
                                        style: GoogleFonts.signika(color: valueColor, fontSize: size.height * 0.02),
                                      ),
                                      TextSpan(
                                        text: membersDetail['mrg_minister'],
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
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(width: size.width * 0.25, alignment: Alignment.topLeft, child: Text('Minister', style: GoogleFonts.signika(fontSize: size.height * 0.02, color: labelColor),)),
                                Text(':  ', style: GoogleFonts.signika(fontSize: size.height * 0.02, color: labelColor),)
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
                ) : Container(),
              ],
            ),
          ),
        ) : Expanded(
          child: Center(
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
      ),
    );
  }
}
