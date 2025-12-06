-- This file contains ALTER statements to add foreign key constraints and other constraints to the database tables.
-- It ensures referential integrity and enforces business rules through constraints.

-- Section: Foreign Key Constraints

--FK

-- Foreign keys for USER table
--user
ALTER TABLE [dbo].[USER] WITH CHECK ADD CONSTRAINT [FK_USERTYPE] FOREIGN KEY ([userType]) REFERENCES [dbo].[USERTYPE]([userTypeID])

ALTER TABLE [dbo].[USER] WITH CHECK ADD CONSTRAINT [FK_GENDER] FOREIGN KEY ([gender]) REFERENCES [dbo].[GENDER]([genderID])


-- Foreign keys for DOCVEH table
--docVeh
ALTER TABLE [dbo].[DOCVEH] WITH CHECK ADD CONSTRAINT [FK_DOCTYPEVEH] FOREIGN KEY ([docType]) REFERENCES [dbo].[DOCTYPE]([docTypeID])

ALTER TABLE [dbo].[DOCVEH] WITH CHECK ADD CONSTRAINT [FK_CHECKEDBYVEH] FOREIGN KEY ([checkedBy]) REFERENCES [dbo].[USER]([userID])

ALTER TABLE [dbo].[DOCVEH] WITH CHECK ADD CONSTRAINT [FK_STATUSVEH] FOREIGN KEY ([status]) REFERENCES [dbo].[DOCSTATUS]([docStatusID])

ALTER TABLE [dbo].[DOCVEH] WITH CHECK ADD CONSTRAINT [FK_VEHIDVEH] FOREIGN KEY ([vehicleID]) REFERENCES [dbo].[VEHICLE]([vehID]) ON DELETE CASCADE


-- Foreign keys for CHECKDOC table
--check docs
ALTER TABLE [dbo].[CHECKDOC] WITH CHECK ADD CONSTRAINT [FK_BYCD] FOREIGN KEY ([byUserID]) REFERENCES [dbo].[USER]([userID])

ALTER TABLE [dbo].[CHECKDOC] WITH CHECK ADD CONSTRAINT [FK_STATUSCD] FOREIGN KEY ([status]) REFERENCES [dbo].[DOCSTATUS]([docStatusID])

ALTER TABLE [dbo].[CHECKDOC] WITH CHECK ADD CONSTRAINT [FK_DOCVEHCD] FOREIGN KEY ([docID]) REFERENCES [dbo].[DOCVEH]([docID]) ON DELETE CASCADE


-- Foreign keys for DOCDRI table
--docDri
ALTER TABLE [dbo].[DOCDRI] WITH CHECK ADD CONSTRAINT [FK_DOCTYPEDRI] FOREIGN KEY ([docType]) REFERENCES [dbo].[DOCTYPE]([docTypeID])

ALTER TABLE [dbo].[DOCDRI] WITH CHECK ADD CONSTRAINT [FK_CHECKEDBYDRI] FOREIGN KEY ([checkedBy]) REFERENCES [dbo].[USER]([userID])

ALTER TABLE [dbo].[DOCDRI] WITH CHECK ADD CONSTRAINT [FK_STATUSDRI] FOREIGN KEY ([status]) REFERENCES [dbo].[DOCSTATUS]([docStatusID])

ALTER TABLE [dbo].[DOCDRI] WITH CHECK ADD CONSTRAINT [FK_WHOSEDRI] FOREIGN KEY ([driverID]) REFERENCES [dbo].[USER]([userID]) ON DELETE CASCADE


-- Foreign keys for VEHICLE table
--vehicle
ALTER TABLE [dbo].[VEHICLE] WITH CHECK ADD CONSTRAINT [FK_GEOVEH] FOREIGN KEY ([geoID]) REFERENCES [dbo].[GEOFENCE]([geoID])

ALTER TABLE [dbo].[VEHICLE] WITH CHECK ADD CONSTRAINT [FK_VEHTYPEVEH] FOREIGN KEY ([vehType]) REFERENCES [dbo].[VEHTYPE]([vehType])

