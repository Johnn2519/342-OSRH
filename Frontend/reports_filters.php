<?php
declare(strict_types=1);

require_once __DIR__ . '/auth.php';
require_once __DIR__ . '/connect.php';

auth_require_role([1, 2]);

$error = null;
$stats = [];
$byService = [];

try {
    $pdo = getSqlServerConnection();
    $stats = $pdo->query(
        'SELECT 
            (SELECT COUNT(*) FROM dbo.TRIP) AS trips,
            (SELECT COUNT(*) FROM dbo.SUBTRIP) AS subtrips,
            (SELECT COUNT(*) FROM dbo.PAYMENT) AS payments,
            (SELECT COUNT(*) FROM dbo.FEEDBACK) AS feedbacks,
            (SELECT COUNT(*) FROM dbo.[USER] WHERE userType = 3) AS drivers,
            (SELECT COUNT(*) FROM dbo.[USER] WHERE userType = 4) AS passengers'
    )->fetch();

    $byService = $pdo->query('SELECT S.serviceTypeID, S.name, COUNT(T.tripID) AS trips FROM dbo.SERVICETYPE S LEFT JOIN dbo.TRIP T ON T.serviceType = S.serviceTypeID GROUP BY S.serviceTypeID, S.name ORDER BY S.serviceTypeID')->fetchAll();
} catch (Throwable $e) {
    $error = $e->getMessage();
}
?>
<!DOCTYPE html>
<html lang="en">

<head>
    <meta charset="UTF-8">
    <title>Reports & Filters</title>
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <link rel="stylesheet" href="css/style.css">
</head>

<body>
    <div class="page-card page">
        <h1>Reports</h1>
        <?php if ($error): ?>
            <p class="status error">Error: <?= htmlspecialchars($error, ENT_QUOTES, 'UTF-8') ?></p><?php endif; ?>
        <?php if (!$error): ?>
            <div class="section">
                <h2>Snapshot</h2>
                <ul>
                    <li>Trips: <?= (int) $stats['trips'] ?> | Subtrips: <?= (int) $stats['subtrips'] ?></li>
                    <li>Payments: <?= (int) $stats['payments'] ?> | Feedback: <?= (int) $stats['feedbacks'] ?></li>
                    <li>Drivers: <?= (int) $stats['drivers'] ?> | Passengers: <?= (int) $stats['passengers'] ?></li>
                </ul>
            </div>

            <div class="section">
                <h2>Trips by service type</h2>
                <table class="table">
                    <thead>
                        <tr>
                            <th>Service</th>
                            <th>Trips</th>
                        </tr>
                    </thead>
                    <tbody>
                        <?php foreach ($byService as $row): ?>
                            <tr>
                                <td><?= htmlspecialchars($row['name'], ENT_QUOTES, 'UTF-8') ?>
                                    (<?= (int) $row['serviceTypeID'] ?>)</td>
                                <td><?= (int) $row['trips'] ?></td>
                            </tr>
                        <?php endforeach; ?>
                    </tbody>
                </table>
            </div>
        <?php endif; ?>
    </div>
</body>

</html>