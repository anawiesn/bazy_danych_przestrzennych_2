SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Agnieszka Nawiesniak>
-- =============================================
CREATE PROCEDURE BDP2_select_data_YearsAgo 
	@YearsAgo INT
AS
BEGIN

SELECT
		fcr.[CurrencyKey]
      ,fcr.[DateKey]
      ,fcr.[AverageRate]
      ,fcr.[EndOfDayRate]
      ,fcr.[Date]
	  ,dc.[CurrencyAlternateKey]
      ,dc.[CurrencyName] FROM [AdventureWorksDW2019].[dbo].[DimCurrency] dc 
INNER JOIN [AdventureWorksDW2019].[dbo].[FactCurrencyRate] fcr
		ON fcr.CurrencyKey = dc.CurrencyKey 
WHERE	dc.CurrencyAlternateKey LIKE 'GBP' 
	AND	fcr.DateKey = DATEPART("yyyy", DATEADD("yyyy", -@YearsAgo, GETDATE()))*10000 
			+ DATEPART("month", GETDATE())*100  
			+ DATEPART("day",GETDATE()) OR dc.CurrencyAlternateKey LIKE 'EUR'
	AND	fcr.DateKey = DATEPART("yyyy", DATEADD("yyyy", -@YearsAgo, GETDATE()))*10000 
			+ DATEPART("month", GETDATE())*100  
			+ DATEPART("day",GETDATE())
END

EXEC BDP2_select_data_YearsAgo 8
