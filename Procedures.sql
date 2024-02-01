Use farm1

--------total: 8_---------------------
CREATE PROCEDURE GenerateAnimalDetailReport
AS
BEGIN
    -- Temporary table to store animal details
    CREATE TABLE #AnimalDetailReport (
        AnimalID INT,
        AnimalName VARCHAR(255),
        BirthDate DATE,
        TotalExpenses DECIMAL(10, 2),
        TotalSales DECIMAL(10, 2),
        TotalProfit DECIMAL(10, 2),
        TotalMilkSold DECIMAL(10, 2)
    );

    -- Insert animal details into the temporary table
    INSERT INTO #AnimalDetailReport (AnimalID, AnimalName, BirthDate)
    SELECT AnimalID, Name AS AnimalName, BirthDate
    FROM Animals;

    -- Calculate total expenses for each animal
    UPDATE #AnimalDetailReport
    SET TotalExpenses = ISNULL((
        SELECT SUM(ISNULL(Cost, 0))
        FROM Expenses
        WHERE Expenses.AnimalID = #AnimalDetailReport.AnimalID
    ), 0);

    -- Calculate total sales for each animal
    UPDATE #AnimalDetailReport
    SET TotalSales = ISNULL((
        SELECT SUM(ISNULL(Earning, 0))
        FROM Sales
        WHERE Sales.AnimalID = #AnimalDetailReport.AnimalID
    ), 0);

    -- Calculate total profit for each animal
    UPDATE #AnimalDetailReport
    SET TotalProfit = ISNULL(TotalSales, 0) - ISNULL(TotalExpenses, 0);

    -- Calculate total milk sold for each animal
    UPDATE #AnimalDetailReport
    SET TotalMilkSold = ISNULL((
        SELECT SUM(ISNULL(MilkSoldInLiters, 0))
        FROM Sales
        WHERE Sales.AnimalID = #AnimalDetailReport.AnimalID
    ), 0);

    -- Display the detailed report for each animal
    SELECT *
    FROM #AnimalDetailReport;

    -- Drop the temporary table
    DROP TABLE #AnimalDetailReport;
END;

-------------------------------------
exec GenerateAnimalDetailReport
-------------------------------------


DROP PROCEDURE GenerateAnimalDetailReport








CREATE PROCEDURE GenerateAnalyticalReport
AS
BEGIN
    -- Analytical Report Based on Statistics
    SELECT
        A.AnimalID,
        A.Name AS AnimalName,
        F.Name AS FoodGroupName,
        COUNT(S.SaleID) AS TotalSales,
        SUM(S.MilkSoldInLiters) AS TotalMilkSold,
        SUM(S.Earning) AS TotalEarning
    FROM
        Animals A
    LEFT JOIN
        Sales S ON A.AnimalID = S.AnimalID
    LEFT JOIN
        FoodGroups F ON A.FoodGroupID = F.FoodGroupID
    GROUP BY
        A.AnimalID, A.Name, F.Name
    ORDER BY
        TotalEarning DESC; -- Ordering by TotalEarning in descending order
END;
EXEC GenerateAnalyticalReport;

----------------------------------------------------------------------
CREATE PROCEDURE GetDataForDateRange
    @StartDate DATE,
    @EndDate DATE
AS
BEGIN
    SELECT *
    FROM DailyReport
    WHERE ReportDate BETWEEN @StartDate AND @EndDate;
END;

EXEC GetDataForDateRange '2023-10-01', '2023-12-31'; -- Execute procedure for a date range


-----------------------------------------------------
CREATE PROCEDURE GetDataForSpecificDay
    @TargetDate DATE
AS
BEGIN
    SELECT *
    FROM DailyReport
    WHERE ReportDate = @TargetDate;
END;

EXEC GetDataForSpecificDay '2023-12-13'; -- Execute procedure for a specific day
-----------------------------------------------------
CREATE PROCEDURE GetAnimalDetails
    @AnimalID INT
AS
BEGIN
    SELECT 
        A.AnimalID,
        A.Name AS AnimalName,
        A.BirthDate,
        A.Gravid,
        F.Name AS FoodGroupName,
        T.TagName,
        I.ItemName,
        I.Quantity AS ItemQuantity,
        I.PricePerUnit,
        DR.TotalMilkSoldInLiters,
        DR.TotalEarning,
        DR.TotalDailyExpense,
        DR.Profit
    FROM Animals A
    LEFT JOIN FoodGroups F ON A.FoodGroupID = F.FoodGroupID
    LEFT JOIN Tags T ON A.TagID = T.TagID
    LEFT JOIN Inventory I ON A.ItemID = I.ItemID
    LEFT JOIN DailyReport DR ON A.ReportDate = DR.ReportDate
    WHERE A.AnimalID = @AnimalID;
END;
EXEC GetAnimalDetails @AnimalID = 1; -- Replace 1 with the actual AnimalID
-------------------------------------------------------
CREATE PROCEDURE GetAllAnimalDetails
AS
BEGIN
    DECLARE @AnimalDetails TABLE (
        AnimalID INT,
        AnimalName VARCHAR(255),
        BirthDate DATE,
        Gravid BIT,
        FoodGroupName VARCHAR(255),
        TagName VARCHAR(255),
        ItemName VARCHAR(255),
        ItemQuantity INT,
        PricePerUnit DECIMAL(10, 2),
        TotalMilkSold DECIMAL(10, 2),
        TotalEarning DECIMAL(10, 2),
        TotalDailyExpense DECIMAL(10, 2),
        Profit DECIMAL(10, 2)
    )

    INSERT INTO @AnimalDetails (AnimalID, AnimalName, BirthDate, Gravid, FoodGroupName, TagName, ItemName, ItemQuantity, PricePerUnit, TotalMilkSold, TotalEarning, TotalDailyExpense, Profit)
    SELECT 
        A.AnimalID,
        A.Name AS AnimalName,
        A.BirthDate,
        A.Gravid,
        F.Name AS FoodGroupName,
        T.TagName,
        I.ItemName,
        I.Quantity AS ItemQuantity,
        I.PricePerUnit,
        DR.TotalMilkSoldInLiters AS TotalMilkSold,
        DR.TotalEarning,
        DR.TotalDailyExpense,
        DR.Profit
    FROM Animals A
    LEFT JOIN FoodGroups F ON A.FoodGroupID = F.FoodGroupID
    LEFT JOIN Tags T ON A.TagID = T.TagID
    LEFT JOIN Inventory I ON A.ItemID = I.ItemID
    LEFT JOIN DailyReport DR ON A.ReportDate = DR.ReportDate

    SELECT * FROM @AnimalDetails
END;

EXEC GetAllAnimalDetails;
----------------------------------------------------end--------------------------------

CREATE PROCEDURE GenerateExpenseDetails
AS
BEGIN
    INSERT INTO Expenses (AnimalID, ExpenseType, Cost, DateRecorded)
    SELECT AnimalID, 'Auto-Generated Expense', ABS(CHECKSUM(NEWID()) % 100) + 1, GETDATE() -- Example expense generation logic
    FROM Animals;
END;
-------------------------------------
EXEC GenerateExpenseDetails
-------------------------------------
