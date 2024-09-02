-- Rank the orders baseded on their sales from highest to lowest
select 
OrderID,
Sales,
Row_number() over (order by Sales DESC) RankSales,
Rank() over (order by Sales DESC) SharedRankSales,
Dense_rank() over (order by Sales DESC) DenseRankSales
from Sales.Orders

--*                         Top-N analysis                    *--
--        Analysis the top performers to do targeted marketing 
-- Find the top highet Sales for each product 


Select *
from
(
select 
OrderID,
ProductID,
Sales,
Row_number() over(partition  by ProductID order by Sales DESC) RankSales
from Sales.Orders ) t where RankSales = 1


--*                      Bottom-N Analysis                 *--
--  help analysis the underperformance to manage Risks and to do optimizations --
--   Find the lowest 2 customers based on their total sales
SELECT *
FROM (
    SELECT 
        CustomerID, 
        SUM(Sales) AS TotalSales,
        ROW_NUMBER() OVER (ORDER BY SUM(Sales) ASC) AS BottomCtrSales
    FROM Sales.Orders
    GROUP BY CustomerID 
) t 
WHERE BottomCtrSales <= 2;


-- Assign new IDs to the row of the orders archive table 

select
ROW_NUMBER() over(order by OrderID) OrdersArchiveID
,* 
from sales.OrdersArchive


--- Identify duplicate rows in the table orders Archive and return a clean result without any duplicates 


Select * from (

select

ROW_NUMBER() over(partition  by OrderID order by CreationTime) Rn
, *
 from sales.OrdersArchive) t where Rn =1

 -- in ordr to make identify where is  the  duplicate 
 Select * from (
select

ROW_NUMBER() over(partition  by OrderID order by CreationTime) Rn
, *
 from sales.OrdersArchive) t where Rn >1


 --- Data segmentation

 select 
       OrderID,
	   Sales,
	   NTILE(1) over(order by Sales DESC)OneBucket,
	    NTILE(2) over(order by Sales DESC)TwoBucket,
		 NTILE(3) over(order by Sales DESC)ThreeBucket,
		  NTILE(4) over(order by Sales DESC)FourBucket
 
 
 from Sales.Orders


 --- Segment all orders into 3 categories : high , medium and low sales 
Select *,
      case when Bucket =1 then 'High'
	  when Bucket =2 then 'Mudium'
	  when Bucket =3 then 'Low'
	 end SalesSegmentoins
From (
  select 
       OrderID,
	   Sales,
	   NTILE(3) over(order by Sales DESC)Bucket
  from Sales.Orders ) t



  --Equalizing load  > in order to export the data, divide the orders into 2 groups

 Select
     NTILE(2) over (order by OrderID) bucket,  *
 from Sales.Orders


 -- Find the products that fall wihin the highest 40% of ptices
 SELECT 
    *, 
    CONCAT(DistRank * 100, '%') AS DistRankPercent
FROM (
    SELECT 
        ProductID,
        Product,
        Price,
        CUME_DIST() OVER (ORDER BY Price DESC) AS DistRank
    FROM Sales.Products
) t
WHERE DistRank <= 0.4;
