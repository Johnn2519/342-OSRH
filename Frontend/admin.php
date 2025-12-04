<?php
session_start();

if (!isset($_SESSION['user'])) {
	header('Location: index.php');
	exit;
}

if ($_SERVER['REQUEST_METHOD'] === 'POST') {
	session_unset();
	session_destroy();
	header('Location: index.php');
	exit;
}

$user = htmlspecialchars($_SESSION['user'], ENT_QUOTES, 'UTF-8');
?>
<!DOCTYPE html>
<html lang="en">
<head>
	<meta charset="UTF-8">
	<title>Admin</title>
	<meta name="viewport" content="width=device-width, initial-scale=1.0">
	<style>
		:root {
			font-family: system-ui, -apple-system, "Segoe UI", sans-serif;
			background: #f5f5f7;
			color: #1c1c1c;
		}
		body {
			margin: 0;
			min-height: 100vh;
			display: flex;
			align-items: center;
			justify-content: center;
			padding: 1rem;
		}
		.card {
			background: #fff;
			border-radius: 12px;
			padding: 2rem;
			box-shadow: 0 10px 30px rgba(0, 0, 0, 0.08);
			width: min(500px, 100%);
		}
		h1 {
			margin-top: 0;
			font-size: 1.75rem;
		}
		p {
			margin: 0 0 1.5rem;
			font-size: 1rem;
		}
		form button {
			padding: 0.85rem 1.5rem;
			border: none;
			border-radius: 8px;
			background: #e53935;
			color: #fff;
			font-weight: 600;
			cursor: pointer;
		}
	</style>
</head>
<body>
	<div class="card">
		<h1>Admin Dashboard</h1>
		<p>Welcome, <?= $user ?>.</p>
		<form method="post">
			<button type="submit">Log out</button>
		</form>
	</div>
</body>
</html>
