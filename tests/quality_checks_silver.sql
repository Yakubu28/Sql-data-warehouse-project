
/*
=================================================================================
Quality Checks
=================================================================================
Script purspose:
this script performs various quality checks for data consistency, accuracy ,
and standardization across the 'silver' schema. it includes checks for:
- Null or duplicate primary keys.
- Unwanted space in string fields.
-Data standardization and consistency.
- Invalid date range and orders.
- Data consistency between related field.

usage Notes:
- Run these check after data loading silver layer.
- Investigate and resolve any discrepancies found during the checks.
====================================================================================
*/

-- ==================================================================
-- Checking 'silver.crm_cust_info'
-- ==================================================================
-- check for NULLs or Duplicates in primary Key
-- Expectation: NO Result 
SELECT 
  cst_id,
  COUNT(*)
FROM silver.crm_cust_info
GROUP BY cst_id
HAVING COUNT(*) > 1 OR cst_id IS NULL;

-- Check for Unwanted Spaces 
-- Expectation: No result 
SELECT
cst_key
FROM silver.crm_cust_info
WHERE cst_key != TRIM(cst_key);

-- Data Standadizationtion & Consistency
SELECT DISTINCT
cst_matital_status
FROM silver.crm_cust_info

--======================================================================
-- Checking 'silver.crm_prd_info'
-- =====================================================================
-- Check for NULLs or Duplicates in primary key
-- Expextation: No Result
SELECT 
  prd_info
  COUNT(*)
FROM silve.crm_prd_info
GROUP BY prd_info
HAVING COUNT (*) >1 OR prd_id IS NULL;

-- Check for Unwanted Spaces
-- Expectation: No Results
SELECT
prd_nm
FROM  silver.crm_prd_info
WHERE prd_nm != TRIM(prd_nm);

-- Checking for NULLs or Negative Values in Cost 
-- Expectation: No Result 
SELECT 
prd_cost 
FROM  silver.crm_prd_info
WHERE prd_cost < 0 OR prd_cost IS NULL;

-- Data Standiztion & Consistencey
SELECT DISTINCT
  prd_line
FROM  silver.crm_prd_info;

-- Check for invalid Date Orders(Start date > End Date)
-- Expectation: NO Result 
SELECT 
*
FROM  silver.crm_prd_info
WHERE prd_end_dt< prd_start_dt;

-- =======================================================
-- Checking 'silver.crm_sales_details' 
--================================================-=======
-- Check For Invalid dates
-- Expectation: No Ivalid Dates
SELECT 
NULLIFF(sls_due_dt, 0) AS sls_due_dt
FROM bronze.crm_slaes_details
WHERE sls_due_dt <= 0
  OR LEN(sls_due_dt) !=*
  OR sls_due_dt > 20500101
  OR sls_due_dt < 190000101;

-- Check for invalid Date Orders(Order Date > Shipping date)
-- Expectation: No Results
SELECT
*
FROM silver.crm_sales_details
WHERE sls_order_dt > sls_ship_dt
OR sls_order_dt >sls_due_dt

-- Check Data consistency: Sales = Quantity * Price
-- Expectation: No Result 
SELECT DISTINCT
  sls_sales,
  sls_quantity,
  sls_price
FROM silver.crm_sales_details
WHERE sls_sales != sls_quantity * sls_price 
  OR sls_sales IS NULL
  OR sls_quantity IS NULL
  OR sls_price IS NULL
  OR sls_sales <= 0
  OR sls_quantity <= 0
  OR sls_price <= 0
ORDER BY sls_sales, sls_quantity, sls_price 

--============================================================
-- Checking 'silver.erp_cust_az12'
--===========================================================
-- Identify Out -of Range dates
-- Expectation: Birthdates between 1924-01-01 and Today
SELECT DISTINCT
  bdate
FROM silver.erp_cust_az12
WHERE bdate < '1924-01-01'
  OR bdtae > GETDATE();

--Data Standardization & Consistency
SELECT DISTINCT 
  gen
FROM silver.erp_cust_az12;

-- ==================================================================
-- Checking 'Silver.erp_loc_a101'
-- ===========================================================================
-- Data Standardization & Consistency
  SELECT DISTINCT
  cntry
FROM silver.erp_loc_a101
ORDER BY cntry;
-- =====================================================================
-- Checking 'Silver.erp_px_cat_g1v2'
-- =====================================================================
-- check for Unwanted Space
-- Expectation: No Results
SELECT
  *
FROM silver.erp_px_cat_g1v2
WHERE cat != TRIM(cat)
  OR subcat != TRIM(subcat)
OR maintenance != TRIM(maintenance);

-- DATA Standardization & Consistency
SELECT  DISTINT 
maintenance
FEOM silver.erp_px_cat_g1v2;

  
