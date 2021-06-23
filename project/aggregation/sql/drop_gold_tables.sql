USE gold;
GO
DROP PROCEDURE IF EXISTS [drop_gold_tables];
GO
CREATE PROCEDURE [drop_gold_tables] @goldns varchar(50)
AS
BEGIN
    DECLARE @sqlcmd nvarchar(MAX)
	SET @sqlcmd = N'IF OBJECT_ID(N'''+ @goldns +'..ext_aggregated_sales'') IS NOT NULL
					BEGIN
					 DROP EXTERNAL TABLE ext_aggregated_sales; 
					END'	
	EXEC sp_executesql @sqlcmd

    SET @sqlcmd = N'IF OBJECT_ID(N'''+ @goldns +'..ext_total_website_hits'') IS NOT NULL
					BEGIN
					 DROP EXTERNAL TABLE ext_total_website_hits; 
					END'	
	EXEC sp_executesql @sqlcmd

	SET @sqlcmd = N'IF OBJECT_ID(N'''+ @goldns +'..ext_advertising_budgets'') IS NOT NULL
					BEGIN
					 DROP EXTERNAL TABLE ext_advertising_budgets; 
					END'	
	EXEC sp_executesql @sqlcmd
	
	SET @sqlcmd = N'IF OBJECT_ID(N'''+ @goldns +'..ext_aggregated_products_by_quarter'') IS NOT NULL
					BEGIN
					 DROP EXTERNAL TABLE ext_aggregated_products_by_quarter; 
					END'	
	EXEC sp_executesql @sqlcmd
END;
GO
