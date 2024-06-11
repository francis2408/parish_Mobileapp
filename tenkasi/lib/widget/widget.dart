import 'dart:async';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:loading_indicator/loading_indicator.dart';
import 'package:tenkasi/private/screens/home/home_screen.dart';
import 'package:tenkasi/widget/common/slide_animations.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'common/common.dart';
import 'common/snackbar.dart';
import 'helper/helper_function.dart';
import 'theme_color/theme_color.dart';
import 'package:flutter_html/flutter_html.dart';

class CustomRoute extends PageRouteBuilder {
  final Widget widget;

  CustomRoute({required this.widget}) : super(
    transitionDuration: const Duration(milliseconds: 500),
    pageBuilder: (BuildContext context, Animation<double> animation, Animation<double> secondaryAnimation) {
      return widget;
    },
    transitionsBuilder: (BuildContext context, Animation<double> animation, Animation<double> secondaryAnimation, Widget child) {
      if (animation.status == AnimationStatus.reverse) {
        return FadeTransition(
          opacity: animation,
          child: child,
        );
      } else {
        return SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(1.0, 0.0),
            end: Offset.zero,
          ).animate(animation),
          child: child,
        );
      }
    },
  );
}

class NoResult extends StatelessWidget {
  const NoResult(
      {Key? key,
        required this.onPressed,
        required this.text,
      })
      : super(key: key);
  final VoidCallback onPressed;
  final String text;

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return InkWell(
      onTap: () {},
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            height: size.height * 0.2,
            width: size.width * 0.2,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              shape: BoxShape.rectangle,
              image: const DecorationImage(
                fit: BoxFit.cover,
                image: AssetImage('assets/images/not_found.png'),
              ),
            ),
          ),
          Text(
            text,
            style: const TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.bold,
                color: Colors.black54
            ),
          ),
          SizedBox(
            height: size.height * 0.01,
          ),
          SizedBox(
            // width: size.width * 0.2,
            child: Builder(
              builder: (context) => TextButton(
                onPressed: () {
                  onPressed();
                },
                style: TextButton.styleFrom(
                  foregroundColor: Colors.white,
                  backgroundColor: noDataButtonColor,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: const Text('Back'),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class CustomLoadingButton extends StatefulWidget {
  final String text;
  final double size;
  final VoidCallback onPressed;
  final bool isLoading;
  final Color buttonColor;
  final Color loadingIndicatorColor;
  const CustomLoadingButton({Key? key, required this.text, required this.size, required this.onPressed, required this.isLoading, required this.buttonColor, required this.loadingIndicatorColor}) : super(key: key);

  @override
  State<CustomLoadingButton> createState() => _CustomLoadingButtonState();
}

class _CustomLoadingButtonState extends State<CustomLoadingButton> {
  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: widget.isLoading ? null : widget.onPressed,
      style: ButtonStyle(
        backgroundColor: MaterialStateProperty.all(widget.buttonColor),
      ),
      child: widget.isLoading ? SizedBox(
        height: 20,
        width: 20,
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(
            widget.loadingIndicatorColor,
          ),
          strokeWidth: 2,
        ),
      ) : Text(widget.text, style: TextStyle(fontSize: widget.size),),
    );
  }
}

class ConfirmAlertDialog extends StatefulWidget {
  final String message;
  final Function onCancelPressed;
  final Function onYesPressed;
  const ConfirmAlertDialog({Key? key, required this.message, required this.onCancelPressed, required this.onYesPressed}) : super(key: key);

  @override
  State<ConfirmAlertDialog> createState() => _ConfirmAlertDialogState();
}

class _ConfirmAlertDialogState extends State<ConfirmAlertDialog> {
  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20.0),
      ),
      child: SizedBox(
        width: size.width * 0.4,
        child: ClipRRect(
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(20.0),
            topRight: Radius.circular(20.0),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Flexible(
                child: Image.asset(
                  'assets/alert/confirm.gif',
                  fit: BoxFit.contain,
                ),
              ),
              SizedBox(height: size.height * 0.01),
              Text(
                'Confirm',
                style: TextStyle(
                  fontSize: size.height * 0.025,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: size.height * 0.01),
              Text(
                widget.message,
                style: TextStyle(
                  fontSize: size.height * 0.02,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: size.height * 0.01),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton(
                    onPressed: () {
                      widget.onCancelPressed(); // Return false when Cancel button is pressed
                    },
                    style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red
                    ),
                    child: const Text('No'),
                  ),
                  SizedBox(width: size.width * 0.05),
                  ElevatedButton(
                    onPressed: () {
                      widget.onYesPressed(); // Return true when Yes button is pressed
                    },
                    style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green
                    ),
                    child: const Text('Yes'),
                  ),
                ],
              ),
              SizedBox(height: size.height * 0.01),
            ],
          ),
        ),
      ),
    );
  }
}

