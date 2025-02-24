-- Genrate a list of customer information
--Show their first name, last name, and email address.
--Sort the list of results by last name.

SELECT
    FirstName, 
    LastName, 
    Email
FROM Customers
 ORDER BY LastName;



-- Create a table in the database to store customer
-- responses to our anniversary invitation.

-- Associate a customer's ID number with the number of people
-- they plan to bring in their party.

CREATE TABLE AnniversaryAttendees (
CustomerID INTEGER,
PartySize INTEGER 
);

-- Create reports that will be used to make three menus.
-- Create a report with all the items sorted by price (lowest tohighest).

select * 
From Dishes
ORDER by  price;

-- Create a report showing appetizers and beverages.

select * 
From Dishes
where Type in('Beverage' ,'Appetizer')
ORDER by Type ;

-- Create a report with all items except beverages.

select * 
From Dishes
where Type <> 'Beverage'
ORDER by Type ;




-- Add  a customer to the Restuurant  loyalty  program. 
-- use the following information to create a record :
--  Anna smith (asmith@samoca.org)
-- 479 Lapis Dr. , mmphis , IN
-- phone 555 555-1212: Birhday: July 21 , 1973


INSERT INTO Customers (FirstName , LastName , Email, Address , City , State , Phone , Birthday)
VALUES('Anna','Smith', 'asmith@samoca.org','479 Lapis Dr.','Memphis', 'TN', '555-555-1212', '1973-07-21')


DELETE FROM Customers 
WHERE CustomerID= 102 ;

select * From Customers where FirstName = 'Anna'

-- update Taylor jenkins 
-- old addrss to new one 74 Pine St., New Yourk, NY

-- searching the exist customer name 

select * from Customers where  FirstName like 'Ta%' ;

-- update 
update Customers
set
  Address = '74 Pine St.',
  City = 'New York',
  State = 'NY'
where CustomerID = 26
-- make sure every thing working 

select * from Customers where  CustomerID = 26 ;

-- remove customer that they can't make reservation
-- Customr named Nordy  has notified us he won't 
-- be able to keep his friday reservation
-- today is july 24 , 2022

select * from Reservations as r
join Customers as c
on r.CustomerID = c.CustomerID
where FirstName = 'Norby'And date >'2022-07-24'

DELETE  from Reservations where reservationID = 2000 ;

-- or 
update Reservations set date = null where reservationID = 2000;


-- Register a customer for our annniversary event.
-- the customer 'atapley2j@kineronin.com wil be in 
-- attendane , and will brings 3 friends 


INSERT INTO AnniversaryAttendees (
CustomerID , PartySize ) 
VALUES (
(   select CustomerID 
    from customers 
    where Email  = 'atapley2j@kinetecoinc.com' 
), 4  )

Select * from AnniversaryAttendees

-- find the reservation information for a customer whose 
-- name we arn't quit sure how to spell
-- steven , stephensen , dtevenson
-- There are four people in the party . today is june 14th 

Select 
    r.reservationID,
    c.FirstName,
    c.LastName,
    r.date,
    r.PartySize
from Reservations as r join Customers as c
on c.CustomerID = r.CustomerID
where c.LastName like 'Ste%' and PartySize = 4  
ORDER by r.date DESC;


-- Create a reservation for a customer who may or may not 
-- already be listed in our customers table.
-- for 5 peopl eon August 12 , 2022 at 6pm 18:00

-- first step check if exist or not 

Select * 
from customers 
where Email = 'smac@kinetecoinc.com'

-- add his information to customer tabel 
--step 1
INSERT INTO Customers (FirstName, LastName , Email , phone) 
VALUES ('Sam','McAdames', 'smac@kinetecoinc.com' , '555-555-1212')

-- Step 2
INSERT INTO Reservations (CustomerID ,date, PartySize )
VALUES (101 ,'2022-08-12 18:00:00', 5)


-- modfying phone informtion there was error
update Customers 
Set 
phone = '(555) 555-1212'
where CustomerID = 101

-- The Target
Select 
      * 
FROM Reservations as r 
join customers as c on c.CustomerID = r.CustomerID
where c.Email = 'smac@kinetecoinc.com'



-- Enter a customer's delivery order into our database,
-- and provide the total cost of the items ordered.
-- Use this order information:
-- Customer: Loretta Hundey, at 6939 Elka Place
-- Items: 1 House Salad, 1 Mini Cheeseburgers, and
-- 1 Tropical Blue Smoothie
-- Delivery date and time: September 20, 2022 @ 2PM (14:00)
-- There are no taxes or other fees.




-- find the customere
select *
FROM Customers
WHERE FirstName like 'Loretta%'

-- Create the order record 
Select * from Orders
where CustomerID =70

INSERT INTO Orders ( CustomerID , OrderDate) 
VALUES(70,'2022-09-20 02:00:00')


-- Add items to the order
INSERT  INTO OrdersDishes  (OrderID , DishID) VALUES
(1001 , (Select DishID from Dishes where Name = 'House Salad')),
(1001 , (Select DishID from Dishes where Name = 'Mini Cheeseburgers')),
(1001 , (Select DishID from Dishes where Name = 'Tropical Blue Smoothie'))

-- check everything works 
Select * 
From Dishes as d
join OrdersDishes as O on d.DishID = o.DishID
where  o.OrderID = 1001

-- Total Cost 
Select 
    SUM(d.price) TotalPrice
From Dishes as d
join OrdersDishes as O on d.DishID = o.DishID
where  o.OrderID = 1001



-- epdate information in the database
-- Set Cleo Goldwater's Favorite Dish to 
-- the Quinoa Salmon Salad



-- identfy ID of Dishe 9
Select DishID
from Dishes
where Name = 'Quinoa Salmon Salad'


-- customer id  42

select *
from Customers
where FirstName = 'Cleo' and LastName='Goldwater'

update Customers
 Set FavoriteDish = (Select DishID from Dishes where Name = 'Quinoa Salmon Salad')
 where CustomerID = 42 


 Select
    c.LastName,
    c.LastName ,
    c.FavoriteDish,
    d.Name
from customers as c 
join dishes as d on c.FavoriteDish = d.DishID


-- Identify a few customers who have ordered delivery
-- from the restaurant the most often, so we can send
-- them a promotional coupon.


SELECT
    c.CustomerID,
    c.FirstName,
    c.LastName,
    c.Email,
    o.Total_orders
from customers as c
 join(
    Select 
          CustomerID,
          Count(OrderID) Total_orders
          from Orders
          group by CustomerID)O
         on o.CustomerID = c.CustomerID
order by Total_orders DESC 
Limit 5 ;
