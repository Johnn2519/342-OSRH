<?php
declare(strict_types=1);

function getSqlServerConnection(string $database = 'ileont01'): PDO
{
	$server = 'mssql.cs.ucy.ac.cy';
	$dsn = "sqlsrv:Server={$server};Database={$database};TrustServerCertificate=1";
	$options = [
		PDO::ATTR_ERRMODE => PDO::ERRMODE_EXCEPTION,
		PDO::ATTR_DEFAULT_FETCH_MODE => PDO::FETCH_ASSOC,
	];

	try {
		return new PDO($dsn, 'ileont01', '9p7UdKA8', $options);
	} catch (PDOException $exception) {
		throw new RuntimeException('Unable to connect to MSSQL server: ' . $exception->getMessage(), 0, $exception);
	}
}
