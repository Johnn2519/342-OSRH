-- Comment: Start of getAllSubTrips procedure
--1 SUBTRIP
CREATE PROCEDURE [dbo].[getAllSubTrips] -- Create procedure to get all subtrips with total count
AS -- Begin procedure body
BEGIN -- Start of procedure logic
    SET NOCOUNT ON; -- Suppress row count messages

	SELECT S.*, -- Select all columns from SUBTRIP
	COUNT(*) OVER () AS TotalSubTrips -- Add total count of subtrips
	FROM [dbo].[SUBTRIP] AS S -- From SUBTRIP table
	ORDER BY S.[trip]; -- Order by trip ID

END; -- End of procedure body
GO -- Batch separator

-- Comment: Start of getAllTrips procedure
--1 TRIP
CREATE PROCEDURE [dbo].[getAllTrips] -- Create procedure to get all trips with total count
AS -- Begin procedure body
BEGIN -- Start of procedure logic
    SET NOCOUNT ON; -- Suppress row count messages

	SELECT T.*, -- Select all columns from TRIP
	COUNT(*) OVER () AS TotalTrips -- Add total count of trips
	FROM [dbo].[TRIP] AS T -- From TRIP table
	ORDER BY T.[tripID]; -- Order by trip ID

END; -- End of procedure body
GO -- Batch separator

-- Comment: Start of GetSubtripsByServiceType procedure
--2 SUBTRIP
CREATE PROCEDURE [dbo].[GetSubtripsByServiceType] -- Create procedure to get subtrips by service type with stats
	@serviceTypeID INT -- Parameter for service type ID
AS -- Begin procedure body
BEGIN -- Start of procedure logic
    SET NOCOUNT ON; -- Suppress row count messages

	DECLARE @totalSubTrips INT; -- Declare variable for total subtrips
	SELECT @totalSubTrips=COUNT(*) -- Set total subtrips count
	FROM [dbo].[SUBTRIP]; -- From SUBTRIP table

	SELECT S.*, T.[serviceType], -- Select subtrip columns and service type
	COUNT(*) OVER () AS TotalMatchingSubTrips, -- Count of matching subtrips
	@totalSubTrips AS totalSubTrips, -- Total subtrips
	CASE  -- Calculate percentage
		WHEN @totalSubTrips=0 THEN 0 -- If no subtrips, 0%
		ELSE CAST(100.00 * COUNT(*) OVER() / @totalSubTrips AS DECIMAL(5,2)) -- Else calculate percentage
	END AS percentOfAllSubTrips -- Alias for percentage
	FROM [dbo].[SUBTRIP] AS S -- From SUBTRIP table
	JOIN [dbo].[TRIP] AS T ON T.[tripID]=S.[trip] -- Join with TRIP on trip ID
	WHERE T.[serviceType]=@serviceTypeID -- Where service type matches parameter
	ORDER BY S.[trip], S.[subTripID]; -- Order by trip and subtrip ID

END; -- End of procedure body
GO -- Batch separator

-- Comment: Start of GetTripsByServiceType procedure
--2 TRIP
CREATE PROCEDURE [dbo].[GetTripsByServiceType] -- Create procedure to get trips by service type with stats
	@serviceTypeID INT -- Parameter for service type ID
AS -- Begin procedure body
BEGIN -- Start of procedure logic
    SET NOCOUNT ON; -- Suppress row count messages

	DECLARE @totalTrips INT; -- Declare variable for total trips
	SELECT @totalTrips=COUNT(*) -- Set total trips count
	FROM [dbo].[TRIP]; -- From TRIP table

	SELECT T.*, -- Select all trip columns
	COUNT(*) OVER () AS TotalMatchingTrips, -- Count of matching trips
	@totalTrips AS totalTrips, -- Total trips
	CASE  -- Calculate percentage
		WHEN @totalTrips=0 THEN 0 -- If no trips, 0%
		ELSE CAST(100.00 * COUNT(*) OVER() / @totalTrips AS DECIMAL(5,2)) -- Else calculate percentage
	END AS percentOfAllTrips -- Alias for percentage
	FROM [dbo].[TRIP] AS T -- From TRIP table
	WHERE T.[serviceType]=@serviceTypeID -- Where service type matches parameter
	ORDER BY T.[tripID]; -- Order by trip ID
