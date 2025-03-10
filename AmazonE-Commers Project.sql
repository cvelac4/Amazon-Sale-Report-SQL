CREATE DATABASE ecom;       -- Creating a data base called ecom.
USE ecom;         -- Connecting to the data base called ecom.

CREATE TABLE asales(         -- Creating a table called asales with values that correspond with the columns in the .csv data file for Amazon sales. 
Index_Value INT,             -- With their corresponding data types and how many values will be printed out when the code is run. 
Order_Id VARCHAR(50),
Date DATE,
STATUS VARCHAR(50),
Fulfilment VARCHAR(50),
Sales_Channel VARCHAR(50),
Ship_Service_Level VARCHAR(50),
Style VARCHAR(50),
SKU VARCHAR(50),
Category VARCHAR (50),
Size VARCHAR(10),
ASIN VARCHAR(20),
Courier_Status VARCHAR(50),
Qty INT,
Currency VARCHAR(50),
Amount FLOAT,
Ship_City VARCHAR(50),
Ship_State VARCHAR(50),
Ship_Postal_code INT,
Ship_Country VARCHAR(50),
Promotion_ids VARCHAR(50),
B2B INT,
Fulfilled_By VARCHAR(50)
);

-- Changing the name of one of my columns. 
ALTER TABLE asales RENAME COLUMN Oty TO Qty ;
ALTER TABLE asales CHANGE COLUMN Qty Qty INT;

-- Look at whole table.
SELECT * FROM asales;      -- This will run the code in the table asales and you will be able to see the data from the .csv data file. 

-- Phase #1  Data Exploration and Quality Check 
-- Replacing blank cells.
SELECT Order_Id,COALESCE(NULLIF(asales.Fulfilled_By,''), 'UNKNOWN') AS Fulfilled_By     -- This will replaced any empty cells in any column I choses and replace it with what I right in, 'UNKNOWN', the singal quotations. 
FROM asales; 

SELECT Order_Id,COALESCE(NULLIF(asales.Promotion_ids,''), 'UNKNOWN') AS Promotion_ids   
FROM asales; 

SELECT Order_Id,COALESCE(NULLIF(asales.Courier_Status,''), 'UNKNOWN') AS Courier_Status   
FROM asales;

-- Checking for null values. 
SELECT Order_Id, COALESCE(Fulfilled_By, 'UN') as Fulfilled_By,COALESCE(Amount,'0') as Amount, COALESCE(Courier_Status,'UN') as Courier_Status, COALESCE(Size,'UN') as Size     -- Checking for Null values and replacing them with what is in cuotations and naming each column correctily and calling the table asales to run the code.
FROM asales;

SELECT Amount, Ifnull(Amount, '0')Amount   -- Another way to find and replace null values in columns with actual values. 
FROM asales; 

SELECT Fulfilled_By, Ifnull(Fulfilled_By, 'UN')Fulfilled_by
FROM asales; 

SELECT Courier_Status, Ifnull(Courier_Status, 'UN')Courier_Status
FROM asales; 

SELECT Size, Ifnull(Size, 'UN')Size 
FROM asales; 

-- Looking for duplicate values and deleting them. 
SELECT SKU, ASIN,         --  The query will find the count of records that have the same values.
COUNT(*) FROM asales
GROUP BY SKU, ASIN
HAVING COUNT(*)>1;

SELECT SKU, ASIN,         -- Return unique rows and the count. 
COUNT(*) FROM asales
GROUP BY SKU, ASIN;


CREATE TABLE new_asales AS     -- A way to delete duplicate records is to add the unique records into a new table and use it to replace the old table.
SELECT SKU, ASIN
FROM asales
GROUP BY SKU, ASIN;

-- Checking columns for any incorrect values. 
SELECT Category, Status, Currency   -- This query I am using to check myself for inconsistant or incorrect values. They all appear to be correct values and none are missing. 
FROM asales; 

-- Phase #2 Data Cleaning and Transformation 
-- Convert currency to USD. 
SELECT Amount * 1.1 AS Price_In_USD    -- This will change the current currency in the Amazon sales data from INR to USD.
FROM asales;

-- Calculate profit margins using
SELECT Qty, Category, Amount * 70 as 'percentage'   -- This will calculate profit margins using a static cost multiplier (e.g., 70% of Amount as cost).
FROM asales;

-- Building a month column.
SELECT EXTRACT(MONTH FROM Date) as Month     -- This will create a column for Month based off the Date data.
FROM asales;       

-- Phase #3  Business Questions and Insights 
-- Category Performance
-- The highest revenew category and it's value.  
SELECT Category, SUM(Qty) AS total_quantity, SUM(Amount * Qty) AS total_revenue   -- This will tell you which category has the highest reveneue. 
FROM asales 
GROUP BY Category
ORDER BY (SUM(Qty) + SUM(Amount * Qty)) DESC
LIMIT 1; 

