USE [master]
GO
IF (DB_ID('ForensicAccountingPython') IS NULL)
    CREATE DATABASE ForensicAccountingPython;
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET NOCOUNT ON
GO
USE [ForensicAccountingPython]
GO
CREATE TABLE [dbo].[Calendar]
(
	[DateKey] [int] NOT NULL,
	[Date] [date] NOT NULL,
	[Day] [tinyint] NOT NULL,
	[DayOfWeek] [tinyint] NOT NULL,
	[DayName] [varchar](10) NOT NULL,
	[IsWeekend] [bit] NOT NULL,
	[DayOfWeekInMonth] [tinyint] NOT NULL,
	[CalendarDayOfYear] [smallint] NOT NULL,
	[WeekOfMonth] [tinyint] NOT NULL,
	[CalendarWeekOfYear] [tinyint] NOT NULL,
	[CalendarMonth] [tinyint] NOT NULL,
	[MonthName] [varchar](10) NOT NULL,
	[CalendarQuarter] [tinyint] NOT NULL,
	[CalendarQuarterName] [char](2) NOT NULL,
	[CalendarYear] [int] NOT NULL,
	[FirstDayOfMonth] [date] NOT NULL,
	[LastDayOfMonth] [date] NOT NULL,
	[FirstDayOfWeek] [date] NOT NULL,
	[LastDayOfWeek] [date] NOT NULL,
	[FirstDayOfQuarter] [date] NOT NULL,
	[LastDayOfQuarter] [date] NOT NULL,
	[CalendarFirstDayOfYear] [date] NOT NULL,
	[CalendarLastDayOfYear] [date] NOT NULL,
	[FirstDayOfNextMonth] [date] NOT NULL,
	[CalendarFirstDayOfNextYear] [date] NOT NULL,
	[FiscalDayOfYear] [smallint] NOT NULL,
	[FiscalWeekOfYear] [tinyint] NOT NULL,
	[FiscalMonth] [tinyint] NOT NULL,
	[FiscalQuarter] [tinyint] NOT NULL,
	[FiscalQuarterName] [char](2) NOT NULL,
	[FiscalYear] [int] NOT NULL,
	[FiscalFirstDayOfYear] [date] NOT NULL,
	[FiscalLastDayOfYear] [date] NOT NULL,
	[FiscalFirstDayOfNextYear] [date] NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[Calendar] ADD  CONSTRAINT [PK_Calendar] PRIMARY KEY CLUSTERED 
(
	[DateKey] ASC
);
GO
CREATE EXTERNAL DATA SOURCE FA_External
WITH
(
    TYPE = BLOB_STORAGE,
    LOCATION = 'https://cspolybasepublic.blob.core.windows.net'
);
GO
BULK INSERT dbo.Calendar FROM 'sqlontheedgepublicdata/Windows_CalendarTable.csv' WITH(DATA_SOURCE = 'FA_External', FORMAT = 'CSV', FIRSTROW = 2);
GO
DROP EXTERNAL DATA SOURCE FA_External;
GO
