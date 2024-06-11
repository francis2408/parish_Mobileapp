import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:loading_indicator/loading_indicator.dart';
import 'package:munchirai/private/screens/bcc/bcc_familys.dart';
import 'package:munchirai/private/screens/bcc/bcc_members.dart';
import 'package:munchirai/private/screens/bcc/bcc_tabs.dart';
import 'package:munchirai/widget/common/common.dart';
import 'package:munchirai/widget/common/internet_connection_checker.dart';
import 'package:munchirai/widget/common/slide_animations.dart';
import 'package:munchirai/widget/theme_color/theme_color.dart';
import 'package:munchirai/widget/widget.dart';

class BCCScreen extends StatefulWidget {
  const BCCScreen({Key? key}) : super(key: key);

  @override
  State<BCCScreen> createState() => _BCCScreenState();
}

class _BCCScreenState extends State<BCCScreen> {
  final ClearSharedPreference shared = ClearSharedPreference();
  bool _isLoading = true;
  bool isSearchTrue = false;
  int? indexValue;
  String indexName = '';

  String searchName = '';
  var searchController = TextEditingController();

  List data = [];
  List bccData = [];
  List results = [];

  getBccData() async {
    var request = http.Request('GET', Uri.parse('$baseUrl/res.parish.bcc'));
    request.body = json.encode({
      "params": {
        "query": "{id,name,establishment_date,heads_ids{id,role,member_id{member_name,image_512,mobile},start_date,end_date,status},areas_covered,parish_family_count,parish_members_count}",
        "order": "name asc"
      }
    });
    request.headers.addAll(header);

    http.StreamedResponse response = await request.send();

    if(response.statusCode == 200) {
      var decode = json.decode(await response.stream.bytesToString())['result'];
      if(decode['status'] == true) {
        data = decode['data']['result'];
        setState(() {
          _isLoading = false;
        });
        bccData = data;
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

  assignValues(indexValue, indexName) async {
    bccId = indexValue.toString();
    String refresh = await Navigator.push(context, CustomRoute(widget: BCCTabsScreen(title: indexName)));
    if(refresh == 'refresh') {
      changeData();
    }
  }

  assignBCCMembersValues(indexValue, indexName) async {
    bccId = indexValue.toString();
    appbarVisible = true;
    String refresh = await Navigator.push(context, CustomRoute(widget: BCCMembersScreen(title: indexName,)));
    if(refresh == 'refresh') {
      changeData();
    }
  }

  void changeData() {
    setState(() {
      _isLoading = true;
      getBccData();
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

  searchData(String searchWord) async {
    var values = [];
    if (searchWord.isEmpty) {
      setState(() {
        results = [];
        isSearchTrue = false;
      });
    } else {
      values = bccData
          .where((user) =>
          user['name'].toLowerCase().contains(searchWord.toLowerCase()))
          .toList();

      setState(() {
        results = values; // Update the results list with filtered data
      });
    }
  }

  @override
  void initState() {
    // Check the internet connection
    internetCheck();
    // TODO: implement initState
    super.initState();
    if(expiryDateTime!.isAfter(currentDateTime)) {
      setState(() {
        getBccData();
      });
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
            'My Parish Anbiyams',
            style: TextStyle(
              fontSize: size.height * 0.02,
              fontWeight: FontWeight.bold,
              color: whiteColor,
            ),
          ),
          centerTitle: true,
          flexibleSpace: Container(
            decoration: const BoxDecoration(
                gradient: LinearGradient(
                    colors: [
                      primaryColor,
                      secondaryColor
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight
                )
            ),
          ),
          // backgroundColor: backgroundColor,
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
          ) : Column(
            children: [
              SizedBox(
                height: size.height * 0.01,
              ),
              Padding(
                padding: const EdgeInsets.only(left: 5, right: 5),
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
                        isSearchTrue = value.isNotEmpty;
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
              Expanded(
                child: isSearchTrue ? results.isNotEmpty ? Column(
                  children: [
                    results.isNotEmpty ? Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(right: 5),
                          child: Text('Showing 1 - ${results.length}', style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: countLabel),),
                        ),
                      ],
                    ) : Container(),
                    results.isNotEmpty ? SizedBox(
                      height: size.height * 0.01,
                    ) : Container(),
                    Expanded(
                      child: SlideFadeAnimation(
                        duration: const Duration(seconds: 1),
                        child: ListView.builder(
                          itemCount: results.length,
                          itemBuilder: (BuildContext context, int index) {
                            return GestureDetector(
                              onTap: () {
                                indexValue = results[index]['id'];
                                indexName = results[index]['name'];
                                assignValues(indexValue, indexName);
                              },
                              child: Padding(
                                padding: const EdgeInsets.only(left: 5, right: 5),
                                child: Card(
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(15),
                                  ),
                                  child: Container(
                                    padding: const EdgeInsets.only(left: 10, top: 10, bottom: 10),
                                    child: Row(
                                      children: [
                                        GestureDetector(
                                          onTap: () {
                                            showDialog(
                                              context: context,
                                              builder: (BuildContext context) {
                                                return Dialog(
                                                  child: Image.asset('assets/images/bcc.png', fit: BoxFit.cover,),
                                                );
                                              },
                                            );
                                          },
                                          child: Container(
                                            height: size.height * 0.11,
                                            width: size.width * 0.18,
                                            decoration: BoxDecoration(
                                              borderRadius: BorderRadius.circular(10),
                                              color: whiteColor,
                                              // boxShadow: const <BoxShadow>[
                                              //   BoxShadow(
                                              //     color: Colors.grey,
                                              //     spreadRadius: -1,
                                              //     blurRadius: 5 ,
                                              //     offset: Offset(0, 1),
                                              //   ),
                                              // ],
                                              shape: BoxShape.rectangle,
                                              image: const DecorationImage(
                                                fit: BoxFit.contain,
                                                image: AssetImage('assets/images/bcc.png'),
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
                                                        results[index]['name'],
                                                        style: GoogleFonts.secularOne(
                                                            fontSize: size.height * 0.02,
                                                            color: textColor
                                                        ),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                                results[index]['heads_ids'] != [] && results[index]['heads_ids'].isNotEmpty ? SizedBox(height: size.height * 0.005,) : Container(),
                                                results[index]['heads_ids'] != [] && results[index]['heads_ids'].isNotEmpty ? ListView.builder(
                                                  shrinkWrap: true,
                                                  scrollDirection: Axis.vertical,
                                                  itemCount: 1,
                                                  itemBuilder: (BuildContext context, int indexs) {
                                                    return Column(
                                                      children: [
                                                        Row(
                                                          children: [
                                                            results[index]['heads_ids'][indexs]['member_id']['member_name'] != '' ? Flexible(
                                                              child: RichText(
                                                                textAlign: TextAlign.left,
                                                                text: TextSpan(
                                                                    text: results[index]['heads_ids'][indexs]['member_id']['member_name'],
                                                                    style: GoogleFonts.secularOne(
                                                                        fontSize: size.height * 0.018,
                                                                        color: blackColor,
                                                                        fontStyle: FontStyle.italic
                                                                    ),
                                                                    children: results[index]['heads_ids'][indexs]['role'] != null && results[index]['heads_ids'][indexs]['role'] != '' ? [
                                                                      const TextSpan(
                                                                        text: '  ',
                                                                      ),
                                                                      TextSpan(
                                                                        text: '(${results[index]['heads_ids'][indexs]['role']})',
                                                                        style: TextStyle(
                                                                            fontSize: size.height * 0.018,
                                                                            color: emptyColor,
                                                                            fontStyle: FontStyle.italic
                                                                        ),
                                                                      ),
                                                                    ] : []
                                                                ),
                                                              ),
                                                            ) : Container(),
                                                          ],
                                                        ),
                                                        SizedBox(
                                                          height: size.height * 0.005,
                                                        ),
                                                      ],
                                                    );
                                                  },
                                                ) : Container(),
                                                SizedBox(height: size.height * 0.005,),
                                                Row(
                                                  children: [
                                                    results[index]['parish_family_count'] != '' && results[index]['parish_family_count'] != null ? GestureDetector(
                                                      onTap: () {
                                                        indexValue = results[index]['id'];
                                                        indexName = results[index]['name'];
                                                        assignValues(indexValue, indexName);
                                                      },
                                                      child: Container(
                                                        padding: const EdgeInsets.only(top: 5, bottom: 5, left: 8, right: 8),
                                                        decoration: BoxDecoration(
                                                          borderRadius: BorderRadius.circular(5),
                                                          color: customBackgroundColor2,
                                                        ),
                                                        child: RichText(
                                                          text: TextSpan(
                                                              text: results[index]['parish_family_count'].toString(),
                                                              style: TextStyle(
                                                                  letterSpacing: 1,
                                                                  fontSize: size.height * 0.016,
                                                                  fontWeight: FontWeight.bold,
                                                                  color: customTextColor2,
                                                                  fontStyle: FontStyle.italic
                                                              ),
                                                              children: <InlineSpan>[
                                                                results[index]['parish_family_count'] == 1 ? TextSpan(
                                                                  text: ' Family',
                                                                  style: TextStyle(
                                                                      letterSpacing: 1,
                                                                      fontSize: size.height * 0.016,
                                                                      fontWeight: FontWeight.bold,
                                                                      color: customTextColor2,
                                                                      fontStyle: FontStyle.italic
                                                                  ),
                                                                ) : TextSpan(
                                                                  text: " Families",
                                                                  style: TextStyle(
                                                                      letterSpacing: 1,
                                                                      fontSize: size.height * 0.016,
                                                                      fontWeight: FontWeight.bold,
                                                                      color: customTextColor2,
                                                                      fontStyle: FontStyle.italic
                                                                  ),
                                                                )
                                                              ]
                                                          ),
                                                        ),
                                                      ),
                                                    ) : Container(),
                                                    results[index]['parish_members_count'] != '' && results[index]['parish_members_count'] != null ? SizedBox(
                                                      width: size.width * 0.05,
                                                    ) : Container(),
                                                    results[index]['parish_members_count'] != '' && results[index]['parish_members_count'] != null ? GestureDetector(
                                                      onTap: () {
                                                        indexValue = results[index]['id'];
                                                        indexName = results[index]['name'];
                                                        assignBCCMembersValues(indexValue, indexName);
                                                      },
                                                      child: Container(
                                                        padding: const EdgeInsets.only(top: 5, bottom: 5, left: 8, right: 8),
                                                        decoration: BoxDecoration(
                                                          borderRadius: BorderRadius.circular(5),
                                                          color: customBackgroundColor1,
                                                        ),
                                                        child: RichText(
                                                          text: TextSpan(
                                                              text: results[index]['parish_members_count'].toString(),
                                                              style: TextStyle(
                                                                  letterSpacing: 1,
                                                                  fontSize: size.height * 0.016,
                                                                  fontWeight: FontWeight.bold,
                                                                  color: customTextColor1,
                                                                  fontStyle: FontStyle.italic
                                                              ),
                                                              children: <InlineSpan>[
                                                                results[index]['parish_members_count'] == 1 ? TextSpan(
                                                                  text: ' Member',
                                                                  style: TextStyle(
                                                                      letterSpacing: 1,
                                                                      fontSize: size.height * 0.016,
                                                                      fontWeight: FontWeight.bold,
                                                                      color: customTextColor1,
                                                                      fontStyle: FontStyle.italic
                                                                  ),
                                                                ) : TextSpan(
                                                                  text: ' Members',
                                                                  style: TextStyle(
                                                                      letterSpacing: 1,
                                                                      fontSize: size.height * 0.016,
                                                                      fontWeight: FontWeight.bold,
                                                                      color: customTextColor1,
                                                                      fontStyle: FontStyle.italic
                                                                  ),
                                                                )
                                                              ]
                                                          ),
                                                        ),
                                                      ),
                                                    ) : Container(),
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
                            );
                          },
                        ),
                      ),
                    )
                  ],
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
                ) : Column(
                  children: [
                    bccData.isNotEmpty ? Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(right: 5),
                          child: Text('Total Count: ${bccData.length}', style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: countLabel),),
                        ),
                      ],
                    ) : Container(),
                    bccData.isNotEmpty ? SizedBox(
                      height: size.height * 0.01,
                    ) : Container(),
                    bccData.isNotEmpty ? Expanded(
                      child: SlideFadeAnimation(
                        duration: const Duration(seconds: 1),
                        child: ListView.builder(
                          itemCount: bccData.length,
                          itemBuilder: (BuildContext context, int index) {
                            return GestureDetector(
                              onTap: () {
                                indexValue = bccData[index]['id'];
                                indexName = bccData[index]['name'];
                                assignValues(indexValue, indexName);
                              },
                              child: Padding(
                                padding: const EdgeInsets.only(left: 5, right: 5),
                                child: Card(
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(15),
                                  ),
                                  child: Container(
                                    padding: const EdgeInsets.only(left: 10, top: 10, bottom: 10),
                                    child: Row(
                                      children: [
                                        GestureDetector(
                                          onTap: () {
                                            showDialog(
                                              context: context,
                                              builder: (BuildContext context) {
                                                return Dialog(
                                                  child: Image.asset('assets/images/bcc.png', fit: BoxFit.cover,),
                                                );
                                              },
                                            );
                                          },
                                          child: Container(
                                            height: size.height * 0.09,
                                            width: size.width * 0.16,
                                            decoration: BoxDecoration(
                                              borderRadius: BorderRadius.circular(10),
                                              color: whiteColor,
                                              // boxShadow: const <BoxShadow>[
                                              //   BoxShadow(
                                              //     color: Colors.grey,
                                              //     spreadRadius: -1,
                                              //     blurRadius: 5 ,
                                              //     offset: Offset(0, 1),
                                              //   ),
                                              // ],
                                              shape: BoxShape.rectangle,
                                              image: const DecorationImage(
                                                fit: BoxFit.contain,
                                                image: AssetImage('assets/images/bcc.png'),
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
                                                        bccData[index]['name'],
                                                        style: GoogleFonts.secularOne(
                                                            fontSize: size.height * 0.02,
                                                            color: textColor
                                                        ),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                                bccData[index]['heads_ids'] != [] && bccData[index]['heads_ids'].isNotEmpty ? SizedBox(height: size.height * 0.005,) : Container(),
                                                bccData[index]['heads_ids'] != [] && bccData[index]['heads_ids'].isNotEmpty ? ListView.builder(
                                                  shrinkWrap: true,
                                                  scrollDirection: Axis.vertical,
                                                  itemCount: 1,
                                                  itemBuilder: (BuildContext context, int indexs) {
                                                    return Column(
                                                      children: [
                                                        Row(
                                                          children: [
                                                            bccData[index]['heads_ids'][indexs]['member_id']['member_name'] != '' ? Flexible(
                                                              child: RichText(
                                                                textAlign: TextAlign.left,
                                                                text: TextSpan(
                                                                    text: bccData[index]['heads_ids'][indexs]['member_id']['member_name'],
                                                                    style: GoogleFonts.secularOne(
                                                                        fontSize: size.height * 0.017,
                                                                        color: blackColor,
                                                                        fontStyle: FontStyle.italic
                                                                    ),
                                                                    children: bccData[index]['heads_ids'][indexs]['role'] != null && bccData[index]['heads_ids'][indexs]['role'] != '' ? [
                                                                      const TextSpan(
                                                                        text: '  ',
                                                                      ),
                                                                      TextSpan(
                                                                        text: '(${bccData[index]['heads_ids'][indexs]['role']})',
                                                                        style: TextStyle(
                                                                            fontSize: size.height * 0.017,
                                                                            color: emptyColor,
                                                                            fontStyle: FontStyle.italic
                                                                        ),
                                                                      ),
                                                                    ] : []
                                                                ),
                                                              ),
                                                            ) : Container(),
                                                          ],
                                                        ),
                                                        SizedBox(
                                                          height: size.height * 0.005,
                                                        ),
                                                      ],
                                                    );
                                                  },
                                                ) : Container(),
                                                SizedBox(height: size.height * 0.005,),
                                                Row(
                                                  children: [
                                                    bccData[index]['parish_family_count'] != '' && bccData[index]['parish_family_count'] != null ? GestureDetector(
                                                      onTap: () {
                                                        indexValue = bccData[index]['id'];
                                                        indexName = bccData[index]['name'];
                                                        assignValues(indexValue, indexName);
                                                      },
                                                      child: Container(
                                                        padding: const EdgeInsets.only(top: 5, bottom: 5, left: 8, right: 8),
                                                        decoration: BoxDecoration(
                                                          borderRadius: BorderRadius.circular(5),
                                                          color: customBackgroundColor2,
                                                        ),
                                                        child: RichText(
                                                          text: TextSpan(
                                                              text: bccData[index]['parish_family_count'].toString(),
                                                              style: TextStyle(
                                                                  letterSpacing: 1,
                                                                  fontSize: size.height * 0.017,
                                                                  fontWeight: FontWeight.bold,
                                                                  color: customTextColor2,
                                                                  fontStyle: FontStyle.italic
                                                              ),
                                                              children: <InlineSpan>[
                                                                bccData[index]['parish_family_count'] == 1 ? TextSpan(
                                                                  text: ' Family',
                                                                  style: TextStyle(
                                                                      letterSpacing: 1,
                                                                      fontSize: size.height * 0.017,
                                                                      fontWeight: FontWeight.bold,
                                                                      color: customTextColor2,
                                                                      fontStyle: FontStyle.italic
                                                                  ),
                                                                ) : TextSpan(
                                                                  text: " Families",
                                                                  style: TextStyle(
                                                                      letterSpacing: 1,
                                                                      fontSize: size.height * 0.017,
                                                                      fontWeight: FontWeight.bold,
                                                                      color: customTextColor2,
                                                                      fontStyle: FontStyle.italic
                                                                  ),
                                                                )
                                                              ]
                                                          ),
                                                        ),
                                                      ),
                                                    ) : Container(),
                                                    bccData[index]['parish_members_count'] != '' && bccData[index]['parish_members_count'] != null ? SizedBox(
                                                      width: size.width * 0.05,
                                                    ) : Container(),
                                                    bccData[index]['parish_members_count'] != '' && bccData[index]['parish_members_count'] != null ? GestureDetector(
                                                      onTap: () {
                                                        indexValue = bccData[index]['id'];
                                                        indexName = bccData[index]['name'];
                                                        assignBCCMembersValues(indexValue, indexName);
                                                      },
                                                      child: Container(
                                                        padding: const EdgeInsets.only(top: 5, bottom: 5, left: 8, right: 8),
                                                        decoration: BoxDecoration(
                                                          borderRadius: BorderRadius.circular(5),
                                                          color: customBackgroundColor1,
                                                        ),
                                                        child: RichText(
                                                          text: TextSpan(
                                                              text: bccData[index]['parish_members_count'].toString(),
                                                              style: TextStyle(
                                                                  letterSpacing: 1,
                                                                  fontSize: size.height * 0.017,
                                                                  fontWeight: FontWeight.bold,
                                                                  color: customTextColor1,
                                                                  fontStyle: FontStyle.italic
                                                              ),
                                                              children: <InlineSpan>[
                                                                bccData[index]['parish_members_count'] == 1 ? TextSpan(
                                                                  text: ' Member',
                                                                  style: TextStyle(
                                                                      letterSpacing: 1,
                                                                      fontSize: size.height * 0.017,
                                                                      fontWeight: FontWeight.bold,
                                                                      color: customTextColor1,
                                                                      fontStyle: FontStyle.italic
                                                                  ),
                                                                ) : TextSpan(
                                                                  text: ' Members',
                                                                  style: TextStyle(
                                                                      letterSpacing: 1,
                                                                      fontSize: size.height * 0.017,
                                                                      fontWeight: FontWeight.bold,
                                                                      color: customTextColor1,
                                                                      fontStyle: FontStyle.italic
                                                                  ),
                                                                )
                                                              ]
                                                          ),
                                                        ),
                                                      ),
                                                    ) : Container(),
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
                            );
                          },
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
              )
            ],
          ),
        ),
      ),
    );
  }
}
