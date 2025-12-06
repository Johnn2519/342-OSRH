<?php
declare(strict_types=1);

// Include authentication and database connection
require_once __DIR__ . '/auth.php';
require_once __DIR__ . '/connect.php';

// Require driver role
auth_require_role([3]);

// Get current user
$user = auth_current_user();
// Establish database connection
$pdo = getSqlServerConnection();

// Fetch vehicle types, geofences, document statuses, and types
$vehTypes = $pdo->query('SELECT vehType, name FROM dbo.VEHTYPE ORDER BY vehType')->fetchAll();
$geofences = $pdo->query('SELECT geoID, name, longMin, longMax, latMin, latMax FROM dbo.GEOFENCE ORDER BY geoID')->fetchAll();
$docStatuses = $pdo->query('SELECT docStatusID, name FROM dbo.DOCSTATUS ORDER BY docStatusID')->fetchAll();
$docTypes = $pdo->query("SELECT docTypeID, name FROM dbo.DOCTYPE WHERE name LIKE '%insurance%' ORDER BY docTypeID")->fetchAll();
if (!$docTypes) {
    $docTypes = $pdo->query('SELECT docTypeID, name FROM dbo.DOCTYPE ORDER BY docTypeID')->fetchAll();
}

$message = null;
$error = null;
$newVehID = null;
$newDocID = null;

// Handle POST request for adding vehicle and document
if ($_SERVER['REQUEST_METHOD'] === 'POST') {
    // Extract and sanitize POST data
    $insuranceNum = (int) ($_POST['insuranceNum'] ?? 0);
    $seatNum = $_POST['seatNum'] !== '' ? (int) $_POST['seatNum'] : null;
    $kgCapacity = $_POST['kgCapacity'] !== '' ? (float) $_POST['kgCapacity'] : null;
    $volCapacity = $_POST['volCapacity'] !== '' ? (float) $_POST['volCapacity'] : null;
    $geoID = (int) ($_POST['geoID'] ?? 0);
    $vehType = (int) ($_POST['vehType'] ?? 0);
    $plate = (int) ($_POST['plate'] ?? 0);
    $available = isset($_POST['available']) ? 1 : 0;
    $ready = isset($_POST['ready']) ? 1 : 0;

    $docPath = trim($_POST['docPath'] ?? '');
    $docIssued = $_POST['docIssued'] ?? '';
    $docExpires = $_POST['docExpires'] ?? '';
    $docType = (int) ($_POST['docType'] ?? 0);
    $docStatus = (int) ($_POST['docStatus'] ?? 0);
    $docCheckedBy = $_POST['docCheckedBy'] !== '' ? (int) $_POST['docCheckedBy'] : null;

    try {
        // Validate required fields
        if (!$insuranceNum || !$geoID || !$vehType || !$plate) {
            throw new RuntimeException('Insurance number, geofence, vehicle type, and plate are required.');
        }
        if ($docPath === '' || $docIssued === '' || !$docType || !$docStatus) {
            throw new RuntimeException('Insurance document path, issued date, type, and status are required.');
        }

        // Begin transaction
        $pdo->beginTransaction();

        // Insert vehicle
        $vehStmt = $pdo->prepare('INSERT INTO dbo.VEHICLE (insuranceNum, seatNum, kgCapacity, volCapacity, geoID, vehType, driver, available, ready, plate) VALUES (:insuranceNum, :seatNum, :kgCapacity, :volCapacity, :geoID, :vehType, :driver, :available, :ready, :plate)');
        $vehStmt->execute([
            ':insuranceNum' => $insuranceNum,
            ':seatNum' => $seatNum,
            ':kgCapacity' => $kgCapacity,
            ':volCapacity' => $volCapacity,
            ':geoID' => $geoID,
            ':vehType' => $vehType,
            ':driver' => $user['id'],
            ':available' => $available,
            ':ready' => $ready,
            ':plate' => $plate,
        ]);
        $newVehID = (int) $pdo->lastInsertId();

        // Insert document
        $docStmt = $pdo->prepare('INSERT INTO dbo.DOCVEH (vehicleID, path, issued, expires, docType, checkedBy, status) VALUES (:vehicleID, :path, :issued, :expires, :docType, :checkedBy, :status)');
        $docStmt->execute([
            ':vehicleID' => $newVehID,
            ':path' => $docPath,
            ':issued' => $docIssued,
            ':expires' => $docExpires !== '' ? $docExpires : null,
            ':docType' => $docType,
            ':checkedBy' => $docCheckedBy,
            ':status' => $docStatus,
        ]);
        $newDocID = (int) $pdo->lastInsertId();

        // Commit transaction
        $pdo->commit();
        $message = 'Vehicle created (ID ' . $newVehID . ') with insurance document (ID ' . $newDocID . ').';
    } catch (Throwable $e) {
        // Rollback on error
        if ($pdo->inTransaction()) {
            $pdo->rollBack();
        }
        $error = $e->getMessage();
    }
}
?>
<!DOCTYPE html>
<html lang="en">

