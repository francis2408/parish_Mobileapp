import 'dart:convert';
import 'dart:io';

import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_svg/svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:loading_indicator/loading_indicator.dart';
import 'package:perambur/account/about.dart';
import 'package:perambur/private/anbiyam/anbiyam.dart';
import 'package:perambur/private/anbiyam/anbiyam_tab.dart';
import 'package:perambur/private/announcement/announcement_screen.dart';
import 'package:perambur/private/association/association.dart';
import 'package:perambur/private/celebration/celebration_tab.dart';
import 'package:perambur/private/event/event_tab.dart';
import 'package:perambur/private/family/family_detail_tab.dart';
import 'package:perambur/private/gallery/gallery_screen.dart';
import 'package:perambur/private/news/news_tab_screen.dart';
import 'package:perambur/private/notification/notification_screen.dart';
import 'package:perambur/private/obituary/obituary_screen.dart';
import 'package:perambur/private/parish/parish_tab.dart';
import 'package:perambur/private/zone/zone_tab.dart';
import 'package:perambur/public/priest_served/previous_rector.dart';
import 'package:perambur/public/mass_timing/mass_timing.dart';
import 'package:perambur/public/priest_served/priest_served.dart';
import 'package:perambur/public/rector_message/rector_message.dart';
import 'package:perambur/private/prayer/prayer_tab_screen.dart';
import 'package:perambur/public/saints/saints_tab.dart';
import 'package:perambur/private/services/services_screen.dart';
import 'package:perambur/public/prayer/send_prayer_request.dart';
import 'package:perambur/public/saints/today_saints_screen.dart';
import 'package:perambur/widget/bible/english_bible.dart';
import 'package:perambur/widget/bible/tamil_bible.dart';
import 'package:perambur/widget/common/common.dart';
import 'package:perambur/widget/common/internet_connection_checker.dart';
import 'package:perambur/widget/common/snackbar.dart';
import 'package:perambur/widget/common/web_view.dart';
import 'package:perambur/widget/helper/helper_function.dart';
import 'package:perambur/widget/navigation/navigation_bar.dart';
import 'package:perambur/widget/theme_color/theme_color.dart';
import 'package:perambur/widget/widget.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
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
  double destinationLatitude = 13.11546;
  double destinationLongitude = 80.23264;

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
  String baptismCount = '';
  String communionCount = '';
  String confirmationCount = '';
  String marriageCount = '';
  String deathCount = '';

  List imgList = [
    'assets/images/two.jpg',
    'assets/images/one.jpg',
  ];

  List newsList = [
    "Welcome to Lourdes Shrine Perambur.",
  ];


  getImageData() async {
    var pref = await SharedPreferences.getInstance();

    if(pref.containsKey('userLoggedInkey')) {
      isSignedIn = (pref.getBool('userLoggedInkey'))!;
    }

    if(pref.containsKey('setName')) {
      loginName = (pref.getString('setName'))!;
    }

    if(pref.containsKey('setDatabaseName')) {
      databaseName = (pref.getString('setDatabaseName'));
    }

    if(pref.containsKey('setPassword')) {
      loginPassword = (pref.getString('setPassword'))!;
    }

    if(pref.containsKey('userRememberKey')) {
      remember = (pref.getBool('userRememberKey'))!;
    }

    if(pref.containsKey('userAuthTokenKey')) {
      authToken = (pref.getString('userAuthTokenKey'))!;
    }

    if(pref.containsKey('userTokenExpires')) {
      tokenExpire = (pref.getString('userTokenExpires'))!;
    }

    if(pref.containsKey('userIdKey')) {
      userId = (pref.getInt('userIdKey'))!;
    }

    if(pref.containsKey('userIdsKey')) {
      userId = (pref.getString('userIdsKey'))!;
    }

    if(pref.containsKey('userNameKey')) {
      userName = (pref.getString('userNameKey'))!;
    }

    if(pref.containsKey('userRoleKey')) {
      userRole = (pref.getString('userRoleKey'))!;
    }

    if(pref.containsKey('userEmailKey')) {
      userEmail = (pref.getString('userEmailKey'))!;
    }

    if(pref.containsKey('userImageKey')) {
      userImage = (pref.getString('userImageKey'))!;
    }

    if(pref.containsKey('userDioceseKey')) {
      DioceseId = (pref.getInt('userDioceseKey'))!;
    }

    if(pref.containsKey('userDiocesesKey')) {
      DioceseId = (pref.getString('userDiocesesKey'))!;
    }

    if(pref.containsKey('userMemberIdKey')) {
      memberId = (pref.getInt('userMemberIdKey'))!;
    }

    if(pref.containsKey('userMemberIdsKey')) {
      memberId = (pref.getString('userMemberIdsKey'))!;
    }

    if (userRole == 'Parish Family') if(pref.containsKey('userBCCIdKey')) {
      bccId = (pref.getInt('userBCCIdKey'))!;
    }

    if (userRole == 'Parish Family') if(pref.containsKey('userBCCIdsKey')) {
      bccId = (pref.getString('userBCCIdsKey'))!;
    }

    if (userRole == 'Parish Family') if(pref.containsKey('userZoneIdKey')) {
      zoneId = (pref.getInt('userZoneIdKey'))!;
    }

    if (userRole == 'Parish Family') if(pref.containsKey('userZoneIdsKey')) {
      zoneId = (pref.getString('userZoneIdsKey'))!;
    }

    if(pref.containsKey('userFamilyIdKey')) {
      familyId = (pref.getInt('userFamilyIdKey'))!;
    }

    if(pref.containsKey('userFamilyIdsKey')) {
      familyId = (pref.getString('userFamilyIdsKey'))!;
    }

    expiryDateTime = DateTime.parse(tokenExpire);
    getNewsData();

    var request = http.Request('GET', Uri.parse('$baseUrl/res.parish'));
    request.body = json.encode({
      "params": {
        "filter": "[['id','=',$parishID]]",
        "access_all": "1",
        "query": "{priest_id{image_1920,member_name,mobile,role_ids},youtube,org_image_ids{id,image_1920},bcc_count,parish_family_count,parish_members_count,zone_count,parish_baptism_count,parish_fhc_count,parish_cnf_count,parish_marriage_count,parish_death_count}"
      }
    });
    request.headers.addAll(header);
    http.StreamedResponse response = await request.send();
    if (response.statusCode == 200) {
      var decode = json.decode(await response.stream.bytesToString())['result'];
      if(decode['status'] == true) {
        List data = decode['data']['result'];
        for (var priest in data) {
          memberImage = priest['priest_id']['image_1920'] != null && priest['priest_id']['image_1920'] != '' ? priest['priest_id']['image_1920'] : '';
          memberName = priest['priest_id']['member_name'] != null && priest['priest_id']['member_name'] != '' ? priest['priest_id']['member_name'] : '';
          memberRole = priest['priest_id']['member_name'] != null && priest['priest_id']['member_name'] != '' ? 'Parish Priest' : '';
          image = priest['org_image_ids'] != [] && priest['org_image_ids'].isNotEmpty ? priest['org_image_ids'] : [];
          youtube = priest['youtube'] != null && priest['youtube'] != '' ? priest['youtube'] : '';
          zoneCount = priest['zone_count'] != null && priest['zone_count'] != '' ? priest['zone_count'].toString() : '0';
          anbiyamCount = priest['bcc_count'] != null && priest['bcc_count'] != '' ? priest['bcc_count'].toString() : '0';
          familyCount = priest['parish_family_count'] != null && priest['parish_family_count'] != '' ? priest['parish_family_count'].toString() : '0';
          membersCount = priest['parish_members_count'] != null && priest['parish_members_count'] != '' ? priest['parish_members_count'].toString() : '0';
          baptismCount = priest['parish_baptism_count'] != null && priest['parish_baptism_count'] != '' ? priest['parish_baptism_count'].toString() : '0';
          communionCount = priest['parish_fhc_count'] != null && priest['parish_fhc_count'] != '' ? priest['parish_fhc_count'].toString() : '0';
          confirmationCount = priest['parish_cnf_count'] != null && priest['parish_cnf_count'] != '' ? priest['parish_cnf_count'].toString() : '0';
          marriageCount = priest['parish_marriage_count'] != null && priest['parish_marriage_count'] != '' ? priest['parish_marriage_count'].toString() : '0';
          deathCount = priest['parish_death_count'] != null && priest['parish_death_count'] != '' ? priest['parish_death_count'].toString() : '0';
        }
        setState(() {
          _isLoading = false;
        });
        // getParishData();
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
    var request = http.Request('GET', Uri.parse('$baseUrl/res.news'));
    request.body = json.encode({
      "params": {
        "filter": "[['parish_id','=',$parishID],['type','=','News'],['state','=','publish']]",
        "order": "date desc",
        "query":"{id,image_1920,name,description,date,type}"
      }
    });
    request.headers.addAll(header);
    http.StreamedResponse response = await request.send();
    if (response.statusCode == 200) {
      var decode = json.decode(await response.stream.bytesToString())['result'];
      if(decode['status'] == true) {
        List data = decode['data']['result'];
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
      for(int i = 0; i < data.length; i++) {
        if(data['parish_bcc_id']['id'] != '' && data['parish_bcc_id']['id'] != null) {
          bccId = data['parish_bcc_id']['id'].toString();
          Navigator.push(context, CustomRoute(widget: AnbiyamDetailTab(name: data['parish_bcc_id']['name'],)));
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
    getImageData();
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
                                  String refresh = await Navigator.push(context, CustomRoute(widget: const NotificationScreen()));
                                  if(refresh == 'refresh') {
                                    changeData();
                                  }
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
                        userRole == 'Parish Family' ? Container(
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
                                        fontSize: 18,
                                        color: emailText,
                                      ),
                                    ),
                                    Container(
                                      padding: EdgeInsets.only(left: size.width * 0.05),
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            userName,
                                            style: GoogleFonts.merriweather(
                                                fontWeight: FontWeight.w800,
                                                color: textHeadColor,
                                                fontSize: 16
                                            ),
                                          ),
                                          Text(
                                            userRole,
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
                                      return userImage != null && userImage != '' ? Dialog(
                                        child: Image.network(userImage, fit: BoxFit.cover,),
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
                                      image: userImage != null && userImage != '' ? NetworkImage(userImage) : const AssetImage('assets/images/profile.png') as ImageProvider,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ) : Container(
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
                                        fontSize: 18,
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
                                                fontSize: 16
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
                                      image: memberImage != null && memberImage != '' ? NetworkImage(memberImage) : const AssetImage('assets/images/profile.png') as ImageProvider,
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
                        if (userRole == 'Parish Admin') const SizedBox(height: 15,),
                        if (userRole == 'Parish Admin') Column(
                          children: [
                            SingleChildScrollView(
                              scrollDirection: Axis.horizontal,
                              child: Padding(
                                padding: const EdgeInsets.only(left: 10, right: 10),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Container(
                                      height: 60,
                                      width: 170,
                                      alignment: Alignment.center,
                                      // padding: EdgeInsets.all(5),
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(10),
                                        // color: Colors.pinkAccent,
                                        gradient: const LinearGradient(
                                          colors: [
                                            Colors.pink,
                                            Colors.pinkAccent,
                                          ],
                                          begin: Alignment.topLeft,
                                          end: Alignment.bottomRight,
                                        ),
                                      ),
                                      child: Stack(
                                        children: [
                                          Positioned(
                                            right: -18,
                                            bottom: -18,
                                            child: Container(
                                              height: 80,
                                              width: 80,
                                              decoration: BoxDecoration(
                                                shape: BoxShape.circle,
                                                color: Colors.white.withOpacity(0.2),
                                              ),
                                            ),
                                          ),
                                          Padding(
                                            padding: const EdgeInsets.all(5.0),
                                            child: Row(
                                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                              children: [
                                                Column(
                                                  crossAxisAlignment: CrossAxisAlignment.start,
                                                  children: [
                                                    Text('Zones',style: GoogleFonts.kanit(
                                                        fontWeight: FontWeight.w500,
                                                        fontSize: 18,
                                                        color: whiteColor
                                                    ),),
                                                    Text(zoneCount, style: GoogleFonts.notoSans(
                                                        fontWeight: FontWeight.w500,
                                                        fontSize: 16,
                                                        color: whiteColor
                                                    ),),
                                                  ],
                                                ),
                                                Padding(
                                                  padding: const EdgeInsets.only(left: 20),
                                                  child: IconButton(
                                                    icon: SvgPicture.asset("assets/icons/zone.svg", color: whiteColor),
                                                    // iconSize: 40,
                                                    onPressed: () {},
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    SizedBox(
                                      width: 10,
                                    ),
                                    Container(
                                      height: 60,
                                      width: 170,
                                      alignment: Alignment.center,
                                      // padding: EdgeInsets.all(5),
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(10),
                                        // color: Colors.blueAccent,
                                        gradient: const LinearGradient(
                                          colors: [
                                            Colors.indigo,
                                            Colors.indigoAccent,
                                          ],
                                          begin: Alignment.topLeft,
                                          end: Alignment.bottomRight,
                                        ),
                                      ),
                                      child: Stack(
                                        children: [
                                          Positioned(
                                            right: -18,
                                            bottom: -18,
                                            child: Container(
                                              height: 80,
                                              width: 80,
                                              decoration: BoxDecoration(
                                                shape: BoxShape.circle,
                                                color: Colors.white.withOpacity(0.2),
                                              ),
                                            ),
                                          ),
                                          Padding(
                                            padding: const EdgeInsets.all(5.0),
                                            child: Row(
                                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                              children: [
                                                Column(
                                                  crossAxisAlignment: CrossAxisAlignment.start,
                                                  children: [
                                                    Text('Anbiyams', style: GoogleFonts.kanit(
                                                        fontWeight: FontWeight.w500,
                                                        fontSize: 18,
                                                        color: whiteColor
                                                    ),),
                                                    Text(anbiyamCount, style: GoogleFonts.notoSans(
                                                        fontWeight: FontWeight.w500,
                                                        fontSize: 16,
                                                        color: whiteColor
                                                    ),),
                                                  ],
                                                ),
                                                IconButton(
                                                  icon: SvgPicture.asset("assets/icons/anbiyam.svg", color: whiteColor),
                                                  // iconSize: 40,
                                                  onPressed: () {},
                                                ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    const SizedBox(
                                      width: 10,
                                    ),
                                    Container(
                                      height: 60,
                                      width: 170,
                                      alignment: Alignment.center,
                                      // padding: EdgeInsets.all(5),
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(10),
                                        // color: Colors.deepPurple,
                                        gradient: const LinearGradient(
                                          colors: [
                                            Colors.deepPurple,
                                            Colors.deepPurpleAccent,
                                          ],
                                          begin: Alignment.topLeft,
                                          end: Alignment.bottomRight,
                                        ),
                                      ),
                                      child: Stack(
                                        children: [
                                          Positioned(
                                            right: -18,
                                            bottom: -18,
                                            child: Container(
                                              height: 80,
                                              width: 80,
                                              decoration: BoxDecoration(
                                                shape: BoxShape.circle,
                                                color: Colors.white.withOpacity(0.2),
                                              ),
                                            ),
                                          ),
                                          Padding(
                                            padding: const EdgeInsets.all(5.0),
                                            child: Row(
                                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                              children: [
                                                Column(
                                                  crossAxisAlignment: CrossAxisAlignment.start,
                                                  children: [
                                                    Text('Families',style: GoogleFonts.kanit(
                                                        fontWeight: FontWeight.w500,
                                                        fontSize: 18,
                                                        color: whiteColor
                                                    ),),
                                                    Text(familyCount,style: GoogleFonts.notoSans(
                                                        fontWeight: FontWeight.w500,
                                                        fontSize: 16,
                                                        color: whiteColor
                                                    ),),
                                                  ],
                                                ),
                                                IconButton(
                                                  icon: SvgPicture.asset("assets/icons/members.svg", color: whiteColor),
                                                  // iconSize: 40,
                                                  onPressed: () {},
                                                ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    const SizedBox(
                                      width: 10,
                                    ),
                                    Container(
                                      height: 60,
                                      width: 170,
                                      alignment: Alignment.center,
                                      // padding: EdgeInsets.all(5),
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(10),
                                        // color: Colors.orange,
                                        gradient: const LinearGradient(
                                          colors: [
                                            Colors.deepOrange,
                                            Colors.deepOrangeAccent,
                                          ],
                                          begin: Alignment.topLeft,
                                          end: Alignment.bottomRight,
                                        ),
                                      ),
                                      child: Stack(
                                        children: [
                                          Positioned(
                                            right: -18,
                                            bottom: -18,
                                            child: Container(
                                              height: 80,
                                              width: 80,
                                              decoration: BoxDecoration(
                                                shape: BoxShape.circle,
                                                color: Colors.white.withOpacity(0.2),
                                              ),
                                            ),
                                          ),
                                          Padding(
                                            padding: const EdgeInsets.all(5.0),
                                            child: Row(
                                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                              children: [
                                                Column(
                                                  crossAxisAlignment: CrossAxisAlignment.start,
                                                  children: [
                                                    Text('Members',style: GoogleFonts.kanit(
                                                        fontWeight: FontWeight.w500,
                                                        fontSize: 18,
                                                        color: whiteColor
                                                    ),),
                                                    Text(membersCount, style: GoogleFonts.notoSans(
                                                        fontWeight: FontWeight.w500,
                                                        fontSize: 16,
                                                        color: whiteColor
                                                    ),),
                                                  ],
                                                ),
                                                IconButton(
                                                  icon: SvgPicture.asset("assets/icons/commission.svg", color: whiteColor),
                                                  // iconSize: 40,
                                                  onPressed: () {},
                                                ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            const SizedBox(height: 20,),
                            SingleChildScrollView(
                              scrollDirection: Axis.horizontal,
                              child: Padding(
                                padding: const EdgeInsets.only(left: 10, right: 10),
                                child: Row(
                                  children: [
                                    Container(
                                      height: 60,
                                      width: 170,
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(10),
                                        gradient: const LinearGradient(
                                          colors: [
                                            Colors.deepPurple,
                                            Colors.deepPurpleAccent,
                                          ],
                                          begin: Alignment.topLeft,
                                          end: Alignment.bottomRight,
                                        ),
                                      ),
                                      child: Stack(
                                        children: [
                                          Positioned(
                                            right: -18,
                                            bottom: -18,
                                            child: Container(
                                              height: 80,
                                              width: 80,
                                              decoration: BoxDecoration(
                                                shape: BoxShape.circle,
                                                color: Colors.white.withOpacity(0.2),
                                              ),
                                            ),
                                          ),
                                          Padding(
                                            padding: const EdgeInsets.all(5.0),
                                            child: Row(
                                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                              children: [
                                                Column(
                                                  crossAxisAlignment: CrossAxisAlignment.start,
                                                  children: [
                                                    Text('Baptism',style: GoogleFonts.kanit(
                                                        fontWeight: FontWeight.w500,
                                                        fontSize: 18,
                                                        color: whiteColor
                                                    ),),
                                                    Text(baptismCount,style: GoogleFonts.notoSans(
                                                        fontWeight: FontWeight.w500,
                                                        fontSize: 16,
                                                        color: whiteColor
                                                    ),),
                                                  ],
                                                ),
                                                IconButton(
                                                  icon: SvgPicture.asset("assets/icons/baptisum.svg", color: whiteColor),
                                                  // iconSize: 40,
                                                  onPressed: () {},
                                                ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    const SizedBox(
                                      width: 10,
                                    ),
                                    Container(
                                      height: 60,
                                      width: 170,
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(10),
                                        gradient: const LinearGradient(
                                          colors: [
                                            Colors.orange,
                                            Colors.orangeAccent,
                                          ],
                                          begin: Alignment.topLeft,
                                          end: Alignment.bottomRight,
                                        ),
                                      ),
                                      child: Stack(
                                        children: [
                                          Positioned(
                                            right: -18,
                                            bottom: -18,
                                            child: Container(
                                              height: 80,
                                              width: 80,
                                              decoration: BoxDecoration(
                                                shape: BoxShape.circle,
                                                color: Colors.white.withOpacity(0.2),
                                              ),
                                            ),
                                          ),
                                          Padding(
                                            padding: const EdgeInsets.all(5.0),
                                            child: Row(
                                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                              children: [
                                                Column(
                                                  crossAxisAlignment: CrossAxisAlignment.start,
                                                  children: [
                                                    Text('Communion',style: GoogleFonts.kanit(
                                                        fontWeight: FontWeight.w500,
                                                        fontSize: 18,
                                                        color: whiteColor
                                                    ),),
                                                    Text(communionCount,style: GoogleFonts.notoSans(
                                                        fontWeight: FontWeight.w500,
                                                        fontSize: 16,
                                                        color: whiteColor
                                                    ),),
                                                  ],
                                                ),
                                                IconButton(
                                                  icon: SvgPicture.asset("assets/icons/mass.svg", color: whiteColor),
                                                  // iconSize: 40,
                                                  onPressed: () {},
                                                ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    const SizedBox(
                                      width: 10,
                                    ),
                                    Container(
                                      height: 60,
                                      width: 170,
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(10),
                                        gradient: const LinearGradient(
                                          colors: [
                                            Colors.pink,
                                            Colors.pinkAccent,
                                          ],
                                          begin: Alignment.topLeft,
                                          end: Alignment.bottomRight,
                                        ),
                                      ),
                                      child: Stack(
                                        children: [
                                          Positioned(
                                            right: -18,
                                            bottom: -18,
                                            child: Container(
                                              height: 80,
                                              width: 80,
                                              decoration: BoxDecoration(
                                                shape: BoxShape.circle,
                                                color: Colors.white.withOpacity(0.2),
                                              ),
                                            ),
                                          ),
                                          Padding(
                                            padding: const EdgeInsets.all(5.0),
                                            child: Row(
                                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                              children: [
                                                Column(
                                                  crossAxisAlignment: CrossAxisAlignment.start,
                                                  children: [
                                                    Text('Confirmation',style: GoogleFonts.kanit(
                                                        fontWeight: FontWeight.w500,
                                                        fontSize: 18,
                                                        color: whiteColor
                                                    ),),
                                                    Text(confirmationCount,style: GoogleFonts.notoSans(
                                                        fontWeight: FontWeight.w500,
                                                        fontSize: 16,
                                                        color: whiteColor
                                                    ),),
                                                  ],
                                                ),
                                                IconButton(
                                                  icon: SvgPicture.asset("assets/icons/hand.svg", color: whiteColor),
                                                  // iconSize: 40,
                                                  onPressed: () {},
                                                ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    const SizedBox(
                                      width: 10,
                                    ),
                                    Container(
                                      height: 60,
                                      width: 170,
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(10),
                                        gradient: const LinearGradient(
                                          colors: [
                                            Colors.blue,
                                            Colors.blueAccent,
                                          ],
                                          begin: Alignment.topLeft,
                                          end: Alignment.bottomRight,
                                        ),
                                      ),
                                      child: Stack(
                                        children: [
                                          Positioned(
                                            right: -18,
                                            bottom: -18,
                                            child: Container(
                                              height: 80,
                                              width: 80,
                                              decoration: BoxDecoration(
                                                shape: BoxShape.circle,
                                                color: Colors.white.withOpacity(0.2),
                                              ),
                                            ),
                                          ),
                                          Padding(
                                            padding: const EdgeInsets.all(5.0),
                                            child: Row(
                                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                              children: [
                                                Column(
                                                  crossAxisAlignment: CrossAxisAlignment.start,
                                                  children: [
                                                    Text('Marriage',style: GoogleFonts.kanit(
                                                        fontWeight: FontWeight.w500,
                                                        fontSize: 18,
                                                        color: whiteColor
                                                    ),),
                                                    Text(marriageCount,style: GoogleFonts.notoSans(
                                                        fontWeight: FontWeight.w500,
                                                        fontSize: 16,
                                                        color: whiteColor
                                                    ),),
                                                  ],
                                                ),
                                                IconButton(
                                                  icon: SvgPicture.asset("assets/icons/marriage.svg", color: whiteColor),
                                                  // iconSize: 40,
                                                  onPressed: () {},
                                                ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    const SizedBox(
                                      width: 10,
                                    ),
                                    Container(
                                      height: 60,
                                      width: 170,
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(10),
                                        gradient: const LinearGradient(
                                          colors: [
                                            Colors.teal,
                                            Colors.teal,
                                          ],
                                          begin: Alignment.topLeft,
                                          end: Alignment.bottomRight,
                                        ),
                                      ),
                                      child: Stack(
                                        children: [
                                          Positioned(
                                            right: -18,
                                            bottom: -18,
                                            child: Container(
                                              height: 80,
                                              width: 80,
                                              decoration: BoxDecoration(
                                                shape: BoxShape.circle,
                                                color: Colors.white.withOpacity(0.2),
                                              ),
                                            ),
                                          ),
                                          Padding(
                                            padding: const EdgeInsets.all(5.0),
                                            child: Row(
                                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                              children: [
                                                Column(
                                                  crossAxisAlignment: CrossAxisAlignment.start,
                                                  children: [
                                                    Text('Death',style: GoogleFonts.kanit(
                                                        fontWeight: FontWeight.w500,
                                                        fontSize: 18,
                                                        color: whiteColor
                                                    ),),
                                                    Text(deathCount,style: GoogleFonts.notoSans(
                                                        fontWeight: FontWeight.w500,
                                                        fontSize: 16,
                                                        color: whiteColor
                                                    ),),
                                                  ],
                                                ),
                                                IconButton(
                                                  icon: SvgPicture.asset("assets/icons/rip.svg", color: whiteColor),
                                                  // iconSize: 40,
                                                  onPressed: () {},
                                                ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
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
                                    String refresh = await Navigator.push(context, CustomRoute(widget: const ParishTabScreen()));
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
                                if(userRole == 'Parish Family') HomeCard(
                                  onPressed: () async {
                                    String refresh = await Navigator.push(context, CustomRoute(widget: const FamilyDetailsTabScreen(title: '')));
                                    if(refresh == 'refresh') {
                                      changeData();
                                    }
                                  },
                                  icon: "assets/icons/members.svg",
                                  title: "My Family",
                                  homeIconSize: 40,
                                  bcolor: Colors.pink.shade700.withOpacity(0.8),
                                  icolor: menuIconColor,
                                ),
                                HomeCard(
                                  onPressed: () async {
                                    String refresh = await Navigator.push(context, CustomRoute(widget: const ZoneTabScreen()));
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
                                userRole == 'Parish Family' ? HomeCard(
                                  onPressed: () async {
                                    String refresh = await Navigator.push(context, CustomRoute(widget: const AnbiyamDetailTab(name: 'My Anbiyam',)));
                                    if(refresh == 'refresh') {
                                      changeData();
                                    }
                                  },
                                  icon: "assets/icons/anbiyam.svg",
                                  title: "My Anbiyam",
                                  homeIconSize: 40,
                                  bcolor: Colors.teal.shade700.withOpacity(0.8),
                                  icolor: menuIconColor,
                                ) : HomeCard(
                                  onPressed: () async {
                                    String refresh = await Navigator.push(context, CustomRoute(widget: const AnbiyamScreen()));
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
                                    String refresh = await Navigator.push(context, CustomRoute(widget: const AssociationScreen()));
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
                                    String refresh = await Navigator.push(context, CustomRoute(widget: const EventTabScreen()));
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
                                    String refresh = await Navigator.push(context, CustomRoute(widget: const NewsTabScreen()));
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
                                  onPressed: () async {
                                    String refresh = await Navigator.push(context, CustomRoute(widget: const PrayerTabScreen()));
                                    if(refresh == 'refresh') {
                                      changeData();
                                    }
                                  },
                                  icon: "assets/icons/rosary.svg",
                                  title: "Prayer",
                                  homeIconSize: 40,
                                  bcolor: Colors.lightGreen.shade700.withOpacity(0.8),
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
                                    String refresh = await Navigator.push(context, CustomRoute(widget: const GalleryScreen()));
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
                                    String refresh = await Navigator.push(context, CustomRoute(widget: const ServicesScreen()));
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
                                    String refresh = await Navigator.push(context, CustomRoute(widget: const CelebrationTabScreen()));
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
                                    String refresh = await Navigator.push(context, CustomRoute(widget: const AnnouncementScreen()));
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
                                    String refresh = await Navigator.push(context, CustomRoute(widget: const ObituaryScreen()));
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
                  accountName: Text(userRole == 'Parish Family' ? userName : memberName, style: TextStyle(fontSize: size.height * 0.02, fontWeight: FontWeight.bold),),
                  accountEmail: Text(userRole == 'Parish Family' ? userRole : memberRole, style: TextStyle(fontSize: size.height * 0.018, fontWeight: FontWeight.bold),),
                  currentAccountPicture: CircleAvatar(
                    child: userRole == 'Parish Family' ? GestureDetector(
                      onTap: () {
                        userImage != '' ? showDialog(
                          context: context,
                          builder: (BuildContext context) {
                            return Dialog(
                              child: Image.network(userImage, fit: BoxFit.cover,),
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
                        child: userImage.isNotEmpty ? Image.network(
                            userImage,
                            height: size.height * 0.1,
                            width: size.width * 0.2,
                            fit: BoxFit.cover
                        ) : Image.asset(
                          'assets/images/profile.png',
                          height: size.height * 0.1,
                          width: size.width * 0.2,
                        ),
                      ),
                    ) : GestureDetector(
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
                          String refresh = await Navigator.push(context, CustomRoute(widget: const PublicTodaySaintsScreen()));
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
                        onPressed: () {},
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
                                    await Navigator.pushReplacement(context, CustomRoute(widget: const NavigationBarScreen()));
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

Widget _buildBackground() {
  // Replace this with your GridView or Image
  return GridView.count(
    crossAxisCount: 1,
    children: List.generate(
        3, (index) => Container(
      // padding: const EdgeInsets.all(10),
      decoration: const BoxDecoration(
        image: DecorationImage(
          image: AssetImage("assets/images/texture.jpg"),
          opacity: 0.3,
          fit: BoxFit.cover,
        ),
      ),
    )),
  );
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
