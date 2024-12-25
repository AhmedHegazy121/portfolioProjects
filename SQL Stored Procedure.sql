--Step 1 : Write Query
-- For us Customers Find the Total Number Of Customers and the AVerage Score

Select 
	COUNT(*) TotalCustomers,
	AVG(Score) Avgscore
from Sales.Customers
where Country = 'USA'


-- step 2 : Turning the query into a stored Procedure 

Create procedure GetCustomerSummary as 
begin
Select 
	COUNT(*) TotalCustomers,
	AVG(Score) Avgscore
from Sales.Customers
where Country = 'USA'
end

-- step 3 : Execute the stored procedure

EXEC GetCustomerSummary


-----             Stored Procedure Parameters
/* Placeholder used to pass values as input  from the caller to the procedure,
allowing dynamic data to be processed*/

--- For german customers find the total number of customers and the Average score

Create procedure GetCustomerGerman as 
begin
Select 
	COUNT(*) TotalCustomers,
	AVG(Score) Avgscore
from Sales.Customers
where Country = 'German'
end

-- Aviod Repetition
-- if  notice repeated code in your project, it's a sign that your code can be improved.

-- Step 1 Define the parameter
-- Step 2 use the parameter
-- Step 3 pass the parameter's Value at Execution

ALTER procedure GetCustomerSummary @Country NVARCHAR(50) = 'USA' as -- step 1 >>Usa is default if i don't determine which country that needed
begin
Select 
	COUNT(*) TotalCustomers,
	AVG(Score) Avgscore
from Sales.Customers
where Country = @Country --step2
end

-- EXcute the stored procedure
EXEC GetCustomerSummary -- use default value
EXEC GetCustomerSummary @Country = 'Germany'
EXEC GetCustomerSummary @Country = 'USA'

--              Multiple Statements
-- Tip : Add a semicolon at the end of each Sql statment

ALTER procedure GetCustomerSummary @Country NVARCHAR(50) = 'USA' as -- step 1 >>Usa is default if i don't determine which country that needed
begin
Select 
	COUNT(*) TotalCustomers,
	AVG(Score) Avgscore
from Sales.Customers
where Country = @Country; --step2


-- Find total nr. of orders and total sales
select
	COUNT(OrderID) TotalOrders
	,SUM(Sales) TotalSales
from Sales.Orders o
Join Sales.Customers  c
on c.CustomerID = o.CustomerID
where c.Country = @Country ;

end

-- EXcute the stored procedure
EXEC GetCustomerSummary -- use default value
EXEC GetCustomerSummary @Country = 'Germany'
EXEC GetCustomerSummary @Country = 'USA'



---              Variables

-- placeholders used to store values to be used later in the procedure.
-- Temporarily store and manipulate data during its execution

ALTER PROCEDURE GetCustomerSummary 
    @Country NVARCHAR(50) = 'USA' -- Default is 'USA' if no country is specified
AS
BEGIN
    -- Step 1: Declare Variables
    DECLARE @TotalCustomers INT, 
            @Avgscore FLOAT;

    -- Calculate total customers and average score
    SELECT 
        @TotalCustomers = COUNT(*),
        @Avgscore = AVG(Score)
    FROM Sales.Customers
    WHERE Country = @Country;

    -- Print the results
    PRINT 'Total customers from ' + @Country + ': ' + CAST(@TotalCustomers AS VARCHAR(10));
    PRINT 'Average score from ' + @Country + ': ' + CAST(@Avgscore AS VARCHAR(10));

    -- Find total number of orders and total sales
    SELECT
        COUNT(o.OrderID) AS TotalOrders,
        SUM(o.Sales) AS TotalSales
    FROM Sales.Orders o
    INNER JOIN Sales.Customers c
        ON c.CustomerID = o.CustomerID
    WHERE c.Country = @Country;
END;
go

EXEC GetCustomerSummary;  -- Default 'USA'
EXEC GetCustomerSummary @Country = 'Germany'; -- Example for another country


------                   Stored Procedure Control Flow If else

/*
Handle nulls before aggregating to ensure accutate results
*/


ALTER PROCEDURE GetCustomerSummary 
    @Country NVARCHAR(50) = 'USA' -- Default is 'USA' if no country is specified
AS
BEGIN
    -- Step 1: Declare Variables
    DECLARE @TotalCustomers INT, 
            @Avgscore FLOAT;

     -- Prepare & cleanup data

-- Select 1 from Sales.Customers where Score is null and Country= 'USA'
if exists (Select 1 from Sales.Customers where Score is null and Country= @Country)
begin
	print('Updating null scores to 0')
	update Sales.Customers
	set Score = 0
	where Score is null and Country = @Country
end 

else
begin
 print('no null scores found')
end 

    -- Calculate total customers and average score
    SELECT 
        @TotalCustomers = COUNT(*),
        @Avgscore = AVG(Score)
    FROM Sales.Customers
    WHERE Country = @Country;

    -- Print the results
    PRINT 'Total customers from ' + @Country + ': ' + CAST(@TotalCustomers AS VARCHAR(10));
    PRINT 'Average score from ' + @Country + ': ' + CAST(@Avgscore AS VARCHAR(10));

    -- Find total number of orders and total sales
    SELECT
        COUNT(o.OrderID) AS TotalOrders,
        SUM(o.Sales) AS TotalSales
    FROM Sales.Orders o
    INNER JOIN Sales.Customers c
        ON c.CustomerID = o.CustomerID
    WHERE c.Country = @Country;
END;
go

EXEC GetCustomerSummary 
EXEC GetCustomerSummary @Country = 'German'



---           handling Error
ALTER PROCEDURE GetCustomerSummary 
    @Country NVARCHAR(50) = 'USA' -- Default is 'USA' if no country is specified
AS
BEGIN

	begin try

		-- Step 1: Declare Variables
	DECLARE

		@TotalCustomers INT, 
		@Avgscore FLOAT;

		 -- Prepare & cleanup data

	-- Select 1 from Sales.Customers where Score is null and Country= 'USA'
	if exists (Select 1 from Sales.Customers where Score is null and Country= @Country)
	begin

		print('Updating null scores to 0')
		update Sales.Customers
		set Score = 0
		where Score is null and Country = @Country
	end 

	else
	begin
		print('no null scores found')
	end 

		-- Calculate total customers and average score
	SELECT 

			@TotalCustomers = COUNT(*),
			@Avgscore = AVG(Score)

	FROM Sales.Customers
	WHERE Country = @Country;

		-- Print the results
		PRINT 'Total customers from ' + @Country + ': ' + CAST(@TotalCustomers AS VARCHAR(10));
		PRINT 'Average score from ' + @Country + ': ' + CAST(@Avgscore AS VARCHAR(10));

		-- Find total number of orders and total sales
	SELECT

			COUNT(o.OrderID) AS TotalOrders,
			SUM(o.Sales) AS TotalSales ,
			--1/0 the Error

	 FROM Sales.Orders o
	 INNER JOIN Sales.Customers c
	 ON c.CustomerID = o.CustomerID
	 WHERE c.Country = @Country;

	end try
--- Handling the ERORR
	Begin catch
		print('An error occured.');
		print('Error Message : ' + error_message());
		print('Error number : ' + cast (error_number() as varchar)) ;
		print('Error Line : ' + cast (error_line() as varchar)) ;
		print('Error Procedure : ' + error_procedure());

	End Catch
END;
go

exec  GetCustomerSummary


