<?php
declare(strict_types=1);

// Function to get SQL Server connection
function getSqlServerConnection(string $database = 'ileont01'): PDO
{
	$server = 'mssql.cs.ucy.ac.cy';
	$dsn = "sqlsrv:Server={$server};Database={$database};TrustServerCertificate=1";
	$options = [
	];

	try {
		return new PDO($dsn, 'ileont01', '9p7UdKA8', $options);
	} catch (PDOException $exception) {
		throw new RuntimeException('Unable to connect to MSSQL server: ' . $exception->getMessage(), 0, $exception);
	}
}
