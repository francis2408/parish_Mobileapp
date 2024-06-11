import 'dart:convert';
import 'dart:io';

import 'package:avosa/account/about.dart';
import 'package:avosa/authentication/login.dart';
import 'package:avosa/private/announcement/announcement_tab.dart';
import 'package:avosa/private/blessings_prayers/blessings_prayers_tab.dart';
import 'package:avosa/private/blessings_prayers/send_prayer_request.dart';
import 'package:avosa/private/contact_us/contact_us.dart';
import 'package:avosa/private/events_news/events_news_tab.dart';
import 'package:avosa/private/mass_timing/mass_timing.dart';
import 'package:avosa/private/notification/common_notification.dart';
import 'package:avosa/private/notification/notification.dart';
import 'package:avosa/private/parish/parish.dart';
import 'package:avosa/private/prayers_links/prayers_links.dart';
import 'package:avosa/private/profile/profile.dart';
import 'package:avosa/private/special_mass/special_mass.dart';
import 'package:avosa/widget/common/common.dart';
import 'package:avosa/widget/common/internet_connection_checker.dart';
import 'package:avosa/widget/common/snackbar.dart';
import 'package:avosa/widget/helper/helper_function.dart';
import 'package:avosa/widget/theme_color/theme_color.dart';
import 'package:avosa/widget/widget.dart';
import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:loading_indicator/loading_indicator.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import 'package:url_launcher/url_launcher.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
  final GlobalKey<ScaffoldState> _scaffoldKey =  GlobalKey<ScaffoldState>();
  final controller = CarouselController();
  bool load = true;
  int activeIndex = 0;
  int activeNewsIndex = 0;
  bool _isLoading = true;
  bool _isNews = true;
  List image = [];
  String url = '';
  List newsData = [];

  // Member Detail
  String memberName = '';
  String memberRole = '';
  String memberImage = '';
  String otherImage = '';
  String memberEmail = '';
  String youtube = '';
  String zoneCount = '';
  String anbiyamCount = '';
  String familyCount = '';
  String membersCount = '';

  List imgList = [
    'assets/images/four.jpeg',
    'assets/images/three.jpeg',
  ];

  List newsList = [
    "Welcome to St. Mary's Catholic Church - Al Ain.",
  ];

  getNewsData() async {
    var pref = await SharedPreferences.getInstance();

    if(pref.containsKey('userLoggedInkey')) {
      isSignedIn = (pref.getBool('userLoggedInkey'))!;
    }

    if(pref.containsKey('userAuthTokenKey')) {
      authToken = (pref.getString('userAuthTokenKey'))!;
    }

    if(pref.containsKey('userNameKey')) {
      userName = (pref.getString('userNameKey'))!;
    }

    if(pref.containsKey('userEmailKey')) {
      userEmail = (pref.getString('userEmailKey'))!;
    }

    if(pref.containsKey('userMobileKey')) {
      userMobile = (pref.getString('userMobileKey'))!;
    }

    if(pref.containsKey('userLanguageKey')) {
      userLanguage = (pref.getInt('userLanguageKey'))!.toString();
    }

    if(pref.containsKey('userLanguagesKey')) {
      userLanguageName = (pref.getString('userLanguagesKey'))!;
    }

    if(pref.containsKey('userMinistryIdKey')) {
      userMinistry = (pref.getInt('userMinistryIdKey'))!.toString();
    }

    if(pref.containsKey('userMinistryIdsKey')) {
      userMinistryName = (pref.getString('userMinistryIdsKey'))!;
    }

    getParishData();
    var request = http.Request('GET', Uri.parse('$baseUrl/event_news/News'));
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
      newsData = decode;
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
    var request = http.Request('GET', Uri.parse('$baseUrl/mobile/parish_info'));
    request.body = json.encode({
      "params": {
        "parish_id": int.parse(parishID),
      }
    });
    request.headers.addAll(headers);
    http.StreamedResponse response = await request.send();
    if (response.statusCode == 200) {
      var decode = json.decode(await response.stream.bytesToString())['result'];
      if(decode['success'] == true) {
        var data = decode['data'];
        for(int i = 0; i < data.length; i++) {
          destinationLatitude = data['latitude'];
          destinationLongitude = data['longitude'];
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

  static void launchMapsUrl(
      double destinationLatitude,
      double destinationLongitude,
      ) async {
    final url = 'https://www.google.com/maps?q=$destinationLatitude,$destinationLongitude';
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      await launch(
        url,
        forceWebView: false,
        enableJavaScript: true,
      );
    }
  }

  logout() async {
    var request = http.Request('GET', Uri.parse('$baseUrl/mobile/logout'));
    request.body = json.encode({
      "params": {
        "token": authToken,
        "parish_id": int.parse(parishID),
      }
    });
    request.headers.addAll(headers);
    http.StreamedResponse response = await request.send();
    if (response.statusCode == 200) {
      var decode = json.decode(await response.stream.bytesToString())['result'];
      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.remove('userLoggedInkey');
      await prefs.remove('userAuthTokenKey');
      await HelperFunctions.setUserLoginSF(false);
      await Future.delayed(const Duration(seconds: 1));
      await Navigator.pushReplacement(context, CustomRoute(widget: const LoginScreen()));
      _flush();
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

  _flush() {
    AnimatedSnackBar.show(
        context,
        'Logout successfully',
        Colors.green
    );
  }

  void changeData() {
    setState(() {
      _isLoading = true;
      getNewsData();
    });
  }

  void showNotification(RemoteMessage message) async {
    await AwesomeNotifications().createNotification(
      content: NotificationContent(
        id: 0,
        channelKey: 'your_channel_key',
        title: message.notification!.title ?? 'Notification Title',
        body: message.notification!.body ?? 'Notification Body',
      ),
      actionButtons: [
        NotificationActionButton(
          key: 'action_key',
          label: 'Okay',
        ),
      ],
    );
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
    getNewsData();
    // Request for permission to show notifications (required for iOS)
    _firebaseMessaging.requestPermission();
    // Subscribe to a topic (optional)
    _firebaseMessaging.subscribeToTopic(db);
    // Handle notifications when the app is in the foreground
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      notificationCount++;
      // Display the notification using awesome_notifications
      showNotification(message);
    });

    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      setState(() {
        notificationCount = 0;
      });
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const CommonNotificationScreen()),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return WillPopScope(
      onWillPop: () async {
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
        return false; },
      child: Scaffold(
          key: _scaffoldKey,
          appBar: AppBar(
            backgroundColor: primaryColor,
            title: Text("St. Mary's Catholic Church - Al Ain", style: TextStyle(fontSize: size.height * 0.02,), maxLines: 2, textAlign: TextAlign.center,),
            centerTitle: true,
            leading: Container(
              alignment: Alignment.topLeft,
              child: IconButton(
                icon: SvgPicture.asset(
                  "assets/icons/menu.svg",
                  color: Colors.white,
                ),
                onPressed: () {
                  _scaffoldKey.currentState?.openDrawer();
                },
              ),
            ),
            actions: [
              Stack(
                children: [
                  IconButton(
                    icon: SvgPicture.asset(
                      "assets/icons/notification.svg",
                      color: Colors.white,
                      height: 25,
                      width: 25,
                    ),
                    onPressed: () async {
                      notificationCount = 0;
                      String refresh = await Navigator.push(context, CustomRoute(widget: isSignedIn ? const NotificationScreen() : const CommonNotificationScreen()));
                      if (refresh == 'refresh') {
                        changeData();
                      }
                    },
                  ),
                  if(notificationCount != 0 && notificationCount != null) Positioned(
                    top: 5,
                    right: 5,
                    child: Container(
                      alignment: Alignment.center,
                      padding: const EdgeInsets.all(2),
                      decoration: BoxDecoration(
                        color: redColor,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      constraints: const BoxConstraints(
                        minWidth: 18,
                        minHeight: 18,
                      ),
                      child: Text(
                        notificationCount.toString(),
                        style: const TextStyle(
                          color: whiteColor,
                          fontSize: 13,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
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
                            padding: const EdgeInsets.only(left: 15, right: 15, top: 10, bottom: 10),
                            child: isSignedIn ? RichText(
                              textAlign: TextAlign.center,
                              text: TextSpan(
                                  text: "Welcome ",
                                  style: GoogleFonts.chelaOne(
                                    letterSpacing: 0.8,
                                    fontSize: 18,
                                    color: emailText,
                                  ),
                                  children: [
                                    TextSpan(
                                      text: userName,
                                      style: GoogleFonts.merriweather(
                                          fontWeight: FontWeight.w800,
                                          color: textHeadColor,
                                          fontSize: 16
                                      ),
                                    ),
                                  ]),
                            ) : RichText(
                              textAlign: TextAlign.center,
                              text: TextSpan(
                                  text: "Welcome ",
                                  style: GoogleFonts.chelaOne(
                                    letterSpacing: 0.8,
                                    fontSize: 18,
                                    color: emailText,
                                  ),
                              ),
                            ),
                          ),
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
                                  if (isSignedIn) HomeCard(
                                    onPressed: () async {
                                      String refresh = await Navigator.push(context, CustomRoute(widget: const ProfileScreen()));
                                      if(refresh == 'refresh') {
                                        changeData();
                                      }
                                    },
                                    icon: "assets/icons/profile.svg",
                                    title: "Profile",
                                    homeIconSize: 40,
                                    bcolor: Colors.deepPurple.shade700.withOpacity(0.8),
                                    icolor: menuIconColor,
                                  ),
                                  HomeCard(
                                    onPressed: () async {
                                      String refresh = await Navigator.push(context, CustomRoute(widget: const ParishScreen()));
                                      if(refresh == 'refresh') {
                                        changeData();
                                      }
                                    },
                                    icon: "assets/icons/church.svg",
                                    title: "Parish Info",
                                    homeIconSize: 40,
                                    bcolor: Colors.orange.shade700.withOpacity(0.8),
                                    icolor: menuIconColor,
                                  ),
                                  HomeCard(
                                    onPressed: () async {
                                      String refresh = await Navigator.push(context, CustomRoute(widget: const MassTimingScreen()));
                                      if(refresh == 'refresh') {
                                        changeData();
                                      }
                                    },
                                    icon: "assets/icons/mass.svg",
                                    title: "Mass Timings",
                                    homeIconSize: 40,
                                    bcolor: Colors.deepOrange.shade700.withOpacity(0.8),
                                    icolor: menuIconColor,
                                  ),
                                  HomeCard(
                                    onPressed: () async {
                                      String refresh = await Navigator.push(context, CustomRoute(widget: const SpecialMassScreen()));
                                      if(refresh == 'refresh') {
                                        changeData();
                                      }
                                    },
                                    icon: "assets/icons/mass2.svg",
                                    title: "Special Masses",
                                    homeIconSize: 40,
                                    bcolor: Colors.red.shade700.withOpacity(0.8),
                                    icolor: menuIconColor,
                                  ),
                                  // HomeCard(
                                  //   onPressed: () {
                                  //     MediaSnackBar.show(
                                  //         context,
                                  //         'assets/images/logo.jpeg',
                                  //         'Confessions is not available now.',
                                  //         blackColor.withOpacity(0.8)
                                  //     );
                                  //   },
                                  //   icon: "assets/icons/confession.svg",
                                  //   title: "Confessions",
                                  //   homeIconSize: 40,
                                  //   bcolor: Colors.indigo.shade700.withOpacity(0.8),
                                  //   icolor: menuIconColor,
                                  // ),
                                  HomeCard(
                                    onPressed: () async {
                                      String refresh = await Navigator.push(context, CustomRoute(widget: const BlessingsAndPrayersScreen()));
                                      if(refresh == 'refresh') {
                                        changeData();
                                      }
                                    },
                                    icon: "assets/icons/blessing.svg",
                                    title: "Blessings & Prayers",
                                    homeIconSize: 40,
                                    bcolor: Colors.teal.shade700.withOpacity(0.8),
                                    icolor: menuIconColor,
                                  ),
                                  HomeCard(
                                    onPressed: () async {
                                      String refresh = await Navigator.push(context, CustomRoute(widget: const AnnouncementTabScreen()));
                                      if(refresh == 'refresh') {
                                        changeData();
                                      }
                                    },
                                    icon: "assets/icons/speaker.svg",
                                    title: "Announcement",
                                    homeIconSize: 40,
                                    bcolor: Colors.tealAccent.shade700.withOpacity(0.8),
                                    icolor: menuIconColor,
                                  ),
                                  HomeCard(
                                    onPressed: () async {
                                      String refresh = await Navigator.push(context, CustomRoute(widget: const EventsAndNewsTabScreen()));
                                      if(refresh == 'refresh') {
                                        changeData();
                                      }
                                    },
                                    icon: "assets/icons/calendar.svg",
                                    title: "Events News",
                                    homeIconSize: 40,
                                    bcolor: Colors.amber.shade700.withOpacity(0.8),
                                    icolor: menuIconColor,
                                  ),
                                  HomeCard(
                                    onPressed: () async {
                                      String refresh = await Navigator.push(context, CustomRoute(widget: const PrayersAndLinksScreen()));
                                      if(refresh == 'refresh') {
                                        changeData();
                                      }
                                    },
                                    icon: "assets/icons/prayer.svg",
                                    title: "Prayers & Links",
                                    homeIconSize: 60,
                                    bcolor: Colors.orange.shade700.withOpacity(0.8),
                                    icolor: menuIconColor,
                                  ),
                                  if (isSignedIn) HomeCard(
                                    onPressed: () async {
                                      String refresh = await Navigator.push(context, CustomRoute(widget: const SendPrayerRequest()));
                                      if(refresh == 'refresh') {
                                        changeData();
                                      }
                                    },
                                    icon: "assets/icons/rosary.svg",
                                    title: "Prayer Request",
                                    homeIconSize: 40,
                                    bcolor: Colors.lightGreen.shade700.withOpacity(0.8),
                                    icolor: menuIconColor,
                                  ),
                                  HomeCard(
                                    onPressed: () async {
                                      String refresh = await Navigator.push(context, CustomRoute(widget: const ContactUSScreen()));
                                      if(refresh == 'refresh') {
                                        changeData();
                                      }
                                    },
                                    icon: "assets/icons/contact.svg",
                                    title: "Contact Us",
                                    homeIconSize: 40,
                                    bcolor: Colors.blue.shade700.withOpacity(0.8),
                                    icolor: menuIconColor,
                                  ),
                                  HomeCard(
                                    onPressed: () {
                                      setState(() {
                                        showDialog(
                                          context: context,
                                          barrierDismissible: false,
                                          builder: (BuildContext context) {
                                            return const CustomLoadingDialog();
                                          },
                                        );
                                      });
                                      launchMapsUrl(double.parse(destinationLatitude), double.parse(destinationLongitude));
                                      Navigator.pop(context);
                                    },
                                    icon: "assets/icons/route.svg",
                                    title: "Route",
                                    homeIconSize: 40,
                                    bcolor: Colors.teal.shade700.withOpacity(0.8),
                                    icolor: menuIconColor,
                                  ),
                                  HomeCard(
                                    onPressed: () async {
                                      notificationCount = 0;
                                      String refresh = await Navigator.push(context, CustomRoute(widget: isSignedIn ? const NotificationScreen() : const CommonNotificationScreen()));
                                      if(refresh == 'refresh') {
                                        changeData();
                                      }
                                    },
                                    icon: "assets/icons/notification.svg",
                                    title: "Push Messages",
                                    homeIconSize: 40,
                                    bcolor: Colors.indigo.shade700.withOpacity(0.8),
                                    icolor: menuIconColor,
                                  ),
                                  HomeCard(
                                    onPressed: () async {
                                      String refresh = await Navigator.push(context, CustomRoute(widget: const AboutScreen()));
                                      if(refresh == 'refresh') {
                                        changeData();
                                      }
                                    },
                                    icon: "assets/icons/info.svg",
                                    title: "About",
                                    homeIconSize: 40,
                                    bcolor: Colors.deepPurpleAccent,
                                    icolor: menuIconColor,
                                  ),
                                  // if (isSignedIn) HomeCard(
                                  //   onPressed: () {
                                  //     MediaSnackBar.show(
                                  //         context,
                                  //         'assets/images/logo.jpeg',
                                  //         'Feedback is not available now.',
                                  //         blackColor.withOpacity(0.8)
                                  //     );
                                  //   },
                                  //   icon: "assets/icons/feedback.svg",
                                  //   title: "Feedback",
                                  //   homeIconSize: 40,
                                  //   bcolor: Colors.pink.shade700.withOpacity(0.8),
                                  //   icolor: menuIconColor,
                                  // ),
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
                  accountName: Text(userName, style: TextStyle(fontSize: size.height * 0.02, fontWeight: FontWeight.bold),),
                  accountEmail: Text(userEmail, style: TextStyle(fontSize: size.height * 0.018, fontWeight: FontWeight.bold),),
                  currentAccountPicture: CircleAvatar(
                    child: GestureDetector(
                      onTap: () {
                        showDialog(
                          context: context,
                          builder: (BuildContext context) {
                            return Dialog(
                              child: Image.asset('assets/images/profile.png', fit: BoxFit.cover,),
                            );
                          },
                        );
                      },
                      child: ClipOval(
                        child: Image.asset(
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
                            'assets/images/four.jpeg',
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
                      // TextButton(
                      //   style: TextButton.styleFrom(
                      //       foregroundColor: navIconColor,
                      //       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      //       backgroundColor: Colors.transparent
                      //   ),
                      //   onPressed: () async {
                      //     Navigator.pop(context);
                      //   },
                      //   child: Row(
                      //     children: [
                      //       Container(
                      //         alignment: Alignment.center,
                      //         decoration: BoxDecoration(
                      //           borderRadius: BorderRadius.circular(8),
                      //         ),
                      //         child: SvgPicture.asset("assets/icons/commission.svg", color: Colors.greenAccent.shade700.withOpacity(0.8), height: 30, width: 30),
                      //       ),
                      //       SizedBox(width: size.width * 0.05),
                      //       Expanded(child: Text('Associations', style: TextStyle(fontSize: size.height * 0.019, color: valueColor, fontWeight: FontWeight.w600),)),
                      //       Icon(Icons.arrow_forward_ios, color: valueColor, size: size.height * 0.02,),
                      //     ],
                      //   ),
                      // ),
                      // const Divider(),
                      // TextButton(
                      //   style: TextButton.styleFrom(
                      //       foregroundColor: navIconColor,
                      //       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      //       backgroundColor: Colors.transparent
                      //   ),
                      //   onPressed: () {},
                      //   child: Row(
                      //     children: [
                      //       Container(
                      //         alignment: Alignment.center,
                      //         decoration: BoxDecoration(
                      //           borderRadius: BorderRadius.circular(8),
                      //         ),
                      //         child: SvgPicture.asset("assets/icons/speaker.svg", color: Colors.red.shade700.withOpacity(0.8), height: 30, width: 30),
                      //       ),
                      //       SizedBox(width: size.width * 0.05),
                      //       Expanded(child: Text('Announcements', style: TextStyle(fontSize: size.height * 0.019, color: valueColor, fontWeight: FontWeight.w600),)),
                      //       Icon(Icons.arrow_forward_ios, color: valueColor, size: size.height * 0.02,),
                      //     ],
                      //   ),
                      // ),
                      // const Divider(),
                      // TextButton(
                      //   style: TextButton.styleFrom(
                      //       foregroundColor: navIconColor,
                      //       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      //       backgroundColor: Colors.transparent
                      //   ),
                      //   onPressed: () async {
                      //     Navigator.pop(context);
                      //   },
                      //   child: Row(
                      //     children: [
                      //       Container(
                      //         alignment: Alignment.center,
                      //         decoration: BoxDecoration(
                      //           borderRadius: BorderRadius.circular(8),
                      //         ),
                      //         child: SvgPicture.asset("assets/icons/rosary.svg", color: Colors.green.shade700.withOpacity(0.8), height: 30, width: 30),
                      //       ),
                      //       SizedBox(width: size.width * 0.05),
                      //       Expanded(child: Text('Prayer Request', style: TextStyle(fontSize: size.height * 0.019, color: valueColor, fontWeight: FontWeight.w600),)),
                      //       Icon(Icons.arrow_forward_ios, color: valueColor, size: size.height * 0.02,),
                      //     ],
                      //   ),
                      // ),
                      // const Divider(),
                      // TextButton(
                      //   style: TextButton.styleFrom(
                      //       foregroundColor: navIconColor,
                      //       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      //       backgroundColor: Colors.transparent
                      //   ),
                      //   onPressed: () {},
                      //   child: Row(
                      //     children: [
                      //       Container(
                      //         alignment: Alignment.center,
                      //         decoration: BoxDecoration(
                      //           borderRadius: BorderRadius.circular(8),
                      //         ),
                      //         child: SvgPicture.asset("assets/icons/saint.svg", color: Colors.teal.shade700.withOpacity(0.8), height: 30, width: 30),
                      //       ),
                      //       SizedBox(width: size.width * 0.05),
                      //       Expanded(child: Text("Today's Saint", style: TextStyle(fontSize: size.height * 0.019, color: valueColor, fontWeight: FontWeight.w600),)),
                      //       Icon(Icons.arrow_forward_ios, color: valueColor, size: size.height * 0.02,),
                      //     ],
                      //   ),
                      // ),
                      // const Divider(),
                      // TextButton(
                      //   style: TextButton.styleFrom(
                      //       foregroundColor: navIconColor,
                      //       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      //       backgroundColor: Colors.transparent
                      //   ),
                      //   onPressed: () {},
                      //   child: Row(
                      //     children: [
                      //       Container(
                      //         alignment: Alignment.center,
                      //         decoration: BoxDecoration(
                      //           borderRadius: BorderRadius.circular(8),
                      //         ),
                      //         child: SvgPicture.asset("assets/icons/notification.svg", color: Colors.amber.shade700.withOpacity(0.8), height: 30, width: 30),
                      //       ),
                      //       SizedBox(width: size.width * 0.05),
                      //       Expanded(child: Text('Notifications', style: TextStyle(fontSize: size.height * 0.019, color: valueColor, fontWeight: FontWeight.w600),)),
                      //       Icon(Icons.arrow_forward_ios, color: valueColor, size: size.height * 0.02,),
                      //     ],
                      //   ),
                      // ),
                      // const Divider(),
                      // TextButton(
                      //   style: TextButton.styleFrom(
                      //       foregroundColor: navIconColor,
                      //       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      //       backgroundColor: Colors.transparent
                      //   ),
                      //   onPressed: () {},
                      //   child: Row(
                      //     children: [
                      //       Container(
                      //         alignment: Alignment.center,
                      //         decoration: BoxDecoration(
                      //           borderRadius: BorderRadius.circular(8),
                      //         ),
                      //         child: SvgPicture.asset("assets/icons/route.svg", color: Colors.redAccent.shade700.withOpacity(0.8), height: 30, width: 30),
                      //       ),
                      //       SizedBox(width: size.width * 0.05),
                      //       Expanded(child: Text('Route', style: TextStyle(fontSize: size.height * 0.019, color: valueColor, fontWeight: FontWeight.w600),)),
                      //       Icon(Icons.arrow_forward_ios, color: valueColor, size: size.height * 0.02,),
                      //     ],
                      //   ),
                      // ),
                      // const Divider(),
                      // TextButton(
                      //   style: TextButton.styleFrom(
                      //       foregroundColor: navIconColor,
                      //       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      //       backgroundColor: Colors.transparent
                      //   ),
                      //   onPressed: () {},
                      //   child: Row(
                      //     children: [
                      //       Container(
                      //         alignment: Alignment.center,
                      //         decoration: BoxDecoration(
                      //           borderRadius: BorderRadius.circular(8),
                      //         ),
                      //         child: SvgPicture.asset("assets/icons/info.svg", color: Colors.indigo.shade700.withOpacity(0.8), height: 30, width: 30),
                      //       ),
                      //       SizedBox(width: size.width * 0.05),
                      //       Expanded(child: Text('About', style: TextStyle(fontSize: size.height * 0.019, color: valueColor, fontWeight: FontWeight.w600),)),
                      //       Icon(Icons.arrow_forward_ios, color: valueColor, size: size.height * 0.02,),
                      //     ],
                      //   ),
                      // ),
                      // const Divider(),
                      // TextButton(
                      //   style: TextButton.styleFrom(
                      //       foregroundColor: navIconColor,
                      //       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      //       backgroundColor: Colors.transparent
                      //   ),
                      //   onPressed: () async {
                      //     Navigator.pop(context);
                      //   },
                      //   child: Row(
                      //     children: [
                      //       Container(
                      //         alignment: Alignment.center,
                      //         decoration: BoxDecoration(
                      //           borderRadius: BorderRadius.circular(8),
                      //         ),
                      //         child: SvgPicture.asset("assets/icons/feedback.svg", color: Colors.orange.shade700.withOpacity(0.8), height: 30, width: 30),
                      //       ),
                      //       SizedBox(width: size.width * 0.05),
                      //       Expanded(child: Text('Feedback', style: TextStyle(fontSize: size.height * 0.019, color: valueColor, fontWeight: FontWeight.w600),)),
                      //       Icon(Icons.arrow_forward_ios, color: valueColor, size: size.height * 0.02,),
                      //     ],
                      //   ),
                      // ),
                      // const Divider(),
                      // TextButton(
                      //   style: TextButton.styleFrom(
                      //       foregroundColor: navIconColor,
                      //       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      //       backgroundColor: Colors.transparent
                      //   ),
                      //   onPressed: () {},
                      //   child: Row(
                      //     children: [
                      //       Container(
                      //         alignment: Alignment.center,
                      //         decoration: BoxDecoration(
                      //           borderRadius: BorderRadius.circular(8),
                      //         ),
                      //         child: SvgPicture.asset("assets/icons/service.svg", color: Colors.deepPurple.shade700.withOpacity(0.8), height: 25, width: 25),
                      //       ),
                      //       SizedBox(width: size.width * 0.05),
                      //       Expanded(child: Text('Services', style: TextStyle(fontSize: size.height * 0.019, color: valueColor, fontWeight: FontWeight.w600),)),
                      //       Icon(Icons.arrow_forward_ios, color: valueColor, size: size.height * 0.02,),
                      //     ],
                      //   ),
                      // ),
                      // const Divider(),
                      // SizedBox(
                      //   height: size.height * 0.01,
                      // ),
                      Padding(
                        padding: const EdgeInsets.only(left: 10),
                        child: Text(
                          'Account',
                          style: TextStyle(
                              fontSize: size.height * 0.02,
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
                          await Navigator.pushReplacement(context, CustomRoute(widget: const LoginScreen()));
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
                            Expanded(child: Text('Login', style: TextStyle(fontSize: size.height * 0.018, color: valueColor, fontWeight: FontWeight.w600),)),
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
                                onYesPressed: () {
                                  showDialog(
                                    context: context,
                                    barrierDismissible: false,
                                    builder: (BuildContext context) {
                                      return const CustomLoadingDialog();
                                    },
                                  );
                                  logout();
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
                              child: SvgPicture.asset("assets/icons/logout.svg", color: Colors.redAccent.shade700.withOpacity(0.8), height: 25, width: 25),
                            ),
                            SizedBox(width: size.width * 0.05),
                            Expanded(child: Text('Logout', style: TextStyle(fontSize: size.height * 0.018, color: Colors.black, fontWeight: FontWeight.w600),)),
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
                SizedBox(height: size.height * 0.4,),
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
                  fontSize: size.height * 0.015
              ),
            ),
          ],
        ),
      ),
    );
  }
}