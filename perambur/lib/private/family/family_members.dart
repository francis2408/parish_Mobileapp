import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:loading_indicator/loading_indicator.dart';
import 'package:perambur/private/members/member_details.dart';
import 'package:perambur/widget/common/common.dart';
import 'package:perambur/widget/common/internet_connection_checker.dart';
import 'package:perambur/widget/common/slide_animations.dart';
import 'package:perambur/widget/theme_color/theme_color.dart';
import 'package:perambur/widget/widget.dart';
import 'package:url_launcher/url_launcher.dart';

class FamilyMembersScreen extends StatefulWidget {
  final String title;
  const FamilyMembersScreen({Key? key, required this.title}) : super(key: key);

  @override
  State<FamilyMembersScreen> createState() => _FamilyMembersScreenState();
}

class _FamilyMembersScreenState extends State<FamilyMembersScreen> {
  final ClearSharedPreference shared = ClearSharedPreference();
  bool _isLoading = true;
  var members;
  int? indexValue;
  String indexName = '';

  getFamilyData() async {
    var request = http.Request('GET', Uri.parse('$baseUrl/res.family/$familyId'));
    request.body = json.encode({
      "params": {
        "query": "{id,name,reference,mobile,parish_bcc_id,child_ids{id,image_512,member_name,dob,relationship_id,mobile},street,street2,city,district_id,state_id,country_id,zip}",
      }
    });
    request.headers.addAll(header);
    http.StreamedResponse response = await request.send();
    if(response.statusCode == 200) {
      var decode = json.decode(await response.stream.bytesToString())['result'];
      var data = decode['data'];
      setState(() {
        _isLoading = false;
      });
      members = data;
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
    memberId = indexValue.toString();
    name = indexName;
    await Navigator.push(context, CustomRoute(widget: const MemberDetailsScreen()));
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
    super.initState();
    if(expiryDateTime!.isAfter(currentDateTime)) {
      getFamilyData();
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
        appbarVisible = false;
        Navigator.pop(context, 'refresh');
        return false;
      },
      child: Scaffold(
        backgroundColor: screenBackgroundColor,
        appBar: appbarVisible ? AppBar(
          backgroundColor: primaryColor,
          title: Text("${widget.title}'s Family Members", style: const TextStyle(fontSize: 16),),
          centerTitle: true,
        ) : null,
        body: SafeArea(
          child: _isLoading ? Center(
            child: SizedBox(
              height: size.height * 0.06,
              child: const LoadingIndicator(
                indicatorType: Indicator.ballSpinFadeLoader,
                colors: [Colors.red,Colors.orange,Colors.yellow,Colors.green,Colors.blue,Colors.indigo,Colors.purple,],
              ),
            ),
          ) : members['child_ids'].isNotEmpty && members['child_ids'] != [] ? SingleChildScrollView(
            child: SlideFadeAnimation(
              duration: const Duration(seconds: 1),
              child: Column(
                children: [
                  SizedBox(
                    height: size.height * 0.01,
                  ),
                  Column(
                    children: [
                      ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: members['child_ids'].length,
                        itemBuilder: (BuildContext context, int index) {
                          return Column(
                            children: [
                              GestureDetector(
                                onTap: () {
                                  indexValue = members['child_ids'][index]['id'];
                                  indexName = members['child_ids'][index]['member_name'];
                                  assignValues(indexValue, indexName);
                                },
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
                                            members['child_ids'][index]['image_512'] != '' ? showDialog(
                                              context: context,
                                              builder: (BuildContext context) {
                                                return Dialog(
                                                  child: Image.network(members['child_ids'][index]['image_512'], fit: BoxFit.cover,),
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
                                            width: size.width * 0.18,
                                            decoration: BoxDecoration(
                                              borderRadius: BorderRadius.circular(10),
                                              shape: BoxShape.rectangle,
                                              image: DecorationImage(
                                                fit: BoxFit.cover,
                                                image: members['child_ids'][index]['image_512'] != null && members['child_ids'][index]['image_512'] != ''
                                                    ? NetworkImage(members['child_ids'][index]['image_512'])
                                                    : const AssetImage('assets/images/profile.png') as ImageProvider,
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
                                                      child: RichText(
                                                        textAlign: TextAlign.left,
                                                        text: TextSpan(
                                                            text: members['child_ids'][index]['member_name'],
                                                            style: GoogleFonts.secularOne(
                                                                fontSize: size.height * 0.02,
                                                                color: textColor
                                                            ),
                                                            children: [
                                                              const TextSpan(text: '  '),
                                                              members['child_ids'][index]['relationship_id']['name'] != null && members['child_ids'][index]['relationship_id']['name'] != '' ? TextSpan(
                                                                text: "( ${members['child_ids'][index]['relationship_id']['name']} )",
                                                                style: GoogleFonts.secularOne(
                                                                    fontSize: size.height * 0.017,
                                                                    color: emptyColor,
                                                                    fontStyle: FontStyle.italic
                                                                ),
                                                              ) : const TextSpan(text: ''),
                                                            ]),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                                members['child_ids'][index]['dob'] != null && members['child_ids'][index]['dob'] != '' ? Row(
                                                  children: [
                                                    Flexible(
                                                      child: RichText(
                                                        textAlign: TextAlign.left,
                                                        text: TextSpan(
                                                            text: members['child_ids'][index]['dob'],
                                                            style: GoogleFonts.secularOne(
                                                                fontSize: size.height * 0.017,
                                                                color: valueColor
                                                            ),
                                                            children: [
                                                              const TextSpan(text: '  '),
                                                              TextSpan(
                                                                text: "( Age: ${DateTime.now().difference(DateFormat("dd-MM-yyyy").parse("${members['child_ids'][index]['dob']}")).inDays ~/ 365} )",
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
                                                ) : Container(),
                                                members['child_ids'][index]['mobile'] != '' && members['child_ids'][index]['mobile'] != null ? IntrinsicHeight(
                                                  child: (members['child_ids'][index]['mobile']).split(',').length != 1 ? Row(
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
                                                                        callAction((members['child_ids'][index]['mobile']).split(',')[0].trim());
                                                                      },
                                                                      icon: const Icon(Icons.phone),
                                                                      color: callColor,
                                                                    ),
                                                                    IconButton(
                                                                      onPressed: () {
                                                                        Navigator.pop(context);
                                                                        smsAction((members['child_ids'][index]['mobile']).split(',')[0].trim());
                                                                      },
                                                                      icon: const Icon(Icons.message),
                                                                      color: smsColor,
                                                                    ),
                                                                    IconButton(
                                                                      onPressed: () {
                                                                        Navigator.pop(context);
                                                                        whatsappAction((members['child_ids'][index]['mobile']).split(',')[0].trim());
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
                                                          (members['child_ids'][index]['mobile']).split(',')[0].trim(),
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
                                                                        callAction((members['child_ids'][index]['mobile']).split(',')[1].trim());
                                                                      },
                                                                      icon: const Icon(Icons.phone),
                                                                      color: callColor,
                                                                    ),
                                                                    IconButton(
                                                                      onPressed: () {
                                                                        Navigator.pop(context);
                                                                        smsAction((members['child_ids'][index]['mobile']).split(',')[1].trim());
                                                                      },
                                                                      icon: const Icon(Icons.message),
                                                                      color: smsColor,
                                                                    ),
                                                                    IconButton(
                                                                      onPressed: () {
                                                                        Navigator.pop(context);
                                                                        whatsappAction((members['child_ids'][index]['mobile']).split(',')[1].trim());
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
                                                          (members['child_ids'][index]['mobile']).split(',')[1].trim(),
                                                          style: GoogleFonts.secularOne(
                                                              color: mobileText,
                                                              fontSize: size.height * 0.018
                                                          ),),
                                                      )
                                                    ],
                                                  ) : Row(
                                                    children: [
                                                      Text(
                                                        (members['child_ids'][index]['mobile']).split(',')[0].trim(),
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
                                                              callAction((members['child_ids'][index]['mobile']).split(',')[0].trim());
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
                                                              smsAction((members['child_ids'][index]['mobile']).split(',')[0].trim());
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
                                                              whatsappAction((members['child_ids'][index]['mobile']).split(',')[0].trim());
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
                            ],
                          );
                        },
                      ),
                    ],
                  ),
                  SizedBox(
                    height: size.height * 0.01,
                  ),
                ],
              ),
            ),
          ) : Column(
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
      ),
    );
  }
}
