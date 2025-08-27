import 'package:get/get.dart';
import 'package:shell/shell.dart';
import 'package:self_utils/utils/log_utils.dart';

class ShellTestController extends GetxController {
  final Shell shell = Shell();
  RxString outputMessage = ''.obs;
  RxBool isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    outputMessage.value = '准备就绪';
  }

  @override
  void onClose() {
    // Shell doesn't have a close method, just dispose
    super.onClose();
  }

  Future<void> runShellCommand() async {
    try {
      isLoading.value = true;
      outputMessage.value = '执行中...';
      
      final WrappedProcess find = await shell
          .start('find', arguments: ['/Users/lixuan/Documents/work']);
      final findString = await find.stdout.readAsString();
      
      outputMessage.value = '执行成功: ${findString.length} 字符';
      Log.info(findString);
    } catch (error, stack) {
      outputMessage.value = '执行失败: $error';
      Log.error('$stack $error');
    } finally {
      isLoading.value = false;
    }
  }

  void clearOutput() {
    outputMessage.value = '准备就绪';
  }
}
