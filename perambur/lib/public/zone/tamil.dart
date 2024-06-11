import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:loading_indicator/loading_indicator.dart';
import 'package:perambur/widget/common/common.dart';
import 'package:perambur/widget/common/internet_connection_checker.dart';
import 'package:perambur/widget/common/slide_animations.dart';
import 'package:perambur/widget/theme_color/theme_color.dart';
import 'package:perambur/widget/widget.dart';

class PublicTamilZoneScreen extends StatefulWidget {
  const PublicTamilZoneScreen({Key? key}) : super(key: key);

  @override
  State<PublicTamilZoneScreen> createState() => _PublicTamilZoneScreenState();
}

class _PublicTamilZoneScreenState extends State<PublicTamilZoneScreen> {
  bool _isLoading = true;
  List<Map<String, dynamic>> tamilZone = [];

  getZoneData() async {
    var request = http.Request('GET', Uri.parse('$baseUrl/public/res.ecclesia.zone/get_ecclesia_zone'));
    request.body = json.encode({
      "params": {
        "args": [int.parse(parishID)]
      }
    });
    request.headers.addAll(headers);
    http.StreamedResponse response = await request.send();
    if (response.statusCode == 200) {
      var decode = json.decode(await response.stream.bytesToString());
      List data = decode['result'];
      for(var datas in data) {
        if (datas['category_id'] == "Tamil") {
          tamilZone.add(datas);
        }
      }
      setState(() {
        _isLoading = false;
      });
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
    getZoneData();
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
          ) : tamilZone.isNotEmpty ? SlideFadeAnimation(
            duration: const Duration(seconds: 1),
            child: SingleChildScrollView(
              child: ListView.builder(
                  key: UniqueKey(),
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: tamilZone.length,
                  itemBuilder: (BuildContext context, int index) {
                    return Column(
                      children: [
                        SizedBox(height: size.height * 0.005,),
                        Card(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.only(top: 5, bottom: 5),
                            child: ListTile(
                              leading: Container(
                                height: size.height * 0.06,
                                width: size.width * 0.13,
                                decoration: BoxDecoration(
                                  color: Colors.indigo.shade700.withOpacity(0.8),
                                  shape: BoxShape.rectangle,
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Center(
                                    child: IconButton(
                                      icon: SvgPicture.asset("assets/icons/zone.svg", color: whiteColor),
                                      iconSize: 60,
                                      onPressed: () {},
                                    )
                                ),
                              ),
                              title: Text(
                                tamilZone[index]['name'],
                                style: GoogleFonts.roboto(
                                  fontSize: size.height * 0.018,
                                  color: blackColor,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  SizedBox(height: size.height * 0.01,),
                                  Row(
                                    children: [
                                      tamilZone[index]['bcc_count'] != '' && tamilZone[index]['bcc_count'] != null && tamilZone[index]['bcc_count'] != 0 ? Container(
                                        padding: const EdgeInsets.only(top: 5, bottom: 5, left: 8, right: 8),
                                        decoration: BoxDecoration(
                                          borderRadius: BorderRadius.circular(5),
                                          color: customBackgroundColor2,
                                        ),
                                        child: RichText(
                                          text: TextSpan(
                                              text: tamilZone[index]['bcc_count'].toString(),
                                              style: TextStyle(
                                                  letterSpacing: 1,
                                                  fontSize: size.height * 0.015,
                                                  fontWeight: FontWeight.bold,
                                                  color: customTextColor2,
                                                  fontStyle: FontStyle.italic
                                              ),
                                              children: <InlineSpan>[
                                                tamilZone[index]['bcc_count'] == 1 ? TextSpan(
                                                  text: ' Anbiyam',
                                                  style: TextStyle(
                                                      letterSpacing: 1,
                                                      fontSize: size.height * 0.015,
                                                      fontWeight: FontWeight.bold,
                                                      color: customTextColor2,
                                                      fontStyle: FontStyle.italic
                                                  ),
                                                ) : TextSpan(
                                                  text: ' Anbiyams',
                                                  style: TextStyle(
                                                      letterSpacing: 1,
                                                      fontSize: size.height * 0.015,
                                                      fontWeight: FontWeight.bold,
                                                      color: customTextColor2,
                                                      fontStyle: FontStyle.italic
                                                  ),
                                                )
                                              ]
                                          ),
                                        ),
                                      ) : Container(),
                                      SizedBox(
                                        width: size.width * 0.05,
                                      ),
                                      tamilZone[index]['family_count'] != '' && tamilZone[index]['family_count'] != null && tamilZone[index]['family_count'] != 0 ? Container(
                                        padding: const EdgeInsets.only(top: 5, bottom: 5, left: 8, right: 8),
                                        decoration: BoxDecoration(
                                          borderRadius: BorderRadius.circular(5),
                                          color: customBackgroundColor1,
                                        ),
                                        child: RichText(
                                          text: TextSpan(
                                              text: tamilZone[index]['family_count'].toString(),
                                              style: TextStyle(
                                                  letterSpacing: 1,
                                                  fontSize: size.height * 0.015,
                                                  fontWeight: FontWeight.bold,
                                                  color: customTextColor1,
                                                  fontStyle: FontStyle.italic
                                              ),
                                              children: <InlineSpan>[
                                                tamilZone[index]['family_count'] == 1 ? TextSpan(
                                                  text: ' Family',
                                                  style: TextStyle(
                                                      letterSpacing: 1,
                                                      fontSize: size.height * 0.015,
                                                      fontWeight: FontWeight.bold,
                                                      color: customTextColor1,
                                                      fontStyle: FontStyle.italic
                                                  ),
                                                ) : TextSpan(
                                                  text: ' Families',
                                                  style: TextStyle(
                                                      letterSpacing: 1,
                                                      fontSize: size.height * 0.015,
                                                      fontWeight: FontWeight.bold,
                                                      color: customTextColor1,
                                                      fontStyle: FontStyle.italic
                                                  ),
                                                )
                                              ]
                                          ),
                                        ),
                                      ) : Container(),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    );
                  }
              ),
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
      ),
    );
  }
}
