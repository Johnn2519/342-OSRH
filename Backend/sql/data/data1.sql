-------------------------------------------------------------------
-- SEED DATA SCRIPT – adds data while keeping your existing records
-- Assumes all tables, constraints & triggers are already created.
-------------------------------------------------------------------

-------------------------
-- 1. BASIC LOOKUPS
-------------------------

-- SERVICETYPE (create a few base ones)
IF NOT EXISTS (SELECT 1 FROM [dbo].[SERVICETYPE])
BEGIN
    INSERT INTO [dbo].[SERVICETYPE] (minPayment, description, [name], moneyRate, [unit])
    VALUES
    (5.00,  N'Standard passenger ride', N'Passenger Ride', 0.50, N'km'),
    (7.50,  N'Parcel delivery',         N'Parcel Delivery', 0.75, N'km'),
    (10.00, N'Van cargo service',       N'Cargo Van',       1.00, N'km');
END;

-- VEHTYPE
IF NOT EXISTS (SELECT 1 FROM [dbo].[VEHTYPE])
BEGIN
    INSERT INTO [dbo].[VEHTYPE] ([name])
    VALUES (N'Sedan'),
           (N'Minivan'),
           (N'Cargo Van');
END;

-- DOCTYPE (uses DOCTYPETYPE 1=For vehicle, 2=For driver)
IF NOT EXISTS (SELECT 1 FROM [dbo].[DOCTYPE])
BEGIN
    INSERT INTO [dbo].[DOCTYPE] ([name],[description],[type])
    VALUES
    (N'Vehicle Insurance', N'Insurance certificate for vehicle', 1),
    (N'Vehicle MOT',       N'MOT certificate',                    1),
    (N'Driver License',    N'Driver''s license copy',             2),
    (N'Driver ID',         N'Driver''s ID document',              2);
END;

-- GEOFENCE
IF NOT EXISTS (SELECT 1 FROM [dbo].[GEOFENCE])
BEGIN
    INSERT INTO [dbo].[GEOFENCE] (longMax, latMax, longMin, latMin, [name])
    VALUES
    (33.320000, 35.150000, 33.300000, 35.130000, N'City Center'),
    (33.400000, 35.200000, 33.380000, 35.180000, N'Airport Area');
END;

-- BRIDGE
IF NOT EXISTS (SELECT 1 FROM [dbo].[BRIDGE])
BEGIN
    INSERT INTO [dbo].[BRIDGE] (longtitude, latitude, [name])
    VALUES
    (33.310000, 35.140000, N'North Bridge'),
    (33.390000, 35.190000, N'South Bridge');
END;

-- GDPRACTIONS
IF NOT EXISTS (SELECT 1 FROM [dbo].[GDPRACTIONS])
BEGIN
    INSERT INTO [dbo].[GDPRACTIONS] ([name],[description])
    VALUES
    (N'Data Access',    N'User requested data access'),
    (N'Data Deletion',  N'User requested data deletion'),
    (N'Data Correction',N'User requested data correction');
END;

-- GDPRSTATUS
IF NOT EXISTS (SELECT 1 FROM [dbo].[GDPRSTATUS])
BEGIN
    INSERT INTO [dbo].[GDPRSTATUS] ([name])
    VALUES (N'Open'),
           (N'In Progress'),
           (N'Closed');
END;


-------------------------
-- 2. USERS
-------------------------
-- You already have:
-- userID = 0, username='company', userType=5 (Company)

-- Base named users (manager, worker, drivers, riders)
IF NOT EXISTS (SELECT 1 FROM [dbo].[USER] WHERE [username] = 'sysman1')
BEGIN
    INSERT INTO [dbo].[USER]
        ([username],[name],[surname],[dob],[gender],[email],[address],[phone],[userType],[rating],[password])
    VALUES
    ('sysman1', N'Alice', N'Manager', '1985-01-15', 2,
     'alice.manager@example.com', N'1 Admin Street', '+35799000001', 1, NULL, 'Pass!123'),
    ('worker1', N'Bob',   N'Worker',  '1990-03-20', 2,
     'bob.worker@example.com',   N'10 Office Road', '+35799000002', 2, NULL, 'Pass!123'),
    ('driver1', N'Chris', N'Driver',  '1988-05-10', 1,
     'chris.driver1@example.com', N'5 Main Ave', '+35799000003', 3, NULL, 'Pass!123'),
    ('driver2', N'Dana',  N'Driver',  '1992-07-12', 1,
     'dana.driver2@example.com',  N'6 Main Ave', '+35799000004', 3, NULL, 'Pass!123'),
    ('driver3', N'Evan',  N'Driver',  '1987-09-25', 2,
     'evan.driver3@example.com',  N'7 Main Ave', '+35799000005', 3, NULL, 'Pass!123'),
    ('user1',   N'Fiona', N'Rider',   '1995-11-05', 1,
     'fiona.user1@example.com',   N'8 Rider St', '+35799000006', 4, NULL, 'Pass!123'),
    ('user2',   N'George',N'Rider',   '1993-02-17', 2,
     'george.user2@example.com',  N'9 Rider St', '+35799000007', 4, NULL, 'Pass!123'),
    ('user3',   N'Helen', N'Rider',   '1994-04-22', 1,
     'helen.user3@example.com',   N'11 Rider St', '+35799000008', 4, NULL, 'Pass!123');
END;

