-- Find the average scores of the customers.
SELECT [CustomerID]
      ,[FirstName]
      ,[LastName]
      ,[Score]
	  ,avg(Score) over() NullAvgScore
	  ,avg(coalesce(Score , 0)) over() Avgscore

FROM [Sales].[Customers]
 
 
 ---Display the full name of customrs in a single field 
 -- by merging theeir first and last names , 
 --and add 10 bouns pints to each customer's score.
 select
	 FirstName + '' +LastName  ,  -- with Null
	 FirstName + '' +Coalesce (LastName , '') FullName, -- convert null to empty string
	 Score + 10, -- with null
	 Coalesce (Score,0) + 10 ScoreWithBouns
FROM [Sales].[Customers]


-- Sort the customrs from lowest to highest scores, with nulls appearing last
-- method 1 Repalce the nulls with very big number
-- method 2 use case when

select 
	CustomerID,
	Score
	--coalesce( Score,999999999999999) score
	from Sales.Customers
order by case when Score is null then 1 else 0 end ,Score



-- Find  the sales price for each order by dividing the sales by quantity
-- to avoid Divide by zero error encountered will use nullif

select
	OrderID
	,Sales
	,Quantity
	, Sales / nullif( Quantity , 0) Price
from Sales.Orders

-- Identify the customres who have no scores
Select
	*
from Sales.Customers
where Score is null

-- List all customres who have score


Select
	*
from Sales.Customers
where Score is not null

-- list all details for customers who have not placed any orders.
Select
	c.*,
	o.OrderID

from Sales.Customers c
left join Sales.Orders o
on c.CustomerID = o.CustomerID

where OrderID is  null
