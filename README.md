# Proyek Data Warehouse dan Analitik

Selamat datang di repositori Proyek Data Warehouse dan Analitik! 🚀
Proyek ini menunjukkan solusi data warehousing dan analitik yang komprehensif, mulai dari membangun data warehouse hingga menghasilkan wawasan yang dapat ditindaklanjuti. Dirancang sebagai proyek portofolio, proyek ini menyoroti praktik terbaik industri dalam rekayasa data dan analitik.

---
## Arsitektur Data

Arsitektur data dalam proyek ini mengikuti Medallion Architecture dengan tiga lapisan utama: **Bronze**, **Silver**, dan **Gold**.
![Data Architecture](docs/dwh.drawio.png)

1. **Lapisan Bronze**: Menyimpan data mentah apa adanya dari sistem sumber. Data diambil dari file CSV dan dimasukkan ke dalam database SQL Server.
2. **Lapisan Silver**: Melakukan proses pembersihan, standarisasi, dan normalisasi data agar siap untuk dianalisis.
3. **Lapisan Gold***: Berisi data yang telah siap digunakan untuk bisnis, dimodelkan dalam skema bintang (star schema) untuk kebutuhan pelaporan dan analitik.

---
