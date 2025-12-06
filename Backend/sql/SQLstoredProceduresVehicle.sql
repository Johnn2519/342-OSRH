-- Comment: Drop procedure if exists
-- Inserts a vehicle together with its insurance document in one transaction
IF OBJECT_ID('dbo.spAddVehicleWithInsurance', 'P') IS NOT NULL -- Check if procedure exists
    DROP PROCEDURE dbo.spAddVehicleWithInsurance; -- Drop the procedure if it exists
GO -- Batch separator

-- Comment: Create the procedure
CREATE PROCEDURE dbo.spAddVehicleWithInsurance -- Define the stored procedure
    @insuranceNum    INT, -- Parameter for insurance number
    @seatNum         INT            = NULL, -- Parameter for seat number, optional
    @kgCapacity      FLOAT          = NULL, -- Parameter for kg capacity, optional
    @volCapacity     FLOAT          = NULL, -- Parameter for volume capacity, optional
    @geoID           INT, -- Parameter for geo ID
    @vehType         INT, -- Parameter for vehicle type
    @driver          INT, -- Parameter for driver ID
    @available       BIT            = 0, -- Parameter for availability, default 0
    @ready           BIT            = 0, -- Parameter for ready status, default 0
    @plate           INT, -- Parameter for plate number
    @docPath         NVARCHAR(200), -- Parameter for document path
    @docIssued       DATE, -- Parameter for document issued date
    @docExpires      DATE           = NULL, -- Parameter for document expires date, optional
    @docType         INT, -- Parameter for document type
    @docCheckedBy    INT            = NULL, -- Parameter for checked by user, optional
    @docStatus       INT, -- Parameter for document status
    @newVehID        INT            OUTPUT, -- Output parameter for new vehicle ID
    @newDocID        INT            OUTPUT -- Output parameter for new document ID
AS -- Begin procedure body
BEGIN -- Start of procedure logic
    SET NOCOUNT ON; -- Suppress row count messages
    BEGIN TRY -- Start try block for error handling
        BEGIN TRAN; -- Begin transaction

        INSERT INTO dbo.VEHICLE -- Insert into VEHICLE table
            (insuranceNum, seatNum, kgCapacity, volCapacity, geoID, vehType, driver, available, ready, plate) -- Specify columns
        VALUES -- Provide values
            (@insuranceNum, @seatNum, @kgCapacity, @volCapacity, @geoID, @vehType, @driver, @available, @ready, @plate); -- Use parameters

        SET @newVehID = SCOPE_IDENTITY(); -- Get the new vehicle ID

        INSERT INTO dbo.DOCVEH -- Insert into DOCVEH table
            (vehicleID, [path], issued, expires, docType, checkedBy, [status]) -- Specify columns
        VALUES -- Provide values
            (@newVehID, @docPath, @docIssued, @docExpires, @docType, @docCheckedBy, @docStatus); -- Use parameters and new vehicle ID

        SET @newDocID = SCOPE_IDENTITY(); -- Get the new document ID

        COMMIT TRAN; -- Commit the transaction
    END TRY -- End try block
    BEGIN CATCH -- Start catch block
        IF @@TRANCOUNT > 0 ROLLBACK TRAN; -- Rollback if transaction active
        DECLARE @err NVARCHAR(4000) = ERROR_MESSAGE(); -- Declare error message variable
        THROW 50001, @err, 1; -- Throw custom error
    END CATCH -- End catch block
END; -- End of procedure body
GO -- Batch separator