-- Make sure we have at least 20 users total
DECLARE @existingUsers int = (SELECT COUNT(*) FROM [dbo].[USER]);
DECLARE @needUsers int = 20 - @existingUsers;
IF @needUsers > 0
BEGIN
    DECLARE @i int = 1;
    WHILE @i <= @needUsers
    BEGIN
        INSERT INTO [dbo].[USER]
            ([username],[name],[surname],[dob],[gender],[email],[address],[phone],[userType],[rating],[password])
        VALUES
        (
            CONCAT('user_auto', @i),
            N'Auto', N'User'+CAST(@i AS nvarchar(10)),
            DATEADD(YEAR, - (20 + (@i % 10)), CONVERT(date, GETDATE())),
            ((@i % 4) + 1),
            CONCAT('auto.user', @i, '@example.com'),
            CONCAT(N'Auto Address ', @i),
            CONCAT('+3579910', RIGHT('000' + CAST(@i AS varchar(3)), 3)),
            CASE WHEN @i % 4 = 0 THEN 1
                 WHEN @i % 4 = 1 THEN 2
                 WHEN @i % 4 = 2 THEN 3
                 ELSE 4 END,
            NULL,
            'Pass!123'
        );
        SET @i += 1;
    END
END;


-------------------------
-- 3. EXTRA LOOKUP ROWS TO REACH 20
-------------------------

-- USERTYPE  (you already have 1..5)
DECLARE @utExisting int = (SELECT COUNT(*) FROM [dbo].[USERTYPE]);
DECLARE @utNeed int = 20 - @utExisting;
IF @utNeed > 0
BEGIN
    DECLARE @iUT int = 1;
    WHILE @iUT <= @utNeed
    BEGIN
        INSERT INTO [dbo].[USERTYPE] ([name],[description])
        VALUES (CONCAT(N'Extra Type ', @iUT), N'Auto-generated user type');
        SET @iUT += 1;
    END
END;

-- DOCSTATUS  (you already have 4)
DECLARE @dsExisting int = (SELECT COUNT(*) FROM [dbo].[DOCSTATUS]);
DECLARE @dsNeed int = 20 - @dsExisting;
IF @dsNeed > 0
BEGIN
    DECLARE @iDS int = 1;
    WHILE @iDS <= @dsNeed
    BEGIN
        INSERT INTO [dbo].[DOCSTATUS] ([name],[okToRun])
        VALUES (CONCAT(N'CustomStatus', @iDS), 0);
        SET @iDS += 1;
    END
END;

-- GENDER (already 4)
DECLARE @gExisting int = (SELECT COUNT(*) FROM [dbo].[GENDER]);
DECLARE @gNeed int = 20 - @gExisting;
IF @gNeed > 0
BEGIN
    DECLARE @iG int = 1;
    WHILE @iG <= @gNeed
    BEGIN
        INSERT INTO [dbo].[GENDER] ([name])
        VALUES (CONCAT(N'CustomGender', @iG));
        SET @iG += 1;
    END
END;

-- TRIPSTATUS (already 4)
DECLARE @tsExisting int = (SELECT COUNT(*) FROM [dbo].[TRIPSTATUS]);
DECLARE @tsNeed int = 20 - @tsExisting;
IF @tsNeed > 0
BEGIN
    DECLARE @iTS int = 1;
    WHILE @iTS <= @tsNeed
    BEGIN
        INSERT INTO [dbo].[TRIPSTATUS] ([name])
        VALUES (CONCAT(N'CustomTripStatus', @iTS));
        SET @iTS += 1;
    END
END;

-- PAYTYPE (already 4)
DECLARE @ptExisting int = (SELECT COUNT(*) FROM [dbo].[PAYTYPE]);
DECLARE @ptNeed int = 20 - @ptExisting;
IF @ptNeed > 0
BEGIN
    DECLARE @iPT int = 1;
    WHILE @iPT <= @ptNeed
    BEGIN
        INSERT INTO [dbo].[PAYTYPE] ([name])
        VALUES (CONCAT(N'CustomPayType', @iPT));
        SET @iPT += 1;
    END
END;

-- PAYMENTMETHOD (already 6)
DECLARE @pmExisting int = (SELECT COUNT(*) FROM [dbo].[PAYMENTMETHOD]);
DECLARE @pmNeed int = 20 - @pmExisting;
IF @pmNeed > 0
BEGIN
    DECLARE @iPM int = 1;
    WHILE @iPM <= @pmNeed
    BEGIN
        INSERT INTO [dbo].[PAYMENTMETHOD] ([name],[description])
        VALUES (CONCAT(N'CustomMethod', @iPM), N'Auto-generated method');
        SET @iPM += 1;
    END
END;

-- TRIPLOGACTION (already 5)
DECLARE @tlaExisting int = (SELECT COUNT(*) FROM [dbo].[TRIPLOGACTION]);
DECLARE @tlaNeed int = 20 - @tlaExisting;
IF @tlaNeed > 0
BEGIN
    DECLARE @iTLA int = 1;
    WHILE @iTLA <= @tlaNeed
    BEGIN
        INSERT INTO [dbo].[TRIPLOGACTION] ([name])
        VALUES (CONCAT(N'CustomAction', @iTLA));
        SET @iTLA += 1;
    END
END;

-- DOCTYPETYPE (already 2: For vehicle, For driver)
DECLARE @dttExisting int = (SELECT COUNT(*) FROM [dbo].[DOCTYPETYPE]);
DECLARE @dttNeed int = 20 - @dttExisting;
IF @dttNeed > 0
BEGIN
    DECLARE @iDTT int = 1;
    WHILE @iDTT <= @dttNeed
    BEGIN
        INSERT INTO [dbo].[DOCTYPETYPE] ([name])
        VALUES (CONCAT(N'ExtraDocTypeType', @iDTT));
        SET @iDTT += 1;
    END
