import 'package:flutter/material.dart';
import 'package:photo_view/photo_view.dart';
import 'package:photo_view/photo_view_gallery.dart';

//图片放大的插件
class ImageZoomable extends StatefulWidget {
  final List<ImageProvider> photoList;
  final int index;

  const ImageZoomable({required this.photoList, required this.index});

  @override
  _ImageZoomableState createState() => _ImageZoomableState();
}

class _ImageZoomableState extends State<ImageZoomable> {
  @override
  int currentIndex = 0;
  late int initialIndex; //初始index
  late int length;
  late int title;

  @override
  void initState() {
    currentIndex = widget.index;
    initialIndex = widget.index;
    length = widget.photoList.length;
    title = initialIndex + 1;
    super.initState();
  }

  void onPageChanged(int index) {
    setState(() {
      currentIndex = index;
      title = index + 1;
    });
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
        child: Scaffold(
          appBar: AppBar(
            title: Text('${title} / ${length}'),
            centerTitle: true,
          ),
          body: GestureDetector(
            onTap: () {
              Navigator.of(context).pop();
            },
            child: Container(
                decoration: const BoxDecoration(
                  color: Colors.black,
                ),
                constraints: BoxConstraints.expand(
                  height: MediaQuery.of(context).size.height,
                ),
                child: Stack(
                  alignment: Alignment.bottomRight,
                  children: <Widget>[
                    PhotoViewGallery.builder(
                      scrollDirection: Axis.horizontal,
                      scrollPhysics: const BouncingScrollPhysics(),
                      builder: (BuildContext context, int index) {
                        return PhotoViewGalleryPageOptions(
                          imageProvider: widget.photoList[index],
                          initialScale: PhotoViewComputedScale.contained * 1,
                        );
                      },
                      itemCount: widget.photoList.length,
                      // loadingChild: widget.loadingChild,
                      backgroundDecoration: const BoxDecoration(
                        color: Colors.black,
                      ),
                      pageController: PageController(initialPage: initialIndex),
                      //点进去哪页默认就显示哪一页
                      onPageChanged: onPageChanged,
                    ),
                    Container(
                      padding: const EdgeInsets.all(10.0),
                      child: Text(
                        'Image ${currentIndex + 1}',
                        style: const TextStyle(
                            color: Colors.white,
                            fontSize: 17.0,
                            decoration: null),
                      ),
                    )
                  ],
                )),
          ),
        ),
        onWillPop: () async {
          return false;
        });
  }
}
