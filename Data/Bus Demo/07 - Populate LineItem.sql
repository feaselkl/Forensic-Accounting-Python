USE [ForensicAccountingPython]
GO
CREATE TABLE #ValuePerCategory
(
	ExpenseCategoryID TINYINT NOT NULL,
	MeanPrice DECIMAL(13, 2) NOT NULL,
	StdDevPrice DECIMAL(13, 2) NOT NULL
);

INSERT INTO #ValuePerCategory 
(
	ExpenseCategoryID,
	MeanPrice,
	StdDevPrice
)
VALUES
(1, 360, 800),
(2 , 440, 410),
(3 , 169.05, 14.99),
(4 , 39.95, 144),
(5 , 64.99, 39),
(6 , 148, 80),
(7 , 30, 30),
(8 , 75, 80),
(9 , 70, 90),
(10, 25, 18),
(11, 80, 65),
(12, 350, 290),
(13, 300, 70),
(14, 600, 300),
(15, 42.50, 8),
(16, 180, 45),
(17, 3.99, 27),
(18, 225, 130),
(19, 30, 9),
(20, 90, 288),
(21, 128, 97),
(22, 99, 99),
(23, 57, 44),
(24, 187, 55),
(25, 158, 62),
(26, 90, 40),
(27, 79, 56),
(28, 608, 558);

CREATE TABLE #RoadConditionExpenseCategories
(
	ExpenseCategoryID TINYINT NOT NULL
);

INSERT into #RoadConditionExpenseCategories
(
	ExpenseCategoryID
)
VALUES
(25),
(26),
(2),
(1),
(24);

CREATE TABLE #LineItem
(
	BusID INT NOT NULL,
	VendorID INT NOT NULL,
	ExpenseCategoryID TINYINT NOT NULL,
	EmployeeID INT NOT NULL,
	CountersignerEmployeeID INT NULL,
	LineItemDate DATE NOT NULL,
	Amount DECIMAL(13, 2) NOT NULL
);

DECLARE
	@InclusionThreshold DECIMAL(7,6) = 0.00028,
	@Precision INT = 2;

INSERT INTO #LineItem
(
	BusID,
	VendorID,
	ExpenseCategoryID,
	EmployeeID,
	CountersignerEmployeeID,
	LineItemDate,
	Amount
)
SELECT
	b.BusID,
	vec.VendorID,
	vec.ExpenseCategoryID,
	r.EmployeeID,
	CASE
		WHEN ABS(s.Amount) >= 1000 THEN
			CASE
				WHEN r.EmployeeID = r.CountersignerEmployeeID AND r.EmployeeID = 1 THEN 3
				WHEN r.EmployeeID = r.CountersignerEmployeeID AND r.EmployeeID = 12 THEN 4
				ELSE r.CountersignerEmployeeID
			END
		ELSE NULL
	END AS CountersignerEmployeeID,
	c.Date,
	ABS(s.Amount) AS Amount
FROM dbo.Calendar c
	CROSS JOIN dbo.Bus b
	CROSS JOIN dbo.VendorExpenseCategory vec
	INNER JOIN dbo.BusModel bm
		ON b.BusModelID = bm.BusModelID
	INNER JOIN #ValuePerCategory vpc
		ON vec.ExpenseCategoryID = vpc.ExpenseCategoryID
	CROSS APPLY (
		SELECT
			RAND(CHECKSUM(NEWID())) AS rand1,
			RAND(CHECKSUM(NEWID())) AS rand2,
			FLOOR(RAND(CHECKSUM(NEWID())) * (12 - 1 + 1)) + 1 AS EmployeeID,
			FLOOR(RAND(CHECKSUM(NEWID())) * (12 - 1 + 1)) + 1 AS CountersignerEmployeeID,
			RAND(CHECKSUM(NEWID())) AS InclusionThreshold
	) r
	CROSS APPLY (
		SELECT
			ROUND((SQRT(-2.0 * LOG(r.rand1)) * COS(2 * PI() * r.rand2)) * vpc.StdDevPrice, @Precision) + vpc.MeanPrice AS Amount
	) s
	CROSS APPLY (
		SELECT
			(r.InclusionThreshold * bm.ModelQuality * b.AverageRoadConditions) - (0.00007 * DATEDIFF(YEAR, b.DateFirstInService, c.Date)) AS InclusionThreshold
	) rFinal
	
WHERE
	c.Date >= '2011-01-01'
	AND c.Date < '2023-01-01'
	AND c.IsWeekend = 0
	AND b.DateFirstInService <= c.Date
	AND ISNULL(b.DateRetired, '9999-12-31') > c.Date
	AND rFinal.InclusionThreshold < @InclusionThreshold;

