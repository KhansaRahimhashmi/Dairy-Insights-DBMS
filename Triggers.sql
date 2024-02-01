Use farm1
--TRIGGER 1:Before Insert Trigger: This trigger will prevent animals with a certain birth date from being inserted.
CREATE TRIGGER Prevent_Specific_Birthdate_Insert
ON Animals
INSTEAD OF INSERT
AS
BEGIN
    IF EXISTS (SELECT 1 FROM inserted WHERE BirthDate = '2023-01-01') -- Your specific birth date
    BEGIN
        RAISERROR ('Animals with this birth date cannot be inserted.', 16, 1);
    END;
    ELSE
    BEGIN
        INSERT INTO Animals (AnimalID, Name, BirthDate, Gravid, FoodGroupID, TagID, ItemID, ReportDate)
        SELECT AnimalID, Name, BirthDate, Gravid, FoodGroupID, TagID, ItemID, ReportDate
        FROM inserted;
    END;
END;
--check as ---------------------------------
-- Attempt to insert an animal with the specific birth date
INSERT INTO Animals (AnimalID, Name, BirthDate, Gravid, FoodGroupID, TagID, ItemID, ReportDate)
VALUES (1, 'Sample Animal', '2023-01-01', 0, 1, 1, 1, '2023-12-01'); -- Modify column values as needed
---------------------------------------------



------------------------------------------------------------------------------------
--TRIGGER 2 : After Update Trigger: This trigger will log updates in the Animals table to an audit table.
CREATE TRIGGER Log_Animal_UpdateS
ON Animals
AFTER UPDATE
AS
BEGIN
    INSERT INTO Animal_Audit (AnimalID, Action, Timestamp)
    SELECT AnimalID, 'Update', GETDATE() FROM inserted;
END;

---
--check as ---------------------------------
UPDATE Animals
SET Name = 'BUFFALO'
WHERE AnimalID = 1; -- Use a valid AnimalID that exists in your Animals table
SELECT * FROM  Animal_Audit;
---------------------------------------------
