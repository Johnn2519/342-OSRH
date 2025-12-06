<?php
declare(strict_types=1);

// Include authentication and database connection
require_once __DIR__ . '/auth.php';
require_once __DIR__ . '/connect.php';

// Require driver or user role
auth_require_role([3, 4]);

// Get current user
$user = auth_current_user();
// Establish database connection
$pdo = getSqlServerConnection();

// Fetch drivers and recent subtrips
$drivers = $pdo->query("SELECT userID, name, surname FROM dbo.[USER] WHERE userType = 3 ORDER BY userID")->fetchAll();
$subTrips = $pdo->query('SELECT TOP 50 subTripID FROM dbo.SUBTRIP ORDER BY subTripID DESC')->fetchAll();

$message = null;
$error = null;

// Handle POST request for feedback submission
if ($_SERVER['REQUEST_METHOD'] === 'POST') {
    $subTrip = (int)($_POST['subTrip'] ?? 0);
    $to = (int)($_POST['to'] ?? 0);
    $comment = trim($_POST['comment'] ?? '');
    $rating = (int)($_POST['rating'] ?? 0);

    try {
        // Validate inputs
        if (!$subTrip || !$to || $rating < 1 || $rating > 5) {
            throw new RuntimeException('Subtrip, recipient, and rating 1-5 are required.');
        }

        // Insert feedback
        $stmt = $pdo->prepare('INSERT INTO dbo.FEEDBACK (subTrip, [from], [to], comment, rating) VALUES (:subTrip, :from, :to, :comment, :rating)');
        $stmt->execute([
            ':subTrip' => $subTrip,
            ':from' => $user['id'],
            ':to' => $to,
            ':comment' => $comment !== '' ? $comment : null,
            ':rating' => $rating,
        ]);

        $message = 'Feedback saved (ID ' . $pdo->lastInsertId() . ').';
    } catch (Throwable $e) {
        $error = $e->getMessage();
    }
}
?>
<!DOCTYPE html>
<html lang="en">
<head>
	<meta charset="UTF-8">
	<title>Feedback Submission</title>
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
		<h1>Feedback Submission</h1>
		<?php if ($error): ?><p class="status error">Error: <?= htmlspecialchars($error, ENT_QUOTES, 'UTF-8') ?></p><?php endif; ?>
		<?php if ($message): ?><p class="status success"><?= htmlspecialchars($message, ENT_QUOTES, 'UTF-8') ?></p><?php endif; ?>
		<form method="post" class="form-grid">
			<label>Subtrip
				<select name="subTrip" required>
					<option value="">Select…</option>
					<?php foreach ($subTrips as $s): ?>
						<option value="<?= (int)$s['subTripID'] ?>"><?= (int)$s['subTripID'] ?></option>
					<?php endforeach; ?>
				</select>
			</label>
			<label>To (driver)
				<select name="to" required>
					<option value="">Select…</option>
					<?php foreach ($drivers as $d): ?>
						<option value="<?= (int)$d['userID'] ?>"><?= htmlspecialchars($d['name'] . ' ' . $d['surname'], ENT_QUOTES, 'UTF-8') ?></option>
					<?php endforeach; ?>
				</select>
			</label>
			<label>Rating (1-5)<input type="number" name="rating" min="1" max="5" required></label>
			<label>Comment<textarea name="comment" maxlength="150"></textarea></label>
			<p class="hint">From user ID <?= (int)$user['id'] ?> (auto).</p>
			<button class="btn" type="submit">Submit feedback</button>
		</form>
	</div>
    <p><a href="user.php">Back</a></p>
</body>
</html>
