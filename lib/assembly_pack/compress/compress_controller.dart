import 'package:get/get.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';

class CompressController extends GetxController {
  final ImagePicker _picker = ImagePicker();

  Rx<File?> originalFile = Rx<File?>(null);
  Rx<File?> compressedFile = Rx<File?>(null);
  RxInt originalWidth = 0.obs;
  RxInt originalHeight = 0.obs;
  RxInt compressedWidth = 0.obs;
  RxInt compressedHeight = 0.obs;
  RxString originalFileSizeText = '0 KB'.obs;
  RxString compressedFileSizeText = '0 KB'.obs;

  RxBool isLoading = false.obs;
  RxBool isCompressing = false.obs;
  RxString statusMessage = '准备就绪'.obs;
  RxDouble compressionRatio = 0.0.obs;
  RxDouble quality = 0.8.obs;

  final List<String> compressionHistory = <String>[].obs;

  @override
  void onInit() {
    super.onInit();
    _initializeController();
  }

  void _initializeController() {
    try {
      statusMessage.value = '压缩控制器已初始化';
      _logAction('控制器初始化');
    } catch (e) {
      statusMessage.value = '控制器初始化失败: $e';
      print('Controller initialization error: $e');
    }
  }

  Future<void> getImage() async {
    try {
      isLoading.value = true;
      statusMessage.value = '正在选择图片...';

      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1024.0,
        maxHeight: 1024.0,
      );

      if (image != null) {
        final File imageFile = File(image.path);
        originalFile.value = imageFile;
        compressedFile.value = null;
        originalFileSizeText.value = await _formatFileSize(imageFile);
        compressedFileSizeText.value = '0 KB';

        // 获取图片尺寸
        await _getImageDimensions(imageFile);

        statusMessage.value = '图片选择成功';
        _logAction('选择图片: ${image.path}');
      } else {
        statusMessage.value = '未选择图片';
      }
    } catch (e) {
      statusMessage.value = '选择图片失败: $e';
      print('Get image error: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> _getImageDimensions(File file) async {
    try {
      // 模拟获取图片尺寸
      final random = DateTime.now().millisecondsSinceEpoch;
      originalWidth.value = 800 + (random % 400);
      originalHeight.value = 600 + (random % 300);

      print(
          'Image dimensions: ${originalWidth.value} x ${originalHeight.value}');
    } catch (e) {
      print('Get image dimensions error: $e');
      originalWidth.value = 0;
      originalHeight.value = 0;
    }
  }

  Future<void> compressImage() async {
    if (originalFile.value == null) {
      statusMessage.value = '请先选择图片';
      return;
    }

    try {
      isCompressing.value = true;
      statusMessage.value = '正在压缩图片...';

      // 模拟压缩过程
      await Future.delayed(Duration(seconds: 2));

      // 模拟压缩后的文件
      final compressedPath = '${originalFile.value!.path}_compressed';
      compressedFile.value = File(compressedPath);
      compressedFileSizeText.value =
          await _formatFileSize(compressedFile.value!);

      // 模拟压缩后的尺寸
      compressedWidth.value = (originalWidth.value * quality.value).round();
      compressedHeight.value = (originalHeight.value * quality.value).round();

      // 计算压缩比
      _calculateCompressionRatio();

      statusMessage.value = '图片压缩完成';
      _logAction(
          '压缩图片: 压缩比 ${(compressionRatio.value * 100).toStringAsFixed(1)}%');
    } catch (e) {
      statusMessage.value = '图片压缩失败: $e';
      print('Compress image error: $e');
    } finally {
      isCompressing.value = false;
    }
  }

  void _calculateCompressionRatio() {
    if (originalFile.value != null && compressedFile.value != null) {
      // 模拟压缩比计算
      final random = DateTime.now().millisecondsSinceEpoch;
      compressionRatio.value = 0.3 + (random % 50) / 100; // 30%-80%
    }
  }

  void setQuality(double newQuality) {
    if (newQuality >= 0.1 && newQuality <= 1.0) {
      quality.value = newQuality;
      statusMessage.value = '质量已设置为: ${(newQuality * 100).toStringAsFixed(0)}%';
      _logAction('设置质量: ${(newQuality * 100).toStringAsFixed(0)}%');
    } else {
      statusMessage.value = '质量值必须在10%-100%之间';
    }
  }

  void clearFiles() {
    originalFile.value = null;
    compressedFile.value = null;
    originalWidth.value = 0;
    originalHeight.value = 0;
    compressedWidth.value = 0;
    compressedHeight.value = 0;
    originalFileSizeText.value = '0 KB';
    compressedFileSizeText.value = '0 KB';
    compressionRatio.value = 0.0;
    statusMessage.value = '文件已清除';
    _logAction('清除文件');
  }

  void clearHistory() {
    compressionHistory.clear();
    statusMessage.value = '历史记录已清除';
  }

  void _logAction(String action) {
    final timestamp = DateTime.now().toString();
    final logEntry = '$timestamp: $action';
    compressionHistory.add(logEntry);

    // 保持历史记录在合理范围内
    if (compressionHistory.length > 100) {
      compressionHistory.removeAt(0);
    }
  }

  Future<void> compressWithCustomSettings({
    double? customQuality,
    int? maxWidth,
    int? maxHeight,
  }) async {
    if (originalFile.value == null) {
      statusMessage.value = '请先选择图片';
      return;
    }

    try {
      isCompressing.value = true;
      statusMessage.value = '正在使用自定义设置压缩...';

      // 应用自定义设置
      if (customQuality != null) quality.value = customQuality;

      await Future.delayed(Duration(seconds: 3));

      // 模拟压缩
      final compressedPath = '${originalFile.value!.path}_custom_compressed';
      compressedFile.value = File(compressedPath);
      compressedFileSizeText.value =
          await _formatFileSize(compressedFile.value!);

      // 应用尺寸限制
      if (maxWidth != null && maxHeight != null) {
        compressedWidth.value = maxWidth;
        compressedHeight.value = maxHeight;
      } else {
        compressedWidth.value = (originalWidth.value * quality.value).round();
        compressedHeight.value = (originalHeight.value * quality.value).round();
      }

      _calculateCompressionRatio();

      statusMessage.value = '自定义压缩完成';
      _logAction(
          '自定义压缩: 质量${(quality.value * 100).toStringAsFixed(0)}%, 尺寸${compressedWidth.value}x${compressedHeight.value}');
    } catch (e) {
      statusMessage.value = '自定义压缩失败: $e';
      print('Custom compress error: $e');
    } finally {
      isCompressing.value = false;
    }
  }

  void batchCompress() {
    if (originalFile.value == null) {
      statusMessage.value = '请先选择图片';
      return;
    }

    try {
      statusMessage.value = '开始批量压缩...';
      _logAction('开始批量压缩');

      // 模拟批量压缩不同质量
      final qualities = [0.9, 0.7, 0.5, 0.3];
      for (int i = 0; i < qualities.length; i++) {
        Future.delayed(Duration(seconds: i), () {
          setQuality(qualities[i]);
          compressImage();
        });
      }
    } catch (e) {
      statusMessage.value = '批量压缩失败: $e';
      print('Batch compress error: $e');
    }
  }

  void resetSettings() {
    quality.value = 0.8;
    statusMessage.value = '设置已重置';
    _logAction('重置设置');
  }

  @override
  void onClose() {
    originalFile.value = null;
    compressedFile.value = null;
    super.onClose();
  }

  Future<String> _formatFileSize(File file) async {
    try {
      if (!await file.exists()) {
        return '未知';
      }
      final int bytes = await file.length();
      return '${(bytes / 1024).toStringAsFixed(2)} KB';
    } catch (e) {
      return '未知';
    }
  }

  bool get hasOriginalFile => originalFile.value != null;
  bool get hasCompressedFile => compressedFile.value != null;
  bool get canCompress => hasOriginalFile && !isCompressing.value;
  bool get hasCompressionHistory => compressionHistory.isNotEmpty;

  String get originalFileSize => originalFileSizeText.value;

  String get compressedFileSize => compressedFileSizeText.value;

  String get originalDimensions =>
      '${originalWidth.value} x ${originalHeight.value}';
  String get compressedDimensions =>
      '${compressedWidth.value} x ${compressedHeight.value}';
  String get compressionInfo =>
      '压缩比: ${(compressionRatio.value * 100).toStringAsFixed(1)}%';
  String get qualityInfo => '质量: ${(quality.value * 100).toStringAsFixed(0)}%';
  int get historyCount => compressionHistory.length;
}