END;

-- DOCTYPE to 20
DECLARE @dtExisting int = (SELECT COUNT(*) FROM [dbo].[DOCTYPE]);
DECLARE @dtNeed int = 20 - @dtExisting;
IF @dtNeed > 0
BEGIN
    DECLARE @iDT int = 1;
    WHILE @iDT <= @dtNeed
    BEGIN
        INSERT INTO [dbo].[DOCTYPE] ([name],[description],[type])
        VALUES (CONCAT(N'AutoDocType', @iDT),
                N'Auto-generated doc type',
                CASE WHEN @iDT % 2 = 0 THEN 1 ELSE 2 END);
        SET @iDT += 1;
    END
END;

-- VEHTYPE to 20
DECLARE @vtExisting int = (SELECT COUNT(*) FROM [dbo].[VEHTYPE]);
DECLARE @vtNeed int = 20 - @vtExisting;
IF @vtNeed > 0
BEGIN
    DECLARE @iVT int = 1;
    WHILE @iVT <= @vtNeed
    BEGIN
        INSERT INTO [dbo].[VEHTYPE] ([name])
        VALUES (CONCAT(N'AutoVehType', @iVT));
        SET @iVT += 1;
    END
END;

-- SERVICETYPE to 20
DECLARE @stExisting int = (SELECT COUNT(*) FROM [dbo].[SERVICETYPE]);
DECLARE @stNeed int = 20 - @stExisting;
IF @stNeed > 0
BEGIN
    DECLARE @iST int = 1;
    WHILE @iST <= @stNeed
    BEGIN
        INSERT INTO [dbo].[SERVICETYPE] (minPayment, description, [name], moneyRate, [unit])
        VALUES (5 + @iST, N'Auto service type', CONCAT(N'AutoService', @iST), 0.50 + @iST * 0.1, N'km');
        SET @iST += 1;
    END
END;

-- GDPRACTIONS to 20
DECLARE @gaExisting int = (SELECT COUNT(*) FROM [dbo].[GDPRACTIONS]);
DECLARE @gaNeed int = 20 - @gaExisting;
IF @gaNeed > 0
BEGIN
    DECLARE @iGA int = 1;
    WHILE @iGA <= @gaNeed
    BEGIN
        INSERT INTO [dbo].[GDPRACTIONS] ([name],[description])
        VALUES (CONCAT(N'AutoGDPRAction', @iGA), N'Auto-generated GDPR action');
        SET @iGA += 1;
    END
END;

-- GDPRSTATUS to 20
DECLARE @gsExisting int = (SELECT COUNT(*) FROM [dbo].[GDPRSTATUS]);
DECLARE @gsNeed int = 20 - @gsExisting;
IF @gsNeed > 0
BEGIN
    DECLARE @iGS int = 1;
    WHILE @iGS <= @gsNeed
    BEGIN
        INSERT INTO [dbo].[GDPRSTATUS] ([name])
        VALUES (CONCAT(N'AutoGDPRStatus', @iGS));
        SET @iGS += 1;
    END
END;

-- GEOFENCE to 20
DECLARE @geoExisting int = (SELECT COUNT(*) FROM [dbo].[GEOFENCE]);
DECLARE @geoNeed int = 20 - @geoExisting;
IF @geoNeed > 0
BEGIN
    DECLARE @iGeo int = 1;
    WHILE @iGeo <= @geoNeed
    BEGIN
        INSERT INTO [dbo].[GEOFENCE] (longMax, latMax, longMin, latMin, [name])
        VALUES (33.300000 + @iGeo * 0.01, 35.100000 + @iGeo * 0.01,
                33.290000 + @iGeo * 0.01, 35.090000 + @iGeo * 0.01,
                CONCAT(N'AutoGeofence', @iGeo));
        SET @iGeo += 1;
    END
END;

-- BRIDGE to 20
DECLARE @brExisting int = (SELECT COUNT(*) FROM [dbo].[BRIDGE]);
DECLARE @brNeed int = 20 - @brExisting;
IF @brNeed > 0
BEGIN
    DECLARE @iBR int = 1;
    WHILE @iBR <= @brNeed
    BEGIN
        INSERT INTO [dbo].[BRIDGE] (longtitude, latitude, [name])
        VALUES (33.310000 + @iBR * 0.01, 35.140000 + @iBR * 0.01,
                CONCAT(N'AutoBridge', @iBR));
        SET @iBR += 1;
    END
END;


-------------------------
-- 4. VEHICLES
-------------------------

