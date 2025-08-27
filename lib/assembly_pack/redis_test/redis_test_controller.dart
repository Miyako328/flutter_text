import 'package:get/get.dart';
import 'package:redis/redis.dart';

class RedisTestController extends GetxController {
  final RedisConnection redisConn = RedisConnection();
  Command? res;
  
  RxBool isConnected = false.obs;
  RxBool isConnecting = false.obs;
  RxString connectionStatus = '未连接'.obs;
  RxString lastResult = ''.obs;
  RxString lastError = ''.obs;
  RxBool hasError = false.obs;
  
  final List<String> operationHistory = <String>[].obs;
  
  @override
  void onInit() {
    super.onInit();
    _init();
  }
  
  Future<void> _init() async {
    try {
      isConnecting.value = true;
      connectionStatus.value = '正在连接...';
      
      res = await redisConn.connect('localhost', 6379);
      
      isConnected.value = true;
      connectionStatus.value = '已连接';
      
      // 测试连接
      await _testConnection();
      
    } catch (e) {
      hasError.value = true;
      lastError.value = '连接失败: $e';
      connectionStatus.value = '连接失败';
      print('Redis connection error: $e');
    } finally {
      isConnecting.value = false;
    }
  }
  
  Future<void> _testConnection() async {
    try {
      if (res != null) {
        final test = await res!.get('qq_password');
        final setList = await res!.send_object(['smembers', 'setList']);
        final keys = await res!.send_object(['keys', '*']);
        
        lastResult.value = '测试结果:\n'
            'qq_password: $test\n'
            'setList: $setList\n'
            'keys: $keys';
        
        operationHistory.add('连接测试完成');
        
        print('Redis test results: $test, $setList, $keys');
      }
    } catch (e) {
      hasError.value = true;
      lastError.value = '测试失败: $e';
      print('Redis test error: $e');
    }
  }
  
  Future<void> setValue(String key, String value) async {
    try {
      if (res != null && isConnected.value) {
        final timestamp = DateTime.now().millisecondsSinceEpoch;
        final fullValue = '${value}_$timestamp';
        
        await res!.send_object(['set', key, fullValue]);
        
        lastResult.value = '设置成功: $key = $fullValue';
        operationHistory.add('设置 $key = $fullValue');
        
        print('Redis set: $key = $fullValue');
      } else {
        throw Exception('Redis未连接');
      }
    } catch (e) {
      hasError.value = true;
      lastError.value = '设置失败: $e';
      print('Redis set error: $e');
    }
  }
  
  Future<void> getValue(String key) async {
    try {
      if (res != null && isConnected.value) {
        final value = await res!.get(key);
        
        lastResult.value = '获取成功: $key = $value';
        operationHistory.add('获取 $key = $value');
        
        print('Redis get: $key = $value');
      } else {
        throw Exception('Redis未连接');
      }
    } catch (e) {
      hasError.value = true;
      lastError.value = '获取失败: $e';
      print('Redis get error: $e');
    }
  }
  
  Future<void> deleteKey(String key) async {
    try {
      if (res != null && isConnected.value) {
        final result = await res!.send_object(['del', key]);
        
        lastResult.value = '删除成功: $key (结果: $result)';
        operationHistory.add('删除 $key');
        
        print('Redis delete: $key, result: $result');
      } else {
        throw Exception('Redis未连接');
      }
    } catch (e) {
      hasError.value = true;
      lastError.value = '删除失败: $e';
      print('Redis delete error: $e');
    }
  }
  
  Future<void> getAllKeys() async {
    try {
      if (res != null && isConnected.value) {
        final keys = await res!.send_object(['keys', '*']);
        
        lastResult.value = '所有键: $keys';
        operationHistory.add('获取所有键');
        
        print('Redis keys: $keys');
      } else {
        throw Exception('Redis未连接');
      }
    } catch (e) {
      hasError.value = true;
      lastError.value = '获取键失败: $e';
      print('Redis keys error: $e');
    }
  }
  
  void clearHistory() {
    operationHistory.clear();
  }
  
  void clearError() {
    hasError.value = false;
    lastError.value = '';
  }
  
  void clearResult() {
    lastResult.value = '';
  }
  
  void resetConnection() {
    isConnected.value = false;
    connectionStatus.value = '未连接';
    lastResult.value = '';
    lastError.value = '';
    hasError.value = false;
    _init();
  }
  
  @override
  void onClose() {
    try {
      redisConn.close();
    } catch (e) {
      print('Error closing Redis connection: $e');
    }
    super.onClose();
  }
  
  bool get canOperate => isConnected.value && res != null;
  bool get isConnectingState => isConnecting.value;
  String get connectionInfo => 'Redis连接状态: ${connectionStatus.value}';
  int get operationCount => operationHistory.length;
}
