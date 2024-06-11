import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:http/http.dart' as http;
import 'package:google_fonts/google_fonts.dart';
import 'package:loading_indicator/loading_indicator.dart';
import 'package:perambur/widget/common/common.dart';
import 'package:perambur/widget/common/internet_connection_checker.dart';
import 'package:perambur/widget/common/slide_animations.dart';
import 'package:perambur/widget/theme_color/theme_color.dart';
import 'package:perambur/widget/widget.dart';
import 'package:url_launcher/url_launcher.dart';

class ServicesScreen extends StatefulWidget {
  const ServicesScreen({Key? key}) : super(key: key);

  @override
  State<ServicesScreen> createState() => _ServicesScreenState();
}

class _ServicesScreenState extends State<ServicesScreen> {
  bool _isLoading = true;
  List service = [];

  int selected = -1;
  int selected2 = -1;
  bool isCategoryExpanded = false;

  getServicesData() async {
    var request = http.Request('GET', Uri.parse('$baseUrl/yellow.page'));
    request.body = json.encode({
      "params": {
        "filter": "[['parish_id','=',$parishID]]",
        "access_all": "1",
        "query": "{id,occupation_id,yellow_page_member_ids{type,name,member_id{image_1920,member_name},mobile}}"
      }
    });
    request.headers.addAll(header);
    http.StreamedResponse response = await request.send();
    if (response.statusCode == 200) {
      var decode = json.decode(await response.stream.bytesToString())['result'];
      if(decode['status'] == true) {
        List data = decode['data']['result'];
        setState(() {
          _isLoading = false;
        });
        service = data;
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
    getServicesData();
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
            'Services',
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
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: size.height * 0.01,),
              Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15.0),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(10),
                  child: Column(
                    children: [
                      Text('Disclaimer', style: TextStyle(color: redColor, fontSize: size.height * 0.018, fontWeight: FontWeight.bold, letterSpacing: 0.7), textAlign: TextAlign.center,),
                      SizedBox(height: size.height * 0.01,),
                      Row(
                        children: [
                          Flexible(
                            child: RichText(
                              textAlign: TextAlign.justify,
                              text: TextSpan(
                                  text: "Lourdes Shrine Perambur",
                                  style: GoogleFonts.roboto(
                                      fontSize: size.height * 0.016,
                                      color: textColor,
                                    fontWeight: FontWeight.w700,
                                  ),
                                  children: [
                                    TextSpan(
                                      text: " church is not lible for any damages that may occur when people use these services. Use at Your Own Risk.",
                                      style: GoogleFonts.roboto(
                                          fontSize: size.height * 0.016,
                                          color: blackColor,
                                        fontWeight: FontWeight.w400,
                                      ),
                                    ),
                                  ]),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(height: size.height * 0.01,),
              service.isNotEmpty ? Expanded(
                child: SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      children: [
                        SlideFadeAnimation(
                          duration: const Duration(seconds: 1),
                          child: ListView.builder(
                            key: Key('builder ${selected.toString()}'),
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: service.length,
                            itemBuilder: (BuildContext context, int index) {
                              final isTileExpanded = index == selected;
                              final textExpandColor = isTileExpanded ? expandColor : blackColor;
                              return Column(
                                mainAxisAlignment: MainAxisAlignment.start,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Card(
                                    color: secondaryColor,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(15.0),
                                    ),
                                    child: ExpansionTile(
                                      key: Key(index.toString()),
                                      initiallyExpanded: index == selected,
                                      backgroundColor: Colors.white,
                                      iconColor: iconColor,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(15.0),
                                      ),
                                      onExpansionChanged: (newState) {
                                        if (newState) {
                                          setState(() {
                                            selected = index;
                                            selected2 = -1;
                                            isCategoryExpanded = true;
                                          });
                                        } else {
                                          setState(() {
                                            selected = -1;
                                            isCategoryExpanded = false;
                                          });
                                        }
                                      },
                                      title: Container(
                                        padding: const EdgeInsets.only(top: 10, bottom: 10),
                                        child: Row(
                                          children: [
                                            Text(
                                              '${service[index]['occupation_id']['name']}',
                                              style: GoogleFonts.roboto(
                                                fontSize: size.height * 0.02,
                                                color: textExpandColor,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                            Text(
                                              '   ',
                                              style: GoogleFonts.roboto(
                                                fontSize: size.height * 0.02,
                                                color: textExpandColor,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                            service[index]['yellow_page_member_ids'].length == 0 ? Container() : Text(
                                              '( ${service[index]['yellow_page_member_ids'].length} )',
                                              style: GoogleFonts.roboto(
                                                fontSize: size.height * 0.02,
                                                color: textExpandColor,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      children: [
                                        service[index]['yellow_page_member_ids'].isNotEmpty ? ListView.builder(
                                          key: Key('builder ${selected2.toString()}'),
                                          shrinkWrap: true,
                                          physics: const NeverScrollableScrollPhysics(),
                                          itemCount: isCategoryExpanded ? service[index]['yellow_page_member_ids'].length : 0,
                                          itemBuilder: (BuildContext context, int indexs) {
                                            return Column(
                                              children: [
                                                Container(
                                                  padding: const EdgeInsets.only(left: 10, top: 5, bottom: 5, right: 10),
                                                  child: Row(
                                                    children: [
                                                      GestureDetector(
                                                        onTap: () {
                                                          service[index]['yellow_page_member_ids'][indexs]['member_id']['image_1920'] != '' ? showDialog(
                                                            context: context,
                                                            builder: (BuildContext context) {
                                                              return Dialog(
                                                                child: Image.network(service[index]['yellow_page_member_ids'][indexs]['member_id']['image_1920'], fit: BoxFit.cover,),
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
                                                          height: size.height * 0.08,
                                                          width: size.width * 0.18,
                                                          decoration: BoxDecoration(
                                                            shape: BoxShape.circle,
                                                            image: DecorationImage(
                                                              fit: BoxFit.cover,
                                                              image: service[index]['yellow_page_member_ids'][indexs]['member_id']['image_1920'] != null && service[index]['yellow_page_member_ids'][indexs]['member_id']['image_1920'] != ''
                                                                  ? NetworkImage(service[index]['yellow_page_member_ids'][indexs]['member_id']['image_1920'])
                                                                  : const AssetImage('assets/images/profile.png') as ImageProvider,
                                                            ),
                                                          ),
                                                        ),
                                                      ),
                                                      Expanded(
                                                        child: Container(
                                                          padding: const EdgeInsets.only(left: 10, right: 10),
                                                          child: Column(
                                                            crossAxisAlignment: CrossAxisAlignment.start,
                                                            children: [
                                                              Row(
                                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                                children: [
                                                                  Flexible(
                                                                    child: Text(
                                                                      service[index]['yellow_page_member_ids'][indexs]['member_id']['member_name'],
                                                                      style: GoogleFonts.secularOne(color: textColor, fontSize: size.height * 0.02),
                                                                    ),
                                                                  )
                                                                ],
                                                              ),
                                                              SizedBox(height: size.height * 0.01,),
                                                              Row(
                                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                                children: [
                                                                  service[index]['yellow_page_member_ids'][indexs]['mobile'] != '' && service[index]['yellow_page_member_ids'][indexs]['mobile'] != null && service[index]['yellow_page_member_ids'][indexs]['mobile'] != false ? IntrinsicHeight(
                                                                    child: (service[index]['yellow_page_member_ids'][indexs]['mobile']).split(',').length != 1 ? Row(
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
                                                                                          callAction((service[index]['yellow_page_member_ids'][indexs]['mobile']).split(',')[0].trim());
                                                                                        },
                                                                                        icon: const Icon(Icons.phone),
                                                                                        color: callColor,
                                                                                      ),
                                                                                      IconButton(
                                                                                        onPressed: () {
                                                                                          Navigator.pop(context);
                                                                                          smsAction((service[index]['yellow_page_member_ids'][indexs]['mobile']).split(',')[0].trim());
                                                                                        },
                                                                                        icon: const Icon(Icons.message),
                                                                                        color: smsColor,
                                                                                      ),
                                                                                      IconButton(
                                                                                        onPressed: () {
                                                                                          Navigator.pop(context);
                                                                                          whatsappAction((service[index]['yellow_page_member_ids'][indexs]['mobile']).split(',')[0].trim());
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
                                                                            (service[index]['yellow_page_member_ids'][indexs]['mobile']).split(',')[0].trim(),
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
                                                                                          callAction((service[index]['yellow_page_member_ids'][indexs]['mobile']).split(',')[1].trim());
                                                                                        },
                                                                                        icon: const Icon(Icons.phone),
                                                                                        color: callColor,
                                                                                      ),
                                                                                      IconButton(
                                                                                        onPressed: () {
                                                                                          Navigator.pop(context);
                                                                                          smsAction((service[index]['yellow_page_member_ids'][indexs]['mobile']).split(',')[1].trim());
                                                                                        },
                                                                                        icon: const Icon(Icons.message),
                                                                                        color: smsColor,
                                                                                      ),
                                                                                      IconButton(
                                                                                        onPressed: () {
                                                                                          Navigator.pop(context);
                                                                                          whatsappAction((service[index]['yellow_page_member_ids'][indexs]['mobile']).split(',')[1].trim());
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
                                                                            (service[index]['yellow_page_member_ids'][indexs]['mobile']).split(',')[1].trim(),
                                                                            style: GoogleFonts.secularOne(
                                                                                color: mobileText,
                                                                                fontSize: size.height * 0.02
                                                                            ),
                                                                          ),
                                                                        )
                                                                      ],
                                                                    ) : Row(
                                                                      children: [
                                                                        Text(
                                                                          (service[index]['yellow_page_member_ids'][indexs]['mobile']).split(',')[0].trim(),
                                                                          style: GoogleFonts.secularOne(
                                                                            color: mobileText,
                                                                            fontSize: size.height * 0.02,
                                                                          ),
                                                                        ),
                                                                        Row(
                                                                          mainAxisSize: MainAxisSize.min,
                                                                          crossAxisAlignment: CrossAxisAlignment.center,
                                                                          children: [
                                                                            const SizedBox(width: 20,),
                                                                            GestureDetector(
                                                                              onTap: () {
                                                                                callAction((service[index]['yellow_page_member_ids'][indexs]['mobile']).split(',')[0].trim());
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
                                                                                smsAction((service[index]['yellow_page_member_ids'][indexs]['mobile']).split(',')[0].trim());
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
                                                                                whatsappAction((service[index]['yellow_page_member_ids'][indexs]['mobile']).split(',')[0].trim());
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
                                                            ],
                                                          ),
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                                if(indexs < service[index]['yellow_page_member_ids'].length - 1) const Divider(
                                                  thickness: 2,
                                                ),
                                              ],
                                            );
                                          },
                                        ) : Center(
                                          child: Container(
                                            alignment: Alignment.center,
                                            padding: const EdgeInsets.only(left: 30, right: 30, bottom: 10),
                                            child: const Text(
                                              'No Data available',
                                              style: TextStyle(
                                                  fontSize: 15,
                                                  fontWeight: FontWeight.bold,
                                                  color: Colors.black
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              );
                            },
                          ),
                        ),
                      ],
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
                          Navigator.pop(context);
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