END; -- End of procedure body
GO -- Batch separator

-- Comment: Start of TripsByMonthDes procedure
--3 busy by month des
CREATE PROCEDURE [dbo].[TripsByMonthDes] -- Create procedure to get trips by month descending by count
AS -- Begin procedure body
BEGIN -- Start of procedure logic
    SET NOCOUNT ON; -- Suppress row count messages
	SELECT -- Select aggregated data
		YEAR(T.[startTime]) AS [tripYear], MONTH(T.[startTime]) AS [tripMonth], COUNT(*) AS [tripCount], -- Year, month, count
		CAST(100.00 * COUNT(*) / SUM(COUNT(*)) OVER() AS DECIMAL(5,2)) AS [percentOfTrps] -- Percentage of total trips
	FROM [dbo].[TRIP] AS T -- From TRIP table
	GROUP BY YEAR(T.[startTime]), MONTH(T.[startTime]) -- Group by year and month
	ORDER BY [tripCount], [tripYear],[tripMonth]; -- Order by count descending, then year, month
END; -- End of procedure body
GO -- Batch separator

-- Comment: Start of avgCostServType procedure
--2.1
CREATE PROCEDURE [dbo].[avgCostServType] -- Create procedure to get average cost by service type
AS -- Begin procedure body
BEGIN -- Start of procedure logic
    SET NOCOUNT ON; -- Suppress row count messages
	SELECT ST.[serviceTypeID], ST.[name] AS serviceTypeName, AVG(S.[price]) AS averageCost -- Select service type ID, name, average price
	FROM [dbo].[SERVICETYPE] AS ST -- From SERVICETYPE table
	JOIN [dbo].[TRIP] AS T ON T.[serviceType]=ST.[serviceTypeID] -- Join with TRIP on service type
	JOIN [dbo].[SUBTRIP] AS S ON S.[trip]=T.[tripID] -- Join with SUBTRIP on trip ID
	GROUP BY ST.[serviceTypeID], ST.[name] -- Group by service type
	ORDER BY ST.[serviceTypeID]; -- Order by service type ID
END; -- End of procedure body
GO -- Batch separator

-- Comment: Start of highLowCostTrips procedure
--2.2
CREATE PROCEDURE [dbo].[highLowCostTrips] -- Create procedure to get highest and lowest cost trips
AS -- Begin procedure body
BEGIN -- Start of procedure logic
    SET NOCOUNT ON; -- Suppress row count messages
	;WITH tripTotals AS( -- Common table expression for trip totals
		SELECT T.[tripID], SUM(S.[price]) AS totalCost -- Select trip ID and sum of prices
		FROM [dbo].[TRIP] AS T -- From TRIP table
		JOIN [dbo].[SUBTRIP] AS S ON S.[trip]=T.[tripID] -- Join with SUBTRIP on trip ID
		GROUP BY T.[tripID] -- Group by trip ID
	), -- End of CTE
	costStats AS( -- Another CTE for min and max costs
		SELECT -- Select min and max
		(SELECT MIN(totalCost) FROM tripTotals) AS minCost, -- Minimum cost
		(SELECT MAX(totalCost) FROM tripTotals) AS maxCost -- Maximum cost
	) -- End of CTE
	SELECT TT.[tripID], TT.[totalCost], -- Select trip ID and total cost
	CASE -- Determine category
		WHEN TT.totalCost=CS.maxCost THEN 'HIGHEST' -- If max, highest
		WHEN TT.totalCost=CS.minCost THEN 'LOWEST' -- If min, lowest
	END AS Category -- Alias for category
	FROM tripTotals TT -- From tripTotals CTE
	CROSS JOIN costStats CS -- Cross join with costStats
	WHERE TT.totalCost=CS.maxCost OR TT.totalCost=CS.minCost -- Where cost is min or max
	ORDER BY TT.totalCost DESC; -- Order by total cost descending
END; -- End of procedure body
GO -- Batch separator