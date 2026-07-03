<?php

declare(strict_types=1);

require __DIR__ . '/bootstrap.php';

try {
    if ($_SERVER['REQUEST_METHOD'] !== 'POST') {
        respond_error('Use POST to claim rewards.', 405);
    }

    $expeditionId = input_value('expedition_id');
    $pdo = db();

    if ($expeditionId === null || $expeditionId === '') {
        $active = active_expedition($pdo);
        if ($active === null) {
            respond_error('没有可领取的探索。');
        }
        $expeditionId = (string) $active['id'];
    }

    $stmt = $pdo->prepare("
        SELECT e.*, r.route_key, r.name AS route_name, r.duration_seconds,
               s.stage_key, s.name AS stage_name
        FROM idle_expeditions e
        JOIN idle_routes r ON r.id = e.route_id
        JOIN idle_stages s ON s.id = e.stage_id
        WHERE e.id = ?
        LIMIT 1
    ");
    $stmt->execute([(int) $expeditionId]);
    $expedition = $stmt->fetch();

    if (!$expedition) {
        respond_error('探索记录不存在。', 404);
    }

    $expedition = normalize_expedition($expedition);

    if ($expedition['claimed_at'] !== null) {
        respond_error('奖励已经领取过。');
    }

    if (!$expedition['can_claim']) {
        respond_error('探索尚未完成。', 400, [
            'remaining_seconds' => $expedition['remaining_seconds'],
        ]);
    }

    $rewardStmt = $pdo->prepare("
        SELECT rr.*, res.name, res.resource_type
        FROM idle_route_rewards rr
        JOIN idle_resources res ON res.resource_key = rr.resource_key
        WHERE rr.route_id = ?
        ORDER BY res.sort_order ASC
    ");
    $rewardStmt->execute([(int) $expedition['route_id']]);
    $rewardRules = $rewardStmt->fetchAll();

    $levels = upgrade_levels($pdo);
    $battleLogs = roll_battle_logs($pdo, $expedition, $levels);
    $rewardFactor = battle_reward_factor($battleLogs);
    $rewards = roll_rewards(
        $rewardRules,
        $levels,
        $expedition['route_key'],
        $rewardFactor
    );

    $pdo->beginTransaction();
    try {
        $updateExpedition = $pdo->prepare("
            UPDATE idle_expeditions
            SET status = 'claimed', claimed_at = NOW()
            WHERE id = ?
        ");
        $updateExpedition->execute([(int) $expedition['id']]);

        $insertBattleLog = $pdo->prepare("
            INSERT INTO idle_battle_logs
            (expedition_id, route_id, monster_key, monster_name, encounter_index,
             result_label, player_power, monster_threat, win_rate, reward_factor, log_text)
            VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
        ");
        foreach ($battleLogs as $battleLog) {
            $insertBattleLog->execute([
                (int) $expedition['id'],
                (int) $expedition['route_id'],
                $battleLog['monster_key'],
                $battleLog['monster_name'],
                $battleLog['encounter_index'],
                $battleLog['result_label'],
                $battleLog['player_power'],
                $battleLog['monster_threat'],
                $battleLog['win_rate'],
                $battleLog['reward_factor'],
                $battleLog['log_text'],
            ]);
        }

        foreach ($rewards as $reward) {
            $insertReward = $pdo->prepare("
                INSERT INTO idle_expedition_rewards
                (expedition_id, resource_key, amount)
                VALUES (?, ?, ?)
            ");
            $insertReward->execute([
                (int) $expedition['id'],
                $reward['resource_key'],
                $reward['amount'],
            ]);

            $updateResource = $pdo->prepare("
                UPDATE idle_resources
                SET amount = amount + ?,
                    total_earned = total_earned + ?
                WHERE resource_key = ?
            ");
            $updateResource->execute([
                $reward['amount'],
                $reward['amount'],
                $reward['resource_key'],
            ]);
        }

        $pdo->commit();
    } catch (Throwable $e) {
        $pdo->rollBack();
        throw $e;
    }

    refresh_stage_unlocks($pdo);

    respond_success([
        'result_title' => $expedition['result_title'],
        'result_content' => $expedition['result_content'],
        'rewards' => $rewards,
        'battle_logs' => $battleLogs,
        'reward_factor' => $rewardFactor,
    ]);
} catch (Throwable $e) {
    respond_error($e->getMessage(), 500);
}

function roll_rewards(
    array $rules,
    array $levels,
    string $routeKey,
    float $rewardFactor
): array
{
    $rewards = [];

    foreach ($rules as $rule) {
        $chance = (int) $rule['chance_percent'];
        $extraChance = extra_chance_for_reward($rule['resource_key'], $levels, $routeKey);
        $finalChance = min(100, $chance + $extraChance);

        if (random_int(1, 100) > $finalChance) {
            continue;
        }

        $min = (int) $rule['min_amount'];
        $max = (int) $rule['max_amount'];
        $amount = $max > $min ? random_int($min, $max) : $min;
        $amount += flat_bonus_for_reward($rule['resource_key'], $levels, $routeKey);
        $amount = max(1, (int) round($amount * $rewardFactor));

        if ($amount <= 0) {
            continue;
        }

        $rewards[] = [
            'resource_key' => $rule['resource_key'],
            'name' => $rule['name'],
            'amount' => $amount,
        ];
    }

    return $rewards;
}

function roll_battle_logs(PDO $pdo, array $expedition, array $levels): array
{
    $stmt = $pdo->prepare("
        SELECT rm.*, m.name, m.base_threat, m.base_hp, m.battle_text
        FROM idle_route_monsters rm
        JOIN idle_monsters m ON m.monster_key = rm.monster_key
        WHERE rm.route_id = ?
          AND rm.enabled = 1
        ORDER BY m.sort_order ASC
    ");
    $stmt->execute([(int) $expedition['route_id']]);
    $monsters = $stmt->fetchAll();

    if (count($monsters) === 0) {
        return [];
    }

    $minEncounters = max(1, min(array_map(static function (array $row): int {
        return (int) $row['min_encounters'];
    }, $monsters)));
    $minEncounters = min(3, $minEncounters);
    $maxEncounters = max($minEncounters, max(array_map(static function (array $row): int {
        return (int) $row['max_encounters'];
    }, $monsters)));
    $maxEncounters = min(3, $maxEncounters);
    $seed = encounter_seed((int) $expedition['id'], (string) $expedition['route_key']);
    $encounterCount = $minEncounters + seeded_int(
        $seed,
        max(1, $maxEncounters - $minEncounters + 1)
    );

    $playerPower = player_power($levels);
    $logs = [];

    for ($i = 1; $i <= $encounterCount; $i++) {
        $monster = weighted_monster($monsters, $seed);
        seeded_float($seed);
        $difficulty = (int) $monster['route_difficulty'];
        $monsterThreat = (int) round((int) $monster['base_threat'] * (1.12 ** $difficulty));
        $rawWinRate = $playerPower / max(1, $playerPower + $monsterThreat);
        $winRate = max(0.35, min(0.95, $rawWinRate));
        $rewardFactor = 0.6 + ($winRate * 0.8);
        $resultLabel = battle_result_label($winRate);

        $logs[] = [
            'monster_key' => $monster['monster_key'],
            'monster_name' => $monster['name'],
            'encounter_index' => $i,
            'result_label' => $resultLabel,
            'player_power' => $playerPower,
            'monster_threat' => $monsterThreat,
            'win_rate' => round($winRate, 4),
            'reward_factor' => round($rewardFactor, 3),
            'log_text' => battle_log_text($monster, $resultLabel),
        ];
    }

    return $logs;
}

function player_power(array $levels): int
{
    $combatLevel = $levels['shia_combat'] ?? 0;
    $guildLevel = $levels['twilight_guild'] ?? 0;
    $bloodLevel = $levels['blood_contract_control'] ?? 0;

    $power = 100 * (1.12 ** $combatLevel);
    $power *= 1 + ($guildLevel * 0.03);
    $power *= 1 + ($bloodLevel * 0.04);

    return max(1, (int) round($power));
}

function weighted_monster(array $monsters, int &$seed): array
{
    $total = 0;
    foreach ($monsters as $monster) {
        $total += max(1, (int) $monster['encounter_weight']);
    }

    $roll = seeded_int($seed, max(1, $total)) + 1;
    $cursor = 0;
    foreach ($monsters as $monster) {
        $cursor += max(1, (int) $monster['encounter_weight']);
        if ($roll <= $cursor) {
            return $monster;
        }
    }

    return $monsters[0];
}

function encounter_seed(int $expeditionId, string $routeKey): int
{
    $seed = $expeditionId * 1103;
    $length = strlen($routeKey);
    for ($i = 0; $i < $length; $i++) {
        $seed = ($seed * 31 + ord($routeKey[$i])) % 2147483648;
    }

    return $seed === 0 ? 1 : $seed;
}

function seeded_int(int &$seed, int $max): int
{
    $seed = (int) (($seed * 1103515245 + 12345) % 2147483648);
    if ($max <= 1) {
        return 0;
    }

    return $seed % $max;
}

function seeded_float(int &$seed): float
{
    $seed = (int) (($seed * 1103515245 + 12345) % 2147483648);
    return $seed / 2147483647;
}

function battle_result_label(float $winRate): string
{
    if ($winRate >= 0.70) {
        return '击退';
    }

    if ($winRate >= 0.50) {
        return '苦战击退';
    }

    return '险胜';
}

function battle_log_text(array $monster, string $resultLabel): string
{
    $battleText = trim((string) ($monster['battle_text'] ?? ''));
    if ($battleText !== '') {
        return $battleText;
    }

    return $resultLabel . ' ' . $monster['name'];
}

function battle_reward_factor(array $battleLogs): float
{
    if (count($battleLogs) === 0) {
        return 1.0;
    }

    $total = 0.0;
    foreach ($battleLogs as $battleLog) {
        $total += (float) $battleLog['reward_factor'];
    }

    return round($total / count($battleLogs), 3);
}

function extra_chance_for_reward(string $resourceKey, array $levels, string $routeKey): int
{
    if ($resourceKey === 'blood_mist_sample') {
        return ($levels['blood_contract_control'] ?? 0) * 5;
    }

    if ($resourceKey === 'atlas_echo') {
        return ($levels['magie_echo'] ?? 0) * 3;
    }

    if ($resourceKey === 'old_empire_fragment' && $routeKey === 'old_road_ruin_search') {
        return ($levels['maclay_archive'] ?? 0) * 2;
    }

    return 0;
}

function flat_bonus_for_reward(string $resourceKey, array $levels, string $routeKey): int
{
    if ($resourceKey === 'gold' && $routeKey === 'twilight_investigation') {
        return ($levels['twilight_guild'] ?? 0) * 2;
    }

    if ($resourceKey === 'dead_apostle_trace' && $routeKey === 'forest_edge_patrol') {
        return intdiv(($levels['shia_combat'] ?? 0), 2);
    }

    if ($resourceKey === 'maclay_mark' && $routeKey === 'old_road_ruin_search') {
        return intdiv(($levels['maclay_archive'] ?? 0), 2);
    }

    return 0;
}
