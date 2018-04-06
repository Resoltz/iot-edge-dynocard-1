/******************************************************
 *
 * Name:         create-dynocard-schema.sql
 *     
 * Design Phase:
 *     Author:   John Miner
 *     Date:     04-01-2018
 *     Purpose:  Create the schema for the [db4cards] database.
 * 
 ******************************************************/

--
-- Create the database (run from master)
--

-- Make copy of existing database
-- CREATE DATABASE [db4cards01] AS COPY OF [db4cards];  



-- Delete existing database
/*

IF  EXISTS (SELECT name FROM sys.databases WHERE name = N'db4cards')
DROP DATABASE [db4cards]
GO

*/

-- Create new database
/*

CREATE DATABASE [db4cards]
(
MAXSIZE = 10GB,
EDITION = 'STANDARD',
SERVICE_OBJECTIVE = 'S1'
)
GO   

*/



--
-- Create Contained database user
--


-- Service Account
CREATE USER [dyno_user] WITH PASSWORD = 'GMZNAQ]Q6R6Ljz9>';

-- Give rights
EXEC sp_addrolemember 'db_owner', 'dyno_user'  




--
-- Create ACTIVE schema
--

-- Delete existing schema.
DROP SCHEMA IF EXISTS [ACTIVE]
GO
 
-- Add new schema.
CREATE SCHEMA [ACTIVE] AUTHORIZATION [dbo]
GO



--
-- Create STAGE schema
--

-- Delete existing schema.
DROP SCHEMA IF EXISTS [STAGE]
GO
 
-- Add new schema.
CREATE SCHEMA [STAGE] AUTHORIZATION [dbo]
GO



--
-- Create PUMP table
--
 
-- Delete existing table
DROP TABLE IF EXISTS [ACTIVE].[PUMP]
GO
 
-- Create new table
CREATE TABLE [ACTIVE].[PUMP]
(
  PU_ID INT IDENTITY(1, 1) NOT NULL,
  PU_TAG VARCHAR(32) NOT NULL,
  PU_INSTALLED DATE NOT NULL,
  PU_LONGITUDE REAL NULL,
  PU_LATITUDE REAL NULL,
  PU_DESCRIPTION VARCHAR(128) NULL,
  PU_UPDATE_DATE DATETIME CONSTRAINT [DF_PUMP_UPD_DATE] DEFAULT (getdate()) ,
  PU_UPDATE_BY VARCHAR(128) CONSTRAINT [DF_PUMP_UPD_BY] DEFAULT (coalesce(suser_sname(),'?')),
  CONSTRAINT [PK_PUMP_ID] PRIMARY KEY CLUSTERED (PU_ID ASC)
)
GO

-- Show no data
SELECT * FROM [ACTIVE].[PUMP];
GO



--
-- Create DYNO CARD table
--

-- Delete existing table
DROP TABLE IF EXISTS [ACTIVE].[DYNO_CARD]
GO
 
-- Create new table
CREATE TABLE [ACTIVE].[DYNO_CARD]
(
  DC_ID INT IDENTITY(1, 1) NOT NULL,
  PU_ID INT NOT NULL,
  DC_UPDATE_DATE DATETIME CONSTRAINT [DF_DYNO_CARD_DATE] DEFAULT (getdate()) ,
  DC_UPDATE_BY VARCHAR(128) CONSTRAINT [DF_DYNO_CARD_BY] DEFAULT (coalesce(suser_sname(),'?')),
  CONSTRAINT [PK_DYNO_CARD_ID] PRIMARY KEY CLUSTERED (DC_ID ASC)
)
GO

-- Add foreign key 
ALTER TABLE [ACTIVE].[DYNO_CARD] WITH CHECK 
  ADD CONSTRAINT [FK_PUMP_ID1] FOREIGN KEY([PU_ID])
  REFERENCES [ACTIVE].[PUMP] ([PU_ID])
GO

-- Show no data
SELECT * FROM [ACTIVE].[DYNO_CARD]
GO



--
-- Create EVENT table
--

-- Delete existing table
DROP TABLE IF EXISTS [ACTIVE].[EVENT]
GO
 
