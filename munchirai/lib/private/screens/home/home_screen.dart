import 'dart:convert';
import 'dart:io';

import 'package:carousel_slider/carousel_slider.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_svg/svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:loading_indicator/loading_indicator.dart';
import 'package:munchirai/private/screens/about/about_screen.dart';
import 'package:munchirai/private/screens/announcement/announcement_screen.dart';
import 'package:munchirai/private/screens/association/association.dart';
import 'package:munchirai/private/screens/authentication/family_login.dart';
import 'package:munchirai/private/screens/bcc/bcc_tabs.dart';
import 'package:munchirai/private/screens/bible/english_bible.dart';
import 'package:munchirai/private/screens/bible/tamil_bible.dart';
import 'package:munchirai/private/screens/dashboard/dashboard.dart';
import 'package:munchirai/private/screens/event/event_tab.dart';
import 'package:munchirai/private/screens/family/family_detail_tab.dart';
import 'package:munchirai/private/screens/feedback/add_feedback_form.dart';
import 'package:munchirai/private/screens/gallery/gallery_screen.dart';
import 'package:munchirai/private/screens/mass_timing/mass_timing.dart';
import 'package:munchirai/private/screens/news/news_tab_screen.dart';
import 'package:munchirai/private/screens/notification/notification_screen.dart';
import 'package:munchirai/private/screens/obituary/obituary_screen.dart';
import 'package:munchirai/private/screens/office/office_members.dart';
import 'package:munchirai/private/screens/parish/parish_tab.dart';
import 'package:munchirai/private/screens/prayer/send_prayer_request.dart';
import 'package:munchirai/private/screens/saints/saints_tab.dart';
import 'package:munchirai/private/screens/services/services_screen.dart';
import 'package:munchirai/private/screens/social_media/social_media_screen.dart';
import 'package:munchirai/widget/common/common.dart';
import 'package:munchirai/widget/common/internet_connection_checker.dart';
import 'package:munchirai/widget/common/snackbar.dart';
import 'package:munchirai/widget/helper/helper_function.dart';
import 'package:munchirai/widget/theme_color/theme_color.dart';
import 'package:munchirai/widget/widget.dart';
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
  String otherImage = 'assets/images/image_two.jpg';
  String memberEmail = '';

  List imgList = [
    'assets/church/one.jpg',
    'assets/church/two.jpg',
    'assets/church/three.jpg',
  ];

  List newsList = [
    "Welcome to The Munchirai Punitha Arockia Matha Church.",
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
        setState(() {
          _isLoading = false;
        });
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
          memberImage = priest['priest_id']['image_1920'] != null && priest['priest_id']['image_1920'] != '' ? priest['priest_id']['image_1920'] : 'assets/images/profile.png';
          memberName = priest['priest_id']['member_name'] != null && priest['priest_id']['member_name'] != '' ? priest['priest_id']['member_name'] : '';
          memberRole = priest['priest_id']['member_name'] != null && priest['priest_id']['member_name'] != '' ? 'Parish Priest' : '';
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

  getFamilyData() async {
    var request = http.Request('GET', Uri.parse('$baseUrl/res.family/$familyId'));
    request.body = json.encode({
      "params": {
        "query": "{id,name,parish_bcc_id}",
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
      for(int i = 0; i < data.length; i++) {
        if(data['parish_bcc_id']['id'] != '' && data['parish_bcc_id']['id'] != null) {
          bccId = data['parish_bcc_id']['id'].toString();
          Navigator.push(context, CustomRoute(widget: BCCTabsScreen(title: data['parish_bcc_id']['name'],)));
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

  determinePosition() async {
    Navigator.pop(context);

    bool serviceEnabled;
    LocationPermission permission;
    Position currentPosition;

    // Test if location services are enabled.
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      // Location services are not enabled, don't continue accessing the position and request users of the App to enable the location services.
      MediaSnackBar.show(
          context,
          'assets/png/route.png',
          'Please enable the location service',
          blackColor.withOpacity(0.8)
      );
    }

    // Check if permission is granted, and request if not.
    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        // Permissions are denied, handle this case appropriately.
        throw Exception('Location permissions are denied');
      }
    }

    // If permission is permanently denied, handle this case.
    if (permission == LocationPermission.deniedForever) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text("Location Permissions"),
          content: Text("Location permissions are permanently denied. Would you like to go to app settings to enable them?"),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: Text("Ok"),
            ),
          ],
        ),
      );
      // Throw an exception to indicate that permissions are permanently denied.
      throw Exception('Location permissions are permanently denied');
    }

    setState(() {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return const CustomLoadingDialog();
        },
      );
    });

    // When we reach here, permissions are granted, and we can continue accessing the position of the device.
    currentPosition = await Geolocator.getCurrentPosition();

    // Here you can launch the map with the obtained coordinates.
    launchMapsUrl(currentPosition.latitude, currentPosition.longitude, destinationLatitude, destinationLongitude);
    Navigator.pop(context);
  }

  static void launchMapsUrl(
      sourceLatitude,
      sourceLongitude,
      destinationLatitude,
      destinationLongitude) async {
    String mapOptions = [
      'saddr=$sourceLatitude,$sourceLongitude',
      'daddr=$destinationLatitude,$destinationLongitude',
      'travelmode=driving',
      'dir_action=navigate',
      't=h'
    ].join('&');
    final url = 'https://www.google.com/maps?$mapOptions';
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

  Future<void> webAction(String web) async {
    try {
      await launch(
        web,
        forceWebView: false,
        enableJavaScript: true,
      );
    } catch (e) {
      throw 'Could not launch $web: $e';
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
      getImageData();
      getNewsData();
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
    // Request for permission to show notifications (required for iOS)
    _firebaseMessaging.requestPermission();
    // Subscribe to a topic (optional)
    _firebaseMessaging.subscribeToTopic(db);
    getData();
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const NotificationScreen()),
      );
    });
  }

  @override
  void dispose() {
    // TODO: implement dispose
    clearImageCache();
    super.dispose();
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
          appBar: AppBar(
            backgroundColor: appBackgroundColor,
            title: RichText(
              textAlign: TextAlign.center,
              text: TextSpan(
                text: "Church of Our Lady of Good Health",
                style: TextStyle(
                    fontSize: size.height * 0.02,
                    fontWeight: FontWeight.bold,
                    color: whiteColor,
                    letterSpacing: 0.5,
                    height: 1.3
                ),
                children: const [
                  TextSpan(
                    text: " - ",
                  ),
                  TextSpan(
                    text: "Munchirai",
                  ),
                ]
              ),
            ),
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
            // toolbarHeight: 80,
            // title: Text("Church of Our Lady of Good Health", style: TextStyle(fontSize: size.height * 0.02, fontWeight: FontWeight.bold, color: whiteColor, letterSpacing: 0.5, height: 1.3), textAlign: TextAlign.center, maxLines: 2,),
            leading: IconButton(
              icon: SvgPicture.asset("assets/icons/menu.svg", color: Colors.white, height: 20,),
              onPressed: () {
                _scaffoldKey.currentState?.openDrawer();
              },
            ),
            actions: [
              IconButton(
                icon: SvgPicture.asset("assets/icons/notification.svg", color: Colors.white, height: 25,),
                onPressed: () async {
                  String refresh = await Navigator.push(context, CustomRoute(widget: const NotificationScreen()));

                  if(refresh == 'refresh') {
                    changeData();
                  }
                },
              )
            ],
            // bottom: PreferredSize(
            //   preferredSize: Size.fromHeight(size.height * 0.02), // Set the preferred height
            //   child: Padding(
            //     padding: const EdgeInsets.all(8.0),
            //     child: Column(
            //       mainAxisAlignment: MainAxisAlignment.center,
            //       children: [
            //         Text("Munchirai", style: TextStyle(fontSize: size.height * 0.02, fontWeight: FontWeight.bold, color: whiteColor), textAlign: TextAlign.center,),
            //       ],
            //     ),
            //   ),
            // ),
          ),
          body: SafeArea(
            child: Center(
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
                  children: [
                    SizedBox(
                      height: size.height * 0.01,
                    ),
                    Column(
                      children: [
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
                        SizedBox(
                          height: size.height * 0.01,
                        ),
                        Container(
                            alignment: Alignment.center,
                            child: buildIndicator()
                        ),
                      ],
                    ),
                    SizedBox(
                      height: size.height * 0.01,
                    ),
                    _isNews ? Container(
                      alignment: Alignment.center,
                      child: SizedBox(
                        height: size.height * 0.06,
                        child: const LoadingIndicator(
                          indicatorType: Indicator.ballPulse,
                          colors: [first,second,first,],
                        ),
                      ),
                    ) : Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        SizedBox(
                            height: size.height * 0.06,
                            width: size.width * 0.15,
                            child: Container(
                              alignment: Alignment.center,
                              decoration: const BoxDecoration(
                                color: Colors.redAccent,
                              ),
                              child: Text('News',style: GoogleFonts.kanit(fontSize: size.height * 0.018, color: Colors.white),),
                            )
                        ),
                        newsData.isNotEmpty ? Flexible(
                          child: Container(
                              padding: const EdgeInsets.only(left: 10),
                              width: double.infinity,
                              decoration: const BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [
                                    Color(0xFFE3F1FF),
                                    Color(0xFFE3F1FF),
                                  ],
                                  begin: Alignment.bottomLeft,
                                  end: Alignment.topRight,
                                ),
                              ),
                              child: CarouselSlider.builder(
                                carouselController: controller,
                                itemCount: newsData.length,
                                itemBuilder: (context, index, realIndex) {
                                  final news = newsData[index]['name'];
                                  return GestureDetector(
                                    onTap: () async {},
                                    child: Container(
                                      padding: const EdgeInsets.only(left: 5),
                                      alignment: Alignment.center,
                                      child: Text(
                                        news,
                                        textAlign: TextAlign.left,
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                        style: GoogleFonts.maitree(
                                          textStyle: const TextStyle(color: Color(0xFF0861B6)),
                                          fontSize: size.height * 0.017,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
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
                              )
                          ),
                        ) : Flexible(
                          child: Container(
                              padding: const EdgeInsets.only(left: 10),
                              width: double.infinity,
                              decoration: const BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [
                                    whiteColor,
                                    whiteColor,
                                  ],
                                  begin: Alignment.bottomLeft,
                                  end: Alignment.topRight,
                                ),
                              ),
                              child: CarouselSlider.builder(
                                carouselController: controller,
                                itemCount: newsList.length,
                                itemBuilder: (context, index, realIndex) {
                                  final news = newsList[index];
                                  return Container(
                                    padding: const EdgeInsets.only(left: 5),
                                    alignment: Alignment.center,
                                    child: Text(
                                      news,
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                      textAlign: TextAlign.left,
                                      style: GoogleFonts.roboto(
                                        textStyle: const TextStyle(color: Color(0xFF0861B6)),
                                        fontSize: size.height * 0.017,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
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
                              )
                          ),
                        ),
                      ],
                    ),
                    SizedBox(
                      height: size.height * 0.02,
                    ),
                    Container(
                      padding: const EdgeInsets.all(5.0),
                      child: Center(
                        child: Wrap(
                          spacing: 20,
                          runSpacing: 20,
                          children: [
                            HomeCard(
                              onPressed: () async {
                                String refresh = await Navigator.push(context, CustomRoute(widget: const ParishTabScreen()));

                                if(refresh == 'refresh') {
                                  changeData();
                                }
                              },
                              icon: "assets/icons/church.svg",
                              title: "Parish",
                              homeIconSize: 35,
                            ),
                            HomeCard(
                              onPressed: () async {
                                String refresh = await Navigator.push(context, CustomRoute(widget: const OfficeMembersScreen()));

                                if(refresh == 'refresh') {
                                  changeData();
                                }
                              },
                              icon: "assets/icons/office.svg",
                              title: "Office",
                              homeIconSize: 40,
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
                            ),
                            HomeCard(
                              onPressed: () async {
                                String refresh = await Navigator.push(context, CustomRoute(widget: const AssociationScreen()));

                                if(refresh == 'refresh') {
                                  changeData();
                                }
                              },
                              icon: "assets/icons/commission.svg",
                              title: "Associations",
                              homeIconSize: 40,
                            ),
                            isSignedIn == true && userRole == 'Parish Admin' ? HomeCard(
                              onPressed: () async {
                                String refresh = await Navigator.push(context, CustomRoute(widget: isSignedIn == true && userRole == 'Parish Admin' ? const DashboardScreen() : const FamilyLoginScreen()));
                                if(refresh == 'refresh') {
                                  changeData();
                                }
                              },
                              icon: "assets/icons/members.svg",
                              title: "My Parish",
                              homeIconSize: 40,
                            ) : HomeCard(
                              onPressed: () async {
                                String refresh = await Navigator.push(context, CustomRoute(widget: isSignedIn == true && userRole == 'Parish Family' ? const FamilyDetailsTabScreen(title: '',) : const FamilyLoginScreen()));
                                if(refresh == 'refresh') {
                                  changeData();
                                }
                              },
                              icon: "assets/icons/members.svg",
                              title: "My Family",
                              homeIconSize: 40,
                            ),
                            if(isSignedIn == true && userRole == 'Parish Family') HomeCard(
                              onPressed: () {
                                getFamilyData();
                              },
                              icon: "assets/icons/hand.svg",
                              title: "My Anbiyam",
                              homeIconSize: 50,
                            ),
                            HomeCard(
                              onPressed: () async {
                                String refresh = await Navigator.push(context, CustomRoute(widget: const ServicesScreen()));

                                if(refresh == 'refresh') {
                                  changeData();
                                }
                              },
                              icon: "assets/icons/service.svg",
                              title: "Services",
                              homeIconSize: 40,
                            ),
                            HomeCard(
                              onPressed: () async {
                                String refresh = await Navigator.push(context, CustomRoute(widget: const SaintsTabScreen()));

                                if(refresh == 'refresh') {
                                  changeData();
                                }
                              },
                              icon: "assets/icons/saint.svg",
                              title: "Saints",
                              homeIconSize: 40,
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
                            ),
                            HomeCard(
                              onPressed: () async {
                                String refresh = await Navigator.push(context, CustomRoute(widget: const EventTabScreen()));

                                if(refresh == 'refresh') {
                                  changeData();
                                }
                              },
                              icon: "assets/icons/calendar.svg",
                              title: "Event",
                              homeIconSize: 40,
                            ),
                            HomeCard(
                              onPressed: () async {
                                String refresh = await Navigator.push(context, CustomRoute(widget: const AnnouncementScreen()));

                                if(refresh == 'refresh') {
                                  changeData();
                                }
                              },
                              icon: "assets/icons/speaker.svg",
                              title: "Announcement",
                              homeIconSize: 40,
                            ),
                            HomeCard(
                              onPressed: () async {
                                String refresh = await Navigator.push(context, CustomRoute(widget: const NewsTabScreen()));

                                if(refresh == 'refresh') {
                                  changeData();
                                }
                              },
                              icon: "assets/icons/news_paper.svg",
                              title: "News",
                              homeIconSize: 40,
                            ),
                            HomeCard(
                              onPressed: () async {
                                String refresh = await Navigator.push(context, CustomRoute(widget: const ObituaryScreen()));

                                if(refresh == 'refresh') {
                                  changeData();
                                }
                              },
                              icon: "assets/icons/rip.svg",
                              title: "Obituary",
                              homeIconSize: 40,
                            ),
                            HomeCard(
                              onPressed: () async {
                                String refresh = await Navigator.push(context, CustomRoute(widget: const NotificationScreen()));

                                if(refresh == 'refresh') {
                                  changeData();
                                }
                              },
                              icon: "assets/icons/notification.svg",
                              title: "Notifications",
                              homeIconSize: 40,
                            ),
                            HomeCard(
                              onPressed: () async {
                                String refresh = await Navigator.push(context, CustomRoute(widget: const SocialMediaScreen()));

                                if(refresh == 'refresh') {
                                  changeData();
                                }
                              },
                              icon: "assets/icons/media.svg",
                              title: "Social Media",
                              homeIconSize: 40,
                            ),
                            HomeCard(
                              onPressed: () async {
                                String refresh = await Navigator.push(context, CustomRoute(widget: const GalleryScreen()));

                                if(refresh == 'refresh') {
                                  changeData();
                                }
                              },
                              icon: "assets/icons/gallery.svg",
                              title: "Gallery",
                              homeIconSize: 40,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          drawer: Drawer(
            backgroundColor: Colors.white,
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
                  otherAccountsPictures: [
                    GestureDetector(
                      onTap: () {
                        otherImage != '' ? showDialog(
                          context: context,
                          builder: (BuildContext context) {
                            return Dialog(
                              child: Stack(
                                children: [
                                  Image.asset(otherImage, fit: BoxFit.cover,),
                                  Positioned(left: 5, child: Text('Most Rev. Antony Pappusamy', style: TextStyle(fontSize: size.height * 0.02, fontWeight: FontWeight.bold),)),
                                  Positioned(top: 20, left: 5, child: Text('Administrator', style: TextStyle(fontSize: size.height * 0.018, fontWeight: FontWeight.bold, color: whiteColor),)),
                                ],
                              ),
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
                        child: otherImage.isNotEmpty ? Image.asset(
                            otherImage,
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
                  ],
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
                          String refresh = await Navigator.push(context, CustomRoute(widget: const AssociationScreen()));

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
                                child: SvgPicture.asset("assets/icons/commission.svg", color: menuPrimaryColor, height: 30, width: 30),
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
                          String refresh = await Navigator.push(context, CustomRoute(widget: const AnnouncementScreen()));

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
                                child: SvgPicture.asset("assets/icons/speaker.svg", color: menuPrimaryColor, height: 30, width: 30),
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
                          String refresh = await Navigator.push(context, CustomRoute(widget: const SendPrayerRequest()));

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
                                child: SvgPicture.asset("assets/icons/rosary.svg", color: menuPrimaryColor, height: 30, width: 30),
                            ),
                            SizedBox(width: size.width * 0.05),
                            Expanded(child: Text('Prayer Request', style: TextStyle(fontSize: size.height * 0.019, color: valueColor, fontWeight: FontWeight.w600),)),
                            Icon(Icons.arrow_forward_ios, color: valueColor, size: size.height * 0.02,),
                          ],
                        ),
                      ),
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
                      //           alignment: Alignment.center,
                      //           decoration: BoxDecoration(
                      //             borderRadius: BorderRadius.circular(8),
                      //           ),
                      //           child: Image.asset("assets/png/construction.png", height: 30, width: 30,)
                      //       ),
                      //       SizedBox(width: size.width * 0.05),
                      //       Expanded(child: Text('Construction', style: TextStyle(fontSize: size.height * 0.019, color: valueColor, fontWeight: FontWeight.w600),)),
                      //       Icon(Icons.arrow_forward_ios, color: valueColor, size: size.height * 0.02,),
                      //     ],
                      //   ),
                      // ),
                      const Divider(),
                      TextButton(
                        style: TextButton.styleFrom(
                            foregroundColor: navIconColor,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                            backgroundColor: Colors.transparent
                        ),
                        onPressed: () async {
                          Navigator.pop(context);
                          String refresh = await Navigator.push(context, CustomRoute(widget: const SaintsTabScreen()));

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
                                child: SvgPicture.asset("assets/icons/saint.svg", color: menuPrimaryColor, height: 30, width: 30),
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
                                child: SvgPicture.asset("assets/icons/bible.svg", color: menuPrimaryColor, height: 30, width: 30),
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
                          String refresh = await Navigator.push(context, CustomRoute(widget: const NotificationScreen()));

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
                                child: SvgPicture.asset("assets/icons/notification.svg", color: menuPrimaryColor, height: 30, width: 30),
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
                          determinePosition();
                        },
                        child: Row(
                          children: [
                            Container(
                                alignment: Alignment.center,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: SvgPicture.asset("assets/icons/route.svg", color: menuPrimaryColor, height: 30, width: 30),
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
                                child: SvgPicture.asset("assets/icons/info.svg", color: menuPrimaryColor, height: 30, width: 30),
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
                          String refresh = await Navigator.push(context, CustomRoute(widget: const AddFeedbackForm()));

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
                                child: SvgPicture.asset("assets/icons/feedback.svg", color: menuPrimaryColor, height: 30, width: 30),
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
                          String refresh = await Navigator.push(context, CustomRoute(widget: const ServicesScreen()));

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
                                child: SvgPicture.asset("assets/icons/service.svg", color: menuPrimaryColor, height: 26, width: 26),
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
                              color: hiLightColor
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
                          String refresh;
                          isSignedIn ? refresh = await Navigator.push(context, CustomRoute(widget: const ServicesScreen())) : refresh = await Navigator.push(context, CustomRoute(widget: const FamilyLoginScreen()));

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
                                child: SvgPicture.asset("assets/icons/key.svg", color: greenColor, height: 30, width: 30),
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
                                onYesPressed: () async {
                                  if(load) {
                                    showDialog(
                                      context: context,
                                      barrierDismissible: false,
                                      builder: (BuildContext context) {
                                        return const CustomLoadingDialog();
                                      },
                                    );
                                    SharedPreferences prefs = await SharedPreferences.getInstance();
                                    await prefs.remove('userLoggedInkey');
                                    await prefs.remove('userAuthTokenKey');
                                    await prefs.remove('userIdKey');
                                    await prefs.remove('userIdsKey');
                                    await prefs.remove('userNameKey');
                                    await prefs.remove('userRoleKey');
                                    await prefs.remove('userEmailKey');
                                    await prefs.remove('userImageKey');
                                    await prefs.remove('userDioceseKey');
                                    await prefs.remove('userParishKey');
                                    await prefs.remove('userMemberKey');
                                    await HelperFunctions.setUserLoginSF(false);
                                    await Future.delayed(const Duration(seconds: 1));
                                    setState(() {
                                      load = false; // Set loading flag to false
                                    });
                                    await Navigator.pushReplacement(context, CustomRoute(widget: const HomeScreen()));
                                    _flush();
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
                                child: SvgPicture.asset("assets/icons/logout.svg", color: redColor, height: 30, width: 30),
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
                                child: SvgPicture.asset("assets/icons/exit.svg", color: redColor, height: 30, width: 30),
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
      activeDotColor: iconBackColor,
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
                color: menuPrimaryColor,
                shape: BoxShape.rectangle,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Center(
                  child: IconButton(
                    icon: SvgPicture.asset(icon, color: whiteColor),
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
                  fontSize: size.height * 0.0155
              ),
            ),
          ],
        ),
      ),
    );
  }
}
