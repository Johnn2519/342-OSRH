/* ============================================================
   EXTRA BULK DATA – ADD 8 500 MORE ROWS PER MAIN TABLE
   (excludes lookup/type tables, respects triggers & constraints)
   ============================================================ */

---------------------------------------------------------------
-- 0. Helper numbers table 1..8500
---------------------------------------------------------------
IF OBJECT_ID('tempdb..#Nums8500') IS NOT NULL DROP TABLE #Nums8500;

SELECT TOP (8500)
       ROW_NUMBER() OVER (ORDER BY (SELECT NULL)) AS n
INTO #Nums8500
FROM sys.all_objects;


---------------------------------------------------------------
-- 1. USER – add 8 500 extra users
---------------------------------------------------------------
INSERT INTO [dbo].[USER]
    ([username],[name],[surname],[dob],[gender],[email],[address],[phone],[userType],[rating],[password])
SELECT
    CONCAT('bulk2user', n.n)                                           AS [username],
    CONCAT(N'Bulk2Name', n.n)                                          AS [name],
    CONCAT(N'Bulk2Surname', n.n)                                       AS [surname],
    DATEADD(YEAR, - (20 + (n.n % 30)), CONVERT(date, GETDATE()))       AS [dob],
    ((n.n % 4) + 1)                                                    AS [gender],
    CONCAT('bulk2_', n.n, '@example.com')                              AS [email],
    CONCAT(N'Bulk2 Address ', n.n)                                     AS [address],
    CONCAT('+3578', RIGHT('0000000' + CAST(n.n AS varchar(7)), 7))     AS [phone],
    CASE (n.n % 5)
        WHEN 1 THEN 1
        WHEN 2 THEN 2
        WHEN 3 THEN 3
        WHEN 4 THEN 4
        ELSE 5
    END                                                                AS [userType],
    NULL                                                               AS [rating],
    N'Bulk2!123'                                                       AS [password]
FROM #Nums8500 n;


---------------------------------------------------------------
-- 2. VEHICLE – add 8 500 extra vehicles
---------------------------------------------------------------
DECLARE @plateStart2 int = (SELECT ISNULL(MAX([plate]), 1000) + 1 FROM [dbo].[VEHICLE]);

INSERT INTO [dbo].[VEHICLE]
    ([insuranceNum],[seatNum],[kgCapacity],[volCapacity],[geoID],[vehType],[driver],[available],[ready],[plate])
SELECT
    400000 + n.n                                                       AS [insuranceNum],
    CASE WHEN n.n % 2 = 1 THEN 4 ELSE NULL END                         AS [seatNum],
    CASE WHEN n.n % 2 = 1 THEN NULL ELSE 600.0 END                     AS [kgCapacity],
    CASE WHEN n.n % 2 = 1 THEN NULL ELSE 6.0 END                       AS [volCapacity],
    (SELECT TOP 1 geoID FROM [dbo].[GEOFENCE] ORDER BY NEWID())        AS [geoID],
    (SELECT TOP 1 vehType FROM [dbo].[VEHTYPE] ORDER BY NEWID())       AS [vehType],
    (SELECT TOP 1 userID FROM [dbo].[USER] WHERE [userType]=3 ORDER BY NEWID()) AS [driver],
    1                                                                  AS [available],
    1                                                                  AS [ready],
    @plateStart2 + n.n                                                 AS [plate]
FROM #Nums8500 n;


---------------------------------------------------------------
-- 3. GEOFENCE – add 8 500 extra geofences
---------------------------------------------------------------
INSERT INTO [dbo].[GEOFENCE]
    ([longMax],[latMax],[longMin],[latMin],[name])
SELECT
    33.500000 + (n.n * 0.0001)                                         AS [longMax],
    35.500000 + (n.n * 0.0001)                                         AS [latMax],
    33.400000 + (n.n * 0.0001)                                         AS [longMin],
    35.400000 + (n.n * 0.0001)                                         AS [latMin],
    CONCAT(N'ExtraGeo', n.n)                                           AS [name]