-- Create new table
CREATE TABLE [ACTIVE].[EVENT]
(
  EV_ID INT IDENTITY(1, 1) NOT NULL,
  PU_ID INT NOT NULL,
  EV_EPOC_DATE INT NULL,
  EV_UPDATE_DATE DATETIME CONSTRAINT [DF_EVENT_UPD_DATE] DEFAULT (getdate()) ,
  EV_UPDATE_BY VARCHAR(128) CONSTRAINT [DF_EVENT_UPD_BY] DEFAULT (coalesce(suser_sname(),'?')),
  CONSTRAINT [PK_EVENT_ID] PRIMARY KEY CLUSTERED (EV_ID ASC)
)
GO

-- Add foreign key 
ALTER TABLE [ACTIVE].[EVENT] WITH CHECK 
  ADD CONSTRAINT [FK_PUMP_ID2] FOREIGN KEY([PU_ID])
  REFERENCES [ACTIVE].[PUMP] ([PU_ID])
GO

-- Show no data
SELECT * FROM [ACTIVE].[EVENT]
GO



--
-- Create EVENT DETAIL table
--

-- Delete existing table
DROP TABLE IF EXISTS [ACTIVE].[EVENT_DETAIL]
GO
 

CREATE TABLE [ACTIVE].[EVENT_DETAIL]
(
    ED_ID [int] IDENTITY(1, 1) NOT NULL,
    EV_ID [int] NOT NULL,
    DC_ID [int] NOT NULL, 
    ED_TRIGGERED_EVENTS BIT CONSTRAINT [DF_EVENT_DETAIL_TRIGGERED_EVENTS] DEFAULT (0),
    ED_UPDATE_DATE DATETIME CONSTRAINT [DF_EVENT_DETAIL_UPD_DATE] DEFAULT (getdate()) ,
    ED_UPDATE_BY VARCHAR(128) CONSTRAINT [DF_EVENT_DETAIL_UPD_BY] DEFAULT (coalesce(suser_sname(),'?')),
    CONSTRAINT [PK_EVENT_DETAIL_ID] PRIMARY KEY CLUSTERED (ED_ID ASC)
)
GO

-- Add foreign key 
ALTER TABLE [ACTIVE].[EVENT_DETAIL] WITH CHECK 
  ADD CONSTRAINT [FK_EVENT_ID] FOREIGN KEY([EV_ID])
  REFERENCES [ACTIVE].[EVENT] ([EV_ID])
GO

-- Add foreign key 
ALTER TABLE [ACTIVE].[EVENT_DETAIL] WITH CHECK 
  ADD CONSTRAINT [FK_DYNO_CARD_ID2] FOREIGN KEY([DC_ID])
  REFERENCES [ACTIVE].[DYNO_CARD] ([DC_ID])
GO

-- Show no data
SELECT * FROM [ACTIVE].[EVENT_DETAIL]
GO



--
-- Create CARD HEADER table
--

-- Delete existing table
DROP TABLE IF EXISTS [ACTIVE].[CARD_HEADER]
GO
 
-- Create new table
CREATE TABLE [ACTIVE].[CARD_HEADER]
(
  CH_ID INT IDENTITY(1, 1) NOT NULL,
  DC_ID INT NOT NULL,
  CH_EPOC_DATE INT NOT NULL,
  CH_SCALED_MAX_LOAD REAL NULL,
  CH_SHUTDOWN_EVENT_ID INT NULL,
  CH_NUMBER_OF_POINTS INT NULL,
  CH_GROSS_STROKE REAL NULL,
  CH_NET_STROKE REAL NULL,
  CH_PUMP_FILLAGE REAL NULL,
  CH_FLUID_LOAD REAL NULL,
  CH_SCALED_MIN_LOAD REAL NULL,
  CH_STROKE_LENGTH REAL NULL,
  CH_STROKE_PERIOD REAL NULL,
  CH_CARD_TYPE CHAR(1) NULL,
  CH_UPDATE_DATE DATETIME CONSTRAINT [DF_CARD_HDR_UPD_DATE] DEFAULT (getdate()) ,
  CH_UPDATE_BY VARCHAR(128) CONSTRAINT [DF_CARD_HDR_UPD_BY] DEFAULT (coalesce(suser_sname(),'?')),
  CONSTRAINT [PK_CARD_HEADER_ID] PRIMARY KEY CLUSTERED (CH_ID ASC)
)
GO

