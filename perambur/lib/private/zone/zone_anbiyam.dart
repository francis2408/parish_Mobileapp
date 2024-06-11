import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:loading_indicator/loading_indicator.dart';
import 'package:perambur/private/anbiyam/anbiyam_tab.dart';
import 'package:perambur/private/family/anbiyam_family.dart';
import 'package:perambur/private/members/anbiyam_members.dart';
import 'package:perambur/widget/common/common.dart';
import 'package:perambur/widget/common/internet_connection_checker.dart';
import 'package:perambur/widget/common/slide_animations.dart';
import 'package:perambur/widget/theme_color/theme_color.dart';
import 'package:perambur/widget/widget.dart';

class ZoneAnbiyamScreen extends StatefulWidget {
  final String name;
  const ZoneAnbiyamScreen({Key? key, required this.name}) : super(key: key);

  @override
  State<ZoneAnbiyamScreen> createState() => _ZoneAnbiyamScreenState();
}

class _ZoneAnbiyamScreenState extends State<ZoneAnbiyamScreen> {
  bool _isLoading = true;
  List anbiyam = [];
  List data = [];
  String searchName = '';
  var searchController = TextEditingController();

  getAnbiyamData() async {
    var request = http.Request('GET', Uri.parse('$baseUrl/res.parish.bcc'));
    request.body = json.encode({
      "params": {
        "params": {
          "filter": "[['zone_id.id','=',${int.parse(zoneId)}]]",
          "query": "{name,substation_id,in_charge,category_id,zone_id,parish_family_count,parish_members_count}",
        }
      }
    });
    request.headers.addAll(header);
    http.StreamedResponse response = await request.send();
    if (response.statusCode == 200) {
      var decode = json.decode(await response.stream.bytesToString())['result']['data'];
      if(decode['status'] == 'success') {
        var datas = decode['result'];
        for(var val in datas) {
          if (val['zone_id']['id'] == int.parse(zoneId)) {
            data.add(val);
          }
        }
        anbiyam = data;
        setState(() {
          _isLoading = false;
        });
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
      anbiyam = results;
    });
  }

