# <p align="center"> Case Study #5: 🛒 Data Mart
 
## <p align="center"> C. Before & After Analysis

This technique is usually used when we inspect an important event and want to inspect the impact *before* and *after* a certain point in time.

Taking the `week_date` value of `2020-06-15` as the baseline week where the Data Mart sustainable packaging changes came into effect.

We would include all `week_date` values for `2020-06-15` as the start of the period after the change and the previous `week_date` values would be before


### 1. What is the total sales for the 4 weeks before and after `2020-06-15`? What is the growth or reduction rate in actual values and percentage of sales?

```sql
WITH clean_weekly_sales_4_weeks AS (
--part of data 4 weeks after and before deployment the change (2020-06-15)
	SELECT *,
		CASE 
			WHEN week_number BETWEEN 20 AND 23 THEN 'before'
			WHEN week_number BETWEEN 24 AND 27 THEN 'after'
		END AS period
	FROM clean_weekly_sales
	--filter the date which include in after or before period
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
```

#### Steps:
- I filtered the data form 2020 where week_number is between 20 and 27.
- Added a new column `period` with values `before` and `after` depending on `week_number` value.
- Using the data from CTE witch include only the data from interested weeks and have a new column `period`.
- I calculeted the total sales before and after, the sales variance and variance percentage.

#### Result:
![Zrzut ekranu 2024-11-04 132608](https://github.com/user-attachments/assets/c5392982-9310-47d7-ae6f-934135b79e2c)

According to the data, the total sales value declined over the 4-week period. The decrease amounted to 26 million, representing a 1.15% drop in value.

### 2. What about the entire 12 weeks before and after?

```sql
WITH clean_weekly_sales_12_weeks AS (
--part of data 12 weeks after and before deployment the change (2020-06-15)
	SELECT *,
		CASE 
			WHEN week_number BETWEEN 12 AND 23 THEN 'before'
			WHEN week_number BETWEEN 24 AND 35 THEN 'after'
		END AS period
	FROM clean_weekly_sales
	--filter the date which include in after or before period
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
```

#### Steps:
- I filtered the data form 2020 where week_number is between 12 and 35.
- Added a new column `period` with values `before` and `after` depending on `week_number` value.
- Using the data from CTE witch include only the data from interested weeks and have a new column `period`.
- I calculeted the total sales before and after, the sales variance and variance percentage.

#### Result:
![Zrzut ekranu 2024-11-04 135316](https://github.com/user-attachments/assets/7636693d-d4f6-4bf5-bc0f-92372ea3ea2d)


According to the data, the total sales value declined over the 12-week period. The decrease amounted to 152 million, representing a 2.14% drop in value.


### 3. How do the sale metrics for these 2 periods before and after compare with the previous years in 2018 and 2019?

```sql
--4-week period

WITH clean_weekly_sales_4_weeks AS (
--part of data 4 weeks after and before deployment the change (2020-06-15)
	SELECT *,
		CASE 
			WHEN week_number BETWEEN 20 AND 23 THEN 'before'
			WHEN week_number BETWEEN 24 AND 27 THEN 'after'
		END AS period
	FROM clean_weekly_sales
	--filter the date which include in after or before period
	WHERE week_number BETWEEN (24 - 4) AND (24 + 4 - 1))

SELECT
	calendar_year,
	SUM(CAST((CASE period WHEN 'after' THEN sales/1000000.0 ELSE 0 END) AS NUMERIC(6,2))) AS after_total_sales_mln,
	SUM(CAST((CASE period WHEN 'before' THEN sales/1000000.0 ELSE 0 END) AS NUMERIC(6,2))) AS before_total_sales_mln,
	SUM(CAST((CASE period WHEN 'after' THEN sales/1000000.0 ELSE 0 END) AS NUMERIC(6,2)))
		- SUM(CAST((CASE period WHEN 'before' THEN sales/1000000.0 ELSE 0 END) AS NUMERIC(6,2)))  AS sales_variance_mln,
	CAST(
		(SUM(CAST((CASE period WHEN 'after' THEN sales ELSE 0 END) AS BIGINT)) * 100.0 / 
			SUM(CAST((CASE period WHEN 'before' THEN sales ELSE 0 END) AS BIGINT))) - 100
		AS NUMERIC(5,2)) AS variance_percentage
FROM clean_weekly_sales_4_weeks
GROUP BY calendar_year
ORDER BY calendar_year;
```

#### Result:
![Zrzut ekranu 2024-11-04 155644](https://github.com/user-attachments/assets/17d4c534-4c8b-4a71-9b46-37db902d62dc)



```sql
--12-week period

WITH clean_weekly_sales_12_weeks AS (
--part of data 12 weeks after and before deployment the change (2020-06-15)
	SELECT *,
		CASE 
			WHEN week_number BETWEEN 12 AND 23 THEN 'before'
			WHEN week_number BETWEEN 24 AND 35 THEN 'after'
		END AS period
	FROM clean_weekly_sales
	--filter the date which include in after or before period
	WHERE week_number BETWEEN (24 - 12) AND (24 + 12 - 1))

SELECT
	calendar_year,
	SUM(CAST((CASE period WHEN 'after' THEN sales/1000000.0 ELSE 0 END) AS NUMERIC(6,2))) AS after_total_sales_mln,
	SUM(CAST((CASE period WHEN 'before' THEN sales/1000000.0 ELSE 0 END) AS NUMERIC(6,2))) AS before_total_sales_mln,
	SUM(CAST((CASE period WHEN 'after' THEN sales/1000000.0 ELSE 0 END) AS NUMERIC(6,2)))
		- SUM(CAST((CASE period WHEN 'before' THEN sales/1000000.0 ELSE 0 END) AS NUMERIC(6,2)))  AS sales_variance_mln,
	CAST(
		(SUM(CAST((CASE period WHEN 'after' THEN sales ELSE 0 END) AS BIGINT)) * 100.0 / 
			SUM(CAST((CASE period WHEN 'before' THEN sales ELSE 0 END) AS BIGINT))) - 100
		AS NUMERIC(5,2)) AS variance_percentage
FROM clean_weekly_sales_12_weeks
GROUP BY calendar_year
ORDER BY calendar_year;
```


#### Result:
![Zrzut ekranu 2024-11-04 155552](https://github.com/user-attachments/assets/ce0cb0ec-85a7-406c-baef-431f51fe887d)