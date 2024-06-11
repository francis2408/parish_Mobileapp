import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:loading_indicator/loading_indicator.dart';
import 'package:perambur/widget/common/common.dart';
import 'package:perambur/widget/common/internet_connection_checker.dart';
import 'package:perambur/widget/common/slide_animations.dart';
import 'package:perambur/widget/theme_color/theme_color.dart';
import 'package:perambur/widget/widget.dart';

import 'image_view_screen.dart';

class PublicGalleryDetailScreen extends StatefulWidget {
  final String title;
  const PublicGalleryDetailScreen({Key? key, required this.title}) : super(key: key);

  @override
  State<PublicGalleryDetailScreen> createState() => _PublicGalleryDetailScreenState();
}

class _PublicGalleryDetailScreenState extends State<PublicGalleryDetailScreen> {
  bool _isLoading = true;
  List imageData = [];
  int selected = -1;

  getImageData() async {
    var request = http.Request('GET', Uri.parse('$baseUrl/public/$parishID/res.gallery'));
    request.body = json.encode({
      "params": {
        "filter": "[['id','=',$galleryId]]",
        "query": "{id,name,date,description,no_of_images,image_ids{id,name,image_1920,gallery_id{date}}}"
      }
    });
    request.headers.addAll(headers);
    http.StreamedResponse response = await request.send();
    if (response.statusCode == 200) {
      var decode = json.decode(await response.stream.bytesToString())['result'];
      if(decode['status'] == 'success') {
        List data = decode['result'];
        for(int i = 0; i < data.length; i++) {
          if (data[i]['image_ids'].isNotEmpty && data[i]['image_ids'] != []) {
            for (var image in data[i]['image_ids']) {
              var imageSize = await getImageSize(image['image_1920']);
              imageData.add({
                'id': image['id'],
                'name': image['name'],
                'date': image['gallery_id']['date'],
                'image_size': imageSize,
                'image': image['image_1920']
              });
            }
          }
        }
        setState(() {
          _isLoading = false;
        });
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

  getImageSize(String imageUrl) async {
    try {
      var size = (await HttpClient().getUrl(Uri.parse(imageUrl))
          .then((request) => request.close()))
          .contentLength;
      if (size < 1024 * 1024) {
        final kb = size / 1024;
        return '${kb.toStringAsFixed(2)} KB';
      } else {
        final mb = size / (1024 * 1024);
        return '${mb.toStringAsFixed(2)} MB';
      }
    } catch (e) {
      return null;
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
    getImageData();
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
          backgroundColor: primaryColor,
          title: Text(
            widget.title,
            style: TextStyle(
              fontSize: size.height * 0.02,
              fontWeight: FontWeight.bold,
              color: whiteColor,
            ),
          ),
          centerTitle: true,
        ),
        body: SafeArea(
          child: Center(
            child: _isLoading ? Center(
              child: SizedBox(
                height: size.height * 0.06,
                child: const LoadingIndicator(
                  indicatorType: Indicator.ballSpinFadeLoader,
                  colors: [Colors.red,Colors.orange,Colors.yellow,Colors.green,Colors.blue,Colors.indigo,Colors.purple,],
                ),
              ),
            ) : imageData.isNotEmpty ? SlideFadeAnimation(
              duration: const Duration(seconds: 1),
              child: SingleChildScrollView(
                child: SizedBox(
                  height: size.height,
                  child: GridView.builder(
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 4,
                      childAspectRatio: 1,
                    ),
                    itemCount: imageData.length,
                    itemBuilder: (context, index) {
                      return GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => PublicImageViewScreen(
                                images: imageData,
                                initialIndex: index,
                              ),
                            ),
                          );},
                        child: Padding(
                          padding: const EdgeInsets.all(2),
                          child: Container(
                            decoration: BoxDecoration(
                              image: DecorationImage(
                                fit: BoxFit.cover,
                                image: imageData[index]['image'] != null && imageData[index]['image'] != '' ?
                                NetworkImage(imageData[index]['image']) : const AssetImage('assets/images/no_image.jpg') as ImageProvider,
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
            ) : Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.only(left: 30, right: 30),
                  child: NoResult(
                    onPressed: () {
                      setState(() {
                        Navigator.pop(context);
                      });
                    },
                    text: 'No Data available',
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
