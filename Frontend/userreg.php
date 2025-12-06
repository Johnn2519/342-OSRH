<?php
declare(strict_types=1);

// Include database connection
require_once __DIR__ . '/connect.php';

$regError = null;
$regSuccess = null;

// Establish database connection
$pdo = getSqlServerConnection();
// Fetch genders for dropdown
$genders = $pdo->query('SELECT genderID, name FROM dbo.GENDER ORDER BY genderID')->fetchAll();

// Handle POST request for user registration
if ($_SERVER['REQUEST_METHOD'] === 'POST') {
    // Extract and sanitize POST data
    $firstName = trim($_POST['first_name'] ?? '');
    $lastName = trim($_POST['last_name'] ?? '');
    $username = trim($_POST['username'] ?? '');
    $dob = trim($_POST['dob'] ?? '');
    $gender = $_POST['gender'] ?? '';
    $address = trim($_POST['address'] ?? '');
    $phone = trim($_POST['phone'] ?? '');
    $email = trim($_POST['email'] ?? '');
    $password = $_POST['password'] ?? '';

    // Basic validation
    if ($firstName === '' || $lastName === '' || $username === '' || $dob === '' || $gender === '' || $address === '' || $phone === '' || $email === '' || $password === '') {
        $regError = 'Please fill in all fields.';
    } elseif (!preg_match('/^[a-zA-Z0-9]+$/', $username)) {
        $regError = 'Username must contain only letters and numbers.';
    } else {
        // Validate date of birth
        $dobObj = DateTime::createFromFormat('Y-m-d', $dob);
        $dobValid = $dobObj && $dobObj->format('Y-m-d') === $dob;
        if (!$dobValid) {
            $regError = 'Please enter a valid date of birth.';
        } elseif ($dobObj > new DateTime('today')) {
            $regError = 'Date of birth must be in the past.';
        } else {
            // Validate phone number
            $phoneDigits = preg_replace('/\D/', '', $phone);
            if (!preg_match('/^[0-9+\-\s\(\)]+$/', $phone) || strlen($phoneDigits) < 7 || strlen($phoneDigits) > 15) {
                $regError = 'Please enter a valid phone number (7–15 digits).';
            } elseif (!filter_var($email, FILTER_VALIDATE_EMAIL)) {
                $regError = 'Please enter a valid email address.';
            } elseif (strlen($password) < 8) {
                $regError = 'Password must be at least 8 characters long.';
            } else {
                // Find gender ID
                $genderId = null;
                foreach ($genders as $g) {
                    if (strcasecmp($g['name'], $gender) === 0) {
                        $genderId = (int) $g['genderID'];
                        break;
                    }
                }
                $genderId = $genderId ?? (int) ($genders[0]['genderID'] ?? 1);

                try {
                    // Insert user into database
                    $stmt = $pdo->prepare('INSERT INTO dbo.[USER] (username, name, surname, dob, gender, email, address, phone, userType, password) VALUES (:username,:name,:surname,:dob,:gender,:email,:address,:phone,:userType,:password)');
                    $stmt->execute([
                        ':username' => $username,
                        ':name' => $firstName,
                        ':surname' => $lastName,
                        ':dob' => $dob,
                        ':gender' => $genderId,
                        ':email' => $email,
                        ':address' => $address,
                        ':phone' => $phone,
                        ':userType' => 4,
                        ':password' => $password,
                    ]);
                    $regSuccess = 'Registration successful. You can now log in.';
                } catch (Throwable $e) {
                    $regError = $e->getMessage();
                }
            }
        }
    }
}
?>
<!DOCTYPE html>
<html lang="en">

<head>
    <meta charset="UTF-8">
    <title>User Registration</title>
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
            padding: 0.75rem;
            border-radius: 8px;
            border: 1px solid #d0d0d0;
            font-size: 1rem;
        }

        button {
            padding: 0.85rem;
            border: none;
            border-radius: 8px;
            background: #28a745;
            color: #fff;
            font-weight: 600;
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
        <h1>User Registration</h1>
        <?php if ($regError): ?>
            <p class="status error"><?= htmlspecialchars($regError) ?></p>
        <?php elseif ($regSuccess): ?>
            <p class="status success"><?= htmlspecialchars($regSuccess) ?></p>
        <?php endif; ?>
        <form method="post" action="">
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
                <input type="date" id="dob" name="dob" max="<?= date('Y-m-d'); ?>" required>
            </div>
            <div>
                <label for="gender">Gender</label>
                <select id="gender" name="gender" required>
                    <option value="">Select Gender</option>
                    <?php foreach ($genders as $g): ?>
                        <option value="<?= htmlspecialchars($g['name'], ENT_QUOTES, 'UTF-8') ?>">
                            <?= htmlspecialchars($g['name'], ENT_QUOTES, 'UTF-8') ?></option>
                    <?php endforeach; ?>
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
            <button type="submit">Register</button>
        </form>
        <p class="back-link">
            <a href="index.php">Back to Login</a>
        </p>
    </div>
</body>

</html>