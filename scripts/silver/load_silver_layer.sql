USE DataWarehouse
GO
CREATE OR ALTER PROCEDURE silver.load_silver AS
BEGIN
	BEGIN TRY
	DECLARE @start_time DATETIME, @end_time DATETIME;
	SET @start_time=GETDATE();
		print '#############################';
		print '    loading sliver layer     ';
		print '#############################';
		/*--------crm file------*/
		print '#############################';
		print '    loading crm files layer     ';
		print '#############################';
		SET @start_time=GETDATE();
		/*crm cust info*/
       
TRUNCATE TABLE silver.crm_cust_info;
INSERT INTO silver.crm_cust_info(
cst_id,
cst_key,
cst_firstname,
cst_lastname,
cst_marital_status,
cst_gndr,
cst_create_date)
SELECT
cst_id,
cst_key,
TRIM(cst_firstname),
TRIM(cst_lastname),
CASE WHEN cst_marital_status ='M' THEN 'Married'
     WHEN cst_marital_status ='S' THEN 'Single'
     ELSE 'N/A'
END cst_marital_status,
CASE WHEN cst_gndr ='F' THEN 'Female'
     WHEN cst_gndr ='M' THEN 'Male'
     ELSE 'N/A'
END cst_gndr,
cst_create_date 
FROM(
SELECT *,
ROW_NUMBER() OVER(PARTITION BY cst_id ORDER BY cst_create_date DESC) AS last_flag
FROM bronze.crm_cust_info
WHERE cst_id IS NOT NULL
)V WHERE last_flag=1

SET @end_time=GETDATE();
		PRINT'INSERTED DATA INTO silver.crm_cust_info in:' +CAST(DATEDIFF(SECOND,@start_time,@end_time) AS NVARCHAR(50))+ 'SECONDS';


SET @start_time=GETDATE();
/*crm product info*/
TRUNCATE TABLE silver.crm_prd_info;
INSERT INTO silver.crm_prd_info(
prd_id ,
cat_id  ,
prd_key  ,
prd_nm  ,
prd_cost ,
prd_line  ,
prd_start_dt ,
prd_end_dt
)
SELECT 
prd_id,
REPLACE(SUBSTRING(prd_key,1,5),'-','_') AS cat_id,
SUBSTRING(prd_key,7,LEN(prd_key)) AS prd_key,
prd_nm,
ISNULL(prd_cost,0) AS prd_cost,
CASE UPPER(TRIM(prd_line))
WHEN 'M' THEN 'MOUNTAIN'
WHEN 'R' THEN 'ROAD'
WHEN 'S' THEN 'OTHER SALES'
WHEN 'T' THEN 'TOURING'
ELSE 'N/A'
END AS prd_line,
CAST(prd_start_dt AS DATE) AS prd_start_dt,
CAST(LEAD(prd_start_dt) OVER( PARTITION BY prd_key ORDER BY prd_start_dt)-1 AS DATE) AS prd_end_dt
FROM bronze.crm_prd_info
SET @end_time=GETDATE();
		PRINT'INSERTED DATA INTO silver.crm_prd_info in:' +CAST(DATEDIFF(SECOND,@start_time,@end_time) AS NVARCHAR(50))+ 'SECONDS';

        SET @start_time=GETDATE();
		/*crm sales details*/
		TRUNCATE TABLE silver.crm_sales_details;
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

CASE WHEN sls_ship_dt = 0 OR LEN(sls_ship_dt) != 8 THEN NULL
     ELSE CAST(CAST(sls_ship_dt AS VARCHAR) AS DATE)
END AS sls_ship_dt,

CASE WHEN sls_due_dt = 0 OR LEN(sls_due_dt) != 8 THEN NULL
     ELSE CAST(CAST(sls_due_dt AS VARCHAR) AS DATE)
END AS sls_due_dt,