-- Add foreign key 
ALTER TABLE [ACTIVE].[CARD_HEADER] WITH CHECK 
  ADD CONSTRAINT [FK_DYNO_CARD_ID1] FOREIGN KEY([DC_ID])
  REFERENCES [ACTIVE].[DYNO_CARD] ([DC_ID])
GO

-- Show no data
SELECT * FROM [ACTIVE].[CARD_HEADER]
GO



--
-- Create CARD DETAIL table
--

-- Delete existing table
DROP TABLE IF EXISTS [ACTIVE].[CARD_DETAIL]
GO
 
-- Create new table
CREATE TABLE [ACTIVE].[CARD_DETAIL]
(
  CD_ID INT IDENTITY(1, 1) NOT NULL,
  CH_ID INT NOT NULL,
  CD_POSITION REAL NOT NULL,
  CD_LOAD REAL NOT NULL,
  CD_UPDATE_DATE DATETIME CONSTRAINT [DF_CARD_DTL_UPD_DATE] DEFAULT (getdate()) ,
  CD_UPDATE_BY VARCHAR(128) CONSTRAINT [DF_CARD_DTL_UPD_BY] DEFAULT (coalesce(suser_sname(),'?')),
  CONSTRAINT [PK_CARD_DETAIL_ID] PRIMARY KEY CLUSTERED (CD_ID ASC)
);


-- Add foreign key 
ALTER TABLE [ACTIVE].[CARD_DETAIL] WITH CHECK 
  ADD CONSTRAINT [FK_HEADER_ID] FOREIGN KEY([CH_ID])
  REFERENCES [ACTIVE].[CARD_HEADER] ([CH_ID])
GO


-- Show no data
SELECT * FROM [ACTIVE].[CARD_DETAIL]
GO


--
-- Create SURFACE DATA table
--

-- Delete existing table
-- DROP TABLE IF EXISTS [STAGE].[SURFACE_DATA]
GO
 
-- Create new table
CREATE TABLE [STAGE].[SURFACE_DATA]
(
  SD_ID INT IDENTITY(1, 1) NOT NULL,
  SD_TAG VARCHAR(32) NOT NULL,
  SD_POSITION REAL NOT NULL,
  SD_LOAD REAL NOT NULL,
  CONSTRAINT [PK_SURFACE_DATA_ID] PRIMARY KEY CLUSTERED (SD_ID ASC)
);

-- Show the data
SELECT * FROM [STAGE].[SURFACE_DATA]
GO


--
-- Create PUMP DATA table
--

-- Delete existing table
-- DROP TABLE IF EXISTS [STAGE].[PUMP_DATA]
GO
 
-- Create new table
CREATE TABLE [STAGE].[PUMP_DATA]
(
  PD_ID INT IDENTITY(1, 1) NOT NULL,
  PD_TAG VARCHAR(32) NOT NULL,
  PD_SECS REAL NOT NULL,
  PD_POSITION REAL NOT NULL,
  PD_LOAD REAL NOT NULL,
  CONSTRAINT [PK_PUMP_DATA_ID] PRIMARY KEY CLUSTERED (PD_ID ASC)
);

-- Show the data
SELECT * FROM [STAGE].[PUMP_DATA]
GO


--
-- Make sure staging data is loaded
--

/*

Special thanks to
	Kimberly Martinez 
	Robert Cutler

From
    Sandia National Laboratories
    Albuquerque, NM 

For supplying sample data
    http://www.sandia.gov/media/dynamo.htm

Execute the following t-sql scripts

  insert-pump-data-set1.sql
  insert-pump-data-set2.sql

  insert-surface-data-set1.sql
  insert-surface-data-set2.sql
  insert-surface-data-set3.sql
  insert-surface-data-set4.sql

*/


-- !!!


/*
  ~~ 1 - Add sample pump data to the schema ~~
*/

INSERT INTO [ACTIVE].[PUMP] VALUES
(
    'SANDIA-06',
	'1996-12-01',
	'32.7767',
	'-90.0404',
	'TENSION PUMP DATA FROM DYNOCARD DATABASE CERCA 1996.',
	DEFAULT,
	DEFAULT
);

