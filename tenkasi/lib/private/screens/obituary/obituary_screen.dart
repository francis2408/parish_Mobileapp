import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:loading_indicator/loading_indicator.dart';
import 'package:tenkasi/private/screens/news/church_screen.dart';
import 'package:tenkasi/private/screens/obituary/obituary_detail_screen.dart';
import 'package:tenkasi/widget/common/common.dart';
import 'package:tenkasi/widget/common/internet_connection_checker.dart';
import 'package:tenkasi/widget/common/slide_animations.dart';
import 'package:tenkasi/widget/theme_color/theme_color.dart';
import 'package:tenkasi/widget/widget.dart';

class ObituaryScreen extends StatefulWidget {
  const ObituaryScreen({Key? key}) : super(key: key);

  @override
  State<ObituaryScreen> createState() => _ObituaryScreenState();
}

class _ObituaryScreenState extends State<ObituaryScreen> {
  bool _isLoading = true;
  bool _isToday = false;
  List deathData = [];
  List data = [];
  int selected = -1;
  String searchName = '';
  var searchController = TextEditingController();
  String today = '';
  String formattedDate = '';

  // Local variables
  String name = '';
  String image = '';
  String dates = '';
  String detail = '';

  RegExp exp = RegExp(r"<[^>]*>",multiLine: true,caseSensitive: true);
  final format = DateFormat("dd-MM-yyyy");

