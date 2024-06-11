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

import 'prayer_detail.dart';

class ParishPrayerListScreen extends StatefulWidget {
  const ParishPrayerListScreen({Key? key}) : super(key: key);

  @override
  State<ParishPrayerListScreen> createState() => _ParishPrayerListScreenState();
}

class _ParishPrayerListScreenState extends State<ParishPrayerListScreen> {
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
      "params": selectedTab != 'All' ? {
        "filter": "[['parish_id','=',$parishID],['type','=','$requestTab'],['status','=','$selectedTab']]",
        "query": "{name,date,liturgy_calendar_id,create_date,intention_type_ids,email,mobile,amount,note,status}",
        "order": "date desc"
      } : {
        "filter": "[['parish_id','=',$parishID],['type','=','$requestTab']]",
        "query": "{name,date,liturgy_calendar_id,create_date,intention_type_ids,email,mobile,amount,note,status}",
        "order": "date desc"
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
    getPrayersData();
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
                        child: Stack(
                          children: [
                            Card(
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
                                        Flexible(child: Text("${prayerData[index]['name']}", style: GoogleFonts.roboto(fontWeight: FontWeight.bold, fontSize: size.height * 0.02, color: textHeadColor),),),
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
                                        const Icon(Icons.access_time, color: iconColor, size: 20,),
                                        SizedBox(width: size.width * 0.02,),
                                        Text(prayerData[index]['date'], style: GoogleFonts.sansita(fontSize: size.height * 0.018, color: blackColor),),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            Positioned(
                              bottom: 5,
                              left: 8,
                              child: Container(
                                alignment: Alignment.topRight,
                                child: Row(
                                    children: [
                                      selectedTab == 'All' ? Container(
                                        padding: const EdgeInsets.all(5),
                                        decoration: BoxDecoration(
                                          borderRadius: const BorderRadius.only(topRight: Radius.circular(5), topLeft: Radius.circular(5), bottomRight: Radius.circular(5), bottomLeft: Radius.circular(10)),
                                          color: prayerData[index]['status'] == 'Requested' ? orangeColor : greenColor,
                                        ),
                                        child: Text('${prayerData[index]['status']}',style: GoogleFonts.secularOne(color: statusTextColor),),
                                      ) : Container(),
                                    ]
                                ),
                              ),
                            ),
                          ],
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
