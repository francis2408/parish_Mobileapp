import 'package:flutter/material.dart';
import 'package:perambur/widget/theme_color/theme_color.dart';
import 'package:photo_view/photo_view.dart';

class PublicImageViewScreen extends StatefulWidget {
  final List images;
  final int initialIndex;
  const PublicImageViewScreen({Key? key, required this.images, required this.initialIndex,}) : super(key: key);

  @override
  State<PublicImageViewScreen> createState() => _ImageViewScreenState();
}

class _ImageViewScreenState extends State<PublicImageViewScreen> {
  late PageController _pageController;
  late int _currentIndex;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
    _pageController = PageController(initialPage: widget.initialIndex);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Scaffold(
      backgroundColor: blackColor,
      appBar: AppBar(
        backgroundColor: primaryColor,
        title: Text(
          'Image View',
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
          alignment: Alignment.center,
          children: [
            PageView.builder(
              controller: _pageController,
              itemCount: widget.images.length,
              onPageChanged: (index) {
                setState(() {
                  _currentIndex = index;
                });
              },
              itemBuilder: (context, index) {
                return widget.images[index]['image'] != null && widget.images[index]['image'] != "" ? PhotoView(
                  imageProvider: NetworkImage(widget.images[index]['image']),
                  minScale: PhotoViewComputedScale.contained,
                  maxScale: PhotoViewComputedScale.covered * 2,
                ) : Image.asset(
                  'assets/images/no_image.jpg',
                  fit: BoxFit.contain,
                );
              },
            ),
            Positioned(
              top: 10,
              child: Row(
                children: [
                  Text(
                    widget.images[_currentIndex]['name'],
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: size.height * 0.02,
                    ),
                  ),
                  SizedBox(
                    width: size.width * 0.05,
                  ),
                  Text(
                    widget.images[_currentIndex]['date'],
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: size.height * 0.02,
                    ),
                  ),
                ],
              ),
            ),
            _currentIndex > 0 ? Positioned(
              left: 10,
              top: size.height / 2,
              child: GestureDetector(
                onTap: () {
                  if (_currentIndex > 0) {
                    _pageController.animateToPage(
                      _currentIndex - 1,
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeInOut,
                    );
                  }
                },
                child: Container(
                  padding: const EdgeInsets.all(3),
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(5),
                      color: Colors.white60
                  ),
                  child: const Icon(Icons.arrow_back_ios_new, color: Colors.black, size: 20,),
                ),
              ),
            ) : Positioned(child: Container()),
            _currentIndex < widget.images.length - 1 ? Positioned(
              right: 10,
              top: MediaQuery.of(context).size.height / 2,
              child: GestureDetector(
                onTap: () {
                  if (_currentIndex < widget.images.length - 1) {
                    _pageController.animateToPage(
                      _currentIndex + 1,
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeInOut,
                    );
                  }
                },
                child: Container(
                  padding: const EdgeInsets.all(3),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(5),
                    color: Colors.white60
                  ),
                  child: const Icon(Icons.arrow_forward_ios, color: Colors.black, size: 20,),
                ),
              ),
            ) : Positioned(child: Container()),
          ],
        ),
      ),
    );
  }
}
