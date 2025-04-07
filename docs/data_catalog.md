# **Katalog Data untuk Gold Layer**  

## **Ringkasan**  
Gold Layer adalah representasi data pada tingkat bisnis yang telah terstruktur untuk mendukung analisis dan pelaporan. Lapisan ini terdiri dari **tabel dimensi** dan **tabel fakta** yang digunakan untuk mengukur metrik bisnis utama.  

---

## **1. gold.dim_customers**  
**Tujuan:**  
Menyimpan informasi pelanggan yang telah diperkaya dengan data demografi dan geografis.  

**Kolom:**  

| Nama Kolom       | Tipe Data      | Deskripsi |
|------------------|---------------|-----------|
| `customer_key`   | INT           | Kunci pengganti (surrogate key) yang secara unik mengidentifikasi setiap pelanggan. |
| `customer_id`    | INT           | Identifikasi unik numerik yang diberikan kepada setiap pelanggan. |
| `customer_number`| NVARCHAR(50)  | Kode alfanumerik unik yang digunakan untuk melacak dan mereferensikan pelanggan. |
| `first_name`     | NVARCHAR(50)  | Nama depan pelanggan sesuai dengan data sistem. |
| `last_name`      | NVARCHAR(50)  | Nama belakang atau nama keluarga pelanggan. |
| `country`        | NVARCHAR(50)  | Negara tempat tinggal pelanggan (misalnya, 'Indonesia'). |
| `marital_status` | NVARCHAR(50)  | Status pernikahan pelanggan (misalnya, 'Menikah', 'Lajang'). |
| `gender`         | NVARCHAR(50)  | Jenis kelamin pelanggan (misalnya, 'Laki-laki', 'Perempuan', 'n/a'). |
| `birthdate`      | DATE          | Tanggal lahir pelanggan dalam format YYYY-MM-DD (misalnya, 1985-07-23). |
| `create_date`    | DATE          | Tanggal saat data pelanggan pertama kali dibuat di sistem. |

---

## **2. gold.dim_products**  
**Tujuan:**  
Menyimpan informasi tentang produk beserta atributnya.  

**Kolom:**  

| Nama Kolom             | Tipe Data     | Deskripsi |
|------------------------|--------------|-----------|
| `product_key`         | INT          | Kunci pengganti (surrogate key) yang secara unik mengidentifikasi setiap produk. |
| `product_id`          | INT          | Identifikasi unik yang diberikan pada produk untuk keperluan pencatatan. |
| `product_number`      | NVARCHAR(50) | Kode alfanumerik unik untuk mengelompokkan atau menginventarisasi produk. |
| `product_name`        | NVARCHAR(50) | Nama produk beserta detail seperti tipe, warna, dan ukuran. |
| `category_id`         | NVARCHAR(50) | Identifikasi unik untuk kategori produk, menghubungkan ke klasifikasi yang lebih tinggi. |
| `category`           | NVARCHAR(50) | Kategori umum produk (misalnya, Sepeda, Komponen) untuk pengelompokan. |
| `subcategory`        | NVARCHAR(50) | Subkategori yang lebih spesifik dalam kategori produk. |
| `maintenance_required` | NVARCHAR(50) | Menunjukkan apakah produk memerlukan perawatan (misalnya, 'Ya', 'Tidak'). |
| `cost`               | INT          | Biaya atau harga dasar produk dalam satuan mata uang tertentu. |
| `product_line`       | NVARCHAR(50) | Seri atau lini produk tertentu (misalnya, Sepeda Gunung, Sepeda Balap). |
| `start_date`         | DATE         | Tanggal mulai produk tersedia untuk dijual atau digunakan. |

---

## **3. gold.fact_sales**  
**Tujuan:**  
Menyimpan data transaksi penjualan untuk kebutuhan analisis.  

**Kolom:**  

| Nama Kolom     | Tipe Data     | Deskripsi |
|---------------|--------------|-----------|
| `order_number`  | NVARCHAR(50)  | Identifikasi unik untuk setiap pesanan penjualan (misalnya, 'SO54496'). |
| `product_key`   | INT           | Kunci pengganti yang menghubungkan pesanan dengan tabel dimensi produk. |
| `customer_key`  | INT           | Kunci pengganti yang menghubungkan pesanan dengan tabel dimensi pelanggan. |
| `order_date`    | DATE          | Tanggal saat pesanan dibuat. |
| `shipping_date` | DATE          | Tanggal saat pesanan dikirim ke pelanggan. |
| `due_date`      | DATE          | Tanggal jatuh tempo pembayaran pesanan. |
| `sales_amount`  | INT           | Total nilai transaksi untuk satu item dalam satuan mata uang. |
| `quantity`      | INT           | Jumlah unit produk yang dipesan dalam satu transaksi. |
| `price`        | INT           | Harga per unit produk dalam satuan mata uang. |

---

Dokumentasi ini dirancang untuk membantu memahami struktur data dalam **Gold Layer**, sehingga mempermudah analisis dan pelaporan bisnis.
