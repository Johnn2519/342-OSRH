--4
CREATE PROCEDURE [dbo].[DriversPay]
AS
BEGIN
    SET NOCOUNT ON;
	SELECT M.driver, M.dname, M.surname, M.payYear, M.payMonth, M.payMonthName, M.monthSubTrips, M.monthAmount, T.TotalSubTrips3Years, T.TotalAmount3Years
    FROM(
        SELECT U.[userID] AS driver, U.[name] AS dname, U.[surname] AS surname, YEAR(P.[date])  AS payYear, 
			MONTH(P.[date]) AS payMonth, DATENAME(MONTH, P.[date]) AS payMonthName, COUNT(*) AS monthSubTrips, SUM(P.[price]) AS monthAmount
        FROM [dbo].[PAYMENT] AS P
        JOIN [dbo].[USER] AS U ON U.[userID]=P.[to]
        WHERE P.[type]=2 AND P.[from]=0 AND YEAR(P.[date])=YEAR(GETDATE())  -- current year
        GROUP BY U.[userID], U.[name], U.[surname], YEAR(P.[date]), MONTH(P.[date]), DATENAME(MONTH, P.[date])
    ) AS M
    JOIN(
        SELECT P.[to] AS driver, COUNT(*) AS TotalSubTrips3Years, SUM(P.[price]) AS TotalAmount3Years
        FROM [dbo].[PAYMENT] AS P
        WHERE P.[type]=2 AND P.[from]=0 AND P.[date]>=DATEADD(YEAR, -3, CONVERT(date, GETDATE()))
        GROUP BY P.[to]
    ) AS T ON T.driver=M.driver
    ORDER BY M.driver, M.payYear, M.payMonth;
END;
