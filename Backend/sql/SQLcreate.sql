--USER

CREATE TABLE [dbo].[USER](
[userID] [int] IDENTITY(1,1) NOT NULL,
[username] [nvarchar](20) NOT NULL,
[name] [nvarchar](30) NOT NULL,
[surname] [nvarchar](30) NOT NULL,
[dob] [date] NOT NULL,
[gender] [int] NOT NULL,
[email] [nvarchar](50) NOT NULL,
[address] [nvarchar](100) NULL,
[phone] [nvarchar](25) NOT NULL,
[userType] [int] NOT NULL,
[rating] [decimal](3,2) NULL,
[password] [nvarchar](50) NOT NULL,
CONSTRAINT [PK_USER] PRIMARY KEY CLUSTERED ([userID]ASC),
CONSTRAINT [UN_USERNAME] UNIQUE ([username])
)

--user Type

CREATE TABLE [dbo].[USERTYPE](
[userTypeID] [int] IDENTITY(1,1) NOT NULL,
[name] [nvarchar](20) NOT NULL,
[description] [nvarchar](50) NULL,
CONSTRAINT [PK_USERTYPE] PRIMARY KEY CLUSTERED ([userTypeID] ASC)
)

--Documents for vehicle

CREATE TABLE [dbo].[DOCVEH](
[docID] [int] IDENTITY(1,1) NOT NULL,
[vehicleID] [int] NOT NULL,
[path] [nvarchar](200) NOT NULL,
[issued] [date] NOT NULL,
[expires] [date] NOT NULL,
[docType] [int] NOT NULL,
[checkedBy] [int] NULL,
[status] [int] NOT NULL,
CONSTRAINT [PK_DOCVEH] PRIMARY KEY CLUSTERED ([docID] ASC)
)

--Documents Check

CREATE TABLE [dbo].[CHECKDOC](
[checkDocID] [int] IDENTITY(1,1) NOT NULL,
[docID] [int] NOT NULL,
[status] [int] NOT NULL,
[comments] [nvarchar](100) NOT NULL,
[byUserID] [int] NOT NULL,
CONSTRAINT [PK_CHECKDOC] PRIMARY KEY CLUSTERED ([checkDocID] ASC)
)

--Documents for drivers

CREATE TABLE [dbo].[DOCDRI](
[docID] [int] IDENTITY(1,1) NOT NULL,
[driverID] [int] NOT NULL,
[path] [nvarchar](200) NOT NULL,
[issued] [date] NOT NULL,
[expires] [date] NULL,
[docType] [int] NOT NULL,
[checkedBy] [int] NULL,
[status] [int] NOT NULL,
CONSTRAINT [PK_DOCDRI] PRIMARY KEY CLUSTERED ([docID] ASC)
)

--docStatus

CREATE TABLE [dbo].[DOCSTATUS](
[docStatusID] [int] IDENTITY(1,1) NOT NULL,
[name] [nvarchar](20) NOT NULL,
[okToRun] [bit] NOT NULL,
CONSTRAINT [PK_DOCSTATUS] PRIMARY KEY CLUSTERED ([docStatusID] ASC)
)

--Vehicle

CREATE TABLE [dbo].[VEHICLE](
[vehID] [int] IDENTITY(1,1) NOT NULL,
[insuranceNum] [int] NOT NULL,
[seatNum] [int] NULL,
[kgCapacity] [float] NULL,
[volCapacity] [float] NULL,
[geoID] [int] NOT NULL,
[vehType] [int] NOT NULL,
[driver] [int] NOT NULL,
[available] [bit] NOT NULL DEFAULT 0,
[ready] [bit] NOT NULL DEFAULT 0,
[plate] [int] NOT NULL,
CONSTRAINT [PK_VEHICLE] PRIMARY KEY CLUSTERED ([vehID] ASC),
CONSTRAINT [UN_PLATE] UNIQUE ([plate])
)

--VehicleType

CREATE TABLE [dbo].[VEHTYPE](
[vehType] [int] IDENTITY(1,1) NOT NULL,
[name] [nvarchar](50) NOT NULL,
CONSTRAINT [PK_VEHTYPE] PRIMARY KEY CLUSTERED ([vehType] ASC)
)

--GENDER

CREATE TABLE [dbo].[GENDER](
[genderID] [int] IDENTITY(1,1) NOT NULL,
[name] [nvarchar](20) NOT NULL,
CONSTRAINT [PK_GENDER] PRIMARY KEY CLUSTERED ([genderID] ASC)
)

--Doc Types

CREATE TABLE [dbo].[DOCTYPE](
[docTypeID] [int] IDENTITY(1,1) NOT NULL,
[name] [nvarchar](20) NOT NULL,
[description] [nvarchar](200) NULL,
[type] [int] NOT NULL,
CONSTRAINT [PK_DOCTYPE] PRIMARY KEY CLUSTERED ([docTypeID] ASC)
)

--Doc Types Types