-- The low performance categores and their vales. 
SELECT Category,                                           -- This will tell you which categories has the lowes preformance and needs attention. 
       MIN(total_revenue) AS min_revenue, 
       MIN(total_quantity) AS min_quantity 
FROM (
SELECT Category, SUM(Amount * Qty) AS total_revenue, SUM(Qty) AS total_quantity
FROM asales 
GROUP BY Category
) AS Category_totals
GROUP BY Category 
HAVING min_revenue = MIN(total_revenue) 
AND min_quantity = MIN(total_quantity); 

-- Seasonal Sales Trends
-- Monthly Sales Trend
SELECT                       -- To calculate the monthly sales trend, group the sales by year and month and sum the sales amounts
    YEAR(Date) AS Year,
    MONTH(Date) AS Month,
    SUM(Amount) AS Monthly_Sales
FROM asales
GROUP BY 
    YEAR(Date), 
    MONTH(Date)
ORDER BY 
    Year, 
    Month;
    
    -- Weekly Sales Trend
SELECT                   -- To calculate the weekly sales trend, group the sales by year and week and sum the sales amounts
    YEAR(Date) AS Year,
    WEEK(Date) AS Week,
    SUM(Amount) AS Weekly_Sales
FROM asales
GROUP BY 
    YEAR(Date), 
    WEEK(Date)
ORDER BY 
    Year, 
    Week;
  
-- To find the days with the highest sales
SELECT                              -- This will tell you which days are the peak period sales.  (There are 4 days that peak)
    Date,
    SUM(Amount) AS Daily_Sales
FROM asales
GROUP BY Date
ORDER BY 
    Daily_Sales DESC
    LIMIT 10;      -- Top 10 peak sales days
   
-- To find the weeks with the highest sales
SELECT                             -- This will tell you which weeks are the peak period sales.  (There is 1 week that peak)
    YEAR(Date) AS Year,
    WEEK(Date) AS Week,
    SUM(Amount) AS Weekly_Sales
FROM asales
GROUP BY 
    YEAR(Date), 
    WEEK(Date)
ORDER BY 
    Weekly_Sales DESC
    LIMIT 10; -- Top 10 peak sales weeks
  
-- To find the months with the highest sales
SELECT                    -- This will tell you which months are the peak period sales.  (There is 1 month that peak)
    YEAR(Date) AS Year,
    MONTH(Date) AS Month,
    SUM(Amount) AS Monthly_Sales
FROM asales
GROUP BY 
    YEAR(Date), 
    MONTH(Date)
ORDER BY 
    Monthly_Sales DESC
	LIMIT 10; -- Top 10 peak sales months
    
-- Fulfillment Efficiency
-- Compare Sales and Revenue
SELECT                   -- Total Sales and Revenue by Fulfilled_By.To calculate the total number of sales and total revenue for each Fulfilled_By.
	Fulfilled_By,        -- The blank cell is an 'UNKNOWN' value but was having dificulty adding the text into the cell. 
    COUNT(Order_Id) AS Total_Sales, -- Total number of sales
    SUM(Amount) AS Total_Revenue   -- Total revenue
FROM asales
GROUP BY Fulfilled_By;

-- Average Revenue per Sale
SELECT                 -- To calculate the average revenue per sale for each fulfillment method. 
    Fulfilled_By,
    AVG(Amount) AS Avg_Revenue_Per_Sale
FROM asales
GROUP BY Fulfilled_By;

-- Monthly Sales and Revenue
SELECT                -- To analyze trends over time, group by month and Fulfilled_By.
    YEAR(Date) AS Year,
    MONTH(Date) AS Month,
    Fulfilled_By,
    COUNT(Order_Id) AS Monthly_Sales,
    SUM(Amount) AS Monthly_Revenue
FROM asales
GROUP BY 
    YEAR(Date), 
    MONTH(Date), 
    Fulfilled_By
ORDER BY 
    Year, 
    Month, 
    Fulfilled_By;
   
--  Count of Canceled or Lost Orders
SELECT                -- To count the number of canceled or lost orders for each Fulfilled_By. 
    Fulfilled_By,
    COUNT(CASE WHEN STATUS = 'Canceled' THEN 1 END) AS Canceled_Orders,
    COUNT(CASE WHEN STATUS = 'Lost' THEN 1 END) AS Lost_Orders
FROM asales
GROUP BY Fulfilled_By;

