import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_svg/svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:perambur/widget/common/common.dart';
import 'package:perambur/widget/common/internet_connection_checker.dart';
import 'package:perambur/widget/common/snackbar.dart';
import 'package:perambur/widget/theme_color/theme_color.dart';
import 'package:perambur/widget/widget.dart';

class AddGalleryScreen extends StatefulWidget {
  const AddGalleryScreen({Key? key}) : super(key: key);

  @override
  State<AddGalleryScreen> createState() => _AddGalleryScreenState();
}

class _AddGalleryScreenState extends State<AddGalleryScreen> {
  final formKey = GlobalKey<FormState>();
  var titleController = TextEditingController();
  var dateController = TextEditingController();
  List<TextEditingController> textControllers = [];
  List<Map<String, dynamic>> imageDataList = [];
  List images = [];
  String dates = '';

  bool _displayNewTextField = false;
  bool _isLoading = true;
  bool load = true;
  bool isTitle = false;
  bool isDate = false;

  final format = DateFormat("dd-MM-yyyy");
  final reverse = DateFormat("yyyy-MM-dd");

  save(String name, date) async {
    var request = http.Request('POST',  Uri.parse('$baseUrl/create/res.gallery'));
    for(var data in imageDataList) {
      images.add([0,0,{
        'name': data['name'],
        'image_1920': data['image_1920'],
      }]);
    }
    request.body = json.encode({
      "params": {
        "data": {"name": name, "date": dates, "image_ids": images, "parish_id": int.parse(parishID)}
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
  Future<void> getImages() async {
    final picker = ImagePicker();
    final pickedFiles = await picker.pickMultiImage(
      imageQuality: 100,
      maxHeight: 1000,
      maxWidth: 1000,
    );

    if (pickedFiles != null) {
      if (pickedFiles.length > 5) {
        AnimatedSnackBar.show(
          context,
          'Please select only 5 images.',
          Colors.red,
        );
      } else {
        for (var pickedFile in pickedFiles) {
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
          final base64Image = base64Encode(file.readAsBytesSync());
          imageDataList.add({
            'name': pickedFile.name,
            'path': pickedFile.path,
            'image_1920': base64Image,
            'size': size,
          });
        }
        setState(() {});
      }
    } else {
      AnimatedSnackBar.show(
        context,
        'No images selected.',
        Colors.red,
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
    textControllers.add(TextEditingController());
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
            'Add Gallery',
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
                                  padding: const EdgeInsets.only(top: 5, bottom: 10),
                                  alignment: Alignment.topLeft,
                                  child: Row(
                                    children: [
                                      Text(
                                        'Name',
                                        style: GoogleFonts.poppins(
                                          fontSize: size.height * 0.018,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.black,
                                        ),
                                      ),
                                      SizedBox(width: size.width * 0.02,),
                                      Text('*', style: GoogleFonts.poppins(fontSize: size.height * 0.02, fontWeight: FontWeight.bold, color: Colors.red,),)
                                    ],
                                  ),
                                ),
                                Container(
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(10),
                                    color: whiteColor,
                                    boxShadow: <BoxShadow>[
                                      BoxShadow(
                                        color: containerShadow.withOpacity(0.5),
                                        spreadRadius: 0.3,
                                        blurRadius: 3,
                                        offset: const Offset(2, 2),
                                      ),
                                    ],
                                  ),
                                  child: TextFormField(
                                    controller: titleController,
                                    keyboardType: TextInputType.text,
                                    autocorrect: true,
                                    autovalidateMode: AutovalidateMode.onUserInteraction,
                                    style: GoogleFonts.breeSerif(
                                        color: Colors.black,
                                        letterSpacing: 0.2
                                    ),
                                    decoration: InputDecoration(
                                      hintText: "Enter name",
                                      border: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(10)
                                      ),
                                      hintStyle: GoogleFonts.breeSerif(
                                        color: labelColor2,
                                        fontStyle: FontStyle.italic,
                                      ),
                                      enabledBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(10),
                                        borderSide: const BorderSide(
                                          color: disableColor,
                                          width: 1.0,
                                        ),
                                      ),
                                      focusedBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(10),
                                        borderSide: const BorderSide(
                                          color: disableColor,
                                          width: 1.0,
                                        ),
                                      ),
                                    ),
                                    // check tha validation
                                    validator: (val) {
                                      if (val!.isEmpty && val == '') {
                                        isTitle = true;
                                      } else {
                                        isTitle = false;
                                      }
                                    },
                                  ),
                                ),
                                isTitle ? Container(
                                    alignment: Alignment.topLeft,
                                    padding: const EdgeInsets.only(left: 10, top: 8),
                                    child: const Text(
                                      "Name is required",
                                      style: TextStyle(
                                          color: Colors.red,
                                          fontWeight: FontWeight.w500
                                      ),
                                    )
                                ) : Container(),
                                SizedBox(
                                  height: size.height * 0.01,
                                ),
                                Container(
                                  padding: const EdgeInsets.only(top: 5, bottom: 10),
                                  alignment: Alignment.topLeft,
                                  child: Row(
                                    children: [
                                      Text(
                                        'Date',
                                        style: GoogleFonts.poppins(
                                          fontSize: size.height * 0.018,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.black,
                                        ),
                                      ),
                                      SizedBox(width: size.width * 0.02,),
                                      Text('*', style: GoogleFonts.poppins(fontSize: size.height * 0.02, fontWeight: FontWeight.bold, color: Colors.red,),)
                                    ],
                                  ),
                                ),
                                Container(
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(10),
                                    color: whiteColor,
                                    boxShadow: <BoxShadow>[
                                      BoxShadow(
                                        color: containerShadow.withOpacity(0.5),
                                        spreadRadius: 0.3,
                                        blurRadius: 3,
                                        offset: const Offset(2, 2),
                                      ),
                                    ],
                                  ),
                                  child: TextFormField(
                                    controller: dateController,
                                    keyboardType: TextInputType.datetime,
                                    autocorrect: true,
                                    autovalidateMode: AutovalidateMode.onUserInteraction,
                                    style: GoogleFonts.breeSerif(
                                        color: Colors.black,
                                        letterSpacing: 0.2
                                    ),
                                    decoration: InputDecoration(
                                      suffixIcon: const Icon(
                                        Icons.calendar_month,
                                        color: Colors.indigo,
                                      ),
                                      hintText: "Choose the date",
                                      border: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(10)
                                      ),
                                      hintStyle: GoogleFonts.breeSerif(
                                        color: labelColor2,
                                        fontStyle: FontStyle.italic,
                                      ),
                                      enabledBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(10),
                                        borderSide: const BorderSide(
                                          color: disableColor,
                                          width: 1.0,
                                        ),
                                      ),
                                      focusedBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(10),
                                        borderSide: const BorderSide(
                                          color: disableColor,
                                          width: 1.0,
                                        ),
                                      ),
                                    ),
                                    // check the validation
                                    validator: (val) {
                                      if (val!.isEmpty && val == '') {
                                        isDate = true;
                                      } else {
                                        isDate = false;
                                      }
                                    },
                                    onChanged: (val) {
                                      if(val.isEmpty) {
                                        setState(() {
                                          dateController.text = '';
                                          dates = '';
                                          isDate = true;
                                        });
                                      }
                                    },
                                    onFieldSubmitted: (val) {
                                      if(val.isEmpty) {
                                        dateController.text = '';
                                        dates = '';
                                        isDate = true;
                                      }
                                    },
                                    onTap: () async {
                                      DateTime? datePick = await showDatePicker(
                                        context: context,
                                        initialDate: dateController.text.isNotEmpty ? format.parse(dateController.text) :DateTime.now(),
                                        firstDate: DateTime(1900),
                                        lastDate: DateTime.now().add(const Duration(days: 365 * 1)),
                                        builder: (context, child) {
                                          return Theme(
                                            data: Theme.of(context).copyWith(
                                              colorScheme: const ColorScheme.light(
                                                primary: primaryColor,
                                                onPrimary: Colors.white,
                                                onSurface: Colors.black,
                                              ),
                                              textButtonTheme: TextButtonThemeData(
                                                style: TextButton.styleFrom(
                                                  foregroundColor: backgroundColor,
                                                ),
                                              ),
                                            ),
                                            child: child!,
                                          );
                                        },
                                      );
                                      if (datePick != null) {
                                        setState(() {
                                          var dateNow = DateTime.now();
                                          var diff = dateNow.difference(datePick);
                                          var year = ((diff.inDays)/365).round();
                                          dateController.text = format.format(datePick);
                                          dates = reverse.format(datePick);
                                        });
                                      }
                                    },
                                  ),
                                ),
                                isDate ? Container(
                                    alignment: Alignment.topLeft,
                                    padding: const EdgeInsets.only(left: 10, top: 8),
                                    child: const Text(
                                      "Date is required",
                                      style: TextStyle(
                                          color: Colors.red,
                                          fontWeight: FontWeight.w500
                                      ),
                                    )
                                ) : Container(),
                                Container(
                                  padding: const EdgeInsets.only(top: 10),
                                  alignment: Alignment.topLeft,
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            'Images',
                                            style: GoogleFonts.poppins(
                                              fontSize: size.height * 0.018,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.black,
                                            ),
                                          ),
                                          Text(
                                            'Please select only 5 images.',
                                            style: GoogleFonts.signika(
                                              fontSize: size.height * 0.018,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.black45,
                                              fontStyle: FontStyle.italic,
                                            ),
                                          ),
                                        ],
                                      ),
                                      TextButton.icon(
                                        onPressed: () {
                                          setState(() {
                                            _displayNewTextField = true;
                                            getImages();
                                            // textControllers.add(TextEditingController()); // Add a new controller
                                          });
                                        },
                                        icon: const Icon(Icons.add_photo_alternate_outlined, color: whiteColor,),
                                        label: Text(
                                          "Add Images",
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
                        if(titleController.text.isNotEmpty && dateController.text.isNotEmpty) {
                          if(load) {
                            showDialog(
                              context: context,
                              barrierDismissible: false,
                              builder: (BuildContext context) {
                                return const CustomLoadingDialog();
                              },
                            );
                            save(titleController.text.toString(), dateController.text.toString());
                          }
                        } else {
                          setState(() {
                            if (titleController.text.isEmpty) isTitle = true;
                            if (dateController.text.isEmpty) isDate = true;
                            AnimatedSnackBar.show(
                                context,
                                'Please fill the required fields',
                                Colors.red
                            );
                          });
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
