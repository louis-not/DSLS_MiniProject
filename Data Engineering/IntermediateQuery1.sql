/****** Script for DSLS: DE Mini Project  ******/

/*
Soal Intermediate Queries 
Nomor 1
*/
SELECT MONTH([OrderDate]) AS "bulan",
		COUNT( DISTINCT [CustomerID]) AS "Jumlah Customer"
  FROM [Northwind].[dbo].[Orders]
  WHERE year([OrderDate]) = 1997
  GROUP BY MONTH([OrderDate]) ;

/*
Nomor 2
*/
SELECT [LastName]
      ,[FirstName]
      ,[Title]
FROM [Northwind].[dbo].[Employees]
WHERE [Title] = 'Sales Representative';

/*
Nomor 3
*/
SELECT TOP (5) OrderDetails.[OrderID], 
			OrderDetails.[Quantity], 
			Products.[ProductName], 
			Orders.[OrderDate]
  
  FROM (([Northwind].[dbo].[Order Details] AS OrderDetails
  INNER JOIN [Northwind].[dbo].[Products] AS Products 
	ON OrderDetails.[ProductID]=Products.[ProductID]) 
	INNER JOIN [Northwind].[dbo].[Orders] AS Orders
	ON OrderDetails.[OrderID]=Orders.[OrderID])
	
  WHERE year(Orders.[OrderDate]) = 1997 
	AND month(Orders.[OrderDate]) = 1

  ORDER BY OrderDetails.[Quantity] DESC; 

 /*
 Nomor 4
 */
 SELECT TOP (1000) OrderDetails.[OrderID], 
			Products.[ProductName], 
			Orders.[OrderDate], 
			Customers.[CompanyName]
  
  FROM ((([Northwind].[dbo].[Order Details] AS OrderDetails
  INNER JOIN [Northwind].[dbo].[Products] AS Products 
	ON OrderDetails.[ProductID]=Products.[ProductID]) 
	INNER JOIN [Northwind].[dbo].[Orders] AS Orders
	ON OrderDetails.[OrderID]=Orders.[OrderID])
	INNER JOIN [Northwind].[dbo].[Customers] AS Customers
	ON Customers.[CustomerID]=Orders.[CustomerID])

  WHERE Products.[ProductName] = 'Chai' 
    AND year(Orders.[OrderDate]) = 1997 
	AND month(Orders.[OrderDate]) = 6;

/*
Nomor 5
*/
WITH Y AS (
SELECT OrderDetails.[OrderID], 
			OrderDetails.[Quantity],
			(OrderDetails.[UnitPrice] * OrderDetails.[Quantity]) AS TotalPrice
FROM [Northwind].[dbo].[Order Details] AS OrderDetails ),

X AS (
SELECT *,
CASE WHEN (Y.[TotalPrice]) <=100 THEN '<=100'
WHEN (Y.[TotalPrice]) > 100 AND (Y.[TotalPrice]) <=250 THEN '100<x<=250'
WHEN (Y.[TotalPrice]) > 250 AND (Y.[TotalPrice]) <=500 THEN '250<x<=500'
ELSE '>500' END AS TotalPriceCategory
FROM Y)

Select TotalPriceCategory, count(DISTINCT [OrderID]) AS TOTAL_ORDERID
From X
Group by TotalPriceCategory

/*
Nomor 6
*/
SELECT Customers.CompanyName, SUM(X.Quantity) AS Order_Quantity
FROM [Northwind].[dbo].[Customers] AS Customers 
LEFT JOIN (
	SELECT Orders.CustomerID, Order_Details.Quantity
	FROM [Northwind].[dbo].[Orders] AS Orders
	JOIN [Northwind].[dbo].[Order Details] AS Order_Details 
		ON Orders.OrderID = Order_Details.OrderID
	WHERE YEAR(Orders.OrderDate) = 1997 
	) AS X 
	ON Customers.CustomerID = X.CustomerID 
GROUP BY Customers.CompanyName
HAVING SUM(X.Quantity) > 500 
ORDER BY SUM(X.Quantity) DESC;

/*
Nomor 7
*/
SELECT X.Bulan, X.ProductName, X.Quantity
FROM (
	SELECT MONTH(Orders.OrderDate) AS Bulan,
			Products.ProductName,
			Order_Details.Quantity,
			ROW_NUMBER() 
				OVER (
					PARTITION BY MONTH(Orders.OrderDate) 
					Order BY Order_Details.Quantity DESC) AS Product_rank
	FROM [Northwind].[dbo].[Orders] AS Orders
	JOIN [Northwind].[dbo].[Order Details] AS Order_Details 
		ON Orders.OrderID = Order_Details.OrderID
	JOIN [Northwind].[dbo].[Products] AS Products
		ON Order_Details.ProductID = Products.ProductID
	WHERE YEAR(Orders.OrderDate) = 1997 
	) AS X
WHERE X.Product_rank <=5 ;

/*
Nomor 8
*/
CREATE VIEW Nomor8 AS
SELECT Order_Details.OrderID, 
		Order_Details.ProductID,
		Products.ProductName,
		Order_Details.UnitPrice,
		Order_Details.Discount,
		Order_Details.UnitPrice *(1-Order_Details.Discount) AS DiscountPrice
FROM [Northwind].[dbo].[Order Details] AS Order_Details 
JOIN [Northwind].[dbo].[Products] AS Products
	ON Order_Details.ProductID = Products.ProductID 

/*
Nomor 9
*/
-- Pembuatan View
CREATE VIEW Nomor9 AS
SELECT Orders.CustomerID,
		Customers.CompanyName,
		Orders.OrderID,
		Orders.OrderDate,
		Orders.RequiredDate,
		Orders.ShippedDate
FROM [Northwind].[dbo].[Orders] AS Orders
JOIN [Northwind].[dbo].[Customers] AS Customers
	ON Orders.CustomerID = Customers.CustomerID

-- Pembuatan Prosedur
CREATE PROCEDURE print_invoice
 @CustomerID VARCHAR(100)
AS
BEGIN
SET NOCOUNT ON;
SELECT * FROM Nomor9
WHERE CustomerID = @CustomerID
END
GO

-- Pengujian Prosedur
EXEC print_invoice @CustomerID = 'HANAR';
