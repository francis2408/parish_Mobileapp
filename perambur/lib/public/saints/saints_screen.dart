import 'dart:async';
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

import 'saints_detail_screen.dart';

class PublicAllSaintsScreen extends StatefulWidget {
  const PublicAllSaintsScreen({Key? key}) : super(key: key);

  @override
  State<PublicAllSaintsScreen> createState() => _PublicAllSaintsScreenState();
}

class _PublicAllSaintsScreenState extends State<PublicAllSaintsScreen> {
  int selected = -1;
  late ScrollController _controller;
  int page = 1;
  int limit = 30;

  bool _showContainer = false;
  Timer? _containerTimer;
  bool _isLoading = true;
  bool _hasNextPage = true;
  bool _isLoadMoreRunning = false;
  bool _isSearch = false;
  bool isSearchTrue = false;
  String saintCount = '';
  String limitCount = '';
  String searchName = '';
  var searchController = TextEditingController();

  List data = [];
  List saintListData = [];
  List saint = [];
  List results = [];

  int? indexValue;
  String indexName = '';

  RegExp exp = RegExp(r"<[^>]*>",multiLine: true,caseSensitive: true);
  final format = DateFormat("dd-MM-yyyy");

  void _loadMore() async {
    if (_hasNextPage == true &&
        _isLoading == false &&
        _isLoadMoreRunning == false &&
        _controller.position.extentAfter < 500) {
      setState(() {
        _isLoadMoreRunning = true;
      });
      // Cancel the previous timer if it exists
      _containerTimer?.cancel();
      page += 1;
      var request = http.Request('GET', Uri.parse("$baseUrl/public/masters/res.saints"));
      request.body = json.encode({
        "params": {
          "page_size": limit,
          "page": page,
          "query": "{name,description,feast_day,feast_month,year_of_birth,year_of_death,image_512}"
        }
      });
      request.headers.addAll(headers);
      http.StreamedResponse response = await request.send();

      if (response.statusCode == 200) {
        var decode = json.decode(await response.stream.bytesToString())['result'];
        final List fetchedPosts = decode['result'];
        if (fetchedPosts.isNotEmpty) {
          setState(() {
            saint.addAll(fetchedPosts);
            limitCount = saint.length.toString();
          });
        } else {
          setState(() {
            _hasNextPage = false;
            _showContainer = true;
          });
          // Start the timer to auto-close the container after 2 seconds
          _containerTimer = Timer(const Duration(seconds: 2), () {
            setState(() {
              _showContainer = false;
            });
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
      setState(() {
        _isLoadMoreRunning = false;
      });
    }
  }

  void getSaintsData() async {
    setState(() {
      _isLoading = true;
    });
    var request = http.Request('GET', Uri.parse("$baseUrl/public/masters/res.saints"));
    request.body = json.encode({
      "params": {
        "page_size": limit,
        "page": page,
        "query": "{name,description,feast_day,feast_month,year_of_birth,year_of_death,image_512}"
      }
    });
    request.headers.addAll(headers);
    http.StreamedResponse response = await request.send();

    if (response.statusCode == 200) {
      var decode = json.decode(await response.stream.bytesToString())['result'];
      if(decode['status'] == 'success') {
        saintCount = decode['count'].toString();
        data = decode['result'];
        setState(() {
          _isLoading = false;
        });
        saint = data;
        limitCount = saint.length.toString();
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

    setState(() {
      _isLoading = false;
    });
  }

  Future<void> getSaintsListData(String searchWord) async {
    searchName = searchWord;
    setState(() {
      _isSearch = true;
    });
    var request = http.Request('GET', Uri.parse("$baseUrl/public/masters/res.saints"));
    request.body = json.encode({
      "params": {
        "query": "{name,description,feast_day,feast_month,year_of_birth,year_of_death,image_512}"
      }
    });
    request.headers.addAll(headers);
    http.StreamedResponse response = await request.send();

    if (response.statusCode == 200) {
      var decode = json.decode(await response.stream.bytesToString())['result'];
      if(decode['status'] == 'success') {
        saintListData = decode['result'];
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
    setState(() {
      _isSearch = false;
    });
  }

  void loadDataWithDelay() {
    Future.delayed(const Duration(seconds: 1), () {
      getSaintsData();
      _controller = ScrollController()..addListener(_loadMore);
    });
  }

  searchData(String searchWord) async {
    var values = [];
    if (searchWord.isEmpty) {
      setState(() {
        results = [];
        isSearchTrue = false;
      });
    } else {
      await getSaintsListData(searchWord); // Wait for data to be fetched
      values = saintListData
          .where((user) =>
          user['name'].toLowerCase().contains(searchWord.toLowerCase()))
          .toList();

      setState(() {
        results = values; // Update the results list with filtered data
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
    loadDataWithDelay();
  }

  @override
  void dispose() {
    // Cancel the timer when the screen is disposed
    _containerTimer?.cancel();
    super.dispose();
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
              saint.isNotEmpty ? Padding(
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
              ) : Container(),
              SizedBox(
                height: size.height * 0.01,
              ),
              Expanded(
                child: _isSearch ? Center(
                  child: SizedBox(
                    height: size.height * 0.06,
                    child: const LoadingIndicator(
                      indicatorType: Indicator.ballSpinFadeLoader,
                      colors: [Colors.red,Colors.orange,Colors.yellow,Colors.green,Colors.blue,Colors.indigo,Colors.purple,],
                    ),
                  ),
                ) : isSearchTrue ? results.isNotEmpty ? Column(
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
                      child: Scrollbar(
                        thumbVisibility: true,
                        interactive: true,
                        radius: const Radius.circular(15),
                        thickness: 8,
                        child: SlideFadeAnimation(
                          duration: const Duration(seconds: 1),
                          child: ListView.builder(
                            itemCount: results.length,
                            itemBuilder: (BuildContext context, int index) {
                              return Padding(
                                padding: const EdgeInsets.only(left: 5, right: 5),
                                child: GestureDetector(
                                  onTap: () {
                                    setState(() {
                                      Navigator.push(context, MaterialPageRoute(builder: (context) {return PublicSaintsDetailsScreen(image: results[index]['image_512'], name: results[index]['name'], birth: results[index]['year_of_birth'], death: results[index]['year_of_death'], feastDay: results[index]['feast_day'], feastMonth: results[index]['feast_month_label'], description: results[index]['description']);}));
                                    });
                                  },
                                  child: Card(
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(15),
                                    ),
                                    child: Row(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        GestureDetector(
                                          onTap: () {
                                            results[index]['image_512'] != '' ? showDialog(
                                              context: context,
                                              builder: (BuildContext context) {
                                                return Dialog(
                                                  child: Image.network(results[index]['image_512'], fit: BoxFit.cover,),
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
                                            height: size.height * 0.11,
                                            width: size.width * 0.22,
                                            decoration: BoxDecoration(
                                              borderRadius: const BorderRadius.only(topLeft: Radius.circular(15), bottomLeft: Radius.circular(15)),
                                              shape: BoxShape.rectangle,
                                              image: DecorationImage(
                                                fit: BoxFit.fill,
                                                image: results[index]['image_512'] != null && results[index]['image_512'] != ''
                                                    ? NetworkImage(results[index]['image_512'])
                                                    : const AssetImage('assets/images/no_image.jpg') as ImageProvider,
                                              ),
                                            ),
                                          ),
                                        ),
                                        Expanded(
                                          child: Container(
                                            padding: const EdgeInsets.only(top: 5, bottom: 5, left: 10, right: 10),
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
                                                          color: textColor,
                                                        ),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                                SizedBox(
                                                  height: size.height * 0.005,
                                                ),
                                                Row(
                                                  children: [
                                                    results[index]['feast_day'] != '' && results[index]['feast_day'] != null ? Text(
                                                      results[index]['feast_day'],
                                                      style: GoogleFonts.roboto(
                                                        fontSize: size.height * 0.018,
                                                        color: textHeadColor,
                                                      ),
                                                    ) : Container(),
                                                    results[index]['feast_day'] != '' && results[index]['feast_day'] != null ? Text(
                                                      ' - ',
                                                      style: GoogleFonts.roboto(
                                                        fontSize: size.height * 0.018,
                                                        color: textHeadColor,
                                                      ),
                                                    ) : Container(),
                                                    Text(
                                                      results[index]['feast_month_label'],
                                                      style: GoogleFonts.roboto(
                                                        fontSize: size.height * 0.018,
                                                        color: textHeadColor,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                                SizedBox(
                                                  height: size.height * 0.005,
                                                ),
                                                Row(
                                                  children: [
                                                    results[index]['description'] != null && results[index]['description'] != '' && results[index]['description'].replaceAll(exp, '') != '' ? Flexible(
                                                      child: Text(
                                                        results[index]['description'].replaceAll(exp, ''),
                                                        maxLines: 2,
                                                        overflow: TextOverflow.ellipsis,
                                                        style: TextStyle(fontSize: size.height * 0.016, color: labelColor),
                                                        textAlign: TextAlign.justify,
                                                      ),
                                                    ) : Flexible(
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
                                                )
                                              ],
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
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
                    saint.isNotEmpty ? Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(right: 5),
                          child: Text('Showing 1 - $limitCount', style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: countLabel),),
                        ),
                      ],
                    ) : Container(),
                    saint.isNotEmpty ? SizedBox(
                      height: size.height * 0.01,
                    ) : Container(),
                    saint.isNotEmpty ? Expanded(
                      child: Scrollbar(
                        thumbVisibility: true,
                        interactive: true,
                        radius: const Radius.circular(15),
                        thickness: 8,
                        child: SlideFadeAnimation(
                          duration: const Duration(seconds: 1),
                          child: ListView.builder(
                            controller: _controller,
                            itemCount: saint.length,
                            itemBuilder: (BuildContext context, int index) {
                              return Padding(
                                padding: const EdgeInsets.only(left: 5, right: 5),
                                child: GestureDetector(
                                  onTap: () {
                                    setState(() {
                                      Navigator.push(context, MaterialPageRoute(builder: (context) {return PublicSaintsDetailsScreen(image: saint[index]['image_512'], name: saint[index]['name'], birth: saint[index]['year_of_birth'], death: saint[index]['year_of_death'], feastDay: saint[index]['feast_day'], feastMonth: saint[index]['feast_month_label'], description: saint[index]['description']);}));
                                    });
                                  },
                                  child: Card(
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(15),
                                    ),
                                    child: Row(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        GestureDetector(
                                          onTap: () {
                                            saint[index]['image_512'] != '' ? showDialog(
                                              context: context,
                                              builder: (BuildContext context) {
                                                return Dialog(
                                                  child: Image.network(saint[index]['image_512'], fit: BoxFit.cover,),
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
                                            height: size.height * 0.11,
                                            width: size.width * 0.22,
                                            decoration: BoxDecoration(
                                              borderRadius: const BorderRadius.only(topLeft: Radius.circular(15), bottomLeft: Radius.circular(15)),
                                              shape: BoxShape.rectangle,
                                              image: DecorationImage(
                                                fit: BoxFit.fill,
                                                image: saint[index]['image_512'] != null && saint[index]['image_512'] != ''
                                                    ? NetworkImage(saint[index]['image_512'])
                                                    : const AssetImage('assets/images/no_image.jpg') as ImageProvider,
                                              ),
                                            ),
                                          ),
                                        ),
                                        Expanded(
                                          child: Container(
                                            padding: const EdgeInsets.only(top: 5, bottom: 5, left: 10, right: 10),
                                            child: Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                Row(
                                                  children: [
                                                    Flexible(
                                                      child: Text(
                                                        saint[index]['name'],
                                                        style: GoogleFonts.secularOne(
                                                          fontSize: size.height * 0.02,
                                                          color: textColor,
                                                        ),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                                SizedBox(
                                                  height: size.height * 0.005,
                                                ),
                                                Row(
                                                  children: [
                                                    saint[index]['feast_day'] != '' && saint[index]['feast_day'] != null ? Text(
                                                      saint[index]['feast_day'],
                                                      style: GoogleFonts.roboto(
                                                        fontSize: size.height * 0.018,
                                                        color: textHeadColor,
                                                      ),
                                                    ) : Container(),
                                                    saint[index]['feast_day'] != '' && saint[index]['feast_day'] != null ? Text(
                                                      ' - ',
                                                      style: GoogleFonts.roboto(
                                                        fontSize: size.height * 0.018,
                                                        color: textHeadColor,
                                                      ),
                                                    ) : Container(),
                                                    Text(
                                                      saint[index]['feast_month_label'],
                                                      style: GoogleFonts.roboto(
                                                        fontSize: size.height * 0.018,
                                                        color: textHeadColor,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                                SizedBox(
                                                  height: size.height * 0.005,
                                                ),
                                                Row(
                                                  children: [
                                                    saint[index]['description'] != null && saint[index]['description'] != '' && saint[index]['description'].replaceAll(exp, '') != '' ? Flexible(
                                                      child: Text(
                                                        saint[index]['description'].replaceAll(exp, ''),
                                                        maxLines: 2,
                                                        overflow: TextOverflow.ellipsis,
                                                        style: TextStyle(fontSize: size.height * 0.016, color: labelColor),
                                                        textAlign: TextAlign.justify,
                                                      ),
                                                    ) : Flexible(
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
                            },
                          ),
                        ),
                      ),
                    ) : Expanded(
                      child: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              padding: const EdgeInsets.only(left: 30, right: 30),
                              child: NoResult(
                                onPressed: () {
                                  setState(() {
                                    Navigator.pop(context);
                                  });
                                },
                                text: 'No Data available',
                              ),
                            )
                          ],
                        ),
                      ),
                    ),
                    if (_isLoadMoreRunning == true)
                      Padding(
                        padding: EdgeInsets.only(top: size.height * 0.01, bottom: size.width * 0.01),
                        child: Center(
                          child: SizedBox(
                            height: size.height * 0.06,
                            child: const LoadingIndicator(
                              indicatorType: Indicator.ballSpinFadeLoader,
                              colors: [Colors.red,Colors.orange,Colors.yellow,Colors.green,Colors.blue,Colors.indigo,Colors.purple,],
                            ),
                          ),
                        ),
                      ),
                    if (_hasNextPage == false)
                      AnimatedContainer(
                        duration: const Duration(seconds: 1),
                        height: _showContainer ? 40 : 0,
                        color: Colors.grey,
                        child: const Center(
                          child: Text('You have fetched all of the saints data'),
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
