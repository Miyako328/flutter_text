import 'dart:async';

import 'package:flutter/material.dart';

import 'idle/idle_api.dart';
import 'idle/idle_models.dart';
import 'idle/widgets/idle_panels.dart';

class MoonlitIdlePage extends StatefulWidget {
  const MoonlitIdlePage({
    this.showBackButton = false,
    this.backFallbackBuilder,
    super.key,
  });

  final bool showBackButton;
  final WidgetBuilder? backFallbackBuilder;

  @override
  State<MoonlitIdlePage> createState() => _MoonlitIdlePageState();
}

class _MoonlitIdlePageState extends State<MoonlitIdlePage> {
  late Future<MoonlitIdleState> _future;
  Timer? _timer;
  MoonlitIdleState? _latestState;
  bool _busy = false;

  @override
  void initState() {
    super.initState();
    _future = MoonlitIdleApi.fetchState();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!mounted) {
        return;
      }

      final MoonlitExpedition? expedition = _latestState?.activeExpedition;
      if (expedition == null) {
        setState(() {});
        return;
      }

      setState(() {});
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _reload() {
    setState(() {
      _future = MoonlitIdleApi.fetchState();
    });
  }

  Future<void> _runAction(Future<String> Function() action) async {
    if (_busy) {
      return;
    }

    setState(() {
      _busy = true;
    });

    try {
      final String message = await action();
      if (mounted && message.isNotEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(message)),
        );
      }
      _reload();
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('$error')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _busy = false;
        });
      }
    }
  }

  Future<void> _claim() async {
    if (_busy) {
      return;
    }

    setState(() {
      _busy = true;
    });

    try {
      final MoonlitClaimResult result = await MoonlitIdleApi.claim();
      _reload();
      if (mounted) {
        await showModalBottomSheet<void>(
          context: context,
          isScrollControlled: true,
          backgroundColor: const Color(0xff17151b),
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
          ),
          builder: (BuildContext context) {
            return IdleBattleReportSheet(result: result);
          },
        );
      }
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('$error')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _busy = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: widget.showBackButton
            ? IconButton(
                tooltip: '返回地图',
                onPressed: _goBack,
                icon: const Icon(Icons.arrow_back),
              )
            : null,
        title: const Text('月下远征'),
        actions: <Widget>[
          IconButton(
            tooltip: '刷新',
            onPressed: _busy ? null : _reload,
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: FutureBuilder<MoonlitIdleState>(
        future: _future,
        builder: (BuildContext context, AsyncSnapshot<MoonlitIdleState> snap) {
          if (snap.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snap.hasError) {
            return IdleErrorView(message: '${snap.error}', onRetry: _reload);
          }

          final MoonlitIdleState? state = snap.data;
          if (state == null) {
            return IdleErrorView(message: '没有拿到远征数据', onRetry: _reload);
          }

          _latestState = state;

          return _IdleContent(
            state: state,
            busy: _busy,
            onRefresh: () async => _reload(),
            onClaim: _claim,
            onStart: (MoonlitRoute route) => _runAction(
              () => MoonlitIdleApi.start(route.routeKey),
            ),
            onUpgrade: (MoonlitUpgrade upgrade) => _runAction(
              () => MoonlitIdleApi.upgrade(upgrade.upgradeKey),
            ),
          );
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
      return;
    }

    final WidgetBuilder? fallback = widget.backFallbackBuilder;
    if (fallback != null) {
      rootNavigator.pushReplacement(
        MaterialPageRoute<void>(builder: fallback),
      );
    }
  }
}

class _IdleContent extends StatelessWidget {
  const _IdleContent({
    required this.state,
    required this.busy,
    required this.onRefresh,
    required this.onClaim,
    required this.onStart,
    required this.onUpgrade,
  });

  final MoonlitIdleState state;
  final bool busy;
  final Future<void> Function() onRefresh;
  final VoidCallback onClaim;
  final void Function(MoonlitRoute route) onStart;
  final void Function(MoonlitUpgrade upgrade) onUpgrade;

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: onRefresh,
      child: DecoratedBox(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: <Color>[
              Color(0xff17151b),
              Color(0xff211a1f),
              Color(0xff121116),
            ],
          ),
        ),
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: <Widget>[
            IdleRegionHeader(state: state),
            const SizedBox(height: 12),
            IdleExpeditionMapPanel(
              state: state,
              onHeroTap: () => _showUpgrades(context),
              onCampTap: () => _showCamp(context),
              onRouteTap: (MoonlitRoute route) => _confirmRoute(context, route),
              onUnavailableTap: (String label) =>
                  _showUnavailableLocation(context, label),
            ),
            const SizedBox(height: 12),
            const IdleInteractionHint(),
            const SizedBox(height: 12),
            IdleActiveExpeditionPanel(
              expedition: state.activeExpedition,
              busy: busy,
              onClaim:
                  state.activeExpedition?.liveCanClaim == true ? onClaim : null,
            ),
          ],
        ),
      ),
    );
  }

  void _showCamp(BuildContext context) {
    final MoonlitRoute? campRoute = _openRouteByKey('twilight_investigation');
    _showGameSheet(
      context: context,
      title: '营地',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          if (campRoute != null) ...<Widget>[
            const IdleSectionTitle(
              icon: Icons.route_outlined,
              title: '营地周边探索',
              subtitle: '从暮色镇派出短程调查',
            ),
            const SizedBox(height: 8),
            IdleRouteTile(
              route: campRoute,
              disabled: busy || state.activeExpedition != null,
              onStart: () {
                Navigator.of(context).pop();
                onStart(campRoute);
              },
            ),
            const SizedBox(height: 14),
          ],
          const IdleSectionTitle(
            icon: Icons.inventory_2_outlined,
            title: '资源库存',
            subtitle: '当前持有 / 历史累计',
          ),
          const SizedBox(height: 8),
          IdleResourceGrid(resources: state.resources),
          const SizedBox(height: 14),
          const IdleSectionTitle(
            icon: Icons.search,
            title: '玛克莱线索',
            subtitle: '历史发现量用于解锁，当前持有量用于门票',
          ),
          const SizedBox(height: 8),
          for (final MoonlitUnlockRequirement item in state.unlockRequirements)
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: IdleUnlockProgressTile(item: item),
            ),
          const SizedBox(height: 8),
          IdleTicketPanel(tickets: state.stageTickets),
        ],
      ),
    );
  }

  void _showUnavailableLocation(BuildContext context, String label) {
    _showGameSheet(
      context: context,
      title: label,
      child: const Text(
        '这里还没有可派出的探索路线，可能需要先收集线索或解锁关卡。',
        style: TextStyle(color: Color(0xffd7c7a7)),
      ),
    );
  }

  void _showUpgrades(BuildContext context) {
    _showGameSheet(
      context: context,
      title: '希尔薇娅',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          const IdleSectionTitle(
            icon: Icons.auto_graph,
            title: '局外养成',
            subtitle: '强化会影响后续放置收益和耗时',
          ),
          const SizedBox(height: 8),
          for (final MoonlitUpgrade upgrade in state.upgrades)
            Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: IdleUpgradeTile(
                upgrade: upgrade,
                costs: state.costsFor(upgrade.upgradeKey),
                resources: state.resourcesByKey,
                busy: busy,
                onUpgrade: () {
                  Navigator.of(context).pop();
                  onUpgrade(upgrade);
                },
              ),
            ),
        ],
      ),
    );
  }

  void _confirmRoute(BuildContext context, MoonlitRoute route) {
    final bool disabled = busy || state.activeExpedition != null;
    _showGameSheet(
      context: context,
      title: route.name,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          IdleRouteTile(
            route: route,
            disabled: disabled,
            onStart: () {
              Navigator.of(context).pop();
              onStart(route);
            },
          ),
          if (disabled) ...<Widget>[
            const SizedBox(height: 10),
            const Text(
              '远征队尚未归来，暂时不能派出新的探索。',
              style: TextStyle(color: Color(0xffd7c7a7)),
            ),
          ],
        ],
      ),
    );
  }

  void _showGameSheet({
    required BuildContext context,
    required String title,
    required Widget child,
  }) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: const Color(0xff17151b),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
      ),
      builder: (BuildContext context) {
        return SafeArea(
          child: ConstrainedBox(
            constraints: BoxConstraints(
              maxHeight: MediaQuery.of(context).size.height * 0.82,
            ),
            child: ListView(
              padding: const EdgeInsets.fromLTRB(16, 14, 16, 18),
              shrinkWrap: true,
              children: <Widget>[
                Row(
                  children: <Widget>[
                    Expanded(
                      child: Text(
                        title,
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              color: const Color(0xffffe7bf),
                              fontWeight: FontWeight.w800,
                            ),
                      ),
                    ),
                    IconButton(
                      tooltip: '关闭',
                      onPressed: () => Navigator.of(context).pop(),
                      icon: const Icon(
                        Icons.close,
                        color: Color(0xffffd27d),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                child,
              ],
            ),
          ),
        );
      },
    );
  }

  MoonlitRoute? _openRouteByKey(String key) {
    for (final MoonlitRoute route in state.openRoutes) {
      if (route.routeKey == key) {
        return route;
      }
    }
    return null;
  }
}