ALTER TABLE [dbo].[VEHICLE] WITH CHECK ADD CONSTRAINT [FK_DRIVERVEH] FOREIGN KEY ([driver]) REFERENCES [dbo].[USER]([userID]) ON DELETE CASCADE


-- Foreign keys for DOCTYPE table
--Doc Types
ALTER TABLE [dbo].[DOCTYPE] WITH CHECK ADD CONSTRAINT [FK_TYPESDT] FOREIGN KEY ([type]) REFERENCES [dbo].[DOCTYPETYPE]([docTypeTypeID])


-- Foreign keys for FEES table
--fees
ALTER TABLE [dbo].[FEES] WITH CHECK ADD CONSTRAINT [FK_SERVICETYPESFEE] FOREIGN KEY ([serviceType]) REFERENCES [dbo].[SERVICETYPE]([serviceTypeID])


-- Foreign keys for AVAILABILITY table
--availability
ALTER TABLE [dbo].[AVAILABILITY] WITH CHECK ADD CONSTRAINT [FK_CAR] FOREIGN KEY ([car]) REFERENCES [dbo].[VEHICLE]([vehID]) ON DELETE CASCADE


-- Foreign keys for CONNECT table
--connect
ALTER TABLE [dbo].[CONNECT] WITH CHECK ADD CONSTRAINT [FK_BRIDGECON] FOREIGN KEY ([bridgeID]) REFERENCES [dbo].[BRIDGE]([bridgeID]) ON UPDATE CASCADE ON DELETE CASCADE

ALTER TABLE [dbo].[CONNECT] WITH CHECK ADD CONSTRAINT [FK_GEOCON] FOREIGN KEY ([geoID]) REFERENCES [dbo].[GEOFENCE]([geoID])  ON UPDATE CASCADE ON DELETE CASCADE


-- Foreign keys for FEEDBACK table
--feedback
ALTER TABLE [dbo].[FEEDBACK] WITH CHECK ADD CONSTRAINT [FK_SUBTRIPF] FOREIGN KEY ([subTrip]) REFERENCES [dbo].[SUBTRIP]([subTripID])

ALTER TABLE [dbo].[FEEDBACK] WITH CHECK ADD CONSTRAINT [FK_FROMF] FOREIGN KEY ([from]) REFERENCES [dbo].[USER]([userID])

ALTER TABLE [dbo].[FEEDBACK] WITH CHECK ADD CONSTRAINT [FK_TOF] FOREIGN KEY ([to]) REFERENCES [dbo].[USER]([userID])


-- Foreign keys for GDPR table
--GDPR
ALTER TABLE [dbo].[GDPR] WITH CHECK ADD CONSTRAINT [FK_PROCBYG] FOREIGN KEY ([proccessedBy]) REFERENCES [dbo].[USER]([userID])

ALTER TABLE [dbo].[GDPR] WITH CHECK ADD CONSTRAINT [FK_REQBYG] FOREIGN KEY ([requestedBy]) REFERENCES [dbo].[USER]([userID])

ALTER TABLE [dbo].[GDPR] WITH CHECK ADD CONSTRAINT [FK_ACTIONG] FOREIGN KEY ([action]) REFERENCES [dbo].[GDPRACTIONS]([gdprActionID])

ALTER TABLE [dbo].[GDPR] WITH CHECK ADD CONSTRAINT [FK_STATUSG] FOREIGN KEY ([status]) REFERENCES [dbo].[GDPRSTATUS]([gdprID])


-- Foreign keys for TRIP table
--trip
ALTER TABLE [dbo].[TRIP] WITH CHECK ADD CONSTRAINT [FK_STATUSTR] FOREIGN KEY ([status]) REFERENCES [dbo].[TRIPSTATUS]([tripStatusID])

ALTER TABLE [dbo].[TRIP] WITH CHECK ADD CONSTRAINT [FK_STYTR] FOREIGN KEY ([serviceType]) REFERENCES [dbo].[SERVICETYPE]([serviceTypeID])

