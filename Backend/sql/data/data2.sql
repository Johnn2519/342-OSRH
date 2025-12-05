/* ============================================================
   BULK DATA SEED – 9 985 NEW ROWS PER MAIN TABLE
   (excludes lookup/type/staff tables, respects triggers)
   ============================================================ */

---------------------------------------------------------------
-- 0. Helper: numbers table 1..9985
---------------------------------------------------------------
IF OBJECT_ID('tempdb..#Nums') IS NOT NULL DROP TABLE #Nums;

SELECT TOP (9985)
       ROW_NUMBER() OVER (ORDER BY (SELECT NULL)) AS n
INTO #Nums
FROM sys.all_objects;


---------------------------------------------------------------
-- 1. USER – add 9 985 new users
--    (dob valid, emails/phones match constraints)
---------------------------------------------------------------
INSERT INTO [dbo].[USER]
    ([username],[name],[surname],[dob],[gender],[email],[address],[phone],[userType],[rating],[password])
SELECT
    CONCAT('bulkuser', n.n)                                            AS [username],
    CONCAT(N'Name', n.n)                                               AS [name],
    CONCAT(N'Surname', n.n)                                            AS [surname],
    DATEADD(YEAR, - (20 + (n.n % 30)), CONVERT(date, GETDATE()))       AS [dob],   -- age 20–49
    ((n.n % 4) + 1)                                                    AS [gender], -- 1..4 from GENDER
    CONCAT('bulk', n.n, '@example.com')                                AS [email],
    CONCAT(N'Bulk Address ', n.n)                                      AS [address],
    CONCAT('+3579', RIGHT('0000000' + CAST(n.n AS varchar(7)), 7))     AS [phone],
    CASE (n.n % 5)
        WHEN 1 THEN 1   -- System Manager
        WHEN 2 THEN 2   -- System Worker
        WHEN 3 THEN 3   -- Driver
        WHEN 4 THEN 4   -- Simple User
        ELSE 5          -- Company
    END                                                                AS [userType],
    NULL                                                               AS [rating],
    N'Bulk!123'                                                        AS [password]
FROM #Nums n;


---------------------------------------------------------------
-- 2. VEHICLE – add 9 985 new vehicles
--    (ready=1 so AVAILABILITY trigger accepts them)
---------------------------------------------------------------
DECLARE @plateStart int = (SELECT ISNULL(MAX([plate]), 1000) + 1 FROM [dbo].[VEHICLE]);

INSERT INTO [dbo].[VEHICLE]
    ([insuranceNum],[seatNum],[kgCapacity],[volCapacity],[geoID],[vehType],[driver],[available],[ready],[plate])
SELECT
    300000 + n.n                                                       AS [insuranceNum],
    CASE WHEN n.n % 2 = 1 THEN 4 ELSE NULL END                         AS [seatNum],
    CASE WHEN n.n % 2 = 1 THEN NULL ELSE 500.0 END                     AS [kgCapacity],
    CASE WHEN n.n % 2 = 1 THEN NULL ELSE 5.0 END                       AS [volCapacity],
    (SELECT TOP 1 geoID FROM [dbo].[GEOFENCE] ORDER BY NEWID())        AS [geoID],
    (SELECT TOP 1 vehType FROM [dbo].[VEHTYPE] ORDER BY NEWID())       AS [vehType],
    (SELECT TOP 1 userID FROM [dbo].[USER] WHERE [userType]=3 ORDER BY NEWID()) AS [driver],
    1                                                                  AS [available],
    1                                                                  AS [ready],
    @plateStart + n.n                                                  AS [plate]
FROM #Nums n;


---------------------------------------------------------------
-- 3. GEOFENCE – add 9 985 geofences
---------------------------------------------------------------
INSERT INTO [dbo].[GEOFENCE]
    ([longMax],[latMax],[longMin],[latMin],[name])
SELECT
    33.000000 + (n.n * 0.0001)                                         AS [longMax],
    35.000000 + (n.n * 0.0001)                                         AS [latMax],
    32.900000 + (n.n * 0.0001)                                         AS [longMin],
    34.900000 + (n.n * 0.0001)                                         AS [latMin],
    CONCAT(N'BulkGeo', n.n)                                            AS [name]
FROM #Nums n;


---------------------------------------------------------------
-- 4. BRIDGE – add 9 985 bridges
---------------------------------------------------------------
INSERT INTO [dbo].[BRIDGE]
    ([longtitude],[latitude],[name])
