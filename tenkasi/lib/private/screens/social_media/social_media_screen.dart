import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:google_fonts/google_fonts.dart';
import 'package:loading_indicator/loading_indicator.dart';
import 'package:tenkasi/private/screens/gallery/gallery_screen.dart';
import 'package:tenkasi/widget/common/common.dart';
import 'package:tenkasi/widget/common/internet_connection_checker.dart';
import 'package:tenkasi/widget/common/slide_animations.dart';
import 'package:tenkasi/widget/common/snackbar.dart';
import 'package:tenkasi/widget/common/web_view.dart';
import 'package:tenkasi/widget/theme_color/theme_color.dart';
import 'package:tenkasi/widget/widget.dart';
import 'package:url_launcher/url_launcher.dart';

class SocialMediaScreen extends StatefulWidget {
  const SocialMediaScreen({Key? key}) : super(key: key);

  @override
  State<SocialMediaScreen> createState() => _SocialMediaScreenState();
}

class _SocialMediaScreenState extends State<SocialMediaScreen> {
  bool _isLoading = true;
  List parish = [];
  String youtube = '';
  String live = '';
  String twitter = '';
  String facebook = '';
  String insta = '';
  String link = '';

  getParishData() async {
    var request = http.Request('GET', Uri.parse('$baseUrl/public/$parishID/parish_details'));
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
        parish = data;
        for(int i = 0; i < parish.length; i++) {
          youtube = parish[i]['youtube'];
          twitter = parish[i]['twitter'];
          facebook = parish[i]['facebook'];
          live = parish[i]['livestream'];
          insta = parish[i]['instagram_account'];
          link = parish[i]['common_link'];
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

  Future<void> openYoutubeApp(String youtube) async {
    youtube != '' && youtube != null ? Navigator.push(context, CustomRoute(widget: WebViewScreen(name: 'Youtube', url: 'https://www.youtube.com/channel/$youtube'))) : MediaSnackBar.show(
        context,
        'assets/png/youtube.png',
        'No YouTube channel was found.',
        blackColor.withOpacity(0.8)
    );
  }

  Future<void> openYoutubeLiveApp(String live) async {
    live != '' && live != null ? Navigator.push(context, CustomRoute(widget: WebViewScreen(name: 'Youtube Live', url: live))) : MediaSnackBar.show(
        context,
        'assets/png/live.png',
        'No live YouTube video was found.',
        blackColor.withOpacity(0.8)
    );
  }

  Future<void> openTwitterApp(String twitter) async {
    twitter != '' && twitter != null ? Navigator.push(context, CustomRoute(widget: WebViewScreen(name: 'Twitter', url: twitter))) : MediaSnackBar.show(
        context,
        'assets/png/twitter.png',
        'No Twitter ID was found.',
        blackColor.withOpacity(0.8)
    );
  }

  Future<void> openFacebookApp(String facebook) async {
    facebook != '' && facebook != null ? Navigator.push(context, CustomRoute(widget: WebViewScreen(name: 'Facebook', url: facebook))) : MediaSnackBar.show(
        context,
        'assets/png/facebook.png',
        'No Facebook ID was found.',
        blackColor.withOpacity(0.8)
    );
  }

  Future<void> openInstaApp(String instagram) async {
    instagram != '' && instagram != null ? Navigator.push(context, CustomRoute(widget: WebViewScreen(name: 'Instagram', url: instagram))) : MediaSnackBar.show(
        context,
        'assets/png/insta.png',
        'No Instagram ID was found.',
        blackColor.withOpacity(0.8)
    );
  }

  Future<void> openLink(String web) async {
    try {
      await launch(
        web,
        forceWebView: false,
        enableJavaScript: true,
      );
    } catch (e) {
      MediaSnackBar.show(
          context,
          'assets/png/link.png',
          'No link found.',
          blackColor.withOpacity(0.8)
      );
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
    getParishData();
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
        appBar: AppBar(
          title: Text(
            'Social Media',
            style: TextStyle(
              fontSize: size.height * 0.02,
              fontWeight: FontWeight.bold,
              color: whiteColor,
            ),
          ),
          centerTitle: true,
          backgroundColor: appBackgroundColor,
        ),
        body: SafeArea(
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [whiteColor, primaryColor.withOpacity(0.2)], // Your gradient colors here
              ),
            ),
            child: _isLoading ? Center(
              child: SizedBox(
                height: size.height * 0.06,
                child: const LoadingIndicator(
                  indicatorType: Indicator.ballSpinFadeLoader,
                  colors: [Colors.red,Colors.orange,Colors.yellow,Colors.green,Colors.blue,Colors.indigo,Colors.purple,],
                ),
              ),
            ) : SlideFadeAnimation(
              duration: const Duration(seconds: 1),
              child: Column(
                children: [
                  SizedBox(height: size.height * 0.01,),
                  Container(
                    padding: const EdgeInsets.all(5.0),
                    child: Center(
                      child: Wrap(
                        spacing: 50,
                        runSpacing: 50,
                        children: [
                          MediaCard(
                            onPressed: () {
                              openYoutubeApp(youtube);
                            },
                            icon: "assets/png/youtube.png",
                            title: "Youtube Videos",
                            homeIconSize: 65,
                          ),
                          MediaCard(
                            onPressed: () {
                              openTwitterApp(twitter);
                            },
                            icon: "assets/png/twitter.png",
                            title: "Twitter",
                            homeIconSize: 65,
                          ),
                          MediaCard(
                            onPressed: () {
                              openFacebookApp(facebook);
                            },
                            icon: "assets/png/facebook.png",
                            title: "Facebook",
                            homeIconSize: 65,
                          ),
                          MediaCard(
                            onPressed: () {
                              openYoutubeLiveApp(live);
                            },
                            icon: "assets/png/live.png",
                            title: "Live Streaming",
                            homeIconSize: 65,
                          ),
                          MediaCard(
                            onPressed: () {
                              openInstaApp(insta);
                            },
                            icon: "assets/png/insta.png",
                            title: "Instagram",
                            homeIconSize: 65,
                          ),
                          MediaCard(
                            onPressed: () {
                              openLink(link);
                            },
                            icon: "assets/png/link.png",
                            title: "Link",
                            homeIconSize: 65,
                          ),
                          // MediaCard(
                          //   onPressed: () {
                          //     Navigator.push(context, CustomRoute(widget: const GalleryScreen()));
                          //   },
                          //   icon: "assets/png/gallery.png",
                          //   title: "Gallery",
                          //   homeIconSize: 65,
                          // ),
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
    );
  }
}

class MediaCard extends StatelessWidget {
  const MediaCard(
      {Key? key,
        required this.onPressed,
        required this.icon,
        required this.title,
        required this. homeIconSize,
      })
      : super(key: key);
  final VoidCallback onPressed;
  final String icon;
  final String title;
  final double homeIconSize;

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return InkWell(
      onTap: () {},
      child: SizedBox(
        height: size.height / 6,
        width: size.width / 3,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              height: size.height * 0.13,
              width: size.width * 0.3,
              decoration: BoxDecoration(
                color: whiteColor,
                shape: BoxShape.rectangle,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Center(
                  child: IconButton(
                    icon: Image.asset(icon),
                    iconSize: homeIconSize,
                    onPressed: onPressed,
                  )
              ),
            ),
            Text(
              title,
              textAlign: TextAlign.center,
              style: GoogleFonts.robotoSlab(
                  color: menuTextColor,
                  fontWeight: FontWeight.bold,
                  fontSize: size.height * 0.02
              ),
            ),
          ],
        ),
      ),
    );
  }
}