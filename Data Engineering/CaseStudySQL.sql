/*
Customer Analysis: RFM Analysis
*/

-- Recency Rank
CREATE VIEW view_r AS
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
	WHERE X.Rank_ <= 3 ;

-- Frequency & Monetary
CREATE VIEW view_fm AS
SELECT O.CustomerID, COUNT(O.OrderID) AS Frequency, 
	SUM(OD.UnitPrice * Quantity) AS Amount
	FROM [Northwind].[dbo].[Orders] AS O 
	JOIN [Northwind].[dbo].[Order Details] AS OD
	ON O.OrderID = OD.OrderID
	WHERE YEAR(O.OrderDate) = 1997
	GROUP BY CustomerID

-- RFM Value
CREATE VIEW view_rfm AS
SELECT view_fm.CustomerID,
		view_r.Recency,
		view_fm.Frequency,
		view_fm.Amount,
		NTILE(4) OVER (ORDER BY view_r.Recency DESC) AS R,
		NTILE(4) OVER (ORDER BY view_fm.Frequency DESC) AS F,
		NTILE(4) OVER (ORDER BY view_fm.Amount DESC) AS M
	FROM view_fm 
	INNER JOIN view_r 
	ON view_fm.CustomerID = view_r.CustomerID;

CREATE VIEW view_rfm_class AS
SELECT view_rfm.CustomerID,
	CONCAT(R, F, M) as rfm_class
	FROM view_rfm;

CREATE VIEW view_rfm_result AS
SELECT *,
	CASE 
		WHEN rfm_class LIKE '1[1-2][1-2]' THEN 'Best Customers'
		WHEN rfm_class LIKE '14[1-2]' THEN 'High-spending New Customers' 
		WHEN rfm_class LIKE  '11[3-4]' THEN 'Lowest-Spending Active Loyal Customers' 
		WHEN rfm_class LIKE  '4[1-2][1-2]' THEN 'Churned Best Customers' 
	ELSE NULL
	END AS rfm_category
	FROM view_rfm_class
	
SELECT * 
	INTO table_rfm_result
	FROM view_rfm_result;
