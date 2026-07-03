import 'dart:math' as math;

class MoonlitIdleState {
  MoonlitIdleState({
    required this.regions,
    required this.stages,
    required this.routes,
    required this.resources,
    required this.upgrades,
    required this.unlockRequirements,
    required this.stageTickets,
    required this.routeMonsters,
    required this.activeExpedition,
  });

  final List<MoonlitRegion> regions;
  final List<MoonlitStage> stages;
  final List<MoonlitRoute> routes;
  final List<MoonlitResource> resources;
  final List<MoonlitUpgrade> upgrades;
  final List<MoonlitUnlockRequirement> unlockRequirements;
  final List<MoonlitStageTicket> stageTickets;
  final List<MoonlitRouteMonster> routeMonsters;
  final MoonlitExpedition? activeExpedition;

  Map<String, MoonlitResource> get resourcesByKey {
    return <String, MoonlitResource>{
      for (final MoonlitResource resource in resources)
        resource.resourceKey: resource,
    };
  }

  List<MoonlitRoute> get openRoutes {
    final Set<int> unlockedStages = stages
        .where((MoonlitStage stage) => stage.unlocked)
        .map((MoonlitStage stage) => stage.id)
        .toSet();
    return routes
        .where((MoonlitRoute route) =>
            route.unlocked && unlockedStages.contains(route.stageId))
        .toList();
  }

  MoonlitStage? stageByKey(String key) {
    for (final MoonlitStage stage in stages) {
      if (stage.stageKey == key) {
        return stage;
      }
    }
    return null;
  }

  List<MoonlitUpgradeCost> costsFor(String upgradeKey) {
    return MoonlitUpgradeCost.defaultCosts(upgradeKey, resourcesByKey);
  }

  MoonlitActiveEncounter? get activeEncounter {
    final MoonlitExpedition? expedition = activeExpedition;
    if (expedition == null || expedition.liveCanClaim) {
      return null;
    }

    final List<MoonlitRouteMonster> monsters =
        _monstersForRoute(expedition.routeKey);
    if (monsters.isEmpty) {
      return null;
    }

    final double progress = expedition.currentProgress;
    final List<_EncounterPlan> plans = _encounterPlans(expedition, monsters);
    _EncounterPlan? activePlan;
    for (final _EncounterPlan plan in plans) {
      final _EncounterWindow window = plan.window;
      if (progress < window.start || progress > window.end) {
        continue;
      }

      activePlan = plan;
      break;
    }

    if (activePlan == null) {
      return null;
    }

    final double localProgress =
        ((progress - activePlan.window.start) / activePlan.window.duration)
            .clamp(0, 1)
            .toDouble();
    final double battleProgress = (localProgress * 1.45).clamp(0, 1).toDouble();
    final MoonlitRouteMonster monster = activePlan.monster;
    final int playerPower = _playerPower;
    final int monsterThreat = monster.threat;
    final double rawWinRate =
        playerPower / math.max(1, playerPower + monsterThreat);
    final double winRate = rawWinRate.clamp(0.35, 0.95).toDouble();

    return MoonlitActiveEncounter(
      monster: monster,
      encounterIndex: activePlan.index,
      playerPower: playerPower,
      monsterThreat: monsterThreat,
      winRate: winRate,
      playerHpRatio: (1 - battleProgress * (0.18 + (1 - winRate) * 0.58))
          .clamp(0.12, 1)
          .toDouble(),
      monsterHpRatio: (1 - battleProgress * 0.96).clamp(0.04, 1).toDouble(),
    );
  }

  int get _playerPower {
    final int combatLevel = _upgradeLevel('shia_combat');
    final int guildLevel = _upgradeLevel('twilight_guild');
    final int bloodLevel = _upgradeLevel('blood_contract_control');
    double power = 100 * math.pow(1.12, combatLevel).toDouble();
    power *= 1 + guildLevel * 0.03;
    power *= 1 + bloodLevel * 0.04;
    return math.max(1, power.round());
  }

  int _upgradeLevel(String key) {
    for (final MoonlitUpgrade upgrade in upgrades) {
      if (upgrade.upgradeKey == key) {
        return upgrade.level;
      }
    }
    return 0;
  }

