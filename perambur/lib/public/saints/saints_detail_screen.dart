import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:loading_indicator/loading_indicator.dart';
import 'package:perambur/widget/common/internet_connection_checker.dart';
import 'package:perambur/widget/common/slide_animations.dart';
import 'package:perambur/widget/theme_color/theme_color.dart';
import 'package:perambur/widget/widget.dart';

class PublicSaintsDetailsScreen extends StatefulWidget {
  final String image;
  final String name;
  final String birth;
  final String death;
  final String feastDay;
  final String feastMonth;
  final String description;
  const PublicSaintsDetailsScreen({Key? key, required this.image, required this.name, required this.birth, required this.death, required this.feastDay, required this.feastMonth, required this.description}) : super(key: key);

  @override
  State<PublicSaintsDetailsScreen> createState() => _PublicSaintsDetailsScreenState();
}

class _PublicSaintsDetailsScreenState extends State<PublicSaintsDetailsScreen> {
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
            "Today's Saint",
            style: TextStyle(
              fontSize: size.height * 0.02,
              fontWeight: FontWeight.bold,
              color: whiteColor,
            ),
          ),
          centerTitle: true,
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
          ) : Stack(
            children: [
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  image: DecorationImage(
                    fit: widget.image != null && widget.image != '' ? BoxFit.cover : BoxFit.contain,
                    image: widget.image != null && widget.image != ''
                        ? NetworkImage(widget.image)
                        : const AssetImage('assets/images/no_image.jpg') as ImageProvider,
                  ),
                ),
              ),
              Positioned(
                top: 20,
                right: 20,
                child: GestureDetector(
                  onTap: () {
                    showModalBottomSheet<void>(
                      context: context,
                      backgroundColor: screenBackgroundColor,
                      transitionAnimationController: AnimationController(
                        vsync: Navigator.of(context),
                        duration: const Duration(seconds: 1),
                      ),
                      shape: const RoundedRectangleBorder(
                        borderRadius: BorderRadius.vertical(top: Radius.circular(20.0)),
                      ),
                      builder: (BuildContext context) {
                        return CustomContentBottomSheet(
                            size: size,
                            title: "Description",
                            content: widget.description
                        );
                      },
                    );
                  },
                  child: Container(
                    padding: const EdgeInsets.all(2),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(30),
                        color: whiteColor,
                      ),
                      child: Image.asset("assets/png/about.png", height: 30, width: 30,)
                  ),
                ),
              ),
              Column(
                // crossAxisAlignment: CrossAxisAlignment.end,
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  SlideFadeAnimation(
                    duration: const Duration(seconds: 3),
                    child: Container(
                      height: size.height * 0.18,
                      decoration: const BoxDecoration(
                          color: whiteColor,
                          borderRadius: BorderRadius.only(topRight: Radius.circular(20), topLeft: Radius.circular(20))
                      ),
                      padding: const EdgeInsets.all(10),
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              widget.name != null && widget.name != '' ? Flexible(child: Text(widget.name, style: GoogleFonts.secularOne(color: textColor, fontSize: size.height * 0.022), textAlign: TextAlign.center,)) : Container(),
                            ],
                          ),
                          SizedBox(height: size.height * 0.01,),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Container(width: size.width * 0.2, alignment: Alignment.topLeft, child: Text('Feast', style: GoogleFonts.signika(fontSize: size.height * 0.02, color: labelColor),)),
                                  Text(':   ', style: GoogleFonts.signika(fontSize: size.height * 0.02, color: labelColor),)
                                ],
                              ),
                              Row(
                                children: [
                                  widget.feastDay != '' && widget.feastDay != null ? Text(
                                    widget.feastDay,
                                    style: GoogleFonts.signika(
                                      fontSize: size.height * 0.02,
                                      color: textHeadColor,
                                    ),
                                  ) : Container(),
                                  widget.feastDay != '' && widget.feastDay != null ? Text(
                                    ' - ',
                                    style: GoogleFonts.signika(
                                      fontSize: size.height * 0.02,
                                      color: textHeadColor,
                                    ),
                                  ) : Container(),
                                  Text(
                                    widget.feastMonth,
                                    style: GoogleFonts.signika(
                                      fontSize: size.height * 0.02,
                                      color: textHeadColor,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          SizedBox(height: size.height * 0.01,),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Container(width: size.width * 0.2, alignment: Alignment.topLeft, child: Text('Birth', style: GoogleFonts.signika(fontSize: size.height * 0.02, color: labelColor),)),
                                  Text(':   ', style: GoogleFonts.signika(fontSize: size.height * 0.02, color: labelColor),)
                                ],
                              ),
                              widget.birth != null && widget.birth != '' ? Flexible(child: Text(widget.birth, style: GoogleFonts.secularOne(color: Colors.black, fontSize: size.height * 0.02),)) : Text("NA", style: GoogleFonts.secularOne(fontSize: size.height * 0.02, color: Colors.grey, fontStyle: FontStyle.italic),),
                            ],
                          ),
                          SizedBox(height: size.height * 0.01,),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Container(width: size.width * 0.2, alignment: Alignment.topLeft, child: Text('Death', style: GoogleFonts.signika(fontSize: size.height * 0.02, color: labelColor),)),
                                  Text(':   ', style: GoogleFonts.signika(fontSize: size.height * 0.02, color: labelColor),)
                                ],
                              ),
                              widget.death != null && widget.death != '' ? Flexible(child: Text(widget.death, style: GoogleFonts.secularOne(color: Colors.black, fontSize: size.height * 0.02),)) : Text("NA", style: GoogleFonts.secularOne(fontSize: size.height * 0.02, color: Colors.grey, fontStyle: FontStyle.italic),),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}
