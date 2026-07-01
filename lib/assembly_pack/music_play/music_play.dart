import 'dart:math';

import 'package:audioplayers/audioplayers.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_neumorphic_plus/flutter_neumorphic.dart';
import 'package:flutter_text/assembly_pack/controller_test/controller.dart';
import 'package:flutter_text/assembly_pack/management/utils/navigator.dart';
import 'package:flutter_text/assembly_pack/music_play/music_helper.dart';
import 'package:flutter_text/assembly_pack/music_play/music_model.dart';
import 'package:self_utils/utils/array_helper.dart';
import 'package:self_utils/utils/datetime_utils.dart';
import 'package:self_utils/utils/log_utils.dart';
import 'package:self_utils/utils/screen.dart';
import 'package:self_utils/utils/toast_utils.dart';
import 'package:self_utils/widget/api_call_back.dart';
import 'package:self_utils/widget/slide_panel_left.dart';

class MusicPlayPage extends StatefulWidget {
  @override
  _MusicPlayState createState() => _MusicPlayState();
}

class _MusicPlayState extends State<MusicPlayPage> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return NeumorphicTheme(child: _Page());
  }
}

class _Page extends StatefulWidget {
  @override
  _PageState createState() => _PageState();
}

class _PageState extends State<_Page> with TickerProviderStateMixin {
  AudioPlayer _audioPlayer = AudioPlayer();
  int? times;
  int? currentTime;

  PlayerState? _state; //播放状态
  PanelController panel = PanelController();
  List<MusicModel> _list = <MusicModel>[];
  MusicModel? currentMusic;
  int currentIndex = 0;

  late AnimationController _controller;
  PlayMode playState = PlayMode.normal;

  @override
  void initState() {
    super.initState();
    getMusicCacheList(init: true);
    animationListen();
  }

  // 转圈动画监听
  void animationListen() {
    _controller =
        AnimationController(vsync: this, duration: const Duration(seconds: 20));
    _controller.addStatusListener((AnimationStatus status) {
      if (status == AnimationStatus.completed) {
        print('status is completed');
        _controller.reset();
        _controller.forward();
      }
    });
    setState(() {});
  }

  void getMusicCacheList({bool init = false}) async {
    _list = await MusicCache.getAllCache();
    if (_list.isNotEmpty == true && init == true) {
      currentMusic = ArrayHelper.get(_list, 0)!;
      currentIndex = 0;
      setState(() {});
    }
  }

  // 上传
  void select() async {
    final FilePickerResult? result = await loadingCallback(
      () => FilePicker.platform.pickFiles(
        allowMultiple: false, //单选
        type: FileType.audio,
      ),
    );

    if (result != null) {
      if (result.isSinglePick == true) {
        currentMusic = await MusicHelper.setAppLocateFile(result);
        if (currentMusic != null) {
          play(currentMusic!.path!);
          setState(() {});
        }
      }
    }
    getMusicCacheList();
  }

  // 目前仅支持播放本地音乐
  void play(String path) async {
    await _audioPlayer.stop();
    _audioPlayer = AudioPlayer();
    await _audioPlayer.play(DeviceFileSource(path)).whenComplete(() {
      addAudioPlayListen();
      if (mounted) {
        _state = PlayerState.playing;
        _controller.forward();
        setState(() {});
      }
    });
  }

  // 监听
  void addAudioPlayListen() {
    _audioPlayer.onPlayerStateChanged.listen((PlayerState event) {
      Log.info('onPlayerStateChanged $event');
      _state = event;
      if (mounted) {
        setState(() {});
      }
      if (event == PlayerState.completed) {
        next(auto: true);
        _controller.stop();
      }
    });
    _audioPlayer.onDurationChanged.listen((Duration duration) {
      times = duration.inSeconds;
      if (mounted) {
        setState(() {});
      }
    });
    _audioPlayer.onPositionChanged.listen((event) {
      currentTime = event.inSeconds;
      if (mounted) {
        setState(() {});
      }
    });
  }

  //暂停
  void startOrPause() async {
    if (_state == null) {
      play(currentMusic!.path!);
      return;
    }
    if (_state == PlayerState.paused) {
      await _audioPlayer.resume();
      _controller.forward();
    } else {
      await _audioPlayer.pause();
      _controller.stop();
    }
  }

  //拖拽进度条
  void onSeekChange(int sec) async {
    await _audioPlayer.seek(Duration(seconds: sec));
  }

