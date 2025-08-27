import 'dart:convert';
import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_background/flutter_background.dart';
import 'package:flutter_text/global/global.dart';
import 'package:flutter_text/init.dart';
import 'package:flutter_text/model/rate_point.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:flutter/gestures.dart';

import 'canvas_paint.dart';
import 'signaling.dart';

class ConnectionPage extends StatefulWidget {
  const ConnectionPage({super.key});

  @override
  State<ConnectionPage> createState() => _ConnectionPageState();
}

class _ConnectionPageState extends State<ConnectionPage> {
  static const methodChannel = const MethodChannel('mChannel');
  GlobalKey<FormState> _key = GlobalKey<FormState>();

  GlobalKey _reKey = GlobalKey();
  List<dynamic> _peers = [];
  Signaling? _signaling;
  String? _selfId;
  RTCVideoRenderer _localRenderer = RTCVideoRenderer();
  RTCVideoRenderer _remoteRenderer = RTCVideoRenderer();
  bool _inCalling = false; // 连接
  bool _isRemoting = false; // 控制端or受控端 client or remote_client
  Session? _session; // 连接session
  bool _waitAccept = false;
  bool isState = false; //

  RTCDataChannel? _dataChannel;
  String? text; //传输的数据

  String? connectId;
  bool _color = false;
  bool _color2 = false;
  bool _color3 = false;
  int count = 0;
  int count2 = 0;
  int count3 = 0;

  @override
  void initState() {
    super.initState();
    _check();
    _init();
  }

  void _check() async {
    if (WebRTC.platformIsAndroid) {
      final bool status = await methodChannel.invokeMethod(
          'check_permission', kActionAccessibilitySettings);
      if (!status) {
        await methodChannel.invokeMethod(
            'request_permission', kActionAccessibilitySettings);
      }

      // Android specific
      await requestBackgroundPermission();
    }
  }

  Future<void> requestBackgroundPermission([bool isRetry = false]) async {
    // Required for android screenshare.
    try {
      var hasPermissions = await FlutterBackground.hasPermissions;
      if (!isRetry) {
        const androidConfig = FlutterBackgroundAndroidConfig(
          notificationTitle: 'Screen Sharing',
          notificationText: 'LiveKit Example is sharing the screen.',
          notificationIcon: AndroidResource(
              name: 'livekit_ic_launcher', defType: 'mipmap'),
        );
        hasPermissions = await FlutterBackground.initialize(
            androidConfig: androidConfig);
      }
      if (hasPermissions &&
          !FlutterBackground.isBackgroundExecutionEnabled) {
        await FlutterBackground.enableBackgroundExecution();
      }
    } catch (e) {
      if (!isRetry) {
        return await Future<void>.delayed(const Duration(seconds: 1),
                () => requestBackgroundPermission(true));
      }
      print('could not publish video: $e');
    }
  }


  // 初始化 -- 连接服务端 -- 成功后获取并显示id和password -- 查看B设备的id和password -- 输入连接后获取b设备屏幕
  Future<void> _init() async {
    await _localRenderer.initialize();
    await _remoteRenderer.initialize();
    await _connect(context);
  }

  // 操作处理
  Future<void> _setScreenMotion(RTCDataChannelMessage data) async {
    try {
      text = data.text; // ？
      if (text != null) {
        final RatePoint point = RatePoint.fromJson(jsonDecode(text!));
        // 控制流控制
        if (WebRTC.platformIsAndroid) {
          var test = {
            'kind': point.kind,
            'x': point.dx,
            'y': point.dy,
          };
          if (point.kind == 'home' || point.kind == 'list') {
            await methodChannel.invokeMethod('physic_input', test);
          } else {
            await methodChannel.invokeMethod('touch_input', test);
          }
        }
      }
      setState(() {});
    } catch (err) {
      print(err);
      rethrow;
    }
  }

