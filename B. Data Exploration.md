# <p align="center"> Case Study #5: 🛒 Data Mart
 
## <p align="center"> B. Data Exploration


### 1. What day of the week is used for each week_date value?

```sql
SELECT 
	DATENAME(weekday, week_date) AS week_day,
	--check how many obserwations come from this specific day
	COUNT(*) AS number_of_rows
FROM clean_weekly_sales
GROUP BY DATENAME(weekday, week_date);
```

#### Result:

week_day | number_of_rows
-- | --
Monday | 17 117

All data comes from Mondays.

### 2. What range of week numbers are missing from the dataset?

```sql
SELECT DISTINCT week_number
FROM clean_weekly_sales
ORDER BY week_number;
```
#### Result:

week_number |
-- |
12 |
13 |
14 |
15 |
... |
34 |
35 |
36 |


The missing ``week_number`` values range from 1 to 11 and from 37 to 53.

### 3. How many total transactions were there for each year in the dataset?

```sql
SELECT
	calendar_year,
	SUM(transactions) AS total_transactions
FROM clean_weekly_sales
GROUP BY calendar_year
ORDER BY calendar_year;
```

#### Result:
![Zrzut ekranu 2024-10-31 131150](https://github.com/user-attachments/assets/375ad2df-991b-4460-9263-881f6b6f8a22)

The number of transactions for each year was around 350 milion.

### 4. What is the total sales for each region for each month?

```sql
SELECT 
	region,
	month_number,
	--change the type of sales from INT to BIGINT because of the integer range
	SUM(CAST(sales AS BIGINT)) AS total_sales
FROM clean_weekly_sales
GROUP BY region, month_number
ORDER BY region, month_number;
```

#### Result:
*Sample of results only for region AFRICA*

![Zrzut ekranu 2024-10-31 131455](https://github.com/user-attachments/assets/e4f00f2a-c2d3-44a4-af42-5f4a0fb27185)


To proceed with further analysis, it is beneficial to calculate, for example, the percentage of total sales in each region or the percentage of total sales in each month. The percentage better illustrates the differences between various months and regions.

### 5. What is the total count of transactions for each platform

```sql
SELECT
	platform,
	SUM(transactions) AS total_transactions
FROM clean_weekly_sales
GROUP BY platform;
```

#### Result:
![Zrzut ekranu 2024-10-31 145730](https://github.com/user-attachments/assets/e0a8c430-5128-4e00-9451-b531bfa75005)


Most transactions come from the `Retail` platform. 


### 6. What is the percentage of sales for Retail vs Shopify for each month?

```sql
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
```

#### Steps:
- Calculated the total sales for each platform and each month. To calculate the sum of sales, it is necessary to cast sales to the `BIGINT`, because the `INT` range is not sufficient.
- Calculated the percentage of sales per platform for each month in the `perc_month_sales` column.
- Displayed the information about the percentage of sales in a pivot table.

#### Result:
![Zrzut ekranu 2024-10-31 145900](https://github.com/user-attachments/assets/cebbb3db-5905-4c18-a0c2-718e01265c19)


In every months, sales from `Retail` platform account for 97% of total sales.

### 7. What is the percentage of sales by demographic for each year in the dataset?

```sql
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
```

#### Steps:
- Calculated the total sales for each demographic group and each year. To calculate the sum of sales, it is necessary to cast sales to the `BIGINT`, because the `INT` range is not sufficient.
- Calculated the percentage of sales per demographic group for each year in the `perc_year_sales` column.
- Displayed the percentage of sales in a pivot table.

#### Result:
![Zrzut ekranu 2024-11-02 180513](https://github.com/user-attachments/assets/e3a522cc-6feb-4219-985c-c32041147af7)


In every year, sales from Families account for around 32% of total sales, while Couples account for about 27%. Over all three years, sales from `unknown` customers account for around 40% of total sales.

### 8. Which age_band and demographic values contribute the most to Retail sales?

```sql
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
```

#### Steps:
- Calculated the total sales for each unique combination of `age_band` and `demographic` for the `Retail` platform. 
- Computed each combination’s percentage of the total Retail sales, ordering results by descending percentage, so the most significant contributors appear at the top.

#### Result:
![Zrzut ekranu 2024-11-02 180528](https://github.com/user-attachments/assets/5b720855-4ca4-497b-ad8b-689852c2619d)


Apart from the `unknown` group, the largest portion of total sales comes from `Retirees` & `Families`, accounting for 16,73% of total sales. 

### 9. Can we use the avg_transaction column to find the average transaction size for each year for Retail vs Shopify? If not - how would you calculate it instead?

```sql
SELECT 
	calendar_year,
	platform,
	CAST(SUM(CAST(sales AS BIGINT)) * 1.0 / SUM(transactions) AS NUMERIC(6,2)) AS avg_transaction
FROM clean_weekly_sales
GROUP BY calendar_year, platform
ORDER BY platform, calendar_year;
```

The average transaction size for each platform cannot be calculated directly from the `avg_transaction` column. To calculate the average transaction size for each platform, total sales need to be divided by the total number of transactions for each platform. 

#### Result:
![Zrzut ekranu 2024-11-02 180543](https://github.com/user-attachments/assets/dca2f5e0-e163-4e93-96e3-4eac956d4865)


The average transaction size for the Retail platform is around $36, whereas for the Shopify platform it is around $180, which is five times higher than the Retail platform. However, remember that the Shopify platform accounts for only 2-3% of total sales in each month. These two pieces of information highlight significant differences in products on each platform or in the types of customers who choose each platform.
