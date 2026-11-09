CREATE TABLE Categories (
    CategoryID INT PRIMARY KEY,
    CategoryName VARCHAR(40),
    Description VARCHAR
);

CREATE TABLE Customers (
    CustomerID VARCHAR(5) PRIMARY KEY,
    CompanyName VARCHAR(40),
    ContactName VARCHAR(30),
    ContactTitle VARCHAR(30),
    City VARCHAR(15),
    Country VARCHAR(15)
);

CREATE TABLE Shippers (
    ShipperID INT PRIMARY KEY,
    CompanyName VARCHAR(40) NOT NULL
);

CREATE TABLE Employees (
    EmployeeID INT PRIMARY KEY,
    EmployeeName VARCHAR(20) NOT NULL,
    Title VARCHAR(30),
    City VARCHAR(15),
    Country VARCHAR(15),
    ReportsTo INT,
	FOREIGN KEY (ReportsTo) REFERENCES Employees (EmployeeID)
);

CREATE TABLE Products (
    ProductID INT PRIMARY KEY,
    ProductName VARCHAR(40) NOT NULL,
    QuantityPerUnit VARCHAR(20),
    UnitPrice DECIMAL(10),
    Discontinued INT,
	CategoryID INT
);

CREATE TABLE Orders (
    OrderID INT PRIMARY KEY,
    CustomerID CHAR(5) REFERENCES Customers(CustomerID),
    EmployeeID INT REFERENCES Employees (EmployeeID),
    OrderDate DATE,
    RequiredDate DATE,
    ShippedDate DATE,
	ShippedID VARCHAR,
    Freight DECIMAL(10,2)
);

CREATE TABLE OrderDetails (
    OrderID INT NOT NULL,
    ProductID INT NOT NULL,
    Quantity INT,
    Discount DECIMAL(4)
);

SELECT *
FROM customers;

SELECT *
FROM employees;


1.  --How have total orders and revenue changeed over time,
--and there any noticedable sales trend?
SELECT
    DATE_TRUNC('month', o.OrderDate) AS order_month,
    COUNT(DISTINCT o.OrderID) AS total_orders,
    SUM(p.UnitPrice * od.Quantity * (1 - od.Discount)) AS total_revenue
FROM Orders o
JOIN OrderDetails od ON o.OrderID = od.OrderID
JOIN Products p ON od.ProductID = p.ProductID
GROUP BY DATE_TRUNC('month', o.OrderDate)
ORDER BY order_month;


2. --which products are the best_selling based on sales quantity?
SELECT 
    p.ProductID,
    p.ProductName,
    SUM(od.Quantity) AS total_quantity_sold
FROM Products p
JOIN OrderDetails od ON p.ProductID = od.ProductID
GROUP BY p.ProductID, p.ProductName
ORDER BY total_quantity_sold DESC
LIMIT 10;



3.  ---which products are the Worst_selling based on sales quantity?
 SELECT 
    p.ProductID,
    p.ProductName,
    SUM(od.quantity) AS total_quantity_sold
FROM Products p
LEFT JOIN OrderDetails od ON p.ProductID = od.ProductID
GROUP BY p.ProductID, p.ProductName
ORDER BY total_quantity_sold ASC
LIMIT 10;



4.  ---which customers generate the highest number of orders 
--and contribute the most revenue
SELECT 
    c.CustomerID,
    c.CompanyName,
    COUNT(DISTINCT o.OrderID) AS total_orders,
    SUM(p.UnitPrice * od.Quantity * (1 - od.Discount)) AS total_revenue
FROM Customers c
JOIN Orders o ON c.CustomerID = o.CustomerID
JOIN OrderDetails od ON o.OrderID = od.OrderID
JOIN Products p ON od.ProductID = p.ProductID
GROUP BY c.CustomerID, c.CompanyName
ORDER BY total_revenue DESC;



5.  ---Are shipping cost consistent across different shipping providers?
SELECT
    s.ShipperID,
    s.CompanyName AS shipper_name,
    COUNT(o.OrderID) AS total_shipments,
    AVG(o.Freight) AS avg_shipping_cost,
    SUM(o.Freight) AS total_shipping_cost
FROM Shippers s
JOIN Orders o ON s.ShipperID = o.ShippedID
GROUP BY s.ShipperID, s.CompanyName
ORDER BY avg_shipping_cost DESC;


ALTER TABLE Orders
ALTER COLUMN ShippedID TYPE INT USING ShippedID::INT;



6.  --how efficient is the delivery proces, and how many 
--orders are delivered on time verse late
SELECT 
    CASE 
        WHEN ShippedDate <= RequiredDate THEN 'On-Time'
        WHEN ShippedDate > RequiredDate THEN 'Late'
        ELSE 'Not Shipped'
    END AS delivery_status,
    COUNT(OrderID) AS order_count,
    ROUND(100.0 * COUNT(OrderID) / SUM(COUNT(OrderID)) OVER (), 2) AS percentage
FROM Orders
GROUP BY 
    CASE 
        WHEN ShippedDate <= RequiredDate THEN 'On-Time'
        WHEN ShippedDate > RequiredDate THEN 'Late'
        ELSE 'Not Shipped'
    END;

