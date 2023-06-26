-- A. Customer Journey

-- Based off the 8 sample customers provided in the sample from the subscriptions table, write a brief description about each customer’s onboarding journey.

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

-- customer_id = 2
-- customer_id = 206
-- customer_id = 494
-- customer_id = 790
-- customer_id = 805
-- customer_id = 810
-- customer_id = 974
-- customer_id = 549

-- B. Data Analysis Questions

-- How many customers has Foodie-Fi ever had?

SELECT 
	COUNT(distinct customer_id) AS customers
FROM subscriptions;

-- What plan start_date values occur after the year 2020 for our dataset? Show the breakdown by count of events for each plan_name

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

-- What is the customer count and percentage of customers who have churned rounded to 1 decimal place?

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

-- How many customers have churned straight after their initial free trial - what percentage is this rounded to the nearest whole number?

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
	
-- What is the number and percentage of customer plans after their initial free trial?

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

-- What is the customer count and percentage breakdown of all 5 plan_name values at 2020-12-31?

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

-- How many customers have upgraded to an annual plan in 2020?

SELECT
	COUNT(DISTINCT customer_id)
FROM subscriptions
WHERE plan_id = 3
AND start_date < '2020-12-31';

-- How many days on average does it take for a customer to an annual plan from the day they join Foodie-Fi?

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

-- Can you further breakdown this average value into 30 day periods (i.e. 0-30 days, 31-60 days etc)

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

-- How many customers downgraded from a pro monthly to a basic monthly plan in 2020?

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
