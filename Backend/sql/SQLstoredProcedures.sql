
--1 SUBTRIP
CREATE PROCEDURE [dbo].[getAllSubTrips]
AS
BEGIN
    SET NOCOUNT ON;

	SELECT S.*,
	COUNT(*) OVER () AS TotalSubTrips
	FROM [dbo].[SUBTRIP] AS S
	ORDER BY S.[trip];

END;

--1 TRIP
CREATE PROCEDURE [dbo].[getAllTrips]
AS
BEGIN
    SET NOCOUNT ON;

	SELECT T.*,
	COUNT(*) OVER () AS TotalTrips
	FROM [dbo].[TRIP] AS T
	ORDER BY T.[tripID];

END;

--2 SUBTRIP
CREATE PROCEDURE [dbo].[GetSubtripsByServiceType]
	@serviceTypeID INT
AS
BEGIN
    SET NOCOUNT ON;

	DECLARE @totalSubTrips INT;
	SELECT @totalSubTrips=COUNT(*)
	FROM [dbo].[SUBTRIP];

	SELECT S.*, T.[serviceType],
	COUNT(*) OVER () AS TotalMatchingSubTrips,
	@totalSubTrips AS totalSubTrips,
	CASE 
		WHEN @totalSubTrips=0 THEN 0
		ELSE CAST(100.00 * COUNT(*) OVER() / @totalSubTrips AS DECIMAL(5,2))
	END AS percentOfAllSubTrips
	FROM [dbo].[SUBTRIP] AS S
	JOIN [dbo].[TRIP] AS T ON T.[tripID]=S.[trip]
	WHERE T.[serviceType]=@serviceTypeID
	ORDER BY S.[trip], S.[subTripID];

END;

--2 TRIP
CREATE PROCEDURE [dbo].[GetTripsByServiceType]
	@serviceTypeID INT
AS
BEGIN
    SET NOCOUNT ON;

	DECLARE @totalTrips INT;
	SELECT @totalTrips=COUNT(*)
	FROM [dbo].[TRIP];

	SELECT T.*,
	COUNT(*) OVER () AS TotalMatchingTrips,
	@totalTrips AS totalTrips,
	CASE 
		WHEN @totalTrips=0 THEN 0
		ELSE CAST(100.00 * COUNT(*) OVER() / @totalTrips AS DECIMAL(5,2))
	END AS percentOfAllTrips
	FROM [dbo].[TRIP] AS T
	WHERE T.[serviceType]=@serviceTypeID
	ORDER BY T.[tripID];
END;

--3 busy by month des
CREATE PROCEDURE [dbo].[TripsByMonthDes]
AS
BEGIN
    SET NOCOUNT ON;
	SELECT
		YEAR(T.[startTime]) AS [tripYear], MONTH(T.[startTime]) AS [tripMonth], COUNT(*) AS [tripCount],
		CAST(100.00 * COUNT(*) / SUM(COUNT(*)) OVER() AS DECIMAL(5,2)) AS [percentOfTrps]
	FROM [dbo].[TRIP] AS T
	GROUP BY YEAR(T.[startTime]), MONTH(T.[startTime])
	ORDER BY [tripCount], [tripYear],[tripMonth];
END;

--2.1
CREATE PROCEDURE [dbo].[avgCostServType]
AS
BEGIN
    SET NOCOUNT ON;
	SELECT ST.[serviceTypeID], ST.[name] AS serviceTypeName, AVG(S.[price]) AS averageCost
	FROM [dbo].[SERVICETYPE] AS ST
	JOIN [dbo].[TRIP] AS T ON T.[serviceType]=ST.[serviceTypeID]
	JOIN [dbo].[SUBTRIP] AS S ON S.[trip]=T.[tripID]
	GROUP BY ST.[serviceTypeID], ST.[name]
	ORDER BY ST.[serviceTypeID];
END;

--2.2
CREATE PROCEDURE [dbo].[highLowCostTrips]
AS
BEGIN
    SET NOCOUNT ON;
	;WITH tripTotals AS(
		SELECT T.[tripID], SUM(S.[price]) AS totalCost
		FROM [dbo].[TRIP] AS T
		JOIN [dbo].[SUBTRIP] AS S ON S.[trip]=T.[tripID]
		GROUP BY T.[tripID]
	),
	costStats AS(
		SELECT
		(SELECT MIN(totalCost) FROM tripTotals) AS minCost,
		(SELECT MAX(totalCost) FROM tripTotals) AS maxCost
	)
	SELECT TT.[tripID], TT.[totalCost],
	CASE
		WHEN TT.totalCost=CS.maxCost THEN 'HIGHEST'
		WHEN TT.totalCost=CS.minCost THEN 'LOWEST'
	END AS Category
	FROM tripTotals TT
	CROSS JOIN costStats CS
	WHERE TT.totalCost=CS.maxCost OR TT.totalCost=CS.minCost
	ORDER BY TT.totalCost DESC;
END;