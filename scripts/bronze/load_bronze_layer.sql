/* This is used to add the data frome the csv files crm and erp into the tables and also to calculate the time taken to complete  the loading process*/ 
CREATE OR ALTER PROCEDURE bronze.load_bronze AS
BEGIN
	BEGIN TRY
	DECLARE @start_time DATETIME, @end_time DATETIME;
	SET @start_time=GETDATE();
		print '#############################';
		print '    loading bronze layer     ';
		print '#############################';
		/*--------crm file------*/
		print '#############################';
		print '    loading crm files layer     ';
		print '#############################';
		SET @start_time=GETDATE();
		/*crm cust info*/
		TRUNCATE TABLE bronze.crm_cust_info;
		BULK INSERT bronze.crm_cust_info
		FROM 'C:\Users\rajat\OneDrive\Desktop\code\warehouse project\sql-data-warehouse-project\datasets\source_crm\cust_info.csv'
		WITH (
		FIRSTROW =2,
		FIELDTERMINATOR=',',
		TABLOCK
		);
		SET @end_time=GETDATE();
		PRINT'INSERTED DATA INTO bronze.crm_cust_info in:' +CAST(DATEDIFF(SECOND,@start_time,@end_time) AS NVARCHAR(50))+ 'SECONDS';


		SET @start_time=GETDATE();
		/*crm product info*/
		TRUNCATE TABLE bronze.crm_prd_info;
		BULK INSERT bronze.crm_prd_info
		FROM 'C:\Users\rajat\OneDrive\Desktop\code\warehouse project\sql-data-warehouse-project\datasets\source_crm\prd_info.csv'
		WITH (
		FIRSTROW =2,
		FIELDTERMINATOR=',',
		TABLOCK
		);
		SET @end_time=GETDATE();
		PRINT'INSERTED DATA INTO bronze.crm_prd_info in:' +CAST(DATEDIFF(SECOND,@start_time,@end_time) AS NVARCHAR(50))+ 'SECONDS';

		SET @start_time=GETDATE();
		/*crm sales details*/
		TRUNCATE TABLE bronze.crm_sales_details;
		BULK INSERT bronze.crm_sales_details
		FROM 'C:\Users\rajat\OneDrive\Desktop\code\warehouse project\sql-data-warehouse-project\datasets\source_crm\sales_details.csv'
		WITH (
		FIRSTROW =2,
		FIELDTERMINATOR=',',
		TABLOCK
		);
		SET @end_time=GETDATE();
		PRINT'INSERTED DATA INTO bronze.sales_datiles in:' +CAST(DATEDIFF(SECOND,@start_time,@end_time) AS NVARCHAR(50))+ 'SECONDS';
		print'CRM file sussucessfully loaded';


		/*------erp file data-------*/
		print '#############################';
		print '    loading erp files layer     ';
		print '#############################';
		SET @start_time=GETDATE();
		/*erp table loc*/
		TRUNCATE TABLE bronze.erp_loc_a101;
		BULK INSERT bronze.erp_loc_a101
		FROM 'C:\Users\rajat\OneDrive\Desktop\code\warehouse project\sql-data-warehouse-project\datasets\source_erp\loc_a101.csv'
		WITH (
		FIRSTROW =2,
		FIELDTERMINATOR=',',
		TABLOCK
		);
		SET @end_time=GETDATE();
		PRINT'INSERTED DATA INTO bronze.erp_loc_a101:' +CAST(DATEDIFF(SECOND,@start_time,@end_time) AS NVARCHAR(50))+ 'SECONDS';

		SET @start_time=GETDATE();
		/*erp table erp cust*/
		TRUNCATE TABLE bronze.erp_cust_az12;
		BULK INSERT bronze.erp_cust_az12
		FROM 'C:\Users\rajat\OneDrive\Desktop\code\warehouse project\sql-data-warehouse-project\datasets\source_erp\cust_az12.csv'
		WITH (
		FIRSTROW =2,
		FIELDTERMINATOR=',',
		TABLOCK
		);
		SET @end_time=GETDATE();
		PRINT'INSERTED DATA INTO bronze.erp_cust_az12 in:' +CAST(DATEDIFF(SECOND,@start_time,@end_time) AS NVARCHAR(50))+ 'SECONDS';


		/*erp table px_cat*/
		SET @start_time=GETDATE();
		TRUNCATE TABLE bronze.erp_px_cat_g1v2;
		BULK INSERT bronze.erp_px_cat_g1v2
		FROM 'C:\Users\rajat\OneDrive\Desktop\code\warehouse project\sql-data-warehouse-project\datasets\source_erp\px_cat_g1v2.csv'
		WITH (
		FIRSTROW =2,
		FIELDTERMINATOR=',',
		TABLOCK
		);
		SET @end_time=GETDATE();
		PRINT'INSERTED DATA INTO bronze.erp_pc_cat_g1v2 in:' +CAST(DATEDIFF(SECOND,@start_time,@end_time) AS NVARCHAR(50))+ 'SECONDS';
		print'ERP files sussucessfully loaded';
		SET @end_time=GETDATE();
		PRINT'TOTAL TIME TAKEN IN UPLOADING DATA INTO BRONZE LAYER IS:' +CAST(DATEDIFF(SECOND,@start_time,@end_time) AS NVARCHAR(50))+ 'SECONDS';
	END TRY
	BEGIN CATCH
	PRINT '#############################################'
	PRINT ' ERROR OCCURED  DURING LOADING BRONZE LAYER '
	PRINT '#############################################'
	END CATCH
END
EXEC bronze.load_bronze;
