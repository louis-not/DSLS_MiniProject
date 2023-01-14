/****** Script for SelectTopNRows command from SSMS  ******/

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