ALTER TABLE [dbo].[TRIP] WITH CHECK ADD CONSTRAINT [FK_REQBYTR] FOREIGN KEY ([requestedBy]) REFERENCES [dbo].[USER]([userID])


-- Foreign keys for SUBTRIP table
--subtrip
ALTER TABLE [dbo].[SUBTRIP] WITH CHECK ADD CONSTRAINT [FK_STATUSST] FOREIGN KEY ([status]) REFERENCES [dbo].[TRIPSTATUS]([tripStatusID])

ALTER TABLE [dbo].[SUBTRIP] WITH CHECK ADD CONSTRAINT [FK_VEHST] FOREIGN KEY ([vehicle]) REFERENCES [dbo].[VEHICLE]([vehID])

ALTER TABLE [dbo].[SUBTRIP] WITH CHECK ADD CONSTRAINT [FK_TRIPST] FOREIGN KEY ([trip]) REFERENCES [dbo].[TRIP]([tripID])


-- Foreign keys for PAYMENT table
--payment
ALTER TABLE [dbo].[PAYMENT] WITH CHECK ADD CONSTRAINT [FK_METHODPAY] FOREIGN KEY ([method]) REFERENCES [dbo].[PAYMENTMETHOD]([paymentMethodID])

ALTER TABLE [dbo].[PAYMENT] WITH CHECK ADD CONSTRAINT [FK_TOPAY] FOREIGN KEY ([to]) REFERENCES [dbo].[USER]([userID])

ALTER TABLE [dbo].[PAYMENT] WITH CHECK ADD CONSTRAINT [FK_FROMPAY] FOREIGN KEY ([from]) REFERENCES [dbo].[USER]([userID])

ALTER TABLE [dbo].[PAYMENT] WITH CHECK ADD CONSTRAINT [FK_STPAY] FOREIGN KEY ([subTrip]) REFERENCES [dbo].[SUBTRIP]([subTripID])

ALTER TABLE [dbo].[PAYMENT] WITH CHECK ADD CONSTRAINT [FK_PAYTYPE] FOREIGN KEY ([type]) REFERENCES [dbo].[PAYTYPE]([payTypeID])


-- Foreign keys for TRIPLOG table
--triplog
ALTER TABLE [dbo].[TRIPLOG] WITH CHECK ADD CONSTRAINT [FK_STTL] FOREIGN KEY ([subTrip]) REFERENCES [dbo].[SUBTRIP]([subTripID])

ALTER TABLE [dbo].[TRIPLOG] WITH CHECK ADD CONSTRAINT [FK_DRITL] FOREIGN KEY ([driver]) REFERENCES [dbo].[USER]([userID])

ALTER TABLE [dbo].[TRIPLOG] WITH CHECK ADD CONSTRAINT [FK_ACTIONTL] FOREIGN KEY ([action]) REFERENCES [dbo].[TRIPLOGACTION]([tripLogActionID])


-- Foreign keys for VEHSERV table
--veh serv
ALTER TABLE [dbo].[VEHSERV] WITH CHECK ADD CONSTRAINT [FK_CARVS] FOREIGN KEY ([car]) REFERENCES [dbo].[VEHICLE]([vehID])

ALTER TABLE [dbo].[VEHSERV] WITH CHECK ADD CONSTRAINT [FK_SERVICEVS] FOREIGN KEY ([service]) REFERENCES [dbo].[SERVICETYPE]([serviceTypeID])


-- Foreign keys for SERVREQ table
--servReq
ALTER TABLE [dbo].[SERVREQ] WITH CHECK ADD CONSTRAINT [FK_SERVICESR] FOREIGN KEY ([service]) REFERENCES [dbo].[SERVICETYPE]([serviceTypeID])


-- Foreign keys for BILLINGS table
--billings
ALTER TABLE [dbo].[BILLINGS] WITH CHECK ADD CONSTRAINT [FK_USERTYPEBIL] FOREIGN KEY ([userType]) REFERENCES [dbo].[USERTYPE]([userTypeID])

ALTER TABLE [dbo].[BILLINGS] WITH CHECK ADD CONSTRAINT [FK_SERVICEBIL] FOREIGN KEY ([service]) REFERENCES [dbo].[SERVICETYPE]([serviceTypeID])


