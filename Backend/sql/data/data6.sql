/* ============================================================
   VARIED TYPES/STATUSES – ADD 1 000 ROWS WITH MIXED STATUS/TYPE
   ============================================================ */

---------------------------------------------------------------
-- 0. Helper numbers table 1..1000
---------------------------------------------------------------
IF OBJECT_ID('tempdb..#Nums1000') IS NOT NULL DROP TABLE #Nums1000;

SELECT TOP (1000)
       ROW_NUMBER() OVER (ORDER BY (SELECT NULL)) AS n
INTO #Nums1000
FROM sys.all_objects;


---------------------------------------------------------------
-- 1. TRIP – 1 000 trips with mixed TRIPSTATUS and dates
---------------------------------------------------------------
INSERT INTO [dbo].[TRIP]
    ([startLong],[startLat],[endtLong],[endLat],
     [startTime],[endTime],[reqTime],[status],
     [seatNum],[kgNum],[volNum],
     [serviceType],[requestedBy])
SELECT
    35.000000 + (n.n * 0.0001)                                         AS [startLong],
    37.000000 + (n.n * 0.0001)                                         AS [startLat],
    35.100000 + (n.n * 0.0001)                                         AS [endtLong],
    37.100000 + (n.n * 0.0001)                                         AS [endLat],
    DATEADD(MINUTE, -(n.n % 20000), GETDATE())                         AS [startTime],
    CASE WHEN n.n % 3 = 0
         THEN DATEADD(MINUTE, (n.n % 180), DATEADD(MINUTE, -(n.n % 20000), GETDATE()))
         ELSE NULL
    END                                                                AS [endTime],
    DATEADD(MINUTE, -((n.n + 50) % 20000), GETDATE())                  AS [reqTime],
    (SELECT TOP 1 tripStatusID FROM [dbo].[TRIPSTATUS] ORDER BY NEWID()) AS [status],
    CASE WHEN n.n % 3 IN (0,2) THEN 1 ELSE NULL END                    AS [seatNum],
    CASE WHEN n.n % 3 IN (1,2) THEN 80.0 ELSE NULL END                 AS [kgNum],
    CASE WHEN n.n % 3 IN (1,2) THEN 2.0 ELSE NULL END                  AS [volNum],
    (SELECT TOP 1 serviceTypeID FROM [dbo].[SERVICETYPE] ORDER BY NEWID()) AS [serviceType],
    (SELECT TOP 1 userID        FROM [dbo].[USER] WHERE [userType]=4 ORDER BY NEWID())   AS [requestedBy]
FROM #Nums1000 n;


---------------------------------------------------------------
-- 2. SUBTRIP – 1 000 subtrips with mixed TRIPSTATUS & endTime
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
    DATEADD(MINUTE, (n.n % 60), t.startTime)                           AS [startTime],
    CASE WHEN n.n % 3 = 0
         THEN DATEADD(MINUTE, (n.n % 120), DATEADD(MINUTE, (n.n % 60), t.startTime))
         ELSE NULL
    END                                                                AS [endTime],
    (SELECT TOP 1 tripStatusID FROM [dbo].[TRIPSTATUS] ORDER BY NEWID()) AS [status],
    CAST(5.00 + (n.n % 40) AS smallmoney)                              AS [price],
    (SELECT TOP 1 vehID FROM [dbo].[VEHICLE] ORDER BY NEWID())         AS [vehicle],
    t.tripID                                                           AS [trip]
FROM #Nums1000 n
CROSS APPLY (
    SELECT TOP 1 *
    FROM [dbo].[TRIP]
    ORDER BY NEWID()
) t;


---------------------------------------------------------------
-- 3. PAYMENT – 1 000 payments with varied PAYTYPE and dates
--    (to = driver, so we avoid the commission trigger path)
---------------------------------------------------------------
INSERT INTO [dbo].[PAYMENT]
    ([date],[method],[from],[to],[subTrip],[price],[type])
SELECT
    DATEADD(MINUTE, -(n.n % 25000), GETDATE())                         AS [date],
    (SELECT TOP 1 paymentMethodID FROM [dbo].[PAYMENTMETHOD] ORDER BY NEWID()) AS [method],
    (SELECT TOP 1 userID FROM [dbo].[USER] WHERE [userType]=4 ORDER BY NEWID()) AS [from],
    drv.userID                                                         AS [to],
    st.subTripID                                                       AS [subTrip],
    CAST(4.00 + (n.n % 60) AS smallmoney)                              AS [price],
    (SELECT TOP 1 payTypeID FROM [dbo].[PAYTYPE] ORDER BY NEWID())     AS [type]
FROM #Nums1000 n
CROSS APPLY (
    SELECT TOP 1 s.subTripID, v.vehID, v.driver
    FROM [dbo].[SUBTRIP] s
    JOIN [dbo].[VEHICLE] v ON v.vehID = s.[vehicle]
    ORDER BY NEWID()
) st
JOIN [dbo].[USER] drv ON drv.userID = st.driver AND drv.userType = 3;


---------------------------------------------------------------
-- 4. FEEDBACK – up to 1 000 extra, still max 2 per subTrip
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
    SELECT TOP (1000)
        ROW_NUMBER() OVER (ORDER BY subTripID) AS rn,
        subTripID
    FROM Expanded
)
INSERT INTO [dbo].[FEEDBACK]
    ([entryDate],[comment],[subTrip],[from],[to],[rating])
