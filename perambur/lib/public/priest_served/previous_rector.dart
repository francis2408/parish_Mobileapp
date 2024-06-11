import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:loading_indicator/loading_indicator.dart';
import 'package:perambur/widget/common/common.dart';
import 'package:perambur/widget/common/internet_connection_checker.dart';
import 'package:perambur/widget/common/slide_animations.dart';
import 'package:perambur/widget/theme_color/theme_color.dart';
import 'package:perambur/widget/widget.dart';
import 'package:url_launcher/url_launcher.dart';

class PreviousRector extends StatefulWidget {
  const PreviousRector({Key? key}) : super(key: key);

  @override
  State<PreviousRector> createState() => _PreviousRectorState();
}

class _PreviousRectorState extends State<PreviousRector> {
  int index = 0;
  bool _isLoading = true;
  List members = [];

  getPublicPriestServedData() async {
    var request = http.Request('GET', Uri.parse("$baseUrl/public/parish.priest.history/get_priest_details"));
    request.body = json.encode({
      "params": {
        "args": [int.parse(parishID)]
      }
    });
    request.headers.addAll(headers);
    http.StreamedResponse response = await request.send();
    if (response.statusCode == 200) {
      List data = json.decode(await response.stream.bytesToString())['result'];
      setState(() {
        _isLoading = false;
      });
      for(var datas in data) {
        if (datas['role_id'] == "Rector") {
          members.add(datas);
        }
      }
    } else {
      var message = json.decode(await response.stream.bytesToString())['message'];
      setState(() {
        _isLoading = false;
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

  getUserPriestServedData() async {
    var request = http.Request('GET', Uri.parse("$baseUrl/parish.priest.history/get_priest_details"));
    request.body = json.encode({
      "params": {
        "args": [int.parse(parishID)]
      }
    });
    request.headers.addAll(header);
    http.StreamedResponse response = await request.send();
    if (response.statusCode == 200) {
      var decode = json.decode(await response.stream.bytesToString())['result'];
      if(decode['status'] == true) {
        List data = decode['result'];
        setState(() {
          _isLoading = false;
        });
        for(var datas in data) {
          if (datas['role_id'] == "Rector") {
            members.add(datas);
          }
        }
      }
    } else {
      var message = json.decode(await response.stream.bytesToString())['message'];
      setState(() {
        _isLoading = false;
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
    if(!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      throw "Can not launch url";
    }
  }

  Future<void> webAction(String web) async {
    if (await canLaunch(web)) {
      await launch(web,forceWebView: true,forceSafariVC: false);
    } else {
      throw 'Could not launch $web';
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
    super.initState();
    isSignedIn ? getUserPriestServedData() : getPublicPriestServedData();
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
            'Previous Rector',
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
          ) : members.isNotEmpty ? SlideFadeAnimation(
            duration: const Duration(seconds: 1),
            child: SingleChildScrollView(
              child: ListView.builder(
                  shrinkWrap: true,
                  // scrollDirection: Axis.vertical,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: members.length,
                  itemBuilder: (BuildContext context, int index) {
                    return Padding(
                      padding: const EdgeInsets.only(left: 5, right: 5),
                      child: Card(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                        child: Container(
                          padding: const EdgeInsets.only(left: 10, top: 10, bottom: 10),
                          child: Row(
                            children: [
                              GestureDetector(
                                onTap: () {
                                  members[index]['image'] != '' ? showDialog(
                                    context: context,
                                    builder: (BuildContext context) {
                                      return Dialog(
                                        child: Image.network(members[index]['image'], fit: BoxFit.cover,),
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
                                  height: 95,
                                  width: 75,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(10),
                                    boxShadow: <BoxShadow>[
                                      if(members[index]['image'] != null && members[index]['image'] != '') const BoxShadow(
                                        color: Colors.grey,
                                        spreadRadius: -1,
                                        blurRadius: 5 ,
                                        offset: Offset(0, 1),
                                      ),
                                    ],
                                    shape: BoxShape.rectangle,
                                    image: DecorationImage(
                                      fit: BoxFit.cover,
                                      image: members[index]['image'] != null && members[index]['image'] != ''
                                          ? NetworkImage(members[index]['image'])
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
                                            child: Text.rich(
                                              textAlign: TextAlign.left,
                                              TextSpan(
                                                  text: members[index]['name'],
                                                  style: GoogleFonts.secularOne(
                                                    fontSize: size.height * 0.02,
                                                    color: textColor,
                                                  ),
                                                  children: [
                                                    const TextSpan(
                                                      text: '  ',
                                                    ),
                                                    if (members[index]['role_id'] != null && members[index]['role_id'] != '') TextSpan(
                                                      text: '(${members[index]['role_id']})',
                                                      style: GoogleFonts.secularOne(
                                                          fontSize: size.height * 0.018,
                                                          color: Colors.black45,
                                                          fontStyle: FontStyle.italic
                                                      ),
                                                    ),
                                                  ]
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
                                          members[index]['date_from'] != null && members[index]['date_from'] != '' ? Text(members[index]['date_from'], style: GoogleFonts.secularOne(color: valueColor, fontSize: size.height * 0.017),) : const Text(""),
                                          SizedBox(width: size.width * 0.03,),
                                          Text("-", style: GoogleFonts.secularOne(color: valueColor, fontSize: size.height * 0.02,),),
                                          SizedBox(width: size.width * 0.03,),
                                          members[index]['date_to'] != null && members[index]['date_to'] != '' ? Text(
                                            members[index]['date_to'], style: GoogleFonts.secularOne(color: valueColor, fontSize: size.height * 0.017,),
                                          ) : Text(
                                            "Till Now", style: GoogleFonts.secularOne(color: valueColor, fontSize: size.height * 0.017,),
                                          ),
                                        ],
                                      ),
                                      members[index]['email'] != null && members[index]['email'] != '' ? SizedBox(
                                        height: size.height * 0.005,
                                      ) : Container(),
                                      Row(
                                        children: [
                                          members[index]['email'] != null && members[index]['email'] != '' ? Flexible(
                                              child: GestureDetector(
                                                  onTap: () {
                                                    emailAction(members[index]['email']);
                                                  },
                                                  child: Text(
                                                    '${members[index]['email']}',
                                                    style: GoogleFonts.secularOne(
                                                        color: emailColor,
                                                        fontSize: size.height * 0.017
                                                    ),
                                                  )
                                              )
                                          ) : Container(),
                                        ],
                                      ),
                                      members[index]['mobile'] != '' && members[index]['mobile'] != null && (members[index]['mobile']).split(',').length != 1 ? SizedBox(
                                        height: size.height * 0.005,
                                      ) : Container(),
                                      Row(
                                        children: [
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
                                                        fontSize: size.height * 0.017
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
                                                    (members[index]['mobile']).split(',')[1].trim(),
                                                    style: GoogleFonts.secularOne(
                                                        color: mobileText,
                                                        fontSize: size.height * 0.017
                                                    ),
                                                  ),
                                                )
                                              ],
                                            ) : Row(
                                              children: [
                                                Text(
                                                  (members[index]['mobile']).split(',')[0].trim(),
                                                  style: GoogleFonts.secularOne(
                                                    color: mobileText,
                                                    fontSize: size.height * 0.017,
                                                  ),
                                                ),
                                                Row(
                                                  mainAxisSize: MainAxisSize.min,
                                                  children: [
                                                    IconButton(
                                                      onPressed: () {
                                                        callAction((members[index]['mobile']).split(',')[0].trim());
                                                      },
                                                      icon: const Icon(Icons.phone),
                                                      color: callColor,
                                                    ),
                                                    IconButton(
                                                      onPressed: () {
                                                        smsAction((members[index]['mobile']).split(',')[0].trim());
                                                      },
                                                      icon: const Icon(Icons.message),
                                                      color: smsColor,
                                                    ),
                                                    IconButton(
                                                      onPressed: () {
                                                        whatsappAction((members[index]['mobile']).split(',')[0].trim());
                                                      },
                                                      icon: SvgPicture.asset('assets/icons/whatsapp.svg', color: whatsAppColor, height: 20, width: 20,),
                                                      color: whatsAppColor,
                                                    ),
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
                      ),
                    );
                  }
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
