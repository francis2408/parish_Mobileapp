import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:loading_indicator/loading_indicator.dart';
import 'package:perambur/private/gallery/add_image.dart';
import 'package:perambur/widget/common/common.dart';
import 'package:perambur/widget/common/internet_connection_checker.dart';
import 'package:perambur/widget/common/slide_animations.dart';
import 'package:perambur/widget/common/snackbar.dart';
import 'package:perambur/widget/theme_color/theme_color.dart';
import 'package:perambur/widget/widget.dart';

import 'image_view_screen.dart';

class GalleryDetailScreen extends StatefulWidget {
  final String title;
  const GalleryDetailScreen({Key? key, required this.title}) : super(key: key);

  @override
  State<GalleryDetailScreen> createState() => _GalleryDetailScreenState();
}

class _GalleryDetailScreenState extends State<GalleryDetailScreen> {
  bool _isLoading = true;
  bool _isAll = false;
  List imageData = [];
  int selected = -1;
  var imageId;

  List selectedIds = [];

  selectImages() {
    if (imageData.isNotEmpty) {
      for (var data in imageData) {
        setState(() {
          selectedIds.add(data['id']);
        });
      }
    }
  }

  getImageData() async {
    var request = http.Request('GET', Uri.parse('$baseUrl/res.gallery'));
    request.body = json.encode({
      "params": {
        "filter": "[['parish_id','=',$parishID],['id','=',$galleryId]]",
        "query": "{id,name,date,description,no_of_images,image_ids{id,name,image_1920,gallery_id{date}}}"
      }
    });
    request.headers.addAll(header);
    http.StreamedResponse response = await request.send();
    if (response.statusCode == 200) {
      var decode = json.decode(await response.stream.bytesToString())['result'];
      if(decode['status'] == true) {
        List data = decode['data']['result'];
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

  delete() async {
    var request = http.Request('POST', Uri.parse('$baseUrl/delete/res.gallery.items'));
    request.body = json.encode({
      "params": {
        "ids": _isAll ? selectedIds : [imageId]
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
            'Image deleted successfully.',
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

  changeData() {
    setState(() {
      _isLoading = true;
      imageData = [];
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
          actions: userRole != 'Parish Family' ? [
            Row(
              children: [
                Theme(
                  data: Theme.of(context).copyWith(
                    unselectedWidgetColor: Colors.white,
                  ),
                  child: Checkbox(
                    activeColor: secondaryColor,
                    checkColor: Colors.white,
                    value: _isAll,
                    onChanged: (value) {
                      setState(() {
                        _isAll = value!;
                        if (_isAll) selectImages();
                        if (_isAll) {
                          showDialog(
                          context: context,
                          builder: (BuildContext context) {
                            return ConfirmAlertDialog(
                              message: 'Are you sure want to delete the all images ?',
                              onCancelPressed: () {
                                setState(() {
                                  _isAll = false;
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
                        }
                      });
                    },
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(5),
                    ),
                  ),
                ),
                Text(
                    "Delete All",
                    style: GoogleFonts.signika(
                      fontSize: size.height * 0.018,
                      color: textColor,
                    )
                ),
              ],
            ),
            SizedBox(width: size.height * 0.01,)
          ] : [],
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
            ) : imageData.isNotEmpty ? Column(
              children: [
                SizedBox(
                  height: size.height * 0.01,
                ),
                Expanded(
                  child: SlideFadeAnimation(
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
                              onTap: () async {
                                imageId = imageData[index]['id'];
                                String refresh = await Navigator.push(context, MaterialPageRoute(
                                  builder: (context) => ImageViewScreen(
                                    images: imageData,
                                    initialIndex: index,
                                  ),
                                ));
                                if(refresh == 'refresh') {
                                  changeData();
                                }},
                              child: Padding(
                                padding: const EdgeInsets.all(2),
                                child: Stack(
                                  children: [
                                    Container(
                                      decoration: BoxDecoration(
                                        image: DecorationImage(
                                          fit: BoxFit.cover,
                                          image: imageData[index]['image'] != null && imageData[index]['image'] != '' ?
                                          NetworkImage(imageData[index]['image']) : const AssetImage('assets/images/no_image.jpg') as ImageProvider,
                                        ),
                                      ),
                                    ),
                                    _isAll ? Positioned(
                                        bottom: 0,
                                        right: 0,
                                        child: Container(
                                          padding: const EdgeInsets.all(1),
                                          decoration: const BoxDecoration(
                                            borderRadius: BorderRadius.only(topLeft: Radius.circular(5)),
                                            color: Colors.white,
                                          ),
                                          child: const Icon(
                                            Icons.check_circle,
                                            color: greenColor,
                                            size: 23,
                                          ),
                                        ),
                                      ) : userRole != 'Parish Family' ? Positioned(
                                      bottom: 0,
                                      right: 0,
                                      child: Container(
                                        padding: const EdgeInsets.all(1),
                                        decoration: const BoxDecoration(
                                          borderRadius: BorderRadius.only(topLeft: Radius.circular(5)),
                                          color: Colors.white,
                                        ),
                                        child: GestureDetector(
                                            onTap: () {
                                              imageId = imageData[index]['id'];
                                              showDialog(
                                                context: context,
                                                builder: (BuildContext context) {
                                                  return ConfirmAlertDialog(
                                                    message: 'Are you sure want to delete the image data ?',
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
                                            child: const Icon(
                                                Icons.delete,
                                                color: redColor,
                                                size: 23
                                            )
                                        ),
                                      ),
                                    ) : Container(),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                  ),
                ),
              ],
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
        floatingActionButton: userRole != 'Parish Family' ? FloatingActionButton(
          backgroundColor: secondaryColor,
          onPressed: () async {
            String refresh = await Navigator.push(context, CustomRoute(widget: const AddImageScreen()));
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