CREATE TABLE [dbo].[DOCTYPETYPE](
[docTypeTypeID] [int] IDENTITY(1,1) NOT NULL,
[name] [nvarchar](20) NOT NULL,
CONSTRAINT [PK_DOCTYPETYPE] PRIMARY KEY CLUSTERED ([docTypeTypeID] ASC)
)


--Availability

CREATE TABLE [dbo].[AVAILABILITY](
[avID] [int] IDENTITY(1,1) NOT NULL,
[avStart] [smalldatetime] NULL,
[avEnd] [smalldatetime] NULL,
[car] [int] NOT NULL,
CONSTRAINT [PK_AVAILABILITY] PRIMARY KEY CLUSTERED ([avID] ASC)
)

--Geofence

CREATE TABLE [dbo].[GEOFENCE](
[geoID] [int] IDENTITY(1,1) NOT NULL,
[longMax] [decimal](10,6) NOT NULL,
[latMax] [decimal](9,6) NOT NULL,
[longMin] [decimal](10,6) NOT NULL,
[latMin] [decimal](9,6) NOT NULL,
[name] [nvarchar](20) NULL,
CONSTRAINT [PK_GEOFENCE] PRIMARY KEY CLUSTERED ([geoID] ASC)
)

--Bridge

CREATE TABLE [dbo].[BRIDGE](
[bridgeID] [int] IDENTITY(1,1) NOT NULL,
[longtitude] [decimal](10,6) NOT NULL,
[latitude] [decimal](9,6) NOT NULL,
[name] [nvarchar](20) NULL,
CONSTRAINT [PK_BRIDGE] PRIMARY KEY CLUSTERED ([bridgeID] ASC)
)

--Connectors

CREATE TABLE [dbo].[CONNECT](
[connectID] [int] IDENTITY(1,1) NOT NULL,
[bridgeID] [int] NOT NULL,
[geoID] [int] NOT NULL,
CONSTRAINT [PK_CONNECT] PRIMARY KEY CLUSTERED ([connectID] ASC)
)

--Feedback

CREATE TABLE [dbo].[FEEDBACK](
[feedID] [int] IDENTITY(1,1) NOT NULL,
[entryDate] [smalldatetime] NOT NULL DEFAULT GETDATE(),
[comment] [nvarchar](150) NULL,
[subTrip] [int] NOT NULL,
[from] [int] NOT NULL,
[to] [int] NOT NULL,
[rating] [tinyint] NULL CHECK ([rating] BETWEEN 1 AND 5),
CONSTRAINT [PK_FEEDBACK] PRIMARY KEY CLUSTERED ([feedID] ASC)
)

--GDPR

CREATE TABLE [dbo].[GDPR](
[logID] [int] IDENTITY(1,1) NOT NULL,
[action] [int] NOT NULL,
[status] [int] NOT NULL,
[proccessedBy] [int] NULL,
[entryDate] [smalldatetime] NOT NULL DEFAULT GETDATE(),
[requestedBy] [int] NOT NULL,
[finishedDate] [smalldatetime] NULL,
CONSTRAINT [PK_GDPR] PRIMARY KEY CLUSTERED ([logID] ASC)
)

--gdprAction

CREATE TABLE [dbo].[GDPRACTIONS](
[gdprActionID] [int] IDENTITY(1,1) NOT NULL,
[name] [nvarchar](20) NOT NULL,
[description] [nvarchar](60) NOT NULL,
CONSTRAINT [PK_GDPRACTIONS] PRIMARY KEY CLUSTERED ([gdprActionID] ASC)
)

--gdprStatus

CREATE TABLE [dbo].[GDPRSTATUS](
[gdprID] [int] IDENTITY(1,1) NOT NULL,
[name] [nvarchar](20) NOT NULL,
CONSTRAINT [PK_GDPRSTATUS] PRIMARY KEY CLUSTERED ([gdprID] ASC)
)

--TRIP

CREATE TABLE [dbo].[TRIP](
[tripID] [int] IDENTITY(1,1) NOT NULL,
[startLong] [decimal](10,6) NOT NULL,
[startLat] [decimal](9,6) NOT NULL,
[endtLong] [decimal](10,6) NOT NULL,
[endLat] [decimal](9,6) NOT NULL,
[startTime] [smalldatetime] NOT NULL,
[endTime] [smalldatetime] NULL,
[reqTime] [smalldatetime] NOT NULL DEFAULT GETDATE(),
[status] [int] NOT NULL,
[seatNum] [int] NULL,
[kgNum] [float] NULL,
[volNum] [float] NULL,
[serviceType] [int] NOT NULL,
[requestedBy] [int] NOT NULL,
CONSTRAINT [PK_TRIP] PRIMARY KEY CLUSTERED ([tripID] ASC)
)

--fee

CREATE TABLE [dbo].[FEES](
[feesID] [int] IDENTITY(1,1) NOT NULL,
[serviceType] [int] NOT NULL,
[amount] [smallmoney] NOT NULL,
[startDate] [smalldatetime] NOT NULL,
[endDate] [smalldatetime] NULL,
CONSTRAINT [PK_FEES] PRIMARY KEY CLUSTERED ([feesID] ASC)
)