  //下一首
  void next({bool? auto}) {
    int index = currentIndex;
    if (playState == PlayMode.normal) {
      if (currentIndex == _list.length - 1) {
        _audioPlayer.pause();
        return;
      } else {
        index = currentIndex + 1;
      }
    } else if (playState == PlayMode.singleLoop) {
      if (auto != true) {
        if (currentIndex == _list.length - 1) {
          index = 0;
        } else {
          index = currentIndex + 1;
        }
      }
    } else if (playState == PlayMode.loop) {
      if (currentIndex == _list.length - 1) {
        index = 0;
      } else {
        index = currentIndex + 1;
      }
    } else if (playState == PlayMode.random) {
      index = Random().nextInt(_list.length) - 1;
    }
    currentMusic = ArrayHelper.get(_list, index)!;
    currentIndex = index;
    play(currentMusic!.path!);
    setState(() {});
  }

  //上一首
  void previous() {
    int index = currentIndex;
    if (currentIndex == 0) {
      index = _list.length - 1;
    } else {
      index = currentIndex - 1;
    }
    currentMusic = ArrayHelper.get(_list, index)!;
    currentIndex = index;
    play(currentMusic!.path!);
    setState(() {});
  }

  //修改播放方式
  void changeAudioMode() {
    playState = MusicHelper.changeMode(playState);
    ToastUtils.showToast(msg: playState.enumToString);
    setState(() {});
  }

