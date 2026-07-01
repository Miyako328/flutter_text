import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_neumorphic_plus/flutter_neumorphic.dart';
import 'package:flutter_text/assembly_pack/management/utils/navigator.dart';

class NeumorphicExamplePage extends StatefulWidget {
  @override
  _NeumorphicExampleState createState() => _NeumorphicExampleState();
}

class _NeumorphicExampleState extends State<NeumorphicExamplePage> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return NeumorphicTheme(child: _page());
  }
}

class _page extends StatefulWidget {
  @override
  _pageState createState() => _pageState();
}

class _pageState extends State<_page> {
  bool _useDark = false;
  AudioPlayer _audioPlayer = AudioPlayer();

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
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
              const SizedBox(height: 30),
              _buildControlsBar(context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTopBar(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
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
              "Now Playing",
              style:
                  TextStyle(color: NeumorphicTheme.defaultTextColor(context)),
            ),
          ),
          Align(
            alignment: Alignment.centerRight,
            child: NeumorphicButton(
              padding: const EdgeInsets.all(18.0),
              onPressed: () {
                setState(() {
                  _useDark = !_useDark;
                  NeumorphicTheme.of(context)?.themeMode =
                      _useDark ? ThemeMode.dark : ThemeMode.light;
                });
              },
              style: const NeumorphicStyle(
                shape: NeumorphicShape.convex,
                boxShape: NeumorphicBoxShape.circle(),
              ),
              child: Icon(
                Icons.list,
                color: _iconsColor(),
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
            'assets/images/timg3.jpg',
            fit: BoxFit.cover,
          )),
    );
  }

  Widget _buildTitle(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: <Widget>[
        Text("Blinding Lights",
            style: TextStyle(
                fontWeight: FontWeight.w800,
                fontSize: 34,
                color: NeumorphicTheme.defaultTextColor(context))),
        const SizedBox(
          height: 4,
        ),
        Text("The Weeknd",
            style: TextStyle(
                fontWeight: FontWeight.w400,
                fontSize: 14,
                color: NeumorphicTheme.defaultTextColor(context))),
      ],
    );
  }

  Widget _buildSeekBar(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 28.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          Stack(
            children: <Widget>[
              Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    "2.00",
                    style: TextStyle(
                        color: NeumorphicTheme.defaultTextColor(context)),
                  )),
              Align(
                  alignment: Alignment.centerRight,
                  child: Text(
                    "3.14",
                    style: TextStyle(
                        color: NeumorphicTheme.defaultTextColor(context)),
                  )),
            ],
          ),
          SizedBox(
            height: 8,
          ),
          NeumorphicSlider(
            height: 8,
            min: 0,
            max: 314,
            value: 100,
            onChanged: (value) {},
          )
        ],
      ),
    );
  }

  Widget _buildControlsBar(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        NeumorphicButton(
          padding: const EdgeInsets.all(18.0),
          onPressed: () {},
          style: NeumorphicStyle(
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
          onPressed: () {},
          style: NeumorphicStyle(
            shape: NeumorphicShape.convex,
            boxShape: NeumorphicBoxShape.circle(),
          ),
          child: Icon(
            Icons.play_arrow,
            size: 42,
            color: _iconsColor(),
          ),
        ),
        const SizedBox(width: 12),
        NeumorphicButton(
          padding: const EdgeInsets.all(18.0),
          onPressed: () {},
          style: NeumorphicStyle(
            shape: NeumorphicShape.convex,
            boxShape: NeumorphicBoxShape.circle(),
          ),
          child: Icon(
            Icons.skip_next,
            color: _iconsColor(),
          ),
        ),
      ],
    );
  }

  Color? _iconsColor() {
    final theme = NeumorphicTheme.of(context);
    if (theme?.isUsingDark == true) {
      return theme?.current?.accentColor;
    } else {
      return null;
    }
  }
}
