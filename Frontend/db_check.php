<?php
declare(strict_types=1);
// Include database connection
require_once __DIR__ . '/connect.php';

header('Content-Type: application/json');

// Initialize result array
$result = [
    'ok' => false,
    'error' => null,
    'serverVersion' => null,
    'counts' => [],
];

try {
    // Establish connection
    $pdo = getSqlServerConnection();
    $result['serverVersion'] = $pdo->getAttribute(PDO::ATTR_SERVER_VERSION);

    // Define tables to count
    $tables = ['USER','USERTYPE','VEHICLE','DOCVEH','DOCDRI','TRIP','SUBTRIP','PAYMENT'];
    foreach ($tables as $t) {
        // Get count for each table
        $stmt = $pdo->query("SELECT COUNT(*) AS c FROM [$t]");
        $result['counts'][$t] = (int)$stmt->fetch()['c'];
    }

    $result['ok'] = true;
} catch (Throwable $e) {
    $result['error'] = $e->getMessage();
}

// Output JSON
echo json_encode($result, JSON_PRETTY_PRINT);
