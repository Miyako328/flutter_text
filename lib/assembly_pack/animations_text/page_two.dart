import 'package:animated_text_kit/animated_text_kit.dart';

import '../../init.dart';

class APageTwo extends StatefulWidget {
  const APageTwo({Key? key}) : super(key: key);

  @override
  State<APageTwo> createState() => _APageTwoState();
}

class _APageTwoState extends State<APageTwo> {
  static const Color _backgroundColor = Color(0xD2FE840A);
  static const Color _tileColor = Color(0x26FFFFFF);

  TextStyle get _primaryTextStyle => const TextStyle(
        fontSize: 43,
        color: Colors.white,
        fontWeight: FontWeight.w600,
      );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _backgroundColor,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (BuildContext context, BoxConstraints constraints) {
            final double horizontalPadding =
                constraints.maxWidth > 720 ? 32 : 18;

            return ListView(
              padding: EdgeInsets.fromLTRB(
                horizontalPadding,
                20,
                horizontalPadding,
                28,
              ),
              children: <Widget>[
                Text(
                  'Animated Text',
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                      ),
                ),
                const SizedBox(height: 16),
                _DemoTile(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      Text('Be', style: _primaryTextStyle),
                      const SizedBox(width: 18),
                      DefaultTextStyle(
                        style: _primaryTextStyle,
                        child: AnimatedTextKit(
                          repeatForever: true,
                          animatedTexts: <AnimatedText>[
                            RotateAnimatedText('Future'),
                            RotateAnimatedText('Awesome'),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                _DemoTile(
                  child: DefaultTextStyle(
                    style: _primaryTextStyle,
                    child: AnimatedTextKit(
                      repeatForever: true,
                      animatedTexts: <AnimatedText>[
                        FadeAnimatedText('text'),
                        FadeAnimatedText('Sec'),
                      ],
                    ),
                  ),
                ),
                _DemoTile(
                  child: DefaultTextStyle(
                    style: _primaryTextStyle,
                    child: AnimatedTextKit(
                      animatedTexts: <AnimatedText>[
                        TyperAnimatedText(
                          'Animated Text that displays a [Text]',
                        ),
                        TyperAnimatedText(
                          'element as if it is being typed one',
                        ),
                      ],
                    ),
                  ),
                ),
                _DemoTile(
                  child: DefaultTextStyle(
                    style: _primaryTextStyle,
                    child: AnimatedTextKit(
                      animatedTexts: <AnimatedText>[
                        TypewriterAnimatedText(
                          'Animated Text that displays a [Text]',
                          speed: const Duration(milliseconds: 100),
                        ),
                        TypewriterAnimatedText(
                          'element as if it is being typed one',
                          speed: const Duration(milliseconds: 100),
                        ),
                      ],
                    ),
                  ),
                ),
                _DemoTile(
                  child: AnimatedTextKit(
                    repeatForever: true,
                    animatedTexts: <AnimatedText>[
                      ColorizeAnimatedText(
                        'Animated Text',
                        textStyle: _primaryTextStyle,
                        colors: const <Color>[
                          Color(0xFF7C3AED),
                          Color(0xFF06B6D4),
                          Color(0xFFFDE047),
                        ],
                        speed: const Duration(milliseconds: 200),
                      ),
                      ColorizeAnimatedText(
                        'typed one',
                        textStyle: _primaryTextStyle,
                        colors: const <Color>[
                          Color(0xFF7C3AED),
                          Color(0xFF06B6D4),
                          Color(0xFFFDE047),
                        ],
                        speed: const Duration(milliseconds: 200),
                      ),
                    ],
                  ),
                ),
                _DemoTile(
                  child: DefaultTextStyle(
                    style: _primaryTextStyle.copyWith(fontSize: 40),
                    child: AnimatedTextKit(
                      repeatForever: true,
                      animatedTexts: <AnimatedText>[
                        WavyAnimatedText('Hello World'),
                      ],
                    ),
                  ),
                ),
                _DemoTile(
                  child: AnimatedTextKit(
                    repeatForever: true,
                    animatedTexts: <AnimatedText>[
                      FlickerAnimatedText(
                        'cyberpunk',
                        textStyle: const TextStyle(
                          fontSize: 50,
                          fontFamily: 'Avalien',
                          package: 'self_utils',
                          color: Colors.white,
                          shadows: <Shadow>[
                            Shadow(
                              blurRadius: 7,
                              color: Colors.white,
                              offset: Offset.zero,
                            ),
                          ],
                        ),
                      ),
                      FlickerAnimatedText(
                        '2077',
                        textStyle: const TextStyle(
                          fontSize: 50,
                          fontFamily: 'Avalien',
                          package: 'self_utils',
                          color: Colors.white,
                          shadows: <Shadow>[
                            Shadow(
                              blurRadius: 7,
                              color: Colors.white,
                              offset: Offset.zero,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _DemoTile extends StatelessWidget {
  final Widget child;

  const _DemoTile({required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 96,
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.symmetric(horizontal: 18),
      decoration: BoxDecoration(
        color: _APageTwoState._tileColor,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.white.withValues(alpha: 0.22)),
      ),
      child: Center(
        child: FittedBox(
          fit: BoxFit.scaleDown,
          child: child,
        ),
      ),
    );
  }
}
