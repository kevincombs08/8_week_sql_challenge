-- Data Cleaning & Validation
------------------------------------------------------------------------------------------------
```
SELECT * FROM runner_orders; 
```
```
UPDATE runner_orders
SET pickup_time = CASE WHEN pickup_time LIKE('') THEN NULL ELSE pickup_time END,
	distance = CASE WHEN distance LIKE ('%km') THEN TRIM('km' FROM distance) 
				WHEN distance LIKE('') THEN NULL 
                ELSE distance END,
	duration = CASE WHEN duration LIKE ('%mins') THEN TRIM('mins' FROM duration)
				WHEN duration LIKE ('%minute') THEN TRIM('minute' FROM duration)
                WHEN duration LIKE ('%minutes') THEN TRIM('minutes' FROM duration)
                WHEN duration LIKE('') THEN NULL
                ELSE duration END,
	cancellation = CASE WHEN cancellation LIKE('') THEN NULL ELSE cancellation END; 
```
```
ALTER TABLE runner_orders
MODIFY COLUMN pickup_time DATETIME,
MODIFY COLUMN distance FLOAT,
MODIFY COLUMN duration INT;
``` 
```
SELECT * FROM customer_orders;
``` 
```
UPDATE customer_orders
SET exclusions = CASE WHEN exclusions LIKE ('') THEN NULL
					WHEN exclusions LIKE ('null') THEN NULL
                    ELSE exclusions END,
	extras = CASE WHEN extras LIKE ('') THEN NULL
				WHEN extras LIKE ('null') THEN NULL
                ELSE extras END;
```
```
ALTER TABLE customer_orders
MODIFY COLUMN order_time DATETIME;
``` 
------------------------------------------------------------------------------------------------

-- A. Pizza Metrics
        