  // 连接服务端
  Future<void> _connect(BuildContext context) async {
    _signaling ??= Signaling(context)..connect();

    // 数据传输
    _signaling?.onDataChannelMessage = (_, dc, RTCDataChannelMessage data) {
      _setScreenMotion(data);
    };

    _signaling?.onDataChannel = (_, channel) {
      _dataChannel = channel;
      setState(() {});
    };

    _signaling?.onSignalingStateChange = (SignalingState state) {
      switch (state) {
        case SignalingState.ConnectionClosed:
        case SignalingState.ConnectionError:
        case SignalingState.ConnectionOpen:
          break;
      }
    };

    // 处理各种state
    _signaling?.onCallStateChange = (Session session, CallState state) async {
      switch (state) {
        case CallState.CallStateNew:
          setState(() {
            _session = session;
          });
          break;
        case CallState.CallStateRinging:
        // 收到连接消息, 设置成自动连接，不用b设备确认。只需要确认密码即可
          _accept();
          if (_session != null && _session?.pid != _selfId) {
            setState(() {
              _isRemoting = true;
            });
          }
          break;
        case CallState.CallStateBye:
          if (_waitAccept) {
            _waitAccept = false;
          }
          setState(() {
            _localRenderer.srcObject = null;
            _remoteRenderer.srcObject = null;
            _inCalling = false;
            _isRemoting = false;
            _session = null;
          });
          break;
        case CallState.CallStateInvite:
          _waitAccept = true; // 等待连接中，
          break;
        case CallState.CallStateConnected:
          if (_waitAccept) {
            _waitAccept = false;
          }

          setState(() {
            _inCalling = true;
          });
          break;
      }
    };

    _signaling?.onPeersUpdate = ((event) {
      setState(() {
        _selfId = event['self'];
        _peers = event['peers']; //peers是服务端中存在的设备
      });
    });

    _signaling?.onLocalStream = ((stream) {
      _localRenderer.srcObject = stream;
      setState(() {});
    });

    _signaling?.onAddRemoteStream = ((_, stream) {
      _remoteRenderer.srcObject = stream;
      setState(() {});
    });

    _signaling?.onRemoveRemoteStream = ((_, stream) {
      _remoteRenderer.srcObject = null;
      setState(() {});
    });

    _signaling?.onInviteStream = ((val) {
      if (val['to'] == _selfId && val['form'] != null) {
        _signaling?.invite(val['form']!);
      }
    });
  }

  Future<void> _onDragEvent(Offset point) async {
    print('_onDragEvent: $point');
    final RatePoint msg = RatePoint('panUpdate', point.dx, point.dy);
    _dataChannel?.send(RTCDataChannelMessage(jsonEncode(msg)));
  }

  Future<void> _onDragEndEvent(Offset point) async {
    print('_onDragEndEvent: $point');
    final RatePoint msg = RatePoint('onTapUp', point.dx, point.dy);
    _dataChannel?.send(RTCDataChannelMessage(jsonEncode(msg)));
  }

  Future<void> _onTapDownEvent(Offset point) async {
    if (_dataChannel != null) {
      print('_onTapDownEvent: $point');
      final RatePoint msg = RatePoint('onTapDown', point.dx, point.dy);
      _dataChannel?.send(RTCDataChannelMessage(jsonEncode(msg)));
    }
  }

  Future<void> _onTapUpEvent(Offset point) async {
    if (_dataChannel != null) {
      print('_onTapUpEvent: $point');
      final msg = RatePoint('onTapUp', point.dx, point.dy);;
      _dataChannel?.send(RTCDataChannelMessage(jsonEncode(msg)));
    }
  }

  void _accept() {
    if (_session != null) {
      _signaling?.accept(_session!.sid);
    }
  }

  void _reject() {
    if (_session != null) {
      _signaling?.reject(_session!.sid);
    }
  }

  void _sendPhysicCol(String key) {
    if (key.isNotEmpty) {
      final msg = RatePoint(key, -1, -1);;
      _dataChannel?.send(RTCDataChannelMessage(jsonEncode(msg)));
    }
  }