FROM #Nums8500 n;


---------------------------------------------------------------
-- 4. BRIDGE – add 8 500 extra bridges
---------------------------------------------------------------
INSERT INTO [dbo].[BRIDGE]
    ([longtitude],[latitude],[name])
SELECT
    33.600000 + (n.n * 0.0001)                                         AS [longtitude],
    35.600000 + (n.n * 0.0001)                                         AS [latitude],
    CONCAT(N'ExtraBridge', n.n)                                        AS [name]
FROM #Nums8500 n;


---------------------------------------------------------------
-- 5. CONNECT – add 8 500 extra bridge–geo connections
---------------------------------------------------------------
INSERT INTO [dbo].[CONNECT]
    ([bridgeID],[geoID])
SELECT
    (SELECT TOP 1 bridgeID FROM [dbo].[BRIDGE] ORDER BY NEWID())       AS [bridgeID],
    (SELECT TOP 1 geoID    FROM [dbo].[GEOFENCE] ORDER BY NEWID())     AS [geoID]
FROM #Nums8500 n;


---------------------------------------------------------------
-- 6. AVAILABILITY – add 8 500 extra records
---------------------------------------------------------------
INSERT INTO [dbo].[AVAILABILITY]
    ([avStart],[avEnd],[car])
SELECT
    CASE WHEN n.n % 2 = 1
         THEN DATEADD(HOUR, -(n.n % 720), GETDATE())
         ELSE NULL
    END                                                                AS [avStart],
    CASE WHEN n.n % 2 = 0
         THEN DATEADD(HOUR, -(n.n % 720), GETDATE())
         ELSE NULL
    END                                                                AS [avEnd],
    (SELECT TOP 1 vehID FROM [dbo].[VEHICLE] WHERE [ready]=1 ORDER BY NEWID()) AS [car]
FROM #Nums8500 n;


---------------------------------------------------------------
-- 7. TRIP – add 8 500 extra trips
---------------------------------------------------------------
INSERT INTO [dbo].[TRIP]
    ([startLong],[startLat],[endtLong],[endLat],
     [startTime],[endTime],[reqTime],[status],
     [seatNum],[kgNum],[volNum],
     [serviceType],[requestedBy])
SELECT
    33.700000 + (n.n * 0.0001)                                         AS [startLong],
    35.700000 + (n.n * 0.0001)                                         AS [startLat],
    33.800000 + (n.n * 0.0001)                                         AS [endtLong],
    35.800000 + (n.n * 0.0001)                                         AS [endLat],
    DATEADD(MINUTE, -(n.n % 60000), GETDATE())                         AS [startTime],  -- spread more
    NULL                                                               AS [endTime],
    DATEADD(MINUTE, -((n.n + 20) % 60000), GETDATE())                  AS [reqTime],
    1                                                                  AS [status],
    CASE WHEN n.n % 3 IN (0,2) THEN 1 ELSE NULL END                    AS [seatNum],
    CASE WHEN n.n % 3 IN (1,2) THEN 70.0 ELSE NULL END                 AS [kgNum],
    CASE WHEN n.n % 3 IN (1,2) THEN 2.0 ELSE NULL END                  AS [volNum],
    (SELECT TOP 1 serviceTypeID FROM [dbo].[SERVICETYPE] ORDER BY NEWID()) AS [serviceType],
    (SELECT TOP 1 userID        FROM [dbo].[USER] WHERE [userType]=4 ORDER BY NEWID())   AS [requestedBy]
FROM #Nums8500 n;


---------------------------------------------------------------
-- 8. SUBTRIP – add 8 500 extra subtrips
---------------------------------------------------------------
INSERT INTO [dbo].[SUBTRIP]
    ([startLong],[startLat],[endtLong],[endLat],
     [startTime],[endTime],[status],[price],
     [vehicle],[trip])
