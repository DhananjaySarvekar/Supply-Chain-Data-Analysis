CREATE DATABASE SUPPLYCHAIN_DB;

USE SUPPLYCHAIN_DB;

CREATE TABLE Products (
    Product_ID VARCHAR(10) PRIMARY KEY,
    Product_Category VARCHAR(100),
    Product_Price DECIMAL(10, 2),
    Warehouse VARCHAR(100)
);

CREATE TABLE Suppliers (
    Supplier_ID VARCHAR(10) PRIMARY KEY,
    Supplier_Name VARCHAR(255),
    Supplier_Location VARCHAR(100),
    Supplier_Email VARCHAR(255)
);

CREATE TABLE Inventory (
    Product_ID VARCHAR(10) PRIMARY KEY,
    Inventory_Level INT,
    Stockout_Flag BOOLEAN,
    Backorder_Flag BOOLEAN
);

CREATE TABLE Orders (
    Order_ID INT PRIMARY KEY,
    Product_ID VARCHAR(10),
    Customer_ID INT,
    Order_Date DATE,
    Shipment_Date DATE,
    Lead_Time INT,
    Order_Quantity INT,
    Shipment_Quantity INT,
    Order_Priority VARCHAR(10),
    FOREIGN KEY (Product_ID) REFERENCES Products(Product_ID)
);

select * from inventory;

select * from orders;

select * from products;

select * from Suppliers;

-- How many products are there in each category?
SELECT 
    Product_Category, 
    COUNT(Product_ID) AS Total_Products
FROM Products
GROUP BY Product_Category;

-- How many products are stored in each warehouse?
SELECT 
    Warehouse, 
    COUNT(Product_ID) AS Total_Products
FROM 
    Products
GROUP BY 
    Warehouse;

-- What is the total quantity ordered for each product?
SELECT 
    Product_ID, 
    SUM(Order_Quantity) AS Total_Quantity_Ordered
FROM 
    Orders
GROUP BY 
    Product_ID;

-- What is the average lead time for orders categorized by priority?
SELECT 
    Order_Priority, 
    AVG(Lead_Time) AS Average_Lead_Time
FROM 
    Orders
GROUP BY 
    Order_Priority;

-- What percentage of orders were fully fulfilled?
SELECT 
    (SUM(CASE WHEN Shipment_Quantity >= Order_Quantity THEN 1 ELSE 0 END) / COUNT(Order_ID) * 100) AS Fulfillment_Rate
FROM 
    Orders;

-- What are the top 5 products by order quantity?
SELECT Product_ID, SUM(Order_Quantity) AS total_order_quantity
FROM Orders
GROUP BY Product_ID
ORDER BY total_order_quantity DESC
LIMIT 5;

-- Which products are in stock and flagged for backorder?
SELECT Product_ID, Inventory_Level
FROM Inventory
WHERE Backorder_Flag = 1;

-- What is the total revenue per product category ?
SELECT Product_Category, SUM(Order_Quantity * Product_Price) AS total_revenue
FROM Orders
JOIN Products ON Orders.Product_ID = Products.Product_ID
GROUP BY Product_Category
ORDER BY total_revenue DESC;

-- Which products have highest shipment fulfillment efficiency?
SELECT Product_ID, SUM(Shipment_Quantity) / SUM(Order_Quantity) AS shipment_ratio
FROM Orders
GROUP BY Product_ID
ORDER BY shipment_ratio DESC
LIMIT 3;

-- How many orders are pending for shipment?
SELECT COUNT(Order_ID) AS pending_orders
FROM Orders
WHERE Shipment_Date IS NULL;

-- Which warehouses holds the highest value of total stock?
SELECT p.Warehouse, SUM(i.Inventory_Level * p.Product_Price) AS total_stock_value
FROM Inventory i
JOIN Products p ON i.Product_ID = p.Product_ID
GROUP BY p.Warehouse
ORDER BY total_stock_value DESC;

-- Which Regions supply more products ?
SELECT Supplier_Location, COUNT(Supplier_ID) AS total_products_supplied
FROM Suppliers
GROUP BY Supplier_Location
ORDER BY total_products_supplied DESC;

-- List products that are supplied from Mumbai along with their suppliers 
SELECT p.Product_ID, p.Product_Category, s.Supplier_Name
FROM Orders o
INNER JOIN Products p ON o.Product_ID = p.Product_ID
INNER JOIN Suppliers s ON s.Supplier_ID = s.Supplier_ID
WHERE s.Supplier_Location = 'Mumbai';

-- Which orders were not shipped within 30 days?
SELECT o.Order_ID, o.Order_Date, o.Shipment_Date, DATEDIFF(o.Shipment_Date, o.Order_Date) AS Delay_Days
FROM Orders o
GROUP BY o.Order_ID, Delay_Days
HAVING DATEDIFF(o.Shipment_Date, o.Order_Date) > 30;

-- Which cities have less than 5 suppliers?
SELECT 
    Supplier_Location,
    COUNT(Supplier_ID) AS Total_Suppliers
FROM Suppliers
GROUP BY Supplier_Location
HAVING COUNT(Supplier_ID) < 5 
ORDER BY Total_Suppliers DESC;  
