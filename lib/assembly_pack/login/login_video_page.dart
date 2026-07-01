import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

class LoginVideoPage extends StatefulWidget {
  LoginVideoPageState createState() => LoginVideoPageState();
}

class LoginVideoPageState extends State<LoginVideoPage> {
  late VideoPlayerController _controller;

//  url  https://storage.googleapis.com/coverr-main/mp4%2FBlue%20Joy.mp4
//  https://storage.googleapis.com/coverr-main/mp4%2Fcoverr-cat-near-girl-1578597074865.mp4
  @override
  void initState() {
    super.initState();
    _controller = VideoPlayerController.network(
        'https://storage.googleapis.com/coverr-main/mp4%2FBlue%20Joy.mp4')
      ..initialize().then((_) {
        if (!mounted) {
          return;
        }
        setState(() {});
        _controller.play();
        _controller.setLooping(true);
      });
  }

  @override
  void dispose() {
    _controller.pause();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Stack(
      fit: StackFit.expand,
      children: <Widget>[
        Transform.scale(
          scale: _controller.value.aspectRatio /
              MediaQuery.of(context).size.aspectRatio,
          child: Center(
            child: Container(
              child: _controller.value.isInitialized
                  ? AspectRatio(
                      aspectRatio: _controller.value.aspectRatio,
                      child: VideoPlayer(_controller),
                    )
                  : const Center(
                      child: CircularProgressIndicator(),
                    ),
            ),
          ),
        ),
        Positioned(
          width: MediaQuery.of(context).size.width,
          bottom: 26.0,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              ClipRRect(
                borderRadius: BorderRadius.circular(60.0),
                child: MaterialButton(
                  onPressed: () {},
                  child: const Text(
                    "微信登录",
                    style: TextStyle(fontSize: 15.0),
                  ),
                  color: Color(0xffFFDB2E),
                  textColor: Color(0xff202326),
                  height: 44.0,
                  minWidth: 240.0,
                  elevation: 0.0,
                ),
              ),
              const SizedBox(
                height: 20.0,
              ),
              ClipRRect(
                borderRadius: BorderRadius.circular(60.0),
                child: MaterialButton(
                  onPressed: () {},
                  child: const Text(
                    "手机号登录",
                    style: TextStyle(fontSize: 15.0),
                  ),
                  color: Color(0xff202326),
                  height: 44.0,
                  minWidth: 240.0,
                  elevation: 0.0,
                  textColor: Color(0xffededed),
                ),
              ),
              const SizedBox(
                height: 60.0,
              ),
              const Text(
                "我已阅读并同意《服务协议》及《隐私政策》",
                style: TextStyle(color: Colors.white, fontSize: 13.0),
              )
            ],
          ),
        ),
        Positioned(
          width: MediaQuery.of(context).size.width,
          top: 80.0,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: const <Widget>[
              Text(
                "登录",
                style: TextStyle(
                    fontSize: 40.0,
                    fontWeight: FontWeight.w400,
                    color: Colors.white),
              ),
              SizedBox(
                height: 10.0,
              ),
              Text(
                "Welcome to Login",
                style: TextStyle(color: Colors.white, fontSize: 15.0),
              )
            ],
          ),
        )
      ],
    ));
  }
}
