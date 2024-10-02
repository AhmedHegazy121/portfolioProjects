--Find the products that have a price higher than the average price of all products

--MainQuery
Select
	*
from
--SubQuery
(
	Select 
	ProductID,
	Product,
	Price,
	AVG (Price) over() avgprice
	from Sales.Products) t

Where Price > avgprice



-- Rank the customerss based on their total amount of sales


Select
	*,
	RANK()over(order by TotalSales Desc) CustomerRank
From
	(
	Select 
	O.CustomerID ,
	C.FirstName +' '+ c.LastName FullName,
	SUM(Sales) TotalSales
	from Sales.Orders  O 
	join Sales.Customers C on O.CustomerID =C.CustomerID
	group by O.CustomerID ,
	C.FirstName +' '+ c.LastName )t


-- Show the product IDs , names, prices and total number of orderes


select 
	ProductID,
	Product,
	Price,
	(select count (OrderID)from Sales.Orders) NrofOrders
from Sales.Products



-- Show all customer detailss and find the total orders for each customer.




Select
--   C.*, o.NrOrders
	C.CustomerID,
	C.FirstName +''+ C.LastName fullname,
	o.NrOrders
from Sales.Customers C 
left join (
	Select 
	CustomerID,
	Count (OrderID) NrOrders
	from Sales.Orders 
	group by CustomerID) o
on C.CustomerID  = o.CustomerID



--- Find the products that have a price highter than the average price of all products




Select 
	ProductID,
	Product,
	Price  
from Sales.Products Where Price > ( select avg(Price) from Sales.Products )





-- Show the details of orders made by customers in Germany



Select *
from Sales.Orders
where CustomerID in
	(Select CustomerID
	from Sales.Customers 
	where Country = 'Germany')


-- Show the details of orders made by customers  who are not from Germany



Select *
from Sales.Orders
where CustomerID in -- or NOT IN 
	(
	Select CustomerID
	from Sales.Customers 
	where Country <> 'Germany'
	)




-- Find female employees whose salaries are greater than the salaries of any male employees




select 
	FirstName +' '+LastName Fullname,
	Gender,
	Salary
from Sales.Employees
where Gender ='F' and Salary > any (Select Salary from Sales.Employees where Gender ='M')

-- Find female employees whose salaries are greater than the salaries of All male employees



select 
	FirstName +' '+LastName Fullname,
	Gender,
	Salary
from Sales.Employees
where Gender ='F' and Salary > all (Select Salary from Sales.Employees where Gender ='M')




-- Show all customer details and find the total oreders for each customer.
-- Correlated subquery.



select *, 
	(Select count(OrderID) from Sales.Orders o where o.CustomerID =c.CustomerID ) TotalOrder
from Sales.Customers C



-- Show the details of orders made by customers in Germany



Select * 
	

from Sales. Orders o

where  Exists (
	Select CustomerID,
	Country
	from Sales. Customers C
	where Country ='Germany'
	and o.CustomerID = c.CustomerID )