-- Show the data
SELECT * FROM [ACTIVE].[PUMP];
GO



/*
  ~~ 2 - Add dyno card data to the schema ~~
*/

-- Card 1
INSERT INTO [ACTIVE].[DYNO_CARD] VALUES
(
1,
DEFAULT,
DEFAULT
);

-- Card 2
INSERT INTO [ACTIVE].[DYNO_CARD] VALUES
(
1,
DEFAULT,
DEFAULT
);

-- Card 3
INSERT INTO [ACTIVE].[DYNO_CARD] VALUES
(
1,
DEFAULT,
DEFAULT
);


-- Card 4
INSERT INTO [ACTIVE].[DYNO_CARD] VALUES
(
1,
DEFAULT,
DEFAULT
);

-- Show the data
SELECT * FROM [ACTIVE].[DYNO_CARD];
GO



/*
  ~~ 3 - Create a surface card & pump card header/detail for each dyno card 1 ~~
*/

-- A - surface data (summary)
INSERT INTO [ACTIVE].[CARD_HEADER] 
(
    DC_ID,
	CH_EPOC_DATE,
    CH_SCALED_MAX_LOAD,
    CH_SCALED_MIN_LOAD,
    CH_STROKE_LENGTH,
    CH_STROKE_PERIOD,
	CH_NUMBER_OF_POINTS,
    CH_CARD_TYPE
) 
SELECT 
    1 AS DC_ID,
	CONVERT(int, DATEDIFF(ss, '01-01-1970 00:00:00', '12/13/96 10:00:00 AM')) as CH_EPOC_DATE,
    MAX(SD_LOAD) AS CH_SCALED_MAX_LOAD,
    MIN(SD_LOAD) AS CH_SCALED_MIN_LOAD,
	MAX(SD_POSITION) AS CH_STROKE_LENGTH,
	60.0 AS CH_STROKE_PERIOD,
	100 AS CH_NUMBER_OF_POINTS,
	'S' AS CH_CARD_TYPE
FROM 
    [STAGE].[SURFACE_DATA] WHERE SD_TAG = 'SX6E03A';
GO


-- B - surface data (details)
INSERT INTO [ACTIVE].[CARD_DETAIL]
(
    CH_ID,
	CD_POSITION,
	CD_LOAD
)
SELECT 
    1 AS CH_ID,
    SD_POSITION AS CH_POSITION,
    SD_LOAD AS CH_LOAD
FROM 
    [STAGE].[SURFACE_DATA] WHERE SD_TAG = 'SX6E03A'
GO


-- C - pump data (summary)
INSERT INTO [ACTIVE].[CARD_HEADER] 
(
    DC_ID,
	CH_EPOC_DATE,
    CH_SCALED_MAX_LOAD,
    CH_SCALED_MIN_LOAD,
    CH_STROKE_LENGTH,
    CH_STROKE_PERIOD,
	CH_NUMBER_OF_POINTS,
    CH_CARD_TYPE
) 
SELECT
    1 AS DC_ID,
	CONVERT(int, DATEDIFF(ss, '01-01-1970 00:00:00', '12/13/96 10:00:00 AM')) as CH_EPOC_DATE,
    MAX(PD_LOAD) AS CH_SCALED_MAX_LOAD,
    MIN(PD_LOAD) AS CH_SCALED_MIN_LOAD,
	MAX(PD_POSITION) AS CH_STROKE_LENGTH,
	60.0 AS CH_STROKE_PERIOD,
	275 AS CH_NUMBER_OF_POINTS,
	'P' AS CH_CARD_TYPE
FROM
    [STAGE].[PUMP_DATA] 
WHERE 
    PD_TAG = '3X6E03' AND PD_ID >= 1 AND PD_ID <= 275;
GO

-- D - pump data (details)
INSERT INTO [ACTIVE].[CARD_DETAIL]
(
    CH_ID,
	CD_POSITION,
	CD_LOAD
)
SELECT 
    2 AS CH_ID,
    PD_POSITION AS CH_POSITION,
    PD_LOAD AS CH_LOAD
FROM
    [STAGE].[PUMP_DATA] 
WHERE 
    PD_TAG = '3X6E03' AND PD_ID >= 1 AND PD_ID <= 275;
GO

