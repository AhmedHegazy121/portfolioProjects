
/*  Heap

	Fast inserts [for staging tables] 

*/


/* Clustered index >> OLTP

For Primary keys if not , then for date columns

*/


/* ColumnStore index >> OLAP

	For Analytical Queries Reduce Size of large Table

*/

/* Non-Clustered index

	For non_PK columns(Foreign keys m joins, and Filters)

*/

/*Filtered index 

	target subset of data Reduce size of index

*/

/*unique index

	Enforce uniqueness improve query speed

*/

use AdventureWorksDW2022
-- HEAP without any index 
select * 
into factInernetSales_HP
from FactInternetSales

--Rowstore gonna store by row by row
select * 
into factInernetSales_RS
from FactInternetSales

create clustered index idx_factInernetSales_RS_PK
on factInernetSales_RS(SalesOrderNumber , SalesOrderLineNumber)

-- columnstore gonna store column by column

select * 
into factInernetSales_CS
from FactInternetSales
create clustered Columnstore index idx_factInernetSales_CS_PK
on factInernetSales_CS

/*
Storage Efficiency
1- ColumnStore index > is the best less Data space above all
2- Heap Tabel > only space for actual data
3-RowStore Culstered index  > the worst  actual space for the data and increase for index
*/

select * 
into DBCustomers
from Sales.Customers

-- primary key PK automatically creates  a culstered index by default 
--tip :: the name of the index should be inx_name of table_column name 
--role:: only  one clustered index can create per table 

create Clustered index idx_DBCustomers_CustomerID  on  dbo.DBCustomers (CustomerID)

-- if you have Duplicated in the column  use nonClustered if Duplicated is allow in the table 

Create nonclustered index idx_DBcutomer_lastname on dbo.DBcustomers (lastname)

Select *

from dbo.dbcustomers
where Country = 'USA' and Score >5000



-- if we wanna speed this query will use nonclustered index
-- Rule the columns of index order must match the order in your query
-- left most prefix rule -- index works only if your query filters start from the first colum int index and follow its oreder
 
 
 create index idx_dbcustomers_countryScore 
 on dbo. DBCustomers(Country , Score)  -- country first as in where clase 


 -- understanding the non clustered index works
 --we have a list of A, B ,C ,N
 --index will be used
 a
 a,b
 a,b,c


 --index won't be used
 B
 A,C
 A,B,N


-- ColumnSore index 
-- highly efficient with compression >> soter
-- fast read performance slow write preformance 
-- OLAP data warehouse, business intelligance, reporting , analyticls
-- best at aggregation
 ---in column store index we just do an one it is not support two but an other sql it work

 Drop index[idx_DBCustomers_CustomerID] on dbo.DBcustomers
 create clustered columnstore index dx_dbcustomer on dbo.DBcustomers

 --only one columnstore  index in table nonclustered or clustered

 create nonclustered columnstore index dx_dbcustomer_firstName on dbo.DBcustomers(Firstname)


 -- UNIQE 
 --Performance 
 -- writting from unique index is slower than non_unique
 -- Reading  from unique index is faster than non_unique 
 -- Duplictes in the columns will prevent creating a unique index
 




 select * from Sales.Products 

 Create unique nonclustered index  IDX_product_category on sales.products(Category)

 --EEROR cause there are duplicate key or vlaue but you can still create this index if the table is empty to make not allowed to make any duplicate  


--it will work cause product column has unique values 
 Create unique nonclustered index  IDX_product_Product on sales.products(Product)

 --- so if we want to add Duplicate value into the table UNIQUE INDEX won't allow us to do that 
 insert into Sales.Products(ProductID,Product) values (106,'Caps')

 -- filtered index
 -- Rules :: 
 -- you cannot create a filtered index on a clustered index.
 -- you cannot create a filtered index on a columnstore index. 
 
 -- if we fouce on only use 
 select * from Sales.Customers
 where Country ='USA'

 create nonclustered index idx_customers_country 
 on Sales.Customers(country)
 where country ='USA'



 --                              Index Management


--                    List all indexes on specific table 
sp_helpindex 'dbo.DBcustomers'

