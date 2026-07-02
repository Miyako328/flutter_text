import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import 'moonlit_idle_page.dart';

const String _defaultMoonlitMapUrl =
    'http://192.168.1.108:18980/moonlit/api/map.php?slug=main-era';

class MoonlitMapPage extends StatefulWidget {
  const MoonlitMapPage({super.key});

  @override
  State<MoonlitMapPage> createState() => _MoonlitMapPageState();
}

class _MoonlitMapPageState extends State<MoonlitMapPage> {
  late Future<MoonlitMapPayload> _future;

  @override
  void initState() {
    super.initState();
    _future = MoonlitMapApi.fetch();
  }

  void _reload() {
    setState(() {
      _future = MoonlitMapApi.fetch();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          tooltip: '返回',
          onPressed: _goBack,
          icon: const Icon(Icons.arrow_back),
        ),
        title: const Text('月下地图册'),
        actions: <Widget>[
          IconButton(
            tooltip: '刷新',
            onPressed: _reload,
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: FutureBuilder<MoonlitMapPayload>(
        future: _future,
        builder:
            (BuildContext context, AsyncSnapshot<MoonlitMapPayload> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return _ErrorView(
              message: '${snapshot.error}',
              onRetry: _reload,
            );
          }

          final MoonlitMapPayload? payload = snapshot.data;
          if (payload == null) {
            return _ErrorView(
              message: '没有拿到地图数据',
              onRetry: _reload,
            );
          }

          return _MoonlitMapView(payload: payload);
        },
      ),
    );
  }

  void _goBack() {
    final NavigatorState navigator = Navigator.of(context);
    if (navigator.canPop()) {
      navigator.pop();
      return;
    }

    final NavigatorState rootNavigator = Navigator.of(
      context,
      rootNavigator: true,
    );
    if (rootNavigator.canPop()) {
      rootNavigator.pop();
    }
  }
}

class _MoonlitMapView extends StatefulWidget {
  const _MoonlitMapView({required this.payload});

  final MoonlitMapPayload payload;

  @override
  State<_MoonlitMapView> createState() => _MoonlitMapViewState();
}

class _MoonlitMapViewState extends State<_MoonlitMapView> {
  bool _gameMode = false;

  @override
  Widget build(BuildContext context) {
    final MoonlitMapPayload payload = widget.payload;
    final double aspectRatio = payload.map.width > 0 && payload.map.height > 0
        ? payload.map.width / payload.map.height
        : 16 / 9;

    return Column(
      children: <Widget>[
        _MapModeBar(
          gameMode: _gameMode,
          onChanged: (bool value) {
            setState(() {
              _gameMode = value;
            });
          },
        ),
        Expanded(
          child: InteractiveViewer(
            minScale: 0.8,
            maxScale: 4,
            constrained: false,
            boundaryMargin: const EdgeInsets.all(240),
            child: SizedBox(
              width: 1200,
              child: AspectRatio(
                aspectRatio: aspectRatio,
                child: LayoutBuilder(
                  builder: (BuildContext context, BoxConstraints constraints) {
                    return Stack(
                      fit: StackFit.expand,
                      children: <Widget>[
                        Image.network(
                          payload.map.imageUrl,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) {
                            return Container(
                              color: const Color(0xff20242a),
                              alignment: Alignment.center,
                              child: const Text(
                                '地图图片加载失败',
                                style: TextStyle(color: Colors.white),
                              ),
                            );
                          },
                        ),
                        for (final MoonlitMapPoint point in payload.points)
                          _MapPointButton(
                            point: point,
                            gameMode: _gameMode,
                            left: constraints.maxWidth * point.x,
                            top: constraints.maxHeight * point.y,
                          ),
                        _TwilightTownButton(
                          gameMode: _gameMode,
                          left: constraints.maxWidth * 0.70,
                          top: constraints.maxHeight * 0.64,
                        ),
                      ],
                    );
                  },
                ),
              ),
            ),
          ),
        ),
        _MapSummary(payload: payload, gameMode: _gameMode),
      ],
    );
  }
}

class _MapModeBar extends StatelessWidget {
  const _MapModeBar({
    required this.gameMode,
    required this.onChanged,
  });

