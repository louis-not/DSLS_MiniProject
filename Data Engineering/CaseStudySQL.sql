/*
Customer Analysis: RFM Analysis
*/

-- Recency Rank
CREATE VIEW view_r2 AS
SELECT X.CustomerID, 
	DATEDIFF(day,X.OrderDate,'1997/12/31') AS Recency
	FROM (
		SELECT CustomerID, 
		OrderDate, 
		DENSE_RANK() OVER (PARTITION BY  CustomerID
			ORDER BY OrderDate DESC) AS Rank_
		FROM [Northwind].[dbo].[Orders]
		WHERE YEAR(OrderDate) = 1997 
		) AS X
	WHERE X.Rank_ =3 ;

-- Frequency & Monetary
CREATE VIEW view_fm2 AS
SELECT O.CustomerID, COUNT(O.OrderID) AS Frequency, 
	SUM(OD.UnitPrice * Quantity) AS Amount
	FROM [Northwind].[dbo].[Orders] AS O 
	JOIN [Northwind].[dbo].[Order Details] AS OD
	ON O.OrderID = OD.OrderID
	WHERE YEAR(O.OrderDate) = 1997
	GROUP BY CustomerID

-- RFM Value
CREATE VIEW view_rfm3 AS
SELECT view_fm2.CustomerID,
		view_r2.Recency,
		view_fm2.Frequency,
		view_fm2.Amount,
		NTILE(5) OVER (ORDER BY view_r2.Recency DESC) AS R,
		NTILE(5) OVER (ORDER BY view_fm2.Frequency DESC) AS F,
		NTILE(5) OVER (ORDER BY view_fm2.Amount DESC) AS M
	FROM view_fm2 
	INNER JOIN view_r2 
	ON view_fm2.CustomerID = view_r2.CustomerID;

CREATE VIEW view_rfm_class3 AS
SELECT view_rfm3.CustomerID,
	CONCAT(R, F, M) as rfm_class
	FROM view_rfm3;

CREATE VIEW view_rfm_result3 AS
SELECT *,
	CASE 
		WHEN rfm_class LIKE '[4-5][4-5][4-5]' THEN 'Best Customers'
		WHEN rfm_class LIKE '[2-4][3-4][4-5]' THEN 'Loyal Customers' 
		WHEN rfm_class LIKE  '[3-5][1-3][1-3]' THEN 'Potential Loyalist' 
		WHEN rfm_class LIKE  '[4-5][1-3][1-3]' THEN 'New Customers' 
		WHEN rfm_class LIKE  '[2-3][2-3][2-4]' THEN 'Need Attention/Hibernating'
		WHEN rfm_class LIKE  '111' THEN 'Lost'
	ELSE NULL
	END AS rfm_category
	FROM view_rfm_class3
	
SELECT * 
	INTO table_rfm_result3
	FROM view_rfm_result3;
	
/*
Product Analysis: Trend
*/

-- view for product for easier queries
CREATE VIEW view_product_od2 AS
SELECT O.CustomerID,
	COUNT(O.OrderID) AS Quantity,
	P.ProductName,
	C.CategoryName 
	FROM [Northwind].[dbo].[Orders] AS O
	JOIN [Northwind].[dbo].[Order Details] AS OD 
	ON O.OrderID = OD.OrderID
	JOIN [Northwind].[dbo].[Products] AS P
	ON OD.ProductID=P.ProductID 
	JOIN [Northwind].[dbo].[Categories] AS C
	ON P.CategoryID = C.CategoryID
	WHERE YEAR(O.OrderDate) = 1997
	GROUP BY O.CustomerID, P.ProductName, C.CategoryName;

-- Pivot on category on high performance customer
CREATE VIEW view_product_rfm AS
SELECT POD.CustomerID, POD.Quantity, POD.ProductName,
	POD.CategoryName, RFM.rfm_category
	FROM view_product_od2 AS POD
	LEFT JOIN table_rfm_result3 AS RFM
	ON RFM.CustomerID = POD.CustomerID
	WHERE RFM.rfm_category IS NOT NULL;

-- Most Popular Category Name by rfm category
CREATE VIEW view_product_to_rfm AS
SELECT *
	FROM (
		SELECT X.rfm_category, X.CategoryName, X.TotalQuantity,
		DENSE_RANK() OVER (PARTITION BY X.rfm_category
				ORDER BY X.TotalQuantity DESC) AS Rank_
		FROM (
			SELECT rfm_category, CategoryName, SUM(Quantity) AS TotalQuantity
				FROM view_product_rfm
				GROUP BY rfm_category, CategoryName
		) AS X
	) AS Y
	WHERE Y.Rank_ <= 3

	
SELECT * 
	INTO table_product_to_rfm
	FROM view_product_to_rfm;
