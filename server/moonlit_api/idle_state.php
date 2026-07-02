<?php

declare(strict_types=1);

require __DIR__ . '/bootstrap.php';

try {
    $pdo = db();
    refresh_stage_unlocks($pdo);

    $regions = $pdo->query("
        SELECT id, region_key, name, description, sort_order, unlocked
        FROM idle_regions
        ORDER BY sort_order ASC, id ASC
    ")->fetchAll();

    $stages = $pdo->query("
        SELECT id, region_id, stage_key, name, stage_type, description,
               unlock_mode, sort_order, unlocked
        FROM idle_stages
        ORDER BY sort_order ASC, id ASC
    ")->fetchAll();

    $routes = $pdo->query("
        SELECT id, stage_id, route_key, name, duration_seconds, description,
               result_title, result_content, sort_order, unlocked
        FROM idle_routes
        ORDER BY sort_order ASC, id ASC
    ")->fetchAll();

    $resources = $pdo->query("
        SELECT resource_key, name, resource_type, amount, total_earned,
               description, sort_order
        FROM idle_resources
        ORDER BY sort_order ASC, resource_key ASC
    ")->fetchAll();

    $upgrades = $pdo->query("
        SELECT upgrade_key, name, level, max_level, description, effect_desc, sort_order
        FROM idle_upgrades
        ORDER BY sort_order ASC, upgrade_key ASC
    ")->fetchAll();

    $unlockRequirements = $pdo->query("
        SELECT req.stage_id, req.resource_key, req.required_total,
               res.name, res.total_earned
        FROM idle_stage_unlock_requirements req
        JOIN idle_resources res ON res.resource_key = req.resource_key
        ORDER BY req.stage_id ASC, res.sort_order ASC
    ")->fetchAll();

    $stageTickets = $pdo->query("
        SELECT t.stage_id, t.resource_key, t.amount,
               res.name, res.amount AS current_amount
        FROM idle_stage_tickets t
        JOIN idle_resources res ON res.resource_key = t.resource_key
        ORDER BY t.stage_id ASC, res.sort_order ASC
    ")->fetchAll();

    $active = active_expedition($pdo);

    respond_success([
        'regions' => $regions,
        'stages' => $stages,
        'routes' => $routes,
        'resources' => $resources,
        'upgrades' => $upgrades,
        'unlock_requirements' => $unlockRequirements,
        'stage_tickets' => $stageTickets,
        'active_expedition' => $active,
        'server_time' => date('Y-m-d H:i:s'),
    ]);
} catch (Throwable $e) {
    respond_error($e->getMessage(), 500);
}
