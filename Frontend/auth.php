<?php
declare(strict_types=1);

require_once __DIR__ . '/connect.php';

function auth_start_session(): void
{
    if (session_status() !== PHP_SESSION_ACTIVE) {
        session_start();
    }
}

function auth_login(string $username, string $password): array
{
    auth_start_session();
    $pdo = getSqlServerConnection();
    $stmt = $pdo->prepare('SELECT userID, username, password, userType, name, surname FROM [dbo].[USER] WHERE username = :u');
    $stmt->execute([':u' => $username]);
    $row = $stmt->fetch();

    if (!$row) {
        throw new RuntimeException('Invalid credentials.');
    }

    $stored = $row['password'];
    $ok = hash_equals($stored, $password);

    if (!$ok) {
        throw new RuntimeException('Invalid credentials.');
    }

    $_SESSION['user'] = [
        'id' => (int) $row['userID'],
        'username' => $row['username'],
        'name' => $row['name'],
        'surname' => $row['surname'],
        'role' => (int) $row['userType'],
    ];

    return $_SESSION['user'];
}

function auth_logout(): void
{
    auth_start_session();
    $_SESSION = [];
    session_destroy();
}

function auth_current_user(): ?array
{
    auth_start_session();
    return $_SESSION['user'] ?? null;
}

function auth_require_role(array $allowedRoles): void
{
    $user = auth_current_user();
    if (!$user || !in_array($user['role'], $allowedRoles, true)) {
        header('Location: index.php');
        exit;
    }
}
