import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:google_fonts/google_fonts.dart';
import 'package:loading_indicator/loading_indicator.dart';
import 'package:munchirai/widget/common/common.dart';
import 'package:munchirai/widget/common/internet_connection_checker.dart';
import 'package:munchirai/widget/common/slide_animations.dart';
import 'package:munchirai/widget/theme_color/theme_color.dart';
import 'package:munchirai/widget/widget.dart';

import 'image_view_screen.dart';

class GalleryDetailScreen extends StatefulWidget {
  final String title;
  const GalleryDetailScreen({Key? key, required this.title}) : super(key: key);

  @override
  State<GalleryDetailScreen> createState() => _GalleryDetailScreenState();
}

class _GalleryDetailScreenState extends State<GalleryDetailScreen> {
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
        // backgroundColor: screenBackgroundColor,
        appBar: AppBar(
          title: Text(
            widget.title,
            style: TextStyle(
              fontSize: size.height * 0.02,
              fontWeight: FontWeight.bold,
              color: whiteColor,
            ),
          ),
          centerTitle: true,
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
          // backgroundColor: backgroundColor,
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
            ) : imageData.isNotEmpty ? Padding(
              padding: const EdgeInsets.only(left: 10, right: 10),
              child: Column(
                children: [
                  SizedBox(
                    height: size.height * 0.01,
                  ),
                  Expanded(
                    child: SlideFadeAnimation(
                      duration: const Duration(seconds: 1),
                      child: SingleChildScrollView(
                        child: ListView.builder(
                            key: Key('builder ${selected.toString()}'),
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: imageData.length,
                            itemBuilder: (BuildContext context, int index) {
                              return Column(
                                children: [
                                  GestureDetector(
                                    onTap: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) => ImageViewScreen(
                                            images: imageData,
                                            initialIndex: index,
                                          ),
                                        ),
                                      );
                                    },
                                    child: Row(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        GestureDetector(
                                          onTap: () {
                                            imageData[index]['image'] != null && imageData[index]['image'] != '' ? showDialog(
                                              context: context,
                                              builder: (BuildContext context) {
                                                return Dialog(
                                                  child: Image.network(imageData[index]['image'], fit: BoxFit.cover,),
                                                );
                                              },
                                            ) : showDialog(
                                              context: context,
                                              builder: (BuildContext context) {
                                                return Dialog(
                                                  child: Image.asset('assets/images/no_image.jpg', fit: BoxFit.cover,),
                                                );
                                              },
                                            );
                                          },
                                          child: Container(
                                            height: size.height * 0.08,
                                            width: size.width * 0.18,
                                            decoration: BoxDecoration(
                                              borderRadius: BorderRadius.circular(10),
                                              boxShadow: const <BoxShadow>[
                                                BoxShadow(
                                                  color: Colors.grey,
                                                  spreadRadius: -1,
                                                  blurRadius: 5 ,
                                                  offset: Offset(0, 1),
                                                ),
                                              ],
                                              shape: BoxShape.rectangle,
                                              image: DecorationImage(
                                                fit: BoxFit.cover,
                                                image: imageData[index]['image'] != null && imageData[index]['image'] != '' ?
                                                NetworkImage(imageData[index]['image']) : const AssetImage('assets/images/no_image.jpg') as ImageProvider,
                                              ),
                                            ),
                                          ),
                                        ),
                                        Expanded(
                                          child: Container(
                                            padding: const EdgeInsets.only(top: 5, bottom: 5, left: 20, right: 10),
                                            child: Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                Row(
                                                  children: [
                                                    Flexible(
                                                      child: Text(
                                                        imageData[index]['name'].split('.').first[0].toUpperCase() + imageData[index]['name'].split('.').first.substring(1),
                                                        style: GoogleFonts.roboto(
                                                            fontWeight: FontWeight.w600,
                                                            fontSize: size.height * 0.02,
                                                            color: labelColor
                                                        ),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                                SizedBox(height: size.height * 0.008,),
                                                Row(
                                                  children: [
                                                    imageData[index]['image_size'] != null && imageData[index]['image_size'] != "" ? Text(
                                                      imageData[index]['image_size'],
                                                      style: const TextStyle(
                                                          color: emptyColor
                                                      ),
                                                    ) : Container(),
                                                    imageData[index]['image_size'] != null && imageData[index]['image_size'] != "" ? SizedBox(width: size.width * 0.01,) : Container(),
                                                    imageData[index]['image_size'] != null && imageData[index]['image_size'] != "" ? const VerticalDivider(
                                                      color: Colors.grey,
                                                      thickness: 3,
                                                    ) : Container(),
                                                    imageData[index]['image_size'] != null && imageData[index]['image_size'] != "" ? SizedBox(width: size.width * 0.01,) : Container(),
                                                    Text(
                                                      imageData[index]['date'],
                                                      style: const TextStyle(
                                                          color: emptyColor
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  SizedBox(height: size.height * 0.015,)
                                ],
                              );
                            }
                        ),
                      ),
                    ),
                  ),
                ],
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
        // floatingActionButton: userRole == "Parish Admin" ? imageData.isEmpty ? ConditionalFloatingActionButton(
        //   isEmpty: true,
        //   iconBackColor: iconBackColor,
        //   onPressed: () {},
        //   child: const Icon(Icons.add, color: buttonIconColor,),
        // ) : ConditionalFloatingActionButton(
        //   isEmpty: false,
        //   iconBackColor: iconBackColor,
        //   onPressed: () {},
        //   child: const Icon(Icons.add, color: buttonIconColor,),
        // ) : Container(),
      ),
    );
  }
}
