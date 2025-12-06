<?php
declare(strict_types=1);

// Include authentication and database connection
require_once __DIR__ . '/auth.php';
require_once __DIR__ . '/connect.php';

// Require admin or manager role
auth_require_role([1, 2]);

// Establish database connection
$pdo = getSqlServerConnection();

$message = null;
$error = null;

// Handle POST request for adding service type
if ($_SERVER['REQUEST_METHOD'] === 'POST') {
    $name = trim($_POST['name'] ?? '');
    $description = trim($_POST['description'] ?? '');
    $minPayment = $_POST['minPayment'] ?? '';
    $moneyRate = $_POST['moneyRate'] ?? '';
    $unit = trim($_POST['unit'] ?? '');

    try {
        // Validate inputs
        if ($name === '' || $description === '' || $minPayment === '' || !is_numeric($minPayment) || $moneyRate === '' || !is_numeric($moneyRate) || $unit === '') {
            throw new RuntimeException('Fill all fields with valid data.');
        }

        // Insert service type
        $stmt = $pdo->prepare('INSERT INTO dbo.SERVICETYPE (minPayment, description, name, moneyRate, unit) VALUES (:minPayment,:description,:name,:moneyRate,:unit)');
        $stmt->execute([
            ':minPayment' => (float) $minPayment,
            ':description' => $description,
            ':name' => $name,
            ':moneyRate' => (float) $moneyRate,
            ':unit' => $unit,
        ]);
        $message = 'Service type created (ID ' . $pdo->lastInsertId() . ').';
    } catch (Throwable $e) {
        $error = $e->getMessage();
    }
}

// Fetch existing service types
$types = $pdo->query('SELECT serviceTypeID, name, description, minPayment, moneyRate, unit FROM dbo.SERVICETYPE ORDER BY serviceTypeID')->fetchAll();
?>
<!DOCTYPE html>
<html lang="en">

<head>
    <meta charset="UTF-8">
    <title>Service Types</title>
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
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
        <h1>Service Types</h1>
        <?php if ($error): ?>
            <p class="status error">Error: <?= htmlspecialchars($error, ENT_QUOTES, 'UTF-8') ?></p><?php endif; ?>
        <?php if ($message): ?>
            <p class="status success"><?= htmlspecialchars($message, ENT_QUOTES, 'UTF-8') ?></p><?php endif; ?>

        <form method="post" class="form-grid">
            <label>Name<input type="text" name="name" maxlength="50" required></label>
            <label>Description<input type="text" name="description" maxlength="100" required></label>
            <label>Minimum payment<input type="number" step="0.01" name="minPayment" required></label>
            <label>Rate<input type="number" step="0.01" name="moneyRate" required></label>
            <label>Unit (e.g., km/min)<input type="text" name="unit" maxlength="10" required></label>
            <button class="btn" type="submit">Add service type</button>
        </form>

        <h2>Existing service types</h2>
        <table class="table">
            <thead>
                <tr>
                    <th>ID</th>
                    <th>Name</th>
                    <th>Description</th>
                    <th>Min payment</th>
                    <th>Rate</th>
                    <th>Unit</th>
                </tr>
            </thead>
            <tbody>
                <?php foreach ($types as $t): ?>
                    <tr>
                        <td><?= (int) $t['serviceTypeID'] ?></td>
                        <td><?= htmlspecialchars($t['name'], ENT_QUOTES, 'UTF-8') ?></td>
                        <td><?= htmlspecialchars($t['description'], ENT_QUOTES, 'UTF-8') ?></td>
                        <td><?= htmlspecialchars((string) $t['minPayment'], ENT_QUOTES, 'UTF-8') ?></td>
                        <td><?= htmlspecialchars((string) $t['moneyRate'], ENT_QUOTES, 'UTF-8') ?></td>
                        <td><?= htmlspecialchars($t['unit'], ENT_QUOTES, 'UTF-8') ?></td>
                    </tr>
                <?php endforeach; ?>
            </tbody>
        </table>
    </div>
    <p><a href="admin.php">Back</a></p>
</body>

</html>