SELECT
    33.100000 + (n.n * 0.0001)                                         AS [longtitude],
    35.100000 + (n.n * 0.0001)                                         AS [latitude],
    CONCAT(N'BulkBridge', n.n)                                         AS [name]
FROM #Nums n;


---------------------------------------------------------------
-- 5. CONNECT – add 9 985 bridge–geofence connections
---------------------------------------------------------------
INSERT INTO [dbo].[CONNECT]
    ([bridgeID],[geoID])
SELECT
    (SELECT TOP 1 bridgeID FROM [dbo].[BRIDGE] ORDER BY NEWID())       AS [bridgeID],
    (SELECT TOP 1 geoID    FROM [dbo].[GEOFENCE] ORDER BY NEWID())     AS [geoID]
FROM #Nums n;


---------------------------------------------------------------
-- 6. AVAILABILITY – add 9 985 availability records
--    (uses vehicles that are ready=1, respects STARTO_REND)
---------------------------------------------------------------
INSERT INTO [dbo].[AVAILABILITY]
    ([avStart],[avEnd],[car])
SELECT
    CASE WHEN n.n % 2 = 1
         THEN DATEADD(HOUR, -(n.n % 240), GETDATE())
         ELSE NULL
    END                                                                AS [avStart],
    CASE WHEN n.n % 2 = 0
         THEN DATEADD(HOUR, -(n.n % 240), GETDATE())
         ELSE NULL
    END                                                                AS [avEnd],
    (SELECT TOP 1 vehID FROM [dbo].[VEHICLE] WHERE [ready]=1 ORDER BY NEWID()) AS [car]
FROM #Nums n;


---------------------------------------------------------------
-- 7. TRIP – add 9 985 trips with varied times & seat/kg/vol combos
---------------------------------------------------------------
INSERT INTO [dbo].[TRIP]
    ([startLong],[startLat],[endtLong],[endLat],
     [startTime],[endTime],[reqTime],[status],
     [seatNum],[kgNum],[volNum],
     [serviceType],[requestedBy])
SELECT
    33.200000 + (n.n * 0.0001)                                         AS [startLong],
    35.200000 + (n.n * 0.0001)                                         AS [startLat],
    33.300000 + (n.n * 0.0001)                                         AS [endtLong],
    35.300000 + (n.n * 0.0001)                                         AS [endLat],
    DATEADD(MINUTE, -(n.n % 43200), GETDATE())                         AS [startTime],  -- up to ~30 days in past
    NULL                                                               AS [endTime],
    DATEADD(MINUTE, -((n.n + 10) % 43200), GETDATE())                  AS [reqTime],
    1                                                                  AS [status],      -- Requested
    CASE WHEN n.n % 3 IN (0,2) THEN 1 ELSE NULL END                    AS [seatNum],
    CASE WHEN n.n % 3 IN (1,2) THEN 50.0 ELSE NULL END                 AS [kgNum],
    CASE WHEN n.n % 3 IN (1,2) THEN 1.5 ELSE NULL END                  AS [volNum],
    (SELECT TOP 1 serviceTypeID FROM [dbo].[SERVICETYPE] ORDER BY NEWID()) AS [serviceType],
    (SELECT TOP 1 userID        FROM [dbo].[USER] WHERE [userType]=4 ORDER BY NEWID())   AS [requestedBy]
FROM #Nums n;


---------------------------------------------------------------
-- 8. SUBTRIP – add 9 985 subtrips linked to trips & vehicles
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
    NULL                                                               AS [endTime],
    1                                                                  AS [status],
    CAST(5.00 + (n.n % 50) AS smallmoney)                              AS [price],
    (SELECT TOP 1 vehID FROM [dbo].[VEHICLE] ORDER BY NEWID())         AS [vehicle],
    t.tripID                                                           AS [trip]
FROM #Nums n
CROSS APPLY (
    SELECT TOP 1 *
    FROM [dbo].[TRIP]
    ORDER BY NEWID()
) t;


---------------------------------------------------------------
-- 9. FEES – add 9 985 fee records (varied dates)
---------------------------------------------------------------
INSERT INTO [dbo].[FEES]
    ([serviceType],[amount],[startDate],[endDate])
SELECT
    (SELECT TOP 1 serviceTypeID FROM [dbo].[SERVICETYPE] ORDER BY NEWID()) AS [serviceType],
    CAST(1.00 + (n.n % 20) AS smallmoney)                              AS [amount],
    DATEADD(DAY, -(n.n % 365), GETDATE())                               AS [startDate],
    NULL                                                               AS [endDate]
FROM #Nums n;


