CREATE DATABASE farm1;
USE farm1;



-- Animals table
CREATE TABLE Animals (
    AnimalID INT PRIMARY KEY,
    Name VARCHAR(255),
    FoodGroupID INT,
    BirthDate DATE,
    Gravid BIT,
    TagID INT,
    ItemID INT,
    ReportDate DATE,
    CONSTRAINT fk_FoodGroup 
        FOREIGN KEY (FoodGroupID) 
        REFERENCES FoodGroups(FoodGroupID)
        ON DELETE CASCADE
        ON UPDATE CASCADE,
        
    CONSTRAINT fk_Tag 
        FOREIGN KEY (TagID) 
        REFERENCES Tags(TagID)
        ON DELETE CASCADE
        ON UPDATE CASCADE,

    CONSTRAINT fk_Item 
        FOREIGN KEY (ItemID) 
        REFERENCES Inventory(ItemID)
        ON DELETE CASCADE
        ON UPDATE CASCADE,

    CONSTRAINT fk_ReportDate 
        FOREIGN KEY (ReportDate) 
        REFERENCES DailyReport(ReportDate)
        ON DELETE CASCADE
        ON UPDATE CASCADE
);


-- FoodGroups table
CREATE TABLE FoodGroups (
    FoodGroupID INT PRIMARY KEY,
    Name VARCHAR(255)
);



-- FoodGroupIngredients table (junction table for many-to-many relationship)


-- Expenses table (for feeding and treatment records)
CREATE TABLE Expenses (
    ExpenseID INT PRIMARY KEY,
    AnimalID INT,
    ExpenseType VARCHAR(255), -- e.g., "Feeding", "Treatment"
    Cost DECIMAL(10, 2),
    DateRecorded DATETIME,
    CONSTRAINT fk_Animal FOREIGN KEY (AnimalID) REFERENCES Animals(AnimalID)
	ON DELETE CASCADE
        ON UPDATE CASCADE
);

-- Inventory table
CREATE TABLE Inventory (
    ItemID INT PRIMARY KEY,
    ItemType VARCHAR(255), -- e.g., "Forage", "Supplement", "Medicine"
    ItemName VARCHAR(255),
    Quantity INT,
    PricePerUnit DECIMAL(10, 2)
);

-- AnimalChildren table (for recording child animals)
CREATE TABLE AnimalChildren (
    ParentAnimalID INT,
    ChildAnimalID INT,
    PRIMARY KEY (ParentAnimalID, ChildAnimalID),
    CONSTRAINT fk_ParentAnimal FOREIGN KEY (ParentAnimalID) REFERENCES Animals(AnimalID),
    CONSTRAINT fk_ChildAnimal FOREIGN KEY (ChildAnimalID) REFERENCES Animals(AnimalID)
);

-- Sales table
CREATE TABLE Sales (
    SaleID INT PRIMARY KEY,
    AnimalID INT,
    MilkSoldInLiters DECIMAL(10, 2),
    Earning DECIMAL(10, 2),
    SaleDate DATE,
    CONSTRAINT fk_Animal_Sale FOREIGN KEY (AnimalID) REFERENCES Animals(AnimalID)

);

-- DailyReport table
CREATE TABLE DailyReport (
    ReportDate DATE PRIMARY KEY,
    TotalMilkSoldInLiters DECIMAL(10, 2),
    TotalEarning DECIMAL(10, 2),
    TotalDailyExpense DECIMAL(10, 2),
    Profit DECIMAL(10, 2)
);

-- Tags table
CREATE TABLE Tags (
    TagID INT PRIMARY KEY,
    TagName VARCHAR(255)
);
Select * from FoodGroups
Select * from Tags
Select * from Inventory 
Select * from DailyReport ;
Select * from Animals;
Select * from AnimalChildren
Select * from Expenses
- 