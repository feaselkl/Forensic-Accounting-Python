USE [ForensicAccounting]
GO
CREATE TABLE dbo.LineItem
(
	LineItemID INT IDENTITY(1,1) NOT NULL,
	BusID INT NOT NULL,
	VendorID INT NOT NULL,
	ExpenseCategoryID TINYINT NOT NULL,
	EmployeeID INT NOT NULL,
	CountersignerEmployeeID INT NULL,
	LineItemDate DATE NOT NULL,
	Amount DECIMAL(13, 2) NOT NULL,
	CONSTRAINT [PK_LineItem] PRIMARY KEY CLUSTERED (LineItemID),
	CONSTRAINT [FK_LineItem_Bus] FOREIGN KEY(BusID) REFERENCES dbo.Bus(BusID),
	CONSTRAINT [FK_LineItem_Vendor] FOREIGN KEY(VendorID) REFERENCES dbo.Vendor(VendorID),
	CONSTRAINT [FK_LineItem_ExpenseCategory] FOREIGN KEY(ExpenseCategoryID) REFERENCES dbo.ExpenseCategory(ExpenseCategoryID),
	CONSTRAINT [FK_LineItem_Employee] FOREIGN KEY(EmployeeID) REFERENCES dbo.Employee(EmployeeID),
	CONSTRAINT [FK_LineItem_Employee2] FOREIGN KEY(CountersignerEmployeeID) REFERENCES dbo.Employee(EmployeeID),
	CONSTRAINT [FK_LineItem_VendorExpenseCategory] FOREIGN KEY(VendorID, ExpenseCategoryID) REFERENCES dbo.VendorExpenseCategory(VendorID, ExpenseCategoryID),
	CONSTRAINT [CK_LineItem_CountersignerEmployeeID] CHECK((Amount < 1000 AND CountersignerEmployeeID IS NULL) OR (Amount >= 1000 AND CountersignerEmployeeID IS NOT NULL))
);
GO
