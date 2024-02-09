Use farm1
-- Procedure for inserting data into Animals table
-- Procedure for inserting data into Animals table with key check
CREATE PROCEDURE InsertAnimal(
    @p_AnimalID INT,
    @p_Name VARCHAR(255),
    @p_FoodGroupID INT,
    @p_BirthDate DATE,
    @p_Gravid BIT,
    @p_TagID INT,
    @p_ItemID INT,
    @p_ReportDate DATE
)
AS
BEGIN
    IF NOT EXISTS (SELECT 1 FROM Animals WHERE AnimalID = @p_AnimalID)
    BEGIN
        INSERT INTO Animals (AnimalID, Name, FoodGroupID, BirthDate, Gravid, TagID, ItemID, ReportDate)
        VALUES (@p_AnimalID, @p_Name, @p_FoodGroupID, @p_BirthDate, @p_Gravid, @p_TagID, @p_ItemID, @p_ReportDate);
    END
    ELSE
    BEGIN
        PRINT 'AnimalID already exists. Insertion failed.';
    END
END;
Drop Procedure InsertAnimal
-- Procedure for inserting data into FoodGroups table
CREATE PROCEDURE InsertFoodGroup (
    @p_FoodGroupID INT,
    @p_Name VARCHAR(255)
)
AS
BEGIN
    IF NOT EXISTS (SELECT 1 FROM FoodGroups WHERE FoodGroupID = @p_FoodGroupID)
    BEGIN
        INSERT INTO FoodGroups (FoodGroupID, Name)
        VALUES (@p_FoodGroupID, @p_Name);
    END
    ELSE
    BEGIN
        PRINT 'FoodGroupID already exists. Insertion failed.';
    END
END;

Drop Procedure InsertFoodGroup
-- Procedure for inserting data into Inventory table
CREATE PROCEDURE InsertInventory(
    @p_ItemID INT,
    @p_ItemType VARCHAR(255),
    @p_ItemName VARCHAR(255),
    @p_Quantity INT,
    @p_PricePerUnit DECIMAL(10, 2)
)
AS
BEGIN
    IF NOT EXISTS (SELECT 1 FROM Inventory WHERE ItemID = @p_ItemID)
    BEGIN
        INSERT INTO Inventory (ItemID, ItemType, ItemName, Quantity, PricePerUnit)
        VALUES (@p_ItemID, @p_ItemType, @p_ItemName, @p_Quantity, @p_PricePerUnit);
    END
    ELSE
    BEGIN
        PRINT 'ItemID already exists. Insertion failed.';
    END
END;
Drop Procedure InsertInventory
CREATE PROCEDURE InsertTag (
    @p_TagID INT,
    @p_TagName VARCHAR(255)
)
AS
BEGIN
    IF NOT EXISTS (SELECT 1 FROM Tags WHERE TagID = @p_TagID)
    BEGIN
        INSERT INTO Tags (TagID, TagName)
        VALUES (@p_TagID, @p_TagName);
    END
    ELSE
    BEGIN
        PRINT 'TagID already exists. Insertion failed.';
    END
END;
Drop PROCEDURE InsertTag
-- Procedure for inserting data into DailyReport table
CREATE PROCEDURE InsertDailyReport (
    @p_ReportDate DATE,
    @p_TotalMilkSold DECIMAL(10, 2),
    @p_TotalEarning DECIMAL(10, 2),
    @p_TotalDailyExpense DECIMAL(10, 2),
    @p_Profit DECIMAL(10, 2)
)
AS
BEGIN
    IF NOT EXISTS (SELECT 1 FROM DailyReport WHERE ReportDate = @p_ReportDate)
    BEGIN
        INSERT INTO DailyReport (ReportDate, TotalMilkSoldInLiters, TotalEarning, TotalDailyExpense, Profit)
        VALUES (@p_ReportDate, @p_TotalMilkSold, @p_TotalEarning, @p_TotalDailyExpense, @p_Profit);
    END
    ELSE
    BEGIN
        PRINT 'ReportDate already exists. Insertion failed.';
    END
END;
Drop Procedure InsertDailyReport
-- Procedure for inserting data into Tags table
CREATE PROCEDURE InsertTag
    @p_TagID INT,
    @p_TagName VARCHAR(255)
AS
BEGIN
    BEGIN TRY
        BEGIN TRANSACTION;
        
        INSERT INTO Tags (TagID, TagName)
        VALUES (@p_TagID, @p_TagName);
        
        COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0
            ROLLBACK TRANSACTION;
        
        THROW;
    END CATCH;
END;

-- Procedure for inserting data into DailyReport table
CREATE PROCEDURE InsertDailyReport
    @p_ReportDate DATE,
    @p_TotalMilkSold DECIMAL(10, 2),
    @p_TotalEarning DECIMAL(10, 2),
    @p_TotalDailyExpense DECIMAL(10, 2),
    @p_Profit DECIMAL(10, 2)
AS
BEGIN
    BEGIN TRY
        BEGIN TRANSACTION;
        
        INSERT INTO DailyReport (ReportDate, TotalMilkSoldInLiters, TotalEarning, TotalDailyExpense, Profit)
        VALUES (@p_ReportDate, @p_TotalMilkSold, @p_TotalEarning, @p_TotalDailyExpense, @p_Profit);
        
        COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0
            ROLLBACK TRANSACTION;
        
        THROW;
    END CATCH;
