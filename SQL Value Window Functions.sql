
-- Time series analysis The process of analyzing the data to understand  patterns , trends , and behaviors over time
---- Years-over-Year(YoY)Analyze the overall Growth or decline of thebusiness's performance over time
-------month-over-month (MoM)-Analyze short-term trends and discover patterns in seasonality 


--Analyze the month-over-month (MoM) performonce by finding the percentage change in sales between the current and previous month

Select * ,
CurrentM - previousM  MoM_change ,
round (cast( (CurrentM - previousM) As float)/ previousM *100 ,1) MOM_precanage

From(
select
	MONTH(OrderDate) Ordermonth ,
	SUM(Sales) CurrentM,
	LAG(SUM(Sales))over(order by MONTH(OrderDate)) previousM
from Sales.Orders
group by MONTH(OrderDate) 
)t 


-- customers peteion analysis
-- Measure customer's behavior and loyalty to help busineeses build strong relationships with customers.
--Anaylze customer loyalty by ranking customers based on the average number of days between  orders
Select 
	CustomerID,
	AVG(DaysUntillNextOrder) AvgNextOrder,
	 RANK()Over(Order by Coalesce( AVG(DaysUntillNextOrder),99999999))RankAvg
from(
	Select 
	OrderID,
	CustomerID, 
	OrderDate CurrentDate,
	LEAD(OrderDate) over(partition by CustomerID order by OrderDate) NextDate,
	DATEDIFF(DAY,OrderDate ,LEAD(OrderDate) over(partition by CustomerID order by OrderDate)) DaysUntillNextOrder 
from  Sales. Orders)t
group by CustomerID


-- Find the  lowest and highest sales for each product 
-- we can use min and mix like  max(sales) over (partition by product)
-- we can use first value for highest and lowest change order by to DSC
-- Find the difference in sales between the current and the lowest saled 
---- -- use case compare to Extermes How well a value is performing relative to the extremes
select 
	ProductID ,
	Sales,
	FIRST_VALUE(Sales)over (partition by ProductID Order by Sales) LowestSale ,
	LAST_VALUE(Sales) over (partition by ProductID Order by Sales
	Rows between Current row and  unbounded following ) HighestSale,
	Sales - FIRST_VALUE(Sales)over (partition by ProductID Order by Sales) LowestToExtrame
from Sales.Orders
