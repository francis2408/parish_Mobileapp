import 'package:flutter/material.dart';
import 'package:flutter_widget_from_html/flutter_widget_from_html.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:loading_indicator/loading_indicator.dart';
import 'package:perambur/widget/common/internet_connection_checker.dart';
import 'package:perambur/widget/common/slide_animations.dart';
import 'package:perambur/widget/theme_color/theme_color.dart';
import 'package:perambur/widget/widget.dart';

class PublicObituaryDetailScreen extends StatefulWidget {
  final String title;
  final String image;
  final String date;
  final String description;
  const PublicObituaryDetailScreen({Key? key, required this.title, required this.image, required this.date, required this.description}) : super(key: key);

  @override
  State<PublicObituaryDetailScreen> createState() => _PublicObituaryDetailScreenState();
}

class _PublicObituaryDetailScreenState extends State<PublicObituaryDetailScreen> {
  bool _isLoading = true;
  RegExp exp = RegExp(r"<[^>]*>",multiLine: true,caseSensitive: true);

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
    _isLoading = false;
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Scaffold(
      backgroundColor: screenBackgroundColor,
      appBar: AppBar(
        title: Text(
          'View Obituary',
          style: TextStyle(
            fontSize: size.height * 0.02,
            fontWeight: FontWeight.bold,
            color: whiteColor,
          ),
        ),
        centerTitle: true,
        flexibleSpace: Container(
          decoration: const BoxDecoration(
              gradient: LinearGradient(
                  colors: [
                    primaryColor,
                    secondaryColor
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight
              )
          ),
        ),
        // backgroundColor: backgroundColor,
      ),
      body: SlideFadeAnimation(
        duration: const Duration(seconds: 1),
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
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
              child: Container(
                width: size.width,
                height: size.height * 0.2,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(15),
                  color: Colors.white,
                  image: DecorationImage(
                    fit: BoxFit.contain,
                    image: widget.image != null && widget.image != ''
                        ? NetworkImage(widget.image)
                        : const AssetImage('assets/images/no_image.jpg') as ImageProvider,
                  ),
                ),
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    Card(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: widget.description.replaceAll(exp, '') != null && widget.description.replaceAll(exp, '') != '' ? Padding(
                        padding: const EdgeInsets.all(8),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(widget.title, style: GoogleFonts.secularOne(fontSize: size.height * 0.022)),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                const Icon(Icons.access_time, color: hiLightColor, size: 20,),
                                SizedBox(width: size.width * 0.02,),
                                Text(
                                  DateFormat('MMMM dd, yyyy').format(DateFormat('dd-MM-yyyy').parse(widget.date)),
                                  style: GoogleFonts.sansita(
                                      color: hiLightColor,
                                      fontSize: size.height * 0.018
                                  ),
                                )
                              ],
                            ),
                            SizedBox(height: size.height * 0.01,),
                            HtmlWidget(
                              widget.description,
                              customStylesBuilder: (element) {
                                if (element.localName == 'p') {
                                  return {
                                    'lineHeight': '1.3',
                                    'textAlign': 'justify',
                                  };
                                }
                                return null;
                              },
                            ),
                          ],
                        ),
                      ) : Padding(
                        padding: const EdgeInsets.all(5),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(width: size.width * 0.2, alignment: Alignment.topLeft, child: Text('Description', style: GoogleFonts.signika(fontSize: size.height * 0.02, fontStyle: FontStyle.italic, color: labelColor),)),
                            Text("NA", style: GoogleFonts.secularOne(fontSize: size.height * 0.02, color: emptyColor, fontStyle: FontStyle.italic),),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
