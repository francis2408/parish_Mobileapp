import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:loading_indicator/loading_indicator.dart';
import 'package:munchirai/private/screens/family/family_detail_tab.dart';
import 'package:munchirai/private/screens/family/family_members.dart';
import 'package:munchirai/widget/common/common.dart';
import 'package:munchirai/widget/common/internet_connection_checker.dart';
import 'package:munchirai/widget/common/slide_animations.dart';
import 'package:munchirai/widget/theme_color/theme_color.dart';
import 'package:munchirai/widget/widget.dart';
import 'package:url_launcher/url_launcher.dart';

class BccFamilyScreen extends StatefulWidget {
  const BccFamilyScreen({Key? key}) : super(key: key);

  @override
  State<BccFamilyScreen> createState() => _BccFamilyScreenState();
}

class _BccFamilyScreenState extends State<BccFamilyScreen> {
  final ClearSharedPreference shared = ClearSharedPreference();
  late ScrollController _controller;
  int page = 1;
  int limit = 20;

  bool _showContainer = false;
  Timer? _containerTimer;
  bool _isLoading = true;
  bool _hasNextPage = true;
  bool _isLoadMoreRunning = false;
  bool _isSearch = false;
  bool isSearchTrue = false;
  String membersCount = '';
  String limitCount = '';
  String searchName = '';
  var searchController = TextEditingController();

  List data = [];
  List membersListData = [];
  List members = [];
  List results = [];

  int? indexValue;
  String indexName = '';

