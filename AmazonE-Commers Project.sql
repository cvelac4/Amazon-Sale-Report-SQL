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

-- Convert currency to USD. 
SELECT Amount * 1.1 AS Price_In_USD
FROM asales;

-- Calculate profit margins using
SELECT Oty, Category, Amount * 70 as 'percentage'   -- This will calculate profit margins using a static cost multiplier (e.g., 70% of Amount as cost).
FROM asales;

-- Building a month column.
SELECT EXTRACT(MONTH FROM Date) as Month     -- This will create a column for Month based off the Date data.
FROM asales;       

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

