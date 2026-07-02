<?php

declare(strict_types=1);

require __DIR__ . '/bootstrap.php';

try {
    if ($_SERVER['REQUEST_METHOD'] !== 'POST') {
        respond_error('Use POST to upgrade.', 405);
    }

    $upgradeKey = input_value('upgrade_key');
    if ($upgradeKey === null || $upgradeKey === '') {
        respond_error('Missing upgrade_key.');
    }

    $pdo = db();

    $stmt = $pdo->prepare("
        SELECT *
        FROM idle_upgrades
        WHERE upgrade_key = ?
        LIMIT 1
    ");
    $stmt->execute([$upgradeKey]);
    $upgrade = $stmt->fetch();

    if (!$upgrade) {
        respond_error('养成项不存在。', 404);
    }

    $currentLevel = (int) $upgrade['level'];
    $maxLevel = (int) $upgrade['max_level'];
    if ($currentLevel >= $maxLevel) {
        respond_error('该养成项已满级。');
    }

    $targetLevel = $currentLevel + 1;
    $costStmt = $pdo->prepare("
        SELECT c.resource_key, c.amount, r.name, r.amount AS current_amount
        FROM idle_upgrade_costs c
        JOIN idle_resources r ON r.resource_key = c.resource_key
        WHERE c.upgrade_key = ? AND c.target_level = ?
        ORDER BY r.sort_order ASC
    ");
    $costStmt->execute([$upgradeKey, $targetLevel]);
    $costs = $costStmt->fetchAll();

    if (count($costs) === 0) {
        respond_error('缺少升级消耗配置。');
    }

    foreach ($costs as $cost) {
        if ((int) $cost['current_amount'] < (int) $cost['amount']) {
            respond_error('资源不足：' . $cost['name'], 400, [
                'missing_resource' => $cost['resource_key'],
            ]);
        }
    }

    $pdo->beginTransaction();
    try {
        foreach ($costs as $cost) {
            $deduct = $pdo->prepare("
                UPDATE idle_resources
                SET amount = amount - ?
                WHERE resource_key = ?
            ");
            $deduct->execute([
                (int) $cost['amount'],
                $cost['resource_key'],
            ]);
        }

        $update = $pdo->prepare("
            UPDATE idle_upgrades
            SET level = ?
            WHERE upgrade_key = ?
        ");
        $update->execute([$targetLevel, $upgradeKey]);

        $pdo->commit();
    } catch (Throwable $e) {
        $pdo->rollBack();
        throw $e;
    }

    $upgrade['level'] = $targetLevel;

    respond_success([
        'upgrade' => $upgrade,
        'costs' => $costs,
    ]);
} catch (Throwable $e) {
    respond_error($e->getMessage(), 500);
}
