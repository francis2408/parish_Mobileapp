import 'dart:convert';

import 'package:avosa/widget/common/common.dart';
import 'package:avosa/widget/common/internet_connection_checker.dart';
import 'package:avosa/widget/theme_color/theme_color.dart';
import 'package:avosa/widget/widget.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:loading_indicator/loading_indicator.dart';

class SpecialMassScreen extends StatefulWidget {
  const SpecialMassScreen({Key? key}) : super(key: key);

  @override
  State<SpecialMassScreen> createState() => _SpecialMassScreenState();
}

class _SpecialMassScreenState extends State<SpecialMassScreen> {
  bool _isLoading = true;
  List mass = [];

  int selected = -1;
  int selected2 = -1;
  int selected3 = -1;
  bool isCategoryExpanded = false;

  getSpecialMassData() async {
    var request = http.Request('GET', Uri.parse('$baseUrl/special/mass'));
    request.body = json.encode({
      "params": {
        "parish_id": int.parse(parishID),
      }
    });
    request.headers.addAll(headers);
    http.StreamedResponse response = await request.send();
    if (response.statusCode == 200) {
      var decode = json.decode(await response.stream.bytesToString())['result'];
      setState(() {
        _isLoading = false;
      });
      mass = decode;
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
    getSpecialMassData();
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
            'Special Masses',
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
          ) : mass.isNotEmpty ? SingleChildScrollView(
            child: ListView.builder(
              key: UniqueKey(),
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: mass.length,
              itemBuilder: (BuildContext context, int index) {
                final isTileExpanded = index == selected;
                final textExpandColor = isTileExpanded ? expandColor : blackColor;
                return Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Card(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15.0),
                      ),
                      child: Container(
                        decoration: BoxDecoration(
                            color: secondaryColor,
                            borderRadius: BorderRadius.circular(15.0)
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
                          title: ListTile(
                            leading: GestureDetector(
                              onTap: () {
                                showDialog(
                                  context: context,
                                  builder: (BuildContext context) {
                                    return mass[index]['image'] != null && mass[index]['image'] != '' ? Dialog(
                                      child: Image.network(mass[index]['image'], fit: BoxFit.cover,),
                                    ) : Dialog(
                                      child: Image.asset('assets/images/no_image.jpg', fit: BoxFit.cover,),
                                    );
                                  },
                                );
                              },
                              child: Container(
                                // height: 95,
                                width: 60,
                                decoration: BoxDecoration(
                                  // borderRadius: BorderRadius.circular(10),
                                  shape: BoxShape.circle,
                                  image: DecorationImage(
                                    fit: BoxFit.cover,
                                    image: mass[index]['image'] != null && mass[index]['image'] != '' ? NetworkImage(mass[index]['image']) : const AssetImage('assets/images/no_image.jpg') as ImageProvider,
                                  ),
                                ),
                              ),
                            ),
                            title: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Container(width: size.width * 0.2, alignment: Alignment.topLeft, child: Text('Date', style: GoogleFonts.signika(fontSize: size.height * 0.02, color: labelColor, fontWeight: FontWeight.bold,),)),
                                    Text(':   ', style: GoogleFonts.signika(fontSize: size.height * 0.02, color: labelColor, fontWeight: FontWeight.bold,),)
                                  ],
                                ),
                                Text(
                                  '${mass[index]['date']}',
                                  style: GoogleFonts.roboto(
                                    fontSize: size.height * 0.02,
                                    color: textExpandColor,
                                  ),
                                ),
                              ],
                            ),
                            subtitle: Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Container(width: size.width * 0.2, alignment: Alignment.topLeft, child: Text('Name', style: GoogleFonts.signika(fontSize: size.height * 0.02, color: labelColor, fontWeight: FontWeight.bold,),)),
                                    Text(':   ', style: GoogleFonts.signika(fontSize: size.height * 0.02, color: labelColor, fontWeight: FontWeight.bold,),)
                                  ],
                                ),
                                Text(
                                  '${mass[index]['name']}',
                                  style: GoogleFonts.roboto(
                                    fontSize: size.height * 0.018,
                                    color: textExpandColor,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          children: [
                            ListView.builder(
                              key: Key('builder ${selected2.toString()}'),
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              itemCount: mass[index]['mass_lines'].length,
                              itemBuilder: (BuildContext context, int indexs) {
                                final isTileExpanded = indexs == selected2;
                                final textExpandColor = isTileExpanded ? secondaryColor : Colors.white;
                                return Column(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Card(
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(15.0),
                                      ),
                                      child: Container(
                                        decoration: BoxDecoration(
                                            color: primaryColor.withOpacity(0.9),
                                            borderRadius: BorderRadius.circular(15.0)
                                        ),
                                        child: ExpansionTile(
                                          key: Key(indexs.toString()),
                                          initiallyExpanded: indexs == selected2,
                                          backgroundColor: Colors.white,
                                          iconColor: iconColor,
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(15.0),
                                          ),
                                          onExpansionChanged: (newState) {
                                            if (newState) {
                                              setState(() {
                                                selected2 = indexs;
                                                selected3 = -1;
                                                isCategoryExpanded = true;
                                              });
                                            } else {
                                              setState(() {
                                                selected2 = -1;
                                                isCategoryExpanded = false;
                                              });
                                            }
                                          },
                                          title: Container(
                                            padding: const EdgeInsets.only(top: 10, bottom: 10),
                                            child: Text(
                                              '${mass[index]['mass_lines'][indexs]['community']}',
                                              style: GoogleFonts.roboto(
                                                fontSize: size.height * 0.02,
                                                color: textExpandColor,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ),
                                          children: [
                                            mass[index]['mass_lines'][indexs]['mass_ids'].isNotEmpty ? ListView.builder(
                                              key: Key('builder ${selected3.toString()}'),
                                              shrinkWrap: true,
                                              physics: const NeverScrollableScrollPhysics(),
                                              itemCount: isCategoryExpanded ? mass[index]['mass_lines'][indexs]['mass_ids'].length : 0, // Update the itemCount to 2 for two expansion tiles
                                              itemBuilder: (BuildContext context, int indexes) {
                                                return Column(
                                                  children: [
                                                    Container(
                                                      padding: const EdgeInsets.only(left: 10, top: 5, bottom: 5, right: 10),
                                                      child: Column(
                                                        crossAxisAlignment: CrossAxisAlignment.start,
                                                        children: [
                                                          Row(
                                                            crossAxisAlignment: CrossAxisAlignment.start,
                                                            children: [
                                                              Row(
                                                                children: [
                                                                  Container(width: size.width * 0.2, alignment: Alignment.topLeft, child: Text('Time', style: GoogleFonts.signika(fontSize: size.height * 0.02, color: labelColor),)),
                                                                  Text(':   ', style: GoogleFonts.signika(fontSize: size.height * 0.02, color: labelColor),)
                                                                ],
                                                              ),
                                                              mass[index]['mass_lines'][indexs]['mass_ids'][indexes]['time'] != '' && mass[index]['mass_lines'][indexs]['mass_ids'][indexes]['time'] != null ? Text(
                                                                mass[index]['mass_lines'][indexs]['mass_ids'][indexes]['time'],
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
                                                                children: [
                                                                  Container(width: size.width * 0.2, alignment: Alignment.topLeft, child: Text('Place', style: GoogleFonts.signika(fontSize: size.height * 0.02, color: labelColor),)),
                                                                  Text(':   ', style: GoogleFonts.signika(fontSize: size.height * 0.02, color: labelColor),)
                                                                ],
                                                              ),
                                                              mass[index]['mass_lines'][indexs]['mass_ids'][indexes]['place'] != '' && mass[index]['mass_lines'][indexs]['mass_ids'][indexes]['place'] != null ? Text(
                                                                mass[index]['mass_lines'][indexs]['mass_ids'][indexes]['place'],
                                                                style: GoogleFonts.secularOne(color: valueColor, fontSize: size.height * 0.02),
                                                              ) : Text(
                                                                'NA',
                                                                style: GoogleFonts.secularOne(fontSize: size.height * 0.02, color: emptyColor, fontStyle: FontStyle.italic),
                                                              )
                                                            ],
                                                          ),
                                                          mass[index]['mass_lines'][indexs]['mass_ids'][indexes]['note'] != '' && mass[index]['mass_lines'][indexs]['mass_ids'][indexes]['note'] != null ? Row(
                                                            crossAxisAlignment: CrossAxisAlignment.start,
                                                            children: [
                                                              Flexible(
                                                                child: RichText(
                                                                  textAlign: TextAlign.justify,
                                                                  text: TextSpan(
                                                                      text: '',
                                                                      children: [
                                                                        WidgetSpan(
                                                                          child: Container(width: size.width * 0.2, alignment: Alignment.topLeft, child: Text('Note', style: GoogleFonts.signika(fontSize: size.height * 0.02, color: labelColor),)),
                                                                        ),
                                                                        TextSpan(
                                                                          text: ':   ',
                                                                          style: GoogleFonts.signika(color: valueColor, fontSize: size.height * 0.02),
                                                                        ),
                                                                        TextSpan(
                                                                          text: mass[index]['mass_lines'][indexs]['mass_ids'][indexes]['note'],
                                                                          style: GoogleFonts.secularOne(color: valueColor, fontSize: size.height * 0.018),
                                                                        ),
                                                                      ]),
                                                                ),
                                                              ),
                                                            ],
                                                          ) : Row(
                                                            crossAxisAlignment: CrossAxisAlignment.start,
                                                            children: [
                                                              Row(
                                                                children: [
                                                                  Container(width: size.width * 0.2, alignment: Alignment.topLeft, child: Text('Note', style: GoogleFonts.signika(fontSize: size.height * 0.02, color: labelColor),)),
                                                                  Text(':   ', style: GoogleFonts.signika(fontSize: size.height * 0.02, color: labelColor),)
                                                                ],
                                                              ),
                                                              Text(
                                                                'NA',
                                                                style: GoogleFonts.secularOne(fontSize: size.height * 0.02, color: emptyColor, fontStyle: FontStyle.italic),
                                                              )
                                                            ],
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                    if(indexes < mass[index]['mass_lines'][indexs]['mass_ids'].length - 1) const Divider(
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
                                    ),
                                  ],
                                );
                              },
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
          ) : Center(
            child: Container(
              alignment: Alignment.center,
              padding: const EdgeInsets.only(left: 30, right: 30),
              child: NoResult(
                onPressed: () {
                  setState(() {
                    Navigator.pop(context, 'refresh');
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
