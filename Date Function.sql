
--Extaract the year , month, day, week and quarter from Creationtime

Select

	OrderID,
	OrderDate,
	CreationTime,
	YEAR(CreationTime) Year,
	MONTH(CreationTime)Month,
	DAY(CreationTime) Day,
	--Datepart
	DATEPART(WEEKDAY,CreationTime) Week,-- in order to get the week and the quarter most use datepart if i use week instaed of week day I would get continous week 
	DATEPART(QUARTER,CreationTime) Quarter,
	DATEPART(MINUTE,CreationTime) Minute, 
	DATEPART(HOUR,CreationTime) hour,
	-- datename 
	DATENAME(Q , CreationTime) QuarterName,
	DATENAME(WEEKDAY , CreationTime) WeekName,
	DATENAME(MONTH, CreationTime) monthName
	--Datetrunc
	,DATETRUNC(day,CreationTime) dayTrunc,-- minute and hour  rest onto zero zero
	DATETRUNC(MONTH,CreationTime) monthTrunc --- the day resetst to zero one

from Sales.Orders


-- zoom in and  zoom the level of details out by using DateTrunce

Select 
--CreationTime cnt , -- will get 1 to each rows that becuase  level of details or granularity of the creation time is very High (Scound)
	DATETRUNC(MONTH,CreationTime)   cnt ,-- if we make it to year we will get ten casue it's the high level of agregation in the date 
	count(*)
from Sales.Orders
group by DATETRUNC(MONTH,CreationTime)


-- extracte the last day of the months and first day 

Select 

	EOMONTH(CreationTime)  endOfMonth,
	DATETRUNC(MONTH,CreationTime) FirtofMonth

from Sales.Orders

-- how many orders were placed each year
select

	YEAR(OrderDate) Year,
	count(OrderID)  NrofOrders
from Sales.Orders

group by YEAR(OrderDate)

-- how many orders were placed each month ?

select

	datename(month,OrderDate) month,
	count(OrderID) NrofOrders

from Sales.Orders 
group by datename(month,OrderDate)


-- Data Filtering : Show all orders that were placed during the month of february.
-- Best practice : Filtering Data using an integer is faster than using a String
select

	* ,
	 datename(month,OrderDate) month

from Sales.Orders 
where month(OrderDate) = 2

-- Best practice : Filtering Data using an integer is faster than using a String

-- formating

select

	OrderID,
	OrderDate,
	Sales,
	FORMAT(CreationTime,'MM-dd-yyyy') Usa_Formating,
	FORMAT(CreationTime,'dd-MM-yyyy') Euro_formting,
	FORMAT(CreationTime,'dd') Day,
	FORMAT(CreationTime,'ddd') DayName,
	FORMAT(CreationTime,'dddd') Fullday,
	FORMAT(CreationTime,'MM') Month,
	FORMAT(CreationTime,'MMM') MonthName

from Sales.Orders 


-- Show creation Time using the following format: Day web jan Q12025 12:34:56 PM

select

	OrderID,
	OrderDate,
	Sales,
	'Day ' +FORMAT(CreationTime , 'dd MMM') + ' Q'+ DATENAME(QUARTER,CreationTime) 
	+ FORMAT(CreationTime,'yyyy hh:34:56 tt') Time --  cause we use pm not full time 24 hours

from Sales.Orders 

-- Data Aggregations 

select

	format (OrderDate,'MMM yy') YearMonth,
	COUNT(*)

from Sales.Orders 
group by format (OrderDate,'MMM yy')


--Convert

select

	convert(int,'123') [string to int convert],
	CreationTime,
	convert(date,CreationTime) [datetime to date convert],
	convert(varchar,CreationTime ,32) [ USA std. style :32],
	convert(varchar,CreationTime ,34) [EURO std. style :34]

from Sales.Orders

--Cast 
select

	cast('3321' as int) [string to integer],
	cast(3321 as varchar) [int to string ],
	cast(CreationTime as date) [date time  to Date]

from Sales.Orders

-- task extract 10  days , add 3 months and add2 years from orderdate
select 

	OrderDate,
	DATEADD(DAY,-10,OrderDate) [Ten Day Before],
	DATEADD(MONTH,3,OrderDate) [Three Months After],
	DATEADD(YEAR,2,OrderDate) [2 Year After]

from Sales.Orders



-- Calculate the age of employees
Select 
	EmployeeID,
	BirthDate,
	DATEDIFF(YEAR, BirthDate,GETDATE())Age
from Sales.Employees

--- Find the average shipping duration in days for each month\
select
	datename(month,OrderDate) month,
	avg(DATEDIFF(DAY,OrderDate,ShipDate)) over(partition by datename(month,OrderDate) ) Avgday

from Sales.Orders

--- other way 
select
	datename(month,OrderDate) month,
	avg(DATEDIFF(DAY,OrderDate,ShipDate))  Avgday

from Sales.Orders
group by datename(month,OrderDate) 

-- Find the number of days between each order and previous oreder
--Time gab analysis
Select 
OrderID,
DATEDIFF(day,PreviousOrder,OrderDate)NrofDay
from
(
Select 
OrderID, 
OrderDate,
lag(OrderDate)over(order by OrderDate) PreviousOrder
from Sales.Orders ) t


--is date sql accept only defult format and year understand as a date. 
 select
	 isdate('1241')checkDate1, -- if zero it's not date
	 isdate('2025-05-20')checkDate2,-- one it is a date
	 isdate('20-08-2025')checkDate3,-- it returns zore cause the sql not understand the format not the stander or defult format.
	 ISDATE('2025')checkDate4,--it will be one
	 ISDATE('08')checkDate5-- it will be zero

 -- case senario 
 
 --cast (orderDate as date)
 Select
	 OrderDate,
	 isdate(OrderDate),
	 case when ISDATE(OrderDate) = 1 then cast(OrderDate as date) -- use else to get value istaed of null
	 end newOrderDate-- without this you will not be able to run this because we have different orderdate
 from
 (
	 select '2025-05-20'as OrderDate union
	 select '2025-05-25' union
	 select '2025-05-21' union
	 select '2025-05'
   )u
where  isdate(OrderDate) =0 --to know where the is the problem
