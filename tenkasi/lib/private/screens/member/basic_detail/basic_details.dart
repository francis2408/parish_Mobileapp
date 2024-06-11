import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:loading_indicator/loading_indicator.dart';
import 'package:tenkasi/widget/common/common.dart';
import 'package:tenkasi/widget/common/internet_connection_checker.dart';
import 'package:tenkasi/widget/common/slide_animations.dart';
import 'package:tenkasi/widget/theme_color/theme_color.dart';
import 'package:tenkasi/widget/widget.dart';
import 'package:url_launcher/url_launcher.dart';

class BasicDetailsScreen extends StatefulWidget {
  const BasicDetailsScreen({Key? key}) : super(key: key);

  @override
  State<BasicDetailsScreen> createState() => _BasicDetailsScreenState();
}

class _BasicDetailsScreenState extends State<BasicDetailsScreen> {
  final ClearSharedPreference shared = ClearSharedPreference();
  bool _isLoading = true;
  var membersDetail;

  getMemberDetailData() async {
    var request = http.Request('GET', Uri.parse('$baseUrl/res.member/$memberId'));
    request.body = json.encode({
      "params": {
        "query": "{image_1920,member_name,name_in_regional_language,family_id,member,dob,age,relationship_id,blood_group_id,physical_status_id,mobile,email,street,street2,city,district_id,state_id,country_id,zip}",
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
      membersDetail = data;
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

  Future<void> emailAction(String email) async {
    final Uri uri = Uri(scheme: "mailto", path: email);
    if(!await launchUrl(
      uri,
      mode: LaunchMode.externalApplication,
    )) {
      throw "Can not launch url";
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
      getMemberDetailData();
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
        ) : membersDetail.isNotEmpty && membersDetail != {} ? Container(
          padding: const EdgeInsets.symmetric(vertical: 5),
          child: SlideFadeAnimation(
            duration: const Duration(seconds: 1),
            child: Column(
              children: [
                Card(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: Container(
                    padding: const EdgeInsets.only(left: 10, top: 10, bottom: 10),
                    child: Row(
                      children: [
                        GestureDetector(
                          onTap: () {
                            membersDetail['image_1920'] != '' ? showDialog(
                              context: context,
                              builder: (BuildContext context) {
                                return Dialog(
                                  child: Image.network(membersDetail['image_1920'], fit: BoxFit.cover,),
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
                          child: Stack(
                            children: [
                              Container(
                                height: size.height * 0.1,
                                width: size.width * 0.18,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(10),
                                  shape: BoxShape.rectangle,
                                  image: DecorationImage(
                                    fit: BoxFit.cover,
                                    image: membersDetail['image_1920'] != null && membersDetail['image_1920'] != ''
                                        ? NetworkImage(membersDetail['image_1920'])
                                        : const AssetImage('assets/images/profile.png') as ImageProvider,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        Expanded(
                          child: Container(
                            padding: const EdgeInsets.only(left: 15, right: 10),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Flexible(
                                      child: Text(
                                        membersDetail['member_name'],
                                        style: GoogleFonts.secularOne(
                                          fontSize: size.height * 0.02,
                                          color: textColor,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                membersDetail['dob'] != null && membersDetail['dob'] != '' ? Row(
                                  children: [
                                    Flexible(
                                      child: RichText(
                                        textAlign: TextAlign.left,
                                        text: TextSpan(
                                            text: membersDetail['dob'],
                                            style: GoogleFonts.secularOne(
                                                fontSize: size.height * 0.02,
                                                color: valueColor
                                            ),
                                            children: [
                                              const TextSpan(text: '  '),
                                              TextSpan(
                                                text: "( Age: ${membersDetail['age']})",
                                                style: GoogleFonts.secularOne(
                                                    fontSize: size.height * 0.02,
                                                    color: emptyColor,
                                                    fontStyle: FontStyle.italic
                                                ),
                                              ),
                                            ]),
                                      ),
                                    ),
                                  ],
                                ) : Container(),
                                membersDetail['mobile'] != '' && membersDetail['mobile'] != null ? IntrinsicHeight(
                                  child: (membersDetail['mobile']).split(',').length != 1 ? Row(
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
                                                        callAction((membersDetail['mobile']).split(',')[0].trim());
                                                      },
                                                      icon: const Icon(Icons.phone),
                                                      color: callColor,
                                                    ),
                                                    IconButton(
                                                      onPressed: () {
                                                        Navigator.pop(context);
                                                        smsAction((membersDetail['mobile']).split(',')[0].trim());
                                                      },
                                                      icon: const Icon(Icons.message),
                                                      color: smsColor,
                                                    ),
                                                    IconButton(
                                                      onPressed: () {
                                                        Navigator.pop(context);
                                                        whatsappAction((membersDetail['mobile']).split(',')[0].trim());
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
                                          (membersDetail['mobile']).split(',')[0].trim(),
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
                                                        callAction((membersDetail['mobile']).split(',')[1].trim());
                                                      },
                                                      icon: const Icon(Icons.phone),
                                                      color: callColor,
                                                    ),
                                                    IconButton(
                                                      onPressed: () {
                                                        Navigator.pop(context);
                                                        smsAction((membersDetail['mobile']).split(',')[1].trim());
                                                      },
                                                      icon: const Icon(Icons.message),
                                                      color: smsColor,
                                                    ),
                                                    IconButton(
                                                      onPressed: () {
                                                        Navigator.pop(context);
                                                        whatsappAction((membersDetail['mobile']).split(',')[1].trim());
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
                                          (membersDetail['mobile']).split(',')[1].trim(),
                                          style: GoogleFonts.secularOne(
                                              color: mobileText,
                                              fontSize: size.height * 0.018
                                          ),),
                                      )
                                    ],
                                  ) : Row(
                                    children: [
                                      Text(
                                        (membersDetail['mobile']).split(',')[0].trim(),
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
                                              callAction((membersDetail['mobile']).split(',')[0].trim());
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
                                              smsAction((membersDetail['mobile']).split(',')[0].trim());
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
                                              whatsappAction((membersDetail['mobile']).split(',')[0].trim());
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
                Card(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15.0),
                  ),
                  child: Container(
                    padding: const EdgeInsets.all(10),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(width: size.width * 0.25, alignment: Alignment.topLeft, child: Text('Name (Reg.)', style: GoogleFonts.signika(fontSize: size.height * 0.02, color: labelColor),)),
                                Text(':  ', style: GoogleFonts.signika(fontSize: size.height * 0.02, color: labelColor),)
                              ],
                            ),
                            membersDetail['name_in_regional_language'] != '' && membersDetail['name_in_regional_language'] != null ? Text(
                              membersDetail['name_in_regional_language'],
                              style: GoogleFonts.secularOne(color: valueColor, fontSize: size.height * 0.02),
                            ) : Text(
                              'NA',
                              style: GoogleFonts.secularOne(fontSize: size.height * 0.02, color: emptyColor, fontStyle: FontStyle.italic),
                            )
                          ],
                        ),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(width: size.width * 0.25, alignment: Alignment.topLeft, child: Text('Family', style: GoogleFonts.signika(fontSize: size.height * 0.02, color: labelColor),)),
                                Text(':  ', style: GoogleFonts.signika(fontSize: size.height * 0.02, color: labelColor),)
                              ],
                            ),
                            membersDetail['family_id']['name'] != '' && membersDetail['family_id']['name'] != null ? Text(
                              membersDetail['family_id']['name'],
                              style: GoogleFonts.secularOne(color: valueColor, fontSize: size.height * 0.02),
                            ) : Text(
                              'NA',
                              style: GoogleFonts.secularOne(fontSize: size.height * 0.02, color: emptyColor, fontStyle: FontStyle.italic),
                            )
                          ],
                        ),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(width: size.width * 0.25, alignment: Alignment.topLeft, child: Text('Member #', style: GoogleFonts.signika(fontSize: size.height * 0.02, color: labelColor),)),
                                Text(':  ', style: GoogleFonts.signika(fontSize: size.height * 0.02, color: labelColor),)
                              ],
                            ),
                            membersDetail['member'] != '' && membersDetail['member'] != null ? Text(
                              membersDetail['member'],
                              style: GoogleFonts.secularOne(color: valueColor, fontSize: size.height * 0.02),
                            ) : Text(
                              'NA',
                              style: GoogleFonts.secularOne(fontSize: size.height * 0.02, color: emptyColor, fontStyle: FontStyle.italic),
                            )
                          ],
                        ),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(width: size.width * 0.25, alignment: Alignment.topLeft, child: Text('Relationship', style: GoogleFonts.signika(fontSize: size.height * 0.02, color: labelColor),)),
                                Text(':  ', style: GoogleFonts.signika(fontSize: size.height * 0.02, color: labelColor),)
                              ],
                            ),
                            membersDetail['relationship_id']['name'] != '' && membersDetail['relationship_id']['name'] != null ? Text(
                              membersDetail['relationship_id']['name'],
                              style: GoogleFonts.secularOne(color: valueColor, fontSize: size.height * 0.02),
                            ) : Text(
                              'NA',
                              style: GoogleFonts.secularOne(fontSize: size.height * 0.02, color: emptyColor, fontStyle: FontStyle.italic),
                            )
                          ],
                        ),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(width: size.width * 0.25, alignment: Alignment.topLeft, child: Text('Blood Group', style: GoogleFonts.signika(fontSize: size.height * 0.02, color: labelColor),)),
                                Text(':  ', style: GoogleFonts.signika(fontSize: size.height * 0.02, color: labelColor),)
                              ],
                            ),
                            membersDetail['blood_group_id']['name'] != '' && membersDetail['blood_group_id']['name'] != null ? Text(
                              membersDetail['blood_group_id']['name'],
                              style: GoogleFonts.secularOne(color: valueColor, fontSize: size.height * 0.02),
                            ) : Text(
                              'NA',
                              style: GoogleFonts.secularOne(fontSize: size.height * 0.02, color: emptyColor, fontStyle: FontStyle.italic),
                            )
                          ],
                        ),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(width: size.width * 0.25, alignment: Alignment.topLeft, child: Text('Physical Status', style: GoogleFonts.signika(fontSize: size.height * 0.02, color: labelColor),)),
                                Text(':  ', style: GoogleFonts.signika(fontSize: size.height * 0.02, color: labelColor),)
                              ],
                            ),
                            membersDetail['physical_status_id']['name'] != '' && membersDetail['physical_status_id']['name'] != null ? Text(
                              membersDetail['physical_status_id']['name'],
                              style: GoogleFonts.secularOne(color: valueColor, fontSize: size.height * 0.02),
                            ) : Text(
                              'NA',
                              style: GoogleFonts.secularOne(fontSize: size.height * 0.02, color: emptyColor, fontStyle: FontStyle.italic),
                            )
                          ],
                        ),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(width: size.width * 0.25, alignment: Alignment.topLeft, child: Text('Mobile', style: GoogleFonts.signika(fontSize: size.height * 0.02, color: labelColor),)),
                                Text(':  ', style: GoogleFonts.signika(fontSize: size.height * 0.02, color: labelColor),)
                              ],
                            ),
                            membersDetail['mobile'] != '' && membersDetail['mobile'] != null ? Text(
                              membersDetail['mobile'],
                              style: GoogleFonts.secularOne(color: valueColor, fontSize: size.height * 0.02),
                            ) : Text(
                              'NA',
                              style: GoogleFonts.secularOne(fontSize: size.height * 0.02, color: emptyColor, fontStyle: FontStyle.italic),
                            )
                          ],
                        ),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(width: size.width * 0.25, alignment: Alignment.topLeft, child: Text('Email', style: GoogleFonts.signika(fontSize: size.height * 0.02, color: labelColor),)),
                                Text(':  ', style: GoogleFonts.signika(fontSize: size.height * 0.02, color: labelColor),)
                              ],
                            ),
                            membersDetail['email'] != '' && membersDetail['email'] != null ? Text(
                              membersDetail['email'],
                              style: GoogleFonts.secularOne(color: valueColor, fontSize: size.height * 0.02),
                            ) : Text(
                              'NA',
                              style: GoogleFonts.secularOne(fontSize: size.height * 0.02, color: emptyColor, fontStyle: FontStyle.italic),
                            )
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                Card(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15.0),
                  ),
                  child: Container(
                    padding: const EdgeInsets.all(10),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(width: size.width * 0.25, alignment: Alignment.topLeft, child: Text('Address', style: GoogleFonts.signika(fontSize: size.height * 0.02, color: labelColor),)),
                            Text(':  ', style: GoogleFonts.signika(fontSize: size.height * 0.02, color: labelColor),)
                          ],
                        ),
                        membersDetail['street'] == '' && membersDetail['street2'] == '' && membersDetail['city'] == '' && membersDetail['district_id'] == [] && membersDetail['state_id'] == [] && membersDetail['country_id'] == [] && membersDetail['zip'] == '' ? Text(
                          'NA',
                          style: GoogleFonts.secularOne(fontSize: size.height * 0.02, color: emptyColor, fontStyle: FontStyle.italic),
                        ) : Flexible(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              membersDetail['street'] != '' ? Text("${membersDetail['street']},", style: GoogleFonts.secularOne(color: valueColor, fontSize: size.height * 0.02),) : Container(),
                              membersDetail['street2'] != '' ? Text("${membersDetail['street2']},", style: GoogleFonts.secularOne(color: valueColor, fontSize: size.height * 0.02),) : Container(),
                              membersDetail['city'] != '' ? Text("${membersDetail['city']},", style: GoogleFonts.secularOne(color: valueColor, fontSize: size.height * 0.02),) : Container(),
                              membersDetail['district_id'] != [] && membersDetail['country_id'] != null ? Text("${membersDetail['district_id']['name']},", style: GoogleFonts.secularOne(color: valueColor, fontSize: size.height * 0.02),) : Container(),
                              membersDetail['state_id'] != [] && membersDetail['country_id'] != null ? Text("${membersDetail['state_id']['name']},", style: GoogleFonts.secularOne(color: valueColor, fontSize: size.height * 0.02),) : Container(),
                              membersDetail['country_id'] != [] && membersDetail['country_id'] != null ? Text("${membersDetail['country_id']['name']},", style: GoogleFonts.secularOne(color: valueColor, fontSize: size.height * 0.02),) : Container(),
                              membersDetail['zip'] != '' ? Text("${membersDetail['zip']}.", style: GoogleFonts.secularOne(color: valueColor, fontSize: size.height * 0.02),) : Container()
                            ],
                          ),
                        )
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ) : Expanded(
          child: Center(
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
          ),
        ),
      ),
    );
  }
}
