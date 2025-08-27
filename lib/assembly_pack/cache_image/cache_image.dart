import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

//todo 等同于Image_widget
class CacheImagePage extends StatefulWidget {
  @override
  _CacheImageState createState() => _CacheImageState();
}

class _CacheImageState extends State<CacheImagePage> {

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('cache image page'),
      ),
      body: Container(
        child: Center(
          child: CachedNetworkImage(
            imageUrl: 'http://via.placeholder.com/200x150',
            progressIndicatorBuilder: (context, url, downloadProgress) =>
                CircularProgressIndicator(value: downloadProgress.progress),
            errorWidget: (BuildContext context, String url, error) => Icon(Icons.error),
          ),
        ),
      ),
    );
  }
}