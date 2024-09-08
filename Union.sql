-- Combine the data from employees and customers into one table 
Select 
	FirstName,
	LastName
from Sales.Employees
union 
Select 
	FirstName,
	LastName
from Sales.Customers


---- Combine the data from employees and customers into one table including duplicates

Select
	FirstName,
	LastName
from Sales.Employees
union All
Select 
 
	FirstName,
	LastName
from Sales.Customers


-- find employees who are not customers at the same time
--Data completeness check : Except oprator can be used to compare tables to detect discrepancies between databases

Select 
	FirstName,
	LastName
from Sales.Employees
Except 
Select 
	FirstName,
	LastName
from Sales.Customers



-- Find empoyees who are also customers


Select 
	FirstName,
	LastName
from Sales.Employees
intersect  
Select 
	FirstName,
	LastName
from Sales.Customers


-- use cases
--combine information : combine similar information before analyzing the Data .
-- Database developeres divide the data into multiple tables to optimize performance and archive old data 

-- Orders are stored in sparate tables (Orders and ordersArchive). combine all orders into one report without duplicates.

Select
	*
from Sales.Orders
union 
Select 
	*
from Sales.OrdersArchive

-- for best practices Never usa a asterisk (*) to combine tables, list needed columns instead
---- source flag : include additional column to indicate the sour of each row.

Select
       'order' as SourceTable 
	   ,[ProductID]
      ,[CustomerID]
      ,[SalesPersonID]
      ,[OrderDate]
      ,[ShipDate]
      ,[OrderStatus]
      ,[ShipAddress]
      ,[BillAddress]
      ,[Quantity]
      ,[Sales]
      ,[CreationTime]
from Sales.Orders
union 
Select 
	'ordersArchive' 
	  ,[ProductID]
      ,[CustomerID]
      ,[SalesPersonID]
      ,[OrderDate]
      ,[ShipDate]
      ,[OrderStatus]
      ,[ShipAddress]
      ,[BillAddress]
      ,[Quantity]
      ,[Sales]
      ,[CreationTime]
from Sales.OrdersArchive
order by ProductID
