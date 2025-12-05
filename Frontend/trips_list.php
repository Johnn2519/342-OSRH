<?php
declare(strict_types=1);

require_once __DIR__ . '/auth.php';
require_once __DIR__ . '/connect.php';

auth_start_session();
auth_require_role([1, 2]);

$error = null;
$rows = [];

try {
	$pdo = getSqlServerConnection();
	$stmt = $pdo->query('EXEC dbo.getAllTrips');
	$rows = $stmt->fetchAll();
} catch (Throwable $e) {
	$error = $e->getMessage();
}
?>
<!DOCTYPE html>
<html lang="en">

<head>
	<meta charset="UTF-8">
	<title>getAllTrips</title>
	<link rel="stylesheet" href="css/style.css">
</head>

<body>
	<div class="page-card page">
		<h1>Trip Listing</h1>
		<?php if ($error): ?>
			<p class="status error">Error: <?= htmlspecialchars($error, ENT_QUOTES, 'UTF-8') ?></p>
		<?php endif; ?>
		<?php if (!$error): ?>
			<table class="table">
				<thead>
					<tr>
						<th>ID</th>
						<th>Start</th>
						<th>End</th>
						<th>Start Time</th>
						<th>End Time</th>
						<th>Status</th>
						<th>Seats</th>
						<th>KG</th>
						<th>VOL</th>
						<th>Service</th>
						<th>Requested By</th>
						<th>Total</th>
					</tr>
				</thead>
				<tbody>
					<?php foreach ($rows as $r): ?>
						<tr>
							<td><?= (int) $r['tripID'] ?></td>
							<td><?= htmlspecialchars($r['startLong'] . ', ' . $r['startLat'], ENT_QUOTES, 'UTF-8') ?></td>
							<td><?= htmlspecialchars($r['endtLong'] . ', ' . $r['endLat'], ENT_QUOTES, 'UTF-8') ?></td>
							<td><?= htmlspecialchars((string) $r['startTime'], ENT_QUOTES, 'UTF-8') ?></td>
							<td><?= htmlspecialchars((string) ($r['endTime'] ?? ''), ENT_QUOTES, 'UTF-8') ?></td>
							<td><?= htmlspecialchars((string) $r['status'], ENT_QUOTES, 'UTF-8') ?></td>
							<td><?= htmlspecialchars((string) $r['seatNum'], ENT_QUOTES, 'UTF-8') ?></td>
							<td><?= htmlspecialchars((string) $r['kgNum'], ENT_QUOTES, 'UTF-8') ?></td>
							<td><?= htmlspecialchars((string) $r['volNum'], ENT_QUOTES, 'UTF-8') ?></td>
							<td><?= htmlspecialchars((string) $r['serviceType'], ENT_QUOTES, 'UTF-8') ?></td>
							<td><?= htmlspecialchars((string) $r['requestedBy'], ENT_QUOTES, 'UTF-8') ?></td>
							<td><?= htmlspecialchars((string) $r['TotalTrips'], ENT_QUOTES, 'UTF-8') ?></td>
						</tr>
					<?php endforeach; ?>
				</tbody>
			</table>
		<?php endif; ?>
	</div>
</body>

</html>