  List<MoonlitRouteMonster> _monstersForRoute(String routeKey) {
    final List<MoonlitRouteMonster> monsters = routeMonsters
        .where((MoonlitRouteMonster monster) => monster.routeKey == routeKey)
        .toList();
    if (monsters.isNotEmpty) {
      return monsters;
    }

    return MoonlitRouteMonster.fallbackForRoute(routeKey);
  }

  List<_EncounterPlan> _encounterPlans(
    MoonlitExpedition expedition,
    List<MoonlitRouteMonster> monsters,
  ) {
    final int minEncounters = monsters
        .map((MoonlitRouteMonster monster) => monster.minEncounters)
        .fold<int>(1, math.min)
        .clamp(1, 3);
    final int maxEncounters = monsters
        .map((MoonlitRouteMonster monster) => monster.maxEncounters)
        .fold<int>(minEncounters, math.max)
        .clamp(minEncounters, 3);
    final int totalWeight = monsters.fold<int>(
      0,
      (int total, MoonlitRouteMonster monster) =>
          total + math.max(1, monster.encounterWeight),
    );
    final _SeededRoller roller = _SeededRoller.fromExpedition(expedition);
    final int count = minEncounters +
        roller.nextInt(math.max(1, maxEncounters - minEncounters + 1));
    const double routeStart = 0.12;
    const double routeEnd = 0.90;
    final double slot = (routeEnd - routeStart) / count;
    double previousEnd = routeStart;

    return List<_EncounterPlan>.generate(count, (int index) {
      final MoonlitRouteMonster monster = _weightedMonster(monsters, roller);
      final double probability =
          math.max(1, monster.encounterWeight) / math.max(1, totalWeight);
      final double duration = (0.08 + probability * 0.10).clamp(0.08, 0.16);
      final double jitter = (roller.nextDouble() - 0.5) * slot * 0.32;
      final double center = routeStart + slot * (index + 0.5) + jitter;
      final double minStart = previousEnd + 0.025;
      final double maxStart = routeEnd - duration;
      final double start = (center - duration / 2).clamp(minStart, maxStart);
      final _EncounterWindow window = _EncounterWindow(
        start,
        math.min(routeEnd, start + duration),
      );
      previousEnd = window.end;

      return _EncounterPlan(
        index: index + 1,
        monster: monster,
        window: window,
      );
    });
  }

  MoonlitRouteMonster _weightedMonster(
    List<MoonlitRouteMonster> monsters,
    _SeededRoller roller,
  ) {
    final int totalWeight = monsters.fold<int>(
      0,
      (int total, MoonlitRouteMonster monster) =>
          total + math.max(1, monster.encounterWeight),
    );
    final int roll = roller.nextInt(math.max(1, totalWeight)) + 1;
    int cursor = 0;
    for (final MoonlitRouteMonster monster in monsters) {
      cursor += math.max(1, monster.encounterWeight);
      if (roll <= cursor) {
        return monster;
      }
    }

    return monsters.first;
  }

  factory MoonlitIdleState.fromJson(Map<String, dynamic> json) {
    return MoonlitIdleState(
      regions: _list(json['regions'], MoonlitRegion.fromJson),
      stages: _list(json['stages'], MoonlitStage.fromJson),
      routes: _list(json['routes'], MoonlitRoute.fromJson),
      resources: _list(json['resources'], MoonlitResource.fromJson),
      upgrades: _list(json['upgrades'], MoonlitUpgrade.fromJson),
      unlockRequirements:
          _list(json['unlock_requirements'], MoonlitUnlockRequirement.fromJson),
      stageTickets: _list(json['stage_tickets'], MoonlitStageTicket.fromJson),
      routeMonsters:
          _list(json['route_monsters'], MoonlitRouteMonster.fromJson),
      activeExpedition: json['active_expedition'] == null
          ? null
          : MoonlitExpedition.fromJson(
              json['active_expedition'] as Map<String, dynamic>,
            ),
    );
  }
}

class _EncounterWindow {
  const _EncounterWindow(this.start, this.end);

  final double start;
  final double end;

  double get duration => end - start;
}

class _EncounterPlan {
  const _EncounterPlan({
    required this.index,
    required this.monster,
    required this.window,
  });

  final int index;
  final MoonlitRouteMonster monster;
  final _EncounterWindow window;
}

