import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:loading_indicator/loading_indicator.dart';
import 'package:perambur/widget/common/common.dart';
import 'package:perambur/widget/common/internet_connection_checker.dart';
import 'package:perambur/widget/common/slide_animations.dart';
import 'package:perambur/widget/theme_color/theme_color.dart';
import 'package:perambur/widget/widget.dart';

import 'saints_detail_screen.dart';

class PublicTodaySaintsScreen extends StatefulWidget {
  const PublicTodaySaintsScreen({Key? key}) : super(key: key);

  @override
  State<PublicTodaySaintsScreen> createState() => _PublicTodaySaintsScreenState();
}

class _PublicTodaySaintsScreenState extends State<PublicTodaySaintsScreen> {
  bool _isLoading = true;
  List saint = [];
  int selected = -1;

  RegExp exp = RegExp(r"<[^>]*>",multiLine: true,caseSensitive: true);
  final format = DateFormat("dd-MM-yyyy");

  getSaintsData() async {
    var todayDay = DateFormat("d").format(DateTime.now());
    var todayMonth = DateFormat("M").format(DateTime.now());
    var request = http.Request('GET', Uri.parse('$baseUrl/public/masters/res.saints'));
    request.body = json.encode({
      "params": {
        "filter": "[('feast_day','=',$todayDay),('feast_month','=',$todayMonth)]",
        "query": "{name,description,feast_day,feast_month,year_of_birth,year_of_death,image_512}"
      }
    });
    request.headers.addAll(headers);
    http.StreamedResponse response = await request.send();
    if (response.statusCode == 200) {
      var decode = json.decode(await response.stream.bytesToString())['result'];
      if(decode['status'] == 'success') {
        List data = decode['result'];
        setState(() {
          _isLoading = false;
        });
        saint = data;
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
    getSaintsData();
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
          ) : saint.isNotEmpty ? Column(
            children: [
              SizedBox(
                height: size.height * 0.01,
              ),
              Expanded(
                child: SlideFadeAnimation(
                  duration: const Duration(seconds: 1),
                  child: SingleChildScrollView(
                    child: ListView.builder(
                        key: Key('builder ${selected.toString()}'),
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: saint.length,
                        itemBuilder: (BuildContext context, int index) {
                          return Column(
                            children: [
                              Padding(
                                padding: const EdgeInsets.only(left: 5, right: 5),
                                child: GestureDetector(
                                  onTap: () {
                                    setState(() {
                                      Navigator.push(context, MaterialPageRoute(builder: (context) {return PublicSaintsDetailsScreen(image: saint[index]['image_512'], name: saint[index]['name'], birth: saint[index]['year_of_birth'], death: saint[index]['year_of_death'], feastDay: saint[index]['feast_day'], feastMonth: saint[index]['feast_month_label'], description: saint[index]['description']);}));
                                    });
                                  },
                                  child: Card(
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(15),
                                    ),
                                    child: Row(
                                      children: [
                                        GestureDetector(
                                          onTap: () {
                                            saint[index]['image_512'] != '' ? showDialog(
                                              context: context,
                                              builder: (BuildContext context) {
                                                return Dialog(
                                                  child: Image.network(saint[index]['image_512'], fit: BoxFit.cover,),
                                                );
                                              },
                                            ) : showDialog(
                                              context: context,
                                              builder: (BuildContext context) {
                                                return Dialog(
                                                  child: Image.asset('assets/images/no_image.jpg', fit: BoxFit.cover,),
                                                );
                                              },
                                            );
                                          },
                                          child: Container(
                                            height: size.height * 0.11,
                                            width: size.width * 0.22,
                                            decoration: BoxDecoration(
                                              borderRadius: const BorderRadius.only(topLeft: Radius.circular(15), bottomLeft: Radius.circular(15)),
                                              shape: BoxShape.rectangle,
                                              image: DecorationImage(
                                                fit: BoxFit.fill,
                                                image: saint[index]['image_512'] != null && saint[index]['image_512'] != ''
                                                    ? NetworkImage(saint[index]['image_512'])
                                                    : const AssetImage('assets/images/no_image.jpg') as ImageProvider,
                                              ),
                                            ),
                                          ),
                                        ),
                                        Expanded(
                                          child: Container(
                                            padding: const EdgeInsets.only(left: 15, right: 10),
                                            child: Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                Row(
                                                  children: [
                                                    Flexible(
                                                      child: Text(
                                                        saint[index]['name'],
                                                        style: GoogleFonts.secularOne(
                                                          fontSize: size.height * 0.02,
                                                          color: textColor,
                                                        ),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                                SizedBox(
                                                  height: size.height * 0.005,
                                                ),
                                                Row(
                                                  children: [
                                                    saint[index]['feast_day'] != '' && saint[index]['feast_day'] != null ? Text(
                                                      saint[index]['feast_day'],
                                                      style: GoogleFonts.roboto(
                                                        fontSize: size.height * 0.018,
                                                        color: textHeadColor,
                                                      ),
                                                    ) : Container(),
                                                    saint[index]['feast_day'] != '' && saint[index]['feast_day'] != null ? Text(
                                                      ' - ',
                                                      style: GoogleFonts.roboto(
                                                        fontSize: size.height * 0.018,
                                                        color: textHeadColor,
                                                      ),
                                                    ) : Container(),
                                                    Text(
                                                      saint[index]['feast_month_label'],
                                                      style: GoogleFonts.roboto(
                                                        fontSize: size.height * 0.018,
                                                        color: textHeadColor,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                                SizedBox(
                                                  height: size.height * 0.005,
                                                ),
                                                Row(
                                                  children: [
                                                    saint[index]['description'] != null && saint[index]['description'] != '' && saint[index]['description'].replaceAll(exp, '') != '' ? Flexible(
                                                      child: Text(
                                                        saint[index]['description'].replaceAll(exp, ''),
                                                        maxLines: 2,
                                                        overflow: TextOverflow.ellipsis,
                                                        style: TextStyle(fontSize: size.height * 0.016, color: labelColor),
                                                        textAlign: TextAlign.justify,
                                                      ),
                                                    ) : Flexible(
                                                      child: Text(
                                                        "No Description available",
                                                        style: TextStyle(
                                                          letterSpacing: 0.5,
                                                          fontSize: size.height * 0.017,
                                                          color: Colors.grey,
                                                          fontStyle: FontStyle.italic,
                                                        ),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ],
                                            ),
                                          ),
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
                ),
              ),
            ],
          ) : Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.only(left: 30, right: 30),
                  child: NoResult(
                    onPressed: () {
                      setState(() {
                        Navigator.pop(context, 'refresh');
                      });
                    },
                    text: 'No Data available',
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
