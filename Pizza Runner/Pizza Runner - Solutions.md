# -- Data Cleaning & Validation
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

# -- A. Pizza Metrics
        
-- 1. How many pizzas were ordered?
```
SELECT COUNT(order_id) AS pizza_count
FROM customer_orders;
```
![Screen Shot 2023-07-17 at 4 08 07 PM](https://github.com/kevincombs08/8_week_sql_challenge/assets/126277909/4bd41343-1522-44e2-b4fc-a2f9c81f84a5)

-- 2. How many unique customer orders were made?
```
SELECT COUNT(distinct order_id) AS distinct_order
FROM customer_orders;  
```
![Screen Shot 2023-07-17 at 4 08 22 PM](https://github.com/kevincombs08/8_week_sql_challenge/assets/126277909/b910c18f-1971-4c2d-945e-96fa3587ad62)

-- 3. How many successful orders were delivered by each runner?
```
SELECT runner_id
	,COUNT(order_id)
FROM runner_orders
WHERE cancellation IS NULL
GROUP BY 1;
```
![Screen Shot 2023-07-17 at 4 08 52 PM](https://github.com/kevincombs08/8_week_sql_challenge/assets/126277909/dc777ce1-51ca-4b94-9ddb-f418d596b4ca)

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
![Screen Shot 2023-07-17 at 4 09 47 PM](https://github.com/kevincombs08/8_week_sql_challenge/assets/126277909/6ee49015-b10c-43c7-bd4e-0d1b45ccd6fc)

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
![Screen Shot 2023-07-17 at 4 10 02 PM](https://github.com/kevincombs08/8_week_sql_challenge/assets/126277909/afe68dc6-50a0-42bc-9b47-b754d1a91dc5)

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
![Screen Shot 2023-07-17 at 4 10 18 PM](https://github.com/kevincombs08/8_week_sql_challenge/assets/126277909/71ba92b5-6bac-456b-be72-060cbf3d970c)

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
![Screen Shot 2023-07-17 at 4 10 33 PM](https://github.com/kevincombs08/8_week_sql_challenge/assets/126277909/812d8b74-a315-4ab5-90d6-6b1fd3068d59)

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
![Screen Shot 2023-07-17 at 4 10 49 PM](https://github.com/kevincombs08/8_week_sql_challenge/assets/126277909/1b663940-14da-4242-9f37-4aa309bcee33)

-- 9. What was the total volume of pizzas ordered for each hour of the day?
```
SELECT EXTRACT(HOUR FROM order_time) AS hour
	,COUNT(order_id) AS pizza_volume
FROM customer_orders
GROUP BY 1
ORDER BY EXTRACT(HOUR FROM order_time); 
```
![Screen Shot 2023-07-17 at 4 11 05 PM](https://github.com/kevincombs08/8_week_sql_challenge/assets/126277909/de173448-201c-4751-b492-23f55101feb7)

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
![Screen Shot 2023-07-17 at 4 11 26 PM](https://github.com/kevincombs08/8_week_sql_challenge/assets/126277909/7dbaf541-5997-4bc6-8329-1e268dc2a5e0)

# -- B. Runner and Customer Experience
        
-- 1. How many runners signed up for each 1 week period? (i.e. week starts 2021-01-01)
```
SELECT 
	YEARWEEK(registration_date) AS registration_week
	,COUNT(*) AS sign_ups
FROM runners
GROUP BY YEARWEEK(registration_date)
ORDER BY COUNT(*) DESC;
```
![Screen Shot 2023-07-17 at 4 11 42 PM](https://github.com/kevincombs08/8_week_sql_challenge/assets/126277909/382c66a6-012f-4428-9c54-f32a7d35bfcb)

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
![Screen Shot 2023-07-17 at 4 12 09 PM](https://github.com/kevincombs08/8_week_sql_challenge/assets/126277909/f9e5953b-6207-4423-b569-2f9b5ce75d3d)

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
![Screen Shot 2023-07-17 at 4 12 24 PM](https://github.com/kevincombs08/8_week_sql_challenge/assets/126277909/4bbd107e-70f2-41e9-b5a0-ff15370ef3d6)

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
![Screen Shot 2023-07-17 at 4 12 43 PM](https://github.com/kevincombs08/8_week_sql_challenge/assets/126277909/20005f26-edc3-482a-a760-906f27e9033b)

-- 5. What was the difference between the longest and shortest delivery times for all orders?
```
SELECT
    MAX(duration) - MIN(duration) AS time_diff
FROM runner_orders;
```
![Screen Shot 2023-07-17 at 4 13 01 PM](https://github.com/kevincombs08/8_week_sql_challenge/assets/126277909/4678b7a9-f3f1-4c2a-8da6-82accb89d746)

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
![Screen Shot 2023-07-17 at 4 13 18 PM](https://github.com/kevincombs08/8_week_sql_challenge/assets/126277909/5d40ec0b-a6fe-4316-8ca6-0d8f9749d740)

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
![Screen Shot 2023-07-17 at 4 13 35 PM](https://github.com/kevincombs08/8_week_sql_challenge/assets/126277909/f0dc5e0c-b021-4e0d-a90d-3b552448a972)