--  Percentage of Canceled or Lost Orders
SELECT              -- To calculate the percentage of canceled or lost orders for each Fulfilled_By. 
    Fulfilled_By,
    COUNT(CASE WHEN STATUS = 'Canceled' THEN 1 END) * 100.0 / COUNT(*) AS Canceled_Percentage,
    COUNT(CASE WHEN STATUS = 'Lost' THEN 1 END) * 100.0 / COUNT(*) AS Lost_Percentage
FROM asales
GROUP BY Fulfilled_By;

-- Total Orders and Canceled/Lost Orders
SELECT           -- To provide a comprehensive view, include total orders alongside canceled and lost orders
    Fulfilled_By,
    COUNT(*) AS Total_Orders,
    COUNT(CASE WHEN STATUS = 'Canceled' THEN 1 END) AS Canceled_Orders,
    COUNT(CASE WHEN STATUS = 'Lost' THEN 1 END) AS Lost_Orders
FROM asales
GROUP BY Fulfilled_By;

-- Product Size Analysis
--  Total Quantity Sold by Size
SELECT        -- To calculate the total quantity sold for each product size.
    Size,
    SUM(Qty) AS Total_Quantity_Sold
FROM asales
GROUP BY Size
ORDER BY Total_Quantity_Sold DESC;

--  Most Popular Sizes
SELECT             -- To find the top N most popular sizes. 
    Size,
    SUM(Qty) AS Total_Quantity_Sold
FROM asales
GROUP BY Size
ORDER BY 
    Total_Quantity_Sold DESC
	LIMIT 5;             -- Change 5 to the desired number of top sizes.

-- Percentage Contribution of Each Size
SELECT             -- To calculate the percentage contribution of each size to total sales
    Size,
    SUM(Qty) AS Total_Quantity_Sold,
    ROUND(SUM(Qty) * 100.0 / (SELECT SUM(Qty) FROM asales), 2) AS Quantity_Percentage
FROM asales
GROUP BY Size
ORDER BY Total_Quantity_Sold DESC;

-- Courier Impact on Revenue
--  Lost Revenue Due to Canceled or Lost Orders
SELECT SUM(Amount) AS Lost_Revenue     -- To calculate the revenue lost due to canceled or lost orders. 
FROM asales
WHERE STATUS IN ('Canceled', 'Lost');

-- Percentage of Revenue Impacted by Courier Status
SELECT      -- To calculate the percentage of total revenue impacted by each courier status.
    Status,
    SUM(Amount) AS Total_Revenue,
    ROUND(SUM(Amount) * 100.0 / (SELECT SUM(Amount) FROM asales), 2) AS Revenue_Percentage
FROM asales
GROUP BY Status
ORDER BY Total_Revenue DESC;

-- B2B vs. B2C Sales
--  Percentage Contribution of B2B and B2C to Total Revenue and Quantity
SELECT          -- To calculate the percentage contribution of B2B and B2C transactions to total revenue and quantity sold.
    Currency,
    SUM(Amount) AS Total_Revenue,
    ROUND(SUM(Amount) * 100.0 / (SELECT SUM(Amount) FROM asales), 2) AS Revenue_Percentage,
    SUM(Qty) AS Total_Quantity_Sold,
    ROUND(SUM(Qty) * 100.0 / (SELECT SUM(Qty) FROM asales), 2) AS Quantity_Percentage
FROM asales
GROUP BY Currency;

--  Monthly Revenue and Quantity Sold by Transaction Type
SELECT    -- To analyze trends over time, group by month and transaction type. 
    YEAR(Date) AS Year,
    MONTH(Date) AS Month,
    Currency,
    SUM(Amount) AS Monthly_Revenue,
    SUM(Qty) AS Monthly_Quantity_Sold
FROM asales
GROUP BY 
    YEAR(Date), 
    MONTH(Date), 
    Currency
ORDER BY 
    Year, 
    Month, 
    Currency;
    
-- Phase #4 Advanced Reporting and Visualization 
-- Sales Leaderboard
--  Top 5 Products by Revenue
SELECT       -- To calculate the total revenue for each product and identify the top 5.
    Order_Id,
    Category,
    SUM(Amount) AS Total_Revenue
FROM asales
GROUP BY 
    Order_Id,
    Category
ORDER BY Total_Revenue DESC
LIMIT 5; -- Top 5 products

--  Top 5 Products by Quantity
SELECT  -- -- To calculate the total quantity for each product and identify the top 5.
    Order_Id,
    Category, 
    SUM(Qty) AS Total_Quantity_Sold
FROM asales
GROUP BY 
    Order_Id, 
    Category 
ORDER BY 
    Total_Quantity_Sold DESC
    LIMIT 5; -- Top 5 products
    
