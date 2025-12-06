<?php
declare(strict_types=1);

// Include database connection
require_once __DIR__ . '/connect.php';

// Start session if not already started
function auth_start_session(): void
{
    if (session_status() !== PHP_SESSION_ACTIVE) {
        session_start();
    }
}

// Login function
function auth_login(string $username, string $password): array
{
    auth_start_session();
    $pdo = getSqlServerConnection();
    // Query user by username
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

    // Set session user data
    $_SESSION['user'] = [
        'id' => (int) $row['userID'],
        'username' => $row['username'],
        'name' => $row['name'],
        'surname' => $row['surname'],
        'role' => (int) $row['userType'],
    ];

    return $_SESSION['user'];
}

// Logout function
function auth_logout(): void
{
    auth_start_session();
    $_SESSION = [];
    session_destroy();
}

// Get current user from session
function auth_current_user(): ?array
{
    auth_start_session();
    return $_SESSION['user'] ?? null;
}

// Require specific roles
function auth_require_role(array $allowedRoles): void
{
    $user = auth_current_user();
    if (!$user || !in_array($user['role'], $allowedRoles, true)) {
        header('Location: index.php');
        exit;
    }
}
