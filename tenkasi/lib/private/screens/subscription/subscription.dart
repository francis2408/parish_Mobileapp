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

class SubscriptionScreen extends StatefulWidget {
  final String name;
  const SubscriptionScreen({Key? key, required this.name}) : super(key: key);

  @override
  State<SubscriptionScreen> createState() => _SubscriptionScreenState();
}

class _SubscriptionScreenState extends State<SubscriptionScreen> {
  final ClearSharedPreference shared = ClearSharedPreference();
  List<Map<String, dynamic>> subscription = [];
  List<Map<String, dynamic>> pendingAmount = [];
  List<String> year = [];
  var totalAmount;
  var pending;
  String? _selectedYear;
  bool _isLoading = true;
  bool _isExpand = false;

  getSubscriptionData() async {
    var request = http.Request('GET', Uri.parse('$baseUrl/res.subscription/get_subscription_details'));
    request.body = json.encode({
      "params": {
        "args":[int.parse(familyId)],
      }
    });
    request.headers.addAll(header);
    http.StreamedResponse response = await request.send();
    if(response.statusCode == 200) {
      var decode = json.decode(await response.stream.bytesToString());
      var data = decode['result'];
      setState(() {
        _isLoading = false;
        if (data.isNotEmpty) {
          totalAmount = data[0]['total_due_amount'];
          pendingAmount = List<Map<String, dynamic>>.from(data[0]['yearly_wise_due_amount']);
          subscription = List<Map<String, dynamic>>.from(data[0]['subscription']);
          year = List<String>.from(data[0]['years'].map((item) => item['year'].toString()));
          year.sort((a, b) => b.compareTo(a));
          if (year.isNotEmpty) {
            _selectedYear = year.first;
          }
        }
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

  List<Map<String, dynamic>> getFilteredSubscription(String year) {
    return subscription.where((item) => item['year'].toString() == year).toList();
  }

  List<Map<String, dynamic>> getFilteredYear(String year) {
    var filteredList = pendingAmount.where((item) => item['year'].toString() == year).toList();
    if (filteredList.isEmpty) {
      return [
        {"year": "$_selectedYear", "amount": ""}
      ];
    }
    return filteredList;
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
      getSubscriptionData();
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
            "${widget.name} Subscription",
            style: TextStyle(
              fontSize: size.height * 0.02,
              fontWeight: FontWeight.bold,
              color: whiteColor,
            ),
          ),
          centerTitle: true,
          backgroundColor: appBackgroundColor,
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
          ) : subscription.isNotEmpty && subscription != [] ? SingleChildScrollView(
            child: SlideFadeAnimation(
              duration: const Duration(seconds: 1),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Card(
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10)
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(8),
                      child: Row(
                        children: [
                          Text('Total due amount', style: TextStyle(color: Colors.teal, fontSize: size.height * 0.02, fontWeight: FontWeight.bold),),
                          Padding(
                            padding: EdgeInsets.only(left: size.width * 0.3, right: 20),
                            child: Text(totalAmount.toString(), style: TextStyle(color: Colors.red, fontSize: size.height * 0.02, fontWeight: FontWeight.bold),),
                          ),
                        ],
                      ),
                    ),
                  ),
                  Card(
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10)
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(8),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Container(
                            width: size.width * 0.47,
                            alignment: Alignment.center,
                            child: DropdownButton<String>(
                              hint: const Text('Subscription Year', style: TextStyle(color: blackColor),),
                              underline: Container(
                                height: 2,
                                color: Colors.transparent,
                              ),
                              items: const [],
                              onChanged: (value) {},
                              icon: const SizedBox.shrink(),
                            ),
                          ),
                          Container(
                            width: size.width * 0.47,
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(10),
                              color: Colors.teal,
                              boxShadow: <BoxShadow>[
                                BoxShadow(
                                  color: Colors.grey.withOpacity(0.5),
                                  spreadRadius: 0.3,
                                  blurRadius: 3,
                                  offset: const Offset(2, 2),
                                ),
                              ],
                            ),
                            child: DropdownButton<String>(
                              hint: const Text("Select Year", style: TextStyle(color: whiteColor)),
                              value: _selectedYear,
                              underline: Container(
                                height: 2,
                                color: Colors.transparent,
                              ),
                              items: year.map<DropdownMenuItem<String>>((String value) {
                                return DropdownMenuItem<String>(
                                  value: value,
                                  child: Text(value),
                                );
                              }).toList(),
                              iconDisabledColor: whiteColor,
                              iconEnabledColor: whiteColor,
                              onChanged: (value) {
                                setState(() {
                                  _selectedYear = value;
                                });
                              },
                              selectedItemBuilder: (BuildContext context) {
                                return year.map<DropdownMenuItem<String>>((String value) {
                                  return DropdownMenuItem<String>(
                                    value: value,
                                    child: Text(value, style: TextStyle(color: whiteColor, fontSize: size.height * 0.018, fontWeight: FontWeight.bold),),
                                  );
                                }).toList();
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  Card(
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10)
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(8),
                      child: Table(
                        defaultVerticalAlignment: TableCellVerticalAlignment.top,
                        children: [
                          TableRow(
                            decoration: const BoxDecoration(
                              color: Colors.teal,
                            ),
                            children: [
                              TableCell(
                                verticalAlignment: TableCellVerticalAlignment.middle,
                                child: Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Text(
                                    'Month',
                                    style: GoogleFonts.signika(fontSize: size.height * 0.02, fontWeight: FontWeight.w700, color: whiteColor),
                                  ),
                                ),
                              ),
                              TableCell(
                                verticalAlignment: TableCellVerticalAlignment.middle,
                                child: Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Text(
                                    'Amount',
                                    style: GoogleFonts.signika(fontSize: size.height * 0.02, fontWeight: FontWeight.w700, color: whiteColor),
                                  ),
                                ),
                              ),
                              TableCell(
                                verticalAlignment: TableCellVerticalAlignment.middle,
                                child: Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Text(
                                    'Status',
                                    style: GoogleFonts.signika(fontSize: size.height * 0.02, fontWeight: FontWeight.w700, color: whiteColor),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          ...getFilteredSubscription(_selectedYear!).map((subscription) => TableRow(
                              decoration: BoxDecoration(
                                border: Border(
                                  bottom: BorderSide(
                                    color: Colors.black.withOpacity(0.5),
                                    width: 0.5,
                                  ),
                                ),
                              ),
                              children: [
                                TableCell(
                                  verticalAlignment: TableCellVerticalAlignment.middle,
                                  child: Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Text(
                                      subscription['month'],
                                      style: TextStyle(
                                        fontSize: size.height * 0.018,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                  ),
                                ),
                                TableCell(
                                  verticalAlignment: TableCellVerticalAlignment.middle,
                                  child: Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Text(
                                      subscription['amount'].toString(),
                                      style: TextStyle(
                                        fontSize: size.height * 0.018,
                                        fontWeight: FontWeight.w700,
                                        color: valueColor,
                                      ),
                                    ),
                                  ),
                                ),
                                TableCell(
                                  verticalAlignment: TableCellVerticalAlignment.middle,
                                  child: Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Text(
                                      subscription['status'],
                                      style: TextStyle(
                                        fontSize: size.height * 0.018,
                                        fontWeight: FontWeight.w700,
                                        color: subscription['status'] == 'Due'
                                            ? Colors.red
                                            : Colors.green,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),).toList(),
                        ],
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(10),
                    child: Row(
                      // mainAxisAlignment: MainAxisAlignment.sp,
                      children: [
                        Text(
                          '$_selectedYear due amount',
                          style: TextStyle(
                            fontSize: size.height * 0.02,
                            fontWeight: FontWeight.bold,
                            color: textHeadColor,
                          ),
                        ),
                      ...getFilteredYear(_selectedYear!).map((pending) => Padding(
                        padding: EdgeInsets.only(left: size.width * 0.3, right: 20),
                        child: Text(
                            pending['amount'] != '' ? pending['amount'].toString() : 'No dues',
                            style: TextStyle(
                              fontSize: size.height * 0.018,
                              fontWeight: FontWeight.w700,
                              color: valueColor,
                            ),
                          ),
                      ),).toList(),
                      ],
                    ),
                  ),
                  SizedBox(
                    height: size.height * 0.01,
                  ),
                ],
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
      ),
    );
  }
}
