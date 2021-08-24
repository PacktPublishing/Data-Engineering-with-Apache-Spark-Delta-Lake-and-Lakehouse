USE gold;
GO
DROP PROCEDURE IF EXISTS [create_synapse_creds];
GO
CREATE PROCEDURE [create_synapse_creds]  @format varchar(50), @extds varchar(50), @creds varchar(50),  @secret varchar(500), @location varchar(200)
AS
BEGIN
    DECLARE @sqlcmd nvarchar(500)
    IF EXISTS (SELECT * FROM sys.external_file_formats WHERE name = @format)
        SET @sqlcmd = N'DROP EXTERNAL FILE FORMAT ' + @format;
        EXEC sp_executesql @sqlcmd
        SET @sqlcmd=''
		
	IF EXISTS (SELECT * FROM sys.external_file_formats WHERE name = 'DeltaLakeFormat')
        SET @sqlcmd = N'DROP EXTERNAL FILE FORMAT DeltaLakeFormat';
        EXEC sp_executesql @sqlcmd
        SET @sqlcmd=''

    IF EXISTS (SELECT * FROM sys.external_data_sources WHERE name = @extds) 
        SET @sqlcmd = N'DROP EXTERNAL DATA SOURCE ' + @extds;
        EXEC sp_executesql @sqlcmd
        SET @sqlcmd=''

    IF EXISTS (SELECT * FROM sys.database_scoped_credentials WHERE name = @creds)
        SET @sqlcmd = N'DROP DATABASE SCOPED CREDENTIAL ' + @creds;
        EXEC sp_executesql @sqlcmd
        SET @sqlcmd=''

    IF  EXISTS (SELECT * FROM sys.symmetric_keys) 
        DROP MASTER KEY;
    
    IF NOT EXISTS (SELECT * FROM sys.symmetric_keys)
        CREATE MASTER KEY;

    IF NOT EXISTS (SELECT * FROM sys.database_scoped_credentials WHERE name = @creds)
        SET @sqlcmd = N'CREATE DATABASE SCOPED CREDENTIAL ' + @creds + ' WITH IDENTITY = ''SHARED ACCESS SIGNATURE'',
        SECRET = ''' + @secret + ''''
        EXEC sp_executesql @sqlcmd
        SET @sqlcmd=''

    IF NOT EXISTS (SELECT * FROM sys.external_data_sources WHERE name =  @extds) 
        SET @sqlcmd = N'CREATE EXTERNAL DATA SOURCE ' + @extds + ' WITH (LOCATION = ''' + @location +
                       ''', CREDENTIAL = ' + @creds + ')';
        EXEC sp_executesql @sqlcmd
        SET @sqlcmd=''

    IF  NOT EXISTS (SELECT * FROM sys.external_file_formats WHERE name =  @format)
        SET @sqlcmd = N'CREATE EXTERNAL FILE FORMAT ' +  @format + ' WITH (
        FORMAT_TYPE = PARQUET, DATA_COMPRESSION = ''org.apache.hadoop.io.compress.SnappyCodec'')';
        EXEC sp_executesql @sqlcmd
        SET @sqlcmd=''
	
	IF  NOT EXISTS (SELECT * FROM sys.external_file_formats WHERE name =  'DeltaLakeFormat')
        SET @sqlcmd = N'CREATE EXTERNAL FILE FORMAT DeltaLakeFormat WITH (  FORMAT_TYPE = DELTA )';
        EXEC sp_executesql @sqlcmd
        SET @sqlcmd=''
END;
GO