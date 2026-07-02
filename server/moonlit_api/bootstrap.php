<?php

declare(strict_types=1);

header('Content-Type: application/json; charset=utf-8');
header('Access-Control-Allow-Origin: *');
header('Access-Control-Allow-Methods: GET, POST, OPTIONS');
header('Access-Control-Allow-Headers: Content-Type');

if ($_SERVER['REQUEST_METHOD'] === 'OPTIONS') {
    http_response_code(204);
    exit;
}

function db(): PDO
{
    static $pdo = null;

    if ($pdo instanceof PDO) {
        return $pdo;
    }

    $configPath = __DIR__ . '/config.php';
    if (!file_exists($configPath)) {
        respond_error('Missing config.php. Copy config.example.php to config.php first.', 500);
    }

    $config = require $configPath;
    $pdo = new PDO(
        sprintf(
            'mysql:host=%s;dbname=%s;charset=utf8mb4',
            $config['db_host'],
            $config['db_name']
        ),
        $config['db_user'],
        $config['db_password'],
        [
            PDO::ATTR_ERRMODE => PDO::ERRMODE_EXCEPTION,
            PDO::ATTR_DEFAULT_FETCH_MODE => PDO::FETCH_ASSOC,
        ]
    );

    return $pdo;
}

function respond_success(array $data = []): void
{
    echo json_encode(
        array_merge(['success' => true], $data),
        JSON_UNESCAPED_UNICODE | JSON_PRETTY_PRINT
    );
    exit;
}

function respond_error(string $message, int $statusCode = 400, array $data = []): void
{
    http_response_code($statusCode);
    echo json_encode(
        array_merge([
            'success' => false,
            'message' => $message,
        ], $data),
        JSON_UNESCAPED_UNICODE | JSON_PRETTY_PRINT
    );
    exit;
}

function input_value(string $key, ?string $default = null): ?string
{
    if (isset($_POST[$key])) {
        return trim((string) $_POST[$key]);
    }

    $raw = file_get_contents('php://input');
    if ($raw !== false && $raw !== '') {
        $json = json_decode($raw, true);
        if (is_array($json) && array_key_exists($key, $json)) {
            return trim((string) $json[$key]);
        }
    }

    if (isset($_GET[$key])) {
        return trim((string) $_GET[$key]);
    }

    return $default;
}

function fetch_all_keyed(PDO $pdo, string $sql, string $key): array
{
    $rows = $pdo->query($sql)->fetchAll();
    $result = [];

    foreach ($rows as $row) {
        $result[$row[$key]] = $row;
    }

    return $result;
}

function active_expedition(PDO $pdo): ?array
{
    $stmt = $pdo->query("
        SELECT e.*, r.route_key, r.name AS route_name, r.duration_seconds,
               s.stage_key, s.name AS stage_name
        FROM idle_expeditions e
        JOIN idle_routes r ON r.id = e.route_id
        JOIN idle_stages s ON s.id = e.stage_id
        WHERE e.status IN ('running', 'finished')
        ORDER BY e.id DESC
        LIMIT 1
    ");
    $expedition = $stmt->fetch();

    if (!$expedition) {
        return null;
    }

    return normalize_expedition($expedition);
}

function normalize_expedition(array $expedition): array
{
    $now = time();
    $finishAt = strtotime($expedition['finish_at']);
    $startedAt = strtotime($expedition['started_at']);
    $duration = max(1, $finishAt - $startedAt);
    $elapsed = max(0, min($duration, $now - $startedAt));
    $remaining = max(0, $finishAt - $now);

    $expedition['remaining_seconds'] = $remaining;
    $expedition['progress'] = round($elapsed / $duration, 4);
    $expedition['can_claim'] = $remaining === 0 && $expedition['claimed_at'] === null;

    if ($expedition['status'] === 'running' && $remaining === 0) {
        $expedition['status'] = 'finished';
    }

    return $expedition;
}

function upgrade_levels(PDO $pdo): array
{
    $rows = $pdo->query("SELECT upgrade_key, level FROM idle_upgrades")->fetchAll();
    $levels = [];

    foreach ($rows as $row) {
        $levels[$row['upgrade_key']] = (int) $row['level'];
    }

    return $levels;
}

function duration_with_upgrades(int $baseDuration, array $levels): int
{
    $combatLevel = $levels['shia_combat'] ?? 0;
    $rate = max(0.70, 1 - ($combatLevel * 0.03));

    return max(10, (int) round($baseDuration * $rate));
}

function refresh_stage_unlocks(PDO $pdo): void
{
    $stages = $pdo->query("
        SELECT id
        FROM idle_stages
        WHERE unlock_mode = 'requirements'
    ")->fetchAll();

    foreach ($stages as $stage) {
        $stmt = $pdo->prepare("
            SELECT req.resource_key, req.required_total,
                   COALESCE(res.total_earned, 0) AS total_earned
            FROM idle_stage_unlock_requirements req
            LEFT JOIN idle_resources res ON res.resource_key = req.resource_key
            WHERE req.stage_id = ?
        ");
        $stmt->execute([$stage['id']]);
        $requirements = $stmt->fetchAll();

        if (count($requirements) === 0) {
            continue;
        }

        $unlocked = true;
        foreach ($requirements as $requirement) {
            if ((int) $requirement['total_earned'] < (int) $requirement['required_total']) {
                $unlocked = false;
                break;
            }
        }

        if ($unlocked) {
            $update = $pdo->prepare("UPDATE idle_stages SET unlocked = 1 WHERE id = ?");
            $update->execute([$stage['id']]);
        }
    }
}

function resource_requirements(PDO $pdo, int $stageId): array
{
    $stmt = $pdo->prepare("
        SELECT t.resource_key, t.amount, r.name, r.amount AS current_amount
        FROM idle_stage_tickets t
        JOIN idle_resources r ON r.resource_key = t.resource_key
        WHERE t.stage_id = ?
        ORDER BY r.sort_order ASC
    ");
    $stmt->execute([$stageId]);

    return $stmt->fetchAll();
}

function ensure_ticket_available(array $tickets): void
{
    foreach ($tickets as $ticket) {
        if ((int) $ticket['current_amount'] < (int) $ticket['amount']) {
            respond_error('线索门票不足：' . $ticket['name'], 400, [
                'missing_resource' => $ticket['resource_key'],
            ]);
        }
    }
}

function deduct_tickets(PDO $pdo, array $tickets): void
{
    foreach ($tickets as $ticket) {
        $stmt = $pdo->prepare("
            UPDATE idle_resources
            SET amount = amount - ?
            WHERE resource_key = ?
        ");
        $stmt->execute([(int) $ticket['amount'], $ticket['resource_key']]);
    }
}
