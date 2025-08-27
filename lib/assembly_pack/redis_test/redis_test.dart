import 'package:self_utils/utils/datetime_utils.dart';

import '/../init.dart';
import 'package:redis/redis.dart';

class RedisTest extends StatefulWidget {
  const RedisTest({Key? key}) : super(key: key);

  @override
  State<RedisTest> createState() => _RedisTestState();
}

class _RedisTestState extends State<RedisTest> {
  final RedisConnection redisConn = RedisConnection();
  late Command res;

  @override
  void initState() {
    super.initState();
    _init();
  }

  Future<void> _init() async {
    res = await redisConn.connect('localhost', 6379);
    final test = await res.get('qq_password');
    final setList = await res.send_object(['smembers', 'setList']);
    final keys = await res.send_object(['keys', '*']);
    Log.info('$test');
    Log.info('$setList');
    Log.info('$keys');
  }

  @override
  void dispose() {
    redisConn.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('redis测试'),
      ),
      body: Container(
        child: Center(
          child: ElevatedButton(
            onPressed: () {
              res.send_object([
                'set',
                'flutter',
                'flutter_value_${DateTimeHelper.getLocalTimeStamp()}'
              ]);
            },
            child: const Text('set'),
          ),
        ),
      ),
    );
  }
}
