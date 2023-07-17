# -- 1. Data Cleansing Steps

-- In a single query, perform the following operations and generate a new table in the data_mart schema named clean_weekly_sales:

-- Convert the week_date to a DATE format

-- Add a week_number as the second column for each week_date value, for example any value from the 1st of January to 7th of January will be 1, 8th to 14th will be 2 etc

-- Add a month_number with the calendar month for each week_date value as the 3rd column

-- Add a calendar_year column as the 4th column containing either 2018, 2019 or 2020 values

-- Add a new column called age_band after the original segment column using the following mapping on the number inside the segment value
	
 -- Segment: age_band
	
 -- 1 Young Adults
	
 -- 2 Middle Aged
	
 -- 3 or 4 Retirees
 
-- Add a new demographic column using the following mapping for the first letter in the segment values:

-- segment: demographic

-- C Couples

-- F Families

-- Ensure all null string values with an "unknown" string value in the original segment column as well as the new age_band and demographic columns

-- Generate a new avg_transaction column as the sales value divided by transactions rounded to 2 decimal places for each record

```
CREATE TABLE clean_weekly_sales AS(
SELECT
	STR_TO_DATE(week_date, '%d/%m/%y') AS week_date
    ,WEEK(STR_TO_DATE(week_date,'%d/%m/%y')) AS week_number
    ,MONTH(STR_TO_DATE(week_date,'%d/%m/%y')) AS month_number
    ,YEAR(STR_TO_DATE(week_date,'%d/%m/%y')) AS year_number
    ,region
    ,platform
    ,segment
    ,CASE WHEN segment LIKE ('%1') THEN 'Young Adults'
		WHEN segment LIKE ('%2') THEN 'Middle Aged'
        WHEN segment LIKE ('%3') THEN 'Retirees'
        WHEN segment LIKE ('%4') THEN 'Retirees'
			ELSE 'Unknown' END AS age_band
	,CASE WHEN segment LIKE ('C%') THEN 'Couples'
		WHEN segment LIKE ('F%') THEN 'Families'
			ELSE 'Unknown' END AS demographics
	,customer_type
	,sales
    ,transactions
	,ROUND((sales/transactions),2) AS avg_transaction
FROM weekly_sales);
```
![Screen Shot 2023-07-17 at 3 42 37 PM](https://github.com/kevincombs08/8_week_sql_challenge/assets/126277909/52daca26-89d3-4240-8c26-556384a29c20)

# -- 2. Data Exploration

-- What day of the week is used for each week_date value?
```
SELECT
	DISTINCT DATE_FORMAT(week_date,'%a') AS week_day
FROM clean_weekly_sales;
```
![Screen Shot 2023-07-17 at 3 43 26 PM](https://github.com/kevincombs08/8_week_sql_challenge/assets/126277909/9bb46845-e653-4c35-add4-439c9b870970)

-- What range of week numbers are missing from the dataset?
```
SELECT
	52 - COUNT(DISTINCT week_number) AS missing_weeks
FROM clean_weekly_sales;
```
![Screen Shot 2023-07-17 at 3 43 45 PM](https://github.com/kevincombs08/8_week_sql_challenge/assets/126277909/dd531554-02ac-4a70-bb80-74a9d8817fe9)

-- How many total transactions were there for each year in the dataset?
```
SELECT
	year_number
    ,SUM(transactions) AS transaction_amount
FROM clean_weekly_sales
GROUP BY year_number
ORDER BY year_number ASC;
```
![Screen Shot 2023-07-17 at 3 44 00 PM](https://github.com/kevincombs08/8_week_sql_challenge/assets/126277909/2e8bd1ce-4930-4580-b7f2-cc102cea26e4)

-- What is the total count of transactions for each platform
```
SELECT
	platform
    ,COUNT(*) AS total_ct
FROM clean_weekly_sales
GROUP BY platform
ORDER BY COUNT(*) DESC;
```
![Screen Shot 2023-07-17 at 3 44 18 PM](https://github.com/kevincombs08/8_week_sql_challenge/assets/126277909/8f3c909a-062f-4338-b547-b5129528be44)

-- What is the percentage of sales for Retail vs Shopify for each month?
```
WITH cte_1 AS(
SELECT
	year_number
    ,month_number
    ,platform
    ,SUM(sales) AS month_sales
FROM clean_weekly_sales
GROUP BY 1,2,3)
SELECT
	year_number
	,month_number
    ,ROUND((SUM(CASE WHEN platform = 'Retail' THEN month_sales
		ELSE NULL
        END)/SUM(month_sales)*100),2) AS retail_pct
	,ROUND((SUM(CASE WHEN platform = 'Shopify' THEN month_sales
		ELSE NULL
        END)/SUM(month_sales)*100),2) AS shopify_pct
FROM cte_1
GROUP BY 1,2
ORDER BY year_number,month_number ASC;
```
![Screen Shot 2023-07-17 at 3 44 40 PM](https://github.com/kevincombs08/8_week_sql_challenge/assets/126277909/fb0759e9-8741-4b12-b8a8-21b85ee7d661)

-- What is the percentage of sales by demographic for each year in the dataset?
```
WITH cte_1 AS(
SELECT
	year_number
    ,demographics
    ,SUM(sales) AS month_sales
FROM clean_weekly_sales
GROUP BY 1,2)
SELECT
	year_number
    ,ROUND((SUM(CASE WHEN demographics = 'Families' THEN month_sales
		ELSE NULL
        END)/SUM(month_sales)*100),2) AS families_pct
	,ROUND((SUM(CASE WHEN demographics = 'Couples' THEN month_sales
		ELSE NULL
        END)/SUM(month_sales)*100),2) AS couples_pct
	,ROUND((SUM(CASE WHEN demographics = 'Unknown' THEN month_sales
		ELSE NULL
        END)/SUM(month_sales)*100),2) AS unknown_pct
FROM cte_1
GROUP BY 1
ORDER BY year_number; 
```
![Screen Shot 2023-07-17 at 3 45 01 PM](https://github.com/kevincombs08/8_week_sql_challenge/assets/126277909/68a7a08f-0125-4234-9edd-540ed189dbe3)

-- Which age_band and demographic values contribute the most to Retail sales?
```
SELECT
	age_band
    ,demographics
    ,SUM(sales) AS total_sales
    ,ROUND((SUM(sales)/(SELECT SUM(sales) FROM clean_weekly_sales)*100),2) AS pct_of_total
FROM clean_weekly_sales
GROUP BY 1,2
ORDER BY SUM(sales) DESC; 
```
![Screen Shot 2023-07-17 at 3 45 35 PM](https://github.com/kevincombs08/8_week_sql_challenge/assets/126277909/65afe5d6-6328-48c9-841b-d8af68c0f224)

-- Can we use the avg_transaction column to find the average transaction size for each year for Retail vs Shopify? If not - how would you calculate it instead?
```
SELECT
	year_number
    ,platform
    ,ROUND(AVG(avg_transaction),0) AS avg_transactions_r
    ,ROUND(SUM(sales)/SUM(transactions),0) AS avg_transac_t
FROM clean_weekly_sales
GROUP BY 1,2;
```
![Screen Shot 2023-07-17 at 3 45 54 PM](https://github.com/kevincombs08/8_week_sql_challenge/assets/126277909/71b1cfc7-3dcb-46c7-bf21-f6f5e4f9a548)

# -- 3. Before & After Analysis

	-- This technique is usually used when we inspect an important event and want to inspect the impact before and after a certain point in time.
	-- Taking the week_date value of 2020-06-15 as the baseline week where the Data Mart sustainable packaging changes came into effect.
	-- We would include all week_date values for 2020-06-15 as the start of the period after the change and the previous week_date values would be before

	-- Using this analysis approach - answer the following questions:
-- What is the total sales for the 4 weeks before and after 2020-06-15? What is the growth or reduction rate in actual values and percentage of sales?
```
WITH week_sales AS(
SELECT
	week_number
    ,SUM(sales) AS total_sales
FROM clean_weekly_sales
WHERE week_number BETWEEN 19 AND 29
AND year_number = '2020'
GROUP BY week_number
ORDER BY week_number)
, wow_changes AS(
SELECT
	SUM(CASE WHEN week_number BETWEEN 19 AND 23 THEN total_sales
    ELSE NULL
    END) AS four_prior
    ,SUM(CASE WHEN week_number BETWEEN 24 AND 27 THEN total_sales
    ELSE NULL
    END) AS four_after
FROM week_sales)
SELECT
	four_prior
    ,four_after
    ,four_after-four_prior AS variance
    ,CONCAT(ROUND((((four_after-four_prior)/four_prior)*100),2),'%') AS pct_change
FROM wow_changes;
```
![Screen Shot 2023-07-17 at 3 46 14 PM](https://github.com/kevincombs08/8_week_sql_challenge/assets/126277909/a0e4bcbf-2b8b-4517-88fa-da34b489026c)

-- What about the entire 12 weeks before and after?
```
WITH twelve_week AS(
SELECT
	week_number
    ,SUM(sales) AS total_sales
FROM clean_weekly_sales
WHERE year_number = '2020'
GROUP BY 1)
,changes_week AS(
SELECT
	SUM(CASE WHEN week_number BETWEEN 11 AND 23 THEN total_sales
		ELSE NULL
		END) AS prior_12
	,SUM(CASE WHEN week_number BETWEEN 24 AND 35 THEN total_sales
		ELSE NULL
        END) AS next_12
FROM twelve_week)
SELECT
	prior_12
    ,next_12
    ,next_12 - prior_12 AS variance
    ,CONCAT(ROUND((((next_12 - prior_12)/prior_12)*100),2),'%')
FROM changes_week;
```
![Screen Shot 2023-07-17 at 3 46 50 PM](https://github.com/kevincombs08/8_week_sql_challenge/assets/126277909/d7f101e5-7b34-4c1c-afd2-e76937161a73)

-- How do the sale metrics for these 2 periods before and after compare with the previous years in 2018 and 2019?
```
WITH twelve_week AS(
SELECT
	year_number
    ,week_number
    ,SUM(sales) AS total_sales
FROM clean_weekly_sales
WHERE week_number BETWEEN 11 AND 35
GROUP BY 1,2)
, changes_week AS(
SELECT
	year_number
	,SUM(CASE WHEN week_number BETWEEN 19 AND 23 THEN total_sales
		ELSE NULL
        END) AS prior_4
	,SUM(CASE WHEN week_number BETWEEN 24 AND 27 THEN total_sales
		ELSE NULL
        END) AS next_4
	,SUM(CASE WHEN week_number BETWEEN 11 AND 23 THEN total_sales
		ELSE NULL
        END) AS prior_12
	,SUM(CASE WHEN week_number BETWEEN 24 AND 35 THEN total_sales
		ELSE NULL
        END) AS next_12
FROM twelve_week
WHERE year_number IN ('2018','2019')
GROUP BY 1)
SELECT
	year_number
    ,prior_4
    ,next_4
    ,next_4 - prior_4 AS week_variance_4
    ,CONCAT(ROUND((((next_4 - prior_4)/prior_4)*100),2),'%') AS pct_change_4
    ,prior_12
    ,next_12
    ,next_12 - prior_12 AS week_variance_12
    ,CONCAT(ROUND((((next_12 - prior_12)/prior_12)*100),2),'%') AS pct_change_12
FROM changes_week
ORDER BY year_number ASC;
```
![Screen Shot 2023-07-17 at 3 48 09 PM](https://github.com/kevincombs08/8_week_sql_challenge/assets/126277909/7a6c4723-bad0-488f-b632-39b4ea98aab3)

# -- 4. Bonus Question

-- Which areas of the business have the highest negative impact in sales metrics performance in 2020 for the 12 week before and after period?

-- region
```
WITH twelve_week AS(
SELECT
	week_number
    ,region
    ,SUM(sales) AS total_sales
FROM clean_weekly_sales
WHERE year_number = '2020'
GROUP BY 1,2)
,changes_week AS(
SELECT
	region
	,SUM(CASE WHEN week_number BETWEEN 11 AND 23 THEN total_sales
		ELSE NULL
		END) AS prior_12
	,SUM(CASE WHEN week_number BETWEEN 24 AND 35 THEN total_sales
		ELSE NULL
        END) AS next_12
FROM twelve_week
GROUP BY 1)
SELECT
	region
	,prior_12
    ,next_12
    ,next_12 - prior_12 AS variance
    ,CONCAT(ROUND((((next_12 - prior_12)/prior_12)*100),2),'%') AS pct_change
FROM changes_week;
```
![Screen Shot 2023-07-17 at 3 48 33 PM](https://github.com/kevincombs08/8_week_sql_challenge/assets/126277909/f62463b6-5f2b-4aa8-945c-f2cea7b20164)

-- platform
```    
WITH twelve_week AS(
SELECT
	week_number
    ,platform
    ,SUM(sales) AS total_sales
FROM clean_weekly_sales
WHERE year_number = '2020'
GROUP BY 1,2)
,changes_week AS(
SELECT
	platform
	,SUM(CASE WHEN week_number BETWEEN 11 AND 23 THEN total_sales
		ELSE NULL
		END) AS prior_12
	,SUM(CASE WHEN week_number BETWEEN 24 AND 35 THEN total_sales
		ELSE NULL
        END) AS next_12
FROM twelve_week
GROUP BY 1)
SELECT
	platform
	,prior_12
    ,next_12
    ,next_12 - prior_12 AS variance
    ,CONCAT(ROUND((((next_12 - prior_12)/prior_12)*100),2),'%') AS pct_change
FROM changes_week;
```
![Screen Shot 2023-07-17 at 3 48 50 PM](https://github.com/kevincombs08/8_week_sql_challenge/assets/126277909/b34e2c9d-74a7-40fe-a67c-766d1a882cc5)

-- age_band
```    
WITH twelve_week AS(
SELECT
	week_number
    ,age_band
    ,SUM(sales) AS total_sales
FROM clean_weekly_sales
WHERE year_number = '2020'
GROUP BY 1,2)
,changes_week AS(
SELECT
	age_band
	,SUM(CASE WHEN week_number BETWEEN 11 AND 23 THEN total_sales
		ELSE NULL
		END) AS prior_12
	,SUM(CASE WHEN week_number BETWEEN 24 AND 35 THEN total_sales
		ELSE NULL
        END) AS next_12
FROM twelve_week
GROUP BY 1)
SELECT
	age_band
	,prior_12
    ,next_12
    ,next_12 - prior_12 AS variance
    ,CONCAT(ROUND((((next_12 - prior_12)/prior_12)*100),2),'%') AS pct_change
FROM changes_week;
```
![Screen Shot 2023-07-17 at 3 49 10 PM](https://github.com/kevincombs08/8_week_sql_challenge/assets/126277909/d5cc129c-c6c2-4fee-99c0-4293259a0894)

-- demographic
```    
WITH twelve_week AS(
SELECT
	week_number
    ,demographics
    ,SUM(sales) AS total_sales
FROM clean_weekly_sales
WHERE year_number = '2020'
GROUP BY 1,2)
,changes_week AS(
SELECT
	demographics
	,SUM(CASE WHEN week_number BETWEEN 11 AND 23 THEN total_sales
		ELSE NULL
		END) AS prior_12
	,SUM(CASE WHEN week_number BETWEEN 24 AND 35 THEN total_sales
		ELSE NULL
        END) AS next_12
FROM twelve_week
GROUP BY 1)
SELECT
	demographics
	,prior_12
    ,next_12
    ,next_12 - prior_12 AS variance
    ,CONCAT(ROUND((((next_12 - prior_12)/prior_12)*100),2),'%') AS pct_change
FROM changes_week;
```
![Screen Shot 2023-07-17 at 3 49 33 PM](https://github.com/kevincombs08/8_week_sql_challenge/assets/126277909/68f10c55-2553-4e8f-b361-bab9896d9831)

-- customer_type
```    
WITH twelve_week AS(
SELECT
	week_number
    ,customer_type
    ,SUM(sales) AS total_sales
FROM clean_weekly_sales
WHERE year_number = '2020'
GROUP BY 1,2)
,changes_week AS(
SELECT
	customer_type
	,SUM(CASE WHEN week_number BETWEEN 11 AND 23 THEN total_sales
		ELSE NULL
		END) AS prior_12
	,SUM(CASE WHEN week_number BETWEEN 24 AND 35 THEN total_sales
		ELSE NULL
        END) AS next_12
FROM twelve_week
GROUP BY 1)
SELECT
	customer_type
	,prior_12
    ,next_12
    ,next_12 - prior_12 AS variance
    ,CONCAT(ROUND((((next_12 - prior_12)/prior_12)*100),2),'%') AS pct_change
FROM changes_week;
```
![Screen Shot 2023-07-17 at 3 49 53 PM](https://github.com/kevincombs08/8_week_sql_challenge/assets/126277909/fc099f8a-366f-454f-acb8-49f73c51581b)

