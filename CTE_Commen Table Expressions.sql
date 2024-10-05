

-- Step 1 : Find the total sales per cusomer.

 With CTE_Total_Sale as
 (
 Select 
	CustomerID,
	SUM(Sales)  TotalSales
 from Sales.Orders
 Group by CustomerID
 )

 --step 2 : Find the last order date per customer.



 ,CTE_last_Date  as

 ( 
	Select 
	CustomerID,
	max(OrderDate)LastDate
	from Sales.Orders
	group by CustomerID
 )

--step 3: Rank Customers based on total sales per customer.

 , CTE_Customer_Rank as

 (
 Select 
 CustomerID,
 TotalSales,
 RANK()OVER(Order by TotalSales DESC) CustomerRank
 from CTE_Total_Sale
 )

 
 --Step 4 : Segment customers based on their total sales.
 ,
 Segment_Customers as
 (
Select
	CustomerID,
CASE
	WHEN TotalSales > 100 then 'High'
	WHEN TotalSales > 50 Then 'Medium'
	else'Low' end CustomerSegmet
from CTE_Total_Sale

 )

 Select 
	c.CustomerID,
	c.FirstName,
	c.LastName,
	ts.TotalSales,
	LastDate,
	CustomerRank,
	Segment.CustomerSegmet
 from Sales.Customers c

 left join CTE_Total_Sale Ts
	 on c.CustomerID = ts.CustomerID
left join CTE_last_Date  D 
	 on c.CustomerID = D.CustomerID
Left join CTE_Customer_Rank R
	on c.CustomerID = R.CustomerID
Left join Segment_Customers Segment
on c.CustomerID =Segment.CustomerID
order by CustomerRank;


--Generate a sequence of Numbers from 1 to 20.
-- pition (MAXRECURION 5000) to control how  many iterations are allowed

With sires as 
(
--Anchor Query   
Select
	1 as number
union all
-- Recursive Query  
Select
	number + 1
From sires
	where number < 20
)
--Main Query
SELECT 
	number
From sires ;


-- Show the employee hierarchy by displaying each employee's level within the organization.


With CTE_emp_hierarchy as(
Select 
	 EmployeeID,
	 FirstName, 
	 ManagerID,
	 1 as Level
from Sales.Employees
Where ManagerID  IS null

union all
Select 
	e.EmployeeID,
	e.FirstName, 
	e. ManagerID,
	ceh.Level + 1
from Sales.Employees e
inner join CTE_emp_hierarchy ceh
on e.ManagerID = ceh.EmployeeID

)

 Select *
 from CTE_emp_hierarchy