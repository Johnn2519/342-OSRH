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
$serviceType = null;
$serviceTypes = [];

// Fetch service types and handle filtering
try {
    $pdo = getSqlServerConnection();
    $serviceTypes = $pdo->query('SELECT serviceTypeID, name FROM dbo.SERVICETYPE ORDER BY serviceTypeID')->fetchAll();

    if ($_SERVER['REQUEST_METHOD'] === 'POST') {
        $serviceType = isset($_POST['serviceType']) ? (int) $_POST['serviceType'] : null;
        if ($serviceType) {
            // Execute stored procedure with parameter
            $stmt = $pdo->prepare('EXEC dbo.GetTripsByServiceType @serviceTypeID = :sid');
            $stmt->execute([':sid' => $serviceType]);
            $rows = $stmt->fetchAll();
        }
    }
} catch (Throwable $e) {
    $error = $e->getMessage();
}
?>
<!DOCTYPE html>
<html lang="en">

<head>
    <meta charset="UTF-8">
    <title>GetTripsByServiceType</title>
    <link rel="stylesheet" href="css/style.css">
    <style>
        input, select, textarea {
            padding: 0.75rem;
            border-radius: 8px;
            border: 1px solid #d0d0d0;
            font-size: 1rem;
        }
        button.btn {
            padding: 0.85rem;
            border: none;
            border-radius: 8px;
            background: #4a67f5;
            color: #fff;
            font-weight: 600;
        }
    </style>
</head>

<body>
    <div class="page-card page">
        <h1>Trips by Service Type</h1>
        <?php if ($error): ?>
            <p class="status error">Error: <?= htmlspecialchars($error, ENT_QUOTES, 'UTF-8') ?></p>
        <?php endif; ?>
        <form method="post" class="section">
            <label for="serviceType">Service type</label>
            <select name="serviceType" id="serviceType" required>
                <option value="">Select…</option>
                <?php foreach ($serviceTypes as $type): ?>
                    <option value="<?= (int) $type['serviceTypeID'] ?>" <?= ($serviceType === (int) $type['serviceTypeID']) ? 'selected' : '' ?>>
                        <?= htmlspecialchars($type['name'], ENT_QUOTES, 'UTF-8') ?>
                    </option>
                <?php endforeach; ?>
            </select>
            <button class="btn" type="submit">Filter</button>
        </form>

        <?php if ($rows): ?>
            <table class="table">
                <thead>
                    <tr>
                        <th>ID</th>
                        <th>Start</th>
                        <th>End</th>
                        <th>Start Time</th>
                        <th>Status</th>
                        <th>Seats</th>
                        <th>KG</th>
                        <th>VOL</th>
                        <th>Requested By</th>
                        <th>Total Matching</th>
                        <th>Total</th>
                        <th>% of All</th>
                    </tr>
                </thead>
                <tbody>
                    <?php foreach ($rows as $r): ?>
                        <tr>
                            <td><?= (int) $r['tripID'] ?></td>
                            <td><?= htmlspecialchars($r['startLong'] . ', ' . $r['startLat'], ENT_QUOTES, 'UTF-8') ?></td>
                            <td><?= htmlspecialchars($r['endtLong'] . ', ' . $r['endLat'], ENT_QUOTES, 'UTF-8') ?></td>
                            <td><?= htmlspecialchars((string) $r['startTime'], ENT_QUOTES, 'UTF-8') ?></td>
                            <td><?= htmlspecialchars((string) $r['status'], ENT_QUOTES, 'UTF-8') ?></td>
                            <td><?= htmlspecialchars((string) $r['seatNum'], ENT_QUOTES, 'UTF-8') ?></td>
                            <td><?= htmlspecialchars((string) $r['kgNum'], ENT_QUOTES, 'UTF-8') ?></td>
                            <td><?= htmlspecialchars((string) $r['volNum'], ENT_QUOTES, 'UTF-8') ?></td>
                            <td><?= htmlspecialchars((string) $r['requestedBy'], ENT_QUOTES, 'UTF-8') ?></td>
                            <td><?= htmlspecialchars((string) $r['TotalMatchingTrips'], ENT_QUOTES, 'UTF-8') ?></td>
                            <td><?= htmlspecialchars((string) $r['totalTrips'], ENT_QUOTES, 'UTF-8') ?></td>
                            <td><?= htmlspecialchars((string) $r['percentOfAllTrips'], ENT_QUOTES, 'UTF-8') ?>%</td>
                        </tr>
                    <?php endforeach; ?>
                </tbody>
            </table>
        <?php elseif ($serviceType && !$error): ?>
            <p class="status">No trips found for that service type.</p>
        <?php endif; ?>
    </div>
    <p><a href="admin.php">Back</a></p>
</body>

</html>