-- Base vehicles for known drivers
IF NOT EXISTS (SELECT 1 FROM [dbo].[VEHICLE])
BEGIN
    INSERT INTO [dbo].[VEHICLE]
        (insuranceNum, seatNum, kgCapacity, volCapacity, geoID, vehType, driver, available, ready, plate)
    VALUES
    (100001, 4, 200.0, 2.5,
     (SELECT TOP 1 geoID FROM [dbo].[GEOFENCE] ORDER BY geoID),
     (SELECT TOP 1 vehType FROM [dbo].[VEHTYPE] ORDER BY vehType),
     (SELECT userID FROM [dbo].[USER] WHERE username='driver1'),
     0, 1, 5001),

    (100002, 6, 250.0, 3.0,
     (SELECT TOP 1 geoID FROM [dbo].[GEOFENCE] ORDER BY geoID DESC),
     (SELECT TOP 1 vehType FROM [dbo].[VEHTYPE] ORDER BY vehType DESC),
     (SELECT userID FROM [dbo].[USER] WHERE username='driver2'),
     0, 1, 5002),

    (100003, NULL, 800.0, 10.0,
     (SELECT TOP 1 geoID FROM [dbo].[GEOFENCE] ORDER BY geoID),
     (SELECT TOP 1 vehType FROM [dbo].[VEHTYPE] ORDER BY vehType),
     (SELECT userID FROM [dbo].[USER] WHERE username='driver3'),
     0, 1, 5003);
END;

-- Fill VEHICLE to 20
DECLARE @vehExisting int = (SELECT COUNT(*) FROM [dbo].[VEHICLE]);
DECLARE @vehNeed int = 20 - @vehExisting;
IF @vehNeed > 0
BEGIN
    DECLARE @iVeh int = 1;
    WHILE @iVeh <= @vehNeed
    BEGIN
        INSERT INTO [dbo].[VEHICLE]
            (insuranceNum, seatNum, kgCapacity, volCapacity, geoID, vehType, driver, available, ready, plate)
        SELECT
            200000 + @iVeh,
            4,
            300.0,
            3.5,
            (SELECT TOP 1 geoID FROM [dbo].[GEOFENCE] ORDER BY geoID),
            (SELECT TOP 1 vehType FROM [dbo].[VEHTYPE] ORDER BY vehType),
            (SELECT TOP 1 userID FROM [dbo].[USER] WHERE userType = 3),
            0,
            1,
            6000 + @iVeh;
        SET @iVeh += 1;
    END
END;


-------------------------
-- 5. AVAILABILITY
-------------------------

IF NOT EXISTS (SELECT 1 FROM [dbo].[AVAILABILITY])
BEGIN
    -- For first 3 vehicles, simple availability windows
    INSERT INTO [dbo].[AVAILABILITY] (avStart, avEnd, car)
    SELECT DATEADD(HOUR,-2,GETDATE()), NULL, vehID
    FROM (SELECT TOP 3 vehID FROM [dbo].[VEHICLE] ORDER BY vehID) v;
END;

-- Fill AVAILABILITY to 20 (each row references a ready vehicle, trigger will adjust available flag)
DECLARE @avExisting int = (SELECT COUNT(*) FROM [dbo].[AVAILABILITY]);
DECLARE @avNeed int = 20 - @avExisting;
IF @avNeed > 0
BEGIN
    DECLARE @iAV int = 1;
    WHILE @iAV <= @avNeed
    BEGIN
        INSERT INTO [dbo].[AVAILABILITY] (avStart, avEnd, car)
        SELECT
            CASE WHEN @iAV % 2 = 1 THEN DATEADD(HOUR, -@iAV, GETDATE()) ELSE NULL END,
            CASE WHEN @iAV % 2 = 0 THEN DATEADD(HOUR, -@iAV, GETDATE()) ELSE NULL END,
            (SELECT TOP 1 vehID FROM [dbo].[VEHICLE] ORDER BY vehID);
        SET @iAV += 1;
    END
END;


-------------------------
-- 6. CONNECT (BRIDGE <-> GEOFENCE)
-------------------------

IF NOT EXISTS (SELECT 1 FROM [dbo].[CONNECT])
BEGIN
    INSERT INTO [dbo].[CONNECT] (bridgeID, geoID)
    SELECT TOP 5 b.bridgeID, g.geoID
    FROM [dbo].[BRIDGE] b
    CROSS JOIN [dbo].[GEOFENCE] g;
END;

DECLARE @conExisting int = (SELECT COUNT(*) FROM [dbo].[CONNECT]);
DECLARE @conNeed int = 20 - @conExisting;
IF @conNeed > 0
BEGIN
    DECLARE @iCON int = 1;
    WHILE @iCON <= @conNeed
    BEGIN
        INSERT INTO [dbo].[CONNECT] (bridgeID, geoID)
        SELECT
            (SELECT TOP 1 bridgeID FROM [dbo].[BRIDGE] ORDER BY NEWID()),
            (SELECT TOP 1 geoID    FROM [dbo].[GEOFENCE] ORDER BY NEWID());
        SET @iCON += 1;
    END
END;


-------------------------
-- 7. FEES
-------------------------

IF NOT EXISTS (SELECT 1 FROM [dbo].[FEES])
BEGIN
    INSERT INTO [dbo].[FEES] (serviceType, amount, startDate, endDate)
    SELECT TOP 3 serviceTypeID, 2.00, DATEADD(DAY,-30,GETDATE()), NULL
    FROM [dbo].[SERVICETYPE] ORDER BY serviceTypeID;
END;

DECLARE @feesExisting int = (SELECT COUNT(*) FROM [dbo].[FEES]);
DECLARE @feesNeed int = 20 - @feesExisting;
IF @feesNeed > 0
BEGIN
    DECLARE @iFees int = 1;
    WHILE @iFees <= @feesNeed
    BEGIN
        INSERT INTO [dbo].[FEES] (serviceType, amount, startDate, endDate)
        SELECT
            (SELECT TOP 1 serviceTypeID FROM [dbo].[SERVICETYPE] ORDER BY NEWID()),
            1.00 + @iFees,
            DATEADD(DAY, -(@iFees * 5), GETDATE()),
            NULL;
        SET @iFees += 1;
    END
