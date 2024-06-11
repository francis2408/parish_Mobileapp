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

import 'news_detail_screen.dart';

class ChurchScreen extends StatefulWidget {
  const ChurchScreen({Key? key}) : super(key: key);

  @override
  State<ChurchScreen> createState() => _ChurchScreenState();
}

class _ChurchScreenState extends State<ChurchScreen> {
  bool _isLoading = true;
  List data = [];
  List newsData = [];
  int selected = -1;
  String searchName = '';
  var searchController = TextEditingController();

  // Local variables
  String name = '';
  String image = '';
  String dates = '';
  String detail = '';

  RegExp exp = RegExp(r"<[^>]*>",multiLine: true,caseSensitive: true);
  final format = DateFormat("dd-MM-yyyy");

  getNewsData() async {
    var request = http.Request('GET', Uri.parse('$baseUrl/res.news'));
    request.body = json.encode({
      "params": {
        "filter": "[['parish_id','=',$parishID],['type','=','News'],['category','=','Church'],['state','=','publish']]",
        "order": "date desc",
        "query":"{id,image_1920,name,description,date,type}"
      }
    });
    request.headers.addAll(header);
    http.StreamedResponse response = await request.send();
    if (response.statusCode == 200) {
      var decode = json.decode(await response.stream.bytesToString())['result'];
      if(decode['status'] == true) {
        data = decode['data']['result'];
        setState(() {
          _isLoading = false;
        });
        newsData = data;
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
      newsData = results;
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
    getNewsData();
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Scaffold(
      backgroundColor: screenBackgroundColor,
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
                    Text('${newsData.length}', style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: countValue),)
                  ],
                ),
              ),
              SizedBox(
                height: size.height * 0.01,
              ),
              newsData.isNotEmpty ? Expanded(
                child: SlideFadeAnimation(
                  duration: const Duration(seconds: 1),
                  child: SingleChildScrollView(
                    child: ListView.builder(
                        key: Key('builder ${selected.toString()}'),
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: newsData.length,
                        itemBuilder: (BuildContext context, int index) {
                          bool isSameDate = true;
                          final String dateString = newsData[index]['date'];
                          final DateTime date = DateFormat('dd-MM-yyyy').parse(dateString);
                          if (index == 0) {
                            isSameDate = false;
                          } else {
                            final String prevDateString = newsData[index - 1]['date'];
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
                                GestureDetector(
                                  onTap: () {
                                    name = newsData[index]['name'];
                                    image = newsData[index]['image_1920'];
                                    dates = newsData[index]['date'];
                                    detail = newsData[index]['description'];
                                    setState(() {
                                      Navigator.push(context, MaterialPageRoute(builder: (context) {return NewsDetailsScreen(title: name, image: image, date: dates, description: detail);}));
                                    });
                                  },
                                  child: Card(
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(15),
                                    ),
                                    child: Container(
                                      padding: const EdgeInsets.only(left: 10, top: 5, bottom: 5),
                                      child: Row(
                                        children: [
                                          GestureDetector(
                                            onTap: () {
                                              newsData[index]['image_1920'] != '' ? showDialog(
                                                context: context,
                                                builder: (BuildContext context) {
                                                  return Dialog(
                                                    child: Image.network(newsData[index]['image_1920'], fit: BoxFit.cover,),
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
                                                  image: newsData[index]['image_1920'] != null && newsData[index]['image_1920'] != ''
                                                      ? NetworkImage(newsData[index]['image_1920'])
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
                                                          newsData[index]['name'],
                                                          style: GoogleFonts.roboto(
                                                            fontSize: size.height * 0.02,
                                                            color: textColor,
                                                          ),
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                  SizedBox(height: size.height * 0.01,),
                                                  newsData[index]['description'] != null && newsData[index]['description'] != '' && newsData[index]['description'].replaceAll(exp, '') != '' ? Row(
                                                    crossAxisAlignment: CrossAxisAlignment.end,
                                                    children: [
                                                      Flexible(
                                                        child: Text(
                                                          newsData[index]['description'].replaceAll(exp, ''),
                                                          maxLines: 2,
                                                          overflow: TextOverflow.ellipsis,
                                                          style: TextStyle(fontSize: size.height * 0.016, color: labelColor),
                                                          textAlign: TextAlign.justify,
                                                        ),
                                                      ),
                                                      SizedBox(width: size.width * 0.01,),
                                                      GestureDetector(
                                                        onTap: () {
                                                          name = newsData[index]['name'];
                                                          image = newsData[index]['image_1920'];
                                                          dates = newsData[index]['date'];
                                                          detail = newsData[index]['description'];
                                                          setState(() {
                                                            Navigator.push(context, MaterialPageRoute(builder: (context) {return NewsDetailsScreen(title: name, image: image, date: dates, description: detail);}));
                                                          });
                                                        },
                                                        child: newsData[index]['description'].replaceAll(exp, '').length >= 80 ? Container(
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
                              ],
                            );
                          } else {
                            return GestureDetector(
                              onTap: () {
                                name = newsData[index]['name'];
                                image = newsData[index]['image_1920'];
                                dates = newsData[index]['date'];
                                detail = newsData[index]['description'];
                                setState(() {
                                  Navigator.push(context, MaterialPageRoute(builder: (context) {return NewsDetailsScreen(title: name, image: image, date: dates, description: detail);}));
                                });
                              },
                              child: Card(
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(15),
                                ),
                                child: Container(
                                  padding: const EdgeInsets.only(left: 10, top: 5, bottom: 5),
                                  child: Row(
                                    children: [
                                      GestureDetector(
                                        onTap: () {
                                          newsData[index]['image_1920'] != '' ? showDialog(
                                            context: context,
                                            builder: (BuildContext context) {
                                              return Dialog(
                                                child: Image.network(newsData[index]['image_1920'], fit: BoxFit.cover,),
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
                                              image: newsData[index]['image_1920'] != null && newsData[index]['image_1920'] != ''
                                                  ? NetworkImage(newsData[index]['image_1920'])
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
                                                      newsData[index]['name'],
                                                      style: GoogleFonts.roboto(
                                                        fontSize: size.height * 0.02,
                                                        color: textColor,
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                              SizedBox(height: size.height * 0.01,),
                                              newsData[index]['description'] != null && newsData[index]['description'] != '' && newsData[index]['description'].replaceAll(exp, '') != '' ? Row(
                                                crossAxisAlignment: CrossAxisAlignment.end,
                                                children: [
                                                  Flexible(
                                                    child: Text(
                                                      newsData[index]['description'].replaceAll(exp, ''),
                                                      maxLines: 2,
                                                      overflow: TextOverflow.ellipsis,
                                                      style: TextStyle(fontSize: size.height * 0.016, color: labelColor),
                                                      textAlign: TextAlign.justify,
                                                    ),
                                                  ),
                                                  SizedBox(width: size.width * 0.01,),
                                                  GestureDetector(
                                                    onTap: () {
                                                      name = newsData[index]['name'];
                                                      image = newsData[index]['image_1920'];
                                                      dates = newsData[index]['date'];
                                                      detail = newsData[index]['description'];
                                                      setState(() {
                                                        Navigator.push(context, MaterialPageRoute(builder: (context) {return NewsDetailsScreen(title: name, image: image, date: dates, description: detail);}));
                                                      });
                                                    },
                                                    child: newsData[index]['description'].replaceAll(exp, '').length >= 80 ? Container(
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