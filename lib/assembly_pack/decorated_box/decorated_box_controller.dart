import 'package:get/get.dart';
import 'package:flutter/material.dart';

class DecoratedBoxController extends GetxController {
  Rx<DecorationPosition> decorationPosition = DecorationPosition.background.obs;
  Rx<Color> backgroundColor = Colors.grey.obs;
  Rx<Color> borderColor = Colors.white.obs;
  RxDouble borderWidth = 6.0.obs;
  Rx<BoxShape> boxShape = BoxShape.rectangle.obs;
  Rx<BoxFit> imageFit = BoxFit.cover.obs;
  RxString imagePath = 'assets/images/timg.jpg'.obs;
  RxString displayText = '定位演示'.obs;
  RxDouble fontSize = 30.0.obs;
  Rx<Color> textColor = Colors.black.obs;
  RxDouble containerWidth = 300.0.obs;
  RxDouble containerHeight = 300.0.obs;

  final List<Color> availableColors = [
    Colors.grey,
    Colors.blue,
    Colors.green,
    Colors.orange,
    Colors.purple,
    Colors.teal,
    Colors.indigo,
    Colors.pink,
    Colors.red,
    Colors.yellow,
  ];

  final List<Color> availableBorderColors = [
    Colors.white,
    Colors.black,
    Colors.red,
    Colors.blue,
    Colors.green,
    Colors.orange,
    Colors.purple,
  ];

  final List<String> availableImages = [
    'assets/images/timg.jpg',
    'assets/images/001.jpeg',
    'assets/images/002.jpg',
    'assets/images/_cat_sky.jpg',
  ];

  void changeDecorationPosition(DecorationPosition position) {
    decorationPosition.value = position;
  }

  void changeBackgroundColor(Color color) {
    backgroundColor.value = color;
  }

  void changeBorderColor(Color color) {
    borderColor.value = color;
  }

  void changeBorderWidth(double width) {
    borderWidth.value = width;
  }

  void changeBoxShape(BoxShape shape) {
    boxShape.value = shape;
  }

  void changeImageFit(BoxFit fit) {
    imageFit.value = fit;
  }

  void changeImagePath(String path) {
    imagePath.value = path;
  }

  void changeDisplayText(String text) {
    displayText.value = text;
  }

  void changeFontSize(double size) {
    fontSize.value = size;
  }

  void changeTextColor(Color color) {
    textColor.value = color;
  }

  void changeContainerSize(double width, double height) {
    containerWidth.value = width;
    containerHeight.value = height;
  }

  void cycleBackgroundColors() {
    final currentIndex = availableColors.indexOf(backgroundColor.value);
    final nextIndex = (currentIndex + 1) % availableColors.length;
    backgroundColor.value = availableColors[nextIndex];
  }

  void cycleBorderColors() {
    final currentIndex = availableBorderColors.indexOf(borderColor.value);
    final nextIndex = (currentIndex + 1) % availableBorderColors.length;
    borderColor.value = availableBorderColors[nextIndex];
  }

  void cycleImages() {
    final currentIndex = availableImages.indexOf(imagePath.value);
    final nextIndex = (currentIndex + 1) % availableImages.length;
    imagePath.value = availableImages[nextIndex];
  }

  void resetToDefaults() {
    decorationPosition.value = DecorationPosition.background;
    backgroundColor.value = Colors.grey;
    borderColor.value = Colors.white;
    borderWidth.value = 6.0;
    boxShape.value = BoxShape.rectangle;
    imageFit.value = BoxFit.cover;
    imagePath.value = 'assets/images/timg.jpg';
    displayText.value = '定位演示';
    fontSize.value = 30.0;
    textColor.value = Colors.black;
    containerWidth.value = 300.0;
    containerHeight.value = 300.0;
  }

  BoxDecoration get currentDecoration => BoxDecoration(
        color: backgroundColor.value,
        image: DecorationImage(
          fit: imageFit.value,
          image: ExactAssetImage(imagePath.value),
        ),
        border: Border.all(
          color: borderColor.value,
          width: borderWidth.value,
        ),
        shape: boxShape.value,
      );

  TextStyle get currentTextStyle => TextStyle(
        fontSize: fontSize.value,
        color: textColor.value,
      );
}
