import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:http/http.dart' as http;
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:loading_indicator/loading_indicator.dart';
import 'package:tenkasi/widget/common/common.dart';
import 'package:tenkasi/widget/common/internet_connection_checker.dart';
import 'package:tenkasi/widget/common/slide_animations.dart';
import 'package:tenkasi/widget/theme_color/theme_color.dart';
import 'package:tenkasi/widget/widget.dart';

class AllEventScreen extends StatefulWidget {
  const AllEventScreen({Key? key}) : super(key: key);

  @override
  State<AllEventScreen> createState() => _AllEventScreenState();
}

class _AllEventScreenState extends State<AllEventScreen> {
  bool _isLoading = true;
  List eventData = [];
  int selected = -1;

  DateTime currentDateTime = DateTime.now();
  DateTime utc = DateTime.now().toUtc();
  String nowDate = '';
  String dateValue = '';
  String day = '';

  RegExp exp = RegExp(r"<[^>]*>",multiLine: true,caseSensitive: true);

  getEventData() async {
    var request = http.Request('GET', Uri.parse('$baseUrl/public/$parishID/calendar.event'));
    String today = DateFormat('yyyy-MM-dd 00:00:00').format(DateTime.now());
    // Finding the end date of the current week
    DateTime weekEndDateTime = currentDateTime.add(Duration(days: DateTime.daysPerWeek - currentDateTime.weekday));
    String weekEndDate = DateFormat('yyyy-MM-dd 23:59:59').format(weekEndDateTime);
    // Finding the start date of the current month
    DateTime monthStartDateTime = DateTime(currentDateTime.year, currentDateTime.month, 1);
    String monthStartDate = DateFormat('yyyy-MM-dd 00:00:00').format(monthStartDateTime);
    // Finding the end date of the current month
    DateTime monthEndDateTime = DateTime(currentDateTime.year, currentDateTime.month + 1, 0);
    String monthEndDate = DateFormat('yyyy-MM-dd 23:59:59').format(monthEndDateTime);

    request.body = json.encode({
      "params": {
        "filter": selectedTab == "This Week" ? "[['category','=','Calendar'],['start','>=','$today'],['stop','<=','$weekEndDate']]" : selectedTab == "This Month" ? "[['category','=','Calendar'],['start','>=','$monthStartDate'],['stop','<=','$monthEndDate']]" : "[['category','=','Calendar']]",
        "query": "{id,name,start,stop,duration,start_date,stop_date,allday,type,location,description,session}",
        "order": selectedTab == "All" ? "start asc" : selectedTab == "This Month" ? "start asc" : "start asc"
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
        eventData = data;
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
    super.initState();
    getEventData();
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
        ) : eventData.isNotEmpty ? Container(
          padding: const EdgeInsets.only(left: 5, right: 5),
          child: Column(
            children: [
              SizedBox(
                height: size.height * 0.01,
              ),
              Expanded(
                child: SingleChildScrollView(
                  child: ListView.builder(
                    key: Key('builder ${selected.toString()}'),
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: eventData.length,
                    itemBuilder: (BuildContext context, int index) {
                      DateTime currentDate;
                      DateTime parsedDate;
                      if(eventData[index]['allday'] != true) {
                        final String dateString = eventData[index]['start'];
                        final DateTime date = DateFormat('dd-MM-yyyy hh:mm a').parse(dateString);
                        DateTime today = DateTime.now();
                        final DateFormat formatter = DateFormat('dd-MM-yyyy');
                        dateValue = formatter.format(date);
                        nowDate = formatter.format(today);
                        currentDate = today;
                        parsedDate = DateFormat('dd-MM-yyyy').parse(dateValue);
                        final DateFormat dayFormat = DateFormat('EEEE');
                        day = dayFormat.format(date);
                      } else {
                        final String dateString = eventData[index]['start_date'];
                        final DateTime date = DateFormat('dd-MM-yyyy').parse(dateString);
                        DateTime today = DateTime.now();
                        nowDate = DateFormat('dd-MM-yyyy').format(today);
                        final DateFormat formatter = DateFormat('dd-MM-yyyy');
                        dateValue = formatter.format(date);
                        currentDate = today;
                        parsedDate = DateFormat('dd-MM-yyyy').parse(dateValue);
                      }
                      return SlideFadeAnimation(
                        duration: const Duration(seconds: 1),
                        child: eventData[index]['allday'] != true ? Column(
                          children: [
                            if(nowDate == dateValue) Card(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(15.0),
                              ),
                              child: Container(
                                padding: const EdgeInsets.all(10),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      '${eventData[index]['name']}',
                                      style: GoogleFonts.signika(
                                        fontSize: size.height * 0.022,
                                        color: textHeadColor,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                    SizedBox(
                                      height: size.height * 0.01,
                                    ),
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Row(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            const Icon(Icons.calendar_month, color: iconColor,),
                                            SizedBox(width: size.width * 0.01,),
                                            RichText(
                                              textAlign: TextAlign.left,
                                              text: TextSpan(
                                                text: DateFormat('dd MMMM, yyyy hh:mm a').format(DateFormat('dd-MM-yyyy hh:mm a').parse(eventData[index]['start'])),
                                                style: GoogleFonts.signika(
                                                  color: textColor,
                                                  fontSize: size.height * 0.021,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                        Text(
                                          DateFormat('EEEE').format(DateFormat('dd-MM-yyyy hh:mm a').parse(eventData[index]['start'])),
                                          style: GoogleFonts.signika(
                                            color: blackColor,
                                            fontSize: size.height * 0.021,
                                          ),
                                        ),
                                      ],
                                    ),
                                    SizedBox(
                                      height: size.height * 0.01,
                                    ),
                                    Row(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        const Icon(Icons.location_on, color: iconColor,),
                                        SizedBox(width: size.width * 0.01,),
                                        eventData[index]['location'] != '' && eventData[index]['location'] != null ? Flexible(child: Text('${eventData[index]['location']}', style: GoogleFonts.signika(color: Colors.black87, fontSize: size.height * 0.02),)) : Text("-", style: GoogleFonts.signika(fontSize: size.height * 0.02, color: Colors.grey, fontStyle: FontStyle.italic),),
                                      ],
                                    ),
                                    eventData[index]['description'].replaceAll(exp, '') != null && eventData[index]['description'].replaceAll(exp, '') != '' ? SizedBox(height: size.height * 0.01,) : Container(),
                                    eventData[index]['description'].replaceAll(exp, '') != null && eventData[index]['description'].replaceAll(exp, '') != '' ? Row(
                                      crossAxisAlignment: CrossAxisAlignment.end,
                                      children: [
                                        Flexible(
                                          child: Text(
                                            eventData[index]['description'].replaceAll(exp, ''),
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                            style: TextStyle(fontSize: size.height * 0.018),
                                          ),
                                        ),
                                        SizedBox(width: size.width * 0.01,),
                                        GestureDetector(
                                          onTap: () {
                                            showDialog(
                                              context: context,
                                              builder: (BuildContext context) {
                                                return Card(
                                                  shape: RoundedRectangleBorder(
                                                      borderRadius: BorderRadius.circular(15)
                                                  ),
                                                  child: Container(
                                                    padding: const EdgeInsets.all(10),
                                                    child: Column(
                                                      children: [
                                                        Row(
                                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                          children: [
                                                            Text("Content", style: GoogleFonts.signika(fontSize: size.height * 0.025, color: backgroundColor),),
                                                            IconButton(
                                                              icon: const Icon(Icons.close, color: Colors.redAccent,),
                                                              onPressed: () {
                                                                Navigator.pop(context);
                                                              },
                                                            ),
                                                          ],
                                                        ),
                                                        SizedBox(
                                                          height: size.height * 0.01,
                                                        ),
                                                        Expanded(
                                                          child: SingleChildScrollView(
                                                            child: Html(
                                                              data: eventData[index]['description'],
                                                            ),
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                );
                                              },
                                            );
                                          },
                                          child: eventData[index]['description'].replaceAll(exp, '').length >= 60 ? Container(
                                              alignment: Alignment.topRight,
                                              child: Row(
                                                mainAxisAlignment: MainAxisAlignment.end,
                                                children: [
                                                  const Text('More', style: TextStyle(
                                                      color: Colors.indigoAccent
                                                  ),),
                                                  SizedBox(width: size.width * 0.018,),
                                                  const Icon(Icons.arrow_forward_ios, color: Colors.indigoAccent, size: 11,)
                                                ],
                                              )
                                          ) : Container(),
                                        )
                                      ],
                                    ) : Container(),
                                  ],
                                ),
                              ),
                            )
                            // else if(currentDate.isBefore(parsedDate))
                            else if(nowDate != dateValue) Card(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(15.0),
                              ),
                              child: Container(
                                padding: const EdgeInsets.all(10),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      '${eventData[index]['name']}',
                                      style: GoogleFonts.signika(
                                        fontSize: size.height * 0.022,
                                        color: textHeadColor,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                    SizedBox(
                                      height: size.height * 0.01,
                                    ),
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Row(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            const Icon(Icons.calendar_month, color: iconColor,),
                                            SizedBox(width: size.width * 0.01,),
                                            RichText(
                                              textAlign: TextAlign.left,
                                              text: TextSpan(
                                                text: DateFormat('dd MMMM, yyyy hh:mm a').format(DateFormat('dd-MM-yyyy hh:mm a').parse(eventData[index]['start'])),
                                                style: GoogleFonts.signika(
                                                  color: textColor,
                                                  fontSize: size.height * 0.021,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                        Text(
                                          DateFormat('EEEE').format(DateFormat('dd-MM-yyyy hh:mm a').parse(eventData[index]['start'])),
                                          style: GoogleFonts.signika(
                                            color: blackColor,
                                            fontSize: size.height * 0.021,
                                          ),
                                        ),
                                      ],
                                    ),
                                    SizedBox(
                                      height: size.height * 0.01,
                                    ),
                                    Row(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        const Icon(Icons.location_on, color: iconColor,),
                                        SizedBox(width: size.width * 0.01,),
                                        eventData[index]['location'] != '' && eventData[index]['location'] != null ? Flexible(child: Text('${eventData[index]['location']}', style: GoogleFonts.signika(color: Colors.black87, fontSize: size.height * 0.02),)) : Text("-", style: GoogleFonts.signika(fontSize: size.height * 0.02, color: Colors.grey, fontStyle: FontStyle.italic),),
                                      ],
                                    ),
                                    eventData[index]['description'].replaceAll(exp, '') != null && eventData[index]['description'].replaceAll(exp, '') != '' ? SizedBox(height: size.height * 0.01,) : Container(),
                                    eventData[index]['description'].replaceAll(exp, '') != null && eventData[index]['description'].replaceAll(exp, '') != '' ? Row(
                                      crossAxisAlignment: CrossAxisAlignment.end,
                                      children: [
                                        Flexible(
                                          child: Text(
                                            eventData[index]['description'].replaceAll(exp, ''),
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                            style: TextStyle(fontSize: size.height * 0.018),
                                          ),
                                        ),
                                        SizedBox(width: size.width * 0.01,),
                                        GestureDetector(
                                          onTap: () {
                                            showDialog(
                                              context: context,
                                              builder: (BuildContext context) {
                                                return Card(
                                                  shape: RoundedRectangleBorder(
                                                      borderRadius: BorderRadius.circular(15)
                                                  ),
                                                  child: Container(
                                                    padding: const EdgeInsets.all(10),
                                                    child: Column(
                                                      children: [
                                                        Row(
                                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                          children: [
                                                            Text("Content", style: GoogleFonts.signika(fontSize: size.height * 0.025, color: backgroundColor),),
                                                            IconButton(
                                                              icon: const Icon(Icons.close, color: Colors.redAccent,),
                                                              onPressed: () {
                                                                Navigator.pop(context);
                                                              },
                                                            ),
                                                          ],
                                                        ),
                                                        SizedBox(
                                                          height: size.height * 0.01,
                                                        ),
                                                        Expanded(
                                                          child: SingleChildScrollView(
                                                            child: Html(
                                                              data: eventData[index]['description'],
                                                            ),
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                );
                                              },
                                            );
                                          },
                                          child: eventData[index]['description'].replaceAll(exp, '').length >= 60 ? Container(
                                              alignment: Alignment.topRight,
                                              child: Row(
                                                mainAxisAlignment: MainAxisAlignment.end,
                                                children: [
                                                  const Text('More', style: TextStyle(
                                                      color: Colors.indigoAccent
                                                  ),),
                                                  SizedBox(width: size.width * 0.018,),
                                                  const Icon(Icons.arrow_forward_ios, color: Colors.indigoAccent, size: 11,)
                                                ],
                                              )
                                          ) : Container(),
                                        )
                                      ],
                                    ) : Container(),
                                  ],
                                ),
                              ),
                            ) else Container(),
                          ],
                        ) : Column(
                          children: [
                            if(nowDate == dateValue) Card(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(15.0),
                              ),
                              child: Container(
                                padding: const EdgeInsets.all(10),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      '${eventData[index]['name']}',
                                      style: GoogleFonts.signika(
                                        fontSize: size.height * 0.022,
                                        color: textHeadColor,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                    SizedBox(
                                      height: size.height * 0.01,
                                    ),
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Row(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            const Icon(Icons.calendar_month, color: iconColor,),
                                            SizedBox(width: size.width * 0.01,),
                                            RichText(
                                              textAlign: TextAlign.left,
                                              text: TextSpan(
                                                  text: DateFormat('dd MMMM, yyyy').format(DateFormat('dd-MM-yyyy hh:mm a').parse(eventData[index]['start'])),
                                                  style: GoogleFonts.signika(
                                                    color: textColor,
                                                    fontSize: size.height * 0.021,
                                                  ),
                                                  children: eventData[index]['session'] != null && eventData[index]['session'] != '' ? [
                                                    const TextSpan(
                                                      text: '  ',
                                                    ),
                                                    TextSpan(
                                                      text: eventData[index]['session'],
                                                      style: GoogleFonts.signika(
                                                        color: textColor,
                                                        fontSize: size.height * 0.021,
                                                      ),
                                                    ),
                                                  ] : []
                                              ),
                                            ),
                                          ],
                                        ),
                                        Text(
                                          DateFormat('EEEE').format(DateFormat('dd-MM-yyyy hh:mm a').parse(eventData[index]['start'])),
                                          style: GoogleFonts.signika(
                                            color: blackColor,
                                            fontSize: size.height * 0.021,
                                          ),
                                        ),
                                      ],
                                    ),
                                    SizedBox(
                                      height: size.height * 0.01,
                                    ),
                                    Row(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        const Icon(Icons.location_on, color: iconColor,),
                                        SizedBox(width: size.width * 0.01,),
                                        eventData[index]['location'] != '' && eventData[index]['location'] != null ? Flexible(child: Text('${eventData[index]['location']}', style: GoogleFonts.signika(color: Colors.black87, fontSize: size.height * 0.02),)) : Text("-", style: GoogleFonts.signika(fontSize: size.height * 0.02, color: Colors.grey, fontStyle: FontStyle.italic),),
                                      ],
                                    ),
                                    eventData[index]['description'] != null && eventData[index]['description'] != '' ? SizedBox(height: size.height * 0.01,) : Container(),
                                    eventData[index]['description'] != null && eventData[index]['description'] != '' ? Row(
                                      crossAxisAlignment: CrossAxisAlignment.end,
                                      children: [
                                        Flexible(
                                          child: Text(
                                            eventData[index]['description'].replaceAll(exp, ''),
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                        SizedBox(width: size.width * 0.01,),
                                        GestureDetector(
                                          onTap: () {
                                            showDialog(
                                              context: context,
                                              builder: (BuildContext context) {
                                                return Card(
                                                  shape: RoundedRectangleBorder(
                                                      borderRadius: BorderRadius.circular(15)
                                                  ),
                                                  child: Container(
                                                    padding: const EdgeInsets.all(10),
                                                    child: Column(
                                                      children: [
                                                        Row(
                                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                          children: [
                                                            Text("Content", style: GoogleFonts.signika(fontSize: size.height * 0.025, color: backgroundColor),),
                                                            IconButton(
                                                              icon: const Icon(Icons.close, color: Colors.redAccent,),
                                                              onPressed: () {
                                                                Navigator.pop(context);
                                                              },
                                                            ),
                                                          ],
                                                        ),
                                                        SizedBox(
                                                          height: size.height * 0.01,
                                                        ),
                                                        Expanded(
                                                          child: SingleChildScrollView(
                                                            child: Html(
                                                              data: eventData[index]['description'],
                                                            ),
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                );
                                              },
                                            );
                                          },
                                          child: eventData[index]['description'].replaceAll(exp, '').length >= 60 ? Container(
                                              alignment: Alignment.topRight,
                                              child: Row(
                                                mainAxisAlignment: MainAxisAlignment.end,
                                                children: [
                                                  const Text('More', style: TextStyle(
                                                      color: Colors.indigoAccent
                                                  ),),
                                                  SizedBox(width: size.width * 0.018,),
                                                  const Icon(Icons.arrow_forward_ios, color: Colors.indigoAccent, size: 11,)
                                                ],
                                              )
                                          ) : Container(),
                                        )
                                      ],
                                    ) : Container(),
                                  ],
                                ),
                              ),
                            )
                            // else if(currentDate.isBefore(parsedDate))
                            else if(nowDate != dateValue) Card(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(15.0),
                              ),
                              child: Container(
                                padding: const EdgeInsets.all(10),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      '${eventData[index]['name']}',
                                      style: GoogleFonts.signika(
                                        fontSize: size.height * 0.022,
                                        color: textHeadColor,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                    SizedBox(
                                      height: size.height * 0.01,
                                    ),
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Row(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            const Icon(Icons.calendar_month, color: iconColor,),
                                            SizedBox(width: size.width * 0.01,),
                                            RichText(
                                              textAlign: TextAlign.left,
                                              text: TextSpan(
                                                  text: DateFormat('dd MMMM, yyyy').format(DateFormat('dd-MM-yyyy hh:mm a').parse(eventData[index]['start'])),
                                                  style: GoogleFonts.signika(
                                                    color: textColor,
                                                    fontSize: size.height * 0.021,
                                                  ),
                                                  children: eventData[index]['session'] != null && eventData[index]['session'] != '' ? [
                                                    const TextSpan(
                                                      text: '  ',
                                                    ),
                                                    TextSpan(
                                                      text: eventData[index]['session'],
                                                      style: GoogleFonts.signika(
                                                        color: textColor,
                                                        fontSize: size.height * 0.021,
                                                      ),
                                                    ),
                                                  ] : []
                                              ),
                                            ),
                                          ],
                                        ),
                                        Text(
                                          DateFormat('EEEE').format(DateFormat('dd-MM-yyyy hh:mm a').parse(eventData[index]['start'])),
                                          style: GoogleFonts.signika(
                                            color: blackColor,
                                            fontSize: size.height * 0.021,
                                          ),
                                        ),
                                      ],
                                    ),
                                    SizedBox(
                                      height: size.height * 0.01,
                                    ),
                                    Row(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        const Icon(Icons.location_on, color: iconColor,),
                                        SizedBox(width: size.width * 0.01,),
                                        eventData[index]['location'] != '' && eventData[index]['location'] != null ? Flexible(child: Text('${eventData[index]['location']}', style: GoogleFonts.signika(color: Colors.black87, fontSize: size.height * 0.02),)) : Text("-", style: GoogleFonts.signika(fontSize: size.height * 0.02, color: Colors.grey, fontStyle: FontStyle.italic),),
                                      ],
                                    ),
                                    eventData[index]['description'] != null && eventData[index]['description'] != '' ? SizedBox(height: size.height * 0.01,) : Container(),
                                    eventData[index]['description'] != null && eventData[index]['description'] != '' ? Row(
                                      crossAxisAlignment: CrossAxisAlignment.end,
                                      children: [
                                        Flexible(
                                          child: Text(
                                            eventData[index]['description'].replaceAll(exp, ''),
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                        SizedBox(width: size.width * 0.01,),
                                        GestureDetector(
                                          onTap: () {
                                            showDialog(
                                              context: context,
                                              builder: (BuildContext context) {
                                                return Card(
                                                  shape: RoundedRectangleBorder(
                                                      borderRadius: BorderRadius.circular(15)
                                                  ),
                                                  child: Container(
                                                    padding: const EdgeInsets.all(10),
                                                    child: Column(
                                                      children: [
                                                        Row(
                                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                          children: [
                                                            Text("Content", style: GoogleFonts.signika(fontSize: size.height * 0.025, color: backgroundColor),),
                                                            IconButton(
                                                              icon: const Icon(Icons.close, color: Colors.redAccent,),
                                                              onPressed: () {
                                                                Navigator.pop(context);
                                                              },
                                                            ),
                                                          ],
                                                        ),
                                                        SizedBox(
                                                          height: size.height * 0.01,
                                                        ),
                                                        Expanded(
                                                          child: SingleChildScrollView(
                                                            child: Html(
                                                              data: eventData[index]['description'],
                                                            ),
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                );
                                              },
                                            );
                                          },
                                          child: eventData[index]['description'].replaceAll(exp, '').length >= 60 ? Container(
                                              alignment: Alignment.topRight,
                                              child: Row(
                                                mainAxisAlignment: MainAxisAlignment.end,
                                                children: [
                                                  const Text('More', style: TextStyle(
                                                      color: Colors.indigoAccent
                                                  ),),
                                                  SizedBox(width: size.width * 0.018,),
                                                  const Icon(Icons.arrow_forward_ios, color: Colors.indigoAccent, size: 11,)
                                                ],
                                              )
                                          ) : Container(),
                                        )
                                      ],
                                    ) : Container(),
                                  ],
                                ),
                              ),
                            ) else Container(),
                          ],
                        ),
                      );
                    },
                  ),
                ),
              ),
            ],
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
    );
  }
}
