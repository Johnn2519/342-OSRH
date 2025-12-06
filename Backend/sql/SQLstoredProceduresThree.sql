-- Comment: Start of DriversPay procedure
--4
CREATE PROCEDURE [dbo].[DriversPay] -- Create procedure to get drivers' pay statistics
AS -- Begin procedure body
BEGIN -- Start of procedure logic
    SET NOCOUNT ON; -- Suppress row count messages
	SELECT M.driver, M.dname, M.surname, M.payYear, M.payMonth, M.payMonthName, M.monthSubTrips, M.monthAmount, T.TotalSubTrips3Years, T.TotalAmount3Years -- Select monthly and 3-year totals
    FROM( -- From derived table for monthly payments
        SELECT U.[userID] AS driver, U.[name] AS dname, U.[surname] AS surname, YEAR(P.[date])  AS payYear,  -- Select driver details and year
			MONTH(P.[date]) AS payMonth, DATENAME(MONTH, P.[date]) AS payMonthName, COUNT(*) AS monthSubTrips, SUM(P.[price]) AS monthAmount -- Month, name, count, sum
        FROM [dbo].[PAYMENT] AS P -- From PAYMENT table
        JOIN [dbo].[USER] AS U ON U.[userID]=P.[to] -- Join with USER on recipient
        WHERE P.[type]=2 AND P.[from]=0 AND YEAR(P.[date])=YEAR(GETDATE()) -- Where type is driver payment, from system, current year
        GROUP BY U.[userID], U.[name], U.[surname], YEAR(P.[date]), MONTH(P.[date]), DATENAME(MONTH, P.[date]) -- Group by driver and date parts
    ) AS M -- Alias for monthly table
    JOIN( -- Join with derived table for 3-year totals
        SELECT P.[to] AS driver, COUNT(*) AS TotalSubTrips3Years, SUM(P.[price]) AS TotalAmount3Years -- Select driver, count, sum for last 3 years
        FROM [dbo].[PAYMENT] AS P -- From PAYMENT table
        WHERE P.[type]=2 AND P.[from]=0 AND P.[date]>=DATEADD(YEAR, -3, CONVERT(date, GETDATE())) -- Where type driver payment, from system, last 3 years
        GROUP BY P.[to] -- Group by recipient
    ) AS T ON T.driver=M.driver -- Join on driver ID
    ORDER BY M.driver, M.payYear, M.payMonth; -- Order by driver, year, month
END; -- End of procedure body

