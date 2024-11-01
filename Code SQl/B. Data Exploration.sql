
-----------------------
--B. Data Exploration--
-----------------------

--Author: Ela Wajdzik
--Date: 30.10.2024
--Tool used: Microsoft SQL Server


-- 1. What day of the week is used for each week_date value?

-- set Monday as the first day of the week
SET DATEFIRST 1;

SELECT 
	DATENAME(weekday, week_date) AS week_day,
	--check how many obserwations come from this specific day
	COUNT(*) AS number_of_rows
FROM clean_weekly_sales
GROUP BY DATENAME(weekday, week_date);

--2. What range of week numbers are missing from the dataset?

SELECT DISTINCT week_number
FROM clean_weekly_sales
ORDER BY week_number;

-- the missing values range from 1 to 11 and from 37 to 53

--3. How many total transactions were there for each year in the dataset?

SELECT
	calendar_year,
	SUM(transactions) AS total_transactions
FROM clean_weekly_sales
GROUP BY calendar_year
ORDER BY calendar_year;

--4. What is the total sales for each region for each month?

SELECT 
	region,
	month_number,
	--change the type of sales from INT to BIGINT because of the integer range
	SUM(CAST(sales AS BIGINT)) AS total_sales
FROM clean_weekly_sales
GROUP BY region, month_number
ORDER BY region, month_number;

--5. What is the total count of transactions for each platform

SELECT
	platform,
	SUM(transactions) AS total_transactions
FROM clean_weekly_sales
GROUP BY platform;

--6. What is the percentage of sales for Retail vs Shopify for each month?

WITH CTE_month_platform_sales AS (
--sales for each platform by month
	SELECT
		month_number,
		platform,
		SUM(CAST(sales AS BIGINT)) AS total_m_p_sales
	FROM clean_weekly_sales
	GROUP BY month_number, platform),
	
CTE_pivot AS (
--the percentage of sales per platform in a month, relative to the total monthly sales
	SELECT 
		*,
		CAST((total_m_p_sales * 100.0 / SUM(total_m_p_sales) OVER (PARTITION BY month_number)) AS NUMERIC(5,2)) AS perc_month_sales
	FROM CTE_month_platform_sales)

SELECT 
	month_number,
	MAX(CASE platform WHEN 'Shopify' THEN perc_month_sales ELSE 0 END) AS shopify_perc_month_sales,
	MAX(CASE platform WHEN 'Retail' THEN perc_month_sales ELSE 0 END) AS retail_perc_month_sales
FROM CTE_pivot
GROUP BY month_number
ORDER BY month_number;

--7. What is the percentage of sales by demographic for each year in the dataset?

WITH CTE_year_demographic_sales AS (
--sales for each year and demographic group
	SELECT 
		calendar_year,
		demographic,
		SUM(CAST(sales AS BIGINT)) AS total_y_d_sales
	FROM clean_weekly_sales
	GROUP BY calendar_year, demographic),

CTE_pivot AS (
--the percentage of sales per demographic group in a year, relative to the total yearly sales
	SELECT 
		*,
		CAST((total_y_d_sales * 100.0 / SUM(total_y_d_sales) OVER(PARTITION BY calendar_year)) AS NUMERIC(5,2)) AS perc_year_sales
	FROM CTE_year_demographic_sales)

SELECT 
	calendar_year,
	MAX(CASE demographic WHEN 'Families' THEN perc_year_sales ELSE 0 END) AS families_perc_sales,
	MAX(CASE demographic WHEN 'Couples' THEN perc_year_sales ELSE 0 END) AS couples_perc_sales,
	MAX(CASE demographic WHEN 'unknown' THEN perc_year_sales ELSE 0 END) AS unknown_perc_sales
FROM CTE_pivot
GROUP BY calendar_year
ORDER BY calendar_year;

--8. Which age_band and demographic values contribute the most to Retail sales?

WITH CTE_age_demographic_sales AS (
--sales for each demographic group and age band
	SELECT 
		age_band,
		demographic,
		SUM(CAST(sales AS BIGINT)) AS total_a_d_sales
	FROM clean_weekly_sales
	--filter the data to include only entries related to the Retail platform
	WHERE platform = 'Retail'
	GROUP BY age_band, demographic)

SELECT 
	*,
	CAST((total_a_d_sales * 100.0 / SUM(total_a_d_sales) OVER ()) AS NUMERIC(5,2)) AS perc_sales
FROM CTE_age_demographic_sales
ORDER BY (total_a_d_sales * 100.0 / SUM(total_a_d_sales) OVER ()) DESC;

--9. Can we use the avg_transaction column to find the average transaction size for each year for Retail vs Shopify? If not - how would you calculate it instead?

SELECT 
	calendar_year,
	platform,
	CAST(SUM(CAST(sales AS BIGINT)) * 1.0 / SUM(transactions) AS NUMERIC(6,2)) AS avg_transaction
FROM clean_weekly_sales
GROUP BY calendar_year, platform
ORDER BY platform, calendar_year;
