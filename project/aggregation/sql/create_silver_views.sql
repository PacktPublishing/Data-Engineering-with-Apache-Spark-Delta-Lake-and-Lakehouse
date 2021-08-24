USE gold;
GO
DROP PROCEDURE IF EXISTS create_silver_views;
GO
CREATE PROCEDURE create_silver_views  @silverns varchar(50), @location varchar(200) 
AS
BEGIN
    DECLARE @sqlcmd nvarchar(MAX)
    EXEC sp_executesql N'IF EXISTS ( SELECT * FROM sys.external_tables WHERE object_id = OBJECT_ID(''products'') )
                         DROP EXTERNAL TABLE products'
    SET @sqlcmd = N'CREATE EXTERNAL TABLE products  (product_id INTEGER, product_name VARCHAR(255), 
                                                     product_category VARCHAR(MAX), updated_at DATETIME) 
        WITH (LOCATION = ''' +  @silverns  + '/sales/products'',  data_source = trainingds, FILE_FORMAT = DeltaLakeFormat)';
	EXEC sp_executesql @sqlcmd

    EXEC sp_executesql N'IF EXISTS ( SELECT * FROM sys.external_tables WHERE object_id = OBJECT_ID(''store_customers'') )
                         DROP EXTERNAL TABLE store_customers'
    SET @sqlcmd = N'CREATE EXTERNAL TABLE store_customers  ([customer_id] INTEGER ,[customer_name] VARCHAR(255) ,[address] VARCHAR(255) ,
                                                            [city] VARCHAR(255) ,[postalcode] VARCHAR(10) ,[country] VARCHAR(100) ,
                                                            [phone] VARCHAR(100) ,[email] VARCHAR(255) ,[credit_card] VARCHAR(255) ,
	                                                        [updated_at] DATETIME) 
        WITH (LOCATION = ''' +  @silverns  + '/sales/store_customers'',  data_source = trainingds, FILE_FORMAT = DeltaLakeFormat)';
	EXEC sp_executesql @sqlcmd

    EXEC sp_executesql N'IF EXISTS ( SELECT * FROM sys.external_tables WHERE object_id = OBJECT_ID(''ecomm_customers'') )
                         DROP EXTERNAL TABLE ecomm_customers'
    SET @sqlcmd = N'CREATE EXTERNAL TABLE ecomm_customers  ([customer_id] INTEGER , [customer_name] VARCHAR(255) ,[address] VARCHAR(255) ,
										                    [city] VARCHAR(255) ,[postalcode] VARCHAR(10) ,[country] VARCHAR(100) ,
										                    [phone] VARCHAR(100) ,[email] VARCHAR(255),  [updated_at] DATETIME ) 
        WITH (LOCATION = ''' +  @silverns  + '/esalesns'',  data_source = trainingds, FILE_FORMAT = DeltaLakeFormat)';
	EXEC sp_executesql @sqlcmd

    EXEC sp_executesql N'DROP VIEW IF EXISTS customers'
	SET @sqlcmd = N' CREATE OR ALTER VIEW customers AS 
	                 SELECT  [customer_id],[customer_name]  ,[address],[city],[postalcode],
                             [country],[phone],[email], NULL as credit_card,[updated_at]
                     FROM [dbo].[ecomm_customers]
                     UNION
                     SELECT  [customer_id],[customer_name],[address],[city],[postalcode],
                             [country],[phone],[email],[credit_card],[updated_at]
                     FROM [dbo].[store_customers]'	
	EXEC sp_executesql @sqlcmd

    EXEC sp_executesql N'IF EXISTS ( SELECT * FROM sys.external_tables WHERE object_id = OBJECT_ID(''store_orders'') )
                         DROP EXTERNAL TABLE store_orders'
    SET @sqlcmd = N'CREATE EXTERNAL TABLE store_orders  ([order_number] INTEGER ,[customer_id] INTEGER ,[product_id] INTEGER ,
                                                         [order_date] VARCHAR(255),[units] INTEGER ,[sale_price] VARCHAR(100) ,
                                                         [sale_price_usd] VARCHAR(100) ,[currency] VARCHAR(255) ,[order_mode] VARCHAR(255) ,
	                                                     [updated_at] DATETIME ) 
        WITH (LOCATION = ''' +  @silverns  + '/sales/store_orders'',  data_source = trainingds, FILE_FORMAT = DeltaLakeFormat)';
	EXEC sp_executesql @sqlcmd

    EXEC sp_executesql N'IF EXISTS ( SELECT * FROM sys.external_tables WHERE object_id = OBJECT_ID(''ecomm_orders'') )
                         DROP EXTERNAL TABLE ecomm_orders'
    SET @sqlcmd = N'CREATE EXTERNAL TABLE ecomm_orders  ([order_number] INTEGER ,[email] VARCHAR(255) , [product_name] VARCHAR(255), 
                                                         [order_date] VARCHAR(255),[order_mode] VARCHAR(255) ,[sale_price] VARCHAR(100) ,
                                                         [sale_price_usd] VARCHAR(100) ,[updated_at] DATETIME ) 
        WITH (LOCATION = ''' +  @silverns  + '/esalesns'',  data_source = trainingds, FILE_FORMAT = DeltaLakeFormat)';
	EXEC sp_executesql @sqlcmd

     EXEC sp_executesql N'DROP VIEW IF EXISTS orders'
	 SET @sqlcmd =  N'CREATE OR ALTER VIEW orders AS 
                      SELECT order_number, email, product_name, order_date, units, sale_price,
					        order_mode, sale_price_usd, dbo.store_orders.updated_at
					 FROM dbo.store_orders 
					 JOIN dbo.customers ON dbo.customers.customer_id = dbo.store_orders.customer_id
					 JOIN dbo.products ON dbo.products.product_id = dbo.store_orders.product_id
					 UNION
					 SELECT order_number, email, product_name, order_date, 1 AS units, sale_price,
					        order_mode, sale_price_usd, updated_at
					 FROM dbo.ecomm_orders'	
	EXEC sp_executesql @sqlcmd

    EXEC sp_executesql N'IF EXISTS ( SELECT * FROM sys.external_tables WHERE object_id = OBJECT_ID(''geolocation'') )
                         DROP EXTERNAL TABLE geolocation'
    SET @sqlcmd = N'CREATE EXTERNAL TABLE geolocation  ([ip1] VARCHAR(255) , [ip2] VARCHAR(255) ,[country_code] VARCHAR(10) ,
										                [country_name] VARCHAR(255) , [updated_at] DATETIME ) 
        WITH (LOCATION = ''' +  @silverns  + '/geolocation'',  data_source = trainingds, FILE_FORMAT = DeltaLakeFormat)';
	EXEC sp_executesql @sqlcmd

    EXEC sp_executesql N'IF EXISTS ( SELECT * FROM sys.external_tables WHERE object_id = OBJECT_ID(''logs'') )
                         DROP EXTERNAL TABLE logs'
    SET @sqlcmd = N'CREATE EXTERNAL TABLE logs  ([time] VARCHAR(255) ,[remote_ip] VARCHAR(255) ,[country_name] VARCHAR(255) ,
                                                 [ip_number] INTEGER ,[request] VARCHAR(MAX) ,[response] VARCHAR(MAX) ,
                                            	 [agent] VARCHAR(MAX) , [updated_at] DATETIME ) 
        WITH (LOCATION = ''' +  @silverns  + '/logs'',  data_source = trainingds, FILE_FORMAT = DeltaLakeFormat)';
	EXEC sp_executesql @sqlcmd


END;
GO