END;


-------------------------
-- 8. TRIPS & SUBTRIPS
-------------------------

-- Base trips (using user1/user2/user3 as requesters)
IF NOT EXISTS (SELECT 1 FROM [dbo].[TRIP])
BEGIN
    INSERT INTO [dbo].[TRIP]
        (startLong,startLat,endtLong,endLat,startTime,endTime,reqTime,status,seatNum,kgNum,volNum,serviceType,requestedBy)
    VALUES
    (33.320000,35.150000,33.330000,35.160000, DATEADD(HOUR,-1,GETDATE()), NULL, GETDATE(),
     1, 1, NULL, NULL,
     (SELECT TOP 1 serviceTypeID FROM [dbo].[SERVICETYPE] ORDER BY serviceTypeID),
     (SELECT userID FROM [dbo].[USER] WHERE username='user1')),

    (33.340000,35.170000,33.350000,35.180000, DATEADD(HOUR,-2,GETDATE()), NULL, GETDATE(),
     1, NULL, 20.0, 0.5,
     (SELECT TOP 1 serviceTypeID FROM [dbo].[SERVICETYPE] ORDER BY serviceTypeID DESC),
     (SELECT userID FROM [dbo].[USER] WHERE username='user2')),

    (33.360000,35.190000,33.370000,35.200000, DATEADD(HOUR,-3,GETDATE()), NULL, GETDATE(),
     1, 2, 50.0, 1.5,
     (SELECT TOP 1 serviceTypeID FROM [dbo].[SERVICETYPE] ORDER BY serviceTypeID),
     (SELECT userID FROM [dbo].[USER] WHERE username='user3'));
END;

-- Fill TRIP to 20
DECLARE @tripExisting int = (SELECT COUNT(*) FROM [dbo].[TRIP]);
DECLARE @tripNeed int = 20 - @tripExisting;
IF @tripNeed > 0
BEGIN
    DECLARE @iTrip int = 1;
    WHILE @iTrip <= @tripNeed
    BEGIN
        INSERT INTO [dbo].[TRIP]
            (startLong,startLat,endtLong,endLat,startTime,endTime,reqTime,status,seatNum,kgNum,volNum,serviceType,requestedBy)
        SELECT
            33.300000 + @iTrip * 0.01,
            35.100000 + @iTrip * 0.01,
            33.320000 + @iTrip * 0.01,
            35.120000 + @iTrip * 0.01,
            DATEADD(HOUR, -@iTrip, GETDATE()),
            NULL,
            GETDATE(),
            1,
            1,
            NULL,
            NULL,
            (SELECT TOP 1 serviceTypeID FROM [dbo].[SERVICETYPE] ORDER BY NEWID()),
            (SELECT TOP 1 userID FROM [dbo].[USER] WHERE userType = 4);
        SET @iTrip += 1;
    END
END;

-- SUBTRIP for existing TRIPs, assign vehicles
IF NOT EXISTS (SELECT 1 FROM [dbo].[SUBTRIP])
BEGIN
    INSERT INTO [dbo].[SUBTRIP]
        (startLong,startLat,endtLong,endLat,startTime,endTime,status,price,vehicle,trip)
    SELECT
        t.startLong,
        t.startLat,
        t.endtLong,
        t.endLat,
        DATEADD(MINUTE, 5, t.startTime),
        NULL,
        1,
        10.00,
        (SELECT TOP 1 vehID FROM [dbo].[VEHICLE] ORDER BY NEWID()),
        t.tripID
    FROM (SELECT TOP 5 * FROM [dbo].[TRIP] ORDER BY tripID) t;
END;

-- Fill SUBTRIP to 20
DECLARE @stExisting2 int = (SELECT COUNT(*) FROM [dbo].[SUBTRIP]);
DECLARE @stNeed2 int = 20 - @stExisting2;
IF @stNeed2 > 0
BEGIN
    DECLARE @iST2 int = 1;
    WHILE @iST2 <= @stNeed2
    BEGIN
        INSERT INTO [dbo].[SUBTRIP]
            (startLong,startLat,endtLong,endLat,startTime,endTime,status,price,vehicle,trip)
        SELECT
            t.startLong,
            t.startLat,
            t.endtLong,
            t.endLat,
            DATEADD(MINUTE, 10 + @iST2, t.startTime),
            NULL,
            1,
            8.00 + @iST2,
            (SELECT TOP 1 vehID FROM [dbo].[VEHICLE] ORDER BY NEWID()),
            t.tripID
        FROM (SELECT TOP 1 * FROM [dbo].[TRIP] ORDER BY NEWID()) t;
        SET @iST2 += 1;
    END
END;


-------------------------
-- 9. PAYMENT
-------------------------

-- We AVOID triggering commission payments (tr_PAY_Driver) by not inserting rows with [to]=0 & type=1 together.
IF NOT EXISTS (SELECT 1 FROM [dbo].[PAYMENT])
BEGIN
    INSERT INTO [dbo].[PAYMENT]
        ([date],[method],[from],[to],[subTrip],[price],[type])
    SELECT
        GETDATE(),
        1,  -- Debit Card
        (SELECT userID FROM [dbo].[USER] WHERE username='user1'),
        (SELECT userID FROM [dbo].[USER] WHERE username='driver1'),
        (SELECT TOP 1 subTripID FROM [dbo].[SUBTRIP] ORDER BY subTripID),
        15.00,
        1   -- Ride (paid directly to driver)
    UNION ALL
    SELECT
        GETDATE(),
        2,
        (SELECT userID FROM [dbo].[USER] WHERE username='user2'),
        (SELECT userID FROM [dbo].[USER] WHERE username='driver2'),
        (SELECT TOP 1 subTripID FROM [dbo].[SUBTRIP] ORDER BY subTripID DESC),
        12.50,
        1;
