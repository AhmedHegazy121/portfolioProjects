-- Find the running total of sales for each month.

--Creating a view.


Create View Sales.V_Monthly_Summary as (

Select 
	DATETRUNC(MONTH, OrderDate) as Month,
	SUM(Sales) TotalSales,
	Count(OrderID) TotalOrder,
	SUM(Quantity) TotalQuantity
from Sales.Orders
Group by DATETRUNC(MONTH, OrderDate)

)

Select * from sales.V_Monthly_Summary


Select 
	Month,
	TotalSales,
	SUM(TotalSales) over (Order by Month) RunningSales
from sales.V_Monthly_Summary


-- drop view

drop view V_Monthly_Summary ;

-----  update the view---

/*if OBJECT_ID('Sales.V_Monthly_Summar','view') is not null
drop view sales.V_Monthly_Summary ;
go*/


drop view Sales.V_Monthly_Summary;


Create View Sales.V_Monthly_Summary as (

Select 
	DATETRUNC(MONTH, OrderDate) as Month,
	SUM(Sales) TotalSales,
	Count(OrderID) TotalOrder,
	SUM(Quantity) TotalQuantity,
	AVG(Sales) AvgSales

from Sales.Orders
Group by DATETRUNC(MONTH, OrderDate)

)


-- Provide a view that combine details from orders, products , customers, and employees.


CREATE VIEW sales.V_DetailsOfAlltable AS (
  SELECT 
		o.OrderID,
		o.OrderDate,
		p.Product AS ProductName,
		p.Category,
		COALESCE(c.FirstName, '') + ' ' + COALESCE(c.LastName, '') AS CustomerName,
		COALESCE(e.FirstName, '') + ' ' + COALESCE(e.LastName, '') AS EmployeeName,
		e.Gender,
		e.Department,
		c.Country,
		o.Sales,
		o.Quantity
  FROM Sales.Orders o
  LEFT JOIN Sales.Products p 
    ON p.ProductID = o.ProductID
  LEFT JOIN Sales.Customers c 
    ON c.CustomerID = o.CustomerID
  LEFT JOIN Sales.Employees e 
    ON e.EmployeeID = o.SalesPersonID
);


-- provide a view for the EU Sales team that combines details from all tables and excludes data related to the USA.


create view V_EU_Sales as(
select 

		o.OrderID,
		o.OrderDate,
		p.Product AS ProductName,
		p.Category,
		COALESCE(c.FirstName, '') + ' ' + COALESCE(c.LastName, '') AS CustomerName,
		COALESCE(e.FirstName, '') + ' ' + COALESCE(e.LastName, '') AS EmployeeName,
		e.Gender,
		e.Department,
		c.Country,
		o.Sales,
		o.Quantity
  FROM Sales.Orders o
  LEFT JOIN Sales.Products p 
    ON p.ProductID = o.ProductID
  LEFT JOIN Sales.Customers c 
    ON c.CustomerID = o.CustomerID
  LEFT JOIN Sales.Employees e 
    ON e.EmployeeID = o.SalesPersonID
where Country <> 'USA'

)