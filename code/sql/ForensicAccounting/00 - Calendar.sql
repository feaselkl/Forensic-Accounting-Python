USE [master]
GO
IF (DB_ID('ForensicAccounting') IS NULL)
    CREATE DATABASE ForensicAccounting;
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET NOCOUNT ON
GO
USE [ForensicAccounting]
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
BULK INSERT dbo.Calendar FROM '/var/opt/mssql/scripts/CalendarData.csv' WITH(FORMAT = 'CSV', FIRSTROW = 2);
GO
