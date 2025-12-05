<?php
declare(strict_types=1);
require_once __DIR__ . '/auth.php';

auth_start_session();
auth_require_role([1, 2]);

if ($_SERVER['REQUEST_METHOD'] === 'POST') {
    auth_logout();
    header('Location: index.php');
    exit;
}

$current = auth_current_user();
$user = htmlspecialchars($current['username'] ?? '', ENT_QUOTES, 'UTF-8');
?>
<!DOCTYPE html>
<html lang="en">

<head>
    <meta charset="UTF-8">
    <title>Admin</title>
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <link rel="stylesheet" href="css/style.css">
</head>

<body>
    <div class="shell">
        <div class="page-card">
            <div style="display:flex; justify-content:flex-end; gap:0.5rem;">
                <form method="post"><button class="btn btn-danger" type="submit">Log out</button></form>
            </div>
            <h1>Admin</h1>
            <p>Welcome, <?= $user ?>.</p>
        </div>

        <div class="page-card">
            <ul class="grid-links">
                <li><a href="trips_list.php">Trips list</a></li>
                <li><a href="trips_by_service.php">Trips by service type</a></li>
                <li><a href="trips_by_month.php">Trips by month</a></li>
                <li><a href="service_type_costs.php">Average cost per service type</a></li>
                <li><a href="trip_cost_extremes.php">Highest / lowest trip costs</a></li>
                <li><a href="reports_filters.php">Reports & Filters</a></li>
                <li><a href="service_types.php">Service Types</a></li>
                <li><a href="vehicle_standards.php">Vehicle Standards</a></li>
                <li><a href="gdpr_log.php">GDPR Log</a></li>
            </ul>
        </div>
    </div>
</body>

</html>