-- Comment: Start of Rating trigger definition
--Rating
CREATE TRIGGER [tr_FEEDBACK_Rating] ON [dbo].[FEEDBACK] -- Create trigger to update user rating after feedback insertion
AFTER INSERT -- Trigger fires after inserting into FEEDBACK table
AS -- Begin trigger body
BEGIN -- Start of trigger logic
	SET NOCOUNT ON; -- Suppress row count messages for performance
	UPDATE [USER] -- Update the USER table
	SET [rating]=( -- Set the rating field to the average of feedbacks
		SELECT CAST( AVG( CAST([FEEDBACK].[rating] AS DECIMAL(3,2)) )  AS DECIMAL(3,2)) -- Calculate average rating with casting
		FROM [FEEDBACK] -- From FEEDBACK table
		WHERE [FEEDBACK].[to]=[USER].[userID] -- Where feedback is directed to this user
	) -- End of subquery for average rating
	FROM [USER] -- From USER table
	JOIN inserted ON inserted.[to]=[USER].[userID]; -- Join with inserted rows on recipient userID
END; -- End of trigger body

-- Comment: Start of checkedBy trigger for DOCVEH
--checkedBy a System Worker in DocVeh
CREATE TRIGGER [tr_CHECKEDBY_DOCVEH] ON [dbo].[DOCVEH] -- Create trigger to enforce system worker check on vehicle documents
AFTER INSERT, UPDATE -- Trigger fires after insert or update on DOCVEH
AS -- Begin trigger body
BEGIN -- Start of trigger logic
	SET NOCOUNT ON; -- Suppress row count messages
	IF EXISTS( -- Check if any inserted row violates the rule
		SELECT 1 -- Select a constant to check existence
		FROM inserted  -- From inserted rows
		JOIN [dbo].[USER] ON inserted.[checkedBy]=[dbo].[USER].[userID] -- Join with USER on checkedBy userID
		WHERE [dbo].[USER].[userType]!=2 -- Where user type is not system worker (2)
	) -- End of existence check
	BEGIN -- If violation exists
		RAISERROR('Only a System Worker can check the documents of a vehicle.', 16, 1); -- Raise error with message
		ROLLBACK TRANSACTION; -- Rollback the transaction
		RETURN; -- Exit trigger
	END -- End of if block
END; -- End of trigger body

-- Comment: Start of checkedBy trigger for DOCDRI
--checkedBy a System Worker in DocDri
CREATE TRIGGER [tr_CHECKEDBY_DOCDRI] ON [dbo].[DOCDRI] -- Create trigger to enforce system worker check on driver documents
AFTER INSERT, UPDATE -- Trigger fires after insert or update on DOCDRI
AS -- Begin trigger body
BEGIN -- Start of trigger logic
	SET NOCOUNT ON; -- Suppress row count messages
	IF EXISTS( -- Check if any inserted row violates the rule
		SELECT 1 -- Select a constant to check existence
		FROM inserted -- From inserted rows
		JOIN [dbo].[USER] ON inserted.[checkedBy]=[dbo].[USER].[userID] -- Join with USER on checkedBy userID
		WHERE [dbo].[USER].[userType]!=2 -- Where user type is not system worker (2)
	) -- End of existence check
	BEGIN -- If violation exists
		RAISERROR('Only a System Worker can check the documents of a driver.', 16, 1); -- Raise error with message
		ROLLBACK TRANSACTION; -- Rollback the transaction
		RETURN; -- Exit trigger
	END -- End of if block
END; -- End of trigger body

-- Comment: Start of byUserID trigger for CHECKDOC
--byUserID a System Worker in CHECKDOC
CREATE TRIGGER [tr_CHECKEDBY_CHECKDOC] ON [dbo].[CHECKDOC] -- Create trigger to enforce system worker recheck on documents
AFTER INSERT, UPDATE -- Trigger fires after insert or update on CHECKDOC
AS -- Begin trigger body
BEGIN -- Start of trigger logic
	SET NOCOUNT ON; -- Suppress row count messages
	IF EXISTS( -- Check if any inserted row violates the rule
		SELECT 1 -- Select a constant to check existence
		FROM inserted  -- From inserted rows
		JOIN [dbo].[USER] ON inserted.[byUserID]=[dbo].[USER].[userID] -- Join with USER on byUserID
		WHERE [dbo].[USER].[userType]!=2 -- Where user type is not system worker (2)
	) -- End of existence check
	BEGIN -- If violation exists
		RAISERROR('Only a System Worker can recheck documents.', 16, 1); -- Raise error with message
		ROLLBACK TRANSACTION; -- Rollback the transaction
		RETURN; -- Exit trigger
	END -- End of if block
END; -- End of trigger body

