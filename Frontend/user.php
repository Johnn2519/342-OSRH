<?php
declare(strict_types=1);
require_once __DIR__ . '/auth.php';
auth_require_role([4]);

if ($_SERVER['REQUEST_METHOD'] === 'POST') {
    auth_logout();
    header('Location: index.php');
    exit;
}
?>
<!DOCTYPE html>
<html lang="en">

<head>
    <meta charset="UTF-8">
    <title>User</title>
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <link rel="stylesheet" href="css/style.css">
</head>

<body>
    <div class="page">
        <div style="display:flex; justify-content:flex-end; gap:0.5rem;">
            <form method="post"><button class="btn btn-danger" type="submit">Log out</button></form>
        </div>
        <h1>User</h1>

        <h2>Ride requests and payments</h2>
        <ul class="grid-links">
            <li><a href="trip_request.php">Request a trip</a></li>
        </ul>

        <h2>Feedback</h2>
        <ul class="grid-links">
            <li><a href="feedback_submit.php">Leave ride feedback (FEEDBACK)</a></li>
        </ul>
    </div>
</body>

</html>