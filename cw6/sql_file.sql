DROP TABLE IF EXISTS [AdventureWorksDW2019].[dbo].[stg_dimemp]
SELECT [EmployeeKey]
      ,[FirstName]
      ,[LastName]
      ,[Title]
INTO [AdventureWorksDW2019].[dbo].[stg_dimemp]
FROM [AdventureWorksDW2019].[dbo].[DimEmployee]		
WHERE EmployeeKey BETWEEN 270 AND 275

DROP TABLE IF EXISTS [AdventureWorksDW2019].[dbo].[scd_dimemp]
CREATE TABLE dbo.scd_dimemp 
			(EmployeeKey INT 
			,FirstName NVARCHAR(50) 
			,LastName NVARCHAR(50) 
			,Title NVARCHAR(50)
			,StartDate DATETIME
			,EndDate DATETIME);

UPDATE [AdventureWorksDW2019].[dbo].[stg_dimemp]	
	SET	LastName ='Nowak'
	WHERE EmployeeKey = 270
	
UPDATE [AdventureWorksDW2019].[dbo].[stg_dimemp]	
	SET Title ='Senior Design Engineer'
	WHERE EmployeeKey = 274

UPDATE [AdventureWorksDW2019].[dbo].[stg_dimemp]
	SET FirstName ='Ryszard' 
	WHERE EmployeeKey = 275

SELECT * FROM [AdventureWorksDW2019].[dbo].[stg_dimemp]	

SELECT * FROM [AdventureWorksDW2019].[dbo].[scd_dimemp]	