  changeData() {
    setState(() {
      _isLoading = true;
      data.clear();
      anbiyam.clear();
      getAnbiyamData();
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
    getAnbiyamData();
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
            widget.name,
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
                    Text('${anbiyam.length}', style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: countValue),)
                  ],
                ),
              ),
              SizedBox(
                height: size.height * 0.01,
              ),
              anbiyam.isNotEmpty ? Expanded(
                child: SlideFadeAnimation(
                  duration: const Duration(seconds: 1),
                  child: SingleChildScrollView(
                    child: ListView.builder(
                        key: UniqueKey(),
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: anbiyam.length,
                        itemBuilder: (BuildContext context, int index) {
                          return Column(
                            children: [
                              GestureDetector(
                                onTap: () async {
                                  bccId = anbiyam[index]['id'].toString();
                                  String refresh = await Navigator.push(context, CustomRoute(widget: AnbiyamDetailTab(name: anbiyam[index]['name'],)));
                                  if(refresh == 'refresh') {
                                    changeData();
                                  }
                                },
                                child: Card(
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(15),
                                  ),
                                  child: Padding(
                                    padding: const EdgeInsets.only(top: 5, bottom: 5),
                                    child: ListTile(
                                      leading: Container(
                                        height: size.height * 0.06,
                                        width: size.width * 0.13,
                                        decoration: BoxDecoration(
                                          color: Colors.teal.shade700.withOpacity(0.8),
                                          shape: BoxShape.rectangle,
                                          borderRadius: BorderRadius.circular(10),
                                        ),
                                        child: Center(
                                            child: IconButton(
                                              icon: SvgPicture.asset("assets/icons/anbiyam.svg", color: whiteColor),
                                              iconSize: 60,
                                              onPressed: () {},
                                            )
                                        ),
                                      ),
                                      title: Text(
                                        anbiyam[index]['name'],
                                        style: GoogleFonts.roboto(
                                          fontSize: size.height * 0.018,
                                          color: blackColor,
                                          fontWeight: FontWeight.w700,
                                        ),
                                      ),
                                      subtitle: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          if (anbiyam[index]['in_charge'] != '') SizedBox(height: size.height * 0.01,),
                                          if (anbiyam[index]['in_charge'] != '') Text(
                                            anbiyam[index]['in_charge'],
                                            style: TextStyle(
                                              fontSize: size.height * 0.015,
                                              fontWeight: FontWeight.bold,
                                              color: textHeadColor,
                                            ),
                                          ),
                                          SizedBox(height: size.height * 0.01,),
                                          Row(
                                            children: [
                                              anbiyam[index]['parish_family_count'] != '' && anbiyam[index]['parish_family_count'] != null && anbiyam[index]['parish_family_count'] != 0 ? GestureDetector(
                                                onTap: () async {
                                                  bccId = anbiyam[index]['id'].toString();
                                                  String refresh = await Navigator.push(context, CustomRoute(widget: AnbiyamFamilyScreen(name: anbiyam[index]['name'],)));
                                                  if(refresh == 'refresh') {
                                                    changeData();
                                                  }
                                                },
                                                child: Container(
                                                  padding: const EdgeInsets.only(top: 5, bottom: 5, left: 8, right: 8),
                                                  decoration: BoxDecoration(
                                                    borderRadius: BorderRadius.circular(5),
                                                    color: customBackgroundColor1,
                                                  ),
                                                  child: RichText(
                                                    text: TextSpan(
                                                        text: anbiyam[index]['parish_family_count'].toString(),
                                                        style: TextStyle(
                                                            letterSpacing: 1,
                                                            fontSize: size.height * 0.015,
                                                            fontWeight: FontWeight.bold,
                                                            color: customTextColor1,
                                                            fontStyle: FontStyle.italic
                                                        ),
                                                        children: <InlineSpan>[
                                                          anbiyam[index]['parish_family_count'] == 1 ? TextSpan(
                                                            text: ' Family',
                                                            style: TextStyle(
                                                                letterSpacing: 1,
                                                                fontSize: size.height * 0.015,
                                                                fontWeight: FontWeight.bold,
                                                                color: customTextColor1,
                                                                fontStyle: FontStyle.italic
                                                            ),
                                                          ) : TextSpan(
                                                            text: ' Families',
                                                            style: TextStyle(
                                                                letterSpacing: 1,
                                                                fontSize: size.height * 0.015,
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
                                              SizedBox(
                                                width: size.width * 0.05,
                                              ),
                                              anbiyam[index]['parish_members_count'] != '' && anbiyam[index]['parish_members_count'] != null && anbiyam[index]['parish_members_count'] != 0 ? GestureDetector(
                                                onTap: () async {
                                                  bccId = anbiyam[index]['id'].toString();
                                                  String refresh = await Navigator.push(context, CustomRoute(widget: AnbiyamMembersScreen(name: anbiyam[index]['name'],)));
                                                  if(refresh == 'refresh') {
                                                    changeData();
                                                  }
                                                },
                                                child: Container(
                                                  padding: const EdgeInsets.only(top: 5, bottom: 5, left: 8, right: 8),
                                                  decoration: BoxDecoration(
                                                    borderRadius: BorderRadius.circular(5),
                                                    color: customBackgroundColor2,
                                                  ),
                                                  child: RichText(
                                                    text: TextSpan(
                                                        text: anbiyam[index]['parish_members_count'].toString(),
                                                        style: TextStyle(
                                                            letterSpacing: 1,
                                                            fontSize: size.height * 0.015,
                                                            fontWeight: FontWeight.bold,
                                                            color: customTextColor2,
                                                            fontStyle: FontStyle.italic
                                                        ),
                                                        children: <InlineSpan>[
                                                          anbiyam[index]['parish_members_count'] == 1 ? TextSpan(
                                                            text: ' Member',
                                                            style: TextStyle(
                                                                letterSpacing: 1,
                                                                fontSize: size.height * 0.015,
                                                                fontWeight: FontWeight.bold,
                                                                color: customTextColor2,
                                                                fontStyle: FontStyle.italic
                                                            ),
                                                          ) : TextSpan(
                                                            text: ' Members',
                                                            style: TextStyle(
                                                                letterSpacing: 1,
                                                                fontSize: size.height * 0.015,
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
                                            ],
                                          ),
                                        ],
                                      ),
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
              ) : Expanded(
                child: Center(
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
            ],
          ),
        ),
      ),
    );
  }
}
