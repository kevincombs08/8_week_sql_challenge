# -- A. Customer Journey

-- Based off the 8 sample customers provided in the sample from the subscriptions table, write a brief description about each customer’s onboarding journey.
```
SELECT
	pl.plan_id
    ,plan_name
    ,price
    ,customer_id
    ,start_date
FROM plans AS pl
	LEFT JOIN subscriptions AS sub
		ON pl.plan_id = sub.plan_id
ORDER BY customer_id;
```
-- customer_id = 2
```
SELECT
	pl.plan_id
    ,plan_name
    ,price
    ,customer_id
    ,start_date
FROM plans AS pl
	LEFT JOIN subscriptions AS sub
		ON pl.plan_id = sub.plan_id
WHERE customer_id = '2'
ORDER BY customer_id;
```
-- This customer signed up for the trial plan on September 20th, 2020 and tested it for 7 days before signing up for the pro annual plan on September 27th, 2020. 

![Screen Shot 2023-06-28 at 9 30 37 AM](https://github.com/kevincombs08/8_week_sql_challenge/assets/126277909/40e1250e-6728-4028-b758-9349c82624f6)

-- customer_id = 206
```
SELECT
	pl.plan_id
    ,plan_name
    ,price
    ,customer_id
    ,start_date
FROM plans AS pl
	LEFT JOIN subscriptions AS sub
		ON pl.plan_id = sub.plan_id
WHERE customer_id = '206'
ORDER BY customer_id;
```
-- This customer signed up for the trial on March 17th, 2020 and tested it for 7 days before signing up for the basic monthly plan on March 24th, 2020. 6 months later, this customer upgraded to the pro annual plan. 

![Screen Shot 2023-06-28 at 9 40 43 AM](https://github.com/kevincombs08/8_week_sql_challenge/assets/126277909/274273ed-f0a1-4e44-8f71-290fccf31036)

-- customer_id = 494
```
SELECT
	pl.plan_id
    ,plan_name
    ,price
    ,customer_id
    ,start_date
FROM plans AS pl
	LEFT JOIN subscriptions AS sub
		ON pl.plan_id = sub.plan_id
WHERE customer_id = '494'
ORDER BY customer_id;
```
-- This customer signed up for the trial on July 18th, 2020. 7 days later, they signed up for the pro monthly tier. 6 months later, this customer cancelled their services.

![Screen Shot 2023-06-28 at 9 45 43 AM](https://github.com/kevincombs08/8_week_sql_challenge/assets/126277909/3c6e12b4-1c29-4571-975a-ba158dfcd166)

-- customer_id = 790
```
SELECT
	pl.plan_id
    ,plan_name
    ,price
    ,customer_id
    ,start_date
FROM plans AS pl
	LEFT JOIN subscriptions AS sub
		ON pl.plan_id = sub.plan_id
WHERE customer_id = '790'
ORDER BY customer_id;
```
-- This customer signed up for the trial on March 10th, 2020 and converted to the basic monthly plan 7 days later on March 17th, 2020.

![Screen Shot 2023-06-28 at 9 50 16 AM](https://github.com/kevincombs08/8_week_sql_challenge/assets/126277909/89bef358-4dcc-4f95-8349-036154f4bbcc)

-- customer_id = 805
```
SELECT
	pl.plan_id
    ,plan_name
    ,price
    ,customer_id
    ,start_date
FROM plans AS pl
	LEFT JOIN subscriptions AS sub
		ON pl.plan_id = sub.plan_id
WHERE customer_id = '805'
ORDER BY customer_id;
```
-- This customer signed up for the trial on April 2nd, 2020 and upgraded to the basic monthly plan on April 9th, 2020. 5 months later, this customer upgraded to the pro monthly on September 2nd, 2020. 

![Screen Shot 2023-06-28 at 9 53 20 AM](https://github.com/kevincombs08/8_week_sql_challenge/assets/126277909/a25e364a-91a7-4c41-992b-95f6527ae4cf)

-- customer_id = 810
```
SELECT
	pl.plan_id
    ,plan_name
    ,price
    ,customer_id
    ,start_date
FROM plans AS pl
	LEFT JOIN subscriptions AS sub
		ON pl.plan_id = sub.plan_id
WHERE customer_id = '810'
ORDER BY customer_id;
```
-- This customer signed up for the trial plan on November 22, 2020 and upgraded to the basic monthly 7 days later. A few short days later on December 2, 2020 they cancelled their account.

![Screen Shot 2023-06-28 at 9 56 09 AM](https://github.com/kevincombs08/8_week_sql_challenge/assets/126277909/345bbd25-f10a-415e-b44d-be3fcef62e9b)

-- customer_id = 974
```
SELECT
	pl.plan_id
    ,plan_name
    ,price
    ,customer_id
    ,start_date
FROM plans AS pl
	LEFT JOIN subscriptions AS sub
		ON pl.plan_id = sub.plan_id
WHERE customer_id = '974'
ORDER BY customer_id;
```
-- This customer signed up for the trial on September 10th, 2020 and 7 days later signed up for the basic monthly plan. A month later, they upgraded to the pro annual plan.

![Screen Shot 2023-06-28 at 10 05 52 AM](https://github.com/kevincombs08/8_week_sql_challenge/assets/126277909/ba9c0904-7a03-4de5-9227-69c6e7db1912)

-- customer_id = 549
```
SELECT
	pl.plan_id
    ,plan_name
    ,price
    ,customer_id
    ,start_date
FROM plans AS pl
	LEFT JOIN subscriptions AS sub
		ON pl.plan_id = sub.plan_id
WHERE customer_id = '549'
ORDER BY customer_id;
```
-- This customer signed up for the trial plan on October 7th 2020 and 7 days later upgraded to the basic monthly. 3 months later, this customer upgraded to the pro monthly plan.

![Screen Shot 2023-06-28 at 10 11 40 AM](https://github.com/kevincombs08/8_week_sql_challenge/assets/126277909/e0c92d2d-8d2c-45de-b1d4-5bfdc20dd66b)

# -- B. Data Analysis Questions

-- How many customers has Foodie-Fi ever had?
```
SELECT 
	COUNT(distinct customer_id) AS customers
FROM subscriptions;
```
![Screen Shot 2023-06-28 at 10 25 08 AM](https://github.com/kevincombs08/8_week_sql_challenge/assets/126277909/492033f3-e1da-4411-8f21-91c5ece405b0)

-- What plan start_date values occur after the year 2020 for our dataset? Show the breakdown by count of events for each plan_name
```
SELECT
	pl.plan_name
    ,SUM(CASE WHEN year(sub.start_date) = 2020 THEN 1
		ELSE 0
        END) AS plan_2020
	,SUM(CASE WHEN year(sub.start_date) > 2020 THEN 1
		ELSE 0
        END) AS plan_2021
FROM subscriptions AS sub
	LEFT JOIN plans AS pl
		ON pl.plan_id = sub.plan_id
GROUP BY 1;
```
![Screen Shot 2023-06-28 at 10 25 54 AM](https://github.com/kevincombs08/8_week_sql_challenge/assets/126277909/5852b7f1-d793-4308-a8a8-5ec810cf9785)

-- What is the customer count and percentage of customers who have churned rounded to 1 decimal place?
```
WITH cte_1 AS(
SELECT
	SUM(CASE WHEN pl.plan_id = 4 THEN 1 
		ELSE 0 
        END) AS churn_count
	,COUNT(distinct customer_id) AS total_cust
FROM subscriptions AS sub
	LEFT JOIN plans AS pl
		ON pl.plan_id = sub.plan_id)
SELECT
	churn_count
	,CONCAT(ROUND(((churn_count/total_cust)*100),1),'%') AS churn_perc
FROM cte_1;
```
![Screen Shot 2023-06-28 at 10 26 17 AM](https://github.com/kevincombs08/8_week_sql_challenge/assets/126277909/ab8cdf9b-15c5-4ed0-86a3-15a5bb45c1db)

-- How many customers have churned straight after their initial free trial - what percentage is this rounded to the nearest whole number?
```
WITH cte_1 AS(
SELECT
	customer_id
    ,pl.plan_id
    ,pl.plan_name
    ,ROW_NUMBER()
		OVER(PARTITION BY customer_id
			ORDER BY pl.plan_id) as plan_row
FROM subscriptions AS s
	LEFT JOIN plans AS pl
		ON pl.plan_id = s.plan_id)
SELECT
	COUNT(*) AS churn_count
	,CONCAT(ROUND((COUNT(*)/
		(SELECT COUNT(DISTINCT customer_id)
			FROM subscriptions)*100),0), '%') AS churn_perc
FROM cte_1
WHERE plan_id = 4
AND plan_row = 2;
```
![Screen Shot 2023-06-28 at 10 28 36 AM](https://github.com/kevincombs08/8_week_sql_challenge/assets/126277909/b3964773-7efd-4803-98a7-9bf3dea5278f)
 
-- What is the number and percentage of customer plans after their initial free trial?
```
WITH cte_1 AS(
SELECT
	customer_id
    ,pl.plan_id
    ,LEAD(pl.plan_id,1)
		OVER(PARTITION BY customer_id
			ORDER BY pl.plan_id) AS next_plan
FROM subscriptions AS s
	LEFT JOIN plans AS pl
		ON pl.plan_id = s.plan_id)
SELECT
	next_plan
	,COUNT(*) AS convert_count
    ,CONCAT(ROUND((COUNT(*)/
		(SELECT COUNT(DISTINCT customer_id)
			FROM subscriptions)*100),0),'%') AS convert_perc
FROM cte_1
WHERE plan_id = 0
AND next_plan !=4
GROUP BY 1;
```

![Screen Shot 2023-06-28 at 10 30 38 AM](https://github.com/kevincombs08/8_week_sql_challenge/assets/126277909/b5c01efa-2e9c-423c-851a-c9219a2e4e40)

-- What is the customer count and percentage breakdown of all 5 plan_name values at 2020-12-31?
```
WITH next_dates AS(
SELECT
	customer_id
    ,pl.plan_id
    ,pl.plan_name
    ,start_date
    ,LEAD(start_date,1)
		OVER(PARTITION BY customer_id
			ORDER BY start_date) AS next_date
FROM subscriptions AS s
	LEFT JOIN plans AS pl
		ON pl.plan_id = s.plan_id
WHERE start_date <= '2020-12-31')
, customer_plans AS(
SELECT 
	plan_id
	,COUNT(DISTINCT customer_id) AS customers
FROM next_dates
WHERE (start_date < '2020-12-31' AND next_date IS NULL)
OR ((start_date < '2020-12-31' AND next_date > '2020-12-31') AND next_date IS NOT NULL)
GROUP BY 1)
SELECT
	plan_id
    ,customers
    ,CONCAT(ROUND((customers/
					(SELECT COUNT(DISTINCT customer_id)
						FROM subscriptions)*100),0),'%') AS customer_perc
FROM customer_plans
GROUP BY 1,2; 
```
![Screen Shot 2023-06-28 at 10 44 28 AM](https://github.com/kevincombs08/8_week_sql_challenge/assets/126277909/ccbbce0f-888c-4795-8765-264c327d324b)


-- How many customers have upgraded to an annual plan in 2020?
```
SELECT
	COUNT(DISTINCT customer_id)
FROM subscriptions
WHERE plan_id = 3
AND start_date < '2020-12-31';
```
![Screen Shot 2023-06-28 at 10 45 34 AM](https://github.com/kevincombs08/8_week_sql_challenge/assets/126277909/aa832578-670d-4e85-aea9-15f90ea182f3)

-- How many days on average does it take for a customer to an annual plan from the day they join Foodie-Fi?
```
WITH cte_1 AS(
SELECT
	customer_id
    ,MAX(CASE WHEN plan_id = 0 THEN start_date 
		ELSE NULL
        END) AS trial_start
	,MAX(CASE WHEN plan_id = 3 THEN start_date
		ELSE NULL
		END) AS annual_start
FROM subscriptions
GROUP BY 1)
SELECT
ROUND(AVG(DATEDIFF(annual_start,trial_start)),0) AS date_diff
FROM cte_1
WHERE annual_start IS NOT NULL;
```
![Screen Shot 2023-06-28 at 10 52 04 AM](https://github.com/kevincombs08/8_week_sql_challenge/assets/126277909/c2ba096e-6dc4-4921-b7ea-8acb7805fccd)

-- Can you further breakdown this average value into 30 day periods (i.e. 0-30 days, 31-60 days etc)
```
WITH dates AS(
SELECT
	customer_id
    ,MAX(CASE WHEN plan_id = 0 THEN start_date 
		ELSE NULL
        END) AS trial_start
	,MAX(CASE WHEN plan_id = 3 THEN start_date
		ELSE NULL
		END) AS annual_start
FROM subscriptions
GROUP BY 1)
, time_diff AS(
SELECT
	customer_id
    ,ROUND(AVG(DATEDIFF(annual_start,trial_start)),0) AS date_diff
FROM dates
WHERE annual_start IS NOT NULL
GROUP BY 1)
, buckets AS(
SELECT
	customer_id
    ,FLOOR(date_diff/30) AS bucket_days
FROM time_diff)
SELECT CONCAT((bucket_days*30) +1 , '-',(bucket_days +1)*30, ' days') as days,
        COUNT(bucket_days) as number_days
FROM buckets
GROUP BY bucket_days
ORDER BY bucket_days ASC;
```
![Screen Shot 2023-06-28 at 10 55 12 AM](https://github.com/kevincombs08/8_week_sql_challenge/assets/126277909/fd2b0418-1579-4382-9524-2293d1ed9bff)

-- How many customers downgraded from a pro monthly to a basic monthly plan in 2020?
```
WITH cte_1 AS(
SELECT 
	*
    ,LEAD(plan_id,1)
		OVER(PARTITION BY customer_id
			ORDER BY plan_id) AS next_plan
FROM subscriptions)
SELECT 
	COUNT(customer_id) AS downgrades
FROM cte_1
WHERE start_date <= '2020-12-31'
AND plan_id = 2
AND next_plan = 1;
```
![Screen Shot 2023-06-28 at 10 56 10 AM](https://github.com/kevincombs08/8_week_sql_challenge/assets/126277909/703371ca-4ccb-44bc-b32d-a50d956be571)