-- Section: Additional Constraints and Alterations

--other alterations

-- Constraints for USER table
--USER
-- widen password column to fit hashed values
IF COALESCE(COL_LENGTH('dbo.USER','password'),0) < 510
BEGIN
	ALTER TABLE [dbo].[USER] ALTER COLUMN [password] NVARCHAR(255) NOT NULL;
END

-- Ensure date of birth is in the past
--dob in the past
ALTER TABLE [dbo].[USER] ADD CONSTRAINT [DOB_PAST] CHECK( [dob]<=CONVERT(date, GETDATE()) )

-- Ensure drivers are at least 18 years old
--Driver 18
ALTER TABLE [dbo].[USER] ADD CONSTRAINT [DRIVER_ADULT] CHECK( [userType]<>3 OR [dob]<=DATEADD(YEAR, -18, CONVERT(date, GETDATE())) )

-- Validate email format
--email format
ALTER TABLE [dbo].[USER] ADD CONSTRAINT [EMAIL_FORMAT] CHECK ( [email] LIKE '%_@_%._%' )

-- Validate phone number format
--phone number format
IF EXISTS (SELECT 1 FROM sys.check_constraints WHERE [name]='PHONE_FORMAT' AND parent_object_id=OBJECT_ID('[dbo].[USER]'))
BEGIN
	ALTER TABLE [dbo].[USER] DROP CONSTRAINT [PHONE_FORMAT];
END
ALTER TABLE [dbo].[USER] ADD CONSTRAINT [PHONE_FORMAT] CHECK ( [phone] LIKE '+%' AND [phone] NOT LIKE '%[^0-9+() -]%' )


-- Constraints for DOCVEH table
--DOCVEH
-- Ensure document issued date is in the past
--issued in the past
ALTER TABLE [dbo].[DOCVEH] ADD CONSTRAINT [ISSUEDPAST_VEHICLE] CHECK( [issued]<=CONVERT(date, GETDATE()) )

-- Ensure document expires in the future
--expires in the future
ALTER TABLE [dbo].[DOCVEH] ADD CONSTRAINT [EXPIRESFUTURE_VEHICLE] CHECK( [expires]>CONVERT(date, GETDATE()) )


-- Constraints for DOCDRI table
--DOCDRI
-- Ensure document issued date is in the past
--issued in the past
ALTER TABLE [dbo].[DOCDRI] ADD CONSTRAINT [ISSUEDPAST_DRIVER] CHECK( [issued]<=CONVERT(date, GETDATE()) )

-- Ensure document expires in the future
--expires in the future
ALTER TABLE [dbo].[DOCDRI] ADD CONSTRAINT [EXPIRESFUTURE_DRIVER] CHECK( [expires]>CONVERT(date, GETDATE()) )


-- Constraints for VEHICLE table
--VEHICLE
-- Ensure capacities are positive values
--more than 0
ALTER TABLE [dbo].[VEHICLE] ADD CONSTRAINT [SEAT_NUM] CHECK( [seatNum] IS NULL OR [seatNum]>0 )
ALTER TABLE [dbo].[VEHICLE] ADD CONSTRAINT [KG_NUM] CHECK( [kgCapacity] IS NULL OR [kgCapacity]>=0.001 )
ALTER TABLE [dbo].[VEHICLE] ADD CONSTRAINT [VOL_NUM] CHECK( [volCapacity] IS NULL OR [volCapacity]>=0.001 )

-- Ensure at least one capacity type is specified for vehicles
--kg vol seats


-- Constraints for TRIP table
--TRIP
-- Ensure at least one requirement type is specified for trips
--kg vol seats

-- Constraints for AVAILABILITY table
--Availability
-- Ensure either start or end time is specified, not both
--end || start
ALTER TABLE [dbo].[AVAILABILITY] ADD CONSTRAINT [STARTO_REND] CHECK( ([avStart] IS NOT NULL AND [avEnd] IS NULL) OR ([avStart] IS NULL AND [avEnd] IS NOT NULL) )