---------------------------------------------------------------
-- 10. PAYMENT – add 9 985 payments (avoids tr_PAY_Driver recursion)
--      We always use [to] = driver, so trigger condition (to=0 AND type=1) is false.
---------------------------------------------------------------
INSERT INTO [dbo].[PAYMENT]
    ([date],[method],[from],[to],[subTrip],[price],[type])
SELECT
    DATEADD(MINUTE, -(n.n % 20000), GETDATE())                         AS [date],
    (SELECT TOP 1 paymentMethodID FROM [dbo].[PAYMENTMETHOD] ORDER BY NEWID()) AS [method],
    (SELECT TOP 1 userID FROM [dbo].[USER] WHERE [userType]=4 ORDER BY NEWID()) AS [from],
    drv.userID                                                         AS [to],
    st.subTripID                                                       AS [subTrip],
    CAST(3.00 + (n.n % 80) AS smallmoney)                              AS [price],
    1                                                                  AS [type]  -- Ride
FROM #Nums n
CROSS APPLY (
    SELECT TOP 1 s.subTripID, v.vehID, v.driver
    FROM [dbo].[SUBTRIP] s
    JOIN [dbo].[VEHICLE] v ON v.vehID = s.[vehicle]
    ORDER BY NEWID()
) stv
JOIN [dbo].[USER] drv ON drv.userID = stv.driver AND drv.userType = 3
CROSS APPLY (SELECT stv.subTripID AS subTripID) st;


---------------------------------------------------------------
-- 11. FEEDBACK – add 9 985 feedback records
--     MAX 2 feedbacks per subTrip (respects trigger tr_FEEDBACK_MAX)
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
    SELECT TOP (9985)
        ROW_NUMBER() OVER (ORDER BY subTripID) AS rn,
        subTripID
    FROM Expanded
)
INSERT INTO [dbo].[FEEDBACK]
    ([entryDate],[comment],[subTrip],[from],[to],[rating])
SELECT
    DATEADD(MINUTE, - (t.rn % 20000), GETDATE())                       AS [entryDate],
    CONCAT(N'Bulk feedback ', t.rn)                                    AS [comment],
    t.subTripID                                                        AS [subTrip],
    (SELECT TOP 1 userID FROM [dbo].[USER] WHERE [userType]=4 ORDER BY NEWID()) AS [from],
    (SELECT TOP 1 userID FROM [dbo].[USER] WHERE [userType]=3 ORDER BY NEWID()) AS [to],
    CAST(1 + (t.rn % 5) AS tinyint)                                    AS [rating]
FROM Targets t;


---------------------------------------------------------------
-- 12. TRIPLOG – add 9 985 trip log entries
---------------------------------------------------------------
INSERT INTO [dbo].[TRIPLOG]
    ([date],[subTrip],[driver],[action])
SELECT
    DATEADD(MINUTE, -(n.n % 20000), GETDATE())                         AS [date],
    st.subTripID                                                       AS [subTrip],
    drv.userID                                                         AS [driver],
    (SELECT TOP 1 tripLogActionID FROM [dbo].[TRIPLOGACTION] ORDER BY NEWID()) AS [action]
FROM #Nums n
CROSS APPLY (
    SELECT TOP 1 s.subTripID, v.driver
    FROM [dbo].[SUBTRIP] s
    JOIN [dbo].[VEHICLE] v ON v.vehID = s.[vehicle]
    ORDER BY NEWID()
) st
JOIN [dbo].[USER] drv ON drv.userID = st.driver AND drv.userType = 3;


---------------------------------------------------------------
-- 13. DOCVEH – add 9 985 vehicle documents
--      checkedBy must be System Worker (userType=2) – trigger enforces it.
---------------------------------------------------------------
INSERT INTO [dbo].[DOCVEH]
    ([vehicleID],[path],[issued],[expires],[docType],[checkedBy],[status])
SELECT
    (SELECT TOP 1 vehID FROM [dbo].[VEHICLE] ORDER BY NEWID())         AS [vehicleID],
    CONCAT(N'/bulk/veh/', n.n, N'.pdf')                                AS [path],
    DATEADD(DAY, - (n.n % 365), CONVERT(date, GETDATE()))              AS [issued],   -- past
    DATEADD(DAY,   365 + (n.n % 365), CONVERT(date, GETDATE()))        AS [expires],  -- future
    (SELECT TOP 1 docTypeID FROM [dbo].[DOCTYPE]
     WHERE [type]=1 ORDER BY NEWID())                                  AS [docType],  -- for vehicle
    (SELECT TOP 1 userID FROM [dbo].[USER] WHERE [userType]=2 ORDER BY NEWID()) AS [checkedBy],
    (SELECT TOP 1 docStatusID FROM [dbo].[DOCSTATUS] ORDER BY NEWID()) AS [status]
