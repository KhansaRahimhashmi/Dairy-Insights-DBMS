Use farm1
-- Create the denormalized table
CREATE TABLE DenormalizedAnimals (
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
);
-- Insert data into the denormalized table using INSERT INTO SELECT
INSERT INTO DenormalizedAnimals (AnimalID, AnimalName, BirthDate, Gravid, FoodGroupName, TagName, ItemName, ItemQuantity, PricePerUnit, TotalMilkSold, TotalEarning, TotalDailyExpense, Profit)
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
LEFT JOIN DailyReport DR ON A.ReportDate = DR.ReportDate;

Select * from DenormalizedAnimals


BULK INSERT DenormalizedAnimals
FROM 'D:\sql_project\DenormalizedAnimalsData.csv'
WITH (
    FIELDTERMINATOR = ',',
    ROWTERMINATOR = '\n',
    FIRSTROW = 2
);