class _SeededRoller {
  _SeededRoller(this._seed);

  int _seed;

  factory _SeededRoller.fromExpedition(MoonlitExpedition expedition) {
    int seed = expedition.id * 1103;
    for (final int codeUnit in expedition.routeKey.codeUnits) {
      seed = (seed * 31 + codeUnit) & 0x7fffffff;
    }
    return _SeededRoller(seed == 0 ? 1 : seed);
  }

  int nextInt(int max) {
    if (max <= 1) {
      _next();
      return 0;
    }
    return _next() % max;
  }

  double nextDouble() {
    return _next() / 0x7fffffff;
  }

  int _next() {
    _seed = (_seed * 1103515245 + 12345) & 0x7fffffff;
    return _seed;
  }
}

class MoonlitRegion {
  MoonlitRegion({
    required this.id,
    required this.regionKey,
    required this.name,
    required this.description,
  });

  final int id;
  final String regionKey;
  final String name;
  final String description;

  factory MoonlitRegion.fromJson(Map<String, dynamic> json) {
    return MoonlitRegion(
      id: toInt(json['id']),
      regionKey: '${json['region_key'] ?? ''}',
      name: '${json['name'] ?? ''}',
      description: '${json['description'] ?? ''}',
    );
  }
}

class MoonlitStage {
  MoonlitStage({
    required this.id,
    required this.stageKey,
    required this.name,
    required this.unlocked,
  });

  final int id;
  final String stageKey;
  final String name;
  final bool unlocked;

  factory MoonlitStage.fromJson(Map<String, dynamic> json) {
    return MoonlitStage(
      id: toInt(json['id']),
      stageKey: '${json['stage_key'] ?? ''}',
      name: '${json['name'] ?? ''}',
      unlocked: toInt(json['unlocked']) == 1,
    );
  }
}

class MoonlitRoute {
  MoonlitRoute({
    required this.id,
    required this.stageId,
    required this.routeKey,
    required this.name,
    required this.durationSeconds,
    required this.description,
    required this.unlocked,
  });

  final int id;
  final int stageId;
  final String routeKey;
  final String name;
  final int durationSeconds;
  final String description;
  final bool unlocked;

  factory MoonlitRoute.fromJson(Map<String, dynamic> json) {
    return MoonlitRoute(
      id: toInt(json['id']),
      stageId: toInt(json['stage_id']),
      routeKey: '${json['route_key'] ?? ''}',
      name: '${json['name'] ?? ''}',
      durationSeconds: toInt(json['duration_seconds']),
      description: '${json['description'] ?? ''}',
      unlocked: toInt(json['unlocked']) == 1,
    );
  }
}

class MoonlitResource {
  MoonlitResource({
    required this.resourceKey,
    required this.name,
    required this.amount,
    required this.totalEarned,
  });

  final String resourceKey;
  final String name;
  final int amount;
  final int totalEarned;

  factory MoonlitResource.fromJson(Map<String, dynamic> json) {
    return MoonlitResource(
      resourceKey: '${json['resource_key'] ?? ''}',
      name: '${json['name'] ?? ''}',
      amount: toInt(json['amount']),
      totalEarned: toInt(json['total_earned']),
    );
  }
}

class MoonlitUpgrade {
  MoonlitUpgrade({
    required this.upgradeKey,
    required this.name,
    required this.level,
    required this.maxLevel,
    required this.effectDesc,
  });

  final String upgradeKey;
  final String name;
  final int level;
  final int maxLevel;
  final String effectDesc;

  factory MoonlitUpgrade.fromJson(Map<String, dynamic> json) {
    return MoonlitUpgrade(
      upgradeKey: '${json['upgrade_key'] ?? ''}',
      name: '${json['name'] ?? ''}',
      level: toInt(json['level']),
      maxLevel: toInt(json['max_level']),
      effectDesc: '${json['effect_desc'] ?? ''}',
    );
  }
}

class MoonlitUnlockRequirement {
  MoonlitUnlockRequirement({
    required this.resourceKey,
    required this.name,
    required this.requiredTotal,
    required this.totalEarned,
  });

  final String resourceKey;
  final String name;
  final int requiredTotal;
  final int totalEarned;

