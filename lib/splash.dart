import 'package:flutter_text/assembly_pack/management/utils/navigator.dart';

import 'index.dart';
import 'init.dart';

class SplashPage extends StatefulWidget {
  @override
  _SplashState createState() => _SplashState();
}

class _SplashState extends State<SplashPage> {
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    setTimer();
  }

  void setTimer() {
    _timer = Timer(const Duration(seconds: 5), () {
      toIndex();
    });
    setState(() {});
  }

  void toIndex() {
    LocateStorage.setBoolWithExpire(
      'SplashShow',
      true,
      const Duration(days: 1),
    );
    NavigatorUtils().pushWidget(
        context, GlobalStore.isMobile ? MainIndexPage() : ManagementPage(),
        replaceRoot: true, type: AnimateType.Fade);
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: <Widget>[
          Container(
            width: double.infinity,
            height: double.infinity,
            child: Center(
              child: Image.asset(
                'assets/images/plane2.gif',
                width: 60,
              ),
            ),
          ),
          Positioned(
            right: screenUtil.adaptive(50),
            bottom: screenUtil.adaptive(100),
            child: Container(
              width: screenUtil.adaptive(100),
              height: screenUtil.adaptive(100),
              decoration: BoxDecoration(
                color: Colors.black26,
                borderRadius: BorderRadius.circular(screenUtil.adaptive(100)),
              ),
              child: InkWell(
                onTap: () {
                  toIndex();
                },
                child: Center(
                  child: Text(
                    '跳过',
                    style: TextStyle(
                      color: const Color(0xffffffff),
                      fontSize: screenUtil.getAutoSp(28),
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
