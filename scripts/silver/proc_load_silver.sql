/*
===============================================================================
Prosedur Tersimpan: Memuat Data ke Lapisan Silver (Bronze -> Silver)
===============================================================================
Tujuan:
    Prosedur ini menjalankan proses ETL (Extract, Transform, Load) untuk 
    memindahkan data dari skema 'bronze' ke skema 'silver'.
    
Apa yang dilakukan:
    - Mengosongkan tabel di skema Silver.
    - Memasukkan data yang sudah dibersihkan dan diproses dari Bronze ke Silver.
		
Parameter:
    Tidak ada. 
    Prosedur ini tidak menerima parameter atau mengembalikan nilai apa pun.

Cara Menggunakan:
    EXEC Silver.load_silver;
===============================================================================
*/


CREATE OR ALTER PROCEDURE silver.load_silver AS
BEGIN
	DECLARE @start_time DATETIME, @end_time DATETIME, @batch_start_time DATETIME, @batch_end_time DATETIME
	BEGIN TRY
		SET @batch_start_time = GETDATE();
		PRINT '=============================================='
		PRINT 'MEMUAT LAPISAN SILVER'
		PRINT '==============================================' + CHAR(10)

		PRINT '----------------------------------------------'
		PRINT 'MEMUAT TABEL CRM'
		PRINT '----------------------------------------------' + CHAR(10)

		SET @start_time = GETDATE();
		PRINT '>> MENGOSONGKAN Tabel : silver.crm_cust_info';
		TRUNCATE TABLE silver.crm_cust_info;
		PRINT '>> Memasukkan Data ke dalam : silver.crm_cust_info';
		
		INSERT INTO silver.crm_cust_info(
			cst_id,
			cst_key,
			cst_firstname,
			cst_lastname,
			cst_material_status,
			cst_gndr,
			cst_create_date
		)
		SELECT
			cst_id,
			cst_key,
			TRIM(cst_firstname) AS cst_firstname,
			TRIM(cst_lastname) AS cst_lastname,
			CASE 
				WHEN UPPER(TRIM(cst_material_status)) = 'S' THEN 'Single'
				WHEN UPPER(TRIM(cst_material_status)) = 'M' THEN 'Married'
				ELSE 'n/a'
			END AS cst_material_status, -- Normalisasi nilai status pernikahan agar mudah dibaca
			CASE 
				WHEN UPPER(TRIM(cst_gndr)) = 'F' THEN 'Female'
				WHEN UPPER(TRIM(cst_gndr)) = 'M' THEN 'Male'
				ELSE 'n/a' 
			END AS cst_gndr, -- Normalisasi nilai gender agar mudah dibaca
			cst_create_date
		FROM (
			SELECT *, ROW_NUMBER() OVER (PARTITION BY cst_id ORDER BY cst_create_date DESC) AS flag_last
			FROM bronze.crm_cust_info
			WHERE cst_id IS NOT NULL
		) t 
		WHERE flag_last = 1 -- Memilih data terbaru dari customer
		
		SET @end_time = GETDATE();
		PRINT '>> Durasi Load :' + CAST(DATEDIFF(SECOND, @start_time, @end_time) AS VARCHAR) + ' Detik'
		PRINT '----------------------------------------------' + CHAR(10)

		SET @start_time = GETDATE();
		PRINT '>> MENGOSONGKAN Tabel : silver.crm_prd_info';
		TRUNCATE TABLE silver.crm_prd_info;
		PRINT '>> Memasukkan Data ke dalam : silver.crm_prd_info';
		
		INSERT INTO silver.crm_prd_info(
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
			REPLACE(SUBSTRING(prd_key, 1, 5), '-', '_') AS cat_id, -- Mengekstrak ID kategori
			SUBSTRING(prd_key, 7, LEN(prd_key)) AS prd_key, -- Mengekstrak kunci produk
			prd_nm,
			ISNULL(prd_cost, 0) AS prd_cost,
			CASE UPPER(TRIM(prd_line)) 
				WHEN 'M' THEN 'Mountain'
				WHEN 'R' THEN 'Road'
				WHEN 'S' THEN 'Other Sales'
				WHEN 'T' THEN 'Touring'
				ELSE 'n/a'
			END AS prd_line, -- Mengubah kode product line menjadi nilai deskriptif
			CAST(prd_start_dt AS DATE) AS prd_start_dt,
			CAST(LEAD(prd_start_dt) OVER (PARTITION BY prd_key ORDER BY prd_start_dt) - 1 AS DATE) AS prd_end_dt -- Menghitung tanggal akhir sebagai satu hari sebelum tanggal mulai berikutnya
		FROM bronze.crm_prd_info
		
		SET @end_time = GETDATE();
		PRINT '>> Durasi Load :' + CAST(DATEDIFF(SECOND, @start_time, @end_time) AS VARCHAR) + ' Detik'
		PRINT '----------------------------------------------' + CHAR(10)

		        -- Loading crm_sales_details
        SET @start_time = GETDATE();
		PRINT '>> Truncating Table: silver.crm_sales_details';
		TRUNCATE TABLE silver.crm_sales_details;
		PRINT '>> Inserting Data Into: silver.crm_sales_details';
		INSERT INTO silver.crm_sales_details (
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
			CASE 
				WHEN sls_order_dt = 0 OR LEN(sls_order_dt) != 8 THEN NULL
				ELSE CAST(CAST(sls_order_dt AS VARCHAR) AS DATE)
			END AS sls_order_dt,
			CASE 
				WHEN sls_ship_dt = 0 OR LEN(sls_ship_dt) != 8 THEN NULL
				ELSE CAST(CAST(sls_ship_dt AS VARCHAR) AS DATE)
			END AS sls_ship_dt,
			CASE 
				WHEN sls_due_dt = 0 OR LEN(sls_due_dt) != 8 THEN NULL
				ELSE CAST(CAST(sls_due_dt AS VARCHAR) AS DATE)
			END AS sls_due_dt,
			CASE 
				WHEN sls_sales IS NULL OR sls_sales <= 0 OR sls_sales != sls_quantity * ABS(sls_price) 
					THEN sls_quantity * ABS(sls_price)
				ELSE sls_sales
			END AS sls_sales, -- Recalculate sales if original value is missing or incorrect
			sls_quantity,
			CASE 
				WHEN sls_price IS NULL OR sls_price <= 0 
					THEN sls_sales / NULLIF(sls_quantity, 0)
				ELSE sls_price  -- Derive price if original value is invalid
			END AS sls_price
		FROM bronze.crm_sales_details;
        SET @end_time = GETDATE();
        PRINT '>> Load Duration: ' + CAST(DATEDIFF(SECOND, @start_time, @end_time) AS NVARCHAR) + ' seconds';
		PRINT '----------------------------------------------' + CHAR(10)

		PRINT '------------------------------------------------';
		PRINT 'MEMUAT TABEL ERP';
		PRINT '------------------------------------------------';

		SET @start_time = GETDATE();
		PRINT '>> MENGOSONGKAN Tabel : silver.erp_cust_az12';
		TRUNCATE TABLE silver.erp_cust_az12;
		PRINT '>> Memasukkan Data ke dalam : silver.erp_cust_az12';

		INSERT INTO silver.erp_cust_az12(
			cid,
			bdate,
			gen
		)
		SELECT
			CASE 
				WHEN cid LIKE 'NAS%' THEN SUBSTRING(cid, 4, LEN(cid)) -- Menghapus prefiks 'NAS' jika ada
				ELSE cid
			END AS cid,
			CASE 
				WHEN bdate > GETDATE() THEN NULL
				ELSE bdate
			END AS bdate, -- Menetapkan tanggal lahir di masa depan sebagai NULL
			CASE 
				WHEN UPPER(TRIM(gen)) IN ('F', 'FEMALE') THEN 'Female'
				WHEN UPPER(TRIM(gen)) IN ('M', 'MALE') THEN 'Male'
				ELSE 'n/a'
			END AS gen -- Normalisasi nilai gender dan menangani kasus tidak dikenal
		FROM bronze.erp_cust_az12
		
		SET @end_time = GETDATE();
		PRINT '>> Durasi Load :' + CAST(DATEDIFF(SECOND, @start_time, @end_time) AS VARCHAR) + ' Detik'
		PRINT '----------------------------------------------' + CHAR(10)

		        -- Loading erp_loc_a101
        SET @start_time = GETDATE();
		PRINT '>> MENGOSONGKAN Tabel : silver.erp_loc_a101';
		TRUNCATE TABLE silver.erp_loc_a101;
		PRINT '>> Memasukkan Data ke dalam : silver.erp_loc_a101';
		INSERT INTO silver.erp_loc_a101 (
			cid,
			cntry
		)
		SELECT
			REPLACE(cid, '-', '') AS cid, 
			CASE
				WHEN TRIM(cntry) = 'DE' THEN 'Germany'
				WHEN TRIM(cntry) IN ('US', 'USA') THEN 'United States'
				WHEN TRIM(cntry) = '' OR cntry IS NULL THEN 'n/a'
				ELSE TRIM(cntry)
			END AS cntry -- Normalize and Handle missing or blank country codes
		FROM bronze.erp_loc_a101;
	    SET @end_time = GETDATE();
        PRINT '>> Load Duration: ' + CAST(DATEDIFF(SECOND, @start_time, @end_time) AS NVARCHAR) + ' seconds';
		PRINT '----------------------------------------------' + CHAR(10)

				-- Loading erp_px_cat_g1v2
		SET @start_time = GETDATE();
		PRINT '>> MENGOSONGKAN Tabel : silver.erp_px_cat_g1v2';
		TRUNCATE TABLE silver.erp_px_cat_g1v2;
		PRINT '>> Memasukkan Data ke dalam: silver.erp_px_cat_g1v2';
		INSERT INTO silver.erp_px_cat_g1v2 (
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
		FROM bronze.erp_px_cat_g1v2;
		SET @end_time = GETDATE();
		PRINT '>> Load Duration: ' + CAST(DATEDIFF(SECOND, @start_time, @end_time) AS NVARCHAR) + ' seconds';
		PRINT '----------------------------------------------' + CHAR(10)


		SET @batch_end_time = GETDATE();
		PRINT '=============================================='
		PRINT 'MEMUAT LAPISAN SILVER SELESAI'
		PRINT '   - Total Durasi Load: ' + CAST(DATEDIFF(SECOND, @batch_start_time, @batch_end_time) AS NVARCHAR) + ' detik';
		PRINT '=============================================='
		
	END TRY
	BEGIN CATCH
		PRINT '=========================================='
		PRINT 'TERJADI KESALAHAN SAAT MEMUAT LAPISAN SILVER'
		PRINT 'Pesan Kesalahan: ' + ERROR_MESSAGE();
		PRINT 'Nomor Kesalahan: ' + CAST(ERROR_NUMBER() AS NVARCHAR);
		PRINT 'Status Kesalahan: ' + CAST(ERROR_STATE() AS NVARCHAR);
		PRINT '=========================================='
	END CATCH
END

EXEC silver.load_silver