  factory MoonlitUnlockRequirement.fromJson(Map<String, dynamic> json) {
    return MoonlitUnlockRequirement(
      resourceKey: '${json['resource_key'] ?? ''}',
      name: '${json['name'] ?? ''}',
      requiredTotal: toInt(json['required_total']),
      totalEarned: toInt(json['total_earned']),
    );
  }
}

class MoonlitStageTicket {
  MoonlitStageTicket({
    required this.resourceKey,
    required this.name,
    required this.amount,
    required this.currentAmount,
  });

  final String resourceKey;
  final String name;
  final int amount;
  final int currentAmount;

  factory MoonlitStageTicket.fromJson(Map<String, dynamic> json) {
    return MoonlitStageTicket(
      resourceKey: '${json['resource_key'] ?? ''}',
      name: '${json['name'] ?? ''}',
      amount: toInt(json['amount']),
      currentAmount: toInt(json['current_amount']),
    );
  }
}

class MoonlitRouteMonster {
  MoonlitRouteMonster({
    required this.routeId,
    required this.routeKey,
    required this.monsterKey,
    required this.name,
    required this.baseThreat,
    required this.baseHp,
    required this.battleText,
    required this.encounterWeight,
    required this.minEncounters,
    required this.maxEncounters,
    required this.routeDifficulty,
  });

  final int routeId;
  final String routeKey;
  final String monsterKey;
  final String name;
  final int baseThreat;
  final int baseHp;
  final String battleText;
  final int encounterWeight;
  final int minEncounters;
  final int maxEncounters;
  final int routeDifficulty;

  int get threat {
    return (baseThreat * math.pow(1.12, routeDifficulty)).round();
  }

  factory MoonlitRouteMonster.fromJson(Map<String, dynamic> json) {
    return MoonlitRouteMonster(
      routeId: toInt(json['route_id']),
      routeKey: '${json['route_key'] ?? ''}',
      monsterKey: '${json['monster_key'] ?? ''}',
      name: '${json['name'] ?? ''}',
      baseThreat: toInt(json['base_threat']),
      baseHp: toInt(json['base_hp']),
      battleText: '${json['battle_text'] ?? ''}',
      encounterWeight: toInt(json['encounter_weight']),
      minEncounters: toInt(json['min_encounters']),
      maxEncounters: toInt(json['max_encounters']),
      routeDifficulty: toInt(json['route_difficulty']),
    );
  }

  static List<MoonlitRouteMonster> fallbackForRoute(String routeKey) {
    final Map<String, List<MoonlitRouteMonster>> defaults =
        <String, List<MoonlitRouteMonster>>{
      'twilight_investigation': <MoonlitRouteMonster>[
        MoonlitRouteMonster._fallback(
          routeKey: routeKey,
          monsterKey: 'rift_wanderer',
          name: '裂谷游荡者',
          baseThreat: 82,
          battleText: '裂谷边缘的影子拖着旧甲片靠近营火。',
        ),
      ],
      'forest_edge_patrol': <MoonlitRouteMonster>[
        MoonlitRouteMonster._fallback(
          routeKey: routeKey,
          monsterKey: 'black_forest_wolf',
          name: '黑林狼',
          baseThreat: 118,
          battleText: '黑林狼从灌木后压低身形，绕着远征队寻找破绽。',
        ),
        MoonlitRouteMonster._fallback(
          routeKey: routeKey,
          monsterKey: 'mist_parasite',
          name: '雾化寄生体',
          baseThreat: 136,
          battleText: '灰雾缠住道路，寄生体从雾里伸出细长的触须。',
        ),
      ],
      'old_road_ruin_search': <MoonlitRouteMonster>[
        MoonlitRouteMonster._fallback(
          routeKey: routeKey,
          monsterKey: 'old_road_soldier',
          name: '旧路残兵',
          baseThreat: 168,
          battleText: '旧帝国残兵的盔甲仍在响动，像被某种命令驱使。',
        ),
      ],
      'maclay_ruins_deep': <MoonlitRouteMonster>[
        MoonlitRouteMonster._fallback(
          routeKey: routeKey,
          monsterKey: 'atlas_whisper',
          name: '阿特拉斯低语',
          baseThreat: 260,
          battleText: '遗址深处传来低语，血契的回声正压向意识边界。',
        ),
      ],
    };

    return defaults[routeKey] ?? <MoonlitRouteMonster>[];
  }

