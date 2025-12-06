<?php
declare(strict_types=1);
// Include authentication functions
require_once __DIR__ . '/auth.php';
// Require driver role
auth_require_role([3]);

// Handle logout POST request
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
    <title>Driver</title>
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <link rel="stylesheet" href="css/style.css">
</head>

<body>
    <div class="page">
        <div style="display:flex; justify-content:flex-end; gap:0.5rem;">
            <form method="post"><button class="btn btn-danger" type="submit">Log out</button></form>
        </div>
        <h1>Driver</h1>

        <ul class="grid-links">
            <li><a href="doc_driver_upload.php">Upload driver documents</a></li>
            <li><a href="vehicle_add.php">Register vehicle</a></li>
            <li><a href="driver_edit.php">Edit your information</a></li>
        </ul>

        <ul class="grid-links">
        </ul>

    </div>
</body>

</html>