-- Comment: Start of availability trigger
--availability
CREATE TRIGGER [tr_CHECK_AVAILABILITY] ON [dbo].[AVAILABILITY] -- Create trigger to manage vehicle availability based on insertions/updates
AFTER INSERT, UPDATE -- Trigger fires after insert or update on AVAILABILITY
AS -- Begin trigger body
BEGIN -- Start of trigger logic
	SET NOCOUNT ON; -- Suppress row count messages
	IF EXISTS( -- Check if any inserted row tries to use unready vehicle
		SELECT 1 -- Select a constant to check existence
		FROM inserted -- From inserted rows
		JOIN [dbo].[VEHICLE] ON inserted.[car]=[dbo].[VEHICLE].[vehID] -- Join with VEHICLE on car ID
		WHERE [dbo].[VEHICLE].[ready]=0 -- Where vehicle is not ready
	) -- End of existence check
	BEGIN -- If violation exists
		RAISERROR('You can not use this vehicle. It is still under evaluation', 16, 1); -- Raise error with message
		ROLLBACK TRANSACTION; -- Rollback the transaction
		RETURN; -- Exit trigger
	END; -- End of if block
	
	UPDATE veh -- Update vehicle availability to 1 if conditions met
	SET veh.[available]=1 -- Set available to true
	FROM [dbo].[VEHICLE] AS veh -- From VEHICLE table aliased as veh
	JOIN inserted ON inserted.[car]=veh.[vehID] -- Join with inserted on car ID
	WHERE veh.[ready]=1 AND inserted.[avStart] IS NOT NULL AND inserted.[avStart]<=GETDATE() AND inserted.[avEnd] IS NULL; -- Conditions for setting available
	
	UPDATE veh -- Update vehicle availability to 0 if conditions met
	SET veh.[available]=0 -- Set available to false
	FROM [dbo].[VEHICLE] AS veh -- From VEHICLE table aliased as veh
	JOIN inserted ON inserted.[car]=veh.[vehID] -- Join with inserted on car ID
	WHERE veh.[ready]=1 AND inserted.[avStart] IS NULL AND inserted.[avEnd] IS NOT NULL AND inserted.[avEnd]<=GETDATE(); -- Conditions for setting unavailable
END; -- End of trigger body

-- Comment: Start of feedbacks max trigger
--feedbacks max 2
CREATE TRIGGER [tr_FEEDBACK_MAX] ON [dbo].[FEEDBACK] -- Create trigger to limit feedbacks per subtrip to 2
AFTER INSERT -- Trigger fires after insert on FEEDBACK
AS -- Begin trigger body
BEGIN -- Start of trigger logic
	SET NOCOUNT ON; -- Suppress row count messages
	IF EXISTS( -- Check if inserting would exceed 2 feedbacks
		SELECT 1 -- Select a constant to check existence
		FROM inserted -- From inserted rows
		CROSS APPLY( -- Cross apply to count feedbacks per subtrip
			SELECT COUNT(*) AS cn -- Count feedbacks
			FROM [dbo].[FEEDBACK] -- From FEEDBACK table
			WHERE [dbo].[FEEDBACK].[subTrip]=inserted.[subTrip] -- Where subtrip matches inserted
		)AS Counts -- Alias for count result
		WHERE Counts.cn>2 -- Where count exceeds 2
	) -- End of existence check
	BEGIN -- If violation exists
		RAISERROR('You can not have more feedbacks for this subtrip.', 16, 1); -- Raise error with message
		ROLLBACK TRANSACTION; -- Rollback the transaction
		RETURN; -- Exit trigger
	END -- End of if block
END; -- End of trigger body

-- Comment: Start of Payment to driver trigger
--Payment to driver
CREATE TRIGGER [tr_PAY_Driver] ON [dbo].[PAYMENT] -- Create trigger to automatically pay driver after payment insertion
AFTER INSERT -- Trigger fires after insert on PAYMENT
AS -- Begin trigger body
BEGIN -- Start of trigger logic
	SET NOCOUNT ON; -- Suppress row count messages
	INSERT INTO [dbo].[PAYMENT] ( [date], [method], [from], [to], [subTrip], [price], [type] ) -- Insert new payment record for driver
	SELECT -- Select values for insertion
		GETDATE() AS [date], 6 AS [method], 0 AS [from], V.[driver] AS [to],  -- Set date, method, from system, to driver
			inserted.[subtrip], CAST((inserted.[price] - F.[amount]) AS SMALLMONEY) AS [price], 2 AS [type] -- Set subtrip, price after fee, type to driver payment
	FROM inserted -- From inserted rows
	JOIN [dbo].[USER] AS U ON U.[userID]=inserted.[from] AND U.[userType]=4 -- Join with USER where from is customer (type 4)
	JOIN [dbo].[SUBTRIP] AS S ON S.[subTripID]=inserted.[subTrip] -- Join with SUBTRIP on subtrip ID
	JOIN [dbo].[TRIP] AS T ON T.[tripID]=S.[trip] -- Join with TRIP on trip ID
  	JOIN [dbo].[VEHICLE] AS V ON V.[vehID]=S.[vehicle] -- Join with VEHICLE on vehicle ID
	JOIN [dbo].[FEES] AS F ON F.[serviceType]=T.[serviceType] AND F.[startDate]<=GETDATE() AND ( F.[endDate] IS NULL OR F.[endDate] >= GETDATE() ) -- Join with FEES on service type and date range
	WHERE inserted.[to] = 0 AND inserted.[type] = 1; -- Where payment is to system (to=0) and type is customer payment (1)
END; -- End of trigger body