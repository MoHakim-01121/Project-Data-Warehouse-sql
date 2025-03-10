/*
===============================================
Membuat Database dan Skemanya
===============================================
Tujuan Skrip:
  Skrip ini membuat database baru dengan nama 'DataWarehouse' setelah terlebih dahulu 
  memeriksa apakah database tersebut sudah ada. Jika database sudah ada, maka akan dihapus 
  dan dibuat ulang. Selain itu, skrip ini juga membuat tiga skema dalam database: 'bronze', 
  'silver', dan 'gold'.

Peringatan!!!:
  Menjalankan skrip ini akan menghapus seluruh database 'DataWarehouse' jika sudah ada.
  Semua data dalam database akan terhapus secara permanen. Harap berhati-hati dan pastikan 
  Anda memiliki cadangan data sebelum menjalankan skrip ini.
*/



USE MASTER;
Go

-- drop dan membuat ulang database 'DataWarehouse'
if exists (Select 1 from sys.databases where name = 'DataWarehouse')
begin
	alter database DataWarehouse set SINGLE_USER with rollback immediate;
	drop Database DataWarehouse;
end;
go


--	Membuat Database 'DataWarehouse'
CREATE DATABASE DataWarehouse;	

use DataWarehouse;

-- Membuat skema
CREATE SCHEMA bronze;
GO
CREATE SCHEMA silver;
GO
CREATE SCHEMA gold;
GO
