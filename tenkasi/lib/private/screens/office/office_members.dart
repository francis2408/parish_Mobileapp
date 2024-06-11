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

class OfficeMembersScreen extends StatefulWidget {
  const OfficeMembersScreen({Key? key}) : super(key: key);

  @override
  State<OfficeMembersScreen> createState() => _OfficeMembersScreenState();
}

class _OfficeMembersScreenState extends State<OfficeMembersScreen> {
  bool _isLoading = true;
  List officeMembers = [];

  getOfficeMembersData() async {
    var request = http.Request('GET', Uri.parse('$baseUrl/public/$parishID/parish_office_members_details'));
    request.body = json.encode({});
    request.headers.addAll(headers);
    http.StreamedResponse response = await request.send();
    if (response.statusCode == 200) {
      var decode = json.decode(await response.stream.bytesToString())['result'];
      if(decode['status'] == 'success') {
        List data = decode['result'];
        setState(() {
          _isLoading = false;
        });
        officeMembers = data;
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

  Future<void> emailAction(String email) async {
    final Uri uri = Uri(scheme: "mailto", path: email);
    if(!await launchUrl(
      uri,
      mode: LaunchMode.externalApplication,
    )) {
      throw "Can not launch url";
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
    getOfficeMembersData();
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
          backgroundColor: appBackgroundColor,
          title: Text(
            'Office Members',
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
          ) : officeMembers.isNotEmpty ? SlideFadeAnimation(
            duration: const Duration(seconds: 1),
            child: ListView.builder(
              itemCount: officeMembers.length,
              itemBuilder: (BuildContext context, int index) {
                return Column(
                  children: [
                    SizedBox(height: size.height * 0.003,),
                    Padding(
                      padding: const EdgeInsets.only(left: 5, right: 5),
                      child: Stack(
                        children: [
                          Card(
                            elevation: 2,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                GestureDetector(
                                  onTap: () {
                                    officeMembers[index]['member_id']['image_1920'] != null && officeMembers[index]['member_id']['image_1920'] != '' ? showDialog(
                                      context: context,
                                      builder: (BuildContext context) {
                                        return Dialog(
                                          child: Image.network(officeMembers[index]['member_id']['image_1920'], fit: BoxFit.cover,),
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
                                        image: officeMembers[index]['member_id']['image_1920'] != null && officeMembers[index]['member_id']['image_1920'] != ''
                                            ? NetworkImage(officeMembers[index]['member_id']['image_1920'])
                                            : const AssetImage('assets/images/profile.png') as ImageProvider,
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
                                                officeMembers[index]['member_id']['member_name'],
                                                style: GoogleFonts.secularOne(
                                                    fontSize: size.height * 0.02,
                                                    color: textColor
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                        SizedBox(height: size.height * 0.008,),
                                        officeMembers[index]['mobile'] != '' && officeMembers[index]['mobile'] != null ? IntrinsicHeight(
                                          child: (officeMembers[index]['mobile']).split(',').length != 1 ? Row(
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
                                                                callAction((officeMembers[index]['mobile']).split(',')[0].trim());
                                                              },
                                                              icon: const Icon(Icons.phone),
                                                              color: callColor,
                                                            ),
                                                            IconButton(
                                                              onPressed: () {
                                                                Navigator.pop(context);
                                                                smsAction((officeMembers[index]['mobile']).split(',')[0].trim());
                                                              },
                                                              icon: const Icon(Icons.message),
                                                              color: smsColor,
                                                            ),
                                                            IconButton(
                                                              onPressed: () {
                                                                Navigator.pop(context);
                                                                whatsappAction((officeMembers[index]['mobile']).split(',')[0].trim());
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
                                                  (officeMembers[index]['mobile']).split(',')[0].trim(),
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
                                                                callAction((officeMembers[index]['mobile']).split(',')[1].trim());
                                                              },
                                                              icon: const Icon(Icons.phone),
                                                              color: callColor,
                                                            ),
                                                            IconButton(
                                                              onPressed: () {
                                                                Navigator.pop(context);
                                                                smsAction((officeMembers[index]['mobile']).split(',')[1].trim());
                                                              },
                                                              icon: const Icon(Icons.message),
                                                              color: smsColor,
                                                            ),
                                                            IconButton(
                                                              onPressed: () {
                                                                Navigator.pop(context);
                                                                whatsappAction((officeMembers[index]['mobile']).split(',')[1].trim());
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
                                                  (officeMembers[index]['mobile']).split(',')[1].trim(),
                                                  style: GoogleFonts.secularOne(
                                                      color: mobileText,
                                                      fontSize: size.height * 0.018
                                                  ),),
                                              )
                                            ],
                                          ) : Row(
                                            children: [
                                              Text(
                                                (officeMembers[index]['mobile']).split(',')[0].trim(),
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
                                                      callAction((officeMembers[index]['mobile']).split(',')[0].trim());
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
                                                      smsAction((officeMembers[index]['mobile']).split(',')[0].trim());
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
                                                      whatsappAction((officeMembers[index]['mobile']).split(',')[0].trim());
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
                                        // officeMembers[index]['email'] != '' && officeMembers[index]['email'] != null ? IntrinsicHeight(
                                        //   child: (officeMembers[index]['mobile']).split(',').length != 1 ? Row(
                                        //     children: [
                                        //       GestureDetector(
                                        //         onTap: () {
                                        //           emailAction((officeMembers[index]['email']).split(',')[0].trim());
                                        //         },
                                        //         child: Text(
                                        //           (officeMembers[index]['email']).split(',')[0].trim(),
                                        //           style: GoogleFonts.secularOne(
                                        //               color: mobileText,
                                        //               fontSize: size.height * 0.018
                                        //           ),),
                                        //       ),
                                        //       SizedBox(width: size.width * 0.01,),
                                        //       const VerticalDivider(
                                        //         color: Colors.grey,
                                        //         thickness: 2,
                                        //       ),
                                        //       SizedBox(width: size.width * 0.01,),
                                        //       GestureDetector(
                                        //         onTap: () {
                                        //           emailAction((officeMembers[index]['email']).split(',')[1].trim());
                                        //         },
                                        //         child: Text(
                                        //           (officeMembers[index]['email']).split(',')[1].trim(),
                                        //           style: GoogleFonts.secularOne(
                                        //               color: emailColor,
                                        //               fontSize: size.height * 0.018
                                        //           ),),
                                        //       )
                                        //     ],
                                        //   ) : Row(
                                        //     children: [
                                        //       Text(
                                        //         (officeMembers[index]['email']).split(',')[0].trim(),
                                        //         style: GoogleFonts.secularOne(
                                        //           color: emailColor,
                                        //           fontSize: size.height * 0.018,
                                        //         ),
                                        //       ),
                                        //       Row(
                                        //         mainAxisSize: MainAxisSize.min,
                                        //         crossAxisAlignment: CrossAxisAlignment.center,
                                        //         children: [
                                        //           const SizedBox(width: 20,),
                                        //           GestureDetector(
                                        //             onTap: () {
                                        //               emailAction((officeMembers[index]['email']).split(',')[0].trim());
                                        //             },
                                        //             child: const Icon(
                                        //               Icons.email,
                                        //               size: 19,
                                        //               color: emailColor,
                                        //             ),
                                        //           ),
                                        //         ],
                                        //       ),
                                        //     ],
                                        //   ),
                                        // ) : Container(),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Positioned(
                            bottom: 5,
                            right: 5,
                            child: Container(
                              alignment: Alignment.center,
                              padding: const EdgeInsets.only(top: 1, bottom: 1, right: 5, left: 5),
                              decoration: const BoxDecoration(
                                borderRadius: BorderRadius.only(topLeft: Radius.circular(5), topRight: Radius.circular(5), bottomLeft: Radius.circular(5), bottomRight: Radius.circular(8),),
                                color: iconColor,
                              ),
                              child: Text(
                                officeMembers[index]['role_id']['name'],
                                style: GoogleFonts.secularOne(
                                    fontSize: size.height * 0.017,
                                    color: whiteColor
                                ),
                              ),
                            ),
                          )
                        ],
                      ),
                    ),
                    // SizedBox(height: size.height * 0.006,)
                  ],
                );
              },
            ),
          ) : Center(
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
      ),
    );
  }
}