  factory MoonlitRouteMonster._fallback({
    required String routeKey,
    required String monsterKey,
    required String name,
    required int baseThreat,
    required String battleText,
  }) {
    return MoonlitRouteMonster(
      routeId: 0,
      routeKey: routeKey,
      monsterKey: monsterKey,
      name: name,
      baseThreat: baseThreat,
      baseHp: baseThreat * 4,
      battleText: battleText,
      encounterWeight: 1,
      minEncounters: 1,
      maxEncounters: 2,
      routeDifficulty: 0,
    );
  }
}

class MoonlitActiveEncounter {
  MoonlitActiveEncounter({
    required this.monster,
    required this.encounterIndex,
    required this.playerPower,
    required this.monsterThreat,
    required this.winRate,
    required this.playerHpRatio,
    required this.monsterHpRatio,
  });

  final MoonlitRouteMonster monster;
  final int encounterIndex;
  final int playerPower;
  final int monsterThreat;
  final double winRate;
  final double playerHpRatio;
  final double monsterHpRatio;

  String get resultLabel {
    if (winRate >= 0.70) {
      return '压制中';
    }
    if (winRate >= 0.50) {
      return '交战中';
    }
    return '险战中';
  }

  int get winPercent => (winRate * 100).round();
}

class MoonlitExpedition {
  MoonlitExpedition({
    required this.id,
    required this.routeKey,
    required this.routeName,
    required this.resultContent,
    required this.remainingSeconds,
    required this.progress,
    required this.canClaim,
    required this.startedAt,
    required this.finishAt,
  });

  final int id;
  final String routeKey;
  final String routeName;
  final String resultContent;
  final int remainingSeconds;
  final double progress;
  final bool canClaim;
  final DateTime? startedAt;
  final DateTime? finishAt;

  bool get liveCanClaim {
    return canClaim || liveRemainingSeconds <= 0;
  }

  int get liveRemainingSeconds {
    if (finishAt == null) {
      return remainingSeconds;
    }
    return finishAt!.difference(DateTime.now()).inSeconds.clamp(0, 1 << 31);
  }

  double get currentProgress {
    if (startedAt == null || finishAt == null) {
      return progress.clamp(0, 1);
    }
    final int total = finishAt!.difference(startedAt!).inSeconds;
    if (total <= 0) {
      return 1;
    }
    final int elapsed = DateTime.now().difference(startedAt!).inSeconds;
    return (elapsed / total).clamp(0, 1);
  }

  factory MoonlitExpedition.fromJson(Map<String, dynamic> json) {
    return MoonlitExpedition(
      id: toInt(json['id']),
      routeKey: '${json['route_key'] ?? ''}',
      routeName: '${json['route_name'] ?? ''}',
      resultContent: '${json['result_content'] ?? ''}',
      remainingSeconds: toInt(json['remaining_seconds']),
      progress: toDouble(json['progress']),
      canClaim: json['can_claim'] == true,
      startedAt: DateTime.tryParse('${json['started_at'] ?? ''}'),
      finishAt: DateTime.tryParse('${json['finish_at'] ?? ''}'),
    );
  }
}

class MoonlitClaimResult {
  MoonlitClaimResult({
    required this.resultTitle,
    required this.resultContent,
    required this.rewards,
    required this.battleLogs,
    required this.rewardFactor,
  });

  final String resultTitle;
  final String resultContent;
  final List<MoonlitClaimReward> rewards;
  final List<MoonlitBattleLog> battleLogs;
  final double rewardFactor;

  String get rewardText {
    if (rewards.isEmpty) {
      return '没有获得资源';
    }

    return rewards
        .map((MoonlitClaimReward reward) => '${reward.name} +${reward.amount}')
        .join('，');
  }

  factory MoonlitClaimResult.fromJson(Map<String, dynamic> json) {
    return MoonlitClaimResult(
      resultTitle: '${json['result_title'] ?? '探索完成'}',
      resultContent: '${json['result_content'] ?? ''}',
      rewards: _list(json['rewards'], MoonlitClaimReward.fromJson),
      battleLogs: _list(json['battle_logs'], MoonlitBattleLog.fromJson),
      rewardFactor: toDouble(json['reward_factor']),
    );
  }
}

