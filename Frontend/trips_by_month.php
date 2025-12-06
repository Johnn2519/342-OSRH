<?php
declare(strict_types=1);

// Include authentication and database connection
require_once __DIR__ . '/auth.php';
require_once __DIR__ . '/connect.php';

// Start session and require admin or manager role
auth_start_session();
auth_require_role([1, 2]);

$error = null;
$rows = [];

// Execute stored procedure for trips by month
try {
    $pdo = getSqlServerConnection();
    $rows = $pdo->query('EXEC dbo.TripsByMonthDes')->fetchAll();
} catch (Throwable $e) {
    $error = $e->getMessage();
}
?>
<!DOCTYPE html>
<html lang="en">

<head>
    <meta charset="UTF-8">
    <title>TripsByMonthDes</title>
    <link rel="stylesheet" href="css/style.css">
</head>

<body>
    <div class="page-card page">
        <h1>Trips by Month</h1>
        <?php if ($error): ?>
            <p class="status error">Error: <?= htmlspecialchars($error, ENT_QUOTES, 'UTF-8') ?></p>
        <?php endif; ?>
        <?php if (!$error): ?>
            <table class="table">
                <thead>
                    <tr>
                        <th>Year</th>
                        <th>Month</th>
                        <th>Trips</th>
                        <th>% of Trips</th>
                    </tr>
                </thead>
                <tbody>
                    <?php foreach ($rows as $r): ?>
                        <tr>
                            <td><?= (int) $r['tripYear'] ?></td>
                            <td><?= htmlspecialchars((string) $r['tripMonth'], ENT_QUOTES, 'UTF-8') ?></td>
                            <td><?= htmlspecialchars((string) $r['tripCount'], ENT_QUOTES, 'UTF-8') ?></td>
                            <td><?= htmlspecialchars((string) $r['percentOfTrps'], ENT_QUOTES, 'UTF-8') ?>%</td>
                        </tr>
                    <?php endforeach; ?>
                </tbody>
            </table>
        <?php endif; ?>
    </div>
    <p><a href="admin.php">Back</a></p>
</body>

</html>