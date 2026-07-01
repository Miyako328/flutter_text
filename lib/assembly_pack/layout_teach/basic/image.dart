import 'package:flutter/material.dart';
import 'package:self_utils/widget/popup_widget.dart';

class BasicImgPage extends StatefulWidget {
  const BasicImgPage({super.key});

  @override
  State<BasicImgPage> createState() => _BasicImgPageState();
}

class _BasicImgPageState extends State<BasicImgPage> {
  static const AssetImage img = AssetImage('assets/images/sun.jpg');

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        PopupTextAndExText(
          showText: 'fill：会拉伸填充满显示空间，图片本身长宽比会发生变化，图片会变形。'
              'cover：会按图片的长宽比放大后居中填满显示空间，图片不会变形，超出显示空间部分会被剪裁。'
              'contain：这是图片的默认适应规则，图片会在保证图片本身长宽比不变的情况下缩放以适应当前显示空间，图片不会变形。'
              'none：图片没有适应策略，会在显示空间内显示图片，如果图片比显示空间大，则显示空间只会显示图片中间部分。',
          builderWidget: Row(
            children: const <Image>[
              Image(
                image: img,
                height: 50.0,
                width: 100.0,
                fit: BoxFit.fill,
              ),
              Image(
                image: img,
                height: 50,
                width: 50.0,
                fit: BoxFit.contain,
              ),
              Image(
                image: img,
                width: 100.0,
                height: 50.0,
                fit: BoxFit.cover,
              ),
            ].map((e) {
              return Row(
                children: <Widget>[
                  Padding(
                    padding: EdgeInsets.all(16.0),
                    child: SizedBox(
                      width: 100,
                      child: e,
                    ),
                  ),
                  Text(e.fit.toString())
                ],
              );
            }).toList(),
          ),
        ),
        PopupTextAndExText(
            showText:
                'fitWidth：图片的宽度会缩放到显示空间的宽度，高度会按比例缩放，然后居中显示，图片不会变形，超出显示空间部分会被剪裁。'
                'fitHeight：图片的高度会缩放到显示空间的高度，宽度会按比例缩放，然后居中显示，图片不会变形，超出显示空间部分会被剪裁。',
            builderWidget: Row(
              children: const <Image>[
                Image(
                  image: img,
                  width: 100.0,
                  height: 50.0,
                  fit: BoxFit.fitWidth,
                ),
                Image(
                  image: img,
                  width: 100.0,
                  height: 50.0,
                  fit: BoxFit.fitHeight,
                ),
                Image(
                  image: img,
                  width: 100.0,
                  height: 50.0,
                  fit: BoxFit.scaleDown,
                ),
              ].map((e) {
                return Row(
                  children: <Widget>[
                    Padding(
                      padding: EdgeInsets.all(16.0),
                      child: SizedBox(
                        width: 100,
                        child: e,
                      ),
                    ),
                    Text(e.fit.toString())
                  ],
                );
              }).toList(),
            )),
        PopupTextAndExText(
          showText: '',
          builderWidget: Row(
            children: const <Image>[
              Image(
                image: img,
                height: 50.0,
                width: 100.0,
                fit: BoxFit.none,
              ),
              Image(
                image: img,
                width: 100.0,
                color: Colors.blue,
                colorBlendMode: BlendMode.difference,
                fit: BoxFit.fill,
              ),
              Image(
                image: img,
                width: 100.0,
                height: 200.0,
                repeat: ImageRepeat.repeatY,
              )
            ].map((e) {
              return Row(
                children: <Widget>[
                  Padding(
                    padding: EdgeInsets.all(16.0),
                    child: SizedBox(
                      width: 100,
                      child: e,
                    ),
                  ),
                  Text(e.fit.toString())
                ],
              );
            }).toList(),
          ),
        ),
      ],
    );
  }
}
