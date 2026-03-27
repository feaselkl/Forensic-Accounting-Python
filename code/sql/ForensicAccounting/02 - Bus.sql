USE [ForensicAccounting]
GO
CREATE TABLE dbo.BusModel
(
	BusModelID TINYINT NOT NULL,
	BusModel VARCHAR(75) NOT NULL,
	ModelQuality DECIMAL(4,3) NOT NULL,
	CONSTRAINT [PK_BusModel] PRIMARY KEY CLUSTERED(BusModelID)
);
GO

-- Insert into bus model
INSERT INTO dbo.BusModel
(
	BusModelID,
	BusModel,
	ModelQuality
)
VALUES
	(1, 'Blue Bird 500', 0.79),
	(2, 'Blue Bird 750', 0.83),
	(3, 'Eldorado E-Z Rider II', 0.91),
	(4, 'Eldorado Axcess', 0.86),
	(5, 'Neoplan AN440', 0.71);
GO

CREATE TABLE dbo.Bus
(
	BusID INT NOT NULL,
	BusModelID TINYINT NOT NULL,
	AverageRoadConditions DECIMAL(4,3) NOT NULL,
	DateFirstInService DATE NOT NULL,
	DateRetired DATE NULL,
	CONSTRAINT [PK_Bus] PRIMARY KEY CLUSTERED (BusID),
	CONSTRAINT [FK_Bus_BusModel] FOREIGN KEY (BusModelID) REFERENCES dbo.BusModel(BusModelID)
);
GO

DECLARE
	@Mean DECIMAL(3,2) = 0.73,
	@sd DECIMAL(4,3) = 0.060,
	@Precision INT = 2;

-- Start with 600 buses
INSERT INTO dbo.Bus
(
	BusID,
	BusModelID,
	AverageRoadConditions,
	DateFirstInService,
	DateRetired
)
SELECT TOP (600)
	ROW_NUMBER() OVER (ORDER BY NEWID()) AS BusID,
	-- Pick models at random.
	CAST(RAND(CHECKSUM(NEWID())) * 5 AS INT) + 1 AS BusModelID,
	s.AverageRoadConditions,
	'2007-01-01' AS DateFirstInService,
	NULL AS DateRetired
FROM dbo.Calendar c
	-- Average road conditions is calculated as a normal distribution
	CROSS APPLY (
		SELECT
			RAND(CHECKSUM(NEWID())) AS rand1,
			RAND(CHECKSUM(NEWID())) AS rand2
	) r
	CROSS APPLY (
		SELECT
			ROUND((SQRT(-2.0 * LOG(r.rand1)) * COS(2 * PI() * r.rand2)) * @sd, @Precision) + @Mean AS AverageRoadConditions
	) s;

-- 80 new buses each year
INSERT INTO dbo.Bus
(
	BusID,
	BusModelID,
	AverageRoadConditions,
	DateFirstInService,
	DateRetired
)
SELECT
	600 + ROW_NUMBER() OVER (ORDER BY c.Date, ao.object_id),
	-- Pick models at random.
	CAST(RAND(CHECKSUM(NEWID())) * 5 AS INT) + 1 AS BusModelID,
	s.AverageRoadConditions,
	c.Date,
	NULL AS DateRetired
FROM dbo.Calendar c
	CROSS JOIN ( SELECT TOP(80) object_id FROM sys.all_objects ) ao
	-- Average road conditions is calculated as a normal distribution
	CROSS APPLY (
		SELECT
			RAND(CHECKSUM(NEWID())) AS rand1,
			RAND(CHECKSUM(NEWID())) AS rand2
	) r
	CROSS APPLY (
		SELECT
			ROUND((SQRT(-2.0 * LOG(r.rand1)) * COS(2 * PI() * r.rand2)) * @sd, @Precision) + @Mean AS AverageRoadConditions
	) s
WHERE
	c.CalendarDayOfYear = 1
	AND c.Date >= '2011-01-01'
	AND c.Date < '2023-01-01';

-- Retire ~50 buses each year
WITH candidates AS
(
	SELECT
		ROW_NUMBER() OVER (PARTITION BY c.Date ORDER BY NEWID()) AS rownum,
		c.Date,
		b.BusID,
		b.DateFirstInService,
		b.DateRetired
	FROM dbo.Calendar c
		INNER JOIN dbo.Bus b
			ON c.Date > b.DateFirstInService
	WHERE
		c.CalendarDayOfYear = 1
		AND c.Date >= '2011-01-01'
		AND c.Date < '2023-01-01'
		AND b.DateRetired IS NULL
)
UPDATE b
SET
	DateRetired = c.Date
FROM candidates c
	INNER JOIN dbo.Bus b
		ON c.BusID = b.BusID
WHERE
	c.rownum <= 53;
GO
