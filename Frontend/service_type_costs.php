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
	$rows = $pdo->query('EXEC dbo.avgCostServType')->fetchAll();
} catch (Throwable $e) {
	$error = $e->getMessage();
}
?>
<!DOCTYPE html>
<html lang="en">

<head>
	<meta charset="UTF-8">
	<title> avgCostServType</title>
	<link rel="stylesheet" href="css/style.css">
</head>

<body>
	<div class="page-card page">
		<h1>Average Cost per Service Type</h1>
		<?php if ($error): ?>
			<p class="status error">Error: <?= htmlspecialchars($error, ENT_QUOTES, 'UTF-8') ?></p>
		<?php endif; ?>
		<?php if (!$error): ?>
			<table class="table">
				<thead>
					<tr>
						<th>Service Type</th>
						<th>Name</th>
						<th>Average Cost</th>
					</tr>
				</thead>
				<tbody>
					<?php foreach ($rows as $r): ?>
						<tr>
							<td><?= (int) $r['serviceTypeID'] ?></td>
							<td><?= htmlspecialchars((string) $r['serviceTypeName'], ENT_QUOTES, 'UTF-8') ?></td>
							<td><?= htmlspecialchars((string) $r['averageCost'], ENT_QUOTES, 'UTF-8') ?></td>
						</tr>
					<?php endforeach; ?>
				</tbody>
			</table>
		<?php endif; ?>
	</div>
</body>

</html>