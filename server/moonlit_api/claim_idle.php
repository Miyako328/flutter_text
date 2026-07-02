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
    $rewards = roll_rewards($rewardRules, $levels, $expedition['route_key']);

    $pdo->beginTransaction();
    try {
        $updateExpedition = $pdo->prepare("
            UPDATE idle_expeditions
            SET status = 'claimed', claimed_at = NOW()
            WHERE id = ?
        ");
        $updateExpedition->execute([(int) $expedition['id']]);

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
    ]);
} catch (Throwable $e) {
    respond_error($e->getMessage(), 500);
}

function roll_rewards(array $rules, array $levels, string $routeKey): array
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
