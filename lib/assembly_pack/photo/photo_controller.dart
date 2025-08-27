import 'package:get/get.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';

class PhotoController extends GetxController {
  final List<File> imageList = <File>[].obs;
  final ImagePicker picker = ImagePicker();
  
  RxBool isPickingImage = false.obs;
  RxString currentImagePath = ''.obs;
  RxInt selectedImageCount = 0.obs;
  
  @override
  void onInit() {
    super.onInit();
  }
  
  Future<void> getImage(int source) async {
    try {
      isPickingImage.value = true;
      final XFile? image = await picker.pickImage(
        source: source == 0 ? ImageSource.camera : ImageSource.gallery,
        maxWidth: 1800,
        maxHeight: 1800,
      );
      
      if (image != null) {
        final File imageFile = File(image.path);
        imageList.add(imageFile);
        currentImagePath.value = image.path;
        selectedImageCount.value = imageList.length;
      }
    } catch (e) {
      print('Error picking image: $e');
    } finally {
      isPickingImage.value = false;
    }
  }
  
  Future<void> getWechatPicker() async {
    try {
      isPickingImage.value = true;
      final List<XFile> images = await picker.pickMultiImage(
        maxWidth: 1800,
        maxHeight: 1800,
      );
      
      for (var image in images) {
        final File imageFile = File(image.path);
        imageList.add(imageFile);
      }
      
      selectedImageCount.value = imageList.length;
    } catch (e) {
      print('Error picking multiple images: $e');
    } finally {
      isPickingImage.value = false;
    }
  }
  
  void removeImage(int index) {
    if (index >= 0 && index < imageList.length) {
      imageList.removeAt(index);
      selectedImageCount.value = imageList.length;
    }
  }
  
  void clearAllImages() {
    imageList.clear();
    selectedImageCount.value = 0;
    currentImagePath.value = '';
  }
}