class ErrorAlertDialog extends StatefulWidget {
  final String message;
  final Function onOkPressed;
  const ErrorAlertDialog({Key? key, required this.message, required this.onOkPressed}) : super(key: key);

  @override
  State<ErrorAlertDialog> createState() => _ErrorAlertDialogState();
}

class _ErrorAlertDialogState extends State<ErrorAlertDialog> {
  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20.0),
      ),
      child: SizedBox(
        width: size.width * 0.4,
        child: ClipRRect(
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(20.0),
            topRight: Radius.circular(20.0),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Flexible(
                child: Image.asset(
                  'assets/alert/error.gif',
                  fit: BoxFit.contain,
                ),
              ),
              SizedBox(height: size.height * 0.01),
              Text(
                'Error',
                style: TextStyle(
                  fontSize: size.height * 0.025,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: size.height * 0.01),
              Text(
                widget.message,
                style: TextStyle(
                  fontSize: size.height * 0.02,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: size.height * 0.01),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton(
                    onPressed: () {
                      widget.onOkPressed(); // Return true when Yes button is pressed
                    },
                    style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green
                    ),
                    child: const Text('Ok'),
                  ),
                ],
              ),
              SizedBox(height: size.height * 0.01),
            ],
          ),
        ),
      ),
    );
  }
}

class InfoAlertDialog extends StatefulWidget {
  final String message;
  final Function onOkPressed;
  const InfoAlertDialog({Key? key, required this.message, required this.onOkPressed}) : super(key: key);

  @override
  State<InfoAlertDialog> createState() => _InfoAlertDialogState();
}

class _InfoAlertDialogState extends State<InfoAlertDialog> {
  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20.0),
      ),
      child: SizedBox(
        width: size.width * 0.4,
        child: ClipRRect(
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(20.0),
            topRight: Radius.circular(20.0),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Flexible(
                child: Image.asset(
                  'assets/alert/error.gif',
                  fit: BoxFit.contain,
                ),
              ),
              SizedBox(height: size.height * 0.01),
              Text(
                'Info',
                style: TextStyle(
                  fontSize: size.height * 0.025,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: size.height * 0.01),
              Text(
                widget.message,
                style: TextStyle(
                  fontSize: size.height * 0.02,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: size.height * 0.01),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton(
                    onPressed: () {
                      widget.onOkPressed(); // Return true when Yes button is pressed
                    },
                    style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green
                    ),
                    child: const Text('Ok'),
                  ),
                ],
              ),
              SizedBox(height: size.height * 0.01),
            ],
          ),
        ),
      ),
    );
  }
}

class WarningAlertDialog extends StatefulWidget {
  final String message;
  final Function onOkPressed;
  const WarningAlertDialog({Key? key, required this.message, required this.onOkPressed}) : super(key: key);

  @override
  State<WarningAlertDialog> createState() => _WarningAlertDialogState();
}

class _WarningAlertDialogState extends State<WarningAlertDialog> {
  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20.0),
      ),
      child: SizedBox(
        width: size.width * 0.4,
        child: ClipRRect(
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(20.0),
            topRight: Radius.circular(20.0),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Flexible(
                child: Image.asset(
                  'assets/alert/warning.gif',
                  fit: BoxFit.contain,
                ),
              ),
              SizedBox(height: size.height * 0.01),
              Text(
                'Warning',
                style: TextStyle(
                  fontSize: size.height * 0.025,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: size.height * 0.01),
              Text(
                widget.message,
                style: TextStyle(
                  fontSize: size.height * 0.02,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: size.height * 0.01),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton(
                    onPressed: () {
                      widget.onOkPressed(); // Return true when Yes button is pressed
                    },
                    style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green
                    ),
                    child: const Text('Ok'),
                  ),
                ],
              ),
              SizedBox(height: size.height * 0.01),
            ],
          ),
        ),
      ),
    );
  }
}

