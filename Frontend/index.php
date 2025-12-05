<?php
declare(strict_types=1);

require_once __DIR__ . '/auth.php';

auth_start_session();
$user = auth_current_user();
if ($user) {
    switch ($user['role']) {
        case 1:
        case 2:
            header('Location: admin.php');
            break;
        case 3:
            header('Location: driver.php');
            break;
        case 4:
            header('Location: user.php');
            break;
        default:
    }
    exit;
}

$loginError = null;
$loginSuccess = null;

if ($_SERVER['REQUEST_METHOD'] === 'POST') {
	$username = trim($_POST['username'] ?? '');
	$password = trim($_POST['password'] ?? '');

	if ($username === '' || $password === '') {
		$loginError = 'Please enter both username and password.';
	} else {
		try {
			$user = auth_login($username, $password);
			$loginSuccess = 'Login successful. Redirecting...';
			switch ($user['role']) {
				case 1:
				case 2:
					header('Location: admin.php');
					break;
				case 3:
					header('Location: driver.php');
					break;
				case 4:
					header('Location: user.php');
					break;
				default:
					header('Location: admin.php');
			}
			exit;
		} catch (Throwable $e) {
			$loginError = 'Invalid credentials.';
		}
	}
}
?>
<!DOCTYPE html>
<html lang="en">

<head>
	<meta charset="UTF-8">
	<title>Login</title>
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
			width: min(400px, 100%);
		}

		h1 {
			margin-top: 0;
			font-size: 1.5rem;
		}

		form {
			display: flex;
			flex-direction: column;
			gap: 1rem;
		}

		label {
			font-weight: 600;
			font-size: 0.95rem;
		}

		input {
			padding: 0.75rem;
			border-radius: 8px;
			border: 1px solid #d0d0d0;
			font-size: 1rem;
		}

		button {
			padding: 0.85rem;
			border: none;
			border-radius: 8px;
			background: #4a67f5;
			color: #fff;
			font-weight: 600;
			font-size: 1rem;
			cursor: pointer;
		}

		.status {
			padding: 0.75rem;
			border-radius: 8px;
			font-size: 0.9rem;
		}

		.status.error {
			background: #ffe6e6;
			color: #cc1f1a;
		}

		.status.success {
			background: #e6ffed;
			color: #0f7b2d;
		}

		.dev-bypass {
			margin-top: 1rem;
			text-align: center;
			font-size: 0.85rem;
		}

		.dev-bypass a {
			color: #4a67f5;
			text-decoration: underline;
			margin: 0 0.25rem;
		}
	</style>
</head>

<body>
	<div class="card">
		<h1>Sign in</h1>
		<?php if ($loginError): ?>
			<p class="status error"><?= htmlspecialchars($loginError) ?></p>
		<?php elseif ($loginSuccess): ?>
			<p class="status success"><?= htmlspecialchars($loginSuccess) ?></p>
		<?php endif; ?>
		<form method="post" action="">
			<div>
				<label for="username">Username</label>
				<input type="text" id="username" name="username" placeholder="Enter your username" autocomplete="username" required>
			</div>
			<div>
				<label for="password">Password</label>
				<input type="password" id="password" name="password" placeholder="" required>
			</div>
			<button type="submit">Log in</button>
			<a href="userreg.php"
				style="display: inline-block; margin-top: 0.5rem; padding: 0.85rem; border: none; border-radius: 8px; background: #28a745; color: #fff; font-weight: 600; font-size: 1rem; text-decoration: none; text-align: center; width: 100%; box-sizing: border-box;">Register</a>
			<p style="text-align: center; margin-top: 0rem; font-size: 0.7rem;">
				<a href="driverreg.php"
					style="color: #4a67f5; text-decoration: underline;">I want to be a driver</a>
			</p>
		</form>
	</div>
</body>

</html>
