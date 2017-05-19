USE Lab_2_Variant_8_Students_Maxym_Karpinsky;
GO

SELECT DATEPART(year, [Students].admission_date) - DATEPART(year, [Students].birth_date)
FROM [Students];

SELECT CONCAT('Директор', ' ', [sc].[name], ' ', CONCAT([scd].fist_name, ' ', [scd].middle_name, ' ', [scd].last_name)) 
FROM [School] AS sc
JOIN [School_Directors] AS scd
ON sc.director_id = scd.id;