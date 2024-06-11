import 'package:flutter/material.dart';
import 'package:loading_indicator/loading_indicator.dart';
import 'package:perambur/widget/theme_color/theme_color.dart';
import 'package:webview_flutter/webview_flutter.dart';

class WebViewScreen extends StatefulWidget {
  final String url;
  final String name;
  const WebViewScreen({Key? key, required this.url, required this.name}) : super(key: key);

  @override
  State<WebViewScreen> createState() => _WebViewScreenState();
}

class _WebViewScreenState extends State<WebViewScreen> {
  bool _isLoading = true;
  var controller;

  void loadDataWithDelay() {
    Future.delayed(const Duration(seconds: 1), () {
      setState(() {
        _isLoading = false;
        controller = WebViewController()
          ..setJavaScriptMode(JavaScriptMode.unrestricted)
          ..setBackgroundColor(whiteColor)
          ..loadRequest(Uri.parse(widget.url));
      });
    });
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    loadDataWithDelay();
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Scaffold(
      appBar: AppBar(
        backgroundColor: primaryColor,
        title: Text(
          widget.name,
          style: TextStyle(
            fontSize: size.height * 0.02,
            fontWeight: FontWeight.bold,
            color: whiteColor,
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
          child: _isLoading ? Center(
            child: SizedBox(
              height: size.height * 0.06,
              child: const LoadingIndicator(
                indicatorType: Indicator.ballSpinFadeLoader,
                colors: [Colors.red,Colors.orange,Colors.yellow,Colors.green,Colors.blue,Colors.indigo,Colors.purple,],
              ),
            ),
          ) : WebViewWidget(controller: controller,)
      ),
    );
  }
}