  void _loadMore() async {
    if (_hasNextPage == true &&
        _isLoading == false &&
        _isLoadMoreRunning == false &&
        _controller.position.extentAfter < 500) {
      setState(() {
        _isLoadMoreRunning = true; // Display a progress indicator at the bottom
      });
      // Cancel the previous timer if it exists
      _containerTimer?.cancel();
      page += 1;
      var request = http.Request('GET', Uri.parse("$baseUrl/res.family/"));
      request.body = json.encode({
        "params": {
          "filter": "[['parish_bcc_id','=',$bccId]]",
          "order": "name asc",
          "page_size": limit,
          "page": page,
          "query": "{id,name,image_512,parish_bcc_id{name,heads_ids{member_id,role,status}},family_head_id{member_name},register_date,family_register_number,reference,mobile,parish_members_count}",
        }
      });
      request.headers.addAll(header);
      http.StreamedResponse response = await request.send();

      if (response.statusCode == 200) {
        var decode = json.decode(await response.stream.bytesToString())['result'];
        if(decode['status'] == true) {
          final List fetchedPosts = decode['data']['result'];
          if (fetchedPosts.isNotEmpty) {
            setState(() {
              members.addAll(fetchedPosts);
              limitCount = members.length.toString();
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

  void getBccFamilyData() async {
    setState(() {
      _isLoading = true;
    });
    var request = http.Request('GET', Uri.parse("$baseUrl/res.family/"));
    request.body = json.encode({
      "params": {
        "filter": "[['parish_bcc_id','=',$bccId]]",
        "order": "name asc",
        "page_size": limit,
        "page": page,
        "query": "{id,name,image_512,parish_bcc_id{name,heads_ids{member_id,role,status}},family_head_id{member_name},register_date,family_register_number,reference,mobile,parish_members_count}",
      }
    });
    request.headers.addAll(header);
    http.StreamedResponse response = await request.send();

    if (response.statusCode == 200) {
      var decode = json.decode(await response.stream.bytesToString())['result'];
      if(decode['status'] == true) {
        membersCount = decode['data']['total_count'].toString();
        data = decode['data']['result'];
        setState(() {
          _isLoading = false;
        });
        members = data;
        limitCount = members.length.toString();
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

  Future<void> getBccFamilyListData(String searchWord) async {
    searchName = searchWord;
    setState(() {
      _isSearch = true;
    });
    var request = http.Request('GET', Uri.parse("$baseUrl/res.family/"));
    request.body = json.encode({
      "params": {
        "filter": "[['parish_bcc_id','=',$bccId]]",
        "order": "name asc",
        "query": "{id,name,image_512,parish_bcc_id{name,heads_ids{member_id,role,status}},family_head_id{member_name},register_date,family_register_number,reference,mobile,parish_members_count}",
      }
    });
    request.headers.addAll(header);
    http.StreamedResponse response = await request.send();

    if (response.statusCode == 200) {
      var decode = json.decode(await response.stream.bytesToString())['result'];
      if(decode['status'] == true) {
        membersListData = decode['data']['result'];
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

  assignValues(indexValue, indexName) async {
    familyId = indexValue.toString();
    await Navigator.push(context, CustomRoute(widget: FamilyDetailsTabScreen(title: indexName)));
  }

  assignFamilyMembersValues(indexValue, indexName) async {
    familyId = indexValue.toString();
    appbarVisible = true;
    await Navigator.push(context, CustomRoute(widget: FamilyMembersScreen(title: indexName,)));
  }

  Future<void> smsAction(String number) async {
    final Uri uri = Uri(scheme: "sms", path: number);
    if(!await launchUrl(uri, mode: LaunchMode.externalApplication,)) {
      throw "Can not launch url";
    }
  }

  Future<void> callAction(String number) async {
    final Uri uri = Uri(scheme: 'tel', path: number);
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      throw 'Can not launch URL';
    }
  }

  Future<void> whatsappAction(String whatsapp) async {
    String? countryCode = extractCountryCode(whatsapp);

    if (countryCode != null) {
      // Perform the WhatsApp action here.
      if (Platform.isAndroid) {
        final whatsappUrl = 'whatsapp://send?phone=$whatsapp';
        await canLaunch(whatsappUrl) ? launch(whatsappUrl) : throw "Can not launch URL";
      } else {
        final whatsappUrl = 'https://api.whatsapp.com/send?phone=$whatsapp';
        await canLaunch(whatsappUrl) ? launch(whatsappUrl) : throw "Can not launch URL";
      }
    } else {
      // Remove any non-digit characters from the phone number
      final cleanNumber = whatsapp.replaceAll(RegExp(r'\D'), '');
      // Extract the country code from the WhatsApp number
      const countryCode = '91'; // Assuming country code length is 2
      // Add the country code if it's missing
      final formattedNumber = cleanNumber.startsWith(countryCode)
          ? cleanNumber
          : countryCode + cleanNumber;
      if (Platform.isAndroid) {
        final whatsappUrl = 'whatsapp://send?phone=$formattedNumber';
        await canLaunch(whatsappUrl) ? launch(whatsappUrl) : throw "Can not launch URL";
      } else {
        final whatsappUrl = 'https://api.whatsapp.com/send?phone=$formattedNumber';
        await canLaunch(whatsappUrl) ? launch(whatsappUrl) : throw "Can not launch URL";
      }
    }
  }

  String? extractCountryCode(String whatsappNumber) {
    if (whatsappNumber != null && whatsappNumber.isNotEmpty) {
      if (whatsappNumber.startsWith('+')) {
        // The country code is assumed to be present at the beginning of the number.
        int endIndex = whatsappNumber.indexOf(' ');
        return endIndex != -1 ? whatsappNumber.substring(1, endIndex) : whatsappNumber.substring(1);
      }
    }
    return null; // Country code not found.
  }

  searchData(String searchWord) async {
    var values = [];
    if (searchWord.isEmpty) {
      setState(() {
        results = [];
        isSearchTrue = false;
      });
    } else {
      await getBccFamilyListData(searchWord); // Wait for data to be fetched
      values = membersListData
          .where((user) =>
          user['name'].toLowerCase().contains(searchWord.toLowerCase()))
          .toList();

      setState(() {
        results = values; // Update the results list with filtered data
      });
    }
  }

  void loadDataWithDelay() {
    Future.delayed(const Duration(seconds: 1), () {
      getBccFamilyData();
      _controller = ScrollController()..addListener(_loadMore);
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
    if(expiryDateTime!.isAfter(currentDateTime)) {
      loadDataWithDelay();
    } else {
      setState(() {
        shared.clearSharedPreferenceData(context);
      });
    }
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
              members.isNotEmpty ? Padding(
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
                          child: Text('Showing 1 - ${results.length} of $membersCount', style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: countLabel),),
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
                              return GestureDetector(
                                onTap: () {
                                  indexValue = results[index]['id'];
                                  indexName = results[index]['name'];
                                  assignValues(indexValue, indexName);
                                },
                                child: Stack(
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.only(left: 5, right: 5),
                                      child: Card(
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(15),
                                        ),
                                        child: Container(
                                          padding: const EdgeInsets.only(left: 10, top: 10, bottom: 10),
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
                                                        child: Image.asset('assets/images/family.png', fit: BoxFit.cover,),
                                                      );
                                                    },
                                                  );
                                                },
                                                child: Container(
                                                  height: size.height * 0.1,
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
                                                    image: DecorationImage(
                                                      fit: BoxFit.cover,
                                                      image: results[index]['image_512'] != null && results[index]['image_512'] != ''
                                                          ? NetworkImage(results[index]['image_512'])
                                                          : const AssetImage('assets/images/family.png') as ImageProvider,
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
                                                      results[index]['family_head_id']['member_name'] != null && results[index]['family_head_id']['member_name'] != '' ? Row(
                                                        children: [
                                                          Flexible(
                                                            child: RichText(
                                                              textAlign: TextAlign.center,
                                                              text: TextSpan(
                                                                  text: results[index]['name'],
                                                                  style: GoogleFonts.secularOne(
                                                                      fontSize: size.height * 0.02,
                                                                      color: textColor
                                                                  ),
                                                                  children: [
                                                                    const TextSpan(text: '  '),
                                                                    TextSpan(
                                                                      text: "( Family Head )",
                                                                      style: GoogleFonts.secularOne(
                                                                          fontSize: size.height * 0.017,
                                                                          color: emptyColor,
                                                                          fontStyle: FontStyle.italic
                                                                      ),
                                                                    ),
                                                                  ]),
                                                            ),
                                                          ),
                                                        ],
                                                      ) : Row(
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
                                                      results[index]['reference'] != null && results[index]['reference'] != '' ? Row(
                                                        children: [
                                                          Flexible(
                                                            child: Text(
                                                              results[index]['reference'],
                                                              style: GoogleFonts.secularOne(
                                                                fontSize: size.height * 0.018,
                                                                color: blackColor,
                                                              ),
                                                            ),
                                                          ),
                                                        ],
                                                      ) : Container(),
                                                      results[index]['mobile'] != '' && results[index]['mobile'] != null ? IntrinsicHeight(
                                                        child: (results[index]['mobile']).split(',').length != 1 ? Row(
                                                          children: [
                                                            GestureDetector(
                                                              onTap: () {
                                                                showDialog(
                                                                  context: context,
                                                                  builder: (BuildContext context) {
                                                                    return AlertDialog(
                                                                      contentPadding: const EdgeInsets.all(10),
                                                                      content: Row(
                                                                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                                                        children: [
                                                                          IconButton(
                                                                            onPressed: () {
                                                                              Navigator.pop(context);
                                                                              callAction((results[index]['mobile']).split(',')[0].trim());
                                                                            },
                                                                            icon: const Icon(Icons.phone),
                                                                            color: callColor,
                                                                          ),
                                                                          IconButton(
                                                                            onPressed: () {
                                                                              Navigator.pop(context);
                                                                              smsAction((results[index]['mobile']).split(',')[0].trim());
                                                                            },
                                                                            icon: const Icon(Icons.message),
                                                                            color: smsColor,
                                                                          ),
                                                                          IconButton(
                                                                            onPressed: () {
                                                                              Navigator.pop(context);
                                                                              whatsappAction((results[index]['mobile']).split(',')[0].trim());
                                                                            },
                                                                            icon: SvgPicture.asset('assets/icons/whatsapp.svg', color: whatsAppColor, height: 20, width: 20,),
                                                                            color: whatsAppColor,
                                                                          ),
                                                                        ],
                                                                      ),
                                                                    );
                                                                  },
                                                                );
                                                              },
                                                              child: Text(
                                                                (results[index]['mobile']).split(',')[0].trim(),
                                                                style: GoogleFonts.secularOne(
                                                                    color: mobileText,
                                                                    fontSize: size.height * 0.018
                                                                ),),
                                                            ),
                                                            SizedBox(width: size.width * 0.01,),
                                                            const VerticalDivider(
                                                              color: Colors.grey,
                                                              thickness: 2,
                                                            ),
                                                            SizedBox(width: size.width * 0.01,),
                                                            GestureDetector(
                                                              onTap: () {
                                                                showDialog(
                                                                  context: context,
                                                                  builder: (BuildContext context) {
                                                                    return AlertDialog(
                                                                      contentPadding: const EdgeInsets.all(10),
                                                                      content: Row(
                                                                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                                                        children: [
                                                                          IconButton(
                                                                            onPressed: () {
                                                                              Navigator.pop(context);
                                                                              callAction((results[index]['mobile']).split(',')[1].trim());
                                                                            },
                                                                            icon: const Icon(Icons.phone),
                                                                            color: callColor,
                                                                          ),
                                                                          IconButton(
                                                                            onPressed: () {
                                                                              Navigator.pop(context);
                                                                              smsAction((results[index]['mobile']).split(',')[1].trim());
                                                                            },
                                                                            icon: const Icon(Icons.message),
                                                                            color: smsColor,
                                                                          ),
                                                                          IconButton(
                                                                            onPressed: () {
                                                                              Navigator.pop(context);
                                                                              whatsappAction((results[index]['mobile']).split(',')[1].trim());
                                                                            },
                                                                            icon: SvgPicture.asset('assets/icons/whatsapp.svg', color: whatsAppColor, height: 20, width: 20,),
                                                                            color: whatsAppColor,
                                                                          ),
                                                                        ],
                                                                      ),
                                                                    );
                                                                  },
                                                                );
                                                              },
                                                              child: Text(
                                                                (results[index]['mobile']).split(',')[1].trim(),
                                                                style: GoogleFonts.secularOne(
                                                                    color: mobileText,
                                                                    fontSize: size.height * 0.018
                                                                ),),
                                                            )
                                                          ],
                                                        ) : Row(
                                                          children: [
                                                            Text(
                                                              (results[index]['mobile']).split(',')[0].trim(),
                                                              style: GoogleFonts.secularOne(
                                                                color: mobileText,
                                                                fontSize: size.height * 0.018,
                                                              ),
                                                            ),
                                                            Row(
                                                              mainAxisSize: MainAxisSize.min,
                                                              crossAxisAlignment: CrossAxisAlignment.center,
                                                              children: [
                                                                const SizedBox(width: 20,),
                                                                GestureDetector(
                                                                  onTap: () {
                                                                    callAction((results[index]['member_id']['mobile']).split(',')[0].trim());
                                                                  },
                                                                  child: const Icon(
                                                                    Icons.phone,
                                                                    size: 19,
                                                                    color: callColor,
                                                                  ),
                                                                ),
                                                                const SizedBox(width: 20,),
                                                                GestureDetector(
                                                                  onTap: () {
                                                                    smsAction((results[index]['member_id']['mobile']).split(',')[0].trim());
                                                                  },
                                                                  child: const Icon(
                                                                    Icons.message,
                                                                    size: 19,
                                                                    color: smsColor,
                                                                  ),
                                                                ),
                                                                const SizedBox(width: 20,),
                                                                GestureDetector(
                                                                  onTap: () {
                                                                    whatsappAction((results[index]['member_id']['mobile']).split(',')[0].trim());
                                                                  },
                                                                  child: SizedBox(
                                                                    child: SvgPicture.asset('assets/icons/whatsapp.svg', color: whatsAppColor, height: 16,),
                                                                  ),
                                                                )
                                                              ],
                                                            ),
                                                          ],
                                                        ),
                                                      ) : Container(),
                                                    ],
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                    Positioned(
                                      bottom: 8,
                                      right: 15,
                                      child: results[index]['parish_members_count'] != '' && results[index]['parish_members_count'] != null ? GestureDetector(
                                        onTap: () {
                                          indexValue = results[index]['id'];
                                          indexName = results[index]['name'];
                                          assignFamilyMembersValues(indexValue, indexName);
                                        },
                                        child: Container(
                                          padding: const EdgeInsets.only(top: 3, bottom: 3, left: 5, right: 5),
                                          decoration: BoxDecoration(
                                            borderRadius: BorderRadius.circular(5),
                                            color: customBackgroundColor1,
                                          ),
                                          child: RichText(
                                            text: TextSpan(
                                                text: results[index]['parish_members_count'].toString(),
                                                style: TextStyle(
                                                    letterSpacing: 1,
                                                    fontSize: size.height * 0.015,
                                                    fontWeight: FontWeight.bold,
                                                    color: customTextColor1,
                                                    fontStyle: FontStyle.italic
                                                ),
                                                children: <InlineSpan>[
                                                  results[index]['parish_members_count'] == 1 ? TextSpan(
                                                    text: ' Member',
                                                    style: TextStyle(
                                                        letterSpacing: 1,
                                                        fontSize: size.height * 0.015,
                                                        fontWeight: FontWeight.bold,
                                                        color: customTextColor1,
                                                        fontStyle: FontStyle.italic
                                                    ),
                                                  ) : TextSpan(
                                                    text: ' Members',
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
                                    )
                                  ],
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
                    members.isNotEmpty ? Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(right: 5),
                          child: Text('Showing 1 - $limitCount of $membersCount', style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: countLabel),),
                        ),
                      ],
                    ) : Container(),
                    members.isNotEmpty ? SizedBox(
                      height: size.height * 0.01,
                    ) : Container(),
                    members.isNotEmpty ? Expanded(
                      child: Scrollbar(
                        thumbVisibility: true,
                        interactive: true,
                        radius: const Radius.circular(15),
                        thickness: 8,
                        child: SlideFadeAnimation(
                          duration: const Duration(seconds: 1),
                          child: ListView.builder(
                            controller: _controller,
                            itemCount: members.length,
                            itemBuilder: (BuildContext context, int index) {
                              return GestureDetector(
                                onTap: () {
                                  indexValue = members[index]['id'];
                                  indexName = members[index]['name'];
                                  assignValues(indexValue, indexName);
                                },
                                child: Stack(
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.only(left: 5, right: 5),
                                      child: Card(
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(15),
                                        ),
                                        child: Container(
                                          padding: const EdgeInsets.only(left: 10, top: 10, bottom: 10),
                                          child: Row(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              GestureDetector(
                                                onTap: () {
                                                  members[index]['image_512'] != '' ? showDialog(
                                                    context: context,
                                                    builder: (BuildContext context) {
                                                      return Dialog(
                                                        child: Image.network(members[index]['image_512'], fit: BoxFit.cover,),
                                                      );
                                                    },
                                                  ) : showDialog(
                                                    context: context,
                                                    builder: (BuildContext context) {
                                                      return Dialog(
                                                        child: Image.asset('assets/images/family.png', fit: BoxFit.cover,),
                                                      );
                                                    },
                                                  );
                                                },
                                                child: Container(
                                                  height: size.height * 0.1,
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
                                                    image: DecorationImage(
                                                      fit: BoxFit.cover,
                                                      image: members[index]['image_512'] != null && members[index]['image_512'] != ''
                                                          ? NetworkImage(members[index]['image_512'])
                                                          : const AssetImage('assets/images/family.png') as ImageProvider,
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
                                                      members[index]['family_head_id']['member_name'] != null && members[index]['family_head_id']['member_name'] != '' ? Row(
                                                        children: [
                                                          Flexible(
                                                            child: RichText(
                                                              textAlign: TextAlign.left,
                                                              text: TextSpan(
                                                                  text: members[index]['name'],
                                                                  style: GoogleFonts.secularOne(
                                                                      fontSize: size.height * 0.02,
                                                                      color: textColor
                                                                  ),
                                                                  children: [
                                                                    const TextSpan(text: '  '),
                                                                    TextSpan(
                                                                      text: "( Family Head )",
                                                                      style: GoogleFonts.secularOne(
                                                                          fontSize: size.height * 0.017,
                                                                          color: emptyColor,
                                                                          fontStyle: FontStyle.italic
                                                                      ),
                                                                    ),
                                                                  ]),
                                                            ),
                                                          ),
                                                        ],
                                                      ) : Row(
                                                        children: [
                                                          Flexible(
                                                            child: Text(
                                                              members[index]['name'],
                                                              style: GoogleFonts.secularOne(
                                                                  fontSize: size.height * 0.02,
                                                                  color: textColor
                                                              ),
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                      members[index]['reference'] != null && members[index]['reference'] != '' ? Row(
                                                        children: [
                                                          Flexible(
                                                            child: Text(
                                                              members[index]['reference'],
                                                              style: GoogleFonts.secularOne(
                                                                fontSize: size.height * 0.018,
                                                                color: blackColor,
                                                              ),
                                                            ),
                                                          ),
                                                        ],
                                                      ) : Container(),
                                                      members[index]['mobile'] != '' && members[index]['mobile'] != null ? IntrinsicHeight(
                                                        child: (members[index]['mobile']).split(',').length != 1 ? Row(
                                                          children: [
                                                            GestureDetector(
                                                              onTap: () {
                                                                showDialog(
                                                                  context: context,
                                                                  builder: (BuildContext context) {
                                                                    return AlertDialog(
                                                                      contentPadding: const EdgeInsets.all(10),
                                                                      content: Row(
                                                                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                                                        children: [
                                                                          IconButton(
                                                                            onPressed: () {
                                                                              Navigator.pop(context);
                                                                              callAction((members[index]['mobile']).split(',')[0].trim());
                                                                            },
                                                                            icon: const Icon(Icons.phone),
                                                                            color: callColor,
                                                                          ),
                                                                          IconButton(
                                                                            onPressed: () {
                                                                              Navigator.pop(context);
                                                                              smsAction((members[index]['mobile']).split(',')[0].trim());
                                                                            },
                                                                            icon: const Icon(Icons.message),
                                                                            color: smsColor,
                                                                          ),
                                                                          IconButton(
                                                                            onPressed: () {
                                                                              Navigator.pop(context);
                                                                              whatsappAction((members[index]['mobile']).split(',')[0].trim());
                                                                            },
                                                                            icon: SvgPicture.asset('assets/icons/whatsapp.svg', color: whatsAppColor, height: 20, width: 20,),
                                                                            color: whatsAppColor,
                                                                          ),
                                                                        ],
                                                                      ),
                                                                    );
                                                                  },
                                                                );
                                                              },
                                                              child: Text(
                                                                (members[index]['mobile']).split(',')[0].trim(),
                                                                style: GoogleFonts.secularOne(
                                                                    color: mobileText,
                                                                    fontSize: size.height * 0.018
                                                                ),),
                                                            ),
                                                            SizedBox(width: size.width * 0.01,),
                                                            const VerticalDivider(
                                                              color: Colors.grey,
                                                              thickness: 2,
                                                            ),
                                                            SizedBox(width: size.width * 0.01,),
                                                            GestureDetector(
                                                              onTap: () {
                                                                showDialog(
                                                                  context: context,
                                                                  builder: (BuildContext context) {
                                                                    return AlertDialog(
                                                                      contentPadding: const EdgeInsets.all(10),
                                                                      content: Row(
                                                                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                                                        children: [
                                                                          IconButton(
                                                                            onPressed: () {
                                                                              Navigator.pop(context);
                                                                              callAction((members[index]['mobile']).split(',')[1].trim());
                                                                            },
                                                                            icon: const Icon(Icons.phone),
                                                                            color: callColor,
                                                                          ),
                                                                          IconButton(
                                                                            onPressed: () {
                                                                              Navigator.pop(context);
                                                                              smsAction((members[index]['mobile']).split(',')[1].trim());
                                                                            },
                                                                            icon: const Icon(Icons.message),
                                                                            color: smsColor,
                                                                          ),
                                                                          IconButton(
                                                                            onPressed: () {
                                                                              Navigator.pop(context);
                                                                              whatsappAction((members[index]['mobile']).split(',')[1].trim());
                                                                            },
                                                                            icon: SvgPicture.asset('assets/icons/whatsapp.svg', color: whatsAppColor, height: 18, width: 18,),
                                                                            color: whatsAppColor,
                                                                          ),
                                                                        ],
                                                                      ),
                                                                    );
                                                                  },
                                                                );
                                                              },
                                                              child: Text(
                                                                (members[index]['mobile']).split(',')[1].trim(),
                                                                style: GoogleFonts.secularOne(
                                                                    color: mobileText,
                                                                    fontSize: size.height * 0.018,
                                                                ),),
                                                            )
                                                          ],
                                                        ) : Row(
                                                          children: [
                                                            Text(
                                                              (members[index]['mobile']).split(',')[0].trim(),
                                                              style: GoogleFonts.secularOne(
                                                                color: mobileText,
                                                                fontSize: size.height * 0.018,
                                                              ),
                                                            ),
                                                            Row(
                                                              mainAxisSize: MainAxisSize.min,
                                                              crossAxisAlignment: CrossAxisAlignment.center,
                                                              children: [
                                                                const SizedBox(width: 20,),
                                                                GestureDetector(
                                                                  onTap: () {
                                                                    callAction((members[index]['member_id']['mobile']).split(',')[0].trim());
                                                                  },
                                                                  child: const Icon(
                                                                    Icons.phone,
                                                                    size: 19,
                                                                    color: callColor,
                                                                  ),
                                                                ),
                                                                const SizedBox(width: 20,),
                                                                GestureDetector(
                                                                  onTap: () {
                                                                    smsAction((members[index]['member_id']['mobile']).split(',')[0].trim());
                                                                  },
                                                                  child: const Icon(
                                                                    Icons.message,
                                                                    size: 19,
                                                                    color: smsColor,
                                                                  ),
                                                                ),
                                                                const SizedBox(width: 20,),
                                                                GestureDetector(
                                                                  onTap: () {
                                                                    whatsappAction((members[index]['member_id']['mobile']).split(',')[0].trim());
                                                                  },
                                                                  child: SizedBox(
                                                                    child: SvgPicture.asset('assets/icons/whatsapp.svg', color: whatsAppColor, height: 16,),
                                                                  ),
                                                                )
                                                              ],
                                                            ),
                                                          ],
                                                        ),
                                                      ) : Container(),
                                                    ],
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                    Positioned(
                                      bottom: 8,
                                      right: 15,
                                      child: members[index]['parish_members_count'] != '' && members[index]['parish_members_count'] != null ? GestureDetector(
                                        onTap: () {
                                          indexValue = members[index]['id'];
                                          indexName = members[index]['name'];
                                          assignFamilyMembersValues(indexValue, indexName);
                                        },
                                        child: Container(
                                          padding: const EdgeInsets.only(top: 3, bottom: 3, left: 5, right: 5),
                                          decoration: BoxDecoration(
                                            borderRadius: BorderRadius.circular(5),
                                            color: customBackgroundColor1,
                                          ),
                                          child: RichText(
                                            text: TextSpan(
                                                text: members[index]['parish_members_count'].toString(),
                                                style: TextStyle(
                                                    letterSpacing: 1,
                                                    fontSize: size.height * 0.015,
                                                    fontWeight: FontWeight.bold,
                                                    color: customTextColor1,
                                                    fontStyle: FontStyle.italic
                                                ),
                                                children: <InlineSpan>[
                                                  members[index]['parish_members_count'] == 1 ? TextSpan(
                                                    text: ' Member',
                                                    style: TextStyle(
                                                        letterSpacing: 1,
                                                        fontSize: size.height * 0.015,
                                                        fontWeight: FontWeight.bold,
                                                        color: customTextColor1,
                                                        fontStyle: FontStyle.italic
                                                    ),
                                                  ) : TextSpan(
                                                    text: ' Members',
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
                                    )
                                  ],
                                ),
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
                          child: Text('You have fetched all of the family data'),
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
