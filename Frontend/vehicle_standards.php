<?php
declare(strict_types=1);

require_once __DIR__ . '/auth.php';
require_once __DIR__ . '/connect.php';

auth_require_role([1, 2]);

$pdo = getSqlServerConnection();
$serviceTypes = $pdo->query('SELECT serviceTypeID, name FROM dbo.SERVICETYPE ORDER BY name')->fetchAll();

$message = null;
$error = null;

if ($_SERVER['REQUEST_METHOD'] === 'POST') {
    $service = (int) ($_POST['service'] ?? 0);
    $description = trim($_POST['description'] ?? '');

    try {
        if (!$service || $description === '') {
            throw new RuntimeException('Select a service type and enter a requirement.');
        }

        $stmt = $pdo->prepare('INSERT INTO dbo.SERVREQ (service, description) VALUES (:service, :description)');
        $stmt->execute([
            ':service' => $service,
            ':description' => $description,
        ]);
        $message = 'Requirement added (ID ' . $pdo->lastInsertId() . ').';
    } catch (Throwable $e) {
        $error = $e->getMessage();
    }
}

$requirements = $pdo->query('SELECT R.servReqID, R.description, S.name AS serviceName FROM dbo.SERVREQ R JOIN dbo.SERVICETYPE S ON S.serviceTypeID = R.service ORDER BY R.servReqID DESC')->fetchAll();
?>
<!DOCTYPE html>
<html lang="en">

<head>
    <meta charset="UTF-8">
    <title>Vehicle Standards</title>
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <link rel="stylesheet" href="css/style.css">
</head>

<body>
    <div class="page-card page">
        <h1>Vehicle Standards per Service Type</h1>
        <?php if ($error): ?>
            <p class="status error">Error: <?= htmlspecialchars($error, ENT_QUOTES, 'UTF-8') ?></p><?php endif; ?>
        <?php if ($message): ?>
            <p class="status success"><?= htmlspecialchars($message, ENT_QUOTES, 'UTF-8') ?></p><?php endif; ?>

        <form method="post" class="form-grid">
            <label>Service type
                <select name="service" required>
                    <option value="">Select…</option>
                    <?php foreach ($serviceTypes as $st): ?>
                        <option value="<?= (int) $st['serviceTypeID'] ?>">
                            <?= htmlspecialchars($st['name'], ENT_QUOTES, 'UTF-8') ?></option>
                    <?php endforeach; ?>
                </select>
            </label>
            <label>Requirement<textarea name="description" maxlength="200" required></textarea></label>
            <button class="btn" type="submit">Add requirement</button>
        </form>

        <h2>Requirements</h2>
        <table class="table">
            <thead>
                <tr>
                    <th>ID</th>
                    <th>Service</th>
                    <th>Description</th>
                </tr>
            </thead>
            <tbody>
                <?php foreach ($requirements as $r): ?>
                    <tr>
                        <td><?= (int) $r['servReqID'] ?></td>
                        <td><?= htmlspecialchars($r['serviceName'], ENT_QUOTES, 'UTF-8') ?></td>
                        <td><?= htmlspecialchars($r['description'], ENT_QUOTES, 'UTF-8') ?></td>
                    </tr>
                <?php endforeach; ?>
            </tbody>
        </table>
    </div>
</body>

</html>