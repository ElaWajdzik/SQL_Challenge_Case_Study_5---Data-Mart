---------------------------
--A. Data Cleansing Steps--
---------------------------

--Author: Ela Wajdzik
--Date: 28.10.2024
--Tool used: Microsoft SQL Server


DROP TABLE IF EXISTS clean_weekly_sales;
CREATE TABLE clean_weekly_sales (
	"id" INTEGER IDENTITY PRIMARY KEY,
	"week_date" DATE,
	"week_number" INTEGER,
	"month_number" INTEGER,
	"calendar_year" INTEGER,
	"age_band" VARCHAR(20),
	"demographic" VARCHAR(10),
	"avg_transaction" NUMERIC(10,2),
	"region" VARCHAR(13),
	"platform" VARCHAR(7),
	"customer_type" VARCHAR(8),
	"transactions" INTEGER,
	"sales" INTEGER
);


WITH CTE_weekly_sales AS (
	SELECT 
		--convert the data in the "week_date" column to date format
		DATEFROMPARTS(
			'20' + RIGHT(week_date, LEN(week_date) -  CHARINDEX('/', week_date, CHARINDEX('/', week_date, 1) + 1)),
			SUBSTRING(week_date, CHARINDEX('/', week_date, 1) +1, CHARINDEX('/', week_date, CHARINDEX('/', week_date, 1) + 1) - CHARINDEX('/', week_date, 1) - 1),
			LEFT(week_date, CHARINDEX('/', week_date, 1) -1)) AS clean_week_date,
		*
	FROM data_mart.weekly_sales)

INSERT INTO clean_weekly_sales(week_date, week_number, month_number, calendar_year, age_band, demographic, avg_transaction, region, platform, customer_type, transactions, sales)
SELECT 
	clean_week_date,
	--calculate the week number, assuming January 1st is the first day of the week
	CEILING(DATEPART(dayofyear, clean_week_date) / 7.0),
	MONTH(clean_week_date),
	YEAR(clean_week_date),
	--expand the age band information using details from the segment column
	CASE	
		WHEN segment LIKE '%1' THEN 'Young Adults'
		WHEN segment LIKE '%2' THEN 'Middle Aged'
		WHEN segment LIKE '%3' OR segment LIKE '%4' THEN 'Retirees'
		ELSE 'unknown'
	END,
	--expand demographic group information using details from the segment column.
	CASE
		WHEN segment LIKE 'C%' THEN 'Couples'
		WHEN segment LIKE 'F%' THEN 'Families'
		ELSE 'unknown'
	END,
	--calculate the average transaction value and convert the result to NUMERIC format
	CAST((sales * 1.0)/transactions AS NUMERIC(10,2)),
	region,
	platform,
	customer_type,
	transactions,
	sales
FROM CTE_weekly_sales;


SELECT TOP 10 *
FROM clean_weekly_sales;