END;

-- Fill PAYMENT to 20
DECLARE @payExisting int = (SELECT COUNT(*) FROM [dbo].[PAYMENT]);
DECLARE @payNeed int = 20 - @payExisting;
IF @payNeed > 0
BEGIN
    DECLARE @iPay int = 1;
    WHILE @iPay <= @payNeed
    BEGIN
        INSERT INTO [dbo].[PAYMENT]
            ([date],[method],[from],[to],[subTrip],[price],[type])
        SELECT
            DATEADD(DAY, -@iPay, GETDATE()),
            (SELECT TOP 1 paymentMethodID FROM [dbo].[PAYMENTMETHOD] ORDER BY NEWID()),
            (SELECT TOP 1 userID FROM [dbo].[USER] WHERE userType = 4),
            (SELECT TOP 1 userID FROM [dbo].[USER] WHERE userType = 3),
            (SELECT TOP 1 subTripID FROM [dbo].[SUBTRIP] ORDER BY NEWID()),
            5.00 + @iPay,
            CASE WHEN @iPay % 3 = 0 THEN 3 ELSE 1 END;
        SET @iPay += 1;
    END
END;


-------------------------
-- 10. FEEDBACK
-------------------------

-- Base feedback (max 2 per subTrip enforced by trigger)
IF NOT EXISTS (SELECT 1 FROM [dbo].[FEEDBACK])
BEGIN
    DECLARE @st1 int = (SELECT TOP 1 subTripID FROM [dbo].[SUBTRIP] ORDER BY subTripID);
    DECLARE @st2 int = (SELECT TOP 1 subTripID FROM [dbo].[SUBTRIP] ORDER BY subTripID DESC);

    INSERT INTO [dbo].[FEEDBACK] (entryDate, [comment], subTrip, [from], [to], rating)
    VALUES
    (GETDATE(), N'Great ride', @st1,
     (SELECT userID FROM [dbo].[USER] WHERE username='user1'),
     (SELECT userID FROM [dbo].[USER] WHERE username='driver1'),
     5),
    (GETDATE(), N'On time and friendly', @st1,
     (SELECT userID FROM [dbo].[USER] WHERE username='user2'),
     (SELECT userID FROM [dbo].[USER] WHERE username='driver1'),
     4),
    (GETDATE(), N'Good driver', @st2,
     (SELECT userID FROM [dbo].[USER] WHERE username='user3'),
     (SELECT userID FROM [dbo].[USER] WHERE username='driver2'),
     4);
END;

-- Fill FEEDBACK to 20, respecting max 2 per subTrip
DECLARE @fbExisting int = (SELECT COUNT(*) FROM [dbo].[FEEDBACK]);
DECLARE @fbNeed int = 20 - @fbExisting;
IF @fbNeed > 0
BEGIN
    DECLARE @iFB int = 1;
    WHILE @iFB <= @fbNeed
    BEGIN
        DECLARE @subForFB int =
        (
            SELECT TOP 1 s.subTripID
            FROM [dbo].[SUBTRIP] s
            CROSS APPLY (
                SELECT COUNT(*) AS cn
                FROM [dbo].[FEEDBACK] f
                WHERE f.subTrip = s.subTripID
            ) c
            WHERE c.cn < 2
            ORDER BY NEWID()
        );

        IF @subForFB IS NOT NULL
        BEGIN
            INSERT INTO [dbo].[FEEDBACK] (entryDate, [comment], subTrip, [from], [to], rating)
            SELECT
                GETDATE(),
                CONCAT(N'Auto feedback ', @iFB),
                @subForFB,
                (SELECT TOP 1 userID FROM [dbo].[USER] WHERE userType = 4 ORDER BY NEWID()),
                (SELECT TOP 1 userID FROM [dbo].[USER] WHERE userType = 3 ORDER BY NEWID()),
                (1 + (@iFB % 5));
        END;

        SET @iFB += 1;
    END
END;


-------------------------
-- 11. TRIPLOG
-------------------------

IF NOT EXISTS (SELECT 1 FROM [dbo].[TRIPLOG])
BEGIN
    INSERT INTO [dbo].[TRIPLOG] ([date], subTrip, driver, [action])
    SELECT TOP 5
        GETDATE(),
        s.subTripID,
        v.driver,
        1  -- Sent
    FROM [dbo].[SUBTRIP] s
    JOIN [dbo].[VEHICLE] v ON v.vehID = s.vehicle;
END;

DECLARE @tlExisting int = (SELECT COUNT(*) FROM [dbo].[TRIPLOG]);
DECLARE @tlNeed int = 20 - @tlExisting;
IF @tlNeed > 0
BEGIN
    DECLARE @iTL int = 1;
    WHILE @iTL <= @tlNeed
    BEGIN
        INSERT INTO [dbo].[TRIPLOG] ([date], subTrip, driver, [action])
        SELECT
            DATEADD(MINUTE, -@iTL, GETDATE()),
            (SELECT TOP 1 subTripID FROM [dbo].[SUBTRIP] ORDER BY NEWID()),
            (SELECT TOP 1 userID FROM [dbo].[USER] WHERE userType = 3 ORDER BY NEWID()),
            (SELECT TOP 1 tripLogActionID FROM [dbo].[TRIPLOGACTION] ORDER BY NEWID());
        SET @iTL += 1;
    END
