import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_widget_from_html/flutter_widget_from_html.dart';
import 'package:http/http.dart' as http;
import 'package:loading_indicator/loading_indicator.dart';
import 'package:perambur/widget/common/common.dart';
import 'package:perambur/widget/common/internet_connection_checker.dart';
import 'package:perambur/widget/common/slide_animations.dart';
import 'package:perambur/widget/theme_color/theme_color.dart';
import 'package:perambur/widget/widget.dart';

class PublicParishHistoryScreen extends StatefulWidget {
  const PublicParishHistoryScreen({Key? key}) : super(key: key);

  @override
  State<PublicParishHistoryScreen> createState() => _PublicParishHistoryScreenState();
}

class _PublicParishHistoryScreenState extends State<PublicParishHistoryScreen> {
  bool _isLoading = true;
  List parish = [];
  RegExp exp = RegExp(r"<[^>]*>",multiLine: true,caseSensitive: true);

  getParishData() async {
    var request = http.Request('GET', Uri.parse('$baseUrl/public/$parishID/parish_details'));
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
        parish = data;
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
    getParishData();
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Scaffold(
      backgroundColor: screenBackgroundColor,
      body: SlideFadeAnimation(
        duration: const Duration(seconds: 1),
        child: _isLoading ? Center(
          child: SizedBox(
            height: size.height * 0.06,
            child: const LoadingIndicator(
              indicatorType: Indicator.ballPulse,
              colors: [Colors.red,Colors.yellow,Colors.green],
            ),
          ),
        ) : ListView.builder(
          itemCount: parish.length,
          itemBuilder: (BuildContext context, int index) {
            return parish[0]['history'] != null && parish[0]['history'].trim().isNotEmpty && parish[0]['history'].replaceAll(exp, '') != null && parish[0]['history'].replaceAll(exp, '') != ''
                ? Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
              ),
              child: HtmlWidget(
                parish[0]['history'],
                customStylesBuilder: (element) {
                  if (element.localName == 'p') {
                    return {
                      'lineHeight': '1.3',
                      'textAlign': 'justify',
                    };
                  }
                  return null;
                },
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
            );
          },
        ),
      ),
    );
  }
}
