import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:loading_indicator/loading_indicator.dart';
import 'package:munchirai/private/screens/family/family_detail_tab.dart';
import 'package:munchirai/private/screens/member/member_details.dart';
import 'package:munchirai/widget/common/common.dart';
import 'package:munchirai/widget/common/internet_connection_checker.dart';
import 'package:munchirai/widget/common/slide_animations.dart';
import 'package:munchirai/widget/theme_color/theme_color.dart';
import 'package:munchirai/widget/widget.dart';
import 'package:url_launcher/url_launcher.dart';

class BCCHeadsScreen extends StatefulWidget {
  const BCCHeadsScreen({Key? key}) : super(key: key);

  @override
  State<BCCHeadsScreen> createState() => _BCCHeadsScreenState();
}

class _BCCHeadsScreenState extends State<BCCHeadsScreen> {
  final ClearSharedPreference shared = ClearSharedPreference();
  bool _isLoading = true;
  List members = [];

  int? indexValue;
  String indexName = '';

  getBccHeadsData() async {
    var request = http.Request('GET', Uri.parse("$baseUrl/res.parish.bcc"));
    request.body = json.encode({
      "params": {
        "filter": "[['id','=',$bccId]]",
        "query": "{id,heads_ids{id,role,member_id{id,member_name,image_512,mobile,family_id},start_date,end_date,status,parish_bcc_id}}",
      }
    });
    request.headers.addAll(header);
    http.StreamedResponse response = await request.send();
    if(response.statusCode == 200) {
      var decode = json.decode(await response.stream.bytesToString())['result'];
      if(decode['status'] == true) {
        List data = decode['data']['result'];
        setState(() {
          _isLoading = false;
        });
        for(int i = 0; i < data.length; i++) {
          members = data[i]['heads_ids'];
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

  assignValues(indexValue, indexName) async {
    familyId = indexValue.toString();
    await Navigator.push(context, CustomRoute(widget: FamilyDetailsTabScreen(title: indexName)));
  }

  assignMemberDetails(indexValue, indexName) async {
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
      getBccHeadsData();
    } else {
      setState(() {
        shared.clearSharedPreferenceData(context);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Scaffold(
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
            Expanded(
              child: Column(
                children: [
                  members.isNotEmpty ? Expanded(
                    child: Scrollbar(
                      thumbVisibility: true,
                      interactive: true,
                      radius: const Radius.circular(15),
                      thickness: 8,
                      child: SlideFadeAnimation(
                        duration: const Duration(seconds: 1),
                        child: ListView.builder(
                          itemCount: members.length,
                          itemBuilder: (BuildContext context, int index) {
                            return Stack(
                              children: [
                                Padding(
                                  padding: const EdgeInsets.only(left: 5, right: 5),
                                  child: GestureDetector(
                                    onTap: () {
                                      indexValue = members[index]['member_id']['id'];
                                      indexName = members[index]['member_id']['member_name'];
                                      assignMemberDetails(indexValue, indexName);
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
                                                members[index]['member_id']['image_512'] != '' ? showDialog(
                                                  context: context,
                                                  builder: (BuildContext context) {
                                                    return Dialog(
                                                      child: Image.network(members[index]['member_id']['image_512'], fit: BoxFit.cover,),
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
                                                  // boxShadow: <BoxShadow>[
                                                  //   if(members[index]['member_id']['image_512'] != null && members[index]['member_id']['image_512'] != '') const BoxShadow(
                                                  //     color: Colors.grey,
                                                  //     spreadRadius: -1,
                                                  //     blurRadius: 5 ,
                                                  //     offset: Offset(0, 1),
                                                  //   ),
                                                  // ],
                                                  shape: BoxShape.rectangle,
                                                  image: DecorationImage(
                                                    fit: BoxFit.cover,
                                                    image: members[index]['member_id']['image_512'] != null && members[index]['member_id']['image_512'] != ''
                                                        ? NetworkImage(members[index]['member_id']['image_512'])
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
                                                          child: Text(
                                                            members[index]['member_id']['member_name'],
                                                            style: GoogleFonts.secularOne(
                                                                fontSize: size.height * 0.02,
                                                                color: textHeadColor
                                                            ),
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                    members[index]['role'] != null && members[index]['role'] != '' ? Row(
                                                      children: [
                                                        Flexible(
                                                          child: Text(
                                                            members[index]['role'],
                                                            style: GoogleFonts.secularOne(
                                                              fontSize: size.height * 0.018,
                                                              color: blackColor,
                                                            ),
                                                          ),
                                                        ),
                                                      ],
                                                    ) : Container(),
                                                    members[index]['member_id']['mobile'] != '' && members[index]['member_id']['mobile'] != null ? IntrinsicHeight(
                                                      child: (members[index]['member_id']['mobile']).split(',').length != 1 ? Row(
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
                                                                            callAction((members[index]['member_id']['mobile']).split(',')[0].trim());
                                                                          },
                                                                          icon: const Icon(Icons.phone, size: 18,),
                                                                          color: callColor,
                                                                        ),
                                                                        IconButton(
                                                                          onPressed: () {
                                                                            Navigator.pop(context);
                                                                            smsAction((members[index]['member_id']['mobile']).split(',')[0].trim());
                                                                          },
                                                                          icon: const Icon(Icons.message, size: 18,),
                                                                          color: smsColor,
                                                                        ),
                                                                        IconButton(
                                                                          onPressed: () {
                                                                            Navigator.pop(context);
                                                                            whatsappAction((members[index]['member_id']['mobile']).split(',')[0].trim());
                                                                          },
                                                                          icon: SvgPicture.asset('assets/icons/whatsapp.svg', color: whatsAppColor, height: 16,),
                                                                          color: whatsAppColor,
                                                                        ),
                                                                      ],
                                                                    ),
                                                                  );
                                                                },
                                                              );
                                                            },
                                                            child: Text(
                                                              (members[index]['member_id']['mobile']).split(',')[0].trim(),
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
                                                                            callAction((members[index]['member_id']['mobile']).split(',')[1].trim());
                                                                          },
                                                                          icon: const Icon(Icons.phone, size: 18,),
                                                                          color: callColor,
                                                                        ),
                                                                        IconButton(
                                                                          onPressed: () {
                                                                            Navigator.pop(context);
                                                                            smsAction((members[index]['member_id']['mobile']).split(',')[1].trim());
                                                                          },
                                                                          icon: const Icon(Icons.message, size: 18,),
                                                                          color: smsColor,
                                                                        ),
                                                                        IconButton(
                                                                          onPressed: () {
                                                                            Navigator.pop(context);
                                                                            whatsappAction((members[index]['member_id']['mobile']).split(',')[1].trim());
                                                                          },
                                                                          icon: SvgPicture.asset('assets/icons/whatsapp.svg', color: whatsAppColor, height: 16,),
                                                                          color: whatsAppColor,
                                                                        ),
                                                                      ],
                                                                    ),
                                                                  );
                                                                },
                                                              );
                                                            },
                                                            child: Text(
                                                              (members[index]['member_id']['mobile']).split(',')[1].trim(),
                                                              style: GoogleFonts.secularOne(
                                                                color: mobileText,
                                                                fontSize: size.height * 0.018,
                                                              ),),
                                                          )
                                                        ],
                                                      ) : Row(
                                                        children: [
                                                          Text(
                                                            (members[index]['member_id']['mobile']).split(',')[0].trim(),
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
                                ),
                                Positioned(
                                  bottom: 8,
                                  right: 15,
                                  child: GestureDetector(
                                    onTap: () {
                                      indexValue = members[index]['member_id']['family_id']['id'];
                                      indexName = members[index]['member_id']['family_id']['name'];
                                      assignValues(indexValue, indexName);
                                    },
                                    child: Container(
                                      padding: const EdgeInsets.only(top: 5, bottom: 5, left: 8, right: 8),
                                      child: RichText(
                                        text: TextSpan(
                                            text: "More...",
                                            style: TextStyle(
                                              fontSize: size.height * 0.018,
                                              fontWeight: FontWeight.bold,
                                              color: customTextColor2,
                                              fontStyle: FontStyle.italic,
                                              decoration: TextDecoration.underline
                                            ),
                                        ),
                                      ),
                                    ),
                                  ),
                                )
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
            )
          ],
        ),
      ),
    );
  }
}
