<?php
declare(strict_types=1);

require_once __DIR__ . '/auth.php';
require_once __DIR__ . '/connect.php';

auth_require_role([3]);

$user = auth_current_user();
$pdo = getSqlServerConnection();

$docTypes = $pdo->query('SELECT docTypeID, name FROM dbo.DOCTYPE ORDER BY docTypeID')->fetchAll();
$docStatuses = $pdo->query('SELECT docStatusID, name FROM dbo.DOCSTATUS ORDER BY docStatusID')->fetchAll();

$message = null;
$error = null;

if ($_SERVER['REQUEST_METHOD'] === 'POST') {
	$path = trim($_POST['path'] ?? '');
	$issued = $_POST['issued'] ?? '';
	$expires = $_POST['expires'] ?? '';
	$docType = (int) ($_POST['docType'] ?? 0);
	$checkedBy = $_POST['checkedBy'] !== '' ? (int) $_POST['checkedBy'] : null;
	$status = (int) ($_POST['status'] ?? 0);

	try {
		if ($path === '' || $issued === '' || !$docType || !$status) {
			throw new RuntimeException('Please fill path, issued date, document type, and status.');
		}

		$stmt = $pdo->prepare('INSERT INTO dbo.DOCDRI (driverID, path, issued, expires, docType, checkedBy, status) VALUES (:driverID, :path, :issued, :expires, :docType, :checkedBy, :status)');
		$stmt->execute([
			':driverID' => $user['id'],
			':path' => $path,
			':issued' => $issued,
			':expires' => $expires !== '' ? $expires : null,
			':docType' => $docType,
			':checkedBy' => $checkedBy,
			':status' => $status,
		]);

		$message = 'Driver document saved (ID ' . $pdo->lastInsertId() . ').';
	} catch (Throwable $e) {
		$error = $e->getMessage();
	}
}
?>
<!DOCTYPE html>
<html lang="en">

<head>
	<meta charset="UTF-8">
	<title>Driver Document Upload</title>
	<link rel="stylesheet" href="css/style.css">
</head>

<body>
	<div class="page-card page">
		<h1>Driver Document Upload</h1>
		<?php if ($error): ?>
			<p class="status error">Error: <?= htmlspecialchars($error, ENT_QUOTES, 'UTF-8') ?></p><?php endif; ?>
		<?php if ($message): ?>
			<p class="status success"><?= htmlspecialchars($message, ENT_QUOTES, 'UTF-8') ?></p><?php endif; ?>
		<form method="post" class="form-grid">
			<label>File path/label<input type="text" name="path" maxlength="200" required></label>
			<label>Issued<input type="date" name="issued" required></label>
			<label>Expires<input type="date" name="expires"></label>
			<label>Document type
				<select name="docType" required>
					<option value="">Select…</option>
					<?php foreach ($docTypes as $dt): ?>
						<option value="<?= (int) $dt['docTypeID'] ?>">
							<?= htmlspecialchars($dt['name'], ENT_QUOTES, 'UTF-8') ?></option>
					<?php endforeach; ?>
				</select>
			</label>
			<label>Checked by<input type="number" name="checkedBy" min="1"></label>
			<label>Status
				<select name="status" required>
					<option value="">Select…</option>
					<?php foreach ($docStatuses as $ds): ?>
						<option value="<?= (int) $ds['docStatusID'] ?>">
							<?= htmlspecialchars($ds['name'], ENT_QUOTES, 'UTF-8') ?></option>
					<?php endforeach; ?>
				</select>
			</label>
			<p class="hint">Driver ID is <?= (int) $user['id'] ?> (auto).</p>
			<button class="btn" type="submit">Save document</button>
		</form>
	</div>
</body>

</html>