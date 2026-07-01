import '../init.dart';

class PlaneIsland extends StatefulWidget {
  final Widget child;

  const PlaneIsland({
    required this.child,
    Key? key,
  }) : super(key: key);

  @override
  State<PlaneIsland> createState() => _PlaneIslandState();
}

class _PlaneIslandState extends State<PlaneIsland>
    with SingleTickerProviderStateMixin {
  AnimationController? _controller;
  double _left = -50;
  bool _changeDirection = false;

  @override
  void initState() {
    super.initState();
    if (Platform.isIOS == true)
      WidgetsBinding.instance.addPostFrameCallback((Duration timeStamp) {
        if (!mounted) {
          return;
        }
        _controller = AnimationController(
            vsync: this,
            duration: const Duration(seconds: 5),
            lowerBound: -50,
            upperBound: 50)
          ..addStatusListener((AnimationStatus status) {
            if (status == AnimationStatus.completed) {
              _controller?.reverse();
              _changeDirection = !_changeDirection;
            } else if (status == AnimationStatus.dismissed) {
              _controller?.forward();
              _changeDirection = !_changeDirection;
            }
          })
          ..addListener(() {
            _left = _controller?.value ?? _left;
          });
        _controller?.forward();
        setState(() {});
      });
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Platform.isIOS
        ? Stack(
            children: <Widget>[
              widget.child,
              Positioned(
                top: 1,
                left: 0,
                right: 0,
                child: Align(
                  alignment: Alignment.topLeft,
                  child: Image.asset(
                    "assets/images/cloud5.gif",
                    width: MediaQuery.of(context).size.width,
                    height: 10,
                  ),
                ),
              ),
              Positioned(
                top: 1,
                left: -20,
                right: 0,
                child: Align(
                  alignment: Alignment.topLeft,
                  child: Image.asset(
                    "assets/images/cloud5.gif",
                    width: MediaQuery.of(context).size.width,
                    height: 10,
                  ),
                ),
              ),
              Positioned(
                top: 1,
                left: -40,
                right: 0,
                child: Align(
                  alignment: Alignment.topLeft,
                  child: Image.asset(
                    "assets/images/cloud5.gif",
                    width: MediaQuery.of(context).size.width,
                    height: 10,
                  ),
                ),
              ),
              Positioned(
                top: 1,
                left: 40,
                right: 0,
                child: Align(
                  alignment: Alignment.topLeft,
                  child: Image.asset(
                    "assets/images/cloud5.gif",
                    width: MediaQuery.of(context).size.width,
                    height: 10,
                  ),
                ),
              ),
              Positioned(
                top: 1,
                left: 80,
                right: 0,
                child: Align(
                  alignment: Alignment.topLeft,
                  child: Image.asset(
                    "assets/images/cloud5.gif",
                    width: MediaQuery.of(context).size.width,
                    height: 10,
                  ),
                ),
              ),
              Positioned(
                top: 1,
                left: _left,
                right: 0,
                child: Container(
                  width: 10,
                  height: 10,
                  child: Directionality(
                    textDirection: TextDirection.rtl,
                    child: Center(
                      child: Image.asset(
                        'assets/images/plane2.gif',
                        matchTextDirection: _changeDirection,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          )
        : widget.child;
  }
}