  getObituaryData() async {
    var request = http.Request('GET', Uri.parse('$baseUrl/public/$parishID/parish_all_news'));
    request.body = json.encode({});
    request.headers.addAll(headers);
    http.StreamedResponse response = await request.send();
    if (response.statusCode == 200) {
      var decode = json.decode(await response.stream.bytesToString())['result'];
      if(decode['status'] == 'success') {
        List datas = decode['result'];
        setState(() {
          _isLoading = false;
        });
        for(int i = 0; i < datas.length; i++) {
          if (datas[i]['category'] == 'Obituary') {
            data = datas[i]['news'];
            deathData = data;
          }
        }
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
      deathData = results;
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
    super.initState();
    getObituaryData();
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
        // appBar: AppBar(
        //   backgroundColor: appBackgroundColor,
        //   title: Text(
        //     'Obituary',
        //     style: TextStyle(
        //       fontSize: size.height * 0.02,
        //       fontWeight: FontWeight.bold,
        //       color: whiteColor,
        //     ),
        //   ),
        //   centerTitle: true,
        // ),
        body: SafeArea(
          child: Container(
            padding: const EdgeInsets.only(top: 5),
            child: Center(
              child: _isLoading ? SizedBox(
                height: size.height * 0.06,
                child: const LoadingIndicator(
                  indicatorType: Indicator.ballSpinFadeLoader,
                  colors: [Colors.red,Colors.orange,Colors.yellow,Colors.green,Colors.blue,Colors.indigo,Colors.purple,],
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
                  deathData.isNotEmpty ? Padding(
                    padding: const EdgeInsets.only(right: 10),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        const Text('Total Count :', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.black),),
                        const SizedBox(width: 3,),
                        Text('${deathData.length}', style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.black),),
                        const SizedBox(width: 5,),
                      ],
                    ),
                  ) : Container(),
                  SizedBox(
                    height: size.height * 0.01,
                  ),
                  deathData.isNotEmpty ? Expanded(
                    child: SingleChildScrollView(
                      child: SlideFadeAnimation(
                        duration: const Duration(seconds: 1),
                        child: ListView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: deathData.length,
                          itemBuilder: (BuildContext context, int index) {
                            final now = DateTime.now();
                            var todays = DateFormat('dd - MMMM').format(now);
                            DateTime date = DateFormat("dd-MM-yyyy").parse(deathData[index]['date']);
                            var formattedDates = DateFormat('dd - MMMM').format(date);
                            return Column(
                              children: [
                                Row(
                                    children:[
                                      Container(
                                        width: size.width * 0.45,
                                        alignment: Alignment.center,
                                        padding: const EdgeInsets.only(left: 20, right: 20, top: 3, bottom: 3),
                                        decoration: const BoxDecoration(
                                          borderRadius: BorderRadius.only(topRight: Radius.circular(10), bottomRight: Radius.circular(10)),
                                          color: hiLightColor,
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
                                    ]),
                                Stack(
                                  children: [
                                    SizedBox(height: size.height * 0.05,),
                                    GestureDetector(
                                      onTap: () {
                                        name = deathData[index]['name'];
                                        image = deathData[index]['image_1920'];
                                        dates = deathData[index]['date'];
                                        detail = deathData[index]['description'];
                                        setState(() {
                                          Navigator.push(context, MaterialPageRoute(builder: (context) {return ObituaryDetailScreen(title: name, image: image, date: dates, description: detail);}));
                                        });
                                      },
                                      child: Card(
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(15.0),
                                        ),
                                        child: Padding(
                                          padding: const EdgeInsets.all(8.0),
                                          child: Row(
                                            children: [
                                              GestureDetector(
                                                onTap: () {
                                                  deathData[index]['image_1920'] != '' ? showDialog(
                                                    context: context,
                                                    builder: (BuildContext context) {
                                                      return Dialog(
                                                        child: Image.network(deathData[index]['image_1920'], fit: BoxFit.cover,),
                                                      );
                                                    },
                                                  ) : showDialog(
                                                    context: context,
                                                    builder: (BuildContext context) {
                                                      return Dialog(
                                                        child: Image.asset('assets/images/profile.png', fit: BoxFit.cover,),
                                                      );
                                                    },
                                                  );
                                                },
                                                child: Container(
                                                  height: size.height * 0.11,
                                                  width: size.width * 0.18,
                                                  decoration: BoxDecoration(
                                                    borderRadius: BorderRadius.circular(10),
                                                    boxShadow: <BoxShadow>[
                                                      if(deathData[index]['image_1920'] != null && deathData[index]['image_1920'] != '') const BoxShadow(
                                                        color: Colors.grey,
                                                        spreadRadius: -1,
                                                        blurRadius: 5 ,
                                                        offset: Offset(0, 1),
                                                      ),
                                                    ],
                                                    shape: BoxShape.rectangle,
                                                    image: DecorationImage(
                                                      fit: BoxFit.cover,
                                                      image: deathData[index]['image_1920'] != null && deathData[index]['image_1920'] != ''
                                                          ? NetworkImage(deathData[index]['image_1920'])
                                                          : const AssetImage('assets/images/profile.png') as ImageProvider,
                                                    ),
                                                  ),
                                                ),
                                              ),
                                              Expanded(
                                                child: Container(
                                                  padding: const EdgeInsets.only(top: 10, right: 5, left: 20),
                                                  child: Column(
                                                    crossAxisAlignment: CrossAxisAlignment.start,
                                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                    children: [
                                                      Row(
                                                        children: [
                                                          Text(
                                                            deathData[index]['name'],
                                                            style: GoogleFonts.roboto(
                                                              fontSize: size.height * 0.02,
                                                              color: textColor,
                                                              fontWeight: FontWeight.bold,
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                      SizedBox(height: size.height * 0.01,),
                                                      // Row(
                                                      //   children: [
                                                      //     const Icon(Icons.access_time, color: hiLightColor, size: 20,),
                                                      //     SizedBox(width: size.width * 0.02,),
                                                      //     Text(DateFormat('dd-MMMM-yyyy').format(DateFormat('dd-MM-yyyy').parse(deathData[index]['date'])), style: GoogleFonts.secularOne(color: hiLightColor, fontSize: size.height * 0.018),),
                                                      //   ],
                                                      // ),
                                                      SizedBox(height: size.height * 0.01,),
                                                      deathData[index]['description'] != null && deathData[index]['description'] != '' && deathData[index]['description'].replaceAll(exp, '') != '' ? Row(
                                                        crossAxisAlignment: CrossAxisAlignment.end,
                                                        children: [
                                                          Flexible(
                                                            child: Text(
                                                              deathData[index]['description'].replaceAll(exp, ''),
                                                              maxLines: 2,
                                                              overflow: TextOverflow.ellipsis,
                                                              style: TextStyle(fontSize: size.height * 0.016, color: labelColor),
                                                              textAlign: TextAlign.justify,
                                                            ),
                                                          ),
                                                          SizedBox(width: size.width * 0.01,),
                                                          GestureDetector(
                                                            onTap: () {
                                                              name = deathData[index]['name'];
                                                              image = deathData[index]['image_1920'];
                                                              dates = deathData[index]['date'];
                                                              detail = deathData[index]['description'];
                                                              setState(() {
                                                                Navigator.push(context, MaterialPageRoute(builder: (context) {return ObituaryDetailScreen(title: name, image: image, date: dates, description: detail);}));
                                                              });
                                                            },
                                                            child: deathData[index]['description'].replaceAll(exp, '').length >= 60 ? Container(
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
                                                            ) : Container(),
                                                          )
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
                                    if(todays == formattedDates) Positioned(
                                      top: size.height * 0.02,
                                      right: size.width * 0.01,
                                      child: Center(
                                        child: Container(
                                          height: size.height * 0.06,
                                          width: size.width * 0.15,
                                          decoration: const BoxDecoration(
                                            image: DecorationImage(
                                              image: AssetImage( "assets/images/death.png"),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            );
                          },
                        ),
                      ),
                    ),
                  ) : Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Center(
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
                        )
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
