USE gold;
GO
DROP PROCEDURE IF EXISTS [create_silver_views];
GO
CREATE PROCEDURE [create_silver_views]  @silverns varchar(50), @location varchar(200) 
AS
BEGIN
    DECLARE @sqlcmd nvarchar(MAX)
    EXEC sp_executesql N'DROP VIEW  IF EXISTS products'
    SET @sqlcmd = N'CREATE OR ALTER VIEW products AS SELECT * FROM openrowset(
	                BULK '''  + '/' + @silverns +'/sales/products/'',  data_source = ''trainingds'',
                    FORMAT = ''delta'') AS rows';
	EXEC sp_executesql @sqlcmd
	
	EXEC sp_executesql N'DROP VIEW IF EXISTS customers'
	SET @sqlcmd = N'CREATE OR ALTER VIEW customers AS
	                SELECT customer_id, customer_name, address, city, postalcode, country, phone, email,credit_card, updated_at FROM openrowset(
					BULK '''  + '/' + @silverns +'/sales/store_customers/'', data_source = ''trainingds'',FORMAT = ''delta'') AS rows
	                UNION
	                SELECT NULL AS customer_id, rows.customer_name, rows.address, rows.city, rows.postalcode, 
		                   rows.country, rows.phone, rows.email, NULL AS credit_card, rows.updated_at FROM openrowset(
				    BULK ''' +  '/' + @silverns +'/esalesns/'', data_source = ''trainingds'', FORMAT = ''delta'') AS rows'
	EXEC sp_executesql @sqlcmd
    
    EXEC sp_executesql N'DROP VIEW IF EXISTS orders'
	SET @sqlcmd = N'CREATE OR ALTER VIEW orders AS
                    SELECT * FROM openrowset(
                    BULK ''' +  '/' + @silverns +'/sales/store_orders/'', data_source = ''trainingds'', FORMAT = ''delta'')   
                    AS rows'	
	EXEC sp_executesql @sqlcmd

    EXEC sp_executesql N'DROP VIEW IF EXISTS geolocation'
	SET @sqlcmd = N'CREATE OR ALTER VIEW geolocation AS
                    SELECT * FROM openrowset(
                    BULK ''' +  '/' + @silverns +'/geolocation/'', data_source = ''trainingds'', FORMAT = ''delta'')   
                    AS rows'	
	EXEC sp_executesql @sqlcmd

    EXEC sp_executesql N'DROP VIEW IF EXISTS logs'
	SET @sqlcmd = N'CREATE OR ALTER VIEW logs AS
                    SELECT * FROM openrowset(
                    BULK ''' +  '/' + @silverns +'/logs/'', data_source = ''trainingds'', FORMAT = ''delta'')   
                    AS rows'	
	EXEC sp_executesql @sqlcmd
END;
GO

