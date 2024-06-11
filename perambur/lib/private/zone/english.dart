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

import 'zone_anbiyam.dart';


class EnglishZoneScreen extends StatefulWidget {
  const EnglishZoneScreen({Key? key}) : super(key: key);

  @override
  State<EnglishZoneScreen> createState() => _EnglishZoneScreenState();
}

class _EnglishZoneScreenState extends State<EnglishZoneScreen> {
  bool _isLoading = true;
  List englishZone = [];

  getZoneData() async {
    var request = http.Request('GET', Uri.parse('$baseUrl/res.ecclesia.zone'));
    request.body = json.encode({
      "params": {
        "filter": "[['parish_id','=',${int.parse(parishID)}],['category_id.name','=','English']]",
        "access_all": "1",
        "query": "{id,name,substation_id,in_charge,category_id}"
      }
    });
    request.headers.addAll(header);
    http.StreamedResponse response = await request.send();
    if (response.statusCode == 200) {
      var decode = json.decode(await response.stream.bytesToString())['result']['data'];
      if(decode['status'] == 'success') {
        List data = decode['result'];
        englishZone = data;
        setState(() {
          _isLoading = false;
        });
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

  changeData() {
    setState(() {
      _isLoading = true;
      englishZone = [];
      getZoneData();
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
          ) : englishZone.isNotEmpty ? SlideFadeAnimation(
            duration: const Duration(seconds: 1),
            child: SingleChildScrollView(
              child: ListView.builder(
                  key: UniqueKey(),
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: englishZone.length,
                  itemBuilder: (BuildContext context, int index) {
                    return Column(
                      children: [
                        SizedBox(height: size.height * 0.005,),
                        GestureDetector(
                          onTap: () async {
                            zoneId = englishZone[index]['id'].toString();
                            String refresh = await Navigator.push(context, CustomRoute(widget: ZoneAnbiyamScreen(name: englishZone[index]['name'],)));
                            if(refresh == 'refresh') {
                              changeData();
                            }
                          },
                          child: Card(
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
                                  englishZone[index]['name'],
                                  style: GoogleFonts.roboto(
                                    fontSize: size.height * 0.018,
                                    color: blackColor,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                                subtitle: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    if (englishZone[index]['in_charge'] != '') SizedBox(height: size.height * 0.01,),
                                    if (englishZone[index]['in_charge'] != '') Text(
                                      englishZone[index]['in_charge'],
                                      style: TextStyle(
                                        fontSize: size.height * 0.015,
                                        fontWeight: FontWeight.bold,
                                        color: textHeadColor,
                                      ),
                                    ),
                                    if (englishZone[index]['substation_id']['name'] != '') SizedBox(height: size.height * 0.01,),
                                    if (englishZone[index]['substation_id']['name'] != '') Text(
                                      englishZone[index]['substation_id']['name'],
                                      style: TextStyle(
                                        fontSize: size.height * 0.015,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.teal,
                                      ),
                                    ),
                                  ],
                                ),
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
