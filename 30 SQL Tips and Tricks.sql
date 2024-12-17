--               Filter Data with Great Preformance 

--===============================================================
--Tip 1: Select Olny what you need
-- ==============================================================

-- Bad practice all effect performance
Select * from SalesDB.Sales.Customers

--Good Practice Select what you need
Select CustomerID, FirstName  From SalesDB.Sales.Customers

--===============================================================
--Tip 2: Avoid unnecessary Distinct & Order BY
-- ==============================================================

-- Bad Practice
select distinct
	FirstName
from  SalesDB.Sales.Customers
order by FirstName


-- Good Practice
select 
	FirstName
from  SalesDB.Sales.Customers


--===============================================================
--Tip 3 : For EXploration  Purpose , limit Rows
-- ==============================================================


-- Bad Practice get us to  make it read all records
select 
	OrderID,
	Sales
from  SalesDB.Sales.Orders

-- Good Practice  only read TEN
select top 10
	OrderID,
	Sales
from  SalesDB.Sales.Orders


--===============================================================
--Tip 4 : Create nonclustered index on frequently used columns in where Clause
-- ==============================================================

Select * from SalesDB.Sales.Orders where OrderStatus = 'Delivered'

Create nonclustered index Idx_Orders_OrderStatus on SalesDB.Sales.Orders(OrderStatus)

--===============================================================
--Tip 5 : Avoid Applying functions to Columns in where Clauses
-- Functions on Columns can block index usage
-- ==============================================================
--Bad Practice
Select * from SalesDB.Sales.Orders
Where LOWER(OrderStatus) ='delivered'


Select*
from SalesDB.Sales.Customers
where SUBSTRING(FirstName,1,1)= 'A'

Select *
from SalesDB.Sales.Orders
where YEAR(OrderDate) = 2025

-- Good Practice
Select * from SalesDB.Sales.Orders
Where OrderStatus ='delivered'


Select *
from SalesDB.Sales.Customers
where FirstName like 'A%'


Select *
from SalesDB.Sales.Orders
where OrderDate between '2025-01-01' and '2025-12-31'

--===============================================================
--Tip 6: Avoid leading wildcards as they prevent idex usage
-- ==============================================================

-- Bad Practice
Select * 
from  SalesDB.Sales.Customers
where LastName like '%Gold%'

-- Good Practice
Select * 
from  SalesDB.Sales.Customers
where LastName like 'Gold%'



--===============================================================
--Tip 7: Use IN instead of Multiple OR
-- ==============================================================

-- Bad Practice
Select * 
from  SalesDB.Sales.Orders
where CustomerID = 1 or CustomerID =2 or CustomerID =3



-- Good Practice
Select * 
from  SalesDB.Sales.Orders
where CustomerID in (1,2,3)

--                                          Best Practice Joining Data


--===============================================================
--Tip 8: Understand the speed of joins & use inner jion when possible 
-- ==============================================================
--Best Performance
Select c.FirstName , o.OrderID from Sales.Customers c inner join Sales.Orders o on c.CustomerID = o.CustomerID
--- Slightly slower Performance
Select c.FirstName , o.OrderID from Sales.Customers c Right  join Sales.Orders o on c.CustomerID = o.CustomerID
Select c.FirstName , o.OrderID from Sales.Orders o left  join Sales.Customers c on c.CustomerID = o.CustomerID

-- Worst Performance
Select c.FirstName , o.OrderID from Sales.Customers c outer  join Sales.Orders o on c.CustomerID = o.CustomerID



--===============================================================
--Tip 9 : Use Explicit join (ANSI JOIN) instead of implicit join (Non_SNSI join)
-- ==============================================================

--Bad Practice
Select 
	o.OrderDate ,
	c.Country
from Sales.Customers c , Sales.Orders o
where c.CustomerID = o.CustomerID

--Best Practice
Select 
	o.OrderDate , 
	c.Country
from Sales.Customers c inner join Sales.Orders o
on  c.CustomerID = o.CustomerID

--===============================================================
--Tip 10: Make sure to index the columns used in the (ON) clause
-- ==============================================================

Select 
	c.CustomerID
	,o.Sales
from Sales.Orders o 
inner join Sales.Customers c
on c.CustomerID = o.CustomerID

Create nonclustered index idx_order_customerid on sales.orders(Customerid)




--===============================================================
--Tip 11 : Filter Before joining (Big Tables)
-- ==============================================================


-- Filter After Join (Where)
Select 
	c.CustomerID
	,o.Sales
