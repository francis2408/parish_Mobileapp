import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:loading_indicator/loading_indicator.dart';
import 'package:tenkasi/private/screens/bible/bible_repository.dart';
import 'package:tenkasi/widget/common/common.dart';
import 'package:tenkasi/widget/common/internet_connection_checker.dart';
import 'package:tenkasi/widget/common/slide_animations.dart';
import 'package:tenkasi/widget/theme_color/theme_color.dart';
import 'package:tenkasi/widget/widget.dart';

class ChapterDetailsScreen extends StatefulWidget {
  const ChapterDetailsScreen({Key? key}) : super(key: key);

  @override
  State<ChapterDetailsScreen> createState() => _ChapterDetailsScreenState();
}

class _ChapterDetailsScreenState extends State<ChapterDetailsScreen> {
  bool _isLoading = true;
  List verses = [];
  List bibleText = [];
  int index = 0;
  var currentChapterIndex;
  var chapterIndex;

  int selected = -1;
  int selectedIndex = -1;
  bool isCategoryExpanded = false;
  bool isSelected = false;

  void goToNextChapter() {
    if (currentChapterIndex <= chapter.length) {
      setState(() {
        currentChapterIndex++;
        chapterIndex = currentChapterIndex;
        verses.clear();
        List datas = [];
        for (int i = 0; i < bibleText.length; i++) {
          if (bookId == bibleText[i]['field'][1] && chapterIndex == bibleText[i]['field'][2]) {
            datas.add({"verse_id": bibleText[i]['field'][3], "verse_name": bibleText[i]['field'][4]});
          }
        }
        verses.add({
          "book_id": bookId,
          "name": BibleRepository().mapOfBibleBooks[bookId],
          "chapter": chapterIndex,
          "verses": datas
        });
      });
    }
  }

  void goToPreviousChapter() {
    if (currentChapterIndex > 1) {
      setState(() {
        currentChapterIndex--;
        chapterIndex = currentChapterIndex;
        verses.clear();
        List datas = [];
        for (int i = 0; i < bibleText.length; i++) {
          if (bookId == bibleText[i]['field'][1] && chapterIndex == bibleText[i]['field'][2]) {
            datas.add({"verse_id": bibleText[i]['field'][3], "verse_name": bibleText[i]['field'][4]});
          }
        }
        verses.add({
          "book_id": bookId,
          "name": BibleRepository().mapOfBibleBooks[bookId],
          "chapter": chapterIndex,
          "verses": datas
        });
      });
    }
  }

  void loadDataWithDelay() {
    Future.delayed(const Duration(seconds: 1), () {
      getVersesData();
    });
  }

  getVersesData() async {
    final text = await rootBundle.loadString('assets/bible/kjv.json');
    Map<String, dynamic> data = json.decode(text);
    bibleText = data['resultset']['row'];
    currentChapterIndex = chapterId;
    List datas = [];
    for (int i = 0; i < bibleText.length; i++) {
      if (bookId == bibleText[i]['field'][1] && chapterId == bibleText[i]['field'][2]) {
        datas.add({"verse_id": bibleText[i]['field'][3], "verse_name": bibleText[i]['field'][4]});
      }
    }
    verses.add({
      "book_id": bookId,
      "name": BibleRepository().mapOfBibleBooks[bookId],
      "chapter": chapterId,
      "verses": datas
    });
    setState(() {
      _isLoading = false;
    });
    return verses;
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
    loadDataWithDelay();
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return WillPopScope(
      onWillPop: () async {
        Navigator.pop(context);
        return false;
      },
      child: Scaffold(
        backgroundColor: screenBackgroundColor,
        appBar: AppBar(
          backgroundColor: appBackgroundColor,
          title: Text(
            bookName,
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
          ) : verses.isNotEmpty ? Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8)
                ),
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      currentChapterIndex != 1 ? GestureDetector(
                        onTap: () {
                          setState(() {
                            isSelected = false;
                            selectedIndex = -1;
                            goToPreviousChapter();
                          });
                        },
                        child: Container(
                          padding: const EdgeInsets.all(3),
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(5),
                              color: menuPrimaryColor
                          ),
                          child: const Icon(Icons.arrow_back_ios_new, color: whiteColor, size: 20,),
                        ),
                      ) : Container(),
                      Text(
                        'Chapter $currentChapterIndex',
                        style: GoogleFonts.roboto(
                          fontSize: size.height * 0.02,
                          color: expandColor,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      currentChapterIndex != chapter.length ? GestureDetector(
                        onTap: () {
                          setState(() {
                            isSelected = false;
                            selectedIndex = -1;
                            goToNextChapter();
                          });
                        },
                        child: Container(
                          padding: const EdgeInsets.all(3),
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(5),
                              color: menuPrimaryColor
                          ),
                          child: const Icon(Icons.arrow_forward_ios, color: whiteColor, size: 20,),
                        ),
                      ) : Container(),
                    ],
                  ),
                ),
              ),
              Expanded(
                child: SingleChildScrollView(
                  child: SlideFadeAnimation(
                    duration: const Duration(seconds: 1),
                    child: ListView.builder(
                      key: Key('builder ${selected.toString()}'),
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: verses[index]['verses'].length,
                      itemBuilder: (BuildContext context, int indexs) {
                        isSelected = selectedIndex == indexs;
                        return GestureDetector(
                          onTap: () {
                            setState(() {
                              selectedIndex = indexs;
                            });
                          },
                          child: Card(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            color: isSelected ? menuSecondaryColor : whiteColor,
                            child: Container(
                              padding: const EdgeInsets.all(8),
                              child: Column(
                                children: [
                                  Row(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        '${verses[index]['verses'][indexs]['verse_id']}.',
                                        style: GoogleFonts.cardo(
                                          fontSize: size.height * 0.02,
                                          color: valueColor,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                      const SizedBox(
                                        width: 8,
                                      ),
                                      Expanded(
                                        child: Row(
                                          children: [
                                            Flexible(
                                              child: Text(
                                                '${verses[index]['verses'][indexs]['verse_name']}',
                                                style: GoogleFonts.roboto(
                                                  fontSize: size.height * 0.02,
                                                  color: valueColor,
                                                  fontWeight: FontWeight.w600,
                                                ),
                                                textAlign: TextAlign.justify,
                                              ),
                                            )
                                          ],
                                        ),
                                      )
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ),
            ],
          ) : Center(
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
          )
        ),
      ),
    );
  }
}
