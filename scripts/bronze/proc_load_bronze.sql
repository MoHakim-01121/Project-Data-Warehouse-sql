/*
=======================================================
Stored Procedure: Memuat Data ke Layer Bronze (sumber -> Bronze)
=======================================================
Tujuan Skrip:  
  Stored procedure ini digunakan untuk memuat data ke dalam skema 'bronze' dari file CSV eksternal.  
  Prosedur ini melakukan langkah-langkah berikut:  
  - Mengosongkan tabel di skema 'bronze' sebelum memuat data baru.  
  - Menggunakan perintah 'BULK INSERT' untuk memasukkan data dari file CSV ke dalam tabel bronze.  

Parameter:  
  Tidak ada.  
  Stored procedure ini tidak menerima parameter dan tidak mengembalikan nilai apa pun.  

Contoh Penggunaan:  
  EXEC bronze.load_bronze;
*/


CREATE OR ALTER PROCEDURE bronze.load_bronze AS
BEGIN
	DECLARE @start_time DATETIME, @end_time DATETIME, @batch_start_time DATETIME, @batch_end_time DATETIME
	BEGIN TRY
		SET @batch_start_time = GETDATE();
		PRINT '==============================================='
		PRINT 'Loading Lapisan Bronze'
		PRINT '==============================================='

		PRINT '-----------------------------------------------'
		PRINT 'Loading Tabel CRM'
		PRINT '-----------------------------------------------'

		SET @start_time = GETDATE();
		PRINT '>> Truncating Table: bronze.crm_cust_info'
		-- load tabel crm_cust_info
		TRUNCATE TABLE bronze.crm_cust_info
		PRINT '>> Inserting Data into: bronze.crm_cust_info'
		BULK INSERT bronze.crm_cust_info
		FROM 'C:\Users\ACER\OneDrive\Documents\dwh_project\datasets\source_crm\cust_info.csv'
		WITH (
			FIRSTROW = 2,
			FIELDTERMINATOR = ',',
			TABLOCK
		);
		SET @end_time = GETDATE();
		PRINT '>> Durasi Load: ' +  CAST (DATEDIFF(second,@start_time, @end_time) AS NVARCHAR) + ' Detik'
		PRINT '------------------'

		PRINT '>> Truncating Table: bronze.crm_prd_info'
		-- load tabel crm_prd_info
		TRUNCATE TABLE bronze.crm_prd_info
		PRINT '>> Inserting Data into: bronze.crm_prd_info'
		BULK INSERT bronze.crm_prd_info
		FROM 'C:\Users\ACER\OneDrive\Documents\dwh_project\datasets\source_crm\prd_info.csv'
		WITH (
			FIRSTROW = 2,
			FIELDTERMINATOR = ',',
			TABLOCK
		);
		PRINT '>> Durasi Load: ' +  CAST (DATEDIFF(second,@start_time, @end_time) AS NVARCHAR) + ' Detik'
		PRINT '------------------'

		PRINT '>> Truncating Table: bronze.crm_sales_details'
		-- load tabel crm_sales_details
		TRUNCATE TABLE bronze.crm_sales_details
		PRINT '>> Inserting Data into: bronze.crm_sales_details'
		BULK INSERT bronze.crm_sales_details
		FROM 'C:\Users\ACER\OneDrive\Documents\dwh_project\datasets\source_crm\sales_details.csv'
		WITH (
			FIRSTROW = 2,
			FIELDTERMINATOR = ',',
			TABLOCK
		);
		PRINT '>> Durasi Load: ' +  CAST (DATEDIFF(second,@start_time, @end_time) AS NVARCHAR) + ' Detik'
		PRINT '------------------'


		PRINT '-----------------------------------------------'
		PRINT 'Loading Tabel ERP'
		PRINT '-----------------------------------------------'

		PRINT '>> Truncating Table: bronze.erp_cust_az12'
		-- load tabel erp_cust_az12
		TRUNCATE TABLE bronze.erp_cust_az12
		PRINT '>> Inserting Data into: bronze.erp_cust_az12'
		BULK INSERT bronze.erp_cust_az12
		FROM 'C:\Users\ACER\OneDrive\Documents\dwh_project\datasets\source_erp\CUST_AZ12.csv'
		WITH (
			FIRSTROW = 2,
			FIELDTERMINATOR = ',',
			TABLOCK
		);
		PRINT '>> Durasi Load: ' +  CAST (DATEDIFF(second,@start_time, @end_time) AS NVARCHAR) + ' Detik'
		PRINT '------------------'

		PRINT '>> Truncating Table: bronze.erp_loc_a101'
		--load tabel erp_loc_a101
		TRUNCATE TABLE bronze.erp_loc_a101
		PRINT '>> Inserting Data into: bronze.erp_loc_a101'
		BULK INSERT bronze.erp_loc_a101
		FROM 'C:\Users\ACER\OneDrive\Documents\dwh_project\datasets\source_erp\LOC_A101.csv'
		WITH (
			FIRSTROW = 2,
			FIELDTERMINATOR = ',',
			TABLOCK
		);
		PRINT '>> Durasi Load Load: ' +  CAST (DATEDIFF(second,@start_time, @end_time) AS NVARCHAR) + ' Detik'
		PRINT '------------------'

		PRINT '>> Truncating Table: bronze.erp_px_cat_g1v2'
		--load tabel erp_px_cat_g1
		TRUNCATE TABLE bronze.erp_px_cat_g1v2
		PRINT '>> Inserting Data into: bronze.erp_px_cat_g1v2'
		BULK INSERT bronze.erp_px_cat_g1v2
		FROM 'C:\Users\ACER\OneDrive\Documents\dwh_project\datasets\source_erp\PX_CAT_G1V2.csv'
		WITH (
			FIRSTROW = 2,
			FIELDTERMINATOR = ',',
			TABLOCK
		);
		PRINT '>> Durasi Load: ' +  CAST (DATEDIFF(second,@start_time, @end_time) AS NVARCHAR) + ' Detik'
		PRINT '------------------'

		SET @batch_end_time = GETDATE();
		PRINT '============================'
		PRINT 'Loading Lapisan Broze Selesai'
		PRINT '		-Total Durasi Load: ' + CAST (DATEDIFF (SECOND, @batch_start_time, @batch_end_time) AS NVARCHAR) + ' Detik'
		PRINT '============================'

	END TRY
	BEGIN CATCH
		PRINT '=========================================='  
		PRINT 'TERJADI KESALAHAN SAAT MEMUAT LAPISAN BRONZE'  
		PRINT 'Pesan Kesalahan: ' + CAST (ERROR_MESSAGE() AS NVARCHAR);  
		PRINT 'Kode Kesalahan: ' + CAST (ERROR_NUMBER() AS NVARCHAR);  
		PRINT '=========================================='

	END CATCH
END
