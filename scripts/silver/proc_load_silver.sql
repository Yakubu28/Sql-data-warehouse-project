
/*
===========================================================
store procedure: load silver layer ( Bronze -> Silver)
==========================================================
script purpose:
	this stored procedure performs the ETL (extract, transform, load) process to 
	populate the 'silver' schema table from the 'bronze' schema.
	Action performed:
	_ Truncates silver tables.
	-inserts transformed and cleansed data from bronze into silver tabel
	Parameters:
	None.
	This store procedure does not accept any parameters or return any values.

	usage Example:

	EXEC silver.load_silver;
	====================================================================

*/




CREATE OR ALTER  PROCEDURE silver.load_silver AS
BEGIN
	DECLARE @start_time DATETIME, @end_time DATETIME, @batch_start_time DATETIME, @batch_end_time DATETIME;
	BEGIN TRY
	SET @batch_start_time = GETDATE();
	PRINT '===================================================';
	PRINT 'Loading Silver Layer';
	PRINT '===================================================';

	PRINT '===================================================';
	PRINT 'Loading CRM Tables';
	PRINT '===================================================';

	-- Loading silver.crm_cust_info
	SET @start_time = GETDATE();
	PRINT '>> Truncate table: Silver.crm_cust_info';
	TRUNCATE TABLE Silver.crm_cust_info;
	PRINT '>> Inserting Data Into: Silver.crm_cust_info';
	-- DATA TRANSFORMATION AND DATA CLEANSING 
	INSERT INTO silver.crm_cust_info (
		cst_id,
		cst_key,
		cst_firstname,
		cst_lastname,
		cst_material_status,
		cst_gndr,
		cst_create_date)

	SELECT
	cst_id,
	cst_key,
	TRIM(cst_firstname) AS cst_firstname,
	TRIM(cst_lastname)AS cst_lastname,
	--DATA CLEANSING REMOVING UNWANTED SPACES  FROM THE NAME 
	--=========================================================
	CASE WHEN UPPER (TRIM(cst_material_status)) = 'S' THEN 'Single'
			WHEN UPPER (TRIM(cst_material_status)) = 'M' THEN 'Married'
		ELSE 'n/a'
		----DATA NORMALIZATION AND STANDARDIZATION handling missing values 
	END cst_material_status,
		CASE WHEN UPPER (TRIM(cst_gndr)) = 'F' THEN 'Female'
			WHEN UPPER (TRIM(cst_gndr)) = 'M' THEN 'Male'
		ELSE 'n/a'
	END cst_gndr,
	cst_create_date
	FROM (
	SELECT
	*,
	ROW_NUMBER() OVER (PARTITION BY cst_id ORDER BY cst_create_date DESC) as flag_last
	FROM bronze.crm_cust_info
	WHERE cst_id IS NOT NULL  
	)t 
	WHERE flag_last <= 1  ;-- SELECT THE MOST RECENT RECORD PER CUSTOMER
	SET @end_time = GETDATE();
	PRINT '>> load Duration: '+ CAST(DATEDIFF(SECOND, @start_time, @end_time) AS NVARCHAR) + 'seconds';
	PRINT '>> ------------------';
	-- REMOVING OF DUPLICATE in primary key
	--=================================================================

	-- Loading silver.crm_prd_info
	SET @start_time = GETDATE();
	PRINT '>> Truncate table: silver.crm_prd_info';
	TRUNCATE TABLE silver.crm_prd_info;
	PRINT '>> Inserting Data Into: silver.crm_prd_info';

	INSERT INTO silver.crm_prd_info (
	prd_id,
	cat_id,
	prd_key,
	prd_nm,
	prd_cost,
	prd_line,
	prd_start_dt,
	prd_end_dt
	)

	SELECT 
	prd_id,
	REPLACE(SUBSTRING(prd_key, 1, 5), '-', '_') AS cat_id, -- we derived a new column based on calculation 
	SUBSTRING(prd_key, 7, LEN(prd_key)) AS prd_key,  -- on existing ones caalled transformation
	prd_nm,
	ISNULL (prd_cost, 0) AS prd_cost, -- we handle missing information istead of null we put zero
		CASE  UPPER(TRIM(prd_line)) -- data normalization 
		 WHEN 'M' THEN 'Mountain'
		 WHEN 'R' THEN 'Road'
		 WHEN  'S' THEN 'Other Sales'
		 WHEN 'T' THEN 'Touring'
		ELSE 'n/a'  --  we handle missing data insead of nall we have n/a
	END prd_line,	
	prd_start_dt,
	LEAD(prd_start_dt) OVER (PARTITION BY prd_key ORDER BY prd_start_dt) AS prd_end_dt -- data enreachment adding a new relevate data
	FROM bronze.crm_prd_info;
	SET @end_time = GETDATE();
	PRINT '>> load Duration: '+ CAST(DATEDIFF(SECOND, @start_time, @end_time) AS NVARCHAR) + 'seconds';
	PRINT '>> ------------------';

	--=======================================================================================
	-- Loading silver.crm_sales_details
	SET @start_time = GETDATE();
	PRINT '>> Truncate table: silver.crm_sales_details';
	TRUNCATE TABLE silver.crm_sales_details;
	PRINT '>> Inserting Data Into: silver.crm_sales_details';
	INSERT INTO silver.crm_sales_details(
		sls_ord_num,
		sls_prd_key,
		sls_cust_id,
		sls_order_dt,
		sls_ship_dt,
		sls_due_dt,
		sls_sales,
		sls_quantity,
		sls_price
	)

	SELECT
	sls_ord_num,
	sls_prd_key,
	sls_cust_id,
	CASE WHEN sls_order_dt = 0 OR LEN(sls_order_dt) != 8 THEN NULL
		ELSE CAST(CAST(sls_order_dt AS VARCHAR) AS DATE)
		END AS sls_order_dt,
	CASE WHEN sls_ship_dt = 0 OR LEN(sls_ship_dt) != 8 THEN  sls_ship_dt
		ELSE CAST(CAST(sls_ship_dt AS VARCHAR) AS DATE)
		END AS sls_ship_dt,
	CASE WHEN sls_due_dt = 0 OR  LEN(sls_due_dt) ! = 8 THEN sls_due_dt
		ELSE CAST(CAST(sls_due_dt AS VARCHAR) AS DATE)
		END AS sls_due_dt,
	CASE WHEN sls_sales IS NULL OR sls_sales <=0 OR sls_sales != sls_sales *ABS(sls_price)
		THEN sls_quantity *ABS(sls_price)
		ELSE sls_sales
		END AS sls_sales,
	sls_quantity,
	CASE WHEN sls_price IS NULL OR sls_price <= 0
		THEN sls_sales / NULLIF(sls_quantity, 0)
		ELSE sls_price
		END  AS sls_price
	FROM bronze.crm_sales_details;
	SET @end_time = GETDATE();
	PRINT '>> load Duration: '+ CAST(DATEDIFF(SECOND, @start_time, @end_time) AS NVARCHAR) + 'seconds';
	PRINT '>> ------------------';
	-- ================================================================================
	-- Loading silver.erp_CUST_AZ12
	SET @start_time = GETDATE();
	PRINT '>> Truncate table: silver.erp_CUST_AZ12';
	TRUNCATE TABLE silver.erp_CUST_AZ12;
	PRINT '>> Inserting Data Into: silver.erp_CUST_AZ12';
	INSERT INTO silver.erp_CUST_AZ12 (
	cid,
	bdate,
	gen
	)

	SELECT 
	CASE WHEN cid LIKE 'NASA%' THEN SUBSTRING(cid, 4, LEN(cid)) -- REMOVEING VALUE  THAT NOT NEEDED 'NAS' PREFIX IF PRESENT
		ELSE cid
	END AS cid,
	CASE WHEN bdate> GETDATE() THEN NULL
		ELSE bdate
	END AS bdate, -- SET future birthdate to null
	CASE WHEN UPPER(TRIM(gen)) IN ('F', 'FEMALE') THEN 'Female'
		WHEN UPPER(TRIM(gen)) IN ('M', 'MALE') THEN 'male'
		ELSE 'n/a'
	END AS gen -- Normalize gender value and handle unknown cases
	FROM bronze.erp_CUST_AZ12;
	SET @end_time = GETDATE();
	PRINT '>> load Duration: '+ CAST(DATEDIFF(SECOND, @start_time, @end_time) AS NVARCHAR) + 'seconds';
	PRINT '>> ------------------';
	--==========================================================
	-- Loading silver.erp_LOC_A101
	SET @start_time = GETDATE();
	PRINT '>> Truncate table: silver.erp_LOC_A101';
	TRUNCATE TABLE silver.erp_LOC_A101;
	PRINT '>> Inserting Data Into: silver.erp_LOC_A101';
	INSERT INTO silver.erp_LOC_A101 (
	cid,
	cntry
	)
	SELECT 
	REPLACE (cid, '-', '')cid,
	CASE WHEN TRIM(cntry) = 'DE' THEN 'GERMANY'
		WHEN TRIM(cntry) IN ('US, USA' )THEN 'UNITED STATE'
		WHEN TRIM(cntry) = '' OR cntry IS NULL THEN 'n/a'
		ELSE TRIM (cntry)
		END  AS CNTRY
	FROM bronze.erp_LOC_A101;
	SET @end_time = GETDATE();
	PRINT '>> load Duration: '+ CAST(DATEDIFF(SECOND, @start_time, @end_time) AS NVARCHAR) + 'seconds';
	PRINT '>> ------------------';
	--==============================================================
	-- Loading silver.erp_PX_CAT_G1V2
	SET @start_time = GETDATE();
	PRINT '>> Truncate table: silver.erp_PX_CAT_G1V2';
	TRUNCATE TABLE silver.erp_PX_CAT_G1V2;
	PRINT '>> Inserting Data Into: silver.erp_PX_CAT_G1V2';
	INSERT INTO silver.erp_PX_CAT_G1V2 (
	id,
	cat,
	subcat,
	maintenance
	)
	SELECT
	id,
	cat,
	subcat,
	maintenance
	FROM bronze.erp_PX_CAT_G1V2;
SET @end_time = GETDATE();
	PRINT '>> load Duration: '+ CAST(DATEDIFF(SECOND, @start_time, @end_time) AS NVARCHAR) + 'seconds';
	PRINT '>> ------------------';

	SET @batch_end_time = GETDATE();
	PRINT '=================================='
	PRINT 'Loading Silver Layer is Completed';
	PRINT '  - Total Load Duration:' + CAST(DATEDIFF(SECOND, @start_time, @end_time) AS NVARCHAR) + 'seconds' ;
	PRINT '==================================='

	END TRY
	BEGIN CATCH 
		PRINT '==============================='
		PRINT 'ERROR OCCURED DURING LOADING BRONZE LAYER'
		PRINT 'Error Message' + ERROR_MESSAGE();
		PRINT 'Error Message' + CAST(ERROR_MESSAGE() AS NVARCHAR);
		PRINT 'Error Message' + CAST(ERROR_STATE() AS NVARCHAR);
		PRINT '==============================='
	END CATCH
END