from Sales.Orders o 
inner join Sales.Customers c
on c.CustomerID = o.CustomerID
where o.OrderStatus = 'Delivered'

-- Filter During Join (on)
Select 
	c.CustomerID
	,o.Sales
from	Sales.Orders o 
inner join	Sales.Customers c
on	c.CustomerID = o.CustomerID
and	 o.OrderStatus = 'Delivered'



-- Filter before Join (SubQuery)
Select 
	c.CustomerID
	, COUNT(o.OrderID)
from Sales.Customers c 
inner join (Select OrderID, CustomerID from Sales.Orders  where OrderStatus = 'Delivered') o
on c.CustomerID = o.CustomerID
group by c.CustomerID

--===============================================================
--Tip 12: Aggregate Befor Joining Tables (Big Tables)
-- ==============================================================
--Best Practic for Small-Medium Tables
--- Grouping and joining

Select 
	C.CustomerID,
	c.FirstName,
	COUNT(o.OrderID) TotalOrder
From	Sales.Customers c
inner	join Sales.Orders o 
on	o.CustomerID = c.CustomerID
group by C.CustomerID, c.FirstName


--Best Practice for Big Tables
--- Pre-aggregated and joining

Select 
	C.CustomerID,
	c.FirstName,
	o.TotalOrder

From Sales.Customers c -- Tip start with dim table in  from statement  that you want do the aggregation
inner	join (
 select
	 CustomerID, 
	 Count(OrderDate) TotalOrder
 from Sales.Orders
 Group by	CustomerID
) o
on	o.CustomerID = c.CustomerID


--Correlated Subquery
--Bad Practices
--Correlated Queries are inefficient because sql execute  aggreagations for evey row

Select
 CustomerID,
 FirstName,
 (select Count(OrderID) from Sales.Orders o
 Where c.CustomerID = o.CustomerID
 ) as orderCount
from Sales.Customers c

--===============================================================
--Tip 13: Use union instead of OR in join
-- ==============================================================

-- Bad Practice	
Select 
	c.FirstName
	,o.Sales
from Sales.Customers c
inner join Sales.Orders o
on c.CustomerID = o.CustomerID
or c.CustomerID = o.SalesPersonID

-- Best practice 

Select 
	c.FirstName
	,o.Sales
from Sales.Customers c
inner join Sales.Orders o
on c.CustomerID = o.CustomerID
union
Select 
	c.FirstName
	,o.Sales
from Sales.Customers c
inner join Sales.Orders o
on c.CustomerID = o.SalesPersonID

--===============================================================
--Tip 14 : Check for NESTED loops and use SQL Hints When necessary 
-- ==============================================================


Select 
	c.FirstName
	,o.Sales
from Sales.Customers c
inner join Sales.Orders o
on c.CustomerID = o.CustomerID

-- Good Practice for having Big table & Small table 
Select 
	c.FirstName
	,o.Sales
from Sales.Customers c
inner join Sales.Orders o
on c.CustomerID = o.CustomerID
option (hash join)

--===============================================================
--Tip 15 : Use UNION ALL instead of using UNION | duplicates are acceptable 
-- ==============================================================

-- Bad Practice
Select CustomerID from Sales.Orders
UNION
Select CustomerID from Sales.OrdersArchive

-- Best Practice
Select CustomerID from Sales.Orders
UNION ALL
Select CustomerID from Sales.OrdersArchive

--===============================================================
--Tip 16 :  Use UNION ALL + Distinct instead of using UNION | duplicates are Not acceptable 
-- ==============================================================

-- Bad Practice
Select CustomerID from Sales.Orders
UNION
Select CustomerID from Sales.OrdersArchive

-- Best Practice

Select
	Distinct CustomerID
from(
Select CustomerID from Sales.Orders
UNION All
Select CustomerID from Sales.OrdersArchive ) as CombinedDatA


---        Best Practices Aggregating Data

--===============================================================
--Tip 17 : use Columnstore index for Aggregations on large Table
-- ==============================================================

Select 
	CustomerID,
	COUNT(OrderID) TotalOrder
from Sales.Orders
group by  CustomerID


Create Clustered columnstore index indx_orders_orderdID on sales.orders


--===============================================================
--Tip 18 : Pre_Aggregate Data and store it  in new Table For Reporting
-- ==============================================================

Select 
 MONTH(OrderDate) OrderMonth,
 SUM(Sales) TotalSales
 into sales.SalesSummary
from Sales.Orders
group by  MONTH(OrderDate)




-- Best Practices SubQuereis

--===============================================================
--Tip 19 : Join , Exists ,  In
-- ==============================================================

