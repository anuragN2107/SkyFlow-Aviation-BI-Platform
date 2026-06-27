USE SkyFlow_DW;
GO

--=========================================================
-- 1. Clean Staging Table for Flight Data
--=========================================================
CREATE TABLE Stage_Flights (
    FL_DATE VARCHAR(MAX),
    OP_CARRIER VARCHAR(MAX),
    OP_CARRIER_FL_NUM VARCHAR(MAX),
    ORIGIN VARCHAR(MAX),
    DEST VARCHAR(MAX),
    CRS_DEP_TIME VARCHAR(MAX),
    DEP_TIME VARCHAR(MAX),
    DEP_DELAY VARCHAR(MAX),
    TAXI_OUT VARCHAR(MAX),
    WHEELS_OFF VARCHAR(MAX),
    WHEELS_ON VARCHAR(MAX),
    TAXI_IN VARCHAR(MAX),
    CRS_ARR_TIME VARCHAR(MAX),
    ARR_TIME VARCHAR(MAX),
    ARR_DELAY VARCHAR(MAX),
    CANCELLED VARCHAR(MAX),
    CANCELLATION_CODE VARCHAR(MAX),
    DIVERTED VARCHAR(MAX),
    CRS_ELAPSED_TIME VARCHAR(MAX),
    ACTUAL_ELAPSED_TIME VARCHAR(MAX),
    AIR_TIME VARCHAR(MAX),
    DISTANCE VARCHAR(MAX),
    CARRIER_DELAY VARCHAR(MAX),
    WEATHER_DELAY VARCHAR(MAX),
    NAS_DELAY VARCHAR(MAX),
    SECURITY_DELAY VARCHAR(MAX),
    LATE_AIRCRAFT_DELAY VARCHAR(MAX)
);
GO

--=========================================================
-- 2. Clean Staging Table for Customer Reviews
--=========================================================
CREATE TABLE Stage_Reviews (
    Review_ID INT IDENTITY(1,1) PRIMARY KEY,
    Customer_Name VARCHAR(255),
    Airline VARCHAR(255),
    Flight_Date VARCHAR(100),
    Review_Text NVARCHAR(MAX),
    Class VARCHAR(100)
);
GO

--=====================================
--View Table
--=====================================
Select * from Stage_Flights 
Select * from Stage_Reviews


--==================================================
--Data Ingestion
--==================================================
BULK INSERT Stage_Flights
FROM 'C:\AirlineData\flights.csv'
WITH (
    FIRSTROW = 2,
    FIELDTERMINATOR = ',',
    ROWTERMINATOR = '0x0a',
    TABLOCK
);
GO


SELECT COUNT(*) AS TotalStagingRows FROM Stage_Flights; --Verifying Data
--============================================================================
-- Create Production Dimension
--============================================================================
IF OBJECT_ID('dbo.Dim_Airports', 'U') IS NOT NULL DROP TABLE dbo.Dim_Airports;
CREATE TABLE Dim_Airports (
    Airport_Key INT IDENTITY(1,1) PRIMARY KEY,
    Airport_Code VARCHAR(10) UNIQUE NOT NULL
);

-- 2. Create Production Fact Table
IF OBJECT_ID('dbo.Fact_Flights', 'U') IS NOT NULL DROP TABLE dbo.Fact_Flights;
CREATE TABLE Fact_Flights (
    Flight_Key BIGINT IDENTITY(1,1) PRIMARY KEY,
    Flight_Date DATE NULL,
    Airline_Code VARCHAR(50) NULL,
    Flight_Num VARCHAR(50) NULL,
    Origin_Airport VARCHAR(10) NULL,
    Dest_Airport VARCHAR(10) NULL,
    Scheduled_Dep_Time INT NULL,
    Actual_Dep_Time INT NULL,
    Dep_Delay FLOAT DEFAULT 0.0,
    Arr_Delay FLOAT DEFAULT 0.0,
    Is_Cancelled BIT DEFAULT 0,
    Is_Diverted BIT DEFAULT 0,
    Distance FLOAT NULL,
    Carrier_Delay FLOAT DEFAULT 0.0,
    Weather_Delay FLOAT DEFAULT 0.0,
    NAS_Delay FLOAT DEFAULT 0.0,
    Security_Delay FLOAT DEFAULT 0.0,
    Late_Aircraft_Delay FLOAT DEFAULT 0.0
);
--=============================================================================================
-- Optimization Index for Performance Modeling
--=============================================================================================
CREATE NONCLUSTERED INDEX IX_FactFlights_Date ON Fact_Flights(Flight_Date);
CREATE NONCLUSTERED INDEX IX_FactFlights_Route ON Fact_Flights(Origin_Airport, Dest_Airport);
GO