CASE WHEN sls_sales IS NULL
          OR sls_sales <= 0
          OR sls_sales != sls_quantity * ABS(sls_price)
     THEN sls_quantity * ABS(sls_price)
     ELSE sls_sales
END AS sls_sales,
sls_quantity,
CASE WHEN sls_price IS NULL OR sls_price<=0
THEN sls_sales/NULLIF(sls_quantity,0)
ELSE sls_price
END AS sls_price
FROM bronze.crm_sales_details
SET @end_time=GETDATE();
		PRINT'INSERTED DATA INTO silver.sales_datiles in:' +CAST(DATEDIFF(SECOND,@start_time,@end_time) AS NVARCHAR(50))+ 'SECONDS';
		print'CRM file sussucessfully loaded';

	/*------erp file data-------*/
		print '#############################';
		print '    loading erp files layer     ';
		print '#############################';
		SET @start_time=GETDATE();
		/*erp table cust*/
		TRUNCATE TABLE silver.erp_cust_aZ12;
INSERT INTO silver.erp_cust_az12(
CID,
BDATE,
GEN)
SELECT 
CASE WHEN CID LIKE 'NAS%'
THEN SUBSTRING(CID,4,LEN(CID))
ELSE CID
END AS CID,
CASE WHEN BDATE > GETDATE()THEN NULL
ELSE BDATE
END AS BDATE,
CASE WHEN UPPER(TRIM(GEN)) IN ('F','FEMALE') THEN 'Female'
     WHEN UPPER(TRIM(GEN)) IN ('M','MALE') THEN 'Male'
     ELSE 'n/a'
     END AS GEN
FROM bronze.erp_cust_az12
SET @end_time=GETDATE();
		PRINT'INSERTED DATA INTO silver.erp_cust_az12 in:' +CAST(DATEDIFF(SECOND,@start_time,@end_time) AS NVARCHAR(50))+ 'SECONDS';

/*erp table loc_a101*/
		SET @start_time=GETDATE();
		TRUNCATE TABLE silver.erp_loc_a101;
INSERT INTO silver.erp_loc_a101(
CID,
CNTRY
)
SELECT 
REPLACE(CID,'-','') AS CID,
CASE WHEN TRIM(CNTRY)='DE' THEN 'GERMANY'
        WHEN TRIM(CNTRY) IN('US' , 'USA') THEN 'United States'
        WHEN TRIM(CNTRY)='NULL' THEN 'N/A'
        WHEN TRIM(CNTRY)='' THEN 'N/A'
        ELSE TRIM(CNTRY)
END AS CNTRY
FROM bronze.erp_loc_a101
SET @end_time=GETDATE();
		PRINT'INSERTED DATA INTO silver.erp_loc_a101:' +CAST(DATEDIFF(SECOND,@start_time,@end_time) AS NVARCHAR(50))+ 'SECONDS';

/*erp table px_cat*/
		SET @start_time=GETDATE();
		TRUNCATE TABLE silver.erp_px_cat_g1v2;
INSERT INTO silver.erp_px_cat_g1v2(
ID,
CAT,
SUBCAT,
MAINTENANCE
)
SELECT
ID,
CAT,
SUBCAT,
MAINTENANCE
FROM bronze.erp_px_cat_g1v2;
SET @end_time=GETDATE();
		PRINT'INSERTED DATA INTO silver.erp_pc_cat_g1v2 in:' +CAST(DATEDIFF(SECOND,@start_time,@end_time) AS NVARCHAR(50))+ 'SECONDS';
		print'ERP files sussucessfully loaded';
		SET @end_time=GETDATE();
		PRINT'TOTAL TIME TAKEN IN UPLOADING DATA INTO silver LAYER IS:' +CAST(DATEDIFF(SECOND,@start_time,@end_time) AS NVARCHAR(50))+ 'SECONDS';
	END TRY
	BEGIN CATCH
	PRINT '#############################################'
	PRINT ' ERROR OCCURED  DURING LOADING silver LAYER '
	PRINT '#############################################'
	END CATCH
END