  final bool gameMode;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return Material(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
        child: Row(
          children: <Widget>[
            const Icon(Icons.travel_explore, size: 20),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                gameMode ? '游戏模式：地点会触发玩法入口' : '资料模式：地点用于查看世界设定',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ),
            SegmentedButton<bool>(
              segments: const <ButtonSegment<bool>>[
                ButtonSegment<bool>(
                  value: false,
                  icon: Icon(Icons.menu_book_outlined),
                  label: Text('资料'),
                ),
                ButtonSegment<bool>(
                  value: true,
                  icon: Icon(Icons.sports_esports_outlined),
                  label: Text('游戏'),
                ),
              ],
              selected: <bool>{gameMode},
              onSelectionChanged: (Set<bool> value) {
                onChanged(value.first);
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _MapPointButton extends StatelessWidget {
  const _MapPointButton({
    required this.point,
    required this.gameMode,
    required this.left,
    required this.top,
  });

  final MoonlitMapPoint point;
  final bool gameMode;
  final double left;
  final double top;

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: left - 14,
      top: top - 14,
      width: 28,
      height: 28,
      child: Tooltip(
        message: point.name,
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            customBorder: const CircleBorder(),
            onTap: () => _showPointSheet(context, point, gameMode: gameMode),
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: _colorForType(point.type),
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 2),
                boxShadow: const <BoxShadow>[
                  BoxShadow(
                    color: Color(0x66000000),
                    blurRadius: 8,
                    offset: Offset(0, 3),
                  ),
                ],
              ),
              child: const Icon(
                Icons.place,
                size: 16,
                color: Colors.white,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Color _colorForType(String type) {
    switch (type) {
      case 'academy':
        return const Color(0xff5568d9);
      case 'family':
        return const Color(0xff9b5a3c);
      case 'guild':
        return const Color(0xff2f8f6b);
      default:
        return const Color(0xff8a6fd1);
    }
  }

  void _showPointSheet(
    BuildContext context,
    MoonlitMapPoint point, {
    required bool gameMode,
  }) {
    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (BuildContext context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 4, 20, 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  point.name,
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 8),
                Text(point.fullDesc.isNotEmpty
                    ? point.fullDesc
                    : point.shortDesc),
                const SizedBox(height: 16),
                _MetaRow(label: '类型', value: point.type),
                if (point.relatedDoc.isNotEmpty)
                  _MetaRow(label: '关联资料', value: point.relatedDoc),
                if (point.relatedArc.isNotEmpty)
                  _MetaRow(label: '关联篇章', value: point.relatedArc),
                _MetaRow(label: '状态', value: point.status),
                const SizedBox(height: 16),
                if (gameMode && _isTwilightTown(point))
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () => _openIdlePage(context),
                      icon: const Icon(Icons.explore_outlined),
                      label: const Text('进入暮色镇远征'),
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  bool _isTwilightTown(MoonlitMapPoint point) {
    return point.name.contains('暮色镇') || point.name.contains('暮色');
  }
}

class _TwilightTownButton extends StatelessWidget {
  const _TwilightTownButton({
    required this.gameMode,
    required this.left,
    required this.top,
  });

  final bool gameMode;
  final double left;
  final double top;

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: left - 18,
      top: top - 18,
      width: 36,
      height: 36,
      child: Tooltip(
        message: gameMode ? '暮色镇远征' : '暮色镇',
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            customBorder: const CircleBorder(),
            onTap: () {
              if (gameMode) {
                _openIdlePage(context);
              } else {
                _showIntro(context);
              }
            },
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: gameMode
                    ? const Color(0xffd64a3d)
                    : const Color(0xff8a6fd1),
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 2),
                boxShadow: <BoxShadow>[
                  BoxShadow(
                    color: gameMode
                        ? const Color(0xaaffd27d)
                        : const Color(0x66000000),
                    blurRadius: gameMode ? 18 : 8,
                    spreadRadius: gameMode ? 2 : 0,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Icon(
                gameMode ? Icons.explore_outlined : Icons.place,
                size: 19,
                color: Colors.white,
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _showIntro(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (BuildContext context) {
        return const SafeArea(
          child: Padding(
            padding: EdgeInsets.fromLTRB(20, 4, 20, 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  '暮色镇',
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.w700),
                ),
                SizedBox(height: 8),
                Text(
                  '南境裂谷以南、通往玛克莱遗址线索的边境小镇。资料模式下这里用于查看设定；切换到游戏模式后，这里会成为当前放置远征入口。',
                ),
                SizedBox(height: 16),
                _MetaRow(label: '模式', value: '资料浏览'),
                _MetaRow(label: '玩法', value: '切换到游戏模式后开放远征入口'),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _MapSummary extends StatelessWidget {
  const _MapSummary({
    required this.payload,
    required this.gameMode,
  });

  final MoonlitMapPayload payload;
  final bool gameMode;

  @override
  Widget build(BuildContext context) {
    return Material(
      elevation: 8,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
        child: Row(
          children: <Widget>[
            const Icon(Icons.map_outlined),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Text(
                    payload.map.name,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  Text(
                    gameMode
                        ? '${payload.points.length + 1} 个地点 · 暮色镇可进入远征'
                        : '${payload.points.length + 1} 个地点 · 拖动/缩放地图后点击点位',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

void _openIdlePage(BuildContext context) {
  Navigator.of(context).pop();
  Navigator.of(context).push(
    MaterialPageRoute<void>(
      builder: (_) => const MoonlitIdlePage(
        showBackButton: true,
        backFallbackBuilder: _buildMapFallback,
      ),
    ),
  );
}

Widget _buildMapFallback(BuildContext context) {
  return const MoonlitMapPage();
}

class _MetaRow extends StatelessWidget {
  const _MetaRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          SizedBox(
            width: 72,
            child: Text(
              label,
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }
}

class _ErrorView extends StatelessWidget {
  const _ErrorView({
    required this.message,
    required this.onRetry,
  });

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            const Icon(Icons.cloud_off, size: 44),
            const SizedBox(height: 12),
            Text(
              message,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh),
              label: const Text('重试'),
            ),
          ],
        ),
      ),
    );
  }
}

class MoonlitMapApi {
  const MoonlitMapApi._();

  static Future<MoonlitMapPayload> fetch() async {
    final Uri uri = Uri.parse(_defaultMoonlitMapUrl);
    final http.Response response =
        await http.get(uri).timeout(const Duration(seconds: 12));

    if (response.statusCode != 200) {
      throw Exception('接口状态异常：${response.statusCode}');
    }

    final Map<String, dynamic> json =
        jsonDecode(utf8.decode(response.bodyBytes)) as Map<String, dynamic>;

    if (json['success'] != true) {
      throw Exception(json['message'] ?? '接口返回失败');
    }

    return MoonlitMapPayload.fromJson(json);
  }
}

class MoonlitMapPayload {
  MoonlitMapPayload({
    required this.map,
    required this.points,
  });

  final MoonlitMapInfo map;
  final List<MoonlitMapPoint> points;

  factory MoonlitMapPayload.fromJson(Map<String, dynamic> json) {
    return MoonlitMapPayload(
      map: MoonlitMapInfo.fromJson(json['map'] as Map<String, dynamic>),
      points: ((json['points'] as List<dynamic>?) ?? <dynamic>[])
          .map((dynamic item) =>
              MoonlitMapPoint.fromJson(item as Map<String, dynamic>))
          .toList(),
    );
  }
}

class MoonlitMapInfo {
  MoonlitMapInfo({
    required this.id,
    required this.name,
    required this.slug,
    required this.imageUrl,
    required this.width,
    required this.height,
    required this.description,
  });

  final int id;
  final String name;
  final String slug;
  final String imageUrl;
  final int width;
  final int height;
  final String description;

  factory MoonlitMapInfo.fromJson(Map<String, dynamic> json) {
    return MoonlitMapInfo(
      id: _toInt(json['id']),
      name: '${json['name'] ?? ''}',
      slug: '${json['slug'] ?? ''}',
      imageUrl: '${json['image_url'] ?? ''}',
      width: _toInt(json['width']),
      height: _toInt(json['height']),
      description: '${json['description'] ?? ''}',
    );
  }
}

class MoonlitMapPoint {
  MoonlitMapPoint({
    required this.id,
    required this.name,
    required this.type,
    required this.x,
    required this.y,
    required this.shortDesc,
    required this.fullDesc,
    required this.relatedDoc,
    required this.relatedArc,
    required this.status,
  });

  final int id;
  final String name;
  final String type;
  final double x;
  final double y;
  final String shortDesc;
  final String fullDesc;
  final String relatedDoc;
  final String relatedArc;
  final String status;

  factory MoonlitMapPoint.fromJson(Map<String, dynamic> json) {
    return MoonlitMapPoint(
      id: _toInt(json['id']),
      name: '${json['name'] ?? ''}',
      type: '${json['type'] ?? ''}',
      x: _toDouble(json['x']),
      y: _toDouble(json['y']),
      shortDesc: '${json['short_desc'] ?? ''}',
      fullDesc: '${json['full_desc'] ?? ''}',
      relatedDoc: '${json['related_doc'] ?? ''}',
      relatedArc: '${json['related_arc'] ?? ''}',
      status: '${json['status'] ?? ''}',
    );
  }
}

int _toInt(dynamic value) {
  if (value is int) {
    return value;
  }
  return int.tryParse('$value') ?? 0;
}

double _toDouble(dynamic value) {
  if (value is double) {
    return value;
  }
  if (value is int) {
    return value.toDouble();
  }
  return double.tryParse('$value') ?? 0;
}