SELECT
    t.startLong,
    t.startLat,
    t.endtLong,
    t.endLat,
    DATEADD(MINUTE, (n.n % 90), t.startTime)                           AS [startTime],
    NULL                                                               AS [endTime],
    1                                                                  AS [status],
    CAST(6.00 + (n.n % 60) AS smallmoney)                              AS [price],
    (SELECT TOP 1 vehID FROM [dbo].[VEHICLE] ORDER BY NEWID())         AS [vehicle],
    t.tripID                                                           AS [trip]
FROM #Nums8500 n
CROSS APPLY (
    SELECT TOP 1 *
    FROM [dbo].[TRIP]
    ORDER BY NEWID()
) t;


---------------------------------------------------------------
-- 9. FEES – add 8 500 extra fee records
---------------------------------------------------------------
INSERT INTO [dbo].[FEES]
    ([serviceType],[amount],[startDate],[endDate])
SELECT
    (SELECT TOP 1 serviceTypeID FROM [dbo].[SERVICETYPE] ORDER BY NEWID()) AS [serviceType],
    CAST(2.00 + (n.n % 25) AS smallmoney)                              AS [amount],
    DATEADD(DAY, -(n.n % 730), GETDATE())                               AS [startDate],
    NULL                                                               AS [endDate]
FROM #Nums8500 n;


---------------------------------------------------------------
-- 10. PAYMENT – add 8 500 extra payments
---------------------------------------------------------------
INSERT INTO [dbo].[PAYMENT]
    ([date],[method],[from],[to],[subTrip],[price],[type])
SELECT
    DATEADD(MINUTE, -(n.n % 40000), GETDATE())                         AS [date],
    (SELECT TOP 1 paymentMethodID FROM [dbo].[PAYMENTMETHOD] ORDER BY NEWID()) AS [method],
    (SELECT TOP 1 userID FROM [dbo].[USER] WHERE [userType]=4 ORDER BY NEWID()) AS [from],
    drv.userID                                                         AS [to],
    st.subTripID                                                       AS [subTrip],
    CAST(4.00 + (n.n % 100) AS smallmoney)                             AS [price],
    1                                                                  AS [type]
FROM #Nums8500 n
CROSS APPLY (
    SELECT TOP 1 s.subTripID, v.vehID, v.driver
    FROM [dbo].[SUBTRIP] s
    JOIN [dbo].[VEHICLE] v ON v.vehID = s.[vehicle]
    ORDER BY NEWID()
) st
JOIN [dbo].[USER] drv ON drv.userID = st.driver AND drv.userType = 3;


---------------------------------------------------------------
-- 11. FEEDBACK – add up to 8 500 extra feedbacks
--      but NEVER more than 2 per subTrip
---------------------------------------------------------------
;WITH SubTripCap AS (
    SELECT
        s.subTripID,
        COUNT(f.feedID) AS existing,
        2 - COUNT(f.feedID) AS capacity
    FROM [dbo].[SUBTRIP] s
    LEFT JOIN [dbo].[FEEDBACK] f ON f.subTrip = s.subTripID
    GROUP BY s.subTripID
    HAVING COUNT(f.feedID) < 2
),
Expanded AS (
    SELECT subTripID
    FROM SubTripCap
    CROSS APPLY (
        SELECT 1 AS slot
        WHERE capacity >= 1
        UNION ALL
        SELECT 2
        WHERE capacity = 2
    ) c
),
Targets AS (
    SELECT TOP (8500)
        ROW_NUMBER() OVER (ORDER BY subTripID) AS rn,
        subTripID
    FROM Expanded
)
INSERT INTO [dbo].[FEEDBACK]
    ([entryDate],[comment],[subTrip],[from],[to],[rating])
