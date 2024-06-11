import 'dart:async';

import 'package:avosa/authentication/login.dart';
import 'package:avosa/widget/theme_color/theme_color.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    Timer(const Duration(seconds: 3), () => Navigator.pushReplacement(context,
        MaterialPageRoute(builder: (context) => const LoginScreen())));
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Scaffold(
      body: Stack(
        children: [
          Positioned(
            top: 0,
            right: 0,
            left: 0,
            child: Container(
              width: size.width,
              height: size.height,
              decoration: const BoxDecoration(
                image: DecorationImage(
                  image: AssetImage("assets/images/one.jpeg"),
                  fit: BoxFit.fill,
                ),
              ),
              child: Container(
                color: primaryColor.withOpacity(0.9),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    Column(
                      children: [
                        Container(
                          height: 100,
                          width: 100,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10.0),
                            image: const DecorationImage(
                              image: AssetImage("assets/images/logo.jpeg"),
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                      ],
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        const CircularProgressIndicator(
                          valueColor:  AlwaysStoppedAnimation<Color>(secondaryColor),
                        ),
                        SizedBox(height: size.height * 0.02,),
                        Text(
                          'Please wait...',
                          style: TextStyle(
                            fontSize: size.height * 0.02,
                            color: secondaryColor,
                            fontWeight: FontWeight.w500,
                          ),
                        )
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
          Positioned(
            top: MediaQuery.of(context).size.height - 50,
            right: 0,
            left: 0,
            child: Column(
              children: [
                Text(
                  "Copyright © ${DateTime.now().year}. St. Mary's Catholic Church - Al Ain. ",
                  style: GoogleFonts.roboto(
                    fontSize: size.height * 0.016,
                    color: whiteColor,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(
                  height: 5,
                ),
                Text(
                  'All rights reserved',
                  style: GoogleFonts.roboto(
                    fontSize: size.height * 0.016,
                    color: whiteColor,
                    fontWeight: FontWeight.bold,
                  ),
                )
              ],
            ),
          ),
        ],
      ),
    );
  }
}
