import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_intro/flutter_intro.dart';

import 'helper.dart';

class IntroPage extends StatefulWidget {
  @override
  _IntroState createState() => _IntroState();
}

class _IntroState extends State<IntroPage> {
  late Intro intro;

  _IntroState() {
    intro = Intro(
      stepCount: 4,
      maskClosable: true,
      onHighlightWidgetTap: (IntroStatus introStatus) {
        print(introStatus);
      },

      /// use defaultTheme
      widgetBuilder: (StepWidgetParams params) {
        final Map position = IntroHelper.smartGetPosition(
          screenSize: params.screenSize,
          size: params.size,
          offset: params.offset ?? Offset.zero,
        );

        final List<String> texts = [
          '开始动作，点击可以重新开始教程引导',
          '第一个功能模块，功能是xxxxxx',
          '第二个功能模块，辣么长的功能模块',
          '最后一个教程模块，点击finish结束',
        ];
        return Stack(
          children: [
            Positioned(
              child: Container(
                width: position['width'],
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: position['crossAxisAlignment'],
                  children: [
                    Text(
                      '${texts[params.currentStepIndex]}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                      ),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        if (params.currentStepIndex + 1 != params.stepCount)
                          OutlinedButton(
                            style: ButtonStyle(
                              foregroundColor: WidgetStateProperty.all<Color>(
                                Colors.white,
                              ),
                              overlayColor: WidgetStateProperty.all<Color>(
                                Colors.white.withValues(alpha: 0.1),
                              ),
                              side: WidgetStateProperty.all<BorderSide>(
                                const BorderSide(
                                  color: Colors.white,
                                ),
                              ),
                              padding:
                                  WidgetStateProperty.all<EdgeInsetsGeometry>(
                                const EdgeInsets.symmetric(
                                  vertical: 0,
                                  horizontal: 8,
                                ),
                              ),
                              shape: WidgetStateProperty.all<OutlinedBorder>(
                                const StadiumBorder(),
                              ),
                            ),
                            onPressed: () {
                              params.onNext!();
                            },
                            child: const Text(
                              '下一步',
                              style: TextStyle(
                                fontSize: 12,
                              ),
                            ),
                          ),
                        const SizedBox(
                          width: 16,
                        ),
                        OutlinedButton(
                          style: ButtonStyle(
                            foregroundColor: WidgetStateProperty.all<Color>(
                              Colors.white,
                            ),
                            overlayColor: WidgetStateProperty.all<Color>(
                              Colors.white.withValues(alpha: 0.1),
                            ),
                            side: WidgetStateProperty.all<BorderSide>(
                              const BorderSide(
                                color: Colors.white,
                              ),
                            ),
                            padding:
                                WidgetStateProperty.all<EdgeInsetsGeometry>(
                              const EdgeInsets.symmetric(
                                vertical: 0,
                                horizontal: 8,
                              ),
                            ),
                            shape: WidgetStateProperty.all<OutlinedBorder>(
                              const StadiumBorder(),
                            ),
                          ),
                          onPressed: () {
                            params.onFinish();
                          },
                          child: const Text(
                            '结束',
                            style: TextStyle(
                              fontSize: 12,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              top: position['top'],
              right: position['right'],
              left: position['left'],
              bottom: position['bottom'],
            )
          ],
        );
      },
    );
    intro.setStepConfig(
      0,
      borderRadius: BorderRadius.circular(64),
    );
  }

  @override
  void initState() {
    super.initState();
    Timer(
      const Duration(
        milliseconds: 500,
      ),
      () {
        /// start the intro
        intro.start(context);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (bool didPop, Object? result) {
        if (didPop) {
          return;
        }
        final IntroStatus introStatus = intro.getStatus();
        if (introStatus.isOpen) {
          intro.dispose();
          return;
        }
        Navigator.of(context).pop();
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('intro page'),
        ),
        body: SingleChildScrollView(
          child: Container(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  width: 100,
                  child: Placeholder(
                    /// 2nd guide
                    key: intro.keys[1],
                    fallbackHeight: 100,
                  ),
                ),
                const SizedBox(
                  height: 16,
                ),
                Placeholder(
                  /// 3rd guide
                  key: intro.keys[2],
                  fallbackHeight: 100,
                ),
                const SizedBox(
                  height: 16,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    SizedBox(
                      width: 100,
                      child: Placeholder(
                        /// 4th guide
                        key: intro.keys[3],
                        fallbackHeight: 100,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
        floatingActionButton: FloatingActionButton(
          /// 1st guide
          key: intro.keys[0],
          child: const Icon(
            Icons.play_arrow,
          ),
          onPressed: () {
            intro.start(context);
          },
        ),
      ),
    );
  }
}
