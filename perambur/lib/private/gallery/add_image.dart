import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:perambur/widget/common/common.dart';
import 'package:perambur/widget/common/internet_connection_checker.dart';
import 'package:perambur/widget/common/snackbar.dart';
import 'package:perambur/widget/theme_color/theme_color.dart';
import 'package:perambur/widget/widget.dart';

class AddImageScreen extends StatefulWidget {
  const AddImageScreen({Key? key}) : super(key: key);

  @override
  State<AddImageScreen> createState() => _AddImageScreenState();
}

class _AddImageScreenState extends State<AddImageScreen> {
  final formKey = GlobalKey<FormState>();
  List<Map<String, dynamic>> imageDataList = [];
  List images = [];
  String dates = '';

  bool _displayNewTextField = true;
  bool _isLoading = true;
  bool load = true;
  bool isTitle = false;
  bool isDate = false;

  final format = DateFormat("dd-MM-yyyy");
  final reverse = DateFormat("yyyy-MM-dd");

  save() async {
    var request = http.Request('POST',  Uri.parse('$baseUrl/create/res.gallery.items'));
    var name;
    var image;
    for(var data in imageDataList) {
      name = data['name'];
      image = data['image_1920'];
    }
    request.body = json.encode({
      "params": {
        "data": {"name": name, "image_1920": image, "gallery_id": int.parse(galleryId)}
      }
    });
    request.headers.addAll(header);
    http.StreamedResponse response = await request.send();
    if(response.statusCode == 200) {
      final message = json.decode(await response.stream.bytesToString())['result'];
      setState(() {
        _isLoading = false;
        AnimatedSnackBar.show(
            context,
            message['message'],
            Colors.green
        );
        Navigator.pop(context);
        Navigator.pop(context, 'refresh');
      });
    } else {
      final message = json.decode(await response.stream.bytesToString())['result']['message'];
      setState(() {
        Navigator.pop(context);
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

  // Gallery Images
  Future<void> getImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(
      imageQuality: 100,
      maxHeight: 1000,
      maxWidth: 1000,
      source: ImageSource.gallery,
    );

    if (pickedFile != null) {
      final file = File(pickedFile.path);
      final sizeInBytes = file.lengthSync();
      final sizeInMb = sizeInBytes / (1024 * 1024);
      var size;
      if (sizeInBytes < 1024) {
        size = '${sizeInBytes.toStringAsFixed(0)} bytes';
      } else if (sizeInBytes < 1024 * 1024) {
        final sizeInKB = sizeInBytes / 1024;
        size = '${sizeInKB.toStringAsFixed(2)} KB';
      } else {
        final sizeInMB = sizeInBytes / (1024 * 1024);
        size = '${sizeInMB.toStringAsFixed(2)} MB';
      }
      if (sizeInMb <= 5) {
        final base64Image = base64Encode(file.readAsBytesSync());
        imageDataList.add({
          'name': pickedFile.name,
          'path': pickedFile.path,
          'image_1920': base64Image,
          'size': size,
        });
      }
      setState(() {});
    } else {
      AnimatedSnackBar.show(
          context,
          'No image selected.',
          Colors.red
      );
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
            'Add Image',
            style: TextStyle(
              fontSize: size.height * 0.02,
              fontWeight: FontWeight.bold,
              color: whiteColor,
            ),
          ),
          centerTitle: true,
        ),
        body: SafeArea(
          child: Stack(
            children: [
              const BackgroundWidget(),
              SingleChildScrollView(
                child: Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      alignment: Alignment.topLeft,
                      child: Form(
                        key: formKey,
                        child: Card(
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10)
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(10),
                            child: Column(
                              children: [
                                Container(
                                  padding: const EdgeInsets.only(top: 10),
                                  alignment: Alignment.topLeft,
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Image',
                                        style: GoogleFonts.poppins(
                                          fontSize: size.height * 0.018,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.black,
                                        ),
                                      ),
                                      if(_displayNewTextField) TextButton.icon(
                                        onPressed: () {
                                          setState(() {
                                            _displayNewTextField = false;
                                            getImage();
                                          });
                                        },
                                        icon: const Icon(Icons.add_photo_alternate_outlined, color: whiteColor,),
                                        label: Text(
                                          "Add Image",
                                          textAlign: TextAlign.center,
                                          style: GoogleFonts.breeSerif(
                                            color: whiteColor,
                                          ),
                                        ),
                                        style: TextButton.styleFrom(
                                          foregroundColor: whiteColor,
                                          backgroundColor: Colors.indigo,
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(8),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                ListView.builder(
                                  shrinkWrap: true,
                                  itemCount: imageDataList.length,
                                  itemBuilder: (context, index) {
                                    return Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: ListTile(
                                        leading: Image.file(
                                          File(imageDataList[index]['path']),
                                          width: 50,
                                          height: 50,
                                        ),
                                        title: Text(
                                          imageDataList[index]['name'],
                                          style: GoogleFonts.breeSerif(fontSize: size.height * 0.02, color: textHeadColor,
                                          ),
                                        ),
                                        subtitle: Text(
                                          imageDataList[index]['size'].toString(),
                                          style: GoogleFonts.breeSerif(fontSize: size.height * 0.018, color: blackColor,
                                          ),
                                        ),
                                        trailing: IconButton(
                                          icon: SvgPicture.asset("assets/icons/exit.svg", color: Colors.redAccent.shade700.withOpacity(0.8), height: 25, width: 25),
                                          onPressed: () {
                                            setState(() {
                                              _displayNewTextField = true;
                                              imageDataList.removeAt(index);
                                            });
                                          },
                                        ),
                                      ),
                                    );
                                  },
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(
                      height: size.height * 0.08,
                    )
                  ],
                ),
              ),
            ],
          ),
        ),
        bottomSheet: Container(
          decoration: const BoxDecoration(
              color: whiteColor,
              border: Border(
                  top: BorderSide(
                      color: Colors.grey,
                      width: 1.0
                  )
              )
          ),
          padding: EdgeInsets.only(top: size.height * 0.01, bottom: size.height * 0.01),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Container(
                width: size.width * 0.4,
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(5),
                    color: Colors.red
                ),
                child: TextButton(
                    onPressed: () {
                      setState(() {
                        Navigator.pop(context, 'refresh');
                      });
                    },
                    child: Text('Cancel', style: TextStyle(color: Colors.white, fontSize: size.height * 0.02),)
                ),
              ),
              Container(
                  width: size.width * 0.4,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(5),
                    color: greenColor,
                  ),
                  child: TextButton(
                      onPressed: () {
                        if(load) {
                          showDialog(
                            context: context,
                            barrierDismissible: false,
                            builder: (BuildContext context) {
                              return const CustomLoadingDialog();
                            },
                          );
                          save();
                        }
                      },
                      child: Text('Save', style: TextStyle(color: Colors.white, fontSize: size.height * 0.02),)
                  )
              ),
            ],
          ),
        ),
      ),
    );
  }
}