END;


-------------------------
-- 12. DOCVEH, DOCDRI, CHECKDOC
-------------------------

IF NOT EXISTS (SELECT 1 FROM [dbo].[DOCVEH])
BEGIN
    INSERT INTO [dbo].[DOCVEH]
        (vehicleID,[path],issued,expires,docType,checkedBy,[status])
    SELECT TOP 5
        v.vehID,
        CONCAT(N'/veh/', v.vehID, N'/insurance.pdf'),
        CONVERT(date, DATEADD(YEAR,-1,GETDATE())),
        CONVERT(date, DATEADD(YEAR, 1,GETDATE())),
        (SELECT TOP 1 docTypeID FROM [dbo].[DOCTYPE] WHERE [type]=1 ORDER BY docTypeID),
        (SELECT userID FROM [dbo].[USER] WHERE username='worker1'),
        4  -- Approved
    FROM [dbo].[VEHICLE] v ORDER BY v.vehID;
END;

DECLARE @dvExisting int = (SELECT COUNT(*) FROM [dbo].[DOCVEH]);
DECLARE @dvNeed int = 20 - @dvExisting;
IF @dvNeed > 0
BEGIN
    DECLARE @iDV int = 1;
    WHILE @iDV <= @dvNeed
    BEGIN
        INSERT INTO [dbo].[DOCVEH]
            (vehicleID,[path],issued,expires,docType,checkedBy,[status])
        SELECT
            (SELECT TOP 1 vehID FROM [dbo].[VEHICLE] ORDER BY NEWID()),
            CONCAT(N'/veh/auto', @iDV, N'.pdf'),
            CONVERT(date, DATEADD(MONTH,-6,GETDATE())),
            CONVERT(date, DATEADD(YEAR, 1,GETDATE())),
            (SELECT TOP 1 docTypeID FROM [dbo].[DOCTYPE] WHERE [type]=1 ORDER BY NEWID()),
            (SELECT userID FROM [dbo].[USER] WHERE username='worker1'),
            1;
        SET @iDV += 1;
    END
END;

-- DOCDRI
IF NOT EXISTS (SELECT 1 FROM [dbo].[DOCDRI])
BEGIN
    INSERT INTO [dbo].[DOCDRI]
        (driverID,[path],issued,expires,docType,checkedBy,[status])
    SELECT TOP 5
        u.userID,
        CONCAT(N'/dri/', u.userID, N'/license.pdf'),
        CONVERT(date, DATEADD(YEAR,-5,GETDATE())),
        CONVERT(date, DATEADD(YEAR, 5,GETDATE())),
        (SELECT TOP 1 docTypeID FROM [dbo].[DOCTYPE] WHERE [type]=2 ORDER BY docTypeID),
        (SELECT userID FROM [dbo].[USER] WHERE username='worker1'),
        4
    FROM [dbo].[USER] u
    WHERE u.userType = 3
    ORDER BY u.userID;
END;

DECLARE @ddExisting int = (SELECT COUNT(*) FROM [dbo].[DOCDRI]);
DECLARE @ddNeed int = 20 - @ddExisting;
IF @ddNeed > 0
BEGIN
    DECLARE @iDD int = 1;
    WHILE @iDD <= @ddNeed
    BEGIN
        INSERT INTO [dbo].[DOCDRI]
            (driverID,[path],issued,expires,docType,checkedBy,[status])
        SELECT
            (SELECT TOP 1 userID FROM [dbo].[USER] WHERE userType = 3 ORDER BY NEWID()),
            CONCAT(N'/dri/auto', @iDD, N'.pdf'),
            CONVERT(date, DATEADD(YEAR,-3,GETDATE())),
            CONVERT(date, DATEADD(YEAR, 2,GETDATE())),
            (SELECT TOP 1 docTypeID FROM [dbo].[DOCTYPE] WHERE [type]=2 ORDER BY NEWID()),
            (SELECT userID FROM [dbo].[USER] WHERE username='worker1'),
            1;
        SET @iDD += 1;
    END
END;

-- CHECKDOC
IF NOT EXISTS (SELECT 1 FROM [dbo].[CHECKDOC])
BEGIN
    INSERT INTO [dbo].[CHECKDOC] (docID,[status],[comments],byUserID)
    SELECT TOP 5 d.docID, d.[status], N'Initial check', (SELECT userID FROM [dbo].[USER] WHERE username='worker1')
    FROM [dbo].[DOCVEH] d ORDER BY d.docID;
END;

DECLARE @cdExisting int = (SELECT COUNT(*) FROM [dbo].[CHECKDOC]);
DECLARE @cdNeed int = 20 - @cdExisting;
IF @cdNeed > 0
BEGIN
    DECLARE @iCD int = 1;
    WHILE @iCD <= @cdNeed
    BEGIN
        INSERT INTO [dbo].[CHECKDOC] (docID,[status],[comments],byUserID)
        SELECT
            (SELECT TOP 1 docID FROM [dbo].[DOCVEH] ORDER BY NEWID()),
            (SELECT TOP 1 docStatusID FROM [dbo].[DOCSTATUS] ORDER BY NEWID()),
            CONCAT(N'Auto check ', @iCD),
            (SELECT userID FROM [dbo].[USER] WHERE username='worker1');
        SET @iCD += 1;
    END