SELECT
    DATEADD(MINUTE, - (t.rn % 40000), GETDATE())                       AS [entryDate],
    CONCAT(N'Extra bulk feedback ', t.rn)                              AS [comment],
    t.subTripID                                                        AS [subTrip],
    (SELECT TOP 1 userID FROM [dbo].[USER] WHERE [userType]=4 ORDER BY NEWID()) AS [from],
    (SELECT TOP 1 userID FROM [dbo].[USER] WHERE [userType]=3 ORDER BY NEWID()) AS [to],
    CAST(1 + (t.rn % 5) AS tinyint)                                    AS [rating]
FROM Targets t;


---------------------------------------------------------------
-- 12. TRIPLOG – add 8 500 extra triplog rows
---------------------------------------------------------------
INSERT INTO [dbo].[TRIPLOG]
    ([date],[subTrip],[driver],[action])
SELECT
    DATEADD(MINUTE, -(n.n % 40000), GETDATE())                         AS [date],
    st.subTripID                                                       AS [subTrip],
    drv.userID                                                         AS [driver],
    (SELECT TOP 1 tripLogActionID FROM [dbo].[TRIPLOGACTION] ORDER BY NEWID()) AS [action]
FROM #Nums8500 n
CROSS APPLY (
    SELECT TOP 1 s.subTripID, v.driver
    FROM [dbo].[SUBTRIP] s
    JOIN [dbo].[VEHICLE] v ON v.vehID = s.[vehicle]
    ORDER BY NEWID()
) st
JOIN [dbo].[USER] drv ON drv.userID = st.driver AND drv.userType = 3;


---------------------------------------------------------------
-- 13. DOCVEH – add 8 500 extra vehicle docs
---------------------------------------------------------------
INSERT INTO [dbo].[DOCVEH]
    ([vehicleID],[path],[issued],[expires],[docType],[checkedBy],[status])
SELECT
    (SELECT TOP 1 vehID FROM [dbo].[VEHICLE] ORDER BY NEWID())         AS [vehicleID],
    CONCAT(N'/extra/veh/', n.n, N'.pdf')                               AS [path],
    DATEADD(DAY, - (n.n % 730), CONVERT(date, GETDATE()))              AS [issued],
    DATEADD(DAY,   365 + (n.n % 730), CONVERT(date, GETDATE()))        AS [expires],
    (SELECT TOP 1 docTypeID FROM [dbo].[DOCTYPE]
     WHERE [type]=1 ORDER BY NEWID())                                  AS [docType],
    (SELECT TOP 1 userID FROM [dbo].[USER] WHERE [userType]=2 ORDER BY NEWID()) AS [checkedBy],
    (SELECT TOP 1 docStatusID FROM [dbo].[DOCSTATUS] ORDER BY NEWID()) AS [status]
FROM #Nums8500 n;


---------------------------------------------------------------
-- 14. DOCDRI – add 8 500 extra driver docs
---------------------------------------------------------------
INSERT INTO [dbo].[DOCDRI]
    ([driverID],[path],[issued],[expires],[docType],[checkedBy],[status])
SELECT
    (SELECT TOP 1 userID FROM [dbo].[USER] WHERE [userType]=3 ORDER BY NEWID()) AS [driverID],
    CONCAT(N'/extra/dri/', n.n, N'.pdf')                               AS [path],
    DATEADD(DAY, - (n.n % 730), CONVERT(date, GETDATE()))              AS [issued],
    DATEADD(DAY,   365 + (n.n % 730), CONVERT(date, GETDATE()))        AS [expires],
    (SELECT TOP 1 docTypeID FROM [dbo].[DOCTYPE]
     WHERE [type]=2 ORDER BY NEWID())                                  AS [docType],
    (SELECT TOP 1 userID FROM [dbo].[USER] WHERE [userType]=2 ORDER BY NEWID()) AS [checkedBy],
    (SELECT TOP 1 docStatusID FROM [dbo].[DOCSTATUS] ORDER BY NEWID()) AS [status]
