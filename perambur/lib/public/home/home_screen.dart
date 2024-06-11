import 'dart:convert';
import 'dart:io';

import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_svg/svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:loading_indicator/loading_indicator.dart';
import 'package:perambur/account/about.dart';
import 'package:perambur/authentication/login.dart';
import 'package:perambur/public/anbiyam/anbiyam.dart';
import 'package:perambur/public/announcement/announcement_screen.dart';
import 'package:perambur/public/association/association.dart';
import 'package:perambur/public/celebration/celebration_tab.dart';
import 'package:perambur/public/event/event_tab.dart';
import 'package:perambur/public/gallery/gallery_screen.dart';
import 'package:perambur/public/mass_timing/mass_timing.dart';
import 'package:perambur/public/news/news_tab_screen.dart';
import 'package:perambur/public/notification/notification_screen.dart';
import 'package:perambur/public/obituary/obituary_screen.dart';
import 'package:perambur/public/parish/parish_tab.dart';
import 'package:perambur/private/prayer/prayer_tab_screen.dart';
import 'package:perambur/public/prayer/send_prayer_request.dart';
import 'package:perambur/public/priest_served/previous_rector.dart';
import 'package:perambur/public/priest_served/priest_served.dart';
import 'package:perambur/public/rector_message/rector_message.dart';
import 'package:perambur/public/saints/saints_tab.dart';
import 'package:perambur/public/services/services_screen.dart';
import 'package:perambur/public/zone/zone_tab.dart';
import 'package:perambur/widget/bible/english_bible.dart';
import 'package:perambur/widget/bible/tamil_bible.dart';
import 'package:perambur/widget/common/common.dart';
import 'package:perambur/widget/common/internet_connection_checker.dart';
import 'package:perambur/widget/common/snackbar.dart';
import 'package:perambur/widget/common/web_view.dart';
import 'package:perambur/widget/theme_color/theme_color.dart';
import 'package:perambur/widget/widget.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

class PublicHomeScreen extends StatefulWidget {
  const PublicHomeScreen({Key? key}) : super(key: key);

  @override
  State<PublicHomeScreen> createState() => _PublicHomeScreenState();
}

