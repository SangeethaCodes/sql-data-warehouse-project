/*
=============================================================================
DDL Script: Create Silver Tables
=============================================================================
Script Purpose:
 This Script create tables in the 'Silver" schema, dropping existing tables is they already exists.
 Run this script to redefine the DDL structure of 'Silver' tables
=============================================================================
*/

If object_id('Silver.crm_cust_info','U') is not null
	drop table Silver.crm_cust_info;
Create table Silver.crm_cust_info (
	cst_id int,
	cst_key nvarchar(50),
	cst_firstname nvarchar(50),
	cst_lastname nvarchar(50),
	cst_material_status nvarchar(50),
	cst_gndr nvarchar(50),
	cst_create_date date
);

If object_id('Silver.crm_prd_info','U') is not null
	drop table Silver.crm_prd_info;
Create table Silver.crm_prd_info(
	prd_id int,
  cat_id nvarchar(50),
	prd_key nvarchar(50),
	prd_nm nvarchar(50),
	prd_cost int,
	prd_line nvarchar(50),
	prd_start_dt datetime,
	prd_end_dt datetime
);

If object_id('Silver.crm_sales_details','U') is not null
	drop table Silver.crm_sales_details;
Create table Silver.crm_sales_details(
	sls_ord_num nvarchar(50),
	sls_prd_key nvarchar(50),
	sls_cust_id int,
	sls_order_dt int,
	sls_ship_dt int,
	sls_due_dt int,
	sls_sales int,
	sls_quantity int,
	sls_price int
);

If object_id('Silver.erp_cust_az12','U') is not null
	drop table Silver.erp_cust_az12;
Create table Silver.erp_cust_az12 (
	cid nvarchar(50),
	bdate date,
	gen nvarchar(50)
);

If object_id('Silver.erp_loc_a101','U') is not null
	drop table Silver.erp_loc_a101;
Create table Silver.erp_loc_a101 (
	cid nvarchar(50),
	cntry nvarchar(50)
);

If object_id('Silver.erp_px_cat_g1v2','U') is not null
	drop table Silver.erp_px_cat_g1v2;
Create table Silver.erp_px_cat_g1v2 (
	id nvarchar(50),
	cat nvarchar(50),
	subcat nvarchar(50),
	maintenance nvarchar(50)
);
