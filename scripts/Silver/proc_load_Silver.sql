/*
================================================================================
Stored Procedure: Load Silver Layer (Source -> Silver)
================================================================================

Script Purpose:
    This stored procedure loads data into the 'Silver' schema from external CSV files.
    It performs the following actions:
    - Truncates the bronze tables before loading data.
    - Uses the `BULK INSERT` command to load data from csv files to Silver tables.

Parameters:
    None.
    This stored procedure does not accept any parameters or return any values.

Usage Example:

    EXEC Silver.load_Silver;

================================================================================
*/

CREATE OR ALTER PROCEDURE Silver.load_Silver as
BEGIN
Declare @start_time datetime, @end_time datetime, @batch_start_time datetime, @batch_end_time datetime;
BEGIN TRY
Set @batch_start_time = GETDATE();
Print'=============================================================';
Print'Loading Silver Layer';
Print'=============================================================';

Print'-------------------------------------------------------------';
Print'Loading CRM Tables';
Print'-------------------------------------------------------------';
	
	Set @Start_time = GETDATE();
	Print'>> Truncating Table: Silver.crm_cust_info';
	Truncate Table Silver.crm_cust_info;
	Print'>> Inserting Data Into: Silver.crm_cust_info';
	Insert into Silver.crm_cust_info(
	cst_id,
	cst_key,
	cst_firstname,
	cst_lastname,
	cst_material_status,
	cst_gndr,
	cst_create_date
	)
	Select
	cst_id,
	cst_key,
	TRIM(cst_firstname) as cst_firstname,
	TRIM(cst_lastname) as cst_lastname,
	CASE WHEN UPPER(TRIM(cst_material_status)) = 'S' THEN 'Single'
		 WHEN UPPER(TRIM(cst_material_status)) = 'M' THEN 'Married'
		 ELSE 'n/a'
	END as cst_material_status,
	CASE WHEN UPPER(TRIM(cst_gndr)) = 'F' THEN 'Female'
		 WHEN UPPER(TRIM(cst_gndr)) = 'M' THEN 'Male'
		 ELSE 'n/a'
	END as cst_gndr,
	cst_create_date
	From (
		Select
		*,
		Row_number() over(partition by cst_id order by cst_create_date desc) as flag_last
		From Bronze.crm_cust_info
		where cst_id is not null
	)t where flag_last = 1;
	Set @end_time = GETDATE();
	Print'>>Load Duration: '+ cast(Datediff(second,@Start_time,@end_time)as nvarchar)+' seconds';
	Print'>>---------------------';

	Set @Start_time = GETDATE();
	Print'>> Truncating Table: Silver.crm_prd_info';
	Truncate Table Silver.crm_prd_info;
	Print'>> Inserting Data Into: Silver.crm_prd_info';
	Insert into Silver.crm_prd_info(
		prd_id,
		cat_id,
		prd_key,
		prd_nm,
		prd_cost,
		prd_line,
		prd_start_dt,
		prd_end_dt
	)
	Select
		Prd_id,
		REPLACE(SUBSTRING(Prd_key,1,5),'-','_') as cat_id,
		SUBSTRING(Prd_key,7,len(Prd_key)) as prd_key,
		prd_nm,
		ISNULL(prd_cost,0) as prd_cost,
		CASE WHEN UPPER(TRIM(prd_line)) = 'M' THEN 'Mountain'
			 WHEN UPPER(TRIM(prd_line)) = 'R' THEN 'Road'
			 WHEN UPPER(TRIM(prd_line)) = 'S' THEN 'Other Sales'
			 WHEN UPPER(TRIM(prd_line)) = 'T' THEN 'Touring'
			 ELSE 'n/a'
		END as prd_line,
		CAST(prd_start_dt as Date) as prd_start_dt,
		CAST(LEAD(prd_start_dt) over (Partition by prd_key order by prd_start_dt)-1 as date) as prd_end_dt
	From Bronze.crm_prd_info;
	Set @end_time = GETDATE();
	Print'>>Load Duration: '+ cast(Datediff(second,@Start_time,@end_time)as nvarchar)+' seconds';
	Print'>>---------------------';

	Set @Start_time = GETDATE();
	Print'>> Truncating Table: Silver.crm_sales_details';
	Truncate Table Silver.crm_sales_details;
	Print'>> Inserting Data Into: Silver.crm_sales_details';
	Insert into Silver.crm_sales_details(
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
	Select
		sls_ord_num,
		sls_prd_key,
		sls_cust_id,
		CASE WHEN sls_order_dt = 0 or LEN(sls_order_dt) != 8 THEN NULL
			 ELSE CAST(CAST(sls_order_dt as VARCHAR) as Date)
		END as sls_order_dt,
		CASE WHEN sls_ship_dt = 0 or LEN(sls_ship_dt) != 8 THEN NULL
			 ELSE CAST(CAST(sls_ship_dt as VARCHAR) as DATE)
		END as sls_ship_dt,
		CASE WHEN sls_due_dt = 0 or LEN(sls_due_dt) != 8 THEN NULL
			 ELSE CAST(CAST(sls_due_dt as VARCHAR) as DATE)
		END as sls_due_dt,
		CASE WHEN sls_sales is null or sls_sales<=0 or sls_sales != sls_quantity*ABS(sls_price) THEN sls_quantity*ABS(sls_price)
			 ELSE sls_sales
		END as sls_sales,--Recaluculate sales if the original value is missing or incorrect
		sls_quantity,
		CASE WHEN sls_price is Null or sls_price <=0 then sls_sales/NULLIF(sls_quantity,0)
			 ELSE sls_price
		END as sls_price --Derive price if original value is incorrect
	From Bronze.crm_sales_details;
	Set @end_time = GETDATE();
	Print'>>Load Duration: '+ cast(Datediff(second,@Start_time,@end_time)as nvarchar)+' seconds';
	Print'>>---------------------';

Print'-------------------------------------------------------------';
Print'Loading ERP Tables';
Print'-------------------------------------------------------------';
	
	Set @Start_time = GETDATE();
	Print'>> Truncating Table: Silver.erp_cust_az12';
	Truncate Table Silver.erp_cust_az12;
	Print'>> Inserting Data Into: Silver.erp_cust_az12';
	Insert into Silver.erp_cust_az12(
	 cid,
	 bdate,
	 gen
	 )

	Select
		CASE WHEN cid like 'NAS%' then SUBSTRING(cid,4,len(cid))
			 ELSE cid
		END as cid,
		CASE WHEN bdate > GETDATE() THEN NULL
			 ELSE bdate
		END as bdate,
		CASE WHEN UPPER(TRIM(gen)) in ('F','Female') THEN 'Female'
			 WHEN UPPER(TRIM(gen)) in ('M','Male') THEN 'Male'
			 Else 'n/a'
		END as gen
	From Bronze.erp_cust_az12;
	Set @end_time = GETDATE();
	Print'>>Load Duration: '+ cast(Datediff(second,@Start_time,@end_time)as nvarchar)+' seconds';
	Print'>>---------------------';

	Set @Start_time = GETDATE();
	Print'>> Truncating Table: Silver.erp_loc_a101';
	Truncate Table Silver.erp_loc_a101;
	Print'>> Inserting Data Into: Silver.erp_loc_a101';
	Insert into Silver.erp_loc_a101(
	cid,
	cntry
	)
	Select
	REPLACE(cid,'-','') as cid,
	CASE WHEN TRIM(cntry) = 'DE' THEN 'Germany'
		 WHEN TRIM(cntry) in ('US','USA') then 'United states'
		 WHEN TRIM(cntry) = '' or cntry is null THEN 'n/a'
		 ELSE TRIM(cntry)
	END as cntry
	From Bronze.erp_loc_a101;
	Set @end_time = GETDATE();
	Print'>>Load Duration: '+ cast(Datediff(second,@Start_time,@end_time)as nvarchar)+' seconds';
	Print'>>---------------------';

	Set @Start_time = GETDATE();
	Print'>> Truncating Table: Silver.erp_px_cat_g1v2';
	Truncate Table Silver.erp_px_cat_g1v2;
	Print'>> Inserting Data Into: Silver.erp_px_cat_g1v2';
	Insert Into Silver.erp_px_cat_g1v2(
	id,
	cat,
	subcat,
	maintenance
	)
	Select
		id,
		cat,
		subcat,
		maintenance
	From Bronze.erp_px_cat_g1v2;
	Set @end_time = GETDATE();
	Print'>>Load Duration: '+ cast(Datediff(second,@Start_time,@end_time)as nvarchar)+' seconds';
	Print'>>---------------------';
  Set @batch_end_time = GETDATE();
  Print'========================================================================================';
  Print'Loading Silver layer is Completed';
  Print'   - Total Load Duration: '+ Cast(datediff(Second,@batch_start_time,@batch_end_time) as nvarchar)+' seconds';
  Print'========================================================================================';
END TRY
BEGIN CATCH
 Print'=============================================';
 Print'Error Occured during Silver loading';
 Print'Error Message'+Error_Message();
 Print'Error Message'+cast(Error_Number() as nvarchar);
 Print'Error Message'+ cast(Error_state() as nvarchar);
 Print'=============================================';
END CATCH;
END