END;
------------------------------------------------------------------------------
EXEC InsertAnimal 443, 'Tiger', 1, '2023-02-01', 0, 102, 202, '2023-12-18';
EXEC InsertAnimal 1235, 'Elephant', 2, '2023-03-01', 0, 103, 203, '2023-12-18';
--------------------------------------------------------------------------

------------------------------------------------------------------------------
EXEC InsertFoodGroup 5000 , 'carnivore';
EXEC InsertFoodGroup 3, 'Omnivores';
------------------------------------------------------------------------------------

-----------------------------------------------------------------------------------
EXEC InsertInventory 201, 'Medicine', 'Painkiller', 50, 10.99;
EXEC InsertInventory 3201, 'Medicine', 'Painkiller', 50, 10.99;
---------------------------------------------------------------------------

----------------------------------------------------------------------------------------
EXEC InsertDailyReport '2023-12-18', 150.5, 500.75, 250.25, 250.5; -- Example Insertion
EXEC InsertDailyReport '2023-12-13', 150.5, 500.75, 250.25, 250.5; -- Example Insertion
-------------------------------------------------------------------------------------


--------------------------------------------------------------------------------------------
EXEC InsertTag 101, 'LargePredator'; -- Example insertion

EXEC InsertTag 1011, 'LargePredator'; -- Example insertion
--------------------------------------------------------------------------------------------
Select * from Animals

-------------------------------------------------------------
CREATE PROCEDURE GenerateSalesFromDailyReportSS
AS
BEGIN
    -- Declare variables
    DECLARE @SaleID INT, @AnimalID INT, @MilkSold DECIMAL(10, 2), @Earning DECIMAL(10, 2), @SaleDate DATE;
    
    -- Cursor to loop through DailyReport data
    DECLARE report_cursor CURSOR FOR
    SELECT ReportDate, TotalMilkSoldInLiters, TotalEarning
    FROM DailyReport;

    OPEN report_cursor;
    FETCH NEXT FROM report_cursor INTO @SaleDate, @MilkSold, @Earning;

    -- Loop through the DailyReport data and insert into Sales table
    WHILE @@FETCH_STATUS = 0
    BEGIN
        -- Get AnimalID based on ReportDate from DailyReport
        SELECT @AnimalID = AnimalID
        FROM Animals
        WHERE ReportDate = @SaleDate;

        -- Generate unique SaleID
        SELECT @SaleID = ISNULL(MAX(SaleID), 0) + 1 FROM Sales;

        -- Insert calculated data into Sales table
        INSERT INTO Sales (SaleID, AnimalID, MilkSoldInLiters, Earning, SaleDate)
        VALUES (@SaleID, @AnimalID, @MilkSold, @Earning, @SaleDate);

        FETCH NEXT FROM report_cursor INTO @SaleDate, @MilkSold, @Earning;
    END;

    CLOSE report_cursor;
    DEALLOCATE report_cursor;
END;
USE farm1
EXEC GenerateSalesFromDailyReportSS
----------------------run this--------------------------------
Select * from Sales
--------------------------------------------------------------


-----------------------------------------------------------------------------
CREATE PROCEDURE InsertAnimalChildrens (
    @p_ParentAnimalID INT,
    @p_ChildAnimalID INT
)
AS
BEGIN
    IF EXISTS (SELECT 1 FROM Animals WHERE AnimalID = @p_ParentAnimalID)
    BEGIN
        INSERT INTO AnimalChildren (ParentAnimalID, ChildAnimalID)
        VALUES (@p_ParentAnimalID, @p_ChildAnimalID);
    END
    ELSE
    BEGIN
        PRINT 'Parent animal does not exist. Insertion failed.';
    END
END;
Use farm1
EXEC InsertAnimalChildrens 1, 3; -- Example insertion of ParentAnimalID: 1 and ChildAnimalID: 2
EXEC InsertAnimalChildrens 1, 4; -- Example insertion of ParentAnimalID: 1 and ChildAnimalID: 2
EXEC InsertAnimalChildrens 1, 5; -- Example insertion of ParentAnimalID: 1 and ChildAnimalID: 2
EXEC InsertAnimalChildrens 1, 6; -- Example insertion of ParentAnimalID: 1 and ChildAnimalID: 2
EXEC InsertAnimalChildrens 2, 9; -- Example insertion of ParentAnimalID: 1 and ChildAnimalID: 2
EXEC InsertAnimalChildrens 2, 7; -- Example insertion of ParentAnimalID: 1 and ChildAnimalID: 2
EXEC InsertAnimalChildrens 2, 8; -- Example insertion of ParentAnimalID: 1 and ChildAnimalID: 2
EXEC InsertAnimalChildrens 10, 30; -- Example insertion of ParentAnimalID: 1 and ChildAnimalID: 2
EXEC InsertAnimalChildrens 14, 333; -- Example insertion of ParentAnimalID: 1 and ChildAnimalID: 2
SELECT * from AnimalChildren



