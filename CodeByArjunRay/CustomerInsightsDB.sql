-- Q1 — How many customers are in the table?
SELECT 
    COUNT(*) AS TotalCustomers
FROM
    Customers;

-- Q2 — Total revenue by customer (sum of Quantity * Price)
SELECT 
    C.CustomerID,
    CONCAT(C.FirstName, ' ', LastName) AS CustomerName,
    SUM(O.Quantity * O.Price) AS TotalRevenue
FROM
    Customers C
        JOIN
    Orders O ON C.CustomerID = O.CustomerID
GROUP BY C.CustomerID
ORDER BY TotalRevenue DESC;

-- Q3 — Top 3 customers by revenue
SELECT 
    C.CustomerID,
    CONCAT(C.FirstName, ' ', C.LastName) AS CustomerName,
    SUM(O.Quantity * O.Price) AS TotalRevenue
FROM
    Customers C
        JOIN
    Orders O ON C.CustomerID = O.CustomerID
GROUP BY C.CustomerID
ORDER BY TotalRevenue DESC
LIMIT 3;

-- Q4 — Which customers made more than 2 purchases?
SELECT 
    C.CustomerID,
    CONCAT(C.FirstName, ' ', C.LastName) AS CustomerName,
    COUNT(O.OrderID) AS OrderCount
FROM
    Orders O
        JOIN
    Customers C ON O.CustomerID = C.CustomerID
GROUP BY C.CustomerID
HAVING OrderCount > 2;

-- Q5 — Average order value (AOV) overall and per customer

-- a. Overall AOV (total revenue / total orders):
SELECT 
    ROUND(SUM(Quantity * Price) / COUNT(DISTINCT OrderID),
            2) AS Overall_AOV
FROM
    Orders O;
    
-- b. AOV per customer
SELECT 
    C.CustomerID,
    CONCAT(C.FirstName, ' ', C.LastName) AS CustomerName,
    ROUND(SUM(O.Quantity * O.Price) / ROUND(COUNT(O.OrderID), 2)) AS AOV_per_Customer
FROM
    Orders O
        JOIN
    Customers C ON O.CustomerID = C.CustomerID
GROUP BY C.CustomerID;

-- Q6 — Repeat purchase rate (percent of customers with >1 order)
SELECT 
    ROUND(100 * SUM(CASE
                WHEN order_count > 1 THEN 1
                ELSE 0
            END) / COUNT(*),
            2) AS RepeatPurchaseRate_Percent
FROM
    (SELECT 
        CustomerID, COUNT(*) AS order_count
    FROM
        Orders
    GROUP BY CustomerID) t;

-- Q7 — Inactive customers (no orders in last 30 days from 2025-08-13)
SELECT 
    C.CustomerID,
    CONCAT(C.FirstName, ' ', C.LastName) AS CustomerName,
    MAX(O.OrderDate) AS LastOrderDate
FROM
    Customers C
        JOIN
    Orders O ON C.CustomerID = O.CustomerID
GROUP BY C.CustomerID
HAVING MAX(O.OrderDate) < DATE_SUB('2025-08-13', INTERVAL 30 DAY)
    OR MAX(O.OrderDate) IS NULL;

-- Q8 — Simple RFM table (Recency, Frequency, Monetary) — recency in days relative to 2025-08-13
SELECT 
    C.CustomerID,
    CONCAT(C.FirstName, ' ', C.LastName) AS CustomerName,
    DATEDIFF('2025-08-13', MAX(O.OrderDate)) AS RecencyDays,
    COUNT(O.OrderID) AS Frequency,
    ROUND(SUM(O.Quantity * O.Price), 2) AS Monetary
FROM
    Customers C
        LEFT JOIN
    Orders O ON C.CustomerID = O.CustomerID
GROUP BY C.CustomerID;

-- Q9 — Customer Lifetime Value (basic: total revenue per customer)
SELECT 
    C.CustomerID,
    CONCAT(C.FirstName, ' ', C.LastName) AS CustomerName,
    SUM(O.Quantity * O.Price) AS CLTV
FROM
    Customers C
        LEFT JOIN
    Orders O ON C.CustomerID = O.CustomerID
GROUP BY C.CustomerID
ORDER BY CLTV DESC;

-- Q10 — Top city by customer revenue (simple geo segmentation)
SELECT 
    City,
    COUNT(DISTINCT C.CustomerID) AS NumCustomers,
    ROUND(SUM(O.Quantity * O.Price), 2) AS CityRevenue
FROM
    Customers C
        LEFT JOIN
    Orders O ON C.CustomerID = O.CustomerID
GROUP BY City
ORDER BY CityRevenue DESC;

-- Q11 — Customers with order frequency and last order date (ready for targeting)
SELECT 
    C.CustomerID,
    CONCAT(C.FirstName, ' ', C.LastName) AS CustomerName,
    COUNT(O.OrderID) AS OrderCount,
    MAX(O.OrderDate) AS LastOrderDate
FROM
    Customers C
        LEFT JOIN
    Orders O ON C.CustomerID = O.CustomerID
GROUP BY C.CustomerID
ORDER BY OrderCount DESC , LastOrderDate DESC;

-- Q12 — Bonus: customers with high frequency but low average order value (good for up-sell)
SELECT 
    C.CustomerID,
    CONCAT(C.FirstName, ' ', C.LastName) AS CustomerName,
    COUNT(O.OrderID) AS Frequency,
    ROUND(AVG(O.Quantity * O.Price), 2) AS AvgOrderValue
FROM
    Customers C
        JOIN
    Orders O ON C.CustomerID = O.CustomerID
GROUP BY C.CustomerID
HAVING Frequency >= 2
ORDER BY AvgOrderValue ASC;



-- No rows — no inactive customers (all have at least one order in the last 30 days).