  @override
  void dispose() {
    if (mounted) {
      _audioPlayer.dispose();
      _controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SlidingUpPanel(
        controller: panel,
        slideDirection: SlideDirection.UP,
        minWidth: 0,
        maxWidth: 200,
        minHeight: 0,
        maxHeight: 400,
        margin: EdgeInsets.only(
            left: screenUtil.adaptive(30),
            right: screenUtil.adaptive(30),
            bottom: screenUtil.adaptive(30)),
        borderRadius: const BorderRadius.all(Radius.circular(24.0)),
        panel: _buildMusicList(context),
        body: SafeArea(
          child: GestureDetector(
            onTap: () {
              panel.close();
            },
            child: NeumorphicBackground(
              child: Column(
                children: <Widget>[
                  const SizedBox(height: 14),
                  _buildTopBar(context),
                  const SizedBox(height: 80),
                  _buildImage(context),
                  const SizedBox(height: 30),
                  _buildTitle(context),
                  const SizedBox(height: 30),
                  _buildSeekBar(context),
                  const SizedBox(height: 40),
                  _buildControlsBar(context),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMusicList(BuildContext context) {
    return RepaintBoundary(
      child: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              margin: EdgeInsets.only(
                top: screenUtil.adaptive(40),
                left: screenUtil.adaptive(35),
              ),
              alignment: Alignment.centerLeft,
              child: Text(
                '当前播放',
                style: TextStyle(fontSize: screenUtil.adaptive(42)),
              ),
            ),
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemBuilder: (BuildContext context, int index) {
                final MusicModel model = ArrayHelper.get(_list, index)!;
                return GestureDetector(
                  onTap: () {
                    panel.close();
                    currentMusic = model;
                    play(model.path!);
                    setState(() {});
                  },
                  child: Container(
                    padding: EdgeInsets.only(
                        left: screenUtil.adaptive(35),
                        right: screenUtil.adaptive(20),
                        bottom: screenUtil.adaptive(10)),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            '${model.name}',
                          ),
                        ),
                        IconButton(
                          onPressed: () async {
                            await MusicCache.deleteCache(model.id!);
                            getMusicCacheList();
                          },
                          icon: Icon(
                            Icons.close,
                            size: screenUtil.adaptive(40),
                          ),
                        )
                      ],
                    ),
                  ),
                );
              },
              itemCount: _list.length,
            )
          ],
        ),
      ),
    );
  }

  Widget _buildTopBar(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 100.0),
      child: Stack(
        alignment: Alignment.center,
        children: <Widget>[
          Align(
            alignment: Alignment.centerLeft,
            child: NeumorphicButton(
              padding: const EdgeInsets.all(18.0),
              onPressed: () {
                WindowsNavigator().pop(context);
              },
              style: const NeumorphicStyle(
                shape: NeumorphicShape.convex,
                boxShape: NeumorphicBoxShape.circle(),
              ),
              child: Icon(
                Icons.navigate_before,
                color: _iconsColor(),
              ),
            ),
          ),
          Align(
            alignment: Alignment.center,
            child: Text(
              '私人音乐坊',
              style: TextStyle(
                  color: NeumorphicTheme.defaultTextColor(context),
                  fontSize: screenUtil.getAutoSp(40)),
            ),
          ),
          Align(
            alignment: Alignment.centerRight,
            child: NeumorphicButton(
              padding: const EdgeInsets.all(18.0),
              onPressed: () {
                select();
              },
              style: const NeumorphicStyle(
                shape: NeumorphicShape.convex,
                boxShape: NeumorphicBoxShape.circle(),
              ),
              child: Column(
                children: [
                  Icon(
                    Icons.file_upload,
                    color: _iconsColor(),
                  ),
                  const Text('上传')
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildImage(BuildContext context) {
    return Neumorphic(
      style: const NeumorphicStyle(
        boxShape: NeumorphicBoxShape.circle(),
      ),
      child: Container(
        height: 200,
        width: 200,
        child: Image.asset(
          'assets/images/002.jpg',
          fit: BoxFit.cover,
        ),
      ),
    );
  }

  Widget _buildTitle(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: <Widget>[
        Text('${currentMusic?.name ?? ' '}',
            style: TextStyle(
                fontWeight: FontWeight.w800,
                fontSize: 16,
                color: NeumorphicTheme.defaultTextColor(context))),
        const SizedBox(
          height: 14,
        ),
      ],
    );
  }

  Widget _buildSeekBar(BuildContext context) {
    return RepaintBoundary(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 120.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            Stack(
              children: <Widget>[
                Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      '${DateTimeHelper.secToMSTime(currentTime)}',
                      style: TextStyle(
                          color: NeumorphicTheme.defaultTextColor(context)),
                    )),
                Align(
                    alignment: Alignment.centerRight,
                    child: Text(
                      '${DateTimeHelper.secToMSTime(times)}',
                      style: TextStyle(
                          color: NeumorphicTheme.defaultTextColor(context)),
                    )),
              ],
            ),
            const SizedBox(
              height: 8,
            ),
            NeumorphicSlider(
              height: 8,
              min: 0,
              max: times?.toDouble() ?? 0,
              value: currentTime?.toDouble() ?? 0,
              onChanged: (double value) {
                onSeekChange(value.toInt());
              },
            )
          ],
        ),
      ),
    );
  }

  Widget _buildControlsBar(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        IconButton(
          onPressed: () {
            changeAudioMode();
          },
          icon: Icon(
            playState == PlayMode.normal
                ? Icons.replay
                : playState == PlayMode.loop
                    ? Icons.loop
                    : playState == PlayMode.singleLoop
                        ? Icons.repeat_one
                        : Icons.all_inclusive,
            size: 32,
          ),
        ),
        const SizedBox(width: 20),
        NeumorphicButton(
          padding: const EdgeInsets.all(18.0),
          onPressed: () {
            previous();
          },
          style: const NeumorphicStyle(
            shape: NeumorphicShape.convex,
            boxShape: NeumorphicBoxShape.circle(),
          ),
          child: Icon(
            Icons.skip_previous,
            color: _iconsColor(),
          ),
        ),
        const SizedBox(width: 12),
        NeumorphicButton(
          padding: const EdgeInsets.all(24.0),
          onPressed: () {
            startOrPause();
          },
          style: const NeumorphicStyle(
            shape: NeumorphicShape.convex,
            boxShape: NeumorphicBoxShape.circle(),
          ),
          child: Icon(
            _state == PlayerState.playing ? Icons.pause : Icons.play_arrow,
            size: 42,
            color: _iconsColor(),
          ),
        ),
        const SizedBox(width: 12),
        NeumorphicButton(
          padding: const EdgeInsets.all(18.0),
          onPressed: () {
            next();
          },
          style: const NeumorphicStyle(
            shape: NeumorphicShape.convex,
            boxShape: NeumorphicBoxShape.circle(),
          ),
          child: Icon(
            Icons.skip_next,
            color: _iconsColor(),
          ),
        ),
        const SizedBox(width: 20),
        IconButton(
          onPressed: () {
            panel.open();
          },
          icon: const Icon(
            Icons.list,
            size: 32,
          ),
        )
      ],
    );
  }

  Color? _iconsColor() {
    final NeumorphicThemeInherited? theme = NeumorphicTheme.of(context);
    if (theme?.isUsingDark == true) {
      return theme?.current?.accentColor;
    } else {
      return null;
    }
  }
}
