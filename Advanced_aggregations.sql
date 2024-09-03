--find the total sales across all orders
select 
	ProductID,
	OrderDate,
Sum(Sales)over(Partition by ProductID) TotalSales
 from Sales.Orders


/* find the total sales across all order and find the total sales by  each product 
 Additionally provide details such order id , order date and  sales
  find the total sales for each combination of product and order status*/



  select 
	  OrderID,
	  ProductID, 
	 OrderDate,
	 OrderStatus,
	 Sales,
	 sum(Sales) over() TotalSales ,
	 sum(Sales) over(partition by ProductID) TotalSalesProducts,
	sum(Sales) over(partition by ProductID , OrderStatus) 
 from Sales.Orders





 ---* Rank each order based on their sales from highest to lowest and provide dateils such order id and order date


  select 
	OrderID,
	OrderDate,
	Sales,
	RANK()over(Order by Sales )
 from Sales.Orders




 select 
	 OrderID,
	 OrderDate,
	 Sales,
	 sum(Sales) over(partition by OrderStatus  order by  OrderDate
	 Rows Between current row and 2 following ) TotalSales
 from Sales.Orders




  select 
	 OrderID,
	 OrderDate,
	 Sales,
	 sum(Sales) over(partition by OrderStatus  order by  OrderDate
	 Rows  2 preceding   ) TotalSales
	 from Sales.Orders




  -- Rank customers based on their total sales
  select 
	  CustomerID,
	  sum(Sales),
	  Rank () over (order by sum(Sales) Desc ) Rank_CUS
from Sales.Orders
group by CustomerID



--     Count Cses Calse
-- 1- over all and categery analysis


-- find the total number of orders 
-- find the total number of Each customers
-- additionally provide details such order id  & order date 



select 
	orderID, 
	OrderDate,
	CustomerID,
	count(*) over()numberOR,
	count (OrderID)over(partition by CustomerID) OrederByCustomer
from sales.Orders


--


-- find the total number of customers 
-- find the total number of scores for the customers 
--additionally all Details of customers 

 select *, 
	 count(*) over() TotalNumberOfCus,
	 count (Score) over() TotalNumberOFscore
from Sales.Customers



 --  3-Check whether the tabe orders contains any duplicate rows 
 -- it must do it in PK



 select 
	 OrderID,
	 count(OrderID) over ( partition by OrderID) checkDup
 from Sales.Orders 



 -- in order to make Dup values on list we will use sub_Query

 select 
 *
 from
 (
 Select 
	  OrderID,
	 count(OrderID) over ( partition by OrderID) checkDup
from Sales.OrdersArchive
 )t where checkDup >1



 /* Find the total sales across all orders and the total sales for each product  
 Additionally , provide details such as order id and order date */

 --* group-wise analysis , to understand patterns within different categories *--


 select 
	 OrderID,
	 OrderDate,
	 ProductID,
	 Sales,
	 sum(Sales) over() TotalSalesByorder,
	 sum(Sales) over(partition by ProductID) TotalSalesByProduct
 from Sales.Orders

 


 -- Find the percentage contributtion of each product's sales to the total sales
 --* part-to-whole : shows the contribution of each data point to the overall dataset *--




 select 
	 OrderID,
	 OrderDate,
	 ProductID,
	 Sales,
	 sum(Sales) over() TotalSales,
	  round(cast(Sales as float) /sum(Sales) over() *100,2) PercentageSales
 from Sales.Orders



 /* Find the average sales across all orders and the average sales for each product  
 Additionally , provide details such as order id and rder date */
 --* The purpose of AVG sales across all for  overall analysis Quick summary or snapshot of the entire dataset *--
 --* The purpose of AVG sales per products is Total  per Group group -wise analysis to understand patterns within different categories *--



 select 
	 OrderID,
	 OrderDate,
	 productID,
	 Sales,
	 avg(coalesce(Sales,0)) over()TotalAvg,
	  avg(coalesce(Sales,0)) over(partition by ProductID) AvgSalesByProduct
 from Sales.Orders 




 -- Find the average scores of customers Additionally ,provide details such as customer ID and Last name 



 Select 
 CustomerID,
LastName,
Score,
AVG(Score)Over () uncorrectAVg,
AVG(Coalesce (Score,0)) over() AvgScoreByCTR 
 from Sales.Customers



 -- Find all orders where sales are higher than the averager sales across all orders 
 --- tip in order to make Filter on window function it shoud use SUB-Query __
 --* compare to average Helps to evaluate whether a velue is above or below The average *--



 select *
 from 
 (
	 select 
	 OrderID,
	ProductID,
	Sales,
	AVG(Sales) over() AvgSales
 from Sales.Orders
 )t where Sales > AvgSales



 /* Find the highest &  lowest sales across all orders and the highset& lowest sales for each product 
 Additionally , provider details duch as order id and  order date */
  --* The purpose of  across all for  overall analysis Quick summary or snapshot of the entire dataset *--
 --* The purpose of AVG sales per products is Total  per Group group -wise analysis to understand patterns within different categories *--



 select
	 OrderID,
	 OrderDate,
	 ProductID,
	 Sales,
	 max(Sales)over() HighestSales,
	 MIN(coalesce (sales,0)) over() LowestSales,
	 max(Sales)over(partition by ProductID ) HighestSalesByProducts,
	 MIN(coalesce (sales,0)) over(partition by ProductID) LowestSalesByProduct
 from Sales.Orders




 -- Calculate the deviation of each sale from both the minimum and maximum sales amounts 
 --* compare to extremes help th evaluate how well a value is performing relative to the extrames *--




 Select 
	 OrderID,
	 ProductID,
	 Sales,
	 max(Sales) over()highestSales,
	 min(Sales) over()LowestSales ,
	 max(Sales) over() - Sales DeviationHighestSales,
	 Sales-  min(Sales) over()DeviationLowestSales
 from Sales.Orders





 -- Show the employees who have the highest Salaries




 Select
 *
 from
 (
	 Select 
	 * ,
	max(Salary)over()HighestSalary
	 from Sales.Employees
)t where Salary = HighestSalary



-- calculate the moving average of sales for each product over time
-- calculate the moving average of sales for each product over time ,including only the next order



Select 

	OrderID,
	OrderDate,
	ProductID,
	Sales,
	avg(Sales) over (partition by ProductID ) AvgSales,
	avg(Sales) over (partition by ProductID Order by OrderDate ) MovingAvg,
	avg(Sales) over (partition by ProductID Order by OrderDate rows between current row and 1 following ) RollingAvg

from Sales.Orders
