import 'dart:convert';

import 'package:avosa/widget/common/common.dart';
import 'package:avosa/widget/common/internet_connection_checker.dart';
import 'package:avosa/widget/theme_color/theme_color.dart';
import 'package:avosa/widget/widget.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:loading_indicator/loading_indicator.dart';

class VehicleBlessingsScreen extends StatefulWidget {
  const VehicleBlessingsScreen({Key? key}) : super(key: key);

  @override
  State<VehicleBlessingsScreen> createState() => _VehicleBlessingsScreenState();
}

class _VehicleBlessingsScreenState extends State<VehicleBlessingsScreen> {
  bool _isLoading = true;
  List blessing = [];

  getBlessingData() async {
    var request = http.Request('GET', Uri.parse('$baseUrl/prayer/services/Vehicle Blessing'));
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
      blessing = decode;
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
    getBlessingData();
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
        ) : blessing.isNotEmpty ? Card(
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
                          'Day',
                          style: GoogleFonts.signika(fontSize: size.height * 0.02, fontWeight: FontWeight.w700, color: whiteColor),
                        ),
                      ),
                    ),
                    TableCell(
                      verticalAlignment: TableCellVerticalAlignment.middle,
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(
                          'Morning',
                          style: GoogleFonts.signika(fontSize: size.height * 0.02, fontWeight: FontWeight.w700, color: whiteColor),
                        ),
                      ),
                    ),
                    TableCell(
                      verticalAlignment: TableCellVerticalAlignment.middle,
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(
                          'Evening',
                          style: GoogleFonts.signika(fontSize: size.height * 0.02, fontWeight: FontWeight.w700, color: whiteColor),
                        ),
                      ),
                    ),
                  ],
                ),
                ...List.generate(blessing.length, (index) => TableRow(
                  decoration: BoxDecoration(
                    border: Border(
                      bottom: BorderSide(color: blackColor.withOpacity(0.5), width: 0.5),
                    ),
                  ),
                  children: [
                    TableCell(
                      verticalAlignment: TableCellVerticalAlignment.middle,
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(
                          '${blessing[index]['day']}',
                          style: TextStyle(fontSize: size.height * 0.018, fontWeight: FontWeight.w700),
                        ),
                      ),
                    ),
                    TableCell(
                      verticalAlignment: TableCellVerticalAlignment.middle,
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(
                          '${blessing[index]['morning_hour']}',
                          style: TextStyle(fontSize: size.height * 0.018, fontWeight: FontWeight.w700, color: labelColor2),
                        ),
                      ),
                    ),
                    TableCell(
                      verticalAlignment: TableCellVerticalAlignment.middle,
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(
                          '${blessing[index]['evening_hour']}',
                          style: TextStyle(fontSize: size.height * 0.018, fontWeight: FontWeight.w700, color: labelColor2),
                        ),
                      ),
                    ),
                  ],
                )),
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
                  Navigator.pop(context, 'refresh');
                });
              },
              text: 'No Data available',
            ),
          ),
        ),
      ),
    );
  }
}
