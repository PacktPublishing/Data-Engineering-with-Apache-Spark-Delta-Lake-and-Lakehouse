USE gold;
GO
DROP PROCEDURE IF EXISTS [create_gold_tables];
GO
CREATE PROCEDURE [create_gold_tables] @goldns varchar(50) , @format varchar(50), @extds varchar(50)
AS
BEGIN
    DECLARE @sqlcmd nvarchar(MAX)
    
	SET @sqlcmd = N'CREATE EXTERNAL TABLE ext_aggregated_sales 
					 WITH (
							LOCATION = ''' + @goldns + '/external/ext_aggregated_sales/'',  
							DATA_SOURCE = ' + @extds + ',  
							FILE_FORMAT = ' + @format + '
						) 
					 AS  SELECT YEAR(order_date) AS year, DATEPART(QUARTER, order_date) as quarter,
										round(sum(sale_price_usd),2) as aggregated_sales_price
										FROM orders 
										JOIN products  ON orders.product_id=products.product_id
										JOIN customers ON orders.customer_id=customers.customer_id
										GROUP BY YEAR(order_date), DATEPART(QUARTER, order_date) '	
	EXEC sp_executesql @sqlcmd

    SET @sqlcmd = N'CREATE EXTERNAL TABLE ext_total_website_hits 
					 WITH (
							LOCATION = ''' + @goldns + '/external/ext_total_website_hits/'',  
							DATA_SOURCE = ' + @extds + ',  
							FILE_FORMAT = ' + @format + '
						) 
					 AS     SELECT SUM(hits) AS total_hits FROM
                            (SELECT country_name, count(*) AS hits 
                            FROM logs 
                            GROUP BY country_name 
                            HAVING count(*) > 1000) as webhits '	
	EXEC sp_executesql @sqlcmd

    SET @sqlcmd = N'CREATE EXTERNAL TABLE ext_advertising_budgets 
					 WITH (
							LOCATION = ''' + @goldns + '/external/ext_advertising_budgets/'',  
							DATA_SOURCE = ' + @extds + ',  
							FILE_FORMAT = ' + @format + '
						) 
					 AS  SELECT country_name, hits, (hits*100/total_hits) AS advtg_budget
                    FROM
                    (SELECT country_name, count(*) as hits, (SELECT total_hits from ext_total_website_hits) AS total_hits 
                    FROM logs 
                    GROUP BY country_name 
                    HAVING count(*) > 1000) AS agg_hits '	
	EXEC sp_executesql @sqlcmd

     SET @sqlcmd = N'CREATE EXTERNAL TABLE ext_aggregated_products_by_quarter 
					 WITH (
							LOCATION = ''' + @goldns + '/external/ext_aggregated_products_by_quarter/'',  
							DATA_SOURCE = ' + @extds + ',  
							FILE_FORMAT = ' + @format + '
						) 
					 AS  SELECT product_category, product_name, YEAR(order_date) AS year, DATEPART(QUARTER, order_date) AS quarter, count(*) AS units_sold
                            FROM orders
                            JOIN products ON products.product_id=orders.product_id
                            GROUP BY product_category, product_name, YEAR(order_date), DATEPART(QUARTER, order_date) '	
	EXEC sp_executesql @sqlcmd

END;
GO