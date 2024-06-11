import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:loading_indicator/loading_indicator.dart';
import 'package:perambur/widget/common/common.dart';
import 'package:perambur/widget/common/internet_connection_checker.dart';
import 'package:perambur/widget/common/slide_animations.dart';
import 'package:perambur/widget/common/snackbar.dart';
import 'package:perambur/widget/theme_color/theme_color.dart';
import 'package:perambur/widget/widget.dart';

import 'add_gallery.dart';
import 'gallery_detail.dart';

class GalleryScreen extends StatefulWidget {
  const GalleryScreen({Key? key}) : super(key: key);

  @override
  State<GalleryScreen> createState() => _GalleryScreenState();
}

class _GalleryScreenState extends State<GalleryScreen> {
  bool _isLoading = true;
  List galleryData = [];
  int selected = -1;

  getGalleryData() async {
    var request = http.Request('GET', Uri.parse('$baseUrl/res.gallery'));
    request.body = json.encode({
      "params": {
        "filter": "[['parish_id','=',$parishID]]",
        "access_all": "1",
        "query": "{id,name,date,description,no_of_images,image_ids{id,name,image_1920}}"
      }
    });
    request.headers.addAll(header);
    http.StreamedResponse response = await request.send();
    if (response.statusCode == 200) {
      var decode = json.decode(await response.stream.bytesToString())['result'];
      if(decode['status'] == true) {
        List data = decode['data']['result'];
        setState(() {
          _isLoading = false;
        });
        galleryData = data;
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

  delete() async {
    var request = http.Request('POST', Uri.parse('$baseUrl/delete/res.gallery'));
    request.body = json.encode({
      "params": {
        "ids": [galleryId]
      }
    });
    request.headers.addAll(header);
    http.StreamedResponse response = await request.send();
    if (response.statusCode == 200) {
      setState(() {
        Navigator.pop(context);
        Navigator.pop(context);
        changeData();
        AnimatedSnackBar.show(
            context,
            'Gallery data deleted successfully.',
            Colors.green
        );
      });
    } else {
      var message = json.decode(await response.stream.bytesToString())['message'];
      setState(() {
        _isLoading = false;
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

  changeData() {
    setState(() {
      _isLoading = true;
      getGalleryData();
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
    getGalleryData();
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
        backgroundColor: screenBackgroundColor,
        appBar: AppBar(
          backgroundColor: primaryColor,
          title: Text(
            'Gallery',
            style: TextStyle(
              fontSize: size.height * 0.02,
              fontWeight: FontWeight.bold,
              color: whiteColor,
            ),
          ),
          centerTitle: true,
        ),
        body: _isLoading ? Center(
          child: SizedBox(
            height: size.height * 0.06,
            child: const LoadingIndicator(
              indicatorType: Indicator.ballSpinFadeLoader,
              colors: [Colors.red,Colors.orange,Colors.yellow,Colors.green,Colors.blue,Colors.indigo,Colors.purple,],
            ),
          ),
        ) : galleryData.isNotEmpty ? Column(
          children: [
            SizedBox(
              height: size.height * 0.01,
            ),
            Expanded(
              child: SlideFadeAnimation(
                duration: const Duration(seconds: 1),
                child: SizedBox(
                  height: size.height,
                  child: GridView.builder(
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      childAspectRatio: 1,
                    ),
                    itemCount: galleryData.length,
                    itemBuilder: (context, index) {
                      return GestureDetector(
                          onTap: () async {
                            galleryId = galleryData[index]['id'].toString();
                            String refresh = await Navigator.push(context, CustomRoute(widget: GalleryDetailScreen(title: '${galleryData[index]['name']}',)));
                            if(refresh == 'refresh') {
                              changeData();
                            }
                          },
                          child: Stack(
                            children: [
                              GridItem(
                                image: galleryData[index]['image_ids'].isNotEmpty && galleryData[index]['image_ids'] != [] ? galleryData[index]['image_ids'][0]['image_1920'] : '',
                                name: galleryData[index]['name'],
                                count: galleryData[index]['no_of_images'].toString(),
                              ),
                              userRole != 'Parish Family' ? Positioned(
                                bottom: 2,
                                right: 2,
                                child: IconButton(
                                  icon: Icon(Icons.delete, color: redColor,),
                                  onPressed: () {
                                    galleryId = galleryData[index]['id'].toString();
                                    showDialog(
                                      context: context,
                                      builder: (BuildContext context) {
                                        return ConfirmAlertDialog(
                                          message: 'Are you sure want to delete the gallery data ?',
                                          onCancelPressed: () {
                                            setState(() {
                                              Navigator.pop(context);
                                            });
                                          },
                                          onYesPressed: () {
                                            setState(() {
                                              showDialog(
                                                context: context,
                                                barrierDismissible: false,
                                                builder: (BuildContext context) {
                                                  return const CustomLoadingDialog();
                                                },
                                              );
                                              delete();
                                            });
                                          },
                                        );
                                      },
                                    );
                                  },
                                ),
                              ) : Container()
                            ],
                          )
                      );
                    },
                  ),
                ),
              ),
            ),
          ],
        ) : Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
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
        floatingActionButton: userRole != 'Parish Family' ? FloatingActionButton(
          backgroundColor: secondaryColor,
          onPressed: () async {
            String refresh = await Navigator.push(context, CustomRoute(widget: const AddGalleryScreen()));
            if(refresh == 'refresh') {
              changeData();
            }
          },
          child: const Icon(
            Icons.add_photo_alternate_outlined,
            color: blackColor,
          ),
        ) : Container(),
      ),
    );
  }
}

class GridItem extends StatelessWidget {
  final String image;
  final String name;
  final String count;
  const GridItem({Key? key, required this.image, required this.name, required this.count}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Card(
          elevation: 4,
          margin: const EdgeInsets.all(10),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: image != null && image != "" ? Image.network(
                    image,
                    fit: BoxFit.cover,
                  ) : Image.asset(
                    "assets/images/no_image.jpg",
                    fit: BoxFit.contain,
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8),
                child: Text(
                  name,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ),
        count != null && count != '' ? Positioned(
          top: 15,
          right: 15,
          child: Container(
            padding: const EdgeInsets.only(top: 5, bottom: 5, left: 10, right: 10),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(5),
              color: Colors.black54,
            ),
            child: RichText(
              text: TextSpan(
                text: count.toString(),
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: whiteColor,
                ),
              ),
            ),
          ),
        ) : Positioned(child: Container())
      ],
    );
  }
}