FROM #Nums n;


---------------------------------------------------------------
-- 14. DOCDRI – add 9 985 driver documents
---------------------------------------------------------------
INSERT INTO [dbo].[DOCDRI]
    ([driverID],[path],[issued],[expires],[docType],[checkedBy],[status])
SELECT
    (SELECT TOP 1 userID FROM [dbo].[USER] WHERE [userType]=3 ORDER BY NEWID()) AS [driverID],
    CONCAT(N'/bulk/dri/', n.n, N'.pdf')                                AS [path],
    DATEADD(DAY, - (n.n % 365), CONVERT(date, GETDATE()))              AS [issued],
    DATEADD(DAY,   365 + (n.n % 365), CONVERT(date, GETDATE()))        AS [expires],
    (SELECT TOP 1 docTypeID FROM [dbo].[DOCTYPE]
     WHERE [type]=2 ORDER BY NEWID())                                  AS [docType],  -- for driver
    (SELECT TOP 1 userID FROM [dbo].[USER] WHERE [userType]=2 ORDER BY NEWID()) AS [checkedBy],
    (SELECT TOP 1 docStatusID FROM [dbo].[DOCSTATUS] ORDER BY NEWID()) AS [status]
FROM #Nums n;


---------------------------------------------------------------
-- 15. CHECKDOC – add 9 985 document checks
---------------------------------------------------------------
INSERT INTO [dbo].[CHECKDOC]
    ([docID],[status],[comments],[byUserID])
SELECT
    (SELECT TOP 1 docID FROM [dbo].[DOCVEH] ORDER BY NEWID())          AS [docID],
    (SELECT TOP 1 docStatusID FROM [dbo].[DOCSTATUS] ORDER BY NEWID()) AS [status],
    CONCAT(N'Bulk check ', n.n)                                        AS [comments],
    (SELECT TOP 1 userID FROM [dbo].[USER] WHERE [userType]=2 ORDER BY NEWID()) AS [byUserID]
FROM #Nums n;


---------------------------------------------------------------
-- 16. VEHSERV – add 9 985 vehicle–service mappings
---------------------------------------------------------------
INSERT INTO [dbo].[VEHSERV]
    ([car],[service])
SELECT
    (SELECT TOP 1 vehID FROM [dbo].[VEHICLE] ORDER BY NEWID())         AS [car],
    (SELECT TOP 1 serviceTypeID FROM [dbo].[SERVICETYPE] ORDER BY NEWID()) AS [service]
FROM #Nums n;


---------------------------------------------------------------
-- 17. SERVREQ – add 9 985 service requirements
---------------------------------------------------------------
INSERT INTO [dbo].[SERVREQ]
    ([service],[description])
SELECT
    (SELECT TOP 1 serviceTypeID FROM [dbo].[SERVICETYPE] ORDER BY NEWID()) AS [service],
    CONCAT(N'Bulk requirement ', n.n)                                  AS [description]
FROM #Nums n;


---------------------------------------------------------------
-- 18. BILLINGS – add 9 985 billing records
---------------------------------------------------------------
INSERT INTO [dbo].[BILLINGS]
    ([service],[userType],[amount],[description])
SELECT
    (SELECT TOP 1 serviceTypeID FROM [dbo].[SERVICETYPE] ORDER BY NEWID()) AS [service],
    (SELECT TOP 1 userTypeID    FROM [dbo].[USERTYPE]    ORDER BY NEWID()) AS [userType],
    CAST(2.00 + (n.n % 50) AS smallmoney)                             AS [amount],
    CONCAT(N'Bulk billing ', n.n)                                     AS [description]
FROM #Nums n;


---------------------------------------------------------------
-- 19. GDPR – add 9 985 GDPR log entries
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
    DATEADD(DAY, -(n.n % 365), GETDATE())                              AS [entryDate],
    (SELECT TOP 1 userID FROM [dbo].[USER] WHERE [userType]=4 ORDER BY NEWID()) AS [requestedBy],
    CASE WHEN n.n % 4 = 0
         THEN NULL
         ELSE DATEADD(DAY, -((n.n % 365) - 1), GETDATE())
    END                                                                AS [finishedDate]
FROM #Nums n;


---------------------------------------------------------------
-- Done
---------------------------------------------------------------
PRINT 'Bulk insert complete.';
