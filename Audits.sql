USE farm1
----------AUDITS TABLES ------------------------
CREATE TABLE Animal_Audit (
    AnimalID INT,
    Action VARCHAR(50),
    Timestamp DATETIME
);

CREATE TABLE AnimalAudit (
    AuditID INT IDENTITY(1,1) PRIMARY KEY,
    AnimalID INT,
    AuditDate DATETIME,
    AuditAction VARCHAR(50),
    NewValue VARCHAR(255),
    ChangedBy VARCHAR(100)
);
-------------------DROP THE TABLE IS WANTED FROM IT ---------------------
Drop Table AnimalAudit




-----------------ANIMAL INSERT AUDIT -------------TRIGGER=------------------
CREATE TRIGGER Animal_Insert_Audit
ON DenormalizedAnimals
AFTER INSERT
AS
BEGIN
    INSERT INTO AnimalAudit (AnimalID, AuditDate, AuditAction, NewValue, ChangedBy)
    SELECT
        AnimalID,
        GETDATE(),
        'INSERT',
        'New Animal Added',
        SYSTEM_USER -- Change this to reflect your user identification method
    FROM 
        inserted; -- Reference the 'inserted' table directly within the trigger
END;

------------------THIS REQUIRED TO RUN ABOVE TRIGGER-----------------------
ALTER TABLE AnimalAudit
ALTER COLUMN AuditID INT NULL;

------------------CHECKING THE ABOVE TRIGGER----------------------------------
INSERT INTO DenormalizedAnimals (AnimalID, AnimalName, BirthDate, Gravid, FoodGroupName, TagName, ItemName, ItemQuantity, PricePerUnit, TotalMilkSold, TotalEarning, TotalDailyExpense, Profit)
VALUES (1, 'Sample Animal', '2023-01-01', 0, 'Sample Food Group', 'Sample Tag', 'Sample Item', 10, 5.00, 100, 50, 30, 20);

-----------------CHECKING AUDIT TABLE INSERTION USING TRIGGEER-----------------
SELECT * FROM AnimalAudit;



--------------------------------------------------------------------------
CREATE TRIGGER Animal_Insert_Audits
ON DenormalizedAnimals
AFTER INSERT, UPDATE, DELETE
AS
BEGIN
    DECLARE @Action NVARCHAR(10);

    IF EXISTS(SELECT * FROM inserted) AND EXISTS(SELECT * FROM deleted)
        BEGIN
            SET @Action = 'UPDATE';

            INSERT INTO AnimalAudit (AnimalID, AuditDate, AuditAction, NewValue, ChangedBy)
            SELECT 
                ISNULL(d.AnimalID, i.AnimalID),
                GETDATE(),
                @Action,
                'Old Animal: ' + ISNULL(CONVERT(VARCHAR(1000), d.AnimalID), '') + ', ' +
                'New Animal: ' + ISNULL(CONVERT(VARCHAR(1000), i.AnimalID), ''),
                SYSTEM_USER
            FROM inserted i
            FULL OUTER JOIN deleted d ON i.AnimalID = d.AnimalID;
        END;
    ELSE IF EXISTS(SELECT * FROM inserted)
        BEGIN
            SET @Action = 'INSERT';

            INSERT INTO AnimalAudit (AnimalID, AuditDate, AuditAction, NewValue, ChangedBy)
            SELECT 
                i.AnimalID,
                GETDATE(),
                @Action,
                'New Animal: ' + ISNULL(CONVERT(VARCHAR(1000), i.AnimalID), ''),
                SYSTEM_USER
            FROM inserted i;
        END;
    ELSE IF EXISTS(SELECT * FROM deleted)
        BEGIN
            SET @Action = 'DELETE';

            INSERT INTO AnimalAudit (AnimalID, AuditDate, AuditAction, NewValue, ChangedBy)
            SELECT 
                d.AnimalID,
                GETDATE(),
                @Action,
                'Old Animal: ' + ISNULL(CONVERT(VARCHAR(1000), d.AnimalID), ''),
                SYSTEM_USER
            FROM deleted d;
        END;
END;


-- Insert a new record into the DenormalizedAnimals table
INSERT INTO DenormalizedAnimals (AnimalID, AnimalName, BirthDate, Gravid, FoodGroupName, TagName, ItemName, ItemQuantity, PricePerUnit, TotalMilkSold, TotalEarning, TotalDailyExpense, Profit)
VALUES (1, 'Lion', '2022-01-01', 1, 'Carnivore', 'Wild', 'Meat', 10, 5.99, 50.00, 100.00, 25.00, 75.00);


-- Update an existing record in the DenormalizedAnimals table
UPDATE DenormalizedAnimals
SET TotalEarning = 120.00
WHERE AnimalID = 1;


-- Delete a record from the DenormalizedAnimals table
DELETE FROM DenormalizedAnimals
WHERE AnimalID = 1;


SELECT * FROM AnimalAudit;
