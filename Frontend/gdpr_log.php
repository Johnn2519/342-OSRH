<?php
declare(strict_types=1);

require_once __DIR__ . '/auth.php';
require_once __DIR__ . '/connect.php';

auth_require_role([1, 2]);

$error = null;
$rows = [];

try {
    $pdo = getSqlServerConnection();
    $sql = 'SELECT G.logID, GA.name AS actionName, GS.name AS statusName, G.entryDate, G.finishedDate,
                   req.username AS requester, proc.username AS processedBy
            FROM dbo.GDPR G
            JOIN dbo.GDPRACTIONS GA ON GA.gdprActionID = G.[action]
            JOIN dbo.GDPRSTATUS GS ON GS.gdprID = G.[status]
            JOIN dbo.[USER] req ON req.userID = G.requestedBy
            LEFT JOIN dbo.[USER] proc ON proc.userID = G.proccessedBy
            ORDER BY G.logID DESC';
    $rows = $pdo->query($sql)->fetchAll();
} catch (Throwable $e) {
    $error = $e->getMessage();
}
?>
<!DOCTYPE html>
<html lang="en">

<head>
    <meta charset="UTF-8">
    <title>GDPR</title>
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <link rel="stylesheet" href="css/style.css">
</head>

<body>
    <div class="page-card page">
        <h1>GDPR</h1>
        <?php if ($error): ?>
            <p class="status error">Error: <?= htmlspecialchars($error, ENT_QUOTES, 'UTF-8') ?></p><?php endif; ?>
        <?php if (!$error): ?>
            <table class="table">
                <thead>
                    <tr>
                        <th>ID</th>
                        <th>Action</th>
                        <th>Status</th>
                        <th>Requester</th>
                        <th>Processed By</th>
                        <th>Entry</th>
                        <th>Finished</th>
                    </tr>
                </thead>
                <tbody>
                    <?php foreach ($rows as $r): ?>
                        <tr>
                            <td><?= (int) $r['logID'] ?></td>
                            <td><?= htmlspecialchars($r['actionName'], ENT_QUOTES, 'UTF-8') ?></td>
                            <td><?= htmlspecialchars($r['statusName'], ENT_QUOTES, 'UTF-8') ?></td>
                            <td><?= htmlspecialchars((string) $r['requester'], ENT_QUOTES, 'UTF-8') ?></td>
                            <td><?= htmlspecialchars((string) ($r['processedBy'] ?? ''), ENT_QUOTES, 'UTF-8') ?></td>
                            <td><?= htmlspecialchars((string) $r['entryDate'], ENT_QUOTES, 'UTF-8') ?></td>
                            <td><?= htmlspecialchars((string) ($r['finishedDate'] ?? ''), ENT_QUOTES, 'UTF-8') ?></td>
                        </tr>
                    <?php endforeach; ?>
                </tbody>
            </table>
        <?php endif; ?>
    </div>
</body>

</html>