<head>
    <meta charset="UTF-8">
    <title>Add Vehicle</title>
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <link rel="stylesheet" href="css/style.css">
    <style>
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
        <h1>Add Vehicle</h1>
        <?php if ($error): ?>
            <p class="status error">Error: <?= htmlspecialchars($error, ENT_QUOTES, 'UTF-8') ?></p><?php endif; ?>
        <?php if ($message): ?>
            <p class="status success"><?= htmlspecialchars($message, ENT_QUOTES, 'UTF-8') ?></p><?php endif; ?>

        <form method="post" class="form-grid">
            <label>Insurance number<input type="number" name="insuranceNum" min="1" required
                    value="<?= isset($_POST['insuranceNum']) ? (int) $_POST['insuranceNum'] : '' ?>"></label>
            <label>Plate number<input type="number" name="plate" min="1" required
                    value="<?= isset($_POST['plate']) ? (int) $_POST['plate'] : '' ?>"></label>
            <label>Vehicle type
                <select name="vehType" required>
                    <option value="">Select…</option>
                    <?php foreach ($vehTypes as $vt): ?>
                        <option value="<?= (int) $vt['vehType'] ?>" <?= isset($_POST['vehType']) && (int) $_POST['vehType'] === (int) $vt['vehType'] ? 'selected' : '' ?>>
                            <?= htmlspecialchars($vt['name'], ENT_QUOTES, 'UTF-8') ?>
                        </option>
                    <?php endforeach; ?>
                </select>
            </label>
            <label>Geofence
                <select name="geoID" required>
                    <option value="">Select…</option>
                    <?php foreach ($geofences as $g): ?>
                        <option value="<?= (int) $g['geoID'] ?>" <?= isset($_POST['geoID']) && (int) $_POST['geoID'] === (int) $g['geoID'] ? 'selected' : '' ?>>ID <?= (int) $g['geoID'] ?>
                            <?= htmlspecialchars((string) ($g['name'] ?? ''), ENT_QUOTES, 'UTF-8') ?>
                        </option>
                    <?php endforeach; ?>
                </select>
            </label>
            <label>Seats<input type="number" name="seatNum" min="1"
                    value="<?= isset($_POST['seatNum']) ? (int) $_POST['seatNum'] : '' ?>"></label>
            <label>Weight capacity (kg)<input type="number" step="0.01" name="kgCapacity" min="0"
                    value="<?= isset($_POST['kgCapacity']) ? htmlspecialchars((string) $_POST['kgCapacity'], ENT_QUOTES, 'UTF-8') : '' ?>"></label>
            <label>Volume capacity (m³)<input type="number" step="0.01" name="volCapacity" min="0"
                    value="<?= isset($_POST['volCapacity']) ? htmlspecialchars((string) $_POST['volCapacity'], ENT_QUOTES, 'UTF-8') : '' ?>"></label>
            <label class="checkbox"><input type="checkbox" name="available" <?= isset($_POST['available']) ? 'checked' : '' ?>>Mark available now</label>
            <label class="checkbox"><input type="checkbox" name="ready" <?= isset($_POST['ready']) ? 'checked' : '' ?>>Mark ready now</label>

            <h2 style="grid-column: 1 / -1; margin-top: 1rem;">Insurance document</h2>
            <label>File path/label<input type="text" name="docPath" maxlength="200" required
                    value="<?= isset($_POST['docPath']) ? htmlspecialchars($_POST['docPath'], ENT_QUOTES, 'UTF-8') : '' ?>"></label>
            <label>Issued date<input type="date" name="docIssued" required
                    value="<?= isset($_POST['docIssued']) ? htmlspecialchars($_POST['docIssued'], ENT_QUOTES, 'UTF-8') : '' ?>"></label>
            <label>Expires date<input type="date" name="docExpires"
                    value="<?= isset($_POST['docExpires']) ? htmlspecialchars($_POST['docExpires'], ENT_QUOTES, 'UTF-8') : '' ?>"></label>
            <label>Document type
                <select name="docType" required>
                    <option value="">Select…</option>
                    <?php foreach ($docTypes as $dt): ?>
                        <option value="<?= (int) $dt['docTypeID'] ?>" <?= isset($_POST['docType']) && (int) $_POST['docType'] === (int) $dt['docTypeID'] ? 'selected' : '' ?>>
                            <?= htmlspecialchars($dt['name'], ENT_QUOTES, 'UTF-8') ?>
                        </option>
                    <?php endforeach; ?>
                </select>
            </label>
            <label>Status
                <select name="docStatus" required>
                    <option value="">Select…</option>
                    <?php foreach ($docStatuses as $ds): ?>
                        <option value="<?= (int) $ds['docStatusID'] ?>" <?= isset($_POST['docStatus']) && (int) $_POST['docStatus'] === (int) $ds['docStatusID'] ? 'selected' : '' ?>>
                            <?= htmlspecialchars($ds['name'], ENT_QUOTES, 'UTF-8') ?>
                        </option>
                    <?php endforeach; ?>
                </select>
            </label>
            <label>Checked by<input type="number" name="docCheckedBy" min="1"
                    value="<?= isset($_POST['docCheckedBy']) ? (int) $_POST['docCheckedBy'] : '' ?>"></label>

            <button class="btn" type="submit">Create vehicle</button>
        </form>
    </div>
    <p><a href="driver.php">Back</a></p>
</body>

</html>