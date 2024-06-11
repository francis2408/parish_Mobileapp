import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:loading_indicator/loading_indicator.dart';
import 'package:perambur/widget/common/common.dart';
import 'package:perambur/widget/common/internet_connection_checker.dart';
import 'package:perambur/widget/common/slide_animations.dart';
import 'package:perambur/widget/theme_color/theme_color.dart';
import 'package:perambur/widget/widget.dart';
import 'package:url_launcher/url_launcher.dart';

class PublicBirthdayScreen extends StatefulWidget {
  const PublicBirthdayScreen({Key? key}) : super(key: key);

  @override
  State<PublicBirthdayScreen> createState() => _PublicBirthdayScreenState();
}

class _PublicBirthdayScreenState extends State<PublicBirthdayScreen> {
  bool _isLoading = true;
  bool _isToday = false;
  List birthData = [];
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
    var request = http.Request('GET', Uri.parse('$baseUrl/public/res.member/get_today_date_to_next_30_days_birthday_details'));
    request.body = json.encode({
      "params": {
        "args": [int.parse(parishID)]
      }
    });
    request.headers.addAll(headers);
    http.StreamedResponse response = await request.send();
    if (response.statusCode == 200) {
      var decode = json.decode(await response.stream.bytesToString());
      data = decode['result'];
      setState(() {
        _isLoading = false;
      });
      birthData = data;
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
      birthData = results;
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
                  birthData.isNotEmpty ? Padding(
                    padding: const EdgeInsets.only(right: 10),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        const Text('Total Count :', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.black),),
                        const SizedBox(width: 3,),
                        Text('${birthData.length}', style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.black),),
                        const SizedBox(width: 5,),
                      ],
                    ),
                  ) : Container(),
                  SizedBox(
                    height: size.height * 0.01,
                  ),
                  birthData.isNotEmpty ? Expanded(
                    child: SingleChildScrollView(
                      child: SlideFadeAnimation(
                        duration: const Duration(seconds: 1),
                        child: ListView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: birthData.length,
                          itemBuilder: (BuildContext context, int index) {
                            final now = DateTime.now();
                            var todays = DateFormat('dd-MMMM').format(now);
                            DateTime date = DateFormat("dd-MMMM").parse(birthData[index]['anniversary_day']);
                            var formattedDates = DateFormat('dd-MMMM').format(date);
                            return Stack(
                              children: [
                                Card(
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(15.0),
                                  ),
                                  child: Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Row(
                                      children: [
                                        GestureDetector(
                                          onTap: () {
                                            birthData[index]['image'] != '' ? showDialog(
                                              context: context,
                                              builder: (BuildContext context) {
                                                return Dialog(
                                                  child: Image.network(birthData[index]['image'], fit: BoxFit.cover,),
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
                                            height: size.height * 0.1,
                                            width: size.width * 0.17,
                                            decoration: BoxDecoration(
                                              borderRadius: BorderRadius.circular(10),
                                              shape: BoxShape.rectangle,
                                              image: DecorationImage(
                                                fit: BoxFit.cover,
                                                image: birthData[index]['image'] != null && birthData[index]['image'] != ''
                                                    ? NetworkImage(birthData[index]['image'])
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
                                                      birthData[index]['name'],
                                                      style: GoogleFonts.roboto(
                                                        fontSize: size.height * 0.02,
                                                        color: textColor,
                                                        fontWeight: FontWeight.bold,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                                SizedBox(height: size.height * 0.01,),
                                                Row(
                                                  children: [
                                                    const Icon(Icons.access_time, color: iconColor, size: 20,),
                                                    SizedBox(width: size.width * 0.02,),
                                                    Text(birthData[index]['anniversary_day'], style: GoogleFonts.secularOne(color: blackColor, fontSize: size.height * 0.018),),
                                                  ],
                                                ),
                                                SizedBox(height: size.height * 0.01,),
                                                birthData[index]['mobile'] != '' && birthData[index]['mobile'] != null ? IntrinsicHeight(
                                                  child: (birthData[index]['mobile']).split(',').length != 1 ? Row(
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
                                                                        callAction((birthData[index]['mobile']).split(',')[0].trim());
                                                                      },
                                                                      icon: const Icon(Icons.phone),
                                                                      color: callColor,
                                                                    ),
                                                                    IconButton(
                                                                      onPressed: () {
                                                                        Navigator.pop(context);
                                                                        smsAction((birthData[index]['mobile']).split(',')[0].trim());
                                                                      },
                                                                      icon: const Icon(Icons.message),
                                                                      color: smsColor,
                                                                    ),
                                                                    IconButton(
                                                                      onPressed: () {
                                                                        Navigator.pop(context);
                                                                        whatsappAction((birthData[index]['mobile']).split(',')[0].trim());
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
                                                          (birthData[index]['mobile']).split(',')[0].trim(),
                                                          style: GoogleFonts.secularOne(
                                                              color: mobileText,
                                                              fontSize: size.height * 0.02
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
                                                                        callAction((birthData[index]['mobile']).split(',')[1].trim());
                                                                      },
                                                                      icon: const Icon(Icons.phone),
                                                                      color: callColor,
                                                                    ),
                                                                    IconButton(
                                                                      onPressed: () {
                                                                        Navigator.pop(context);
                                                                        smsAction((birthData[index]['mobile']).split(',')[1].trim());
                                                                      },
                                                                      icon: const Icon(Icons.message),
                                                                      color: smsColor,
                                                                    ),
                                                                    IconButton(
                                                                      onPressed: () {
                                                                        Navigator.pop(context);
                                                                        whatsappAction((birthData[index]['mobile']).split(',')[1].trim());
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
                                                          (birthData[index]['mobile']).split(',')[1].trim(),
                                                          style: GoogleFonts.secularOne(
                                                              color: mobileText,
                                                              fontSize: size.height * 0.02
                                                          ),),
                                                      )
                                                    ],
                                                  ) : Row(
                                                    children: [
                                                      Text(
                                                        (birthData[index]['mobile']).split(',')[0].trim(),
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
                                                              callAction((birthData[index]['mobile']).split(',')[0].trim());
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
                                                              smsAction((birthData[index]['mobile']).split(',')[0].trim());
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
                                                              whatsappAction((birthData[index]['mobile']).split(',')[0].trim());
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
                                if(todays == formattedDates) Positioned(
                                  top: size.height * 0.02,
                                  right: size.width * 0.01,
                                  child: Center(
                                    child: Container(
                                      height: size.height * 0.06,
                                      width: size.width * 0.15,
                                      decoration: const BoxDecoration(
                                        image: DecorationImage(
                                          image: AssetImage( "assets/images/celebration.png"),
                                        ),
                                      ),
                                    ),
                                  ),
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
