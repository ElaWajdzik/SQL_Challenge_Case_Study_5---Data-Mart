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


### Compare the periods across different `region`

![Zrzut ekranu 2024-11-02 183308](https://github.com/user-attachments/assets/dbef8e68-cba6-4e2d-a33c-b75984cedf3a)

The regions *ASIA* and *OCEANIA* have the highest negative impact on sales metrics. The percentage variance in this regions is less than -2%,  and they account for 81.8% of the total sales difference.


### Compare the periods across different `platform`

![Zrzut ekranu 2024-11-07 235812](https://github.com/user-attachments/assets/d88ce0f5-a16f-41e2-a164-986133175af8)

Most sales (around 95%) come from the *Retail* platform. I don't think any specific platform has the highest negative impact on sales metrics. In the future, it would be beneficial to increase purchases through the *Shopify* platform and explore other platforms to sell products. Diversifying income sources helps build a healthy and resilient business.

### Compare the periods across different `age_band` and `demographic`

![Zrzut ekranu 2024-11-07 235852](https://github.com/user-attachments/assets/92207cec-133b-418e-982f-4d1eeb6fd445)

![Zrzut ekranu 2024-11-07 235933](https://github.com/user-attachments/assets/eedc3bf8-8e42-4e2b-ad48-99870f5ca626)

A significant number of customers are still in the *unknown group*, which has a high negative impact on sales. The percentage variance in this group is less than -2%, accounting for 60% of the total sales difference.

This situation may indicate that customers in the *unknown group* are not strongly attached to our brand. In this case, it would be wise to invest extra effort in encouraging these customers to share more about who they are. On the other hand, it might also suggest that we are not acquiring as many new customers in the *unknown group* as before. To address this, focusing more on outbound marketing efforts could be beneficial.


### Compare the periods across different `customer_type`

![Zrzut ekranu 2024-11-08 000006](https://github.com/user-attachments/assets/8fd11c96-8717-4135-8915-7ce1189bef9d)

Two signnefent `customer_type` (*Guest* and *Existing*) have a high negative impact on sales.

### The next step
Do you have any further recommendations for Danny’s team at Data Mart or any interesting insights based off this analysis?

Investigate regions *ASIA* and *OCEANIA*:
- Examine which areas of the business are driving the highest negative impact on sales.
- Compare sales trends over a 12-week period across different years to identify patterns or anomalies.

Dive deeper into customer data:
- Analyze the dynamics of acquiring new customers over time -> are we attracting fewer new customers, or are there seasonal trends to consider?
- Investigate how and when customers provide information about their `age_band` and `demographic`. This can help identify opportunities to improve data coverage and accuracy for better insights in the future.

Prepare an interactive dashboard that illustrates sales trends over time across all areas of the business.
 
***

Thank you for your attention! 🫶️

[Return to README ➔](https://github.com/ElaWajdzik/SQL_Challenge_Case_Study_5---Data-Mart/blob/main/README.md)
