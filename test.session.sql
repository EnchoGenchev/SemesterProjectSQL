-- Display full schema: all user tables, columns, data types, nullability, and length

SELECT 
    t.name AS Table_Name,
    c.name AS Column_Name,
    ty.name AS Data_Type,
    c.max_length AS Max_Length,
    c.is_nullable AS Is_Nullable,
    c.is_identity AS Is_Identity
FROM sys.columns c
JOIN sys.tables t       ON c.object_id = t.object_id
JOIN sys.types ty       ON c.user_type_id = ty.user_type_id
ORDER BY t.name, c.column_id;