-- 1. How many pizzas were ordered?
```
SELECT COUNT(order_id) AS pizza_count
FROM customer_orders;
```
![Screen Shot 2023-06-27 at 11 03 18 AM](https://github.com/kevincombs08/8_week_sql_challenge/assets/126277909/e0794b30-5598-4316-b54a-74e3f6c01a7e)

-- 2. How many unique customer orders were made?
```
SELECT COUNT(distinct order_id) AS distinct_order
FROM customer_orders;  
```
![Screen Shot 2023-06-27 at 11 03 43 AM](https://github.com/kevincombs08/8_week_sql_challenge/assets/126277909/26eac0d3-c74b-487d-bf21-f49f6ef38386)

-- 3. How many successful orders were delivered by each runner?
```
SELECT runner_id
	,COUNT(order_id)
FROM runner_orders
WHERE cancellation IS NULL
GROUP BY 1;
```
![Screen Shot 2023-06-27 at 11 05 22 AM](https://github.com/kevincombs08/8_week_sql_challenge/assets/126277909/fe524c2e-c5d3-4c97-9ae7-a72fa835cc25)

-- 4. How many of each type of pizza was delivered?
```
SELECT pn.pizza_name
	,COUNT(ro.order_id) AS pizza_count
FROM customer_orders AS co
	LEFT JOIN pizza_names AS pn
		ON pn.pizza_id = co.pizza_id
	LEFT JOIN runner_orders AS ro
		ON ro.order_id = co.order_id
WHERE ro.cancellation IS NULL
GROUP BY 1; 
```
![Screen Shot 2023-06-27 at 11 06 44 AM](https://github.com/kevincombs08/8_week_sql_challenge/assets/126277909/ee673276-857f-4c66-be27-cde0a6d23aa1)

-- 5. How many Vegetarian and Meatlovers were ordered by each customer?
```
SELECT customer_id
	,pn.pizza_name
    ,COUNT(co.pizza_id) AS pizza_count
FROM customer_orders AS co
	LEFT JOIN pizza_names AS pn
		ON co.pizza_id = pn.pizza_id
GROUP BY 1,2
ORDER BY customer_id;
```
![Screen Shot 2023-06-27 at 11 07 18 AM](https://github.com/kevincombs08/8_week_sql_challenge/assets/126277909/cd3d457a-6113-4c98-b693-596711d27ff2)

-- 6. What was the maximum number of pizzas delivered in a single order?
```
with cte_1 as(
SELECT
	order_id
    ,COUNT(pizza_id) AS pizza_count
FROM customer_orders 
GROUP BY 1)
SELECT MAX(pizza_count) AS pizza_count
FROM cte_1;
```
![Screen Shot 2023-06-27 at 11 09 39 AM](https://github.com/kevincombs08/8_week_sql_challenge/assets/126277909/64a40443-a79d-4c82-96e7-fcd7d8ea045b)

-- 7. For each customer, how many delivered pizzas had at least 1 change and how many had no changes?
```
SELECT customer_id
	,SUM(CASE WHEN exclusions IS NOT NULL THEN 1 
		WHEN extras IS NOT NULL THEN 1 
        ELSE 0 END) AS changes
	,SUM(CASE WHEN exclusions IS NULL 
		AND extras IS NULL THEN 1
        ELSE 0 END) AS no_changes
FROM customer_orders AS co
	LEFT JOIN runner_orders AS ro
		ON co.order_id = ro.order_id
WHERE ro.cancellation IS NULL 
GROUP BY 1;
```
![Screen Shot 2023-06-27 at 11 10 03 AM](https://github.com/kevincombs08/8_week_sql_challenge/assets/126277909/f85b0f4f-2116-4a93-b3bd-14faf6d670f5)

-- 8. How many pizzas were delivered that had both exclusions and extras?
```
SELECT SUM(CASE WHEN exclusions IS NOT NULL 
		AND extras IS NOT NULL THEN 1
        ELSE 0 END) AS change_both
FROM customer_orders AS co
	LEFT JOIN runner_orders AS ro
		ON co.order_id = ro.order_id
WHERE ro.cancellation IS NULL;
```
![Screen Shot 2023-06-27 at 11 10 22 AM](https://github.com/kevincombs08/8_week_sql_challenge/assets/126277909/ec101907-3b03-4b64-a318-ddee3b068417)

-- 9. What was the total volume of pizzas ordered for each hour of the day?
```
SELECT EXTRACT(HOUR FROM order_time) AS hour
	,COUNT(order_id) AS pizza_volume
FROM customer_orders
GROUP BY 1
ORDER BY EXTRACT(HOUR FROM order_time); 
```
![Screen Shot 2023-06-27 at 11 11 03 AM](https://github.com/kevincombs08/8_week_sql_challenge/assets/126277909/4f201b29-dc86-4a65-989f-cccf250488a4)

-- 10. What was the volume of orders for each day of the week?
```
SELECT CASE WHEN DAYOFWEEK(DATE(order_time)) = 1 THEN 'Tuesday'
		WHEN DAYOFWEEK(DATE(order_time)) = 2 THEN 'Wednesday'
        WHEN DAYOFWEEK(DATE(order_time)) = 3 THEN 'Thursday'
        WHEN DAYOFWEEK(DATE(order_time)) = 4 THEN 'Friday'
        WHEN DAYOFWEEK(DATE(order_time)) = 5 THEN 'Saturday'
        WHEN DAYOFWEEK(DATE(order_time)) = 6 THEN 'Sunday'
        WHEN DAYOFWEEK(DATE(order_time)) = 7 THEN 'Monday'
        ELSE DAYOFWEEK(DATE(order_time))
        END AS DOW
	,COUNT(order_id) AS pizza_count
FROM customer_orders
GROUP BY 1
ORDER BY COUNT(order_id) DESC;
```
![Screen Shot 2023-06-27 at 11 11 41 AM](https://github.com/kevincombs08/8_week_sql_challenge/assets/126277909/230f678b-35b7-4dd9-bb37-59d9ccbfe877)

-- B. Runner and Customer Experience
        
-- 1. How many runners signed up for each 1 week period? (i.e. week starts 2021-01-01)
```
SELECT 
	YEARWEEK(registration_date) AS registration_week
	,COUNT(*) AS sign_ups
FROM runners
GROUP BY YEARWEEK(registration_date)
ORDER BY COUNT(*) DESC;
```
![Screen Shot 2023-06-27 at 11 12 28 AM](https://github.com/kevincombs08/8_week_sql_challenge/assets/126277909/88cf6186-2ac9-45f8-84ef-ede7261c878b)

-- 2. What was the average time in minutes it took for each runner to arrive at the Pizza Runner HQ to pickup the order?
```
WITH cte_1 AS(
SELECT 
	ro.runner_id
	,ro.pickup_time
	,order_time
    ,DATE_FORMAT(TIMEDIFF(ro.pickup_time,order_time),'%i') AS time_diff
FROM customer_orders AS co
LEFT JOIN 
	runner_orders AS ro
		ON co.order_id = ro.order_id
WHERE pickup_time IS NOT NULL
GROUP BY 1,2,3)
SELECT 
	runner_id
	,CONCAT(ROUND(AVG(time_diff),0), ' minutes') AS time_taken
FROM cte_1
GROUP BY runner_id;
```
![Screen Shot 2023-06-27 at 11 12 50 AM](https://github.com/kevincombs08/8_week_sql_challenge/assets/126277909/4d1df309-db36-4684-a414-b5f5e1fc71d6)

-- 3. Is there any relationship between the number of pizzas and how long the order takes to prepare?
```
WITH cte_1 AS(
SELECT
	co.order_id
    ,ro.pickup_time
    ,co.order_time
    ,count(co.order_id) AS pizza_count
    ,DATE_FORMAT(TIMEDIFF(ro.pickup_time,order_time),'%i') AS time_diff
FROM customer_orders AS co
LEFT JOIN(
	SELECT order_id
    	,pickup_time
	FROM runner_orders) AS ro
		ON co.order_id = ro.order_id
WHERE ro.pickup_time IS NOT NULL
GROUP BY 1,2,3)
SELECT
    pizza_count
    ,avg(time_diff) as time_to_prep
FROM cte_1 
GROUP BY pizza_count;
```
![Screen Shot 2023-06-27 at 11 13 48 AM](https://github.com/kevincombs08/8_week_sql_challenge/assets/126277909/0d37bb9b-461b-4dc6-ab31-687bee605dd0)

-- 4. What was the average distance travelled for each customer?
```
SELECT
	co.customer_id
    ,ROUND(AVG(distance),0) AS avg_distance
FROM runner_orders AS ro
	LEFT JOIN customer_orders AS co
		ON co.order_id = ro.order_id
WHERE ro.pickup_time IS NOT NULL
GROUP BY co.customer_id
ORDER BY ROUND(AVG(distance),0) DESC;
```
![Screen Shot 2023-06-27 at 11 14 08 AM](https://github.com/kevincombs08/8_week_sql_challenge/assets/126277909/e68147f5-fdc7-4d85-8ce0-ba015e6589e2)

-- 5. What was the difference between the longest and shortest delivery times for all orders?
```
SELECT
    MAX(duration) - MIN(duration) AS time_diff
FROM runner_orders;
```
![Screen Shot 2023-06-27 at 11 14 32 AM](https://github.com/kevincombs08/8_week_sql_challenge/assets/126277909/8f1b6ccd-9d5d-4dae-b527-d80daa654b42)

-- 6. What was the average speed for each runner for each delivery and do you notice any trend for these values?
```
SELECT
    co.customer_id
    ,runner_id
    ,COUNT(co.pizza_id) AS pizza_count
    ,distance
    ,ROUND((duration/60),2) AS hours
    ,ROUND(((distance/duration)*60),2) AS km_per_h
FROM runner_orders AS ro
	LEFT JOIN customer_orders AS co
		ON co.order_id = ro.order_id
WHERE cancellation IS NULL
GROUP BY 1,2,4,5,6
ORDER BY runner_id;
```
![Screen Shot 2023-06-27 at 11 15 00 AM](https://github.com/kevincombs08/8_week_sql_challenge/assets/126277909/e614be6a-8406-4400-97cf-09a200ecebf4)

-- 7. What is the successful delivery percentage for each runner?
```
WITH cte_1 AS(
SELECT 
	runner_id
    ,SUM(CASE WHEN cancellation IS NULL THEN 1
		ELSE 0
        END) AS confirmed
	,COUNT(order_id) AS total_orders
FROM runner_orders
GROUP BY runner_id)
SELECT 
	runner_id
    ,CONCAT(ROUND(((confirmed/total_orders)*100),0),'%') AS success_rate
FROM cte_1
ORDER BY runner_id;
```
![Screen Shot 2023-06-27 at 11 15 32 AM](https://github.com/kevincombs08/8_week_sql_challenge/assets/126277909/cd52911b-cb31-4129-9e5c-ccfcd2d4da19)
