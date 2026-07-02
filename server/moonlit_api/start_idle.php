<?php

declare(strict_types=1);

require __DIR__ . '/bootstrap.php';

try {
    if ($_SERVER['REQUEST_METHOD'] !== 'POST') {
        respond_error('Use POST to start an expedition.', 405);
    }

    $routeKey = input_value('route_key');
    if ($routeKey === null || $routeKey === '') {
        respond_error('Missing route_key.');
    }

    $pdo = db();
    refresh_stage_unlocks($pdo);

    if (active_expedition($pdo) !== null) {
        respond_error('已有探索正在进行或等待领取。');
    }

    $stmt = $pdo->prepare("
        SELECT r.*, s.id AS stage_id, s.stage_key, s.name AS stage_name,
               s.unlocked AS stage_unlocked, s.stage_type
        FROM idle_routes r
        JOIN idle_stages s ON s.id = r.stage_id
        WHERE r.route_key = ?
        LIMIT 1
    ");
    $stmt->execute([$routeKey]);
    $route = $stmt->fetch();

    if (!$route) {
        respond_error('探索路线不存在。', 404);
    }

    if ((int) $route['unlocked'] !== 1 || (int) $route['stage_unlocked'] !== 1) {
        respond_error('该探索路线尚未解锁。');
    }

    $tickets = resource_requirements($pdo, (int) $route['stage_id']);

    $pdo->beginTransaction();
    try {
        if (count($tickets) > 0) {
            ensure_ticket_available($tickets);
            deduct_tickets($pdo, $tickets);
        }

        $levels = upgrade_levels($pdo);
        $duration = duration_with_upgrades((int) $route['duration_seconds'], $levels);
        $finishAt = date('Y-m-d H:i:s', time() + $duration);

        $insert = $pdo->prepare("
            INSERT INTO idle_expeditions
            (route_id, stage_id, status, started_at, finish_at, result_title, result_content)
            VALUES (?, ?, 'running', NOW(), ?, ?, ?)
        ");
        $insert->execute([
            (int) $route['id'],
            (int) $route['stage_id'],
            $finishAt,
            $route['result_title'],
            $route['result_content'],
        ]);

        $expeditionId = (int) $pdo->lastInsertId();
        $pdo->commit();
    } catch (Throwable $e) {
        $pdo->rollBack();
        throw $e;
    }

    $stmt = $pdo->prepare("
        SELECT e.*, r.route_key, r.name AS route_name, r.duration_seconds,
               s.stage_key, s.name AS stage_name
        FROM idle_expeditions e
        JOIN idle_routes r ON r.id = e.route_id
        JOIN idle_stages s ON s.id = e.stage_id
        WHERE e.id = ?
    ");
    $stmt->execute([$expeditionId]);
    $expedition = normalize_expedition($stmt->fetch());

    respond_success([
        'expedition' => $expedition,
    ]);
} catch (Throwable $e) {
    respond_error($e->getMessage(), 500);
}
