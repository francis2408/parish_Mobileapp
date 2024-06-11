import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:loading_indicator/loading_indicator.dart';
import 'package:munchirai/private/screens/prayer/prayer_detail.dart';
import 'package:munchirai/widget/common/common.dart';
import 'package:munchirai/widget/common/internet_connection_checker.dart';
import 'package:munchirai/widget/common/slide_animations.dart';
import 'package:munchirai/widget/theme_color/theme_color.dart';
import 'package:munchirai/widget/widget.dart';

class PrayerRequest extends StatefulWidget {
  const PrayerRequest({Key? key}) : super(key: key);

  @override
  State<PrayerRequest> createState() => _PrayerRequestState();
}

class _PrayerRequestState extends State<PrayerRequest> {
  final ClearSharedPreference shared = ClearSharedPreference();
  bool _isLoading = true;

  List prayerData = [];
  String name = '';
  String date = '';
  String mobile = '';
  String email = '';
  String note = '';

  getPrayersData() async {
    var request = http.Request('GET', Uri.parse('$baseUrl/prayer.request'));
    request.body = json.encode({
      "params": {
        "query": "{name,date,liturgy_calendar_id,create_date,intention_type_ids,email,mobile,amount,note}",
        "order": "date asc"
      }
    });
    request.headers.addAll(header);
    http.StreamedResponse response = await request.send();
    if(response.statusCode == 200) {
      var decode = json.decode(await response.stream.bytesToString())['result'];
      if(decode['status'] == true) {
        List data = decode['data']['result'];
        setState(() {
          _isLoading = false;
        });
        prayerData = data;
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
    if(expiryDateTime!.isAfter(currentDateTime)) {
      setState(() {
        getPrayersData();
      });
    } else {
      setState(() {
        shared.clearSharedPreferenceData(context);
      });
    }
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
            'Prayer Requests',
            style: TextStyle(
              fontSize: size.height * 0.02,
              fontWeight: FontWeight.bold,
              color: whiteColor,
            ),
          ),
          centerTitle: true,
          flexibleSpace: Container(
            decoration: const BoxDecoration(
                gradient: LinearGradient(
                    colors: [
                      primaryColor,
                      secondaryColor
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight
                )
            ),
          ),
          // backgroundColor: backgroundColor,
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
          ) : prayerData.isNotEmpty ? SlideFadeAnimation(
            duration: const Duration(seconds: 1),
            child: SingleChildScrollView(
              child: Column(
                children: [
                  SizedBox(height: size.height * 0.01,),
                  ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: prayerData.length,
                    itemBuilder: (BuildContext context, int index) {
                      return GestureDetector(
                        onTap: () {
                          name = prayerData[index]['name'];
                          date = prayerData[index]['date'];
                          mobile = prayerData[index]['mobile'];
                          email = prayerData[index]['email'];
                          note = prayerData[index]['note'];
                          setState(() {
                            Navigator.push(context, MaterialPageRoute(builder: (context) {return PrayerDetailScreen(name: name, date: date, mobile: mobile, email: email, note: note,);}));
                          });
                        },
                        child: Card(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15.0),
                          ),
                          child: Container(
                            padding: const EdgeInsets.only(left: 10, top: 10, right: 10, bottom: 10),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Flexible(child: Text("${prayerData[index]['name']}", style: GoogleFonts.roboto(fontWeight: FontWeight.bold, fontSize: size.height * 0.02, color: valueColor),),),
                                  ],
                                ),
                                prayerData[index]['note'] != null && prayerData[index]['note'] != '' && prayerData[index]['note'] != '' ? SizedBox(height: size.height * 0.01,) : Container(),
                                prayerData[index]['note'] != null && prayerData[index]['note'] != '' && prayerData[index]['note'] != '' ? Row(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    Flexible(child: Text("${prayerData[index]['note']}", maxLines: 2, overflow: TextOverflow.ellipsis, style: TextStyle(fontSize: size.height * 0.016, color: Colors.black54),),),
                                  ],
                                ) : Container(),
                                SizedBox(height: size.height * 0.01,),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: [
                                    const Icon(Icons.access_time, color: hiLightColor, size: 20,),
                                    SizedBox(width: size.width * 0.02,),
                                    Text(prayerData[index]['date'], style: GoogleFonts.sansita(fontSize: size.height * 0.018, color: hiLightColor),),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ],
              ),
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
