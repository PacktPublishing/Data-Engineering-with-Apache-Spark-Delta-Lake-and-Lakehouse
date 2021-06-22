USE gold;
GO
CREATE PROCEDURE [create_gold_views] 
AS
BEGIN
    DECLARE @sqlcmd nvarchar(MAX)
    EXEC sp_executesql N'DROP VIEW IF EXISTS aggregated_sales'
	SET @sqlcmd = N'CREATE VIEW aggregated_sales AS 
	                SELECT YEAR(order_date) AS year, DATEPART(QUARTER, order_date) as quarter,
					round(sum(sale_price_usd),2) as aggregated_sales_price
					FROM orders 
					JOIN products  ON orders.product_id=products.product_id
					JOIN customers ON orders.customer_id=customers.customer_id
					GROUP BY YEAR(order_date), DATEPART(QUARTER, order_date) '	
	EXEC sp_executesql @sqlcmd

    EXEC sp_executesql N'DROP VIEW IF EXISTS total_website_hits'
	SET @sqlcmd = N'CREATE VIEW total_website_hits AS 
	                SELECT SUM(hits) AS total_hits FROM
                    (SELECT country_name, count(*) AS hits 
                    FROM logs 
                    GROUP BY country_name 
                    HAVING count(*) > 1000) as webhits '	
	EXEC sp_executesql @sqlcmd

    EXEC sp_executesql N'DROP VIEW IF EXISTS advertising_budgets'
	SET @sqlcmd = N'CREATE VIEW advertising_budgets AS 
	                SELECT country_name, hits, (hits*100/total_hits) AS advtg_budget
                    FROM
                    (SELECT country_name, count(*) as hits, (SELECT total_hits from total_website_hits) AS total_hits 
                    FROM logs 
                    GROUP BY country_name 
                    HAVING count(*) > 1000) AS agg_hits '	
	EXEC sp_executesql @sqlcmd

    EXEC sp_executesql N'DROP VIEW IF EXISTS aggregated_products_by_quarter'
	SET @sqlcmd = N'CREATE VIEW aggregated_products_by_quarter AS 
	                SELECT product_category, product_name, YEAR(order_date) AS year, DATEPART(QUARTER, order_date) AS quarter, count(*) AS units_sold
                    FROM orders
                    JOIN products ON products.product_id=orders.product_id
                    GROUP BY product_category, product_name, YEAR(order_date), DATEPART(QUARTER, order_date) '	
	EXEC sp_executesql @sqlcmd
END;
GO
