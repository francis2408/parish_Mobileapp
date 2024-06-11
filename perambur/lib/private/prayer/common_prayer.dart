import 'package:flutter/material.dart';
import 'package:perambur/widget/widget.dart';

class CommonPrayerScreen extends StatefulWidget {
  const CommonPrayerScreen({Key? key}) : super(key: key);

  @override
  State<CommonPrayerScreen> createState() => _CommonPrayerScreenState();
}

class _CommonPrayerScreenState extends State<CommonPrayerScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: Container(
            alignment: Alignment.center,
            padding: const EdgeInsets.only(left: 30, right: 30),
            child: NoResult(
              onPressed: () {
                setState(() {
                  Navigator.pop(context);
                });
              },
              text: 'No Data available',
            ),
          ),
        ),
      ),
    );
  }
}
