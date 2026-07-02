class MoonlitIdleState {
  MoonlitIdleState({
    required this.regions,
    required this.stages,
    required this.routes,
    required this.resources,
    required this.upgrades,
    required this.unlockRequirements,
    required this.stageTickets,
    required this.activeExpedition,
  });

  final List<MoonlitRegion> regions;
  final List<MoonlitStage> stages;
  final List<MoonlitRoute> routes;
  final List<MoonlitResource> resources;
  final List<MoonlitUpgrade> upgrades;
  final List<MoonlitUnlockRequirement> unlockRequirements;
  final List<MoonlitStageTicket> stageTickets;
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
      activeExpedition: json['active_expedition'] == null
          ? null
          : MoonlitExpedition.fromJson(
              json['active_expedition'] as Map<String, dynamic>,
            ),
    );
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
