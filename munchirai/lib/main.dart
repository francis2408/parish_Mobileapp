import 'dart:io';

import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_in_store_app_version_checker/flutter_in_store_app_version_checker.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:in_app_update/in_app_update.dart';
import 'package:munchirai/private/screens/home/home_screen.dart';
import 'package:munchirai/widget/common/awesome_notification.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'firebase_options.dart';
import 'private/screens/splash/splash_screen.dart';
import 'widget/common/common.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  bool isSignedIn = false;
  bool remem = false;
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  await AwesomeNotifications().initialize(null, [
    NotificationChannel(
      channelKey: 'your_channel_key',
      channelName: 'Your Channel Name',
      channelDescription: 'Your Channel Description',
    ),
  ]);

  FirebaseMessaging.onMessage.listen((RemoteMessage message) {
    if(message.data['topic'] == db) {
      final notification = message.notification;
      if (notification != null) {
        MyNotificationService.showNotification(
          title: notification.title ?? 'New Notification',
          body: notification.body ?? 'Notification Body',
          payload: message.data['data'] ?? '',
        );
      }
    }
  });

  if (Platform.isIOS) {
    String? apnsToken = await FirebaseMessaging.instance.getAPNSToken();
    if (apnsToken != null) {
      await FirebaseMessaging.instance.subscribeToTopic(db);
    } else {
      await Future<void>.delayed(
        const Duration(
          seconds: 1,
        ),
      );
      apnsToken = await FirebaseMessaging.instance.getAPNSToken();
      if (apnsToken != null) {
        await FirebaseMessaging.instance.subscribeToTopic(db);
      }
    }
  } else {
    await FirebaseMessaging.instance.subscribeToTopic(db);
  }

  SharedPreferences prefs = await SharedPreferences.getInstance();
  isSignedIn = prefs.getBool('userLoggedInkey') ?? false;
  String name = prefs.getString('setName') ?? '';
  String pass = prefs.getString('setPassword') ?? '';
  String base = prefs.getString('setDatabaseName') ?? '';
  String mobile = prefs.getString('setMobileNumber') ?? '';
  remem = prefs.getBool('userRememberKey') ?? false;

  if(name != '' && name != null && pass != '' && pass != null && mobile != '' && mobile != null && remem != false) {
    loginName = name;
    loginPassword = pass;
    databaseName = base;
    mobileNumber = mobile;
    remember = remem;
  }

  runApp(MyApp(isSignedIn));
}

class MyApp extends StatefulWidget {
  final bool isSignedIn;
  const MyApp(this.isSignedIn, {Key? key}) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey();
  final _checker = InStoreAppVersionChecker();

  Future<void> checkVersion() async {
    final value = await _checker.checkUpdate();
    setState(() {
      updateAvailable = value.canUpdate;
      curentVersion = value.currentVersion;
      latestVersion = value.newVersion;
    });
    checkUpdate();
  }

  Future<void> checkUpdate() async {
    if (updateAvailable) {
      checkForUpdate();
    } else {
      setState(() {
        isSignedIn = widget.isSignedIn;
      });
    }
  }

  // Platform messages are asynchronous, so we initialize in an async method.
  Future<void> checkForUpdate() async {
    InAppUpdate.checkForUpdate().then((updateInfo) {
      if(updateInfo.updateAvailability == UpdateAvailability.updateAvailable) {
        if(updateInfo.immediateUpdateAllowed) {
          InAppUpdate.performImmediateUpdate().then((appUpdateResult) {
            if(appUpdateResult == AppUpdateResult.success) {
              setState(() {
                isSignedIn = false;
              });
            } else {
              setState(() {
                isSignedIn = widget.isSignedIn;
              });
            }
          });
        }
      }
    });
  }

  @override
  void initState() {
    super.initState();
    checkVersion();
  }

  @override
  Widget build(BuildContext context) {
    isSignedIn = widget.isSignedIn;
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        textTheme: GoogleFonts.robotoSlabTextTheme(
          Theme.of(context).textTheme,
        ),
      ),
      home: ScaffoldMessenger(
        key: _scaffoldKey,
        child: isSignedIn ? const HomeScreen() : const SplashScreen(),
      ),
    );
  }
}

