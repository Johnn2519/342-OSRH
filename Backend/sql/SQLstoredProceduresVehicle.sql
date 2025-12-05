-- Inserts a vehicle together with its insurance document in one transaction
IF OBJECT_ID('dbo.spAddVehicleWithInsurance', 'P') IS NOT NULL
    DROP PROCEDURE dbo.spAddVehicleWithInsurance;
GO

CREATE PROCEDURE dbo.spAddVehicleWithInsurance
    @insuranceNum    INT,
    @seatNum         INT            = NULL,
    @kgCapacity      FLOAT          = NULL,
    @volCapacity     FLOAT          = NULL,
    @geoID           INT,
    @vehType         INT,
    @driver          INT,
    @available       BIT            = 0,
    @ready           BIT            = 0,
    @plate           INT,
    @docPath         NVARCHAR(200),
    @docIssued       DATE,
    @docExpires      DATE           = NULL,
    @docType         INT,
    @docCheckedBy    INT            = NULL,
    @docStatus       INT,
    @newVehID        INT            OUTPUT,
    @newDocID        INT            OUTPUT
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRY
        BEGIN TRAN;

        INSERT INTO dbo.VEHICLE
            (insuranceNum, seatNum, kgCapacity, volCapacity, geoID, vehType, driver, available, ready, plate)
        VALUES
            (@insuranceNum, @seatNum, @kgCapacity, @volCapacity, @geoID, @vehType, @driver, @available, @ready, @plate);

        SET @newVehID = SCOPE_IDENTITY();

        INSERT INTO dbo.DOCVEH
            (vehicleID, [path], issued, expires, docType, checkedBy, [status])
        VALUES
            (@newVehID, @docPath, @docIssued, @docExpires, @docType, @docCheckedBy, @docStatus);

        SET @newDocID = SCOPE_IDENTITY();

        COMMIT TRAN;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0 ROLLBACK TRAN;
        DECLARE @err NVARCHAR(4000) = ERROR_MESSAGE();
        THROW 50001, @err, 1;
    END CATCH
END;
GO