-- JOIN (Best Practice : If the performance equals to EXISTS)
select
	o.OrderID
	,o.Sales
from Sales.Orders o
join Sales.Customers c
on  o.CustomerID  = c.CustomerID
where c.Country = 'USA'



-- EXISTS(Best Practice : USe it for large Tables)
-- Exists better than Join bexause, it stops at first match and avoid data dupliction

select
	o.OrderID
	,o.Sales
from Sales.Orders o
where exists (
     Select 1
     from Sales.Customers c
     Where o.CustomerID  = c.CustomerID
     AND c.Country = 'USA'
)

-- IN (Bad Practice) 
-- The IN iperator processes and evaluates all rows.
-- IT lacks and early exit mechanism
select
	o.OrderID
	,o.Sales
from Sales.Orders o
where o.CustomerID  in (
	Select CustomerID 
    from Sales.Customers 
	Where Country = 'USA'

)


--===============================================================
--Tip 20 : Avoid Redudant Logic in Your Query
-- ==============================================================
---- Note "Spot redundant queries'Review and fix them'"
-- Bad Practice
Select 
	EmployeeID 
	,FirstName 
	, 'Above Average' STATUS
from Sales.Employees
WHERE Salary > (SELECT AVG(Salary) FROM Sales.Employees )

UNION ALL 

Select 
	EmployeeID 
	,FirstName 
	, 'Below Average' STATUS
from Sales.Employees
WHERE Salary < (SELECT AVG(Salary) FROM Sales.Employees )

-- Good Practice
SELECT 
	EmployeeID,
	FirstName,
	CASE
		WHEN Salary > AVG(Salary) OVER() THEN 'Above Average'
		WHEN Salary < AVG(Salary) OVER() THEN 'Below Average'
		ELSE 'Average'
	END
FROM Sales.Employees


-----                     Best Practices Creating Tables(DDL) Data Defintion Language


--===============================================================
--Tip 21: Avoid Data Types Varchaart & TEXT
-- ==============================================================
Create table Customersingfo(
CustomerID int,
firstname  varchar (max),
country varchar(255),
TotalPurchases Float,
Score int , -- it changed from text to int
Birthdate Date, -- from varchar to date type
employeeid int 
constraint Fk_CustomersInfo_EmpoyeeID Foreign Key (EmpoyeeID)
references sales.empoyees (EmployeeID)
)

--===============================================================
--Tip 22: Avoid (MAX) unnecessarily large lenghts in data types
-- ==============================================================

Create table Customersingfo(
CustomerID int,
firstname  varchar (50),
country varchar(50),
TotalPurchases Float,
Score int , 
Birthdate Date, 
employeeid int 
constraint Fk_CustomersInfo_EmpoyeeID Foreign Key (EmpoyeeID)
references sales.empoyees (EmployeeID)
)


--===============================================================
--Tip 23 : Use the not NUll constraint where applicable
-- ==============================================================

Create table Customersingfo(
CustomerID int, 
firstname  varchar (50) not null,
country varchar(50) not null,
TotalPurchases Float,
Score int , 
Birthdate Date, 
employeeid int 
constraint Fk_CustomersInfo_EmpoyeeID Foreign Key (EmpoyeeID)
references sales.empoyees (EmployeeID)
)


--===============================================================
--Tip 24 : Ensure all your tables have  a Clusterd Primary key
-- ==============================================================


Create table Customersingfo(
CustomerID int Primary key clustered, 
firstname  varchar (50) not null,
country varchar(50) not null,
TotalPurchases Float,
Score int , 
Birthdate Date, 
employeeid int 
constraint Fk_CustomersInfo_EmpoyeeID Foreign Key (EmpoyeeID)
references sales.empoyees (EmployeeID)
)

--===============================================================
--Tip 25 :Create a non_clustered index for foreign keys that are used frquently
-- ==============================================================

Create nonclustered index ix_good _customeres_ employeeID 
ON customersinfo(employeeID)


---                          Best Practices indexing



--===============================================================
--Tip 26 : Avoid over indexing
--Tip 27 : Drop unused indexes
--Tip 28 : Update Statistics (Weekly)
--Tip 29 : Reorganize & Rebuild Indexes (Weekly)
--Tip 30 : partition Large Tables (Facts) To improve performance 
-- Next, apply a columnstore index for the best results 
-- ==============================================================


----                      Best Practices Final Thoughts

-- Focus on Writing Clear Queries
-- Optimize performance only when necessary
-- Always Test Using Execution Plan