--                      Monitor index usage
--sys >>system schema contains metadata about database tables views indexes
--- metadata information it's like description of the tables views columnes
--Dynamic Managment view (DMV)>> Provides Real-time insights into database performance and system health
--benfits of drop index that not use at all  saved storage  , improved wrie performance



select * from sys.dm_db_index_usage_stats s

select

	tab.name as tableName ,
	inx.name as indexName ,
	inx.type_desc as indextype,
	inx.is_primary_key AS isPrimaryKey,
	inx. is_unique as isUnique,
	inx.is_disabled as isDisbled,
	s.user_seeks,
	s.user_scans,
	s.user_lookups,
	s.user_updates,
	coalesce(s.last_user_seek , s.last_user_scan)as lastUpdate
from sys.indexes inx
inner join sys.tables tab on
inx.object_id = tab.object_id
left join sys.dm_db_index_usage_stats s on
inx.object_id = s.object_id and inx.index_id = s.index_id 

order by tab.name , inx.name




-- Missing indexes >> this will stored in cach so if there is an restart it will be gone
--Tip EValuate the recommmendations before creating any index




Select 
	 fs.SalesOrderLineNumber
	 ,dp.EnglishProductName
	 ,dp.Color
from FactInternetSales fs
inner join  DimProduct Dp
on fs.ProductKey = dp.ProductKey
where dp.Color ='Black'




--checking for missing index 


select * from sys.dm_db_missing_index_details


-- Montir the Duplicate of index



select 
	tbl.name as TableName
	,col.name as IndexColumn
	,idx.name as IndxName
	,idx.type_desc as IndexType
	,Count(*) over(partition by tbl.name , col.name) ColumnCount
from sys.indexes idx
join sys.tables tbl on idx.object_id = tbl.object_id
join sys.index_columns  Ic on idx.object_id = Ic.object_id and idx.index_id =ic.index_id
JOIN  sys.columns col on ic.object_id = col.object_id and ic.column_id =col.column_id




--update Statistics
-- will gonna check the last update and the modification_counter if there is any number more than zero we should updateStatistics
Select 
	 SCHEMA_NAME(T.schema_id) as SchemaName 
	,t.name as TableName
	,s.name as StatisticsName
	,sp.last_updated as LastUpdate
	,DATEDIFF(DAY, SP.last_updated ,GETDATE()) AS LastUpdateDate
	,sp.rows as'Rows'
	,sp.modification_counter as ModificationSinceLastUpdate

from sys.stats as s
join sys.tables t
on s.object_id = t.object_id
Cross Apply sys.dm_db_stats_properties (S.object_id,s.stats_id) as sp
order by sp.modification_counter DESC;




-- use cases of update Statistics
-- 1- weekly job to update statistics on weekends
-- 2- after Migrating Date

-- to update Statistics for spacific one 
update Statistics sales.products IDX_product_Product

-- update all tabel
update Statistics sales.products

--update all databse >>	 it will take so much time to be execute
EXEC sp_updatestats



--                          Fragmentation 
-- Unsed spaces to data pages
-- Data pages are out of order

--Fragmentation  Mothods
--Reorganize
--Defragments leaf to keep them sorted
-- Light operation
-- Rebuild
--Recreates index from Scratch
-- Heavy Operation




--- check Fragmentation
Select *
from sys.dm_db_index_physical_stats(DB_ID(),null, null, null , 'LIMITED')



-- avg_Fragmentation_in_percent >> indicate how _of_order pages are within the index
--if avg_Fragmentation_in_percent >> 0% means no fragmentation(perfect)
-- if avg_Fragmentation_in_percent >> 100% means index is completely (Out of order)





select
	tab.name as tableName ,
	inx.name as indexName ,
	inx.type_desc as indextype,
	frg.avg_fragmentation_in_percent,
	frg.page_count
from sys.indexes inx
inner join sys.tables tab on
inx.object_id = tab.object_id
 left join sys.dm_db_index_usage_stats s on
inx.object_id = s.object_id and inx.index_id = s.index_id
inner join sys.dm_db_index_physical_stats(DB_ID(),null, null, null , 'LIMITED') Frg
on Frg.object_id =tab.object_id
order by frg.avg_page_space_used_in_percent DESC



