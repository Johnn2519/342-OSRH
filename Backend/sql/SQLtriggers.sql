--Rating
CREATE TRIGGER [tr_FEEDBACK_Rating] ON [dbo].[FEEDBACK]
AFTER INSERT
AS
BEGIN
	SET NOCOUNT ON;
	UPDATE [USER]
	SET [rating]=(
		SELECT CAST( AVG( CAST([FEEDBACK].[rating] AS DECIMAL(3,2)) )  AS DECIMAL(3,2))
		FROM [FEEDBACK]
		WHERE [FEEDBACK].[to]=[USER].[userID]
	)
	FROM [USER]
	JOIN inserted ON inserted.[to]=[USER].[userID];
END;

--checkedBy a System Worker in DocVeh
CREATE TRIGGER [tr_CHECKEDBY_DOCVEH] ON [dbo].[DOCVEH]
AFTER INSERT, UPDATE
AS
BEGIN
	SET NOCOUNT ON;
	IF EXISTS(
		SELECT 1
		FROM inserted 
		JOIN [dbo].[USER] ON inserted.[checkedBy]=[dbo].[USER].[userID]
		WHERE [dbo].[USER].[userType]!=2
	)
	BEGIN
		RAISERROR('Only a System Worker can check the documents of a vehicle.', 16, 1);
		ROLLBACK TRANSACTION;
		RETURN;
	END
END;

--checkedBy a System Worker in DocDri
CREATE TRIGGER [tr_CHECKEDBY_DOCDRI] ON [dbo].[DOCDRI]
AFTER INSERT, UPDATE
AS
BEGIN
	SET NOCOUNT ON;
	IF EXISTS(
		SELECT 1
		FROM inserted
		JOIN [dbo].[USER] ON inserted.[checkedBy]=[dbo].[USER].[userID]
		WHERE [dbo].[USER].[userType]!=2
	)
	BEGIN
		RAISERROR('Only a System Worker can check the documents of a driver.', 16, 1);
		ROLLBACK TRANSACTION;
		RETURN;
	END
END;

--byUserID a System Worker in CHECKDOC
CREATE TRIGGER [tr_CHECKEDBY_CHECKDOC] ON [dbo].[CHECKDOC]
AFTER INSERT, UPDATE
AS
BEGIN
	SET NOCOUNT ON;
	IF EXISTS(
		SELECT 1
		FROM inserted 
		JOIN [dbo].[USER] ON inserted.[byUserID]=[dbo].[USER].[userID]
		WHERE [dbo].[USER].[userType]!=2
	)
	BEGIN
		RAISERROR('Only a System Worker can recheck documents.', 16, 1);
		ROLLBACK TRANSACTION;
		RETURN;
	END
END;

--availability
CREATE TRIGGER [tr_CHECK_AVAILABILITY] ON [dbo].[AVAILABILITY]
AFTER INSERT, UPDATE
AS
BEGIN
	SET NOCOUNT ON;
	IF EXISTS(
		SELECT 1
		FROM inserted
		JOIN [dbo].[VEHICLE] ON inserted.[car]=[dbo].[VEHICLE].[vehID]
		WHERE [dbo].[VEHICLE].[ready]=0
	)
	BEGIN
		RAISERROR('You can not use this vehicle. It is still under evaluation', 16, 1);
		ROLLBACK TRANSACTION;
		RETURN;
	END;
	
	UPDATE veh
	SET veh.[available]=1
	FROM [dbo].[VEHICLE] AS veh
	JOIN inserted ON inserted.[car]=veh.[vehID]
	WHERE veh.[ready]=1 AND inserted.[avStart] IS NOT NULL AND inserted.[avStart]<=GETDATE() AND inserted.[avEnd] IS NULL;
	
	UPDATE veh
	SET veh.[available]=0
	FROM [dbo].[VEHICLE] AS veh
	JOIN inserted ON inserted.[car]=veh.[vehID]
	WHERE veh.[ready]=1 AND inserted.[avStart] IS NULL AND inserted.[avEnd] IS NOT NULL AND inserted.[avEnd]<=GETDATE();
END;

--feedbacks max 2
CREATE TRIGGER [tr_FEEDBACK_MAX] ON [dbo].[FEEDBACK]
AFTER INSERT
AS
BEGIN
	SET NOCOUNT ON;
	IF EXISTS(
		SELECT 1
		FROM inserted
		CROSS APPLY(
			SELECT COUNT(*) AS cn
			FROM [dbo].[FEEDBACK]
			WHERE [dbo].[FEEDBACK].[subTrip]=inserted.[subTrip]
		)AS Counts
		WHERE Counts.cn>2
	)
	BEGIN
		RAISERROR('You can not have more feedbacks for this subtrip.', 16, 1);
		ROLLBACK TRANSACTION;
		RETURN;
	END
END;

--Payment to driver
CREATE TRIGGER [tr_PAY_Driver] ON [dbo].[PAYMENT]
AFTER INSERT
AS
BEGIN
	SET NOCOUNT ON;
	INSERT INTO [dbo].[PAYMENT] ( [date], [method], [from], [to], [subTrip], [price], [type] )
	SELECT
		GETDATE() AS [date], 6 AS [method], 0 AS [from], V.[driver] AS [to], 
			inserted.[subtrip], CAST((inserted.[price] - F.[amount]) AS SMALLMONEY) AS [price], 2 AS [type]
	FROM inserted
	JOIN [dbo].[USER] AS U ON U.[userID]=inserted.[from] AND U.[userType]=4
	JOIN [dbo].[SUBTRIP] AS S ON S.[subTripID]=inserted.[subTrip]
	JOIN [dbo].[TRIP] AS T ON T.[tripID]=S.[trip]
  	JOIN [dbo].[VEHICLE] AS V ON V.[vehID]=S.[vehicle]
	JOIN [dbo].[FEES] AS F ON F.[serviceType]=T.[serviceType] AND F.[startDate]<=GETDATE() AND ( F.[endDate] IS NULL OR F.[endDate] >= GETDATE() )
	WHERE inserted.[to] = 0 AND inserted.[type] = 1;
END;