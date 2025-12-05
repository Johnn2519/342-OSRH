--3
CREATE PROCEDURE [dbo].[driverStat]
AS
BEGIN
    SET NOCOUNT ON;
	SELECT V.[vehID] AS vehicleID, U.[userID] AS userID, U.[name] AS name, U.[surname] AS surname, U.[rating] AS rating, 
		DT.totalComplSubTrips AS complSubTrips
	FROM [dbo].[USER] AS U
	JOIN [VEHICLE] AS V ON V.[driver]=U.[userID]
	JOIN(
		SELECT VV.[driver] AS DRIVER, COUNT(SS.[subTripID]) AS totalComplSubTrips
		FROM [dbo].[SUBTRIP] AS SS
		JOIN [dbo].[TRIPSTATUS] AS TSTS ON TSTS.[tripStatusID]=SS.[status]
		JOIN [dbo].[VEHICLE] AS VV ON VV.[vehID]=SS.[vehicle]
		WHERE TSTS.[tripStatusID]=4
		GROUP BY VV.[driver]
	) AS DT ON DT.driver=U.[userID]
	WHERE U.[userType]=3
	ORDER BY U.[userID], V.[vehID];
END;