-- Comment: Start of driverStat procedure
--3
CREATE PROCEDURE [dbo].[driverStat] -- Create procedure to get driver statistics
AS -- Begin procedure body
BEGIN -- Start of procedure logic
    SET NOCOUNT ON; -- Suppress row count messages
	SELECT V.[vehID] AS vehicleID, U.[userID] AS userID, U.[name] AS name, U.[surname] AS surname, U.[rating] AS rating,  -- Select vehicle ID, user details, rating
		DT.totalComplSubTrips AS complSubTrips -- And total completed subtrips
	FROM [dbo].[USER] AS U -- From USER table aliased as U
	JOIN [VEHICLE] AS V ON V.[driver]=U.[userID] -- Join with VEHICLE on driver ID
	JOIN( -- Join with derived table for completed subtrips count
		SELECT VV.[driver] AS DRIVER, COUNT(SS.[subTripID]) AS totalComplSubTrips -- Select driver and count of completed subtrips
		FROM [dbo].[SUBTRIP] AS SS -- From SUBTRIP table
		JOIN [dbo].[TRIPSTATUS] AS TSTS ON TSTS.[tripStatusID]=SS.[status] -- Join with TRIPSTATUS on status
		JOIN [dbo].[VEHICLE] AS VV ON VV.[vehID]=SS.[vehicle] -- Join with VEHICLE on vehicle ID
		WHERE TSTS.[tripStatusID]=4 -- Where status is completed (4)
		GROUP BY VV.[driver] -- Group by driver
	) AS DT ON DT.driver=U.[userID] -- Join on driver ID
	WHERE U.[userType]=3 -- Where user type is driver (3)
	ORDER BY U.[userID], V.[vehID]; -- Order by user ID and vehicle ID
END; -- End of procedure body