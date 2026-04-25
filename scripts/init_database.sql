/*
==========================================================================
create Database and schemas
=====================================================================
script purpose:
this script create a new datebase named 'datawarehouse' after checking if it already exists.
if the database exists, it is dropped and recreated. Additionally the script sets up three schemas
within the database:'bronze' 'sliver' 'gold'.

WARNING:
Running this script will drop the entire 'datawarehouse' database if it exists.
all data in the database will be parmantly deleted. proceed with caution and 
ensure you have proper backups before running this script.
*/




Use master;
GO
-- DROP AND RECREATE THE DATAWAREHOUSE DATABASE
IF EXISTS (SELECT 1 FROM sys.databases WHERE name = 'Datawarehouse')
BEGIN 
	ALTER DATABASE Datawarehouse SET SINGLE_USER WITH ROLLBACK IMMEDIATE;
	DROP DATABASE DataWarehouse;
	END;
	GO
	-- CREATE THE 'DATAWAREHOUSE' DATABASE
	CREATE  DATABASE Datawarehouse;
	GO

	USE DataWarehouse;
	GO

	--CREATE SCHEMAS

CREATE SCHEMA bronze;
GO

CREATE SCHEMA sliver;
GO

CREATE SCHEMA gold;
GO
