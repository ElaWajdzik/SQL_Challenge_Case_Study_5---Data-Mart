
------------------------------
--C. Before & After Analysis--
------------------------------

--Author: Ela Wajdzik
--Date: 31.10.2024
--Tool used: Microsoft SQL Server

-- deployment date of the change
-- week_date = 2020-06-15 
-- week_number = 24 AND calendar_year = 2020

-- AFTER week_date >= 2020-06-15 
-- BEFORE week_date < 2020-06-15 

-- 1. What is the total sales for the 4 weeks before and after 2020-06-15? What is the growth or reduction rate in actual values and percentage of sales?


WITH clean_weekly_sales_4_weeks AS (
--select data from the 4 weeks before and after the deployment date (2020-06-15)
	SELECT *,
		CASE 
			WHEN week_number BETWEEN 20 AND 23 THEN 'before'
			WHEN week_number BETWEEN 24 AND 27 THEN 'after'
		END AS period
	FROM clean_weekly_sales
	--filter for dates that fall within this period
	WHERE calendar_year = 2020
	AND week_number BETWEEN (24 - 4) AND (24 + 4 - 1))

SELECT
	SUM(CAST((CASE period WHEN 'after' THEN sales ELSE 0 END) AS BIGINT)) AS after_total_sales,
	SUM(CAST((CASE period WHEN 'before' THEN sales ELSE 0 END) AS BIGINT)) AS before_total_sales,
	SUM(CAST((CASE period WHEN 'after' THEN sales ELSE 0 END) AS BIGINT))
		- SUM(CAST((CASE period WHEN 'before' THEN sales ELSE 0 END) AS BIGINT))  AS sales_variance,
	CAST(
		(SUM(CAST((CASE period WHEN 'after' THEN sales ELSE 0 END) AS BIGINT)) * 100.0 / 
			SUM(CAST((CASE period WHEN 'before' THEN sales ELSE 0 END) AS BIGINT))) - 100
		AS NUMERIC(5,2)) AS variance_percentage
FROM clean_weekly_sales_4_weeks;

-- 2. What about the entire 12 weeks before and after?

WITH clean_weekly_sales_12_weeks AS (
--select data from the 12 weeks before and after the deployment date (2020-06-15)
	SELECT *,
		CASE 
			WHEN week_number BETWEEN 12 AND 23 THEN 'before'
			WHEN week_number BETWEEN 24 AND 35 THEN 'after'
		END AS period
	FROM clean_weekly_sales
	--filter for dates that fall within this period
	WHERE calendar_year = 2020
	AND week_number BETWEEN (24 - 12) AND (24 + 12 - 1))

SELECT
	SUM(CAST((CASE period WHEN 'after' THEN sales ELSE 0 END) AS BIGINT)) AS after_total_sales,
	SUM(CAST((CASE period WHEN 'before' THEN sales ELSE 0 END) AS BIGINT)) AS before_total_sales,
	SUM(CAST((CASE period WHEN 'after' THEN sales ELSE 0 END) AS BIGINT))
		- SUM(CAST((CASE period WHEN 'before' THEN sales ELSE 0 END) AS BIGINT))  AS sales_variance,
	CAST(
		(SUM(CAST((CASE period WHEN 'after' THEN sales ELSE 0 END) AS BIGINT)) * 100.0 / 
			SUM(CAST((CASE period WHEN 'before' THEN sales ELSE 0 END) AS BIGINT))) - 100
		AS NUMERIC(5,2)) AS variance_percentage
FROM clean_weekly_sales_12_weeks;


-- 3. How do the sale metrics for these 2 periods before and after compare with the previous years in 2018 and 2019?

--4 weeks

WITH clean_weekly_sales_4_weeks AS (
--select data from the 4 weeks before and after the deployment date (2020-06-15)
	SELECT *,
		CASE 
			WHEN week_number BETWEEN 20 AND 23 THEN 'before'
			WHEN week_number BETWEEN 24 AND 27 THEN 'after'
		END AS period
	FROM clean_weekly_sales
	--filter for dates that fall within this period
	WHERE week_number BETWEEN (24 - 4) AND (24 + 4 - 1))

SELECT
	calendar_year,
	SUM(CAST((CASE period WHEN 'after' THEN sales ELSE 0 END) AS BIGINT)) AS after_total_sales,
	SUM(CAST((CASE period WHEN 'before' THEN sales ELSE 0 END) AS BIGINT)) AS before_total_sales,
	SUM(CAST((CASE period WHEN 'after' THEN sales ELSE 0 END) AS BIGINT))
		- SUM(CAST((CASE period WHEN 'before' THEN sales ELSE 0 END) AS BIGINT))  AS sales_variance,
	CAST(
		(SUM(CAST((CASE period WHEN 'after' THEN sales ELSE 0 END) AS BIGINT)) * 100.0 / 
			SUM(CAST((CASE period WHEN 'before' THEN sales ELSE 0 END) AS BIGINT))) - 100
		AS NUMERIC(5,2)) AS variance_percentage
FROM clean_weekly_sales_4_weeks
GROUP BY calendar_year
ORDER BY calendar_year;

--12 weeks

WITH clean_weekly_sales_12_weeks AS (
--select data from the 12 weeks before and after the deployment date (2020-06-15)
	SELECT *,
		CASE 
			WHEN week_number BETWEEN 12 AND 23 THEN 'before'
			WHEN week_number BETWEEN 24 AND 35 THEN 'after'
		END AS period
	FROM clean_weekly_sales
	--filter for dates that fall within this period
	WHERE week_number BETWEEN (24 - 12) AND (24 + 12 - 1))

SELECT
	calendar_year,
	SUM(CAST((CASE period WHEN 'after' THEN sales ELSE 0 END) AS BIGINT)) AS after_total_sales,
	SUM(CAST((CASE period WHEN 'before' THEN sales ELSE 0 END) AS BIGINT)) AS before_total_sales,
	SUM(CAST((CASE period WHEN 'after' THEN sales ELSE 0 END) AS BIGINT))
		- SUM(CAST((CASE period WHEN 'before' THEN sales ELSE 0 END) AS BIGINT))  AS sales_variance,
	CAST(
		(SUM(CAST((CASE period WHEN 'after' THEN sales ELSE 0 END) AS BIGINT)) * 100.0 / 
			SUM(CAST((CASE period WHEN 'before' THEN sales ELSE 0 END) AS BIGINT))) - 100
		AS NUMERIC(5,2)) AS variance_percentage
FROM clean_weekly_sales_12_weeks
GROUP BY calendar_year
ORDER BY calendar_year;