-- Show the data
SELECT * FROM [ACTIVE].[CARD_HEADER] WHERE DC_ID = 1;
GO

-- Show the data
SELECT * FROM [ACTIVE].[CARD_DETAIL] WHERE CH_ID IN (1, 2);
GO



/*
  ~~ 4 - Create a surface card & pump card header/detail for each dyno card 2 ~~
*/

-- A - surface data (summary)
INSERT INTO [ACTIVE].[CARD_HEADER] 
(
    DC_ID,
	CH_EPOC_DATE,
    CH_SCALED_MAX_LOAD,
    CH_SCALED_MIN_LOAD,
    CH_STROKE_LENGTH,
    CH_STROKE_PERIOD,
	CH_NUMBER_OF_POINTS,
    CH_CARD_TYPE
) 
SELECT 
    2 AS DC_ID,
	CONVERT(int, DATEDIFF(ss, '01-01-1970 00:00:00', '12/13/96 11:00:00 AM')) as CH_EPOC_DATE,
    MAX(SD_LOAD) AS CH_SCALED_MAX_LOAD,
    MIN(SD_LOAD) AS CH_SCALED_MIN_LOAD,
	MAX(SD_POSITION) AS CH_STROKE_LENGTH,
	60.0 AS CH_STROKE_PERIOD,
	100 AS CH_NUMBER_OF_POINTS,
	'S' AS CH_CARD_TYPE
FROM 
    [STAGE].[SURFACE_DATA] WHERE SD_TAG = 'SX6E03B';
GO


-- B - surface data (details)
INSERT INTO [ACTIVE].[CARD_DETAIL]
(
    CH_ID,
	CD_POSITION,
	CD_LOAD
)
SELECT 
    3 AS CH_ID,
    SD_POSITION AS CH_POSITION,
    SD_LOAD AS CH_LOAD
FROM 
    [STAGE].[SURFACE_DATA] WHERE SD_TAG = 'SX6E03B'
GO


-- C - pump data (summary)
INSERT INTO [ACTIVE].[CARD_HEADER] 
(
    DC_ID,
	CH_EPOC_DATE,
    CH_SCALED_MAX_LOAD,
    CH_SCALED_MIN_LOAD,
    CH_STROKE_LENGTH,
    CH_STROKE_PERIOD,
	CH_NUMBER_OF_POINTS,
    CH_CARD_TYPE
) 
SELECT
    2 AS DC_ID,
	CONVERT(int, DATEDIFF(ss, '01-01-1970 00:00:00', '12/13/96 11:00:00 AM')) as CH_EPOC_DATE,
    MAX(PD_LOAD) AS CH_SCALED_MAX_LOAD,
    MIN(PD_LOAD) AS CH_SCALED_MIN_LOAD,
	MAX(PD_POSITION) AS CH_STROKE_LENGTH,
	60.0 AS CH_STROKE_PERIOD,
	275 AS CH_NUMBER_OF_POINTS,
	'P' AS CH_CARD_TYPE
FROM
    [STAGE].[PUMP_DATA] 
WHERE 
    PD_TAG = '3X6E03' AND PD_ID >= 276 AND PD_ID <= 550;
GO

-- D - pump data (details)
INSERT INTO [ACTIVE].[CARD_DETAIL]
(
    CH_ID,
	CD_POSITION,
	CD_LOAD
)
SELECT 
    4 AS CH_ID,
    PD_POSITION AS CH_POSITION,
    PD_LOAD AS CH_LOAD
FROM
    [STAGE].[PUMP_DATA] 
WHERE 
    PD_TAG = '3X6E03' AND PD_ID >= 276 AND PD_ID <= 550;
GO


-- Show the data
SELECT * FROM [ACTIVE].[CARD_HEADER] WHERE DC_ID = 2;
GO

-- Show the data
SELECT * FROM [ACTIVE].[CARD_DETAIL] WHERE CH_ID IN (3, 4);
GO



/*
  ~~ 5 - Create a surface card & pump card header/detail for each dyno card 3 ~~
*/