FROM #Nums8500 n;


---------------------------------------------------------------
-- 15. CHECKDOC – add 8 500 extra checks
---------------------------------------------------------------
INSERT INTO [dbo].[CHECKDOC]
    ([docID],[status],[comments],[byUserID])
SELECT
    (SELECT TOP 1 docID FROM [dbo].[DOCVEH] ORDER BY NEWID())          AS [docID],
    (SELECT TOP 1 docStatusID FROM [dbo].[DOCSTATUS] ORDER BY NEWID()) AS [status],
    CONCAT(N'Extra bulk check ', n.n)                                  AS [comments],
    (SELECT TOP 1 userID FROM [dbo].[USER] WHERE [userType]=2 ORDER BY NEWID()) AS [byUserID]
FROM #Nums8500 n;


---------------------------------------------------------------
-- 16. VEHSERV – add 8 500 extra mappings
---------------------------------------------------------------
INSERT INTO [dbo].[VEHSERV]
    ([car],[service])
SELECT
    (SELECT TOP 1 vehID FROM [dbo].[VEHICLE] ORDER BY NEWID())         AS [car],
    (SELECT TOP 1 serviceTypeID FROM [dbo].[SERVICETYPE] ORDER BY NEWID()) AS [service]
FROM #Nums8500 n;


---------------------------------------------------------------
-- 17. SERVREQ – add 8 500 extra service requirements
---------------------------------------------------------------
INSERT INTO [dbo].[SERVREQ]
    ([service],[description])
SELECT
    (SELECT TOP 1 serviceTypeID FROM [dbo].[SERVICETYPE] ORDER BY NEWID()) AS [service],
    CONCAT(N'Extra bulk requirement ', n.n)                            AS [description]
FROM #Nums8500 n;


---------------------------------------------------------------
-- 18. BILLINGS – add 8 500 extra billing rows
---------------------------------------------------------------
INSERT INTO [dbo].[BILLINGS]
    ([service],[userType],[amount],[description])
SELECT
    (SELECT TOP 1 serviceTypeID FROM [dbo].[SERVICETYPE] ORDER BY NEWID()) AS [service],
    (SELECT TOP 1 userTypeID    FROM [dbo].[USERTYPE]    ORDER BY NEWID()) AS [userType],
    CAST(3.00 + (n.n % 60) AS smallmoney)                              AS [amount],
    CONCAT(N'Extra bulk billing ', n.n)                                AS [description]
FROM #Nums8500 n;


---------------------------------------------------------------
-- 19. GDPR – add 8 500 extra GDPR log entries
---------------------------------------------------------------
INSERT INTO [dbo].[GDPR]
    ([action],[status],[proccessedBy],[entryDate],[requestedBy],[finishedDate])
SELECT
    (SELECT TOP 1 gdprActionID FROM [dbo].[GDPRACTIONS] ORDER BY NEWID()) AS [action],
    (SELECT TOP 1 gdprID       FROM [dbo].[GDPRSTATUS]  ORDER BY NEWID()) AS [status],
    CASE WHEN n.n % 3 = 0
         THEN NULL
         ELSE (SELECT TOP 1 userID FROM [dbo].[USER] WHERE [userType] IN (1,2) ORDER BY NEWID())
    END                                                                AS [proccessedBy],
    DATEADD(DAY, -(n.n % 730), GETDATE())                              AS [entryDate],
    (SELECT TOP 1 userID FROM [dbo].[USER] WHERE [userType]=4 ORDER BY NEWID()) AS [requestedBy],
    CASE WHEN n.n % 4 = 0
         THEN NULL
         ELSE DATEADD(DAY, -((n.n % 730) - 1), GETDATE())
    END                                                                AS [finishedDate]
FROM #Nums8500 n;


---------------------------------------------------------------
-- Done
---------------------------------------------------------------
PRINT 'Extra 8,500 rows inserted per main table (where capacity allowed).';