class _PublicHomeScreenState extends State<PublicHomeScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey =  GlobalKey<ScaffoldState>();
  final bool _canPop = false;
  bool load = true;
  int activeIndex = 0;
  int activeNewsIndex = 0;
  int indexValue = 0;
  final controller = CarouselController();
  bool _isLoading = true;
  bool _isNews = true;
  List image = [];
  String url = '';
  List newsData = [];
  List todayBirthday = [];
  List todayFeastday = [];
  List todayDeath = [];
  List member = [];
  int total = 0;
  double destinationLatitude = 8.2753837;
  double destinationLongitude = 77.1776960;

  // Member Detail
  String memberName = '';
  String memberRole = '';
  String memberImage = '';
  String otherImage = '';
  String memberEmail = '';
  String youtube = '';


  List imgList = [
    'assets/images/two.jpg',
    'assets/images/one.jpg',
  ];

  List newsList = [
    "Welcome to Lourdes Shrine Perambur.",
  ];

  getData() {
    getImageData();
    getParishData();
    getNewsData();
  }

  getImageData() async {
    var pref = await SharedPreferences.getInstance();

    if(pref.containsKey('userLoggedInkey')) {
      isSignedIn = (pref.getBool('userLoggedInkey'))!;
    }

    if(pref.containsKey('setName')) {
      loginName = (pref.getString('setName'))!;
    }

    if(pref.containsKey('setPassword')) {
      loginPassword = (pref.getString('setPassword'))!;
    }

    if(pref.containsKey('setMobileNumber')) {
      mobileNumber = (pref.getString('setMobileNumber'))!;
    }

    if(pref.containsKey('setDatabaseName')) {
      databaseName = (pref.getString('setDatabaseName'))!;
    }

    if(pref.containsKey('userRememberKey')) {
      remember = (pref.getBool('userRememberKey'))!;
    }

    if(pref.containsKey('userRoleKey')) {
      userRole = (pref.getString('userRoleKey'))!;
    }

    var request = http.Request('GET', Uri.parse('$baseUrl/public/$parishID/parish_slider_images'));
    request.body = json.encode({});
    request.headers.addAll(headers);
    http.StreamedResponse response = await request.send();
    if (response.statusCode == 200) {
      var decode = json.decode(await response.stream.bytesToString())['result'];
      if(decode['status'] == 'success') {
        List data = decode['result'];
        image = data;
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
        for (var priest in data) {
          memberImage = priest['priest_id']['image_1920'] != null && priest['priest_id']['image_1920'] != '' ? priest['priest_id']['image_1920'] : '';
          memberName = priest['priest_id']['member_name'] != null && priest['priest_id']['member_name'] != '' ? priest['priest_id']['member_name'] : '';
          memberRole = priest['priest_id']['member_name'] != null && priest['priest_id']['member_name'] != '' ? 'Parish Priest' : '';
          youtube = priest['youtube'] != null && priest['youtube'] != '' ? priest['youtube'] : '';
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

  getNewsData() async {
    var request = http.Request('GET', Uri.parse('$baseUrl/public/$parishID/parish_published_news'));
    request.body = json.encode({});
    request.headers.addAll(headers);
    http.StreamedResponse response = await request.send();
    if (response.statusCode == 200) {
      var decode = json.decode(await response.stream.bytesToString())['result'];
      if(decode['status'] == 'success') {
        List data = decode['result'];
        setState(() {
          _isNews = false;
        });
        newsData = data;
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

  void changeData() {
    setState(() {
      _isLoading = true;
      getData();
    });
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
    getData();
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return WillPopScope(
      onWillPop: () async {
        if (_canPop) {
          return true;
        } else {
          showDialog(
            context: context,
            builder: (BuildContext context) {
              return ConfirmAlertDialog(
                message: 'Are you sure want to exit.',
                onYesPressed: () {
                  exit(0);
                },
                onCancelPressed: () {
                  Navigator.pop(context);
                },
              );
            },
          );
          return false;
        }
      },
      child: Scaffold(
          key: _scaffoldKey,
          backgroundColor: whiteColor,
          body: SafeArea(
            child: Stack(
              children: [
                const BackgroundWidget(),
                Center(
                  child: SingleChildScrollView(
                    child: _isLoading ? Center(
                      child: SizedBox(
                        height: size.height * 0.06,
                        child: const LoadingIndicator(
                          indicatorType: Indicator.ballSpinFadeLoader,
                          colors: [Colors.red,Colors.orange,Colors.yellow,Colors.green,Colors.blue,Colors.indigo,Colors.purple,],
                        ),
                      ),
                    ) : Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              GestureDetector(
                                onTap: () {
                                  _scaffoldKey.currentState?.openDrawer();
                                },
                                child: SizedBox(
                                  height: 35,
                                  width: 35,
                                  child: Padding(
                                    padding: const EdgeInsets.all(4.0),
                                    child: SvgPicture.asset("assets/icons/menu.svg", color: blackColor, height: 20,),
                                  ),
                                ),
                              ),
                              Text('Lourdes Shrine - Perambur',style: GoogleFonts.merriweather(
                                fontWeight: FontWeight.w900,letterSpacing: 0.2,
                                color: textHeadColor,
                                fontSize: 18,
                              ),),
                              GestureDetector(
                                onTap: () async {
                                  String refresh = await Navigator.push(context, CustomRoute(widget: const PublicNotificationScreen()));
                                },
                                child: SizedBox(
                                  height: 35,
                                  width: 35,
                                  child: Padding(
                                    padding: const EdgeInsets.all(4.0),
                                    child: SvgPicture.asset("assets/icons/notification.svg", color: blackColor, height: 20,),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.only(left: 15, right: 15, top: 10, bottom: 10),
                          child: Row(
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Welcome',
                                      style: GoogleFonts.chelaOne(
                                        letterSpacing: 0.8,
                                        fontSize: 20,
                                        color: emailText,
                                      ),
                                    ),
                                    Container(
                                      padding: EdgeInsets.only(left: size.width * 0.05),
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            memberName,
                                            style: GoogleFonts.merriweather(
                                                fontWeight: FontWeight.w800,
                                                color: textHeadColor,
                                                fontSize: 18
                                            ),
                                          ),
                                          Text(
                                            memberRole,
                                            style: GoogleFonts.cabin(
                                                fontWeight: FontWeight.w400,
                                                color: blackColor,
                                                fontSize: 13
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              GestureDetector(
                                onTap: () {
                                  showDialog(
                                    context: context,
                                    builder: (BuildContext context) {
                                      return memberImage != null && memberImage != '' ? Dialog(
                                        child: Image.network(memberImage, fit: BoxFit.cover,),
                                      ) : Dialog(
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
                                    shape: BoxShape.rectangle,
                                    image: DecorationImage(
                                      fit: BoxFit.cover,
                                      image: memberImage != null && memberImage != '' ? NetworkImage(memberImage) : const AssetImage('assets/images/jeffrey.jpg') as ImageProvider,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 5,),
                        CarouselSlider.builder(
                          carouselController: controller,
                          itemCount: image.isNotEmpty ? image.length : imgList.length,
                          itemBuilder: (context, index, realIndex) {
                            final urlImage = image.isNotEmpty ? image[index]['image_1920'] : imgList[index];
                            return ClipRRect(
                              borderRadius:
                              const BorderRadius.all(Radius.circular(20.0)),
                              child: image.isNotEmpty ? Image.network(urlImage, fit: BoxFit.fill, width: 1000.0) : Image.asset(urlImage, fit: BoxFit.cover, width: 1000.0),
                            );
                          },
                          options: CarouselOptions(
                            viewportFraction: 0.95,
                            aspectRatio: 2.0,
                            height: size.height * 0.2,
                            autoPlay: true,
                            enableInfiniteScroll: true,
                            autoPlayAnimationDuration: const Duration(seconds: 2),
                            enlargeCenterPage: true,
                            onPageChanged: ((index, reason) {
                              setState(() {
                                activeIndex = index;
                              });
                            }),
                          ),
                        ),
                        const SizedBox(height: 10,),
                        Container(
                            alignment: Alignment.center,
                            child: buildIndicator()
                        ),
                        const SizedBox(height: 10,),
                        newsData.isNotEmpty ? CarouselSlider.builder(
                          carouselController: controller,
                          itemCount: newsData.length,
                          itemBuilder: (context, index, realIndex) {
                            final news = newsData[index]['name'];
                            return Stack(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(10),
                                    gradient: LinearGradient(
                                      colors: [
                                        menuPrimaryColor.withOpacity(0.8),
                                        menuPrimaryColor,
                                      ],
                                      begin: Alignment.topLeft,
                                      end: Alignment.bottomRight,
                                    ),
                                  ),
                                  alignment: Alignment.center,
                                  child: Text(
                                    news,
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                    textAlign: TextAlign.left,
                                    style: GoogleFonts.roboto(
                                      textStyle: const TextStyle(color: whiteColor),
                                      fontSize: size.height * 0.017,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                                Positioned(
                                  bottom: -18,
                                  right: -18,
                                  child: Container(
                                    height: 50,
                                    width: 50,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: Colors.white.withOpacity(0.2),
                                    ),
                                  ),
                                ),
                              ],
                            );
                          },
                          options: CarouselOptions(
                            viewportFraction: 0.95,
                            aspectRatio: 2.0,
                            height: size.height * 0.06,
                            autoPlay: newsData.length > 1 ? true : false,
                            enableInfiniteScroll: newsData.length > 1 ? true : false,
                            autoPlayAnimationDuration: const Duration(seconds: 2),
                            enlargeCenterPage: true,
                            onPageChanged: ((index, reason) {
                              setState(() {
                                activeNewsIndex = index;
                              });
                            }),
                          ),
                        ) : CarouselSlider.builder(
                          carouselController: controller,
                          itemCount: newsList.length,
                          itemBuilder: (context, index, realIndex) {
                            final news = newsList[index];
                            return Stack(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(10),
                                    gradient: LinearGradient(
                                      colors: [
                                        menuPrimaryColor.withOpacity(0.8),
                                        menuPrimaryColor,
                                      ],
                                      begin: Alignment.topLeft,
                                      end: Alignment.bottomRight,
                                    ),
                                  ),
                                  alignment: Alignment.center,
                                  child: Text(
                                    news,
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                    textAlign: TextAlign.left,
                                    style: GoogleFonts.roboto(
                                      textStyle: const TextStyle(color: whiteColor),
                                      fontSize: size.height * 0.017,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                                Positioned(
                                  bottom: -18,
                                  right: -18,
                                  child: Container(
                                    height: 50,
                                    width: 50,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: Colors.white.withOpacity(0.2),
                                    ),
                                  ),
                                ),
                              ],
                            );
                          },
                          options: CarouselOptions(
                            viewportFraction: 0.95,
                            aspectRatio: 2.0,
                            height: size.height * 0.06,
                            autoPlay: newsList.length > 1 ? true : false,
                            enableInfiniteScroll: newsList.length > 1 ? true : false,
                            autoPlayAnimationDuration: const Duration(seconds: 2),
                            enlargeCenterPage: true,
                            onPageChanged: ((index, reason) {
                              setState(() {
                                activeNewsIndex = index;
                              });
                            }),
                          ),
                        ),
                        const SizedBox(height: 10,),
                        Container(
                          padding: const EdgeInsets.all(5.0),
                          child: Center(
                            child: Wrap(
                              spacing: 20,
                              runSpacing: 20,
                              children: [
                                HomeCard(
                                  onPressed: () async {
                                    String refresh = await Navigator.push(context, CustomRoute(widget: const RectorMessageScreen()));
                                    if(refresh == 'refresh') {
                                      changeData();
                                    }
                                  },
                                  icon: "assets/icons/chat.svg",
                                  title: "Priest Message",
                                  homeIconSize: 40,
                                  bcolor: Colors.orange.shade700.withOpacity(0.8),
                                  icolor: menuIconColor,
                                ),
                                HomeCard(
                                  onPressed: () async {
                                    String refresh = await Navigator.push(context, CustomRoute(widget: const PublicParishTabScreen()));
                                    if(refresh == 'refresh') {
                                      changeData();
                                    }
                                  },
                                  icon: "assets/icons/church.svg",
                                  title: "Parish",
                                  homeIconSize: 35,
                                  bcolor: Colors.purple.shade700.withOpacity(0.8),
                                  icolor: menuIconColor,
                                ),
                                HomeCard(
                                  onPressed: () async {
                                    String refresh = await Navigator.push(context, CustomRoute(widget: const PreviousRector()));
                                    if(refresh == 'refresh') {
                                      changeData();
                                    }
                                  },
                                  icon: "assets/icons/dean.svg",
                                  title: "Previous Rector",
                                  homeIconSize: 40,
                                  bcolor: Colors.deepOrange.shade700.withOpacity(0.8),
                                  icolor: menuIconColor,
                                ),
                                HomeCard(
                                  onPressed: () async {
                                    String refresh = await Navigator.push(context, CustomRoute(widget: const PriestServed()));
                                    if(refresh == 'refresh') {
                                      changeData();
                                    }
                                  },
                                  icon: "assets/icons/priest.svg",
                                  title: "Priest Served",
                                  homeIconSize: 40,
                                  bcolor: Colors.red.shade700.withOpacity(0.8),
                                  icolor: menuIconColor,
                                ),
                                HomeCard(
                                  onPressed: () async {
                                    String refresh = await Navigator.push(context, CustomRoute(widget: const PublicZoneTabScreen()));
                                    if(refresh == 'refresh') {
                                      changeData();
                                    }
                                  },
                                  icon: "assets/icons/zone.svg",
                                  title: "Zones",
                                  homeIconSize: 40,
                                  bcolor: Colors.indigo.shade700.withOpacity(0.8),
                                  icolor: menuIconColor,
                                ),
                                HomeCard(
                                  onPressed: () async {
                                    String refresh = await Navigator.push(context, CustomRoute(widget: const PublicAnbiyamScreen()));
                                    if(refresh == 'refresh') {
                                      changeData();
                                    }
                                  },
                                  icon: "assets/icons/anbiyam.svg",
                                  title: "Anbiyams",
                                  homeIconSize: 40,
                                  bcolor: Colors.teal.shade700.withOpacity(0.8),
                                  icolor: menuIconColor,
                                ),
                                HomeCard(
                                  onPressed: () async {
                                    String refresh = await Navigator.push(context, CustomRoute(widget: const PublicAssociationScreen()));
                                    if(refresh == 'refresh') {
                                      changeData();
                                    }
                                  },
                                  icon: "assets/icons/commission.svg",
                                  title: "Associations",
                                  homeIconSize: 40,
                                  bcolor: Colors.tealAccent.shade700.withOpacity(0.8),
                                  icolor: menuIconColor,
                                ),
                                HomeCard(
                                  onPressed: () async {
                                    String refresh = await Navigator.push(context, CustomRoute(widget: const PublicMassTimingScreen()));
                                    if(refresh == 'refresh') {
                                      changeData();
                                    }
                                  },
                                  icon: "assets/icons/mass.svg",
                                  title: "Mass Timings",
                                  homeIconSize: 40,
                                  bcolor: Colors.amber.shade700.withOpacity(0.8),
                                  icolor: menuIconColor,
                                ),
                                HomeCard(
                                  onPressed: () async {
                                    String refresh = await Navigator.push(context, CustomRoute(widget: const PublicEventTabScreen()));
                                    if(refresh == 'refresh') {
                                      changeData();
                                    }
                                  },
                                  icon: "assets/icons/calendar.svg",
                                  title: "Parish Events",
                                  homeIconSize: 40,
                                  bcolor: Colors.orange.shade700.withOpacity(0.8),
                                  icolor: menuIconColor,
                                ),
                                HomeCard(
                                  onPressed: () async {
                                    String refresh = await Navigator.push(context, CustomRoute(widget: const PublicNewsTabScreen()));
                                    if(refresh == 'refresh') {
                                      changeData();
                                    }
                                  },
                                  icon: "assets/icons/news_paper.svg",
                                  title: "Parish News",
                                  homeIconSize: 40,
                                  bcolor: Colors.deepOrangeAccent.shade700.withOpacity(0.8),
                                  icolor: menuIconColor,
                                ),
                                HomeCard(
                                  onPressed: () {
                                    showDialog(
                                      context: context,
                                      builder: (BuildContext context) {
                                        return CustomBibleDialog(
                                          onTamilPressed: () async {
                                            Navigator.pop(context);
                                            String refresh = await Navigator.push(context, CustomRoute(widget: const TamilBibleScreen()));
                                            if(refresh == 'refresh') {
                                              changeData();
                                            }
                                          },
                                          onEnglishPressed: () async {
                                            Navigator.pop(context);
                                            String refresh = await Navigator.push(context, CustomRoute(widget: const EnglishBibleScreen()));
                                            if(refresh == 'refresh') {
                                              changeData();
                                            }
                                          },
                                        );
                                      },
                                    );
                                  },
                                  icon: "assets/icons/bible.svg",
                                  title: "Bible",
                                  homeIconSize: 40,
                                  bcolor: Colors.brown.shade700.withOpacity(0.8),
                                  icolor: menuIconColor,
                                ),
                                HomeCard(
                                  onPressed: () async {
                                    String refresh = await Navigator.push(context, CustomRoute(widget: const PublicSaintsTabScreen()));
                                    if(refresh == 'refresh') {
                                      changeData();
                                    }
                                  },
                                  icon: "assets/icons/saint.svg",
                                  title: "Saints",
                                  homeIconSize: 40,
                                  bcolor: Colors.teal.shade700.withOpacity(0.8),
                                  icolor: menuIconColor,
                                ),
                                HomeCard(
                                  onPressed: () async {
                                    String refresh = await Navigator.push(context, CustomRoute(widget: const PublicGalleryScreen()));
                                    if(refresh == 'refresh') {
                                      changeData();
                                    }
                                  },
                                  icon: "assets/icons/gallery.svg",
                                  title: "Gallery",
                                  homeIconSize: 40,
                                  bcolor: Colors.indigo.shade700.withOpacity(0.8),
                                  icolor: menuIconColor,
                                ),
                                HomeCard(
                                  onPressed: () {
                                    youtube != '' && youtube != null ? Navigator.push(context, CustomRoute(widget: WebViewScreen(name: 'Youtube', url: 'https://www.youtube.com/channel/$youtube'))) : MediaSnackBar.show(
                                        context,
                                        'assets/png/youtube.png',
                                        'No YouTube channel was found.',
                                        blackColor.withOpacity(0.8)
                                    );
                                  },
                                  icon: "assets/icons/youtube.svg",
                                  title: "Youtube",
                                  homeIconSize: 40,
                                  bcolor: Colors.red,
                                  icolor: menuIconColor,
                                ),
                                HomeCard(
                                  onPressed: () async {
                                    String refresh = await Navigator.push(context, CustomRoute(widget: const PublicServicesScreen()));
                                    if(refresh == 'refresh') {
                                      changeData();
                                    }
                                  },
                                  icon: "assets/icons/service.svg",
                                  title: "Parish Services",
                                  homeIconSize: 40,
                                  bcolor: Colors.deepPurple.shade700.withOpacity(0.8),
                                  icolor: menuIconColor,
                                ),
                                HomeCard(
                                  onPressed: () async {
                                    String refresh = await Navigator.push(context, CustomRoute(widget: const PublicCelebrationTabScreen()));
                                    if(refresh == 'refresh') {
                                      changeData();
                                    }
                                  },
                                  icon: "assets/icons/birthday.svg",
                                  title: "Celebration",
                                  homeIconSize: 40,
                                  bcolor: Colors.pink.shade700.withOpacity(0.8),
                                  icolor: menuIconColor,
                                ),
                                HomeCard(
                                  onPressed: () async {
                                    String refresh = await Navigator.push(context, CustomRoute(widget: const PublicAnnouncementScreen()));
                                    if(refresh == 'refresh') {
                                      changeData();
                                    }
                                  },
                                  icon: "assets/icons/speaker.svg",
                                  title: "Announcement",
                                  homeIconSize: 40,
                                  bcolor: Colors.redAccent.shade700.withOpacity(0.8),
                                  icolor: menuIconColor,
                                ),
                                HomeCard(
                                  onPressed: () async {
                                    String refresh = await Navigator.push(context, CustomRoute(widget: const PublicObituaryScreen()));
                                    if(refresh == 'refresh') {
                                      changeData();
                                    }
                                  },
                                  icon: "assets/icons/rip.svg",
                                  title: "Obituary",
                                  homeIconSize: 40,
                                  bcolor: Colors.brown.shade700.withOpacity(0.8),
                                  icolor: menuIconColor,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ]
            ),
          ),
          drawer: Drawer(
            backgroundColor: whiteColor,
            child: ListView(
              padding: EdgeInsets.zero,
              children: [
                UserAccountsDrawerHeader(
                  accountName: Text(memberName, style: TextStyle(fontSize: size.height * 0.02, fontWeight: FontWeight.bold),),
                  accountEmail: Text(memberRole, style: TextStyle(fontSize: size.height * 0.018, fontWeight: FontWeight.bold),),
                  currentAccountPicture: CircleAvatar(
                    child: GestureDetector(
                      onTap: () {
                        memberImage != '' ? showDialog(
                          context: context,
                          builder: (BuildContext context) {
                            return Dialog(
                              child: Image.network(memberImage, fit: BoxFit.cover,),
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
                      child: ClipOval(
                        child: memberImage.isNotEmpty ? Image.network(
                            memberImage,
                            height: size.height * 0.1,
                            width: size.width * 0.2,
                            fit: BoxFit.cover
                        ) : Image.asset(
                          'assets/images/profile.png',
                          height: size.height * 0.1,
                          width: size.width * 0.2,
                        ),
                      ),
                    ),
                  ),
                  decoration: const BoxDecoration(
                      image: DecorationImage(
                          image: AssetImage(
                            'assets/images/nav.jpg',
                          ),
                          fit: BoxFit.cover
                      )
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 5.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      TextButton(
                        style: TextButton.styleFrom(
                            foregroundColor: navIconColor,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                            backgroundColor: Colors.transparent
                        ),
                        onPressed: () async {
                          Navigator.pop(context);
                          String refresh = await Navigator.push(context, CustomRoute(widget: const PublicAssociationScreen()));
                          if(refresh == 'refresh') {
                            changeData();
                          }
                        },
                        child: Row(
                          children: [
                            Container(
                              alignment: Alignment.center,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: SvgPicture.asset("assets/icons/commission.svg", color: Colors.greenAccent.shade700.withOpacity(0.8), height: 30, width: 30),
                            ),
                            SizedBox(width: size.width * 0.05),
                            Expanded(child: Text('Associations', style: TextStyle(fontSize: size.height * 0.019, color: valueColor, fontWeight: FontWeight.w600),)),
                            Icon(Icons.arrow_forward_ios, color: valueColor, size: size.height * 0.02,),
                          ],
                        ),
                      ),
                      const Divider(),
                      TextButton(
                        style: TextButton.styleFrom(
                            foregroundColor: navIconColor,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                            backgroundColor: Colors.transparent
                        ),
                        onPressed: () async {
                          Navigator.pop(context);
                          String refresh = await Navigator.push(context, CustomRoute(widget: const PublicAnnouncementScreen()));
                          if(refresh == 'refresh') {
                            changeData();
                          }
                        },
                        child: Row(
                          children: [
                            Container(
                              alignment: Alignment.center,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: SvgPicture.asset("assets/icons/speaker.svg", color: Colors.red.shade700.withOpacity(0.8), height: 30, width: 30),
                            ),
                            SizedBox(width: size.width * 0.05),
                            Expanded(child: Text('Announcements', style: TextStyle(fontSize: size.height * 0.019, color: valueColor, fontWeight: FontWeight.w600),)),
                            Icon(Icons.arrow_forward_ios, color: valueColor, size: size.height * 0.02,),
                          ],
                        ),
                      ),
                      const Divider(),
                      TextButton(
                        style: TextButton.styleFrom(
                            foregroundColor: navIconColor,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                            backgroundColor: Colors.transparent
                        ),
                        onPressed: () async {
                          Navigator.pop(context);
                          String refresh = await Navigator.push(context, CustomRoute(widget: const PublicSendPrayerRequest()));
                          if(refresh == 'refresh') {
                            changeData();
                          }
                        },
                        child: Row(
                          children: [
                            Container(
                              alignment: Alignment.center,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: SvgPicture.asset("assets/icons/rosary.svg", color: Colors.green.shade700.withOpacity(0.8), height: 30, width: 30),
                            ),
                            SizedBox(width: size.width * 0.05),
                            Expanded(child: Text('Prayer Request', style: TextStyle(fontSize: size.height * 0.019, color: valueColor, fontWeight: FontWeight.w600),)),
                            Icon(Icons.arrow_forward_ios, color: valueColor, size: size.height * 0.02,),
                          ],
                        ),
                      ),
                      const Divider(),
                      TextButton(
                        style: TextButton.styleFrom(
                            foregroundColor: navIconColor,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                            backgroundColor: Colors.transparent
                        ),
                        onPressed: () async {
                          Navigator.pop(context);
                          String refresh = await Navigator.push(context, CustomRoute(widget: const PublicSaintsTabScreen()));
                          if(refresh == 'refresh') {
                            changeData();
                          }
                        },
                        child: Row(
                          children: [
                            Container(
                              alignment: Alignment.center,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: SvgPicture.asset("assets/icons/saint.svg", color: Colors.teal.shade700.withOpacity(0.8), height: 30, width: 30),
                            ),
                            SizedBox(width: size.width * 0.05),
                            Expanded(child: Text("Today's Saint", style: TextStyle(fontSize: size.height * 0.019, color: valueColor, fontWeight: FontWeight.w600),)),
                            Icon(Icons.arrow_forward_ios, color: valueColor, size: size.height * 0.02,),
                          ],
                        ),
                      ),
                      const Divider(),
                      TextButton(
                        style: TextButton.styleFrom(
                            foregroundColor: navIconColor,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                            backgroundColor: Colors.transparent
                        ),
                        onPressed: () {
                          Navigator.pop(context);
                          showDialog(
                            context: context,
                            builder: (BuildContext context) {
                              return CustomBibleDialog(
                                onTamilPressed: () async {
                                  Navigator.pop(context);
                                  String refresh = await Navigator.push(context, CustomRoute(widget: const TamilBibleScreen()));
                                  if(refresh == 'refresh') {
                                    changeData();
                                  }
                                },
                                onEnglishPressed: () async {
                                  Navigator.pop(context);
                                  String refresh = await Navigator.push(context, CustomRoute(widget: const EnglishBibleScreen()));
                                  if(refresh == 'refresh') {
                                    changeData();
                                  }
                                },
                              );
                            },
                          );
                        },
                        child: Row(
                          children: [
                            Container(
                              alignment: Alignment.center,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: SvgPicture.asset("assets/icons/bible.svg", color: Colors.brown.shade700.withOpacity(0.8), height: 30, width: 30),
                            ),
                            SizedBox(width: size.width * 0.05),
                            Expanded(child: Text('Bible', style: TextStyle(fontSize: size.height * 0.019, color: valueColor, fontWeight: FontWeight.w600),)),
                            Icon(Icons.arrow_forward_ios, color: valueColor, size: size.height * 0.02,),
                          ],
                        ),
                      ),
                      const Divider(),
                      TextButton(
                        style: TextButton.styleFrom(
                            foregroundColor: navIconColor,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                            backgroundColor: Colors.transparent
                        ),
                        onPressed: () async {
                          Navigator.pop(context);
                          String refresh = await Navigator.push(context, CustomRoute(widget: const PublicNotificationScreen()));
                          if(refresh == 'refresh') {
                            changeData();
                          }
                        },
                        child: Row(
                          children: [
                            Container(
                              alignment: Alignment.center,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: SvgPicture.asset("assets/icons/notification.svg", color: Colors.amber.shade700.withOpacity(0.8), height: 30, width: 30),
                            ),
                            SizedBox(width: size.width * 0.05),
                            Expanded(child: Text('Notifications', style: TextStyle(fontSize: size.height * 0.019, color: valueColor, fontWeight: FontWeight.w600),)),
                            Icon(Icons.arrow_forward_ios, color: valueColor, size: size.height * 0.02,),
                          ],
                        ),
                      ),
                      const Divider(),
                      TextButton(
                        style: TextButton.styleFrom(
                            foregroundColor: navIconColor,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                            backgroundColor: Colors.transparent
                        ),
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        child: Row(
                          children: [
                            Container(
                              alignment: Alignment.center,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: SvgPicture.asset("assets/icons/route.svg", color: Colors.redAccent.shade700.withOpacity(0.8), height: 30, width: 30),
                            ),
                            SizedBox(width: size.width * 0.05),
                            Expanded(child: Text('Route', style: TextStyle(fontSize: size.height * 0.019, color: valueColor, fontWeight: FontWeight.w600),)),
                            Icon(Icons.arrow_forward_ios, color: valueColor, size: size.height * 0.02,),
                          ],
                        ),
                      ),
                      const Divider(),
                      TextButton(
                        style: TextButton.styleFrom(
                            foregroundColor: navIconColor,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                            backgroundColor: Colors.transparent
                        ),
                        onPressed: () async {
                          Navigator.pop(context);
                          String refresh = await Navigator.push(context, CustomRoute(widget: const AboutScreen()));
                          if(refresh == 'refresh') {
                            changeData();
                          }
                        },
                        child: Row(
                          children: [
                            Container(
                              alignment: Alignment.center,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: SvgPicture.asset("assets/icons/info.svg", color: Colors.indigo.shade700.withOpacity(0.8), height: 30, width: 30),
                            ),
                            SizedBox(width: size.width * 0.05),
                            Expanded(child: Text('About', style: TextStyle(fontSize: size.height * 0.019, color: valueColor, fontWeight: FontWeight.w600),)),
                            Icon(Icons.arrow_forward_ios, color: valueColor, size: size.height * 0.02,),
                          ],
                        ),
                      ),
                      const Divider(),
                      TextButton(
                        style: TextButton.styleFrom(
                            foregroundColor: navIconColor,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                            backgroundColor: Colors.transparent
                        ),
                        onPressed: () async {
                          Navigator.pop(context);
                        },
                        child: Row(
                          children: [
                            Container(
                              alignment: Alignment.center,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: SvgPicture.asset("assets/icons/feedback.svg", color: Colors.orange.shade700.withOpacity(0.8), height: 30, width: 30),
                            ),
                            SizedBox(width: size.width * 0.05),
                            Expanded(child: Text('Feedback', style: TextStyle(fontSize: size.height * 0.019, color: valueColor, fontWeight: FontWeight.w600),)),
                            Icon(Icons.arrow_forward_ios, color: valueColor, size: size.height * 0.02,),
                          ],
                        ),
                      ),
                      const Divider(),
                      TextButton(
                        style: TextButton.styleFrom(
                            foregroundColor: navIconColor,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                            backgroundColor: Colors.transparent
                        ),
                        onPressed: () async {
                          Navigator.pop(context);
                          String refresh = await Navigator.push(context, CustomRoute(widget: const PublicServicesScreen()));
                          if(refresh == 'refresh') {
                            changeData();
                          }
                        },
                        child: Row(
                          children: [
                            Container(
                              alignment: Alignment.center,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: SvgPicture.asset("assets/icons/service.svg", color: Colors.deepPurple.shade700.withOpacity(0.8), height: 25, width: 25),
                            ),
                            SizedBox(width: size.width * 0.05),
                            Expanded(child: Text('Services', style: TextStyle(fontSize: size.height * 0.019, color: valueColor, fontWeight: FontWeight.w600),)),
                            Icon(Icons.arrow_forward_ios, color: valueColor, size: size.height * 0.02,),
                          ],
                        ),
                      ),
                      const Divider(),
                      SizedBox(
                        height: size.height * 0.015,
                      ),
                      Padding(
                        padding: const EdgeInsets.only(left: 10),
                        child: Text(
                          'Account',
                          style: TextStyle(
                              fontSize: size.height * 0.022,
                              fontWeight: FontWeight.bold,
                              color: textHeadColor
                          ),
                          textAlign: TextAlign.left,
                        ),
                      ),
                      SizedBox(
                        height: size.height * 0.015,
                      ),
                      isSignedIn != true ? TextButton(
                        style: TextButton.styleFrom(
                            foregroundColor: navIconColor,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                            backgroundColor: Colors.transparent
                        ),
                        onPressed: () async {
                          Navigator.pop(context);
                          await Navigator.push(context, CustomRoute(widget: const LoginScreen()));
                        },
                        child: Row(
                          children: [
                            Container(
                              alignment: Alignment.center,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: SvgPicture.asset("assets/icons/key.svg", color: Colors.green.shade700.withOpacity(0.8), height: 25, width: 25),
                            ),
                            SizedBox(width: size.width * 0.05),
                            Expanded(child: Text('Login', style: TextStyle(fontSize: size.height * 0.019, color: valueColor, fontWeight: FontWeight.w600),)),
                          ],
                        ),
                      ) : Container(),
                      isSignedIn != true ? const Divider() : Container(),
                      isSignedIn ? TextButton(
                        style: TextButton.styleFrom(
                            foregroundColor: navIconColor,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                            backgroundColor: Colors.transparent
                        ),
                        onPressed: () {
                          Navigator.pop(context);
                          showDialog(
                            context: context,
                            builder: (BuildContext context) {
                              return ConfirmAlertDialog(
                                message: 'Are you sure you want to logout?',
                                onCancelPressed: () {
                                  Navigator.pop(context);
                                },
                                onYesPressed: () async {},
                              );
                            },
                          );
                        },
                        child: Row(
                          children: [
                            Container(
                              alignment: Alignment.center,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: SvgPicture.asset("assets/icons/logout.svg", color: Colors.redAccent.shade700.withOpacity(0.8), height: 25, width: 25),
                            ),
                            SizedBox(width: size.width * 0.05),
                            Expanded(child: Text('Logout', style: TextStyle(fontSize: size.height * 0.019, color: Colors.black, fontWeight: FontWeight.w600),)),
                          ],
                        ),
                      ) : Container(),
                      isSignedIn ? const Divider() : Container(),
                      TextButton(
                        style: TextButton.styleFrom(
                            foregroundColor: navIconColor,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                            backgroundColor: Colors.transparent
                        ),
                        onPressed: () {
                          Navigator.pop(context);
                          showDialog(
                            context: context,
                            builder: (BuildContext context) {
                              return ConfirmAlertDialog(
                                message: 'Are you sure want to exit.',
                                onYesPressed: () {
                                  exit(0);
                                },
                                onCancelPressed: () {
                                  Navigator.pop(context);
                                },
                              );
                            },
                          );
                        },
                        child: Row(
                          children: [
                            Container(
                              alignment: Alignment.center,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: SvgPicture.asset("assets/icons/exit.svg", color: Colors.redAccent.shade700.withOpacity(0.8), height: 25, width: 25),
                            ),
                            SizedBox(width: size.width * 0.05),
                            Expanded(child: Text('Exit', style: TextStyle(fontSize: size.height * 0.019, color: valueColor, fontWeight: FontWeight.w600),)),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: size.height * 0.1,),
                Text(
                  "v$curentVersion",
                  style: GoogleFonts.robotoSlab(
                    fontSize: size.height * 0.018,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(
                  height: size.height * 0.01,
                ),
                Text(
                  "© Boscosoft Technologies Pvt. Ltd.",
                  style: GoogleFonts.robotoSlab(
                    fontSize: size.height * 0.018,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(
                  height: size.height * 0.01,
                ),
              ],
            ),
          )
      ),
    );
  }

  Widget buildIndicator() => AnimatedSmoothIndicator(
    onDotClicked: animateToSlide,
    effect: const ExpandingDotsEffect(
      dotHeight: 5,
      dotWidth: 5,
      activeDotColor: menuPrimaryColor,
    ),
    activeIndex: activeIndex,
    count: image.isNotEmpty ? image.length : imgList.length,
  );

  void animateToSlide(int index) => controller.animateToPage(index);

  Widget buildTextIndicator() => AnimatedSmoothIndicator(
    onDotClicked: animatedToSlide,
    effect: const ExpandingDotsEffect(
        dotHeight: 3,
        dotWidth: 3,
        activeDotColor: Colors.white
    ),
    activeIndex: activeNewsIndex,
    count: newsData.isNotEmpty ? newsData.length : newsList.length,
  );

  void animatedToSlide(int index) => controller.animateToPage(index);
}

class HomeCard extends StatelessWidget {
  const HomeCard(
      {Key? key,
        required this.onPressed,
        required this.icon,
        required this.title,
        required this. homeIconSize,
        required this.icolor,
        required this. bcolor,
      })
      : super(key: key);
  final VoidCallback onPressed;
  final String icon;
  final String title;
  final double homeIconSize;
  final Color icolor;
  final Color bcolor;

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return InkWell(
      onTap: () {},
      child: SizedBox(
        height: size.height / 8.5,
        width: size.width / 4,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              height: size.height * 0.07,
              width: size.width * 0.15,
              decoration: BoxDecoration(
                color: bcolor,
                shape: BoxShape.rectangle,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Center(
                  child: IconButton(
                    icon: SvgPicture.asset(icon, color: icolor),
                    iconSize: homeIconSize,
                    onPressed: onPressed,
                  )
              ),
            ),
            Text(
              title,
              textAlign: TextAlign.center,
              style: GoogleFonts.raleway(
                  color: menuTextColor,
                  fontWeight: FontWeight.bold,
                  fontSize: size.height * 0.0155
              ),
            ),
          ],
        ),
      ),
    );
  }
}
