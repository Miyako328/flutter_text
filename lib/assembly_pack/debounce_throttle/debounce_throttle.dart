import 'package:flutter_text/init.dart';

class DebounceTPage extends StatefulWidget {
  @override
  _DebounceTState createState() => _DebounceTState();
}

class _DebounceTState extends State<DebounceTPage> {
  int normal = 0;
  int debounce = 0;
  int throttle = 0;

  Timer? _timer;
  bool canAction = true;

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: GlobalStore.isMobile ? AppBar(
        title: const Text('防抖和节流'),
      ):null,
      body: Container(
        child: Center(
          child: Column(
            children: [
              TextButton(
                onPressed: () {
                  setState(() {
                    normal++;
                  });
                },
                child: Text('基础 $normal'),
              ),
              // 防抖
              TextButton(
                onPressed: () {
                  Utils.debounce(
                    () => setState(() {
                      debounce++;
                    }),
                    delay: const Duration(milliseconds: 2000),
                  );
                },
                child: Text('防抖 $debounce'),
              ),
              // 节流
              TextButton(
                onPressed: () async {
                  if (!canAction) return;
                  setState(() {
                    canAction = false;
                  });
                  await Future<void>.delayed(
                      const Duration(milliseconds: 2000));
                  throttle++;
                  canAction = true;
                  setState(() {});
                },
                child: Text('节流 $throttle'),
              ),

            ],
          ),
        ),
      ),
    );
  }
}
