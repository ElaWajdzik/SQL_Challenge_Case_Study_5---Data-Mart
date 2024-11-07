# <p align="center"> Case Study #5: 🛒 Data Mart
 
## <p align="center"> D. Bonus Question

Which areas of the business have the highest negative impact in sales metrics performance in 2020 for the 12 week before and after period?

- `region`
- `platform`
- `age_band`
- `demographic`
- `customer_type`

Do you have any further recommendations for Danny’s team at Data Mart or any interesting insights based off this analysis?

***
<br></br>

First of all, it would be good to compare the total sales over a 12-week period in 2020 and calculate the percentage variance between the `before` and `after` periods. The total difference between these two intervals is 152.3 million, representing a 2.14% reduction in sales. To identify the areas with the most significant negative impact, I focused on records with a percentage variance of less than -2% and where the value of the difference represents a significant percentage of the total variance.

![Zrzut ekranu 2024-11-04 155552](https://github.com/user-attachments/assets/ce0cb0ec-85a7-406c-baef-431f51fe887d)

I checked every area using the same query, changing the column name in two places to group by the respective column.

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
	WHERE week_number BETWEEN (24 - 12) AND (24 + 12 - 1)
	AND calendar_year = 2020
	)

SELECT
	region,
	SUM(CAST((CASE period WHEN 'after' THEN sales/1000000.0 ELSE 0 END) AS NUMERIC(6,2))) AS after_total_sales_mln,
	SUM(CAST((CASE period WHEN 'before' THEN sales/1000000.0 ELSE 0 END) AS NUMERIC(6,2))) AS before_total_sales_mln,
	SUM(CAST((CASE period WHEN 'after' THEN sales/1000000.0 ELSE 0 END) AS NUMERIC(6,2)))
		- SUM(CAST((CASE period WHEN 'before' THEN sales/1000000.0 ELSE 0 END) AS NUMERIC(6,2)))  AS sales_variance_mln,
	CAST(
		(SUM(CAST((CASE period WHEN 'after' THEN sales ELSE 0 END) AS BIGINT)) * 100.0 / 
			SUM(CAST((CASE period WHEN 'before' THEN sales ELSE 0 END) AS BIGINT))) - 100
		AS NUMERIC(5,2)) AS variance_percentage
FROM clean_weekly_sales_12_weeks
GROUP BY region
ORDER BY SUM(CAST((CASE period WHEN 'after' THEN sales ELSE 0 END) AS BIGINT)) * 100.0 / 
			SUM(CAST((CASE period WHEN 'before' THEN sales ELSE 0 END) AS BIGINT)) - 100;
 ```


Compare the periods across different `region`


Compare the periods across different `platform`


Compare the periods across different `age_band`


Compare the periods across different `demographic`


Compare the periods across different `customer_type`







<br></br>
***

Thank you for your attention! 🫶️

[Return to README ➔](https://github.com/ElaWajdzik/SQL_Challenge_Case_Study_5---Data-Mart/blob/main/README.md)
