import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:loading_indicator/loading_indicator.dart';
import 'package:perambur/widget/common/common.dart';
import 'package:perambur/widget/common/internet_connection_checker.dart';
import 'package:perambur/widget/common/slide_animations.dart';
import 'package:perambur/widget/theme_color/theme_color.dart';
import 'package:perambur/widget/widget.dart';

class TamilChapterDetailsScreen extends StatefulWidget {
  const TamilChapterDetailsScreen({Key? key}) : super(key: key);

  @override
  State<TamilChapterDetailsScreen> createState() => _TamilChapterDetailsScreenState();
}

class _TamilChapterDetailsScreenState extends State<TamilChapterDetailsScreen> {
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
        for (int i = 0; i < separatedValues.length; i++) {
          if (bookId == separatedValues[i]['book'] && chapterIndex == separatedValues[i]['chapter']) {
            datas.add({"verse_id": separatedValues[i]['verse'], "verse_name": separatedValues[i]['verses']});
          }
        }
        verses.add({
          "book_id": bookId,
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
        for (int i = 0; i < separatedValues.length; i++) {
          if (bookId == separatedValues[i]['book'] && chapterIndex == separatedValues[i]['chapter']) {
            datas.add({"verse_id": separatedValues[i]['verse'], "verse_name": separatedValues[i]['verses']});
          }
        }
        verses.add({
          "book_id": bookId,
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

  getVersesData() {
    currentChapterIndex = chapterId;
    List datas = [];
    for (int i = 0; i < separatedValues.length; i++) {
      if (bookId == separatedValues[i]['book'] && currentChapterIndex == separatedValues[i]['chapter']) {
        datas.add({"verse_id": separatedValues[i]['verse'], "verse_name": separatedValues[i]['verses']});
      }
    }
    verses.add({
      "book_id": bookId,
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
          backgroundColor: primaryColor,
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
                                color: menuSecondaryColor
                            ),
                            child: const Icon(Icons.arrow_back_ios_new, color: blackColor, size: 20,),
                          ),
                        ) : Container(),
                        Text(
                          'அதிகாரம் - $currentChapterIndex',
                          style: GoogleFonts.roboto(
                            fontSize: size.height * 0.02,
                            color: textHeadColor,
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
                                color: menuSecondaryColor
                            ),
                            child: const Icon(Icons.arrow_forward_ios, color: blackColor, size: 20,),
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
                                            fontSize: size.height * 0.018,
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
                                                    fontSize: size.height * 0.018,
                                                    color: valueColor,
                                                    fontWeight: FontWeight.w500,
                                                  ),
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
