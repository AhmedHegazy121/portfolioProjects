--Divide the Big Table into smaller partitions while still being treated as a single logical table.

/*--  partition Function
Define the logic on how to divide your data into partitions
Based on partition keys like (Column, Region)*/



--- step 1 : create a partition function
Create Partition function partitionByYear(Date)
as Range Left For Values ('2023-12-31','2024-12-31','2025-12-31')

-- Query lists all existing Partition Function
Select 
	name,
	type,
	type_desc,
	boundary_value_on_right
from sys.partition_functions



-- FileGroups
-- logical container of one or more data files to help organize  partitions

--Step 2 create fileGroups

Alter database [SalesDB] ADD FileGroup FG_2023;
Alter database [SalesDB] ADD FileGroup FG_2024;
Alter database [SalesDB] ADD FileGroup FG_2025;
Alter database [SalesDB] ADD FileGroup FG_2026;

--- if we need to delete it 
Alter database [SalesDB] Remove FileGroup FG_2023;


---Query lists all existing FileGroups
Select *
from sys.filegroups
where type = 'FG'
/*
Primary 
Default File group where all objects of a database of Stored
*/

/*
.NDF
file format is Secondary data files we have like primary and secondary in partitions we usually go with this format the ndf
*/

-- Step 3 : Add .ndf Files To each fileGroup

Alter database SalesDB Add File
(
	name = P_2023, -- logical Name
	FileName = 'C:\Program Files\Microsoft SQL Server\MSSQL16.SQLEXPRESS\MSSQL\DATA\P_2023.ndf'

) To filegroup FG_2023;


Alter database SalesDB Add File
(
	name = P_2024, -- logical Name
	FileName = 'C:\Program Files\Microsoft SQL Server\MSSQL16.SQLEXPRESS\MSSQL\DATA\P_2024.ndf'

) To filegroup FG_2024;



Alter database SalesDB Add File
(
	name = P_2025, -- logical Name
	FileName = 'C:\Program Files\Microsoft SQL Server\MSSQL16.SQLEXPRESS\MSSQL\DATA\P_2025.ndf'

) To filegroup FG_2025;



Alter database SalesDB Add File
(
	name = P_2026, -- logical Name
	FileName = 'C:\Program Files\Microsoft SQL Server\MSSQL16.SQLEXPRESS\MSSQL\DATA\P_2026.ndf'

) To filegroup FG_2026;


-- check
select 
	fg. name as FilegroupName,
	mf.name as logicalfileName,
	mf.physical_name as physicalFilePath,
	mf.size / 128 as SizeInMB

from
	sys.filegroups fg
join
	sys.master_files mf on fg.data_space_id = mf.data_space_id
where
	mf.data_space_id =DB_ID('SalesDB')

--Step 4 : Create partition scheme
-- sort  the filegroups according to the redult of the function's partitions.
--3 Boundaries = 4 partitions = 4 FileGroups\
--Maped the  partions to the File groups


Create partition scheme schemePartitionByYear
AS PARTITION partitionByYear
TO(FG_2023,FG_2024,FG_2025,FG_2026)


-- Query lists all Partition Scheme
SELECT
ps.name AS PartitionSchemeName,
pf.name AS PartitionFunctionName,
ds.destination_id AS PartitionNumber,
fg.name AS FilegroupName
FROM sys.partition_schemes ps
JOIN sys.partition_functions pf ON ps. function_id = pf. function_id
JOIN sys.destination_data_spaces ds ON ps.data_space_id = ds.partition_scheme_id
JOIN sys. filegroups fg ON ds.data_space_id = fg.data_space_id


--step 5 : Create the partition table

Create table sales.Orders_partittioned
(
	OrderID INT,
	OrderDate DATE,
	Sales INT

) ON SchemePartitionByYear (OrderDate)

insert into Sales.Orders_partittioned Values (1,'2023-05-15',100)
insert into Sales.Orders_partittioned Values (1,'2024-05-15',1000)
insert into Sales.Orders_partittioned Values (1,'2025-12-31',100)

Select * From Sales.Orders_partittioned


-- to check if the number of rows and be sure that recods get into the right tabel

SELECT
p.partition_number AS PartitionNumber,
f.name AS PartitionFilegroup,
p.rows AS NumberOfRows
FROM sys.partitions p
JOIN sys. destination_data_spaces dds ON p.partition_number = dds.destination_id
JOIN sys. filegroups f ON dds.data_space_id = f.data_space_id
WHERE OBJECT_NAME(p.object_id) = 'Orders_partittioned';


--partition Table The Performance
Select *
into sales.Orders_Nopartittioned
from Sales.Orders_partittioned

-- use partition number of rows to be read is 1 
select *
from Sales.Orders_partittioned
where OrderDate = '2025-12-31'

-- use without partition number of rows to be read is 3
select *
from Sales.Orders_Nopartittioned
where OrderDate = '2025-12-31'