/*
when to Deframent?
< 10% no action needed
10-30 % Reorganize
> 30% Rebuild
*/



Alter index PK__Customer__A4AE64B87FC20A48 on sales.customers Reorganize

Alter index PK__Customer__A4AE64B87FC20A48 on sales.customers Rebuild








--                                    Execution plan
-- Roadmap Generated by a database on how it will execute your query step by step


--               Estimated Execution plan
--prdicts the execution plan without actually the query


---              Acual Execution plan
--- shows the execution plan as it occurred after running the query

----              live Execution plan
---- shows the real-time execution flow as the query runs


----              estimated vs Actual plans 
/*if the prdictions don't match the actual Excution plan
this indicated issuses like inaccurate statistics or
outdated indexes leading to poor performance */


----                 Table Scan
------  Reads the entire table, page by page and row by row
-- "everything" which can lead to slower query performance on large tables.


-----                 Index scan 
----- Scans all data in an index to find matching rows


select * from dbo.FactResellerSales_HP


-- heaps vs . Clustered index 
--tip
--- afrer creating a new index , check the ececution plan to see if your query uses the index


Select *

from FactResellerSales
where CarrierTrackingNumber= '4911-403C-98'

Create nonclustered index idx_FactReseller_CTA
on FactResellerSales(CarrierTrackingNumber)

-- now will see INDEX SEEK 
-- A targeted search within an index , retrieving only specific rows
-- types of SCan 
/*
                                     types of SCan 
Table Scan : Reads every row in a table >>> Heap. the bad one
index Scan : reads all entries in an index to find results >>>>> Clustered Index. the middle
idex  See k : Quickly locates specific rows in an index >>>> NonCludtered Index. the best one
 */
 /*                       
							 key lookup

  that's mean that there are rows or data is not include in index or they don't have index so 
  SQL is gonna  create key lookup and nest between the index seek and key lookup to get our query
  */






 /* 
                                     join Algorithms

 Nested Loops: Compares Tables row by row ; best for small tables.
 Hash Match : Matches rows using a hash tables, best for  large tables.
 merge join: Merge two sorted tables, efficient when both are sorted. 
 */



 Select 
	 p.EnglishProductName,
	 SUM(s.SalesAmount) as TotalSales
 from FactResellerSales s
 join DimProduct p
 on p.ProductKey = s.ProductKey
 group by  p.EnglishProductName


 --- culsterd Columnstore index is better with aggregation

  Select 
	 p.EnglishProductName,
	 SUM(s.SalesAmount) as TotalSales
 from FactResellerSales_HP s
 join DimProduct p
 on p.ProductKey = s.ProductKey
 group by  p.EnglishProductName

 USE [AdventureWorksDW2022]
GO

/****** Object:  Index [idx_FactResellerSalesHP]    Script Date: 11/25/2024 6:31:45 AM ******/
DROP INDEX [idx_FactResellerSalesHP] ON [dbo].[FactResellerSales_HP]
GO
    


 Create Clustered columnstore index idx_FactResellerSalesHP on FactResellerSales_HP


 go 


 /*Sql HINTS commands you add to a query to force the database to run it in a specific way for better performance
 -- change the join type from nested loops to hash 
  # Tip 
 - we can not work with option and with function to gather.
 - Test hints in all project environments (DEV, PROD) as performance may vary.
 - hints are quick fices (Workround not solution) you still have to find the cause and fix it .
 
 
 */
 Select 
	o.Sales
	,c.Country
from SalesDB.Sales.Orders o
left join SalesDB.Sales.Customers c
on o.CustomerID = c. CustomerID
option (HASH join)

-- change the Index type from index scan  to forceseek

 Select 
	o.Sales
	,c.Country
from SalesDB.Sales.Orders o
left join SalesDB.Sales.Customers c with(ForceSeek)
on o.CustomerID = c. CustomerID


-- Force Sql to use specific index 

Select 
	o.Sales
	,c.Country
from SalesDB.Sales.Orders o
left join SalesDB.Sales.Customers c with(index([PK__Customer__A4AE64B87FC20A48]))
on o.CustomerID = c. CustomerID
