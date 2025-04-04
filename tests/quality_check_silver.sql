/*
===============================================================================
Pemeriksaan Kualitas Data
===============================================================================
Tujuan Skrip:
    Skrip ini melakukan berbagai pemeriksaan kualitas data untuk memastikan 
    konsistensi, keakuratan, dan standarisasi dalam lapisan 'silver'. 
    Pemeriksaan yang dilakukan meliputi:
    - Cek primary key yang null atau duplikat.
    - Cek spasi yang tidak diinginkan dalam kolom string.
    - Cek standarisasi dan konsistensi data.
    - Cek rentang tanggal yang tidak valid.
    - Cek konsistensi data antara kolom yang saling terkait.

Catatan Penggunaan:
    - Jalankan skrip ini setelah proses pemuatan data ke lapisan Silver.
    - Tindak lanjuti dan perbaiki jika ditemukan ketidaksesuaian.
===============================================================================
*/

-- ====================================================================
-- Pemeriksaan pada 'silver.crm_cust_info'
-- ====================================================================

-- Cek apakah ada primary key yang NULL atau duplikat
-- Harapan: Tidak ada hasil
SELECT 
    cst_id,
    COUNT(*) 
FROM silver.crm_cust_info
GROUP BY cst_id
HAVING COUNT(*) > 1 OR cst_id IS NULL;

-- Cek apakah ada spasi yang tidak diinginkan dalam kolom string
-- Harapan: Tidak ada hasil
SELECT 
    cst_key 
FROM silver.crm_cust_info
WHERE cst_key != TRIM(cst_key);

-- Cek standarisasi dan konsistensi data (contoh: status pernikahan)
SELECT DISTINCT 
    cst_marital_status 
FROM silver.crm_cust_info;

-- ====================================================================
-- Pemeriksaan pada 'silver.crm_prd_info'
-- ====================================================================

-- Cek apakah ada primary key yang NULL atau duplikat
-- Harapan: Tidak ada hasil
SELECT 
    prd_id,
    COUNT(*) 
FROM silver.crm_prd_info
GROUP BY prd_id
HAVING COUNT(*) > 1 OR prd_id IS NULL;

-- Cek apakah ada spasi yang tidak diinginkan dalam nama produk
-- Harapan: Tidak ada hasil
SELECT 
    prd_nm 
FROM silver.crm_prd_info
WHERE prd_nm != TRIM(prd_nm);

-- Cek apakah ada nilai NULL atau negatif pada harga produk
-- Harapan: Tidak ada hasil
SELECT 
    prd_cost 
FROM silver.crm_prd_info
WHERE prd_cost < 0 OR prd_cost IS NULL;

-- Cek standarisasi dan konsistensi data (contoh: kategori produk)
SELECT DISTINCT 
    prd_line 
FROM silver.crm_prd_info;

-- Cek apakah ada tanggal yang tidak valid (tgl mulai > tgl selesai)
-- Harapan: Tidak ada hasil
SELECT 
    * 
FROM silver.crm_prd_info
WHERE prd_end_dt < prd_start_dt;

-- ====================================================================
-- Pemeriksaan pada 'silver.crm_sales_details'
-- ====================================================================

-- Cek apakah ada tanggal yang tidak valid pada detail penjualan
-- Harapan: Tidak ada hasil
SELECT 
    NULLIF(sls_due_dt, 0) AS sls_due_dt 
FROM bronze.crm_sales_details
WHERE sls_due_dt <= 0 
    OR LEN(sls_due_dt) != 8 
    OR sls_due_dt > 20500101 
    OR sls_due_dt < 19000101;

-- Cek apakah tanggal pemesanan lebih besar dari tanggal pengiriman atau jatuh tempo
-- Harapan: Tidak ada hasil
SELECT 
    * 
FROM silver.crm_sales_details
WHERE sls_order_dt > sls_ship_dt 
   OR sls_order_dt > sls_due_dt;

-- Cek apakah total penjualan sesuai dengan jumlah x harga
-- Harapan: Tidak ada hasil
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
ORDER BY sls_sales, sls_quantity, sls_price;

-- ====================================================================
-- Pemeriksaan pada 'silver.erp_cust_az12'
-- ====================================================================

-- Identifikasi tanggal lahir di luar rentang yang diharapkan (1924 - hari ini)
-- Harapan: Tidak ada hasil
SELECT DISTINCT 
    bdate 
FROM silver.erp_cust_az12
WHERE bdate < '1924-01-01' 
   OR bdate > GETDATE();

-- Cek standarisasi dan konsistensi data (contoh: jenis kelamin)
SELECT DISTINCT 
    gen 
FROM silver.erp_cust_az12;

-- ====================================================================
-- Pemeriksaan pada 'silver.erp_loc_a101'
-- ====================================================================

-- Cek standarisasi dan konsistensi data (contoh: nama negara)
SELECT DISTINCT 
    cntry 
FROM silver.erp_loc_a101
ORDER BY cntry;

-- ====================================================================
-- Pemeriksaan pada 'silver.erp_px_cat_g1v2'
-- ====================================================================

-- Cek apakah ada spasi yang tidak diinginkan dalam kategori produk
-- Harapan: Tidak ada hasil
SELECT 
    * 
FROM silver.erp_px_cat_g1v2
WHERE cat != TRIM(cat) 
   OR subcat != TRIM(subcat) 
   OR maintenance != TRIM(maintenance);

-- Cek standarisasi dan konsistensi data (contoh: kategori perawatan)
SELECT DISTINCT 
    maintenance 
FROM silver.erp_px_cat_g1v2;
