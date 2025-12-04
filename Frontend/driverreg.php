<?php
$regError = null;
$regSuccess = null;

if ($_SERVER['REQUEST_METHOD'] === 'POST') {
	$firstName = trim($_POST['first_name'] ?? '');
	$lastName = trim($_POST['last_name'] ?? '');
	$username = trim($_POST['username'] ?? '');
	$dob = trim($_POST['dob'] ?? '');
	$gender = $_POST['gender'] ?? '';
	$address = trim($_POST['address'] ?? '');
	$phone = trim($_POST['phone'] ?? '');
	$email = trim($_POST['email'] ?? '');
	$password = $_POST['password'] ?? '';
	$dateIssued = trim($_POST['date_issued'] ?? '');
	$expiryDate = trim($_POST['expiry_date'] ?? '');
	// capture uploaded file names (if any)
	$documentFileName = $_FILES['document_file']['name'] ?? '';
	$criminalRecordFileName = $_FILES['criminal_record_file']['name'] ?? '';
	$insuranceFileName = $_FILES['insurance_file']['name'] ?? '';

	if ($firstName === '' || $lastName === '' || $username === '' || $dob === '' || $gender === '' || $address === '' || $phone === '' || $email === '' || $password === '' || $dateIssued === '' || $expiryDate === '') {
		$regError = 'Please fill in all fields.';
	} elseif (!preg_match('/^[a-zA-Z0-9]+$/', $username)) {
		$regError = 'Username must contain only letters and numbers.';
	} elseif (!DateTime::createFromFormat('Y-m-d', $dob)) {
		$regError = 'Please enter a valid date of birth.';
	} elseif (!in_array($gender, ['male', 'female', 'non-binary', 'other'])) {
		$regError = 'Please select a valid gender.';
	} else {
		// Validate phone: allow digits, spaces, +, -, parentheses; require 7-15 digits
		$phoneDigits = preg_replace('/\D/', '', $phone);
		if (!preg_match('/^[0-9+\-\s\(\)]+$/', $phone) || strlen($phoneDigits) < 7 || strlen($phoneDigits) > 15) {
			$regError = 'Please enter a valid phone number (7–15 digits).';
		} elseif (!filter_var($email, FILTER_VALIDATE_EMAIL)) {
			$regError = 'Please enter a valid email address.';
		} elseif (strlen($password) < 8) {
			$regError = 'Password must be at least 8 characters long.';
		} elseif (!DateTime::createFromFormat('Y-m-d', $dateIssued)) {
			$regError = 'Please enter a valid date issued.';
		} elseif (!DateTime::createFromFormat('Y-m-d', $expiryDate)) {
			$regError = 'Please enter a valid expiry date.';
		} else {
			// Simulate registration success (replace with actual database insertion)
			$regSuccess = 'Registration successful. You can now log in.';
			// Optionally redirect to login after a delay
			// header('Refresh: 2; URL=index.php');
		}
	}
}
?>
<!DOCTYPE html>
<html lang="en">

<head>
	<meta charset="UTF-8">
	<title>Driver Registration</title>
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

		input,
		select {
			padding: 0.5rem;
			border-radius: 8px;
			border: 1px solid #d0d0d0;
			font-size: 0.9rem;
		}

		button {
			padding: 0.85rem;
			border: none;
			border-radius: 8px;
			background: #28a745;
			color: #fff;
			font-weight: 600;
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

		.back-link {
			margin-top: 1rem;
			text-align: center;
			font-size: 0.85rem;
		}

		.back-link a {
			color: #4a67f5;
			text-decoration: underline;
		}
	</style>
</head>

<body>
	<div class="card">
		<h1>Driver Registration</h1>
		<?php if ($regError): ?>
			<p class="status error"><?= htmlspecialchars($regError) ?></p>
		<?php elseif ($regSuccess): ?>
			<p class="status success"><?= htmlspecialchars($regSuccess) ?></p>
		<?php endif; ?>
		<form method="post" action="" enctype="multipart/form-data">
			<div>
				<label for="username">Username</label>
				<input type="text" id="username" name="username" placeholder="" required>
			</div>
			<div>
				<label for="first_name">First Name</label>
				<input type="text" id="first_name" name="first_name" placeholder="" required>
			</div>
			<div>
				<label for="last_name">Last Name</label>
				<input type="text" id="last_name" name="last_name" placeholder="" required>
			</div>
			<div>
				<label for="dob">Date of Birth</label>
				<input type="date" id="dob" name="dob" required>
			</div>
			<div>
				<label for="gender">Gender</label>
				<select id="gender" name="gender" required>
					<option value="">Select Gender</option>
					<option value="male">Male</option>
					<option value="female">Female</option>
					<option value="non-binary">Non-binary</option>
					<option value="other">Other</option>
				</select>
			</div>
			<div>
				<label for="address">Address</label>
				<input type="text" id="address" name="address" placeholder="" required>
			</div>
			<div>
				<label for="phone">Phone</label>
				<input type="text" id="phone" name="phone" placeholder="" required>
			</div>
			<div>
				<label for="email">Email</label>
				<input type="email" id="email" name="email" placeholder="" required>
			</div>
			<div>
				<label for="password">Password</label>
				<input type="password" id="password" name="password" placeholder="" required>
			</div>
			<fieldset>
				<legend>Documents</legend>
				<div>
					<label for="document_file">Drivers License</label>
					<input type="file" id="document_file" name="document_file" accept=".pdf,.jpg,.png">
				</div>
				<div>
					<label for="date_issued">Date Issued</label>
					<input type="date" id="date_issued" name="date_issued" required>
				</div>
				<div>
					<label for="expiry_date">Expiry Date</label>
					<input type="date" id="expiry_date" name="expiry_date" required>
				</div>
				<div style="margin: 1rem 0;"></div>
				<div>
					<label for="criminal_record_file">Criminal Record Certificate</label>
					<input type="file" id="criminal_record_file" name="criminal_record_file" accept=".pdf,.jpg,.png">
				</div>
				<div>
					<label for="date_issued">Date Issued</label>
					<input type="date" id="date_issued" name="date_issued" required>
				</div>
				<div>
					<label for="expiry_date">Expiry Date</label>
					<input type="date" id="expiry_date" name="expiry_date" required>
				</div>
				<div style="margin: 1rem 0;"></div>
				<div>
					<label for="insurance_file">Insurance Coverage Certificate</label>
					<input type="file" id="insurance_file" name="insurance_file" accept=".pdf,.jpg,.png">
				</div>
				<div>
					<label for="date_issued">Date Issued</label>
					<input type="date" id="date_issued" name="date_issued" required>
				</div>
				<div>
					<label for="expiry_date">Expiry Date</label>
					<input type="date" id="expiry_date" name="expiry_date" required>
				</div>
			</fieldset>
			<button type="submit">Register</button>
		</form>
		<p class="back-link">
			<a href="index.php">Back to Login</a>
		</p>
	</div>
</body>

</html>