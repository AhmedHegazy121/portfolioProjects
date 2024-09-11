-- Use  case :categorizing Data / Main purpose is data transformation derive new information create new columns based on existing data
-- Group the data into different categories based on certain conditions

/*
 Generate a report showing the total sales for each category :
High : if the sales higher than 50 
Medium : if the sales between 20 and 50 
Low : if the sale equal or  lower than 20 
Sort the categories frm highest sales to lowest */

Select 
	Category,
	sum(Sales) TotalSales
from
(
select
	OrderDate,
	sales ,
case 
	when Sales > 50 then 'High'
	when Sales > 20 then 'Medium'
	Else 'low'
end Category
from Sales.Orders ) t
group by Category
order by TotalSales Desc


-- Mapping : transform the values from one form to another

-- Retrieve employee details with gender displayed as full text
select * 
,case
	 when Gender ='M' Then'Male'
	 When Gender ='F' then 'Female'
end FullGender
from Sales.Employees

-- Retrieve customer details with abbreviated country code

Select 
Distinct Country
From Sales.Customers

Select
	Country,
Case
	when Country ='Germany' Then 'DE'
	When Country = 'USA' Then 'US'
end AbbreviatedCountry
from Sales.Customers


--Handling nullls : Replace Nulls with a specific value. 
--  Find average scores of customers and treat Nulls as 0 and additional provide details such customrID and lastname

Select 
	CustomerID,
	LastName, 
	Score,
case 
	when Score is null then 0
	Else Score 
end newScore, -- convert to zero
	avg(Score)over () avgScore,-- with null
avg(
 Case 
	 when Score is null then 0
	 else score
 end 
 ) over() AvgnewScore --counvert to zero
from Sales.Customers



-- conditional aggregation : apply aggregate functions only on subsets of data the fulfill certain conditions.
-- count how many times each customers has made an order with sales greater than 30.
-- Flag  binary indicator (1,0)to be summarized to show how many times the condition is true.
Select 
	CustomerID,
sum (case	
	when Sales > 30 then 1
	else 0
End )NrOfOrders,
	count(OrderID) NrOFAllOrders
	
from Sales.Orders
group by CustomerID