-- Category Trends
-- Pivot Table for Monthly Revenue by Category
SELECT          -- This is to create a pivot table, use conditional aggregation to display each category as a separate column.
    YEAR(Date) AS Year,
    MONTH(Date) AS Month,
    SUM(CASE WHEN Category = 'Set' THEN Amount ELSE 0 END) AS Set_Category,
    SUM(CASE WHEN Category = 'kurta' THEN Amount ELSE 0 END) AS Kurta,
    SUM(CASE WHEN Category = 'West Dress' THEN Amount ELSE 0 END) AS West_Dress,
    SUM(CASE WHEN Category = 'Top' THEN Amount ELSE 0 END) AS Top,
	SUM(CASE WHEN Category = 'Bottom' THEN Amount ELSE 0 END) AS Bottom,
	SUM(CASE WHEN Category = 'Saree' THEN Amount ELSE 0 END) AS Saree,
	SUM(CASE WHEN Category = 'Blouse' THEN Amount ELSE 0 END) AS Blouse,
	SUM(CASE WHEN Category = 'Ethnic Dress' THEN Amount ELSE 0 END) AS Ethnic_Dress
FROM asales
GROUP BY YEAR(Date), MONTH(Date)
ORDER BY Year, Month;

-- Combined Ranking for Revenue and Quantity
WITH asales AS (
    SELECT            -- To combine rankings for both revenue and quantity sold. Here you will get the sums for Amount and Qty.  
        Category,
        SUM(Amount) AS Total_Revenue,
        SUM(Qty) AS Total_Quantity_Sold
    FROM asales
    GROUP BY Category
)
SELECT 
    Category,      -- This is to caculate the Amount and Qty ranking using Rank() on Total_Revenue and Total_Quantity_Sold. 
    Total_Revenue,
    RANK() OVER (ORDER BY Total_Revenue DESC) AS Revenue_Rank,
    Total_Quantity_Sold,
    RANK() OVER (ORDER BY Total_Quantity_Sold DESC) AS Quantity_Rank
FROM asales
ORDER BY Revenue_Rank, Quantity_Rank;

-- Performance by Fulfillment
-- Total Revenue by Fulfillment Method
SELECT        -- This is to  calculate the total revenue for each fulfillment method. 
    Fulfilled_By,
    SUM(Amount) AS Total_Revenue
FROM asales
GROUP BY Fulfilled_By;

-- Rank Fulfillment Methods by Revenue
SELECT        -- Use the RANK() window function to rank fulfillment methods based on total revenue
    Fulfilled_By,
    SUM(Amount) AS Total_Revenue,
    RANK() OVER (ORDER BY SUM(Amount) DESC) AS Revenue_Rank
FROM asales
GROUP BY Fulfilled_By;

-- Phase #5 Recommendations and Business Strategy
--  Total Revenue and Quantity Sold by Category
SELECT     -- Calculate total revenue and quantity sold for each category. 
    Category,
    SUM(Amount) AS Total_Revenue,
    SUM(Qty) AS Total_Quantity_Sold,
    AVG(Amount) AS Avg_Revenue_Per_Order
FROM asales
GROUP BY Category
ORDER BY Total_Revenue ASC; -- Sort by lowest revenue first

-- Calculate Total Quantity Sold and Average Monthly Sales
SELECT       -- First, calculate the total quantity sold and average monthly sales for each product. 
    Order_Id,
    Category, -- Optional, if available
    SUM(Qty) AS Total_Quantity_Sold,
    AVG(Qty) AS Avg_Monthly_Sales
FROM 
    asales
GROUP BY 
    Order_Id, 
    Category;
    
    -- Customer Satisfaction by Fulfillment Method
   SELECT      -- Calculate the average customer rating for each fulfillment method and identify methods with low ratings. 
    Fulfilled_By,
    AVG(STATUS) AS Avg_Customer_Rating
FROM asales
GROUP BY Fulfilled_By
HAVING Avg_Customer_Rating < 3; -- Adjust threshold as needed

--  Lost Shipments by Product Category
SELECT       -- Identify which product categories have the highest lost shipment rates. 

    category,
    COUNT(CASE WHEN STATUS = 'Lost' THEN 1 END) AS Lost_Shipments,
    COUNT(*) AS Total_Shipments,
    COUNT(CASE WHEN STATUS = 'Lost' THEN 1 END) * 100.0 / COUNT(*) AS Lost_Shipment_Percentage
FROM asales
GROUP BY Category
ORDER BY Lost_Shipment_Percentage DESC;

-- Top Products in B2B Sales
SELECT     -- Identify the top-selling products in B2B transactions:
    Order_Id,
    Category, 
    SUM(Qty) AS Total_Quantity_Sold,
    SUM(Amount) AS Total_Revenue
FROM asales
WHERE 
    Currency = 'B2B'
GROUP BY Order_Id, Category
ORDER BY 
    Total_Revenue DESC
    LIMIT 10; -- Adjust limit as needed