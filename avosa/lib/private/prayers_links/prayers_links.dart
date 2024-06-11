import 'dart:convert';

import 'package:avosa/widget/common/common.dart';
import 'package:avosa/widget/common/internet_connection_checker.dart';
import 'package:avosa/widget/common/slide_animations.dart';
import 'package:avosa/widget/theme_color/theme_color.dart';
import 'package:avosa/widget/widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:loading_indicator/loading_indicator.dart';
import 'package:url_launcher/url_launcher.dart';

class PrayersAndLinksScreen extends StatefulWidget {
  const PrayersAndLinksScreen({Key? key}) : super(key: key);

  @override
  State<PrayersAndLinksScreen> createState() => _PrayersAndLinksScreenState();
}

class _PrayersAndLinksScreenState extends State<PrayersAndLinksScreen> {
  bool _isLoading = true;
  List prayers = [];
  RegExp exp = RegExp(r"<[^>]*>",multiLine: true,caseSensitive: true);

  getMassTimingData() async {
    var request = http.Request('GET', Uri.parse('$baseUrl/prayer/links'));
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
      prayers = decode;
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
            'Prayers & Links',
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
          ) : prayers.isNotEmpty ? SlideFadeAnimation(
            duration: const Duration(seconds: 1),
            child: SingleChildScrollView(
              child: ListView.builder(
                  key: UniqueKey(),
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: prayers.length,
                  itemBuilder: (BuildContext context, int index) {
                    return Column(
                      children: [
                        SizedBox(height: size.height * 0.005,),
                        GestureDetector(
                          onTap: () {
                            showModalBottomSheet<void>(
                              context: context,
                              backgroundColor: screenBackgroundColor,
                              transitionAnimationController: AnimationController(
                                vsync: Navigator.of(context),
                                duration: const Duration(seconds: 1),
                              ),
                              shape: const RoundedRectangleBorder(
                                borderRadius: BorderRadius.vertical(top: Radius.circular(20.0)),
                              ),
                              builder: (BuildContext context) {
                                return CustomContentBottomSheet(
                                  title: "Description",
                                  content: _highlightHttpLink(prayers[index]['description']),
                                );
                              },
                            );
                          },
                          child: Card(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(15),
                            ),
                            child: Container(
                              padding: const EdgeInsets.only(left: 10, top: 5, bottom: 5),
                              child: Row(
                                children: [
                                  Container(
                                    height: size.height * 0.06,
                                    width: size.width * 0.13,
                                    decoration: BoxDecoration(
                                      color: Colors.orange.shade200.withOpacity(0.6),
                                      shape: BoxShape.rectangle,
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: Center(
                                        child: IconButton(
                                          icon: SvgPicture.asset("assets/icons/prayer.svg", color: Colors.orange.shade700.withOpacity(0.8)),
                                          iconSize: 60,
                                          onPressed: () {},
                                        )
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
                                                  prayers[index]['name'],
                                                  style: GoogleFonts.roboto(
                                                    fontSize: size.height * 0.02,
                                                    color: textHeadColor,
                                                    fontWeight: FontWeight.w700,
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                          SizedBox(height: size.height * 0.01,),
                                          prayers[index]['description'] != null && prayers[index]['description'] != '' && prayers[index]['description'].replaceAll(exp, '') != '' ? Row(
                                            crossAxisAlignment: CrossAxisAlignment.end,
                                            children: [
                                              Flexible(
                                                child: Text(
                                                  prayers[index]['description'].replaceAll(exp, ''),
                                                  maxLines: 2,
                                                  overflow: TextOverflow.ellipsis,
                                                  style: TextStyle(fontSize: size.height * 0.016, color: labelColor),
                                                  textAlign: TextAlign.justify,
                                                ),
                                              ),
                                              SizedBox(width: size.width * 0.01,),
                                              prayers[index]['description'].replaceAll(exp, '').length >= 80 ? Container(
                                                  alignment: Alignment.topRight,
                                                  child: Row(
                                                    mainAxisAlignment: MainAxisAlignment.end,
                                                    children: [
                                                      const Text('More', style: TextStyle(
                                                          color: mobileText
                                                      ),),
                                                      SizedBox(width: size.width * 0.018,),
                                                      const Icon(Icons.arrow_forward_ios, color: mobileText, size: 11,)
                                                    ],
                                                  )
                                              ) : Container()
                                            ],
                                          ) : Row(
                                            children: [
                                              Flexible(
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

  String _highlightHttpLink(String content) {
    // Regular expression to find URLs
    RegExp urlRegex = RegExp(
        r'(https?://\S+)');

    // Replace URLs with anchor tags
    String highlightedContent =
    content.replaceAllMapped(urlRegex, (match) {
      String url = match.group(0)!;
      return '<a href="$url">$url</a>';
    });

    return highlightedContent;
  }
}
