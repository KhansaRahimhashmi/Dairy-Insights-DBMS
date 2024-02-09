Use farm1

CREATE NONCLUSTERED INDEX IX_Name ON Animals(Name);
-- Drop existing clustered index
DROP INDEX PK_Animals ON Animals;

-- Create a new clustered index on another column, for instance, BirthDate
CREATE CLUSTERED INDEX IX_BirthDate ON Animals(BirthDate);

----------RUNNING QUERY ---------------------
SELECT 
    OBJECT_NAME(object_id) AS TableName,
    name AS IndexName,
    type_desc AS IndexType
FROM sys.indexes 
WHERE OBJECT_NAME(object_id) = 'Animals';

------EXECUTION ------------------------
EXEC sp_helpindex 'Animals';

------OUTPUT SHOWING-------------------
SELECT 
    i.name AS IndexName,
    c.name AS ColumnName
FROM sys.indexes i
INNER JOIN sys.index_columns ic ON i.object_id = ic.object_id AND i.index_id = ic.index_id
INNER JOIN sys.columns c ON ic.object_id = c.object_id AND ic.column_id = c.column_id
WHERE OBJECT_NAME(i.object_id) = 'Animals';

-------------------------------------