--=============================================================================================
-- Populate the Airport Dimension
INSERT INTO Dim_Airports (Airport_Code)
SELECT DISTINCT ORIGIN FROM Stage_Flights WHERE ORIGIN IS NOT NULL AND ORIGIN <> ''
UNION
SELECT DISTINCT DEST FROM Stage_Flights WHERE DEST IS NOT NULL AND DEST <> '';

Select * from Dim_Airports

-- Clean, Transform, and Populate the Fact Table
INSERT INTO Fact_Flights (
    Flight_Date, Airline_Code, Flight_Num, Origin_Airport, Dest_Airport,
    Scheduled_Dep_Time, Actual_Dep_Time, Dep_Delay, Arr_Delay, 
    Is_Cancelled, Is_Diverted, Distance, Carrier_Delay, Weather_Delay, 
    NAS_Delay, Security_Delay, Late_Aircraft_Delay
)
SELECT 
    TRY_CAST(FL_DATE AS DATE),
    NULLIF(OP_CARRIER, ''),
    NULLIF(OP_CARRIER_FL_NUM, ''),
    NULLIF(ORIGIN, ''),
    NULLIF(DEST, ''),
    TRY_CAST(CRS_DEP_TIME AS INT),
    TRY_CAST(DEP_TIME AS INT),
    ISNULL(TRY_CAST(DEP_DELAY AS FLOAT), 0.0),
    ISNULL(TRY_CAST(ARR_DELAY AS FLOAT), 0.0),
    CASE WHEN CANCELLED IN ('1.00', '1', '1.0') THEN 1 ELSE 0 END,
    CASE WHEN DIVERTED IN ('1.00', '1', '1.0') THEN 1 ELSE 0 END,
    TRY_CAST(DISTANCE AS FLOAT),
    ISNULL(TRY_CAST(CARRIER_DELAY AS FLOAT), 0.0),
    ISNULL(TRY_CAST(WEATHER_DELAY AS FLOAT), 0.0),
    ISNULL(TRY_CAST(NAS_DELAY AS FLOAT), 0.0),
    ISNULL(TRY_CAST(SECURITY_DELAY AS FLOAT), 0.0),
    ISNULL(TRY_CAST(LATE_AIRCRAFT_DELAY AS FLOAT), 0.0)
FROM Stage_Flights
WHERE ORIGIN IS NOT NULL AND DEST IS NOT NULL AND ORIGIN <> '' AND DEST <> '';
GO

--=====================================================================================
-- Verification of Production Data Warehouse
--==========================================================================================
SELECT 
    COUNT(*) AS TotalFlightsInFact,
    SUM(CASE WHEN Is_Cancelled = 1 THEN 1 ELSE 0 END) AS TotalCancellations,
    AVG(Dep_Delay) AS AverageDepartureDelay
FROM Fact_Flights;

--=========================================================================================
-- Extraction for ML training
--==================================================================================================
SELECT TOP 500000
    Flight_Date,
    Airline_Code,
    Flight_Num,
    Origin_Airport,
    Dest_Airport,
    Scheduled_Dep_Time,
    Distance,
    Dep_Delay,
    CASE WHEN Dep_Delay > 15 THEN 1 ELSE 0 END AS Is_Delayed 
FROM Fact_Flights
WHERE Is_Cancelled = 0 AND Is_Diverted = 0
ORDER BY NEWID(); 
GO

--======================================================================================
--Push the NLP Results into SQL Server
--======================================================================================
IF OBJECT_ID('dbo.Fact_Reviews', 'U') IS NOT NULL DROP TABLE dbo.Fact_Reviews;
CREATE TABLE Fact_Reviews (
    Passenger_ID INT PRIMARY KEY,
    Gender VARCHAR(50),
    Customer_Type VARCHAR(100),
    Age INT,
    Type_of_Travel VARCHAR(100),
    Class VARCHAR(100),
    Flight_Distance FLOAT,
    Departure_Delay_Mins FLOAT,
    Arrival_Delay_Mins FLOAT,
    Satisfaction_Status VARCHAR(50),
    Review_Text NVARCHAR(MAX),
    Sentiment_Score FLOAT,
    Sentiment_Category VARCHAR(50)
);
GO

USE SkyFlow_DW;
GO

--===================================================================
--Data Ingestion
--=================================================================
BULK INSERT Fact_Reviews
FROM 'C:\AirlineData\enriched_customer_reviews.csv'
WITH (
    FIRSTROW = 2,               
    FIELDTERMINATOR = ',',      
    ROWTERMINATOR = '0x0a',     
    TABLOCK,                  
    FORMAT = 'CSV'            
);
GO

--Verify the Ingestion
SELECT COUNT(*) AS TotalReviewsLoaded FROM Fact_Reviews;
--Check top 5 Records
SELECT TOP 5 
    Passenger_ID, 
    Class, 
    Satisfaction_Status, 
    Sentiment_Score, 
    Sentiment_Category 
FROM Fact_Reviews;
--========================================================================================