<?php
declare(strict_types=1);
require_once __DIR__ . '/connect.php';

header('Content-Type: application/json');

$result = [
    'ok' => false,
    'error' => null,
    'serverVersion' => null,
    'counts' => [],
];

try {
    $pdo = getSqlServerConnection();
    $result['serverVersion'] = $pdo->getAttribute(PDO::ATTR_SERVER_VERSION);

    $tables = ['USER','USERTYPE','VEHICLE','DOCVEH','DOCDRI','TRIP','SUBTRIP','PAYMENT'];
    foreach ($tables as $t) {
        $stmt = $pdo->query("SELECT COUNT(*) AS c FROM [$t]");
        $result['counts'][$t] = (int)$stmt->fetch()['c'];
    }

    $result['ok'] = true;
} catch (Throwable $e) {
    $result['error'] = $e->getMessage();
}

echo json_encode($result, JSON_PRETTY_PRINT);