SELECT
    DATEADD(MINUTE, - (t.rn % 25000), GETDATE())                       AS [entryDate],
    CONCAT(N'Varied status feedback ', t.rn)                           AS [comment],
    t.subTripID                                                        AS [subTrip],
    (SELECT TOP 1 userID FROM [dbo].[USER] WHERE [userType]=4 ORDER BY NEWID()) AS [from],
    (SELECT TOP 1 userID FROM [dbo].[USER] WHERE [userType]=3 ORDER BY NEWID()) AS [to],
    CAST(1 + (t.rn % 5) AS tinyint)                                    AS [rating]
FROM Targets t;


---------------------------------------------------------------
-- 5. DOCVEH – 1 000 docs with mixed DOCSTATUS
---------------------------------------------------------------
INSERT INTO [dbo].[DOCVEH]
    ([vehicleID],[path],[issued],[expires],[docType],[checkedBy],[status])
SELECT
    (SELECT TOP 1 vehID FROM [dbo].[VEHICLE] ORDER BY NEWID())         AS [vehicleID],
    CONCAT(N'/mixed/veh/', n.n, N'.pdf')                               AS [path],
    DATEADD(DAY, - (n.n % 365), CONVERT(date, GETDATE()))              AS [issued],
    DATEADD(DAY,   365 + (n.n % 365), CONVERT(date, GETDATE()))        AS [expires],
    (SELECT TOP 1 docTypeID FROM [dbo].[DOCTYPE]
     WHERE [type]=1 ORDER BY NEWID())                                  AS [docType],
    (SELECT TOP 1 userID FROM [dbo].[USER] WHERE [userType]=2 ORDER BY NEWID()) AS [checkedBy],
    (SELECT TOP 1 docStatusID FROM [dbo].[DOCSTATUS] ORDER BY NEWID()) AS [status]
FROM #Nums1000 n;


---------------------------------------------------------------
-- 6. DOCDRI – 1 000 driver docs with mixed DOCSTATUS
---------------------------------------------------------------
INSERT INTO [dbo].[DOCDRI]
    ([driverID],[path],[issued],[expires],[docType],[checkedBy],[status])
SELECT
    (SELECT TOP 1 userID FROM [dbo].[USER] WHERE [userType]=3 ORDER BY NEWID()) AS [driverID],
    CONCAT(N'/mixed/dri/', n.n, N'.pdf')                               AS [path],
    DATEADD(DAY, - (n.n % 365), CONVERT(date, GETDATE()))              AS [issued],
    DATEADD(DAY,   365 + (n.n % 365), CONVERT(date, GETDATE()))        AS [expires],
    (SELECT TOP 1 docTypeID FROM [dbo].[DOCTYPE]
     WHERE [type]=2 ORDER BY NEWID())                                  AS [docType],
    (SELECT TOP 1 userID FROM [dbo].[USER] WHERE [userType]=2 ORDER BY NEWID()) AS [checkedBy],
    (SELECT TOP 1 docStatusID FROM [dbo].[DOCSTATUS] ORDER BY NEWID()) AS [status]
FROM #Nums1000 n;


---------------------------------------------------------------
-- 7. CHECKDOC – 1 000 checks with varied DOCSTATUS
---------------------------------------------------------------
INSERT INTO [dbo].[CHECKDOC]
    ([docID],[status],[comments],[byUserID])
SELECT
    (SELECT TOP 1 docID FROM [dbo].[DOCVEH] ORDER BY NEWID())          AS [docID],
    (SELECT TOP 1 docStatusID FROM [dbo].[DOCSTATUS] ORDER BY NEWID()) AS [status],
    CONCAT(N'Varied doc check ', n.n)                                  AS [comments],
    (SELECT TOP 1 userID FROM [dbo].[USER] WHERE [userType]=2 ORDER BY NEWID()) AS [byUserID]
FROM #Nums1000 n;


---------------------------------------------------------------
-- 8. TRIPLOG – 1 000 logs with mixed TRIPLOGACTION
---------------------------------------------------------------
INSERT INTO [dbo].[TRIPLOG]
    ([date],[subTrip],[driver],[action])
SELECT
    DATEADD(MINUTE, -(n.n % 25000), GETDATE())                         AS [date],
    st.subTripID                                                       AS [subTrip],
    drv.userID                                                         AS [driver],
    (SELECT TOP 1 tripLogActionID FROM [dbo].[TRIPLOGACTION] ORDER BY NEWID()) AS [action]
FROM #Nums1000 n
CROSS APPLY (
    SELECT TOP 1 s.subTripID, v.driver
    FROM [dbo].[SUBTRIP] s
    JOIN [dbo].[VEHICLE] v ON v.vehID = s.[vehicle]
    ORDER BY NEWID()
) st
JOIN [dbo].[USER] drv ON drv.userID = st.driver AND drv.userType = 3;


---------------------------------------------------------------
-- 9. GDPR – 1 000 records with mixed GDPRSTATUS & dates
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
         ELSE DATEADD(DAY, (n.n % 30), DATEADD(DAY, -(n.n % 730), GETDATE()))
    END                                                                AS [finishedDate]
FROM #Nums1000 n;


---------------------------------------------------------------
PRINT '1,000 varied rows inserted with mixed status/type values.';
---------------------------------------------------------------