END;


-------------------------
-- 13. VEHSERV
-------------------------

IF NOT EXISTS (SELECT 1 FROM [dbo].[VEHSERV])
BEGIN
    INSERT INTO [dbo].[VEHSERV] (car, [service])
    SELECT TOP 5 v.vehID, s.serviceTypeID
    FROM [dbo].[VEHICLE] v
    CROSS JOIN [dbo].[SERVICETYPE] s;
END;

DECLARE @vsExisting int = (SELECT COUNT(*) FROM [dbo].[VEHSERV]);
DECLARE @vsNeed int = 20 - @vsExisting;
IF @vsNeed > 0
BEGIN
    DECLARE @iVS int = 1;
    WHILE @iVS <= @vsNeed
    BEGIN
        INSERT INTO [dbo].[VEHSERV] (car, [service])
        SELECT
            (SELECT TOP 1 vehID FROM [dbo].[VEHICLE] ORDER BY NEWID()),
            (SELECT TOP 1 serviceTypeID FROM [dbo].[SERVICETYPE] ORDER BY NEWID());
        SET @iVS += 1;
    END
END;


-------------------------
-- 14. SERVREQ
-------------------------

IF NOT EXISTS (SELECT 1 FROM [dbo].[SERVREQ])
BEGIN
    INSERT INTO [dbo].[SERVREQ] ([service],[description])
    SELECT TOP 5 serviceTypeID, N'Base requirement'
    FROM [dbo].[SERVICETYPE] ORDER BY serviceTypeID;
END;

DECLARE @srExisting int = (SELECT COUNT(*) FROM [dbo].[SERVREQ]);
DECLARE @srNeed int = 20 - @srExisting;
IF @srNeed > 0
BEGIN
    DECLARE @iSR int = 1;
    WHILE @iSR <= @srNeed
    BEGIN
        INSERT INTO [dbo].[SERVREQ] ([service],[description])
        SELECT
            (SELECT TOP 1 serviceTypeID FROM [dbo].[SERVICETYPE] ORDER BY NEWID()),
            CONCAT(N'Auto requirement ', @iSR);
        SET @iSR += 1;
    END
END;


-------------------------
-- 15. BILLINGS
-------------------------

IF NOT EXISTS (SELECT 1 FROM [dbo].[BILLINGS])
BEGIN
    INSERT INTO [dbo].[BILLINGS] ([service],[userType],[amount],[description])
    SELECT TOP 5
        s.serviceTypeID,
        u.userTypeID,
        3.50,
        N'Base billing'
    FROM [dbo].[SERVICETYPE] s
    CROSS JOIN [dbo].[USERTYPE] u;
END;

DECLARE @bilExisting int = (SELECT COUNT(*) FROM [dbo].[BILLINGS]);
DECLARE @bilNeed int = 20 - @bilExisting;
IF @bilNeed > 0
BEGIN
    DECLARE @iBIL int = 1;
    WHILE @iBIL <= @bilNeed
    BEGIN
        INSERT INTO [dbo].[BILLINGS] ([service],[userType],[amount],[description])
        SELECT
            (SELECT TOP 1 serviceTypeID FROM [dbo].[SERVICETYPE] ORDER BY NEWID()),
            (SELECT TOP 1 userTypeID FROM [dbo].[USERTYPE] ORDER BY NEWID()),
            2.00 + @iBIL,
            CONCAT(N'Auto billing ', @iBIL);
        SET @iBIL += 1;
    END
END;


-------------------------
-- 16. GDPR LOG
-------------------------

IF NOT EXISTS (SELECT 1 FROM [dbo].[GDPR])
BEGIN
    INSERT INTO [dbo].[GDPR]
        ([action],[status],[proccessedBy],[entryDate],[requestedBy],[finishedDate])
    VALUES
    (
        (SELECT TOP 1 gdprActionID FROM [dbo].[GDPRACTIONS] ORDER BY gdprActionID),
        (SELECT TOP 1 gdprID       FROM [dbo].[GDPRSTATUS] ORDER BY gdprID),
        (SELECT userID FROM [dbo].[USER] WHERE username='worker1'),
        GETDATE(),
        (SELECT userID FROM [dbo].[USER] WHERE username='user1'),
        NULL
    );
END;

DECLARE @gdExisting int = (SELECT COUNT(*) FROM [dbo].[GDPR]);
DECLARE @gdNeed int = 20 - @gdExisting;
IF @gdNeed > 0
BEGIN
    DECLARE @iGD int = 1;
    WHILE @iGD <= @gdNeed
    BEGIN
        INSERT INTO [dbo].[GDPR]
            ([action],[status],[proccessedBy],[entryDate],[requestedBy],[finishedDate])
        SELECT
            (SELECT TOP 1 gdprActionID FROM [dbo].[GDPRACTIONS] ORDER BY NEWID()),
            (SELECT TOP 1 gdprID       FROM [dbo].[GDPRSTATUS] ORDER BY NEWID()),
            (SELECT TOP 1 userID       FROM [dbo].[USER] WHERE userType IN (1,2) ORDER BY NEWID()),
            DATEADD(DAY, -@iGD, GETDATE()),
            (SELECT TOP 1 userID       FROM [dbo].[USER] WHERE userType = 4 ORDER BY NEWID()),
            NULL;
        SET @iGD += 1;
    END
END;

-------------------------------------------------------------------
-- END OF SEED SCRIPT
-------------------------------------------------------------------
