import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:loading_indicator/loading_indicator.dart';
import 'package:munchirai/private/screens/bible/bible_repository.dart';
import 'package:munchirai/widget/common/common.dart';
import 'package:munchirai/widget/common/internet_connection_checker.dart';
import 'package:munchirai/widget/common/slide_animations.dart';
import 'package:munchirai/widget/theme_color/theme_color.dart';
import 'package:munchirai/widget/widget.dart';

import 'chapter_detail.dart';

class OldTestamentScreen extends StatefulWidget {
  const OldTestamentScreen({Key? key}) : super(key: key);

  @override
  State<OldTestamentScreen> createState() => _OldTestamentScreenState();
}

class _OldTestamentScreenState extends State<OldTestamentScreen> {
  bool _isLoading = true;
  List books = [];
  List bibleText = [];
  Set<int> addedIds = {};

  int selected = -1;
  bool isCategoryExpanded = false;

  void loadDataWithDelay() {
    Future.delayed(const Duration(seconds: 1), () {
      getOldTestamentData();
    });
  }

  getOldTestamentData() async {
    final text = await rootBundle.loadString('assets/bible/kjv.json');
    Map<String, dynamic> data = json.decode(text);
    bibleText = data['resultset']['row'];
    for (int i = 0; i < bibleText.length; i++) {
      int id = bibleText[i]['field'][1];

      // Check if the id has already been added to the set
      if (!addedIds.contains(id)) {
        // If not, add the id to the set and create the book object
        addedIds.add(id);
        books.add({
          "id": id,
          "name": BibleRepository().mapOfBibleBooks[id],
          "testament": id >= 40 ? "New" : "Old",
        });
      }
    }
    setState(() {
      _isLoading = false;
    });
    return books;
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
    return Scaffold(
      backgroundColor: screenBackgroundColor,
      body: SafeArea(
        child: _isLoading ? Center(
          child: SizedBox(
            height: size.height * 0.06,
            child: const LoadingIndicator(
              indicatorType: Indicator.ballSpinFadeLoader,
              colors: [Colors.red,Colors.orange,Colors.yellow,Colors.green,Colors.blue,Colors.indigo,Colors.purple,],
            ),
          ),
        ) : books.isNotEmpty ? SingleChildScrollView(
          child: SlideFadeAnimation(
            duration: const Duration(seconds: 1),
            child: ListView.builder(
              key: Key('builder ${selected.toString()}'),
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: 39,
              itemBuilder: (BuildContext context, int index) {
                return Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Theme(
                      data: Theme.of(context).copyWith(
                        listTileTheme: ListTileTheme.of(context)
                            .copyWith(dense: true, minVerticalPadding: 1),
                      ),
                      child: ExpansionTile(
                        key: Key(index.toString()),
                        initiallyExpanded: index == selected,
                        backgroundColor: Colors.white,
                        iconColor: iconColor,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15.0),
                        ),
                        onExpansionChanged: (newState) {
                          if (newState) {
                            setState(() {
                              selected = index;
                              isCategoryExpanded = true;

                              Set<int> uniqueChapterIds = {};
                              chapter = [];
                              for (int i = 0; i < bibleText.length; i++) {
                                if(books[index]['id'] == bibleText[i]['field'][1]) {
                                  int chapterId = bibleText[i]['field'][2];
                                  if (!uniqueChapterIds.contains(chapterId)) {
                                    uniqueChapterIds.add(chapterId);
                                    chapter.add({"id": chapterId});
                                  }
                                }
                              }
                            });
                          } else {
                            setState(() {
                              selected = -1;
                              isCategoryExpanded = false;
                              chapter = [];
                            });
                          }
                        },
                        title: Text(
                          '${books[index]['name']}',
                          style: GoogleFonts.roboto(
                            fontSize: size.height * 0.02,
                            color: expandColor,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        children: [
                          chapter.isNotEmpty ? GridView.count(
                            shrinkWrap: true,
                            crossAxisCount: 8,
                            physics: const NeverScrollableScrollPhysics(),
                            children: List.generate(chapter.length, (indexs) => Padding(
                              padding: const EdgeInsets.all(8),
                              child: GestureDetector(
                                onTap: () async {
                                  bookId = books[index]['id'];
                                  bookName = books[index]['name'];
                                  chapterId = chapter[indexs]['id'];
                                  await Navigator.push(context, MaterialPageRoute(builder: (context) => const ChapterDetailsScreen()));
                                },
                                child: Container(
                                  alignment: Alignment.center,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(5),
                                    color: menuPrimaryColor,
                                  ),
                                  child: Text(
                                    chapter[indexs]['id'].toString(),
                                    style: GoogleFonts.roboto(
                                      fontSize: size.height * 0.02,
                                      color: whiteColor,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ),
                            )),
                          ) : Center(
                            child: Container(
                              alignment: Alignment.center,
                              padding: const EdgeInsets.only(left: 30, right: 30, bottom: 10),
                              child: const Text(
                                'No Data available',
                                style: TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black54
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Divider()
                  ],
                );
              },
            ),
          ),
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
        ),
      ),
    );
  }
}