-- Fraudulent entries:
-- Vendor 5
-- Employees 4, 8, 10, 12
-- Soft cap of 1000
-- Started February 9th, 2019
-- Ended October 14th, 2021

SET @InclusionThreshold = 0.00024;
INSERT INTO #LineItem
(
	BusID,
	VendorID,
	ExpenseCategoryID,
	EmployeeID,
	CountersignerEmployeeID,
	LineItemDate,
	Amount
)
SELECT
	b.BusID,
	vec.VendorID,
	vec.ExpenseCategoryID,
	CASE r.EmployeeID
		WHEN 1 THEN 4
		WHEN 2 THEN 8
		WHEN 3 THEN 10
		WHEN 4 THEN 12
		ELSE 4
	END AS EmployeeID,
	CASE
		WHEN ABS(sFinal.Amount) >= 1000 THEN
			CASE
				WHEN r.EmployeeID = r.CountersignerEmployeeID AND r.EmployeeID = 1 THEN 10
				WHEN r.EmployeeID = r.CountersignerEmployeeID AND r.EmployeeID = 4 THEN 4
				ELSE
					CASE r.CountersignerEmployeeID
						WHEN 1 THEN 4
						WHEN 2 THEN 8
						WHEN 3 THEN 10
						WHEN 4 THEN 12
						ELSE 4
					END 
			END
		ELSE NULL
	END AS CountersignerEmployeeID,
	c.Date,
	sFinal.Amount
FROM dbo.Calendar c
	CROSS JOIN dbo.Bus b
	CROSS JOIN dbo.VendorExpenseCategory vec
	-- This is to simulate multiple entries
	CROSS JOIN dbo.Vendor v_simmult
	INNER JOIN dbo.BusModel bm
		ON b.BusModelID = bm.BusModelID
	INNER JOIN #ValuePerCategory vpc
		ON vec.ExpenseCategoryID = vpc.ExpenseCategoryID
	CROSS APPLY (
		SELECT
			RAND(CHECKSUM(NEWID())) AS rand1,
			RAND(CHECKSUM(NEWID())) AS rand2,
			RAND(CHECKSUM(NEWID())) AS rand3,
			FLOOR(RAND(CHECKSUM(NEWID())) * (4 - 1 + 1)) + 1 AS EmployeeID,
			FLOOR(RAND(CHECKSUM(NEWID())) * (4 - 1 + 1)) + 1 AS CountersignerEmployeeID,
			RAND(CHECKSUM(NEWID())) AS InclusionThreshold
	) r
	CROSS APPLY (
		SELECT
			ROUND((SQRT(-2.0 * LOG(r.rand1)) * COS(2 * PI() * r.rand2)) * (vpc.StdDevPrice * 1.5), @Precision) + (vpc.MeanPrice * 2.5) AS Amount
	) s
	CROSS APPLY (
		SELECT
			CASE
				WHEN ABS(s.Amount) >= 1000 AND r.rand3 < 0.7 THEN 999.99
				ELSE ABS(s.Amount)
			END AS Amount
	) sFinal
	CROSS APPLY (
		SELECT
			r.InclusionThreshold * bm.ModelQuality * b.AverageRoadConditions AS InclusionThreshold
	) rFinal
WHERE
	c.Date >= '2019-02-09'
	AND c.Date < '2021-10-14'
	AND c.IsWeekend = 0
	AND b.DateFirstInService <= c.Date
	AND ISNULL(b.DateRetired, '9999-12-31') > c.Date
	AND vec.VendorID = 5
	AND rFinal.InclusionThreshold < @InclusionThreshold;

INSERT INTO dbo.LineItem 
(
	BusID,
	VendorID,
	ExpenseCategoryID,
	EmployeeID,
	CountersignerEmployeeID,
	LineItemDate,
	Amount
)
SELECT
	li.BusID,
	li.VendorID,
	li.ExpenseCategoryID,
	li.EmployeeID,
	li.CountersignerEmployeeID,
	li.LineItemDate,
	li.Amount
FROM #LineItem li
ORDER BY
	li.LineItemDate,
	li.BusID,
	li.VendorID,
	li.ExpenseCategoryID,
	li.Amount DESC;

/* Seed in some gaps */
DELETE
FROM dbo.LineItem
WHERE LineItemID IN (6, 7, 14, 20, 199, 200, 201, 202, 339, 340, 341);
GO

SELECT
	c.CalendarYear,
	SUM(li.Amount) AS Amount
FROM dbo.LineItem li
	INNER JOIN dbo.Calendar c
		ON li.LineItemDate = c.Date
GROUP BY
	c.CalendarYear
ORDER BY
	c.CalendarYear;