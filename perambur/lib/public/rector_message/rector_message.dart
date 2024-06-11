import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_widget_from_html/flutter_widget_from_html.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:loading_indicator/loading_indicator.dart';
import 'package:perambur/widget/common/common.dart';
import 'package:perambur/widget/common/internet_connection_checker.dart';
import 'package:perambur/widget/common/slide_animations.dart';
import 'package:perambur/widget/theme_color/theme_color.dart';
import 'package:perambur/widget/widget.dart';

class RectorMessageScreen extends StatefulWidget {
  const RectorMessageScreen({Key? key}) : super(key: key);

  @override
  State<RectorMessageScreen> createState() => _RectorMessageScreenState();
}

class _RectorMessageScreenState extends State<RectorMessageScreen> {
  bool _isLoading = true;
  List data = [];
  List message = [];

  String searchName = '';
  var searchController = TextEditingController();
  RegExp exp = RegExp(r"<[^>]*>",multiLine: true,caseSensitive: true);

  getPublicRectorMessageData() async {
    var request = http.Request('GET', Uri.parse("$baseUrl/public/res.news/get_rector_message"));
    request.body = json.encode({
      "params": {
        "args": [int.parse(parishID)]
      }
    });
    request.headers.addAll(headers);
    http.StreamedResponse response = await request.send();
    if (response.statusCode == 200) {
      data = json.decode(await response.stream.bytesToString())['result'];
      setState(() {
        _isLoading = false;
      });
      message = data;
    } else {
      var message = json.decode(await response.stream.bytesToString())['message'];
      setState(() {
        _isLoading = false;
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

  getUserRectorMessageData() async {
    var request = http.Request('GET', Uri.parse("$baseUrl/res.news/get_rector_message"));
    request.body = json.encode({
      "params": {
        "args": [int.parse(parishID)]
      }
    });
    request.headers.addAll(header);
    http.StreamedResponse response = await request.send();
    if (response.statusCode == 200) {
      var decode = json.decode(await response.stream.bytesToString())['result'];
      if(decode['status'] == true) {
        List data = decode['result'];
        setState(() {
          _isLoading = false;
        });
        message = data;
      }
    } else {
      var message = json.decode(await response.stream.bytesToString())['message'];
      setState(() {
        _isLoading = false;
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

  searchData(String searchWord) {
    List results = [];
    if (searchWord.isEmpty) {
      // if the search field is empty or only contains white-space, we'll display all users
      results = data;
    } else {
      results = data
          .where((user) =>
          user['name'].toLowerCase().contains(searchWord.toLowerCase())).toList();
      // we use the toLowerCase() method to make it case-insensitive
    }

    setState((){
      message = results;
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
    isSignedIn ? getUserRectorMessageData() : getPublicRectorMessageData();
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
            'Priest Message',
            style: TextStyle(
              fontSize: size.height * 0.02,
              fontWeight: FontWeight.bold,
              color: whiteColor,
            ),
          ),
          centerTitle: true,
        ),
        body: SafeArea(
          child: Center(
            child: _isLoading ? Center(
              child: SizedBox(
                height: size.height * 0.06,
                child: const LoadingIndicator(
                  indicatorType: Indicator.ballSpinFadeLoader,
                  colors: [Colors.red,Colors.orange,Colors.yellow,Colors.green,Colors.blue,Colors.indigo,Colors.purple,],
                ),
              ),
            ) : Column(
              children: [
                SizedBox(
                  height: size.height * 0.01,
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 10, right: 10),
                  child: Card(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15.0),
                    ),
                    elevation: 5,
                    child: TextField(
                      controller: searchController,
                      onChanged: (value) {
                        setState(() {
                          searchName = value;
                          searchData(searchName);
                        });
                      },
                      onSubmitted: (value) {
                        setState(() {
                          searchData(value);
                        });
                      },
                      decoration: InputDecoration(
                        contentPadding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 10.0),
                        hintText: "Search",
                        hintStyle: TextStyle(
                          color: Colors.grey,
                          fontSize: size.height * 0.02,
                          fontStyle: FontStyle.italic,
                        ),
                        suffixIcon: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            GestureDetector(
                              onTap: () {
                                if (searchName.isNotEmpty) {
                                  setState(() {
                                    searchController.clear();
                                    searchName = '';
                                    searchData(searchName);
                                  });
                                }
                              },
                              child: searchName.isNotEmpty && searchName != ''
                                  ? const Icon(Icons.clear, color: redColor)
                                  : Container(),
                            ),
                            SizedBox(width: size.width * 0.01),
                            GestureDetector(
                              onTap: () {
                                setState(() {
                                  searchData(searchName);
                                });
                              },
                              child: Container(
                                height: 50,
                                width: 45,
                                decoration: const BoxDecoration(
                                  borderRadius: BorderRadius.only(
                                    topRight: Radius.circular(15),
                                    bottomRight: Radius.circular(15),
                                  ),
                                  color: iconBackColor,
                                ),
                                child: const Icon(Icons.search, color: whiteColor),
                              ),
                            ),
                          ],
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10.0),
                          borderSide: const BorderSide(),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10.0),
                          borderSide: const BorderSide(width: 1, color: Colors.transparent),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: const BorderSide(
                            color: Colors.transparent,
                            width: 1.0,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                SizedBox(
                  height: size.height * 0.01,
                ),
                Padding(
                  padding: const EdgeInsets.only(right: 10),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      const Text('Total Count :', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: countLabel),),
                      const SizedBox(width: 3,),
                      Text('${message.length}', style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: countValue),)
                    ],
                  ),
                ),
                SizedBox(
                  height: size.height * 0.01,
                ),
                message.isNotEmpty ? Expanded(
                  child: SlideFadeAnimation(
                    duration: const Duration(seconds: 1),
                    child: SingleChildScrollView(
                      child: ListView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: message.length,
                          itemBuilder: (BuildContext context, int index) {
                            bool isSameDate = true;
                            final String dateString = message[index]['date'];
                            final DateTime date = DateFormat('dd-MM-yyyy').parse(dateString);
                            if (index == 0) {
                              isSameDate = false;
                            } else {
                              final String prevDateString = message[index - 1]['date'];
                              final DateTime prevDate = DateFormat('dd-MM-yyyy').parse(prevDateString);
                              isSameDate = date.isSameDate(prevDate);
                            }
                            if(index == 0 || !(isSameDate)) {
                              return Column(
                                children: [
                                  SizedBox(height: size.height * 0.005,),
                                  Container(
                                    alignment: Alignment.centerLeft,
                                    child: Container(
                                      width: size.width * 0.45,
                                      alignment: Alignment.center,
                                      padding: const EdgeInsets.only(left: 20, right: 20, top: 3, bottom: 3),
                                      decoration: const BoxDecoration(
                                        borderRadius: BorderRadius.only(topRight: Radius.circular(10), bottomRight: Radius.circular(10)),
                                        color: primaryColor,
                                      ),
                                      child: Text(
                                        date.formatDate(),
                                        style: GoogleFonts.roboto(
                                            color: Colors.white,
                                            fontWeight: FontWeight.bold,
                                            fontSize: size.height * 0.018
                                        ),
                                      ),
                                    ),
                                  ),
                                  SizedBox(height: size.height * 0.005,),
                                  Card(
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(15),
                                    ),
                                    child: Container(
                                      padding: const EdgeInsets.only(left: 10, top: 5, bottom: 5),
                                      child: Row(
                                        children: [
                                          GestureDetector(
                                            onTap: () {
                                              message[index]['image'] != '' && message[index]['image'] != null ? showDialog(
                                                context: context,
                                                builder: (BuildContext context) {
                                                  return Dialog(
                                                    child: Image.network(message[index]['image'], fit: BoxFit.cover,),
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
                                              height: size.height * 0.1,
                                              width: size.width * 0.20,
                                              decoration: BoxDecoration(
                                                borderRadius: BorderRadius.circular(10),
                                                shape: BoxShape.rectangle,
                                                image: DecorationImage(
                                                  fit: BoxFit.cover,
                                                  image: message[index]['image'] != null && message[index]['image'] != ''
                                                      ? NetworkImage(message[index]['image'])
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
                                                          message[index]['title'],
                                                          style: GoogleFonts.roboto(
                                                            fontSize: size.height * 0.02,
                                                            color: textColor,
                                                          ),
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                  SizedBox(height: size.height * 0.01,),
                                                  message[index]['description'] != null && message[index]['description'] != '' && message[index]['description'].replaceAll(exp, '') != '' ? GestureDetector(
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
                                                          return ClipRRect(
                                                            borderRadius: const BorderRadius.vertical(top: Radius.circular(25.0)),
                                                            child: Container(
                                                              height: size.height * 0.6,
                                                              decoration: const BoxDecoration(
                                                                borderRadius: BorderRadius.only(
                                                                  topRight: Radius.circular(25),
                                                                  topLeft: Radius.circular(25),
                                                                ),
                                                                color: Colors.white,
                                                              ),
                                                              child: Center(
                                                                child: Column(
                                                                  mainAxisAlignment: MainAxisAlignment.center,
                                                                  mainAxisSize: MainAxisSize.min,
                                                                  children: <Widget>[
                                                                    SizedBox(height: size.height * 0.01),
                                                                    Container(
                                                                      width: size.width * 0.3,
                                                                      height: size.height * 0.008,
                                                                      alignment: Alignment.topCenter,
                                                                      decoration: BoxDecoration(
                                                                        borderRadius: BorderRadius.circular(30),
                                                                        color: screenBackgroundColor,
                                                                      ),
                                                                    ),
                                                                    SizedBox(height: size.height * 0.01),
                                                                    Padding(
                                                                      padding: const EdgeInsets.only(left: 10, right: 10),
                                                                      child: Row(
                                                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                                        children: [
                                                                          Text(
                                                                              message[index]['title'],
                                                                              style: GoogleFonts.signika(
                                                                                  fontSize: size.height * 0.023,
                                                                                  color: textColor
                                                                              )
                                                                          ),
                                                                          IconButton(
                                                                            icon: const Icon(Icons.close, color: buttonRed,),
                                                                            onPressed: () {
                                                                              Navigator.pop(context);
                                                                            },
                                                                          ),
                                                                        ],
                                                                      ),
                                                                    ),
                                                                    SizedBox(width: size.height * 0.01),
                                                                    Padding(
                                                                      padding: const EdgeInsets.only(right: 10),
                                                                      child: Row(
                                                                        mainAxisAlignment: MainAxisAlignment.end,
                                                                        children: [
                                                                          const Icon(Icons.access_time_filled, color: iconColor, size: 20,),
                                                                          SizedBox(width: size.width * 0.03,),
                                                                          Text(
                                                                              DateFormat('dd-MMMM-yyyy').format(DateFormat('dd-MM-yyyy').parse(message[index]['date'])),
                                                                              style: GoogleFonts.signika(
                                                                                  fontSize: size.height * 0.02,
                                                                                  color: textHeadColor
                                                                              )
                                                                          ),
                                                                        ],
                                                                      ),
                                                                    ),
                                                                    Expanded(
                                                                      child: SingleChildScrollView(
                                                                        child: Padding(
                                                                          padding: const EdgeInsets.all(8.0),
                                                                          child: HtmlWidget(
                                                                            message[index]['description'],
                                                                            customStylesBuilder: (element) {
                                                                              if (element.localName == 'p') {
                                                                                return {
                                                                                  'lineHeight': '1.5',
                                                                                  'textAlign': 'justify',
                                                                                };
                                                                              }
                                                                              return null;
                                                                            },
                                                                          ),
                                                                        ),
                                                                      ),
                                                                    ),
                                                                  ],
                                                                ),
                                                              ),
                                                            ),
                                                          );
                                                        },
                                                      );
                                                    },
                                                    child: Row(
                                                      crossAxisAlignment: CrossAxisAlignment.end,
                                                      children: [
                                                        Flexible(
                                                          child: Text(
                                                            message[index]['description'].replaceAll(exp, ''),
                                                            maxLines: 2,
                                                            overflow: TextOverflow.ellipsis,
                                                            style: TextStyle(fontSize: size.height * 0.016, color: labelColor),
                                                            textAlign: TextAlign.justify,
                                                          ),
                                                        ),
                                                        SizedBox(width: size.width * 0.01,),
                                                        message[index]['description'].replaceAll(exp, '').length >= 80 ? Container(
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
                                                    ),
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
                                ],
                              );
                            } else {
                              return Card(
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(15),
                                ),
                                child: Container(
                                  padding: const EdgeInsets.only(left: 10, top: 5, bottom: 5),
                                  child: Row(
                                    children: [
                                      GestureDetector(
                                        onTap: () {
                                          message[index]['image'] != '' && message[index]['image'] != null ? showDialog(
                                            context: context,
                                            builder: (BuildContext context) {
                                              return Dialog(
                                                child: Image.network(message[index]['image'], fit: BoxFit.cover,),
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
                                          height: size.height * 0.1,
                                          width: size.width * 0.20,
                                          decoration: BoxDecoration(
                                            borderRadius: BorderRadius.circular(10),
                                            shape: BoxShape.rectangle,
                                            image: DecorationImage(
                                              fit: BoxFit.cover,
                                              image: message[index]['image'] != null && message[index]['image'] != ''
                                                  ? NetworkImage(message[index]['image'])
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
                                                      message[index]['title'],
                                                      style: GoogleFonts.roboto(
                                                        fontSize: size.height * 0.02,
                                                        color: textColor,
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                              SizedBox(height: size.height * 0.01,),
                                              message[index]['description'] != null && message[index]['description'] != '' && message[index]['description'].replaceAll(exp, '') != '' ? GestureDetector(
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
                                                      return ClipRRect(
                                                        borderRadius: const BorderRadius.vertical(top: Radius.circular(25.0)),
                                                        child: Container(
                                                          height: size.height * 0.6,
                                                          decoration: const BoxDecoration(
                                                            borderRadius: BorderRadius.only(
                                                              topRight: Radius.circular(25),
                                                              topLeft: Radius.circular(25),
                                                            ),
                                                            color: Colors.white,
                                                          ),
                                                          child: Center(
                                                            child: Column(
                                                              mainAxisAlignment: MainAxisAlignment.center,
                                                              mainAxisSize: MainAxisSize.min,
                                                              children: <Widget>[
                                                                SizedBox(height: size.height * 0.01),
                                                                Container(
                                                                  width: size.width * 0.3,
                                                                  height: size.height * 0.008,
                                                                  alignment: Alignment.topCenter,
                                                                  decoration: BoxDecoration(
                                                                    borderRadius: BorderRadius.circular(30),
                                                                    color: screenBackgroundColor,
                                                                  ),
                                                                ),
                                                                SizedBox(height: size.height * 0.01),
                                                                Padding(
                                                                  padding: const EdgeInsets.only(left: 10, right: 10),
                                                                  child: Row(
                                                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                                    children: [
                                                                      Text(
                                                                          message[index]['title'],
                                                                          style: GoogleFonts.signika(
                                                                              fontSize: size.height * 0.023,
                                                                              color: textColor
                                                                          )
                                                                      ),
                                                                      IconButton(
                                                                        icon: const Icon(Icons.close, color: buttonRed,),
                                                                        onPressed: () {
                                                                          Navigator.pop(context);
                                                                        },
                                                                      ),
                                                                    ],
                                                                  ),
                                                                ),
                                                                SizedBox(width: size.height * 0.01),
                                                                Padding(
                                                                  padding: const EdgeInsets.only(right: 10),
                                                                  child: Row(
                                                                    mainAxisAlignment: MainAxisAlignment.end,
                                                                    children: [
                                                                      const Icon(Icons.access_time_filled, color: iconColor, size: 20,),
                                                                      SizedBox(width: size.width * 0.03,),
                                                                      Text(
                                                                          DateFormat('dd-MMMM-yyyy').format(DateFormat('dd-MM-yyyy').parse(message[index]['date'])),
                                                                          style: GoogleFonts.signika(
                                                                              fontSize: size.height * 0.02,
                                                                              color: textHeadColor
                                                                          )
                                                                      ),
                                                                    ],
                                                                  ),
                                                                ),
                                                                Expanded(
                                                                  child: SingleChildScrollView(
                                                                    child: Padding(
                                                                      padding: const EdgeInsets.all(8.0),
                                                                      child: HtmlWidget(
                                                                        message[index]['description'],
                                                                        customStylesBuilder: (element) {
                                                                          if (element.localName == 'p') {
                                                                            return {
                                                                              'lineHeight': '1.5',
                                                                              'textAlign': 'justify',
                                                                            };
                                                                          }
                                                                          return null;
                                                                        },
                                                                      ),
                                                                    ),
                                                                  ),
                                                                ),
                                                              ],
                                                            ),
                                                          ),
                                                        ),
                                                      );
                                                    },
                                                  );
                                                },
                                                child: Row(
                                                  crossAxisAlignment: CrossAxisAlignment.end,
                                                  children: [
                                                    Flexible(
                                                      child: Text(
                                                        message[index]['description'].replaceAll(exp, ''),
                                                        maxLines: 2,
                                                        overflow: TextOverflow.ellipsis,
                                                        style: TextStyle(fontSize: size.height * 0.016, color: labelColor),
                                                        textAlign: TextAlign.justify,
                                                      ),
                                                    ),
                                                    SizedBox(width: size.width * 0.01,),
                                                    message[index]['description'].replaceAll(exp, '').length >= 80 ? Container(
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
                                                ),
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
                              );
                            }
                          }
                      ),
                    ),
                  ),
                ) : Expanded(
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
              ],
            ),
          ),
        ),
      ),
    );
  }
}

const String dateFormatter = 'MMMM dd, y';

extension DateHelper on DateTime {

  String formatDate() {
    final formatter = DateFormat(dateFormatter);
    return formatter.format(this);
  }
  bool isSameDate(DateTime other) {
    return year == other.year &&
        month == other.month &&
        day == other.day;
  }

  int getDifferenceInDaysWithNow() {
    final now = DateTime.now();
    return now.difference(this).inDays;
  }
}
