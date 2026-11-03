/*
=============================================================================
DDL Script: Create Bronze Tables
=============================================================================
Script Purpose:
 This Script create tables in the 'Bronze" schema, dropping existing tables is they already exists.
 Run this script to redefine the DDL structure of 'Bronze' tables
=============================================================================
*/

If object_id('Bronze.crm_cust_info','U') is not null
	drop table Bronze.crm_cust_info;
Create table Bronze.crm_cust_info (
	cst_id int,
	cst_key nvarchar(50),
	cst_firstname nvarchar(50),
	cst_lastname nvarchar(50),
	cst_material_status nvarchar(50),
	cst_gndr nvarchar(50),
	cst_create_date date
);

If object_id('Bronze.crm_prd_info','U') is not null
	drop table Bronze.crm_prd_info;
Create table Bronze.crm_prd_info(
	prd_id int,
	prd_key nvarchar(50),
	prd_nm nvarchar(50),
	prd_cost int,
	prd_line nvarchar(50),
	prd_start_dt datetime,
	prd_end_dt datetime
);

If object_id('Bronze.crm_sales_details','U') is not null
	drop table Bronze.crm_sales_details;
Create table Bronze.crm_sales_details(
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

If object_id('Bronze.erp_loc_a101','U') is not null
	drop table Bronze.erp_loc_a101;
Create table Bronze.erp_loc_a101 (
	cid nvarchar(50),
	cntry nvarchar(50)
);

If object_id('Bronze.erp_cust_az12','U') is not null
	drop table Bronze.erp_cust_az12;
Create table Bronze.erp_cust_az12 (
	cid nvarchar(50),
	bdate date,
	gen nvarchar(50)
);
