# <p align="center"> Case Study #5: 🛒 Data Mart
 
## <p align="center"> A. Data Cleansing Steps

In a single query, perform the following operations and generate a new table in the `data_mart` schema named `clean_weekly_sales`:

* Convert the `week_date` to a `DATE` format.

* Add a `week_number` as the second column for each `week_date` value, for example any value from the 1st of January to 7th of January will be 1, 8th to 14th will be 2 etc.

* Add a `month_number` with the calendar month for each `week_date` value as the 3rd column.

* Add a `calendar_year` column as the 4th column containing either 2018, 2019 or 2020 values.

* Add a new column called `age_band` after the original `segment` column using the following mapping on the number inside the `segment` value

<div style="display: flex; justify-content: center; text-align: center;">

segment | age_band
-- | --
1 | Young Adults
2 | Middle Aged
3 or 4 | Retirees

</div>


* Add a new d`emographic` column using the following mapping for the first letter in the `segment` values:

<div style="display: flex; justify-content: center; text-align: center;">

segment | demographic
-- | --
C | Couples
F | Families

</div>


* Ensure all `null` string values with an `"unknown"` string value in the original `segment` column as well as the new `age_band` and `demographic` columns

* Generate a new `avg_transaction` column as the `sales` value divided by `transactions` rounded to 2 decimal places for each record

<br></br>
In the first step, I created an empty table called `clean_weekly_sales` with all the importatnt columns.

```sql
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
```
Using the `weekly_sales` table, I converted the data in the `week_date` column to date format with the `DATEFROMPARTS()` and `CHARINDEX()` functions. The result was saved in the Common Table Expression `CTE_weekly_sales`.

```sql
WITH CTE_weekly_sales AS (
	SELECT 
		--convert the data in the "week_date" column to date format
		DATEFROMPARTS(
			'20' + RIGHT(week_date, LEN(week_date) -  CHARINDEX('/', week_date, CHARINDEX('/', week_date, 1) + 1)),
			SUBSTRING(week_date, CHARINDEX('/', week_date, 1) +1, CHARINDEX('/', week_date, CHARINDEX('/', week_date, 1) + 1) - CHARINDEX('/', week_date, 1) - 1),
			LEFT(week_date, CHARINDEX('/', week_date, 1) -1)) AS clean_week_date,
		*
	FROM data_mart.weekly_sales)
```

Next, I inserted data from the `CTE_weekly_sales` table into the `clean_weekly_sales` table. The following calculations were made:
* `week_number` - calculated using the `CEILING()` and `DATEPART()` functions
* `age_band` - determined using `CASE` function to check the last number in `segment`
* `demographic` - determined using `CASE` function check the first letter in `segment`
* `avg_transaction` - calculated by dividing sales by transactions, with the format changed to `NUMERIC`


```sql
INSERT INTO clean_weekly_sales(week_date, week_number, month_number, calendar_year, age_band, demographic, avg_transaction, region, platform, customer_type, transactions, sales)
SELECT 
	clean_week_date,
	--calculate the week number, assuming January 1st is the first day of the week
	CEILING(DATEPART(dayofyear, clean_week_date) / 7.0),
	MONTH(clean_week_date),
	YEAR(clean_week_date),
	--expand the age band information using details from the segment column
	CASE RIGHT(segment,1)
		WHEN '1' THEN 'Young Adults'
		WHEN '2'THEN 'Middle Aged'
		WHEN '3'THEN 'Retirees'
		WHEN '4'THEN 'Retirees'
		ELSE 'unknown'
	END,
	--expand demographic group information using details from the segment column.
	CASE LEFT(segment,1)
		WHEN 'C' THEN 'Couples'
		WHEN 'F' THEN 'Families'
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
```
The sample of `clean_weekly_sales` table
