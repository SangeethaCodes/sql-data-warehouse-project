/*
================================================================================
Stored Procedure: Load Bronze Layer (Source -> Bronze)
================================================================================

Script Purpose:
    This stored procedure loads data into the 'bronze' schema from external CSV files.
    It performs the following actions:
    - Truncates the bronze tables before loading data.
    - Uses the `BULK INSERT` command to load data from csv files to bronze tables.

Parameters:
    None.
    This stored procedure does not accept any parameters or return any values.

Usage Example:

    EXEC bronze.load_bronze;

================================================================================
*/

CREATE or ALTER procedure Bronze.load_bronze as
BEGIN
Declare @start_time datetime, @end_time datetime, @batch_start_time datetime, @batch_end_time datetime;
  BEGIN TRY
  Set @batch_start_time = GETDATE();
	Print'======================================================';
	Print'Loading Bronze Layer';
	Print'======================================================';

	Print '-----------------------------------------------------';
	Print'Loading CRM Tables';
	Print '-----------------------------------------------------';

	Set @Start_time = GETDATE();
	  Print'>> Truncating Table:Bronze.crm_cust_info';
		truncate table Bronze.crm_cust_info;
	  Print'>>Inserting Data Into:Bronze.crm_cust_info';
		bulk insert Bronze.crm_cust_info
		From 'C:\Users\Lenovo\Downloads\sql-data-warehouse-project-main\sql-data-warehouse-project-main\01_datasets\source_crm\cust_info.csv'
		with(
			firstrow=2,
			fieldterminator = ',',
			tablock
		);
    Set @end_time = GETDATE();
	Print'>>Load Duration: '+ cast(Datediff(second,@Start_time,@end_time)as nvarchar)+' seconds';
	Print'>>---------------------';

    Set @Start_time = GETDATE();
	  Print'>> Truncating Table:Bronze.crm_prd_info';
		truncate table Bronze.crm_prd_info;
	  Print'>>Inserting Data Into:Bronze.crm_prd_info';
		bulk insert Bronze.crm_prd_info
		From 'C:\Users\Lenovo\Downloads\sql-data-warehouse-project-main\sql-data-warehouse-project-main\01_datasets\source_crm\prd_info.csv'
		with(
			firstrow=2,
			fieldterminator = ',',
			tablock
		);
	Set @end_time = GETDATE();
	Print'>>Load Duration: '+ cast(Datediff(second,@Start_time,@end_time)as nvarchar)+' seconds';
	Print'>>---------------------';


	Set @Start_time = GETDATE();
	  Print'>> Truncating Table:Bronze.crm_sales_details';
		truncate table Bronze.crm_sales_details;
	  Print'>>Inserting Data Into:Bronze.crm_sales_details';
		bulk insert Bronze.crm_sales_details
		From 'C:\Users\Lenovo\Downloads\sql-data-warehouse-project-main\sql-data-warehouse-project-main\01_datasets\source_crm\sales_details.csv'
		with(
			firstrow=2,
			fieldterminator = ',',
			tablock
		);
	Set @end_time = GETDATE();
	Print'>>Load Duration: '+ cast(Datediff(second,@Start_time,@end_time)as nvarchar)+' seconds';
	Print'>>---------------------';


	Print '-----------------------------------------------------';
	Print'Loading ERP Tables';
	Print '-----------------------------------------------------';

	Set @Start_time = GETDATE();
	  Print'>> Truncating Table:Bronze.erp_cust_az12';
		truncate table Bronze.erp_cust_az12;
	  Print'>>Inserting Data Into:Bronze.erp_cust_az12';
		bulk insert Bronze.erp_cust_az12
		From 'C:\Users\Lenovo\Downloads\sql-data-warehouse-project-main\sql-data-warehouse-project-main\01_datasets\source_erp\cust_az12.csv'
		with(
			firstrow=2,
			fieldterminator = ',',
			tablock
		);
	Set @end_time = GETDATE();
	Print'>>Load Duration: '+ cast(Datediff(second,@Start_time,@end_time)as nvarchar)+' seconds';
	Print'>>---------------------';


	Set @Start_time = GETDATE();
	  Print'>> Truncating Table:Bronze.erp_loc_a101';
		truncate table Bronze.erp_loc_a101;
	  Print'>>Inserting Data Into:Bronze.erp_loc_a101';
		bulk insert Bronze.erp_loc_a101
		From 'C:\Users\Lenovo\Downloads\sql-data-warehouse-project-main\sql-data-warehouse-project-main\01_datasets\source_erp\loc_a101.csv'
		with(
			firstrow=2,
			fieldterminator = ',',
			tablock
		);
	Set @end_time = GETDATE();
	Print'>>Load Duration: '+ cast(Datediff(second,@Start_time,@end_time)as nvarchar)+' seconds';
	Print'>>---------------------';


	Set @Start_time = GETDATE();
	  Print'>> Truncating Table:Bronze.erp_px_cat_g1v2';
		truncate table Bronze.erp_px_cat_g1v2;
	  Print'>>Inserting Data Into:Bronze.erp_px_cat_g1v2';
		bulk insert Bronze.erp_px_cat_g1v2
		From 'C:\Users\Lenovo\Downloads\sql-data-warehouse-project-main\sql-data-warehouse-project-main\01_datasets\source_erp\px_cat_g1v2.csv'
		with(
			firstrow=2,
			fieldterminator = ',',
			tablock
		);
	Set @end_time = GETDATE();
	Print'>>Load Duration: '+ cast(Datediff(second,@Start_time,@end_time)as nvarchar)+' seconds';
	Print'>>---------------------';

  Set @batch_end_time = GETDATE();
  Print'========================================================================================';
  Print'Loading Bronze layer is Completed';
  Print'   - Total Load Duration: '+ Cast(datediff(Second,@batch_start_time,@batch_end_time) as nvarchar)+' seconds';
  Print'========================================================================================';

  END TRY
  BEGIN CATCH
    Print'=============================================';
    Print'Error Occured during Bronze loading';
    Print'Error Message'+Error_Message();
    Print'Error Message'+cast(Error_Number() as nvarchar);
    Print'Error Message'+ cast(Error_state() as nvarchar);
    Print'=============================================';
END CATCH;
END
