
-----------------------
--B. Data Exploration--
-----------------------


-- 1. What day of the week is used for each week_date value?

-- set MOnday as a first day of the week
SET DATEFIRST 1;

SELECT 
	DATEPART(weekday, week_date) AS week_day,
	COUNT(*) As number_of_rows
FROM clean_weekly_sales
GROUP BY DATEPART(weekday, week_date)

--2. What range of week numbers are missing from the dataset?

SELECT week_number
FROM clean_weekly_sales
GROUP BY week_number
ORDER BY week_number;

-- the missing values are in range 1 to 11 and 37 to 53

--3. How many total transactions were there for each year in the dataset?

SELECT
	calendar_year,
	COUNT(*) AS number_of_transactions
FROM clean_weekly_sales
GROUP BY calendar_year;

--4. What is the total sales for each region for each month?

SELECT 
	region,
	month_number,
	SUM(CAST(sales AS NUMERIC(18,0))) AS total_sales
FROM clean_weekly_sales
GROUP BY region, month_number;

--5. What is the total count of transactions for each platform

SELECT
	platform,
	COUNT(*) AS number_of_transactions
FROM clean_weekly_sales
GROUP BY platform;

--6. What is the percentage of sales for Retail vs Shopify for each month?