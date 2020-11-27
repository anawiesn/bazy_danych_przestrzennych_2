/****** podpunkt a ******/
SELECT [OrderDate]
	,COUNT( OrderDate ) AS OrderDate_cnt
FROM [AdventureWorksDW2019].[dbo].[FactInternetSales]
GROUP BY OrderDate
HAVING COUNT( OrderDate ) < 100
ORDER BY OrderDate_cnt DESC;

/****** podpunkt b ******/
SELECT [OrderDate]
		,COUNT(OrderDate) OVER( PARTITION BY OrderDate ) AS OrderDate_cnt
		,[ProductKey]
		,[UnitPrice]
		,ROW_NUMBER() OVER( PARTITION BY OrderDate ORDER BY UnitPrice DESC ) AS row_count
INTO #temporary1
FROM [AdventureWorksDW2019].[dbo].[FactInternetSales]

SELECT [OrderDate]
	   ,dp.[EnglishProductName]
	   ,[UnitPrice]
FROM #temporary1
INNER JOIN [AdventureWorksDW2019].[dbo].[DimProduct] dp
ON #temporary1.ProductKey = dp.ProductKey
WHERE row_count < 4
ORDER BY OrderDate_cnt DESC