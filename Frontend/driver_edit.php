<?php
declare(strict_types=1);

require_once __DIR__ . '/auth.php';
require_once __DIR__ . '/connect.php';

auth_require_role([3]);

$user = auth_current_user();
$pdo = getSqlServerConnection();

$message = null;
$error = null;

$stmt = $pdo->prepare('SELECT name, surname, email, phone, address FROM dbo.[USER] WHERE userID = :id');
$stmt->execute([':id' => $user['id']]);
$current = $stmt->fetch();

if ($_SERVER['REQUEST_METHOD'] === 'POST') {
    $name = trim($_POST['name'] ?? '');
    $surname = trim($_POST['surname'] ?? '');
    $email = trim($_POST['email'] ?? '');
    $phone = trim($_POST['phone'] ?? '');
    $address = trim($_POST['address'] ?? '');

    try {
        if ($name === '' || $surname === '' || $email === '' || $phone === '' || $address === '') {
            throw new RuntimeException('All fields are required.');
        }
        if (!filter_var($email, FILTER_VALIDATE_EMAIL)) {
            throw new RuntimeException('Invalid email address.');
        }

        $stmt = $pdo->prepare('UPDATE dbo.[USER] SET name = :name, surname = :surname, email = :email, phone = :phone, address = :address WHERE userID = :id');
        $stmt->execute([
            ':name' => $name,
            ':surname' => $surname,
            ':email' => $email,
            ':phone' => $phone,
            ':address' => $address,
            ':id' => $user['id'],
        ]);

        $message = 'Information updated successfully.';
        $_SESSION['user']['name'] = $name;
        $_SESSION['user']['surname'] = $surname;
    } catch (Throwable $e) {
        $error = $e->getMessage();
    }
}
?>
<!DOCTYPE html>
<html lang="en">

<head>
    <meta charset="UTF-8">
    <title>Edit Driver Information</title>
    <link rel="stylesheet" href="css/style.css">
</head>

<body>
    <div class="page-card page">
        <h1>Edit Driver Information</h1>
        <?php if ($error): ?>
            <p class="status error">Error: <?= htmlspecialchars($error, ENT_QUOTES, 'UTF-8') ?></p><?php endif; ?>
        <?php if ($message): ?>
            <p class="status success"><?= htmlspecialchars($message, ENT_QUOTES, 'UTF-8') ?></p><?php endif; ?>
        <form method="post" class="form-grid">
            <label>Name<input type="text" name="name"
                    value="<?= htmlspecialchars($current['name'], ENT_QUOTES, 'UTF-8') ?>" required></label>
            <label>Surname<input type="text" name="surname"
                    value="<?= htmlspecialchars($current['surname'], ENT_QUOTES, 'UTF-8') ?>" required></label>
            <label>Email<input type="email" name="email"
                    value="<?= htmlspecialchars($current['email'], ENT_QUOTES, 'UTF-8') ?>" required></label>
            <label>Phone<input type="text" name="phone"
                    value="<?= htmlspecialchars($current['phone'], ENT_QUOTES, 'UTF-8') ?>" required></label>
            <label>Address<input type="text" name="address"
                    value="<?= htmlspecialchars($current['address'], ENT_QUOTES, 'UTF-8') ?>" required></label>
            <button class="btn" type="submit">Submit</button>
        </form>
        <p><a href="driver.php">Back</a></p>
    </div>
</body>

</html>