--SERVICE_TYPE

CREATE TABLE [dbo].[SERVICETYPE](
[serviceTypeID] [int] IDENTITY(1,1) NOT NULL,
[minPayment] [smallmoney] NOT NULL,
[description] [nvarchar](100) NOT NULL,
[name] [nvarchar](50) NOT NULL,
[moneyRate] [smallmoney] NOT NULL,
[unit] [nvarchar](10) NOT NULL,
CONSTRAINT [PK_SERVICETYPE] PRIMARY KEY CLUSTERED ([serviceTypeID] ASC)
)

--SubTrip

CREATE TABLE [dbo].[SUBTRIP](
[subTripID] [int] IDENTITY(1,1) NOT NULL,
[startLong] [decimal](10,6) NOT NULL,
[startLat] [decimal](9,6) NOT NULL,
[endtLong] [decimal](10,6) NOT NULL,
[endLat] [decimal](9,6) NOT NULL,
[startTime] [smalldatetime] NOT NULL,
[endTime] [smalldatetime] NULL,
[status] [int] NOT NULL,
[price] [smallmoney] NOT NULL,
[vehicle] [int] NULL,
[trip] [int] NOT NULL,
CONSTRAINT [PK_SUBTRIP] PRIMARY KEY CLUSTERED ([subTripID] ASC)
)

--tripStatus

CREATE TABLE [dbo].[TRIPSTATUS](
[tripStatusID] [int] IDENTITY(1,1) NOT NULL,
[name] [nvarchar](20) NOT NULL,
CONSTRAINT [PK_TRIPSTATUS] PRIMARY KEY CLUSTERED ([tripStatusID] ASC)
)

--payment

CREATE TABLE [dbo].[PAYMENT](
[paymentID] [int] IDENTITY(1,1) NOT NULL,
[date] [smalldatetime] NOT NULL DEFAULT GETDATE(),
[method] [int] NOT NULL,
[from] [int] NOT NULL,
[to] [int] NOT NULL,
[subTrip] [int] NULL,
[price] [smallmoney] NOT NULL,
[type] [int] NOT NULL,
CONSTRAINT [PK_PAYMENT] PRIMARY KEY CLUSTERED ([paymentID] ASC)
)

--paymentType

CREATE TABLE [dbo].[PAYTYPE](
[payTypeID] [int] IDENTITY(1,1) NOT NULL,
[name] [nvarchar](20) NOT NULL,
CONSTRAINT [PK_PAYTYPE] PRIMARY KEY CLUSTERED ([payTypeID] ASC)
)

--method

CREATE TABLE [dbo].[PAYMENTMETHOD](
[paymentMethodID] [int] IDENTITY(1,1) NOT NULL,
[name] [nvarchar](20) NOT NULL,
[description] [nvarchar](20) NULL,
CONSTRAINT [PK_PAYMENTMETHOD] PRIMARY KEY CLUSTERED ([paymentMethodID] ASC)
)

--TRIPLOGAction

CREATE TABLE [dbo].[TRIPLOGACTION](
[tripLogActionID] [int] IDENTITY(1,1) NOT NULL,
[name] [nvarchar](20) NOT NULL,
CONSTRAINT [PK_TRIPLOGACTION] PRIMARY KEY CLUSTERED ([tripLogActionID] ASC)
)

--TRIPLOG

CREATE TABLE [dbo].[TRIPLOG](
[tripLogID] [int] IDENTITY(1,1) NOT NULL,
[date] [smalldatetime] NOT NULL DEFAULT GETDATE(),
[subTrip] [int] NOT NULL,
[driver] [int] NOT NULL,
[action] [int] NOT NULL,
CONSTRAINT [PK_TRIPLOG] PRIMARY KEY CLUSTERED ([tripLogID] ASC)
)

--veh serv

CREATE TABLE [dbo].[VEHSERV](
[vehServID] [int] IDENTITY(1,1) NOT NULL,
[car] [int] NOT NULL,
[service] [int] NOT NULL,
CONSTRAINT [PK_VEHSERV] PRIMARY KEY CLUSTERED ([vehServID] ASC)
)

--ServRequirements

CREATE TABLE [dbo].[SERVREQ](
[servReqID] [int] IDENTITY(1,1) NOT NULL,
[service] [int] NOT NULL,
[description] [nvarchar](200) NOT NULL,
CONSTRAINT [PK_SERVREQ] PRIMARY KEY CLUSTERED ([servReqID] ASC)
)

--Billings

CREATE TABLE [dbo].[BILLINGS](
[billingsID] [int] IDENTITY(1,1) NOT NULL,
[service] [int] NULL,
[userType] [int] NULL,
[amount] [smallmoney] NOT NULL,
[description] [nvarchar](70) NOT NULL,
CONSTRAINT [PK_BILLINGS] PRIMARY KEY CLUSTERED ([billingsID] ASC)
)
