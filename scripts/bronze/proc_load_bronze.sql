/*
================================================================
store procedure : load bronze layer (source -> bronze)
================================================================
Script purpose:
this store procedure load data into the 'bronze' schema from external CSV files.
it performs the following action:
- truncate the bronze tables before loading data.
- uses the BULK INSERT command to load data from CSV files to bronze tables

parameters:
	None.
	this store procedure does not acept any parameters or return any values.

	Usage Example:
		EXEC bronze.load_bronze;
================================================================================
*/

--EXEC bronze.load_bronze

CREATE OR ALTER PROCEDURE bronze.load_bronze AS
BEGIN
	DECLARE @Start_time DATETIME , @end_time DATETIME;
	SET @Start_time = GETDATE();
	BEGIN TRY 
		PRINT '===============================================';
		PRINT 'Loading Bronze Layer';
		PRINT '===============================================';

		PRINT '-------------------------------------------------------';
		PRINT 'Loading CRM Tables';
		PRINT '-------------------------------------------------------';
		SET @Start_time = GETDATE();
		PRINT '>> Truncate Table:  bronze.crm_cust_info ';

			TRUNCATE TABLE bronze.crm_cust_info;

			PRINT '>> Inserting  Data into :  bronze.crm_cust_info ';
			BULK INSERT bronze.crm_cust_info
			FROM 'C:\Users\yakub\Desktop\NEW STUDY\sql-data-warehouse-project\datasets\source_crm\cust_info.csv'
			WITH(
				FIRSTROW = 2,
				FIELDTERMINATOR = ',',
				TABLOCK

			);
				SET @end_time = GETDATE();

				PRINT '>> Load Duration:'+ CAST(DATEDIFF(SECOND,@start_time,@end_time)AS NVARCHAR) + 'Seconds';
				PRINT '-------------------------------------------------------';

			-- SELECT * FROM bronze.crm_cust_info;
			SET @Start_time = GETDATE();
			PRINT '>> Truncate Table: bronze.crm_prd_info ';
			TRUNCATE TABLE bronze.crm_prd_info;

			PRINT '>> Inserting  Data into : bronze.crm_prd_info ';
			BULK INSERT bronze.crm_prd_info
			FROM 'C:\Users\yakub\Desktop\NEW STUDY\sql-data-warehouse-project\datasets\source_crm\prd_info.csv'
			WITH(
				FIRSTROW = 2,
				FIELDTERMINATOR = ',',
				TABLOCK

			);
			SET @end_time = GETDATE();

				PRINT '>> Load Duration:'+ CAST(DATEDIFF(SECOND,@start_time,@end_time)AS NVARCHAR) + 'Seconds';
				PRINT '-------------------------------------------------------';

			-- SELECT* FROM  bronze.crm_prd_info;
			SET @Start_time = GETDATE();
			PRINT '>> Truncate Table: bronze.crm_sales_details ';
			TRUNCATE TABLE bronze.crm_sales_details;

			PRINT '>> Inserting  Data into : bronze.crm_sales_details ';
			BULK INSERT bronze.crm_sales_details
			FROM 'C:\Users\yakub\Desktop\NEW STUDY\sql-data-warehouse-project\datasets\source_crm\sales_details.csv'
			WITH(
				FIRSTROW = 2,
				FIELDTERMINATOR = ',',
				TABLOCK

			);
			SET @end_time = GETDATE();

				PRINT '>> Load Duration:'+ CAST(DATEDIFF(SECOND,@start_time,@end_time)AS NVARCHAR) + 'Seconds';
				PRINT '-------------------------------------------------------';
			-- SELECT * FROM bronze.crm_cust_info;

			-- SELECT* FROM bronze.crm_sales_details;

			PRINT '-------------------------------------------------------';
			PRINT 'Loading erp Table ';
			PRINT '-------------------------------------------------------';
			SET @Start_time = GETDATE();
			PRINT '>> Truncate Table Into: bronze.erp_CUST_AZ12 ';
			TRUNCATE TABLE bronze.erp_CUST_AZ12;

			PRINT '>> Insert Data Into: bronze.erp_CUST_AZ12 ';
			BULK INSERT bronze.erp_CUST_AZ12
			FROM 'C:\Users\yakub\Desktop\NEW STUDY\sql-data-warehouse-project\datasets\source_erp\CUST_AZ12.csv'
			WITH(
			FIRSTROW = 2,
			FIELDTERMINATOR = ',',
			TABLOCK
			);
			SET @end_time = GETDATE();

				PRINT '>> Load Duration:'+ CAST(DATEDIFF(SECOND,@start_time,@end_time)AS NVARCHAR) + 'Seconds';
				PRINT '-------------------------------------------------------';
			-- SELECT * FROM bronze.crm_cust_info;

			--SELECT* FROM bronze.erp_CUST_AZ12
			SET @Start_time = GETDATE();
			PRINT '>> Truncate  Table into :  bronze.erp_LOC_A101';
			TRUNCATE TABLE bronze.erp_LOC_A101;

			PRINT '>> Inserting  Data into :  bronze.erp_LOC_A101 ';
			BULK INSERT bronze.erp_LOC_A101
			FROM 'C:\Users\yakub\Desktop\NEW STUDY\sql-data-warehouse-project\datasets\source_erp\LOC_A101.csv'
			WITH(
				FIRSTROW = 2,
				FIELDTERMINATOR = ',',
				TABLOCK
			);
			SET @end_time = GETDATE();

				PRINT '>> Load Duration:'+ CAST(DATEDIFF(SECOND,@start_time,@end_time)AS NVARCHAR) + 'Seconds';
				PRINT '-------------------------------------------------------';
			-- SELECT * FROM bronze.crm_cust_info;
			-- SELECT* FROM bronze.erp_LOC_A101 ;
			SET @Start_time = GETDATE();
			PRINT '>> Truncate  Table into :  bronze.erp_PX_CAT_G1V2';
			TRUNCATE TABLE bronze.erp_PX_CAT_G1V2;

			PRINT '>> Truncate  Table into :  bronze.erp_PX_CAT_G1V2';
			BULK INSERT bronze.erp_PX_CAT_G1V2
			FROM 'C:\Users\yakub\Desktop\NEW STUDY\sql-data-warehouse-project\datasets\source_erp\PX_CAT_G1V2.csv'
			WITH(
				FIRSTROW = 2,
				FIELDTERMINATOR = ',',
				TABLOCK
	);
				SET @end_time = GETDATE();

				PRINT '>> Load Duration:'+ CAST(DATEDIFF(SECOND,@start_time,@end_time)AS NVARCHAR) + 'Seconds';
				PRINT '-------------------------------------------------------';
			-- SELECT * FROM bronze.crm_cust_info;
	END TRY
	BEGIN CATCH 
		 PRINT '====================================================='
		 PRINT 'ERROR OCCURED DURING LOADING BRONZE LAYER'
		 PRINT 'Error Message' + ERROR_MESSAGE() ;
		 PRINT 'Error Message' +CAST( ERROR_NUMBER() AS NVARCHAR) ;
	END CATCH 
	SET @end_time = GETDATE();

				PRINT '>>  Load Total Duration:'+ CAST(DATEDIFF(SECOND,@start_time,@end_time)AS NVARCHAR) + 'Seconds';
				PRINT '-------------------------------------------------------';
END