-- A - surface data (summary)
INSERT INTO [ACTIVE].[CARD_HEADER] 
(
    DC_ID,
	CH_EPOC_DATE,
    CH_SCALED_MAX_LOAD,
    CH_SCALED_MIN_LOAD,
    CH_STROKE_LENGTH,
    CH_STROKE_PERIOD,
	CH_NUMBER_OF_POINTS,
    CH_CARD_TYPE
) 
SELECT 
    3 AS DC_ID,
	CONVERT(int, DATEDIFF(ss, '01-01-1970 00:00:00', '12/13/96 12:00:00 PM')) as CH_EPOC_DATE,
    MAX(SD_LOAD) AS CH_SCALED_MAX_LOAD,
    MIN(SD_LOAD) AS CH_SCALED_MIN_LOAD,
	MAX(SD_POSITION) AS CH_STROKE_LENGTH,
	60.0 AS CH_STROKE_PERIOD,
	100 AS CH_NUMBER_OF_POINTS,
	'S' AS CH_CARD_TYPE
FROM 
    [STAGE].[SURFACE_DATA] WHERE SD_TAG = 'SX6I03A';
GO


-- B - surface data (details)
INSERT INTO [ACTIVE].[CARD_DETAIL]
(
    CH_ID,
	CD_POSITION,
	CD_LOAD
)
SELECT 
    5 AS CH_ID,
    SD_POSITION AS CH_POSITION,
    SD_LOAD AS CH_LOAD
FROM 
    [STAGE].[SURFACE_DATA] WHERE SD_TAG = 'SX6I03A'
GO


-- C - pump data (summary)
INSERT INTO [ACTIVE].[CARD_HEADER] 
(
    DC_ID,
	CH_EPOC_DATE,
    CH_SCALED_MAX_LOAD,
    CH_SCALED_MIN_LOAD,
    CH_STROKE_LENGTH,
    CH_STROKE_PERIOD,
	CH_NUMBER_OF_POINTS,
    CH_CARD_TYPE
) 
SELECT
    3 AS DC_ID,
	CONVERT(int, DATEDIFF(ss, '01-01-1970 00:00:00', '12/13/96 12:00:00 PM')) as CH_EPOC_DATE,
    MAX(PD_LOAD) AS CH_SCALED_MAX_LOAD,
    MIN(PD_LOAD) AS CH_SCALED_MIN_LOAD,
	MAX(PD_POSITION) AS CH_STROKE_LENGTH,
	60.0 AS CH_STROKE_PERIOD,
	275 AS CH_NUMBER_OF_POINTS,
	'P' AS CH_CARD_TYPE
FROM
    [STAGE].[PUMP_DATA] 
WHERE 
    PD_TAG = '3X6I03' AND PD_ID > 3002 AND PD_ID < 3278
GO


-- D - pump data (details)
INSERT INTO [ACTIVE].[CARD_DETAIL]
(
    CH_ID,
	CD_POSITION,
	CD_LOAD
)
SELECT 
    6 AS CH_ID,
    PD_POSITION AS CH_POSITION,
    PD_LOAD AS CH_LOAD
FROM
    [STAGE].[PUMP_DATA] 
WHERE 
    PD_TAG = '3X6I03' AND PD_ID > 3002 AND PD_ID < 3278
GO


-- Show the data
SELECT * FROM [ACTIVE].[CARD_HEADER] WHERE DC_ID = 3;
GO

-- Show the data
SELECT * FROM [ACTIVE].[CARD_DETAIL] WHERE CH_ID IN (5, 6);
GO



/*
  ~~ 6 - Create a surface card & pump card header/detail for each dyno card 4 ~~
*/

-- A - surface data (summary)
INSERT INTO [ACTIVE].[CARD_HEADER] 
(
    DC_ID,
	CH_EPOC_DATE,
    CH_SCALED_MAX_LOAD,
    CH_SCALED_MIN_LOAD,
    CH_STROKE_LENGTH,
    CH_STROKE_PERIOD,
	CH_NUMBER_OF_POINTS,
    CH_CARD_TYPE
) 
SELECT 
    4 AS DC_ID,
	CONVERT(int, DATEDIFF(ss, '01-01-1970 00:00:00', '12/13/96 01:00:00 PM')) as CH_EPOC_DATE,
    MAX(SD_LOAD) AS CH_SCALED_MAX_LOAD,
    MIN(SD_LOAD) AS CH_SCALED_MIN_LOAD,
	MAX(SD_POSITION) AS CH_STROKE_LENGTH,
	60.0 AS CH_STROKE_PERIOD,
	100 AS CH_NUMBER_OF_POINTS,
	'S' AS CH_CARD_TYPE