class CustomLoadingDialog extends StatelessWidget {
  const CustomLoadingDialog({super.key});

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20.0),
      ),
      elevation: 0,
      child: Container(
        alignment: Alignment.center,
        height: size.height * 0.15,
        width: size.width * 0.15,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SizedBox(
              height: size.height * 0.06,
              child: const LoadingIndicator(
                indicatorType: Indicator.ballSpinFadeLoader,
                colors: [Colors.red,Colors.orange,Colors.yellow,Colors.green,Colors.blue,Colors.indigo,Colors.purple,],
              ),
            ),
            SizedBox(height: size.height * 0.01,),
            Text(
              'Please wait...',
              style: TextStyle(
                fontSize: size.height * 0.018,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class CustomBottomSheet extends StatelessWidget {
  final Size size;
  final VoidCallback onDeletePressed;
  final VoidCallback onEditPressed;

  const CustomBottomSheet({super.key, required this.size, required this.onDeletePressed, required this.onEditPressed,});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: size.height * 0.15,
      decoration: const BoxDecoration(
        borderRadius: BorderRadius.only(
          topRight: Radius.circular(25),
          topLeft: Radius.circular(25),
        ),
        color: whiteColor,
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Container(
              width: size.width * 0.3,
              height: size.height * 0.008,
              alignment: Alignment.topCenter,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(30),
                color: const Color(0xFFCDCDCD),
              ),
            ),
            SizedBox(height: size.height * 0.05),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                userRole == 'House/Community' && userMember == '' ? Container(
                  width: size.width * 0.3,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(5),
                  ),
                  child: TextButton.icon(
                    onPressed: onDeletePressed,
                    icon: const Icon(Icons.delete),
                    label: const Text('Delete'),
                    style: TextButton.styleFrom(
                      foregroundColor: Colors.white,
                      backgroundColor: Colors.red,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(5),
                      ),
                    ),
                  ),
                ) : userRole != 'House/Community' ? Container(
                  width: size.width * 0.3,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(5),
                  ),
                  child: TextButton.icon(
                    onPressed: onDeletePressed,
                    icon: const Icon(Icons.delete),
                    label: const Text('Delete'),
                    style: TextButton.styleFrom(
                      foregroundColor: Colors.white,
                      backgroundColor: Colors.red,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(5),
                      ),
                    ),
                  ),
                ) : Container(),
                SizedBox(width: size.width * 0.03),
                Container(
                  width: size.width * 0.3,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(5),
                  ),
                  child: TextButton.icon(
                    onPressed: onEditPressed,
                    icon: const Icon(Icons.edit),
                    label: const Text('Edit'),
                    style: TextButton.styleFrom(
                      foregroundColor: Colors.white,
                      backgroundColor: Colors.orange,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(5),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class ConditionalFloatingActionButton extends StatefulWidget {
  final bool isEmpty;
  final Color iconBackColor;
  final VoidCallback onPressed;
  final Widget? child;

  const ConditionalFloatingActionButton({
    Key? key,
    required this.isEmpty,
    required this.iconBackColor,
    required this.onPressed,
    this.child,
  }) : super(key: key);

  @override
  State<ConditionalFloatingActionButton> createState() => _ConditionalFloatingActionButtonState();
}

class _ConditionalFloatingActionButtonState
    extends State<ConditionalFloatingActionButton> {
  Timer? glowTimer;
  bool isGlowing = false;
  double glowOpacity = 0.0;

  void startGlowAnimation() {
    const duration = Duration(milliseconds: 800);
    glowTimer = Timer.periodic(duration, (Timer timer) {
      setState(() {
        isGlowing = !isGlowing;
        glowOpacity = isGlowing ? 1.0 : 0.0;
      });
    });
  }

  @override
  void initState() {
    super.initState();
    startGlowAnimation();
  }

  @override
  void dispose() {
    glowTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return widget.isEmpty ? AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      width: 55.0,
      height: 55.0,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: widget.iconBackColor
            .withOpacity(glowOpacity),
        boxShadow: [
          BoxShadow(
            color: widget.iconBackColor
                .withOpacity(glowOpacity),
            blurRadius: 10.0,
            spreadRadius: 5.0,
          ),
        ],
      ),
      child: FloatingActionButton(
        onPressed: widget.onPressed,
        backgroundColor: widget.iconBackColor,
        child: widget.child,
      ),
    ) : FloatingActionButton(
      onPressed: widget.onPressed,
      backgroundColor: widget.iconBackColor,
      child: widget.child,
    );
  }
}

