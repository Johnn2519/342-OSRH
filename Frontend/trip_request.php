<?php
declare(strict_types=1);

// Include authentication and database connection
require_once __DIR__ . '/auth.php';
require_once __DIR__ . '/connect.php';

// Require admin, manager, or user role
auth_require_role([1, 4]);

// Get current user
$user = auth_current_user();
// Establish database connection
$pdo = getSqlServerConnection();

// Fetch statuses and service types
$statuses = $pdo->query('SELECT tripStatusID, name FROM dbo.TRIPSTATUS ORDER BY tripStatusID')->fetchAll();
$serviceTypes = $pdo->query('SELECT serviceTypeID, name FROM dbo.SERVICETYPE ORDER BY serviceTypeID')->fetchAll();

// Find requested status ID
$requestedId = null;
foreach ($statuses as $s) {
    if (strtolower($s['name']) === 'requested') {
        $requestedId = (int) $s['tripStatusID'];
        break;
    }
}

$message = null;
$error = null;

// Handle POST request for trip request
if ($_SERVER['REQUEST_METHOD'] === 'POST') {
    // Extract and validate data
    $data = [
        'startLong' => $_POST['startLong'] ?? '',
        'startLat' => $_POST['startLat'] ?? '',
        'endtLong' => $_POST['endtLong'] ?? '',
        'endLat' => $_POST['endLat'] ?? '',
        'startTime' => date('Y-m-d\TH:i:s'),
        'endTime' => $_POST['endTime'] ?? '',
        'status' => $requestedId,
        'seatNum' => $_POST['seatNum'] !== '' ? (int) $_POST['seatNum'] : null,
        'kgNum' => $_POST['kgNum'] !== '' ? (float) $_POST['kgNum'] : null,
        'volNum' => $_POST['volNum'] !== '' ? (float) $_POST['volNum'] : null,
        'serviceType' => (int) ($_POST['serviceType'] ?? 0),
    ];

    try {
        // Validate required fields
        if ($data['startLong'] === '' || !is_numeric($data['startLong']) || $data['startLat'] === '' || !is_numeric($data['startLat']) || $data['endtLong'] === '' || !is_numeric($data['endtLong']) || $data['endLat'] === '' || !is_numeric($data['endLat']) || !$data['status'] || !$data['serviceType']) {
            throw new RuntimeException('Please fill all required fields with valid data.');
        }

        // Insert trip into database
        $stmt = $pdo->prepare('INSERT INTO dbo.TRIP (startLong, startLat, endtLong, endLat, startTime, endTime, status, seatNum, kgNum, volNum, serviceType, requestedBy) VALUES (:startLong, :startLat, :endtLong, :endLat, :startTime, :endTime, :status, :seatNum, :kgNum, :volNum, :serviceType, :requestedBy)');
        $stmt->execute([
            ':startLong' => (float) $data['startLong'],
            ':startLat' => (float) $data['startLat'],
            ':endtLong' => (float) $data['endtLong'],
            ':endLat' => (float) $data['endLat'],
            ':startTime' => $data['startTime'],
            ':endTime' => $data['endTime'] !== '' ? $data['endTime'] : null,
            ':status' => $data['status'],
            ':seatNum' => $data['seatNum'],
            ':kgNum' => $data['kgNum'],
            ':volNum' => $data['volNum'],
            ':serviceType' => $data['serviceType'],
            ':requestedBy' => $user['id'],
        ]);

        $message = 'Trip saved with ID ' . $pdo->lastInsertId();
    } catch (Throwable $e) {
        $error = $e->getMessage();
    }
}
?>
<!DOCTYPE html>
<html lang="en">

<head>
    <meta charset="UTF-8">
    <title>Trip Request</title>
    <link rel="stylesheet" href="css/style.css">
    <link rel="stylesheet" href="https://unpkg.com/leaflet@1.9.4/dist/leaflet.css"
        integrity="sha256-p4NxAoJBhIIN+hmNHrzRCf9tD/miZyoHS5obTRR9BMY=" crossorigin="">
    <style>
        #map {
            height: 360px;
            width: 100%;
            min-height: 360px;
            background: #f9f9f9;
            border: 1px solid #e5e5e5;
            border-radius: 10px;
            margin-bottom: 1rem;
            position: relative;
        }

        .map-controls {
            display: flex;
            gap: 1rem;
            margin-bottom: 0.5rem;
            align-items: center;
            flex-wrap: wrap;
        }

        input,
        select,
        textarea {
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
        <h1>Trip Request</h1>
        <?php if ($error): ?>
            <p class="status error">Error: <?= htmlspecialchars($error, ENT_QUOTES, 'UTF-8') ?></p>
        <?php endif; ?>
        <?php if ($message): ?>
            <p class="status success"><?= htmlspecialchars($message, ENT_QUOTES, 'UTF-8') ?></p>
        <?php endif; ?>
        <div class="section">
            <div class="map-controls">
                <label class="checkbox"><input type="radio" name="pinTarget" value="start" checked> Set start
                    pin</label>
                <label class="checkbox"><input type="radio" name="pinTarget" value="end"> Set destination pin</label>
            </div>
            <div id="map"></div>
        </div>

        <form method="post" class="form-grid" id="trip-form">
            <label style="display: none;">Start longitude<input type="number" step="0.000001" name="startLong"
                    required></label>
            <label style="display: none;">Start latitude<input type="number" step="0.000001" name="startLat"
                    required></label>
            <label style="display: none;">End longitude<input type="number" step="0.000001" name="endtLong"
                    required></label>
            <label style="display: none;">End latitude<input type="number" step="0.000001" name="endLat"
                    required></label>
            <label>End time<input type="datetime-local" name="endTime"></label>
            <label>Seats<input type="number" name="seatNum" min="0"></label>
            <label>KG<input type="number" step="0.01" name="kgNum" min="0"></label>
            <label>Volume<input type="number" step="0.01" name="volNum" min="0"></label>
            <label>Service type
                <select name="serviceType" required>
                    <option value="">Select…</option>
                    <?php foreach ($serviceTypes as $st): ?>
                        <option value="<?= (int) $st['serviceTypeID'] ?>">
                            <?= htmlspecialchars($st['name'], ENT_QUOTES, 'UTF-8') ?>
                        </option>
                    <?php endforeach; ?>
                </select>
            </label>
            <button class="btn" type="submit">Submit request</button>
        </form>
        <p class="hint">Requested by user ID <?= (int) $user['id'] ?> (auto-filled).</p>
    </div>

    <script src="https://unpkg.com/leaflet@1.9.4/dist/leaflet.js"
        integrity="sha256-20nQCchB9co0qIjJZRGuk2/Z9VM+kNiyxNV1lvTlZBo=" crossorigin="" defer></script>
    <script src="js/trip_map.js" defer></script>
</body>
    <p><a href="user.php">Back</a></p>
</html>