FROM 
    [STAGE].[SURFACE_DATA] WHERE SD_TAG = 'SX6I03B';
GO


-- B - surface data (details)
INSERT INTO [ACTIVE].[CARD_DETAIL]
(
    CH_ID,
	CD_POSITION,
	CD_LOAD
)
SELECT 
    7 AS CH_ID,
    SD_POSITION AS CH_POSITION,
    SD_LOAD AS CH_LOAD
FROM 
    [STAGE].[SURFACE_DATA] WHERE SD_TAG = 'SX6I03B'
GO


-- C - pump data (summary)
INSERT INTO [ACTIVE].[CARD_HEADER] 
(
    DC_ID,
	CH_EPOC_DATE,
    CH_SCALED_MAX_LOAD,
    CH_SCALED_MIN_LOAD,
    CH_STROKE_LENGTH,
    CH_STROKE_PERIOD,
	CH_NUMBER_OF_POINTS,
    CH_CARD_TYPE
) 
SELECT
    4 AS DC_ID,
	CONVERT(int, DATEDIFF(ss, '01-01-1970 00:00:00', '12/13/96 01:00:00 PM')) as CH_EPOC_DATE,
    MAX(PD_LOAD) AS CH_SCALED_MAX_LOAD,
    MIN(PD_LOAD) AS CH_SCALED_MIN_LOAD,
	MAX(PD_POSITION) AS CH_STROKE_LENGTH,
	60.0 AS CH_STROKE_PERIOD,
	275 AS CH_NUMBER_OF_POINTS,
	'P' AS CH_CARD_TYPE
FROM
    [STAGE].[PUMP_DATA] 
WHERE 
    PD_TAG = '3X6I03' AND PD_ID > 3278 AND PD_ID < 3554
GO


-- D - pump data (details)
INSERT INTO [ACTIVE].[CARD_DETAIL]
(
    CH_ID,
	CD_POSITION,
	CD_LOAD
)
SELECT 
    8 AS CH_ID,
    PD_POSITION AS CH_POSITION,
    PD_LOAD AS CH_LOAD
FROM
    [STAGE].[PUMP_DATA] 
WHERE 
    PD_TAG = '3X6I03' AND PD_ID > 3278 AND PD_ID < 3554
GO


-- Show the data
SELECT * FROM [ACTIVE].[CARD_HEADER] WHERE DC_ID = 4;
GO

-- Show the data
SELECT * FROM [ACTIVE].[CARD_DETAIL] WHERE CH_ID IN (7, 8);
GO




/*
  ~~ 7 - Create a single event ~~
*/


-- Add sample events
INSERT INTO [ACTIVE].[EVENT] VALUES
(
    1,
	CONVERT(int, DATEDIFF(ss, '01-01-1970 00:00:00', '12/13/96 10:00:00 AM')),
	DEFAULT,
	DEFAULT
);
GO

-- Show the data
SELECT * FROM [ACTIVE].[EVENT];
GO


/*
  ~~ 8 - Link 4 cards to one event ~~
*/


-- A - event detail 1 = dyno card 1
INSERT INTO [ACTIVE].[EVENT_DETAIL] VALUES
(
    1,
	1,
	DEFAULT,
	DEFAULT,
	DEFAULT
);
GO

-- B - event detail 2 = dyno card 2
INSERT INTO [ACTIVE].[EVENT_DETAIL] VALUES
(
    1,
	2,
	-1,
	DEFAULT,
	DEFAULT
);
GO

-- C - event detail 3 = dyno card 3
INSERT INTO [ACTIVE].[EVENT_DETAIL] VALUES
(
    1,
	3,
	DEFAULT,
	DEFAULT,
	DEFAULT
);
GO

-- D - event detail 4 = dyno card 4
INSERT INTO [ACTIVE].[EVENT_DETAIL] VALUES
(
    1,
	4,
	DEFAULT,
	DEFAULT,
	DEFAULT
);
GO

-- Show the data
SELECT * FROM [ACTIVE].[EVENT_DETAIL];
GO