class CustomProfileBottomSheet extends StatelessWidget {
  final Size size;
  final VoidCallback onGalleryPressed;
  final VoidCallback onCameraPressed;
  final VoidCallback onRemovePressed;

  const CustomProfileBottomSheet({
    Key? key,
    required this.size,
    required this.onGalleryPressed,
    required this.onCameraPressed,
    required this.onRemovePressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: const BorderRadius.vertical(top: Radius.circular(25.0)),
      child: Container(
        height: size.height * 0.25,
        decoration: const BoxDecoration(
          borderRadius: BorderRadius.only(
            topRight: Radius.circular(25),
            topLeft: Radius.circular(25),
          ),
          color: Colors.white,
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Container(
                width: size.width * 0.3,
                height: size.height * 0.008,
                alignment: Alignment.topCenter,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(30),
                  color: screenBackgroundColor,
                ),
              ),
              SizedBox(height: size.height * 0.01),
              ListTile(
                leading: Image.asset('assets/images/gallery.png'),
                title: Text(
                  'Gallery',
                  style: GoogleFonts.signika(
                    fontSize: size.height * 0.02,
                    color: Colors.black,
                  ),
                ),
                onTap: onGalleryPressed,
              ),
              SizedBox(width: size.height * 0.01),
              ListTile(
                leading: Image.asset('assets/images/camera.png'),
                title: Text(
                    'Camera',
                    style: GoogleFonts.signika(
                      fontSize: size.height * 0.02,
                      color: Colors.black,
                    )
                ),
                onTap: onCameraPressed,
              ),
              SizedBox(width: size.height * 0.02),
              Container(
                width: size.width * 0.8,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(5),
                ),
                child: TextButton.icon(
                  onPressed: onRemovePressed,
                  icon: const Icon(Icons.delete),
                  label: const Text('Remove'),
                  style: TextButton.styleFrom(
                    foregroundColor: Colors.white,
                    backgroundColor: Colors.red,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(5),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class CustomContentBottomSheet extends StatelessWidget {
  final Size size;
  final String title;
  final String content;

  const CustomContentBottomSheet({
    Key? key,
    required this.size,
    required this.title,
    required this.content,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: const BorderRadius.vertical(top: Radius.circular(25.0)),
      child: Container(
        height: size.height * 0.6,
        decoration: const BoxDecoration(
          borderRadius: BorderRadius.only(
            topRight: Radius.circular(25),
            topLeft: Radius.circular(25),
          ),
          color: Colors.white,
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              SizedBox(height: size.height * 0.01),
              Container(
                width: size.width * 0.3,
                height: size.height * 0.008,
                alignment: Alignment.topCenter,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(30),
                  color: screenBackgroundColor,
                ),
              ),
              SizedBox(height: size.height * 0.01),
              Padding(
                padding: const EdgeInsets.only(left: 10, right: 10),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                        title,
                        style: GoogleFonts.signika(
                            fontSize: size.height * 0.025,
                            color: backgroundColor
                        )
                    ),
                    IconButton(
                      icon: const Icon(Icons.close, color: buttonRed,),
                      onPressed: () {
                        Navigator.pop(context);
                      },
                    ),
                  ],
                ),
              ),
              SizedBox(width: size.height * 0.01),
              Expanded(
                child: SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Html(
                      data: content,
                      style: {
                        'p': Style(
                          lineHeight: const LineHeight(1.5),
                          textAlign: TextAlign.justify,
                          fontSize: FontSize(size.height * 0.02),
                        ),
                      },
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class CustomTabBar extends StatefulWidget {
  const CustomTabBar({
    Key? key,
    required this.tabController,
    required this.tabs,
    required this.onTabTap,
  }) : super(key: key);

  final TabController tabController;
  final List<String> tabs;
  final Function(int) onTabTap;

  @override
  State<CustomTabBar> createState() => _CustomTabBarState();
}

class _CustomTabBarState extends State<CustomTabBar> {
  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Container(
      alignment: Alignment.topCenter,
      padding: EdgeInsets.only(
        left: MediaQuery.of(context).size.width * 0.03,
        right: MediaQuery.of(context).size.width * 0.03,
      ),
      child: Container(
        padding: const EdgeInsets.all(5),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: whiteColor,
          borderRadius: BorderRadius.circular(25.0),
        ),
        constraints: BoxConstraints.expand(height: MediaQuery.of(context).size.height * 0.05),
        child: TabBar(
          controller: widget.tabController,
          indicator: BoxDecoration(
            color: tabBackColor, // Define tabBackColor elsewhere in your code
            borderRadius: BorderRadius.circular(25.0),
            boxShadow: [
              BoxShadow(
                color: tabBackColor.withOpacity(0.8),
                blurRadius: 10,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          labelColor: tabLabelColor, // Define tabLabelColor elsewhere in your code
          unselectedLabelColor: unselectColor, // Define unselectColor elsewhere in your code
          tabs: widget.tabs.map((tabText) {
            return Tab(
              child: Text(
                tabText,
                style: TextStyle(
                  fontSize: size.height * 0.018,
                ),
              ),
            );
          }).toList(),
          onTap: (index) {
            widget.onTabTap(index);
          },
        ),
      ),
    );
  }
}

void clearImageCache() {
  PaintingBinding.instance.imageCache.clear();
}

class CustomBibleDialog extends StatelessWidget {
  final VoidCallback onTamilPressed;
  final VoidCallback onEnglishPressed;
  const CustomBibleDialog({super.key, required this.onTamilPressed, required this.onEnglishPressed});

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20.0),
      ),
      elevation: 0,
      child: Stack(
        children: [
          SlideFadeAnimation(
            duration: const Duration(seconds: 1),
            child: SizedBox(
              height: size.height * 0.3,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Text(
                    'Select the Language to continue',
                    style: TextStyle(
                      fontSize: size.height * 0.018,
                      fontWeight: FontWeight.bold,
                      color: textColor
                    ),
                  ),
                  SizedBox(
                    width: size.width * 0.35,
                    child: Center(
                        child: Image.asset("assets/png/bible_type.png")
                    ),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      TextButton(
                        style: TextButton.styleFrom(
                            foregroundColor: navIconColor,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                            backgroundColor: primaryColor
                        ),
                        onPressed: onTamilPressed,
                        child: Padding(
                          padding: const EdgeInsets.only(left: 15, right: 15),
                          child: Text('TAMIL', style: GoogleFonts.roboto(fontSize: size.height * 0.018, color: whiteColor, fontWeight: FontWeight.bold),),
                        ),
                      ),
                      TextButton(
                        style: TextButton.styleFrom(
                            foregroundColor: navIconColor,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                            backgroundColor: primaryColor
                        ),
                        onPressed: onEnglishPressed,
                        child: Padding(
                          padding: const EdgeInsets.only(left: 15, right: 15),
                          child: Text('ENGLISH', style: GoogleFonts.roboto(fontSize: size.height * 0.018, color: whiteColor, fontWeight: FontWeight.bold),),
                        ),
                      ),
                    ],
                  )
                ],
              ),
            ),
          ),
          Positioned(
              top: 0,
              right: 0,
              child: IconButton(
                icon: const Icon(Icons.cancel, color: buttonRed,),
                onPressed: () {
                  Navigator.pop(context);
                },
              ),
          )
        ],
      ),
    );
  }
}

class ClearSharedPreference {
  clearSharedPreferenceData(BuildContext context) async {
    // Deleting shared-preferences data
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
    authToken = '';
    tokenExpire = '';
    userRole = '';
    isSignedIn = false;
    await Future.delayed(const Duration(seconds: 1));
    Navigator.of(context).pushReplacement(CustomRoute(widget: const HomeScreen()));
    AnimatedSnackBar.show(
        context,
        'Your session expired; please login again.',
        Colors.blue
    );
  }
}
