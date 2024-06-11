import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_svg/svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:loading_indicator/loading_indicator.dart';
import 'package:perambur/widget/common/common.dart';
import 'package:perambur/widget/common/internet_connection_checker.dart';
import 'package:perambur/widget/common/slide_animations.dart';
import 'package:perambur/widget/theme_color/theme_color.dart';
import 'package:perambur/widget/widget.dart';
import 'package:url_launcher/url_launcher.dart';

class FamilyDetailsScreen extends StatefulWidget {
  const FamilyDetailsScreen({Key? key}) : super(key: key);

  @override
  State<FamilyDetailsScreen> createState() => _FamilyDetailsScreenState();
}

class _FamilyDetailsScreenState extends State<FamilyDetailsScreen> {
  final ClearSharedPreference shared = ClearSharedPreference();
  bool _isLoading = true;
  var members;

  getFamilyData() async {
    var request = http.Request('GET', Uri.parse('$baseUrl/res.family/$familyId'));
    request.body = json.encode({
      "params": {
        // "access_all": "1",
        "query": "{id,name,image_512,reference,mobile,family_head_id,parish_bcc_id,child_ids{id,image_512,member_name,dob,relationship_id,mobile},street,street2,city,district_id,state_id,country_id,zip,settlement_status,house_type_id,house_ownership,economic_status,phone,mobile,email,same_as_above_address,permanent_street,permanent_street2,permanent_city,permanent_district_id,permanent_state_id,permanent_country_id,permanent_zip}",
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
          ) : members.isNotEmpty && members != {} ? SingleChildScrollView(
            child: SlideFadeAnimation(
              duration: const Duration(seconds: 1),
              child: Column(
                children: [
                  SizedBox(
                    height: size.height * 0.01,
                  ),
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
                              members['image_512'] != '' ? showDialog(
                                context: context,
                                builder: (BuildContext context) {
                                  return Dialog(
                                    child: Image.network(members['image_512'], fit: BoxFit.cover,),
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
                              height: size.height * 0.11,
                              width: size.width * 0.2,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(10),
                                boxShadow: <BoxShadow>[
                                  if(members['image_512'] != null && members['image_512'] != '') const BoxShadow(
                                    color: Colors.grey,
                                    spreadRadius: -1,
                                    blurRadius: 5 ,
                                    offset: Offset(0, 1),
                                  ),
                                ],
                                shape: BoxShape.rectangle,
                                image: DecorationImage(
                                  fit: BoxFit.cover,
                                  image: members['image_512'] != null && members['image_512'] != ''
                                      ? NetworkImage(members['image_512'])
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
                                  members['family_head_id']['name'] != null && members['family_head_id']['name'] != '' ? Row(
                                    children: [
                                      Flexible(
                                        child: RichText(
                                          textAlign: TextAlign.left,
                                          text: TextSpan(
                                              text: members['name'],
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
                                          members['name'],
                                          style: GoogleFonts.secularOne(
                                              fontSize: size.height * 0.02,
                                              color: textColor
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  members['reference'] != null && members['reference'] != '' ? Row(
                                    children: [
                                      Flexible(
                                        child: Text(
                                          'FCN : ',
                                          style: GoogleFonts.secularOne(
                                            fontSize: size.height * 0.018,
                                            color: blackColor,
                                          ),
                                        ),
                                      ),
                                      Text(
                                        members['reference'],
                                        style: GoogleFonts.secularOne(
                                          fontSize: size.height * 0.018,
                                          color: Colors.teal,
                                        ),
                                      ),
                                    ],
                                  ) : Container(),
                                  members['parish_bcc_id']['name'] != '' && members['parish_bcc_id']['name'] != null ? Text(
                                    members['parish_bcc_id']['name'],
                                    style: GoogleFonts.secularOne(fontSize: size.height * 0.018, color: emptyColor,),
                                  ) : Container(),
                                  members['mobile'] != '' && members['mobile'] != null ? IntrinsicHeight(
                                    child: (members['mobile']).split(',').length != 1 ? Row(
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
                                                          callAction((members['mobile']).split(',')[0].trim());
                                                        },
                                                        icon: const Icon(Icons.phone),
                                                        color: callColor,
                                                      ),
                                                      IconButton(
                                                        onPressed: () {
                                                          Navigator.pop(context);
                                                          smsAction((members['mobile']).split(',')[0].trim());
                                                        },
                                                        icon: const Icon(Icons.message),
                                                        color: smsColor,
                                                      ),
                                                      IconButton(
                                                        onPressed: () {
                                                          Navigator.pop(context);
                                                          whatsappAction((members['mobile']).split(',')[0].trim());
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
                                            (members['mobile']).split(',')[0].trim(),
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
                                                          callAction((members['mobile']).split(',')[1].trim());
                                                        },
                                                        icon: const Icon(Icons.phone),
                                                        color: callColor,
                                                      ),
                                                      IconButton(
                                                        onPressed: () {
                                                          Navigator.pop(context);
                                                          smsAction((members['mobile']).split(',')[1].trim());
                                                        },
                                                        icon: const Icon(Icons.message),
                                                        color: smsColor,
                                                      ),
                                                      IconButton(
                                                        onPressed: () {
                                                          Navigator.pop(context);
                                                          whatsappAction((members['mobile']).split(',')[1].trim());
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
                                            (members['mobile']).split(',')[1].trim(),
                                            style: GoogleFonts.secularOne(
                                                color: mobileText,
                                                fontSize: size.height * 0.018
                                            ),),
                                        )
                                      ],
                                    ) : Row(
                                      children: [
                                        Text(
                                          (members['mobile']).split(',')[0].trim(),
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
                                                callAction((members['mobile']).split(',')[0].trim());
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
                                                smsAction((members['mobile']).split(',')[0].trim());
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
                                                whatsappAction((members['mobile']).split(',')[0].trim());
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
                                  Container(width: size.width * 0.25, alignment: Alignment.topLeft, child: Text('Settled as', style: GoogleFonts.signika(fontSize: size.height * 0.02, color: labelColor),)),
                                  Text(':  ', style: GoogleFonts.signika(fontSize: size.height * 0.02, color: labelColor),)
                                ],
                              ),
                              members['settlement_status'] != '' && members['settlement_status'] != null ? Text(
                                members['settlement_status'],
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
                                  Container(width: size.width * 0.25, alignment: Alignment.topLeft, child: Text('Economic', style: GoogleFonts.signika(fontSize: size.height * 0.02, color: labelColor),)),
                                  Text(':  ', style: GoogleFonts.signika(fontSize: size.height * 0.02, color: labelColor),)
                                ],
                              ),
                              members['economic_status'] != '' && members['economic_status'] != null ? Text(
                                members['economic_status'],
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
                                  Container(width: size.width * 0.25, alignment: Alignment.topLeft, child: Text('House Type', style: GoogleFonts.signika(fontSize: size.height * 0.02, color: labelColor),)),
                                  Text(':  ', style: GoogleFonts.signika(fontSize: size.height * 0.02, color: labelColor),)
                                ],
                              ),
                              members['house_type_id']['name'] != '' && members['house_type_id']['name'] != null ? Text(
                                members['house_type_id']['name'],
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
                                  Container(width: size.width * 0.25, alignment: Alignment.topLeft, child: Text('House Ownership', style: GoogleFonts.signika(fontSize: size.height * 0.02, color: labelColor),)),
                                  Text(':  ', style: GoogleFonts.signika(fontSize: size.height * 0.02, color: labelColor),)
                                ],
                              ),
                              members['house_ownership'] != '' && members['house_ownership'] != null ? Text(
                                members['house_ownership'],
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
                              Container(width: size.width * 0.25, alignment: Alignment.topLeft, child: Text('Residential Address', style: GoogleFonts.signika(fontSize: size.height * 0.02, color: labelColor),)),
                              Text(':  ', style: GoogleFonts.signika(fontSize: size.height * 0.02, color: labelColor),)
                            ],
                          ),
                          members['street'] == '' && members['street2'] == '' && members['city'] == '' && members['district_id'] == [] && members['state_id'] == [] && members['country_id'] == [] && members['zip'] == '' ? Text(
                            'NA',
                            style: GoogleFonts.secularOne(fontSize: size.height * 0.02, color: emptyColor, fontStyle: FontStyle.italic),
                          ) : Flexible(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                members['street'] != '' ? Text("${members['street']},", style: GoogleFonts.secularOne(color: valueColor, fontSize: size.height * 0.02),) : Container(),
                                members['street2'] != '' ? Text("${members['street2']},", style: GoogleFonts.secularOne(color: valueColor, fontSize: size.height * 0.02),) : Container(),
                                members['city'] != '' ? Text("${members['city']},", style: GoogleFonts.secularOne(color: valueColor, fontSize: size.height * 0.02),) : Container(),
                                members['district_id'] != [] && members['country_id'] != null ? Text("${members['district_id']['name']},", style: GoogleFonts.secularOne(color: valueColor, fontSize: size.height * 0.02),) : Container(),
                                members['state_id'] != [] && members['country_id'] != null ? Text("${members['state_id']['name']},", style: GoogleFonts.secularOne(color: valueColor, fontSize: size.height * 0.02),) : Container(),
                                members['country_id'] != [] && members['country_id'] != null ? Text("${members['country_id']['name']},", style: GoogleFonts.secularOne(color: valueColor, fontSize: size.height * 0.02),) : Container(),
                                members['zip'] != '' ? Text("${members['zip']}.", style: GoogleFonts.secularOne(color: valueColor, fontSize: size.height * 0.02),) : Container()
                              ],
                            ),
                          )
                        ],
                      ),
                    ),
                  ),
                  members['same_as_above_address'] == true ? Card(
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
                              Container(width: size.width * 0.25, alignment: Alignment.topLeft, child: Text('Permanent Address', style: GoogleFonts.signika(fontSize: size.height * 0.02, color: labelColor),)),
                              Text(':  ', style: GoogleFonts.signika(fontSize: size.height * 0.02, color: labelColor),)
                            ],
                          ),
                          members['permanent_street'] == '' && members['permanent_street2'] == '' && members['permanent_city'] == '' && members['permanent_district_id'] == [] && members['permanent_state_id'] == [] && members['permanent_country_id'] == [] && members['permanent_zip'] == '' ? Text(
                            'NA',
                            style: GoogleFonts.secularOne(fontSize: size.height * 0.02, color: emptyColor, fontStyle: FontStyle.italic),
                          ) : Flexible(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                members['permanent_street'] != '' ? Text("${members['permanent_street']},", style: GoogleFonts.secularOne(color: valueColor, fontSize: size.height * 0.02),) : Container(),
                                members['permanent_street2'] != '' ? Text("${members['permanent_street2']},", style: GoogleFonts.secularOne(color: valueColor, fontSize: size.height * 0.02),) : Container(),
                                members['permanent_city'] != '' ? Text("${members['permanent_city']},", style: GoogleFonts.secularOne(color: valueColor, fontSize: size.height * 0.02),) : Container(),
                                members['permanent_district_id'] != [] && members['permanent_country_id'] != null ? Text("${members['permanent_district_id']['name']},", style: GoogleFonts.secularOne(color: valueColor, fontSize: size.height * 0.02),) : Container(),
                                members['permanent_state_id'] != [] && members['permanent_country_id'] != null ? Text("${members['permanent_state_id']['name']},", style: GoogleFonts.secularOne(color: valueColor, fontSize: size.height * 0.02),) : Container(),
                                members['permanent_country_id'] != [] && members['permanent_country_id'] != null ? Text("${members['permanent_country_id']['name']},", style: GoogleFonts.secularOne(color: valueColor, fontSize: size.height * 0.02),) : Container(),
                                members['permanent_zip'] != '' ? Text("${members['permanent_zip']}.", style: GoogleFonts.secularOne(color: valueColor, fontSize: size.height * 0.02),) : Container()
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ) : Container(),
                  SizedBox(
                    height: size.height * 0.01,
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
      ),
    );
  }
}