  void _sendConnectMsg() {
    final FormState? form = _key.currentState;
    if (form != null && form.validate()) {
      form.save();
      if (connectId != null && connectId!.isNotEmpty) {
        if (_signaling != null && connectId != _selfId) {
          _signaling?.invite(connectId!);
        }
      } else {
        ToastUtils.showToast(msg: '请输入受控设备的ID');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: ((Platform.isAndroid || Platform.isIOS) && !_inCalling)
          ? AppBar(
        title: const Text('连接至远程设备'),
      )
          : null,
      body: _inCalling
          ? OrientationBuilder(builder: (context, orientation) {
        return Stack(
          children: [
            Positioned(
              top: 0,
              bottom: 0,
              child: Container(
                margin: EdgeInsets.fromLTRB(0.0, 0.0, 0.0, 0.0),
                width: MediaQuery.of(context).size.width,
                height: MediaQuery.of(context).size.height,
                decoration: BoxDecoration(color: Colors.black54),
                child: RTCVideoView(
                  _remoteRenderer,
                  key: _reKey,
                ),
              ),
            ),
            PaintRander(
              videoRenderer: _remoteRenderer,
              tapDownEventCallBack: _onTapDownEvent,
              tapUpEventCallBack: _onTapUpEvent,
              dragEndEventCallBack: _onDragEndEvent,
              dragEventCallBack: _onDragEvent,
            ),
          ],
        );
      })
          : Form(
        key: _key,
        child: SingleChildScrollView(
          child: Column(
            children: [
              const SizedBox(
                height: 20,
              ),
              Text('本地的id是：$_selfId'),
              const SizedBox(
                height: 20,
              ),
              _isRemoting
                  ? Column(
                children: [
                  Text('当前设备正在屏幕共享，控制者id为：${_session?.pid}'),
                  const SizedBox(
                    height: 10,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      GestureDetector(
                        onTap: () {
                          _color = !_color;
                          count++;
                          setState(() {});
                        },
                        child: Container(
                          color: _color
                              ? Colors.amberAccent
                              : Colors.blueAccent,
                          width: 100,
                          height: 50,
                          child: Text('$count'),
                        ),
                      ),
                      const SizedBox(
                        width: 20,
                      ),
                      GestureDetector(
                        onTap: () {
                          _color2 = !_color2;
                          count2++;
                          setState(() {});
                        },
                        child: Container(
                          color: _color2
                              ? Colors.cyan
                              : Colors.orangeAccent,
                          width: 100,
                          height: 50,
                          child: Text('$count2'),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  Text('$text'),
                ],
              )
                  : Column(
                children: [
                  Container(
                    margin: const EdgeInsets.only(
                        left: 30, right: 30),
                    child: TextFormField(
                      initialValue: connectId,
                      decoration: const InputDecoration(
                        hintText: '连接至',
                      ),
                      onSaved: (value) {
                        connectId = value;
                        setState(() {});
                      },
                    ),
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  Wrap(
                    children: [
                      ElevatedButton(
                        onPressed: () {
                          _sendConnectMsg();
                        },
                        child: const Text('link Start！'),
                      ),
                      const SizedBox(
                        width: 15,
                      ),
                    ],
                  )
                ],
              )
            ],
          ),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: _inCalling
          ? SizedBox(
          child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Row(
                  children: [
                    const SizedBox(width: 20,),
                    FloatingActionButton(
                      onPressed: () {
                        _sendPhysicCol('home');
                      },
                      tooltip: 'home',
                      child: const Icon(Icons.home_filled),
                      backgroundColor: Colors.pink,
                    ),
                    const SizedBox(width: 20,),
                    FloatingActionButton(
                      onPressed: () {
                        _sendPhysicCol('list');
                      },
                      tooltip: 'app_list',
                      child: const Icon(Icons.list_alt),
                      backgroundColor: Colors.pink,
                    ),
                  ],
                ),
                Row(
                  children: [
                    FloatingActionButton(
                      onPressed: _reject,
                      tooltip: 'Hangup',
                      child: const Icon(Icons.call_end),
                      backgroundColor: Colors.pink,
                    ),
                    const SizedBox(width: 20,)
                  ],
                )
              ]))
          : null,
    );
  }

  @override
  void deactivate() {
    super.deactivate();
    _signaling?.close();
    _localRenderer.dispose();
    _remoteRenderer.dispose();
  }
}