class MoonlitClaimReward {
  MoonlitClaimReward({
    required this.resourceKey,
    required this.name,
    required this.amount,
  });

  final String resourceKey;
  final String name;
  final int amount;

  factory MoonlitClaimReward.fromJson(Map<String, dynamic> json) {
    return MoonlitClaimReward(
      resourceKey: '${json['resource_key'] ?? ''}',
      name: '${json['name'] ?? ''}',
      amount: toInt(json['amount']),
    );
  }
}

class MoonlitBattleLog {
  MoonlitBattleLog({
    required this.monsterKey,
    required this.monsterName,
    required this.encounterIndex,
    required this.resultLabel,
    required this.playerPower,
    required this.monsterThreat,
    required this.winRate,
    required this.rewardFactor,
    required this.logText,
  });

  final String monsterKey;
  final String monsterName;
  final int encounterIndex;
  final String resultLabel;
  final int playerPower;
  final int monsterThreat;
  final double winRate;
  final double rewardFactor;
  final String logText;

  int get winPercent => (winRate * 100).round();

  factory MoonlitBattleLog.fromJson(Map<String, dynamic> json) {
    return MoonlitBattleLog(
      monsterKey: '${json['monster_key'] ?? ''}',
      monsterName: '${json['monster_name'] ?? ''}',
      encounterIndex: toInt(json['encounter_index']),
      resultLabel: '${json['result_label'] ?? ''}',
      playerPower: toInt(json['player_power']),
      monsterThreat: toInt(json['monster_threat']),
      winRate: toDouble(json['win_rate']),
      rewardFactor: toDouble(json['reward_factor']),
      logText: '${json['log_text'] ?? ''}',
    );
  }
}

class MoonlitUpgradeCost {
  MoonlitUpgradeCost({
    required this.resourceKey,
    required this.name,
    required this.amount,
  });

  final String resourceKey;
  final String name;
  final int amount;

  static List<MoonlitUpgradeCost> defaultCosts(
    String upgradeKey,
    Map<String, MoonlitResource> resources,
  ) {
    final Map<String, List<MoonlitUpgradeCost>> costs =
        <String, List<MoonlitUpgradeCost>>{
      'twilight_guild': <MoonlitUpgradeCost>[
        _cost(resources, 'gold', 20),
        _cost(resources, 'twilight_reputation', 2),
      ],
      'maclay_archive': <MoonlitUpgradeCost>[
        _cost(resources, 'maclay_mark', 2),
      ],
      'shia_combat': <MoonlitUpgradeCost>[
        _cost(resources, 'gold', 20),
        _cost(resources, 'blood_trace_shard', 1),
      ],
      'blood_contract_control': <MoonlitUpgradeCost>[
        _cost(resources, 'blood_trace_shard', 1),
        _cost(resources, 'blood_mist_sample', 2),
      ],
      'magie_echo': <MoonlitUpgradeCost>[
        _cost(resources, 'old_empire_fragment', 1),
        _cost(resources, 'atlas_echo', 1),
      ],
    };
    return costs[upgradeKey] ?? <MoonlitUpgradeCost>[];
  }

  static MoonlitUpgradeCost _cost(
    Map<String, MoonlitResource> resources,
    String key,
    int amount,
  ) {
    return MoonlitUpgradeCost(
      resourceKey: key,
      name: resources[key]?.name ?? key,
      amount: amount,
    );
  }
}

List<T> _list<T>(dynamic value, T Function(Map<String, dynamic>) fromJson) {
  return ((value as List<dynamic>?) ?? <dynamic>[])
      .map((dynamic item) => fromJson(item as Map<String, dynamic>))
      .toList();
}

int toInt(dynamic value) {
  if (value is int) {
    return value;
  }
  return int.tryParse('$value') ?? 0;
}

double toDouble(dynamic value) {
  if (value is double) {
    return value;
  }
  if (value is int) {
    return value.toDouble();
  }
  return double.tryParse('$value') ?? 0;
}

String formatSeconds(int seconds) {
  final int safe = seconds < 0 ? 0 : seconds;
  final int minutes = safe ~/ 60;
  final int remain = safe % 60;
  return '${minutes.toString().padLeft(2, '0')}:${remain.toString().padLeft(2, '0')}';
}
