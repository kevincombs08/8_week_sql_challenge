# -- A. Customer Nodes Exploration

-- How many unique nodes are there on the Data Bank system?
``` 
SELECT
	COUNT(DISTINCT node_id) AS node_count
FROM customer_nodes;
```
![Screen Shot 2023-06-28 at 11 18 57 AM](https://github.com/kevincombs08/8_week_sql_challenge/assets/126277909/5d3865e3-87ec-4c9d-b800-8dd09a2c2cee)

-- What is the number of nodes per region?
```
SELECT
	region_name
    ,COUNT(node_id) AS num_nodes
FROM regions AS r
	LEFT JOIN customer_nodes AS cn
		ON r.region_id = cn.region_id
GROUP BY region_name
ORDER BY num_nodes DESC;
```
![Screen Shot 2023-06-28 at 11 19 16 AM](https://github.com/kevincombs08/8_week_sql_challenge/assets/126277909/12cc5a74-e3d9-4a43-9bd5-a38e69658591)

-- How many customers are allocated to each region?
```
SELECT
	region_name
    ,COUNT(DISTINCT customer_id) AS num_customer
FROM regions AS r
	LEFT JOIN customer_nodes AS cn
		ON r.region_id = cn.region_id
GROUP BY region_name
ORDER BY num_customer DESC;
```
![Screen Shot 2023-06-28 at 11 19 33 AM](https://github.com/kevincombs08/8_week_sql_challenge/assets/126277909/d78cf490-e739-4269-a4d7-40f13d9f3781)

-- How many days on average are customers reallocated to a different node?
```
SELECT
	ROUND(AVG(DATEDIFF(end_date,start_date)),2) AS avg_date_diff
FROM customer_nodes
WHERE end_date != '9999-12-31';
```
![Screen Shot 2023-06-28 at 11 19 51 AM](https://github.com/kevincombs08/8_week_sql_challenge/assets/126277909/27a8c07f-cafa-4d13-9dfd-1b5d707e1cf7)

-- What is the median, 80th and 95th percentile for this same reallocation days metric for each region?
```
WITH cte_1 AS(
SELECT
	region_name
	,DATEDIFF(end_date,start_date) AS avg_date_diff
    ,PERCENT_RANK()
		OVER(ORDER BY DATEDIFF(end_date,start_date)) AS pct_rnk
FROM customer_nodes AS cn
	LEFT JOIN regions AS r
		ON r.region_id = cn.region_id
WHERE end_date != '9999-12-31'
ORDER BY 1,2)
SELECT
	region_name
    ,CONCAT(ROUND(AVG(CASE WHEN pct_rnk LIKE('0.52%') THEN avg_date_diff
    ELSE NULL 
    END),0),' days') AS fifty_perc
    ,CONCAT(ROUND(AVG(CASE WHEN pct_rnk LIKE('0.80%') THEN avg_date_diff
    ELSE NULL
    END),0),' days') AS eighty_perc
	,CONCAT(ROUND(AVG(CASE WHEN pct_rnk LIKE('0.90%') THEN avg_date_diff
    ELSE NULL
    END),0),' days') AS ninety_perc
FROM cte_1
GROUP BY 1;
```
![Screen Shot 2023-06-28 at 11 20 16 AM](https://github.com/kevincombs08/8_week_sql_challenge/assets/126277909/aa1b8e76-a371-4099-bc8e-da35aafccd00)

# -- B. Customer Transactions

-- What is the unique count and total amount for each transaction type?
```
SELECT
	txn_type
    ,COUNT(customer_id) AS type_count
    ,ROUND(SUM(txn_amount),2) AS type_sum
FROM customer_transactions
GROUP BY 1;
```
![Screen Shot 2023-06-28 at 11 20 31 AM](https://github.com/kevincombs08/8_week_sql_challenge/assets/126277909/1cae8891-777f-4a58-8b1c-fd3ec6cab661)

-- What is the average total historical deposit counts and amounts for all customers?
```
WITH cte_1 AS(
SELECT
	DISTINCT customer_id
    ,COUNT(customer_id) AS customer_count
    ,AVG(txn_amount) AS deposit_amount
FROM customer_transactions
WHERE txn_type = 'deposit'
GROUP BY 1)
SELECT
	ROUND(AVG(customer_count),2) AS avg_count
    ,ROUND(AVG(deposit_amount),2) AS avg_amount
FROM cte_1;
```
![Screen Shot 2023-06-28 at 11 21 02 AM](https://github.com/kevincombs08/8_week_sql_challenge/assets/126277909/8e0700e1-2365-48f1-8586-12f5b01f104f)

-- For each month - how many Data Bank customers make more than 1 deposit and either 1 purchase or 1 withdrawal in a single month?
```
WITH cte_1 AS(
SELECT 
	customer_id
    ,month(txn_date) AS month
    ,SUM(CASE WHEN txn_type = 'deposit' THEN 1 ELSE 0 END) AS deposit_ct
    ,SUM(CASE WHEN txn_type = 'purchase' THEN 1 ELSE 0 END) AS purchase_ct
    ,SUM(CASE WHEN txn_type = 'withdrawal' THEN 1 ELSE 0 END) AS with_ct
FROM customer_transactions
GROUP BY 1,2)
SELECT
	month
    ,COUNT(customer_id)
FROM cte_1
WHERE deposit_ct > 1 AND (purchase_ct = 1 OR with_ct = 1)
GROUP BY 1
ORDER BY 1;
```
![Screen Shot 2023-06-28 at 11 21 34 AM](https://github.com/kevincombs08/8_week_sql_challenge/assets/126277909/8f2150b0-ff08-48e2-82d2-5d908b4f6103)

-- What is the closing balance for each customer at the end of the month?
```
WITH cte_1 AS(
SELECT
	month(txn_date) AS month
    ,customer_id
    ,SUM(CASE WHEN txn_type = 'deposit' THEN txn_amount ELSE 0 END) AS deposit_amount
    ,SUM(CASE WHEN txn_type = 'purchase' THEN txn_amount ELSE 0 END) AS purchase_amount
    ,SUM(CASE WHEN txn_type = 'withdrawal' THEN txn_amount ELSE 0 END) AS withd_amount
FROM customer_transactions
GROUP BY 1,2)
SELECT
	customer_id
    ,month
    ,SUM(deposit_amount - (purchase_amount + withd_amount)) AS transactions
    ,SUM(deposit_amount - (purchase_amount + withd_amount)) 
		OVER(PARTITION BY customer_id ORDER BY month) AS total_amount
FROM cte_1 
GROUP BY 1,2;
```
![Screen Shot 2023-06-28 at 11 24 11 AM](https://github.com/kevincombs08/8_week_sql_challenge/assets/126277909/b32cbb16-6e42-490c-b774-2d1402345d40)

-- What is the percentage of customers who increase their closing balance by more than 5%?
```
WITH cte_1 AS(
SELECT
	month(txn_date) AS month
    ,customer_id
    ,SUM(CASE WHEN txn_type = 'deposit' THEN txn_amount ELSE 0 END) AS deposit_amount
    ,SUM(CASE WHEN txn_type = 'purchase' THEN txn_amount ELSE 0 END) AS purchase_amount
    ,SUM(CASE WHEN txn_type = 'withdrawal' THEN txn_amount ELSE 0 END) AS withd_amount
FROM customer_transactions
GROUP BY 1,2)
, cte_2 AS(
SELECT
	customer_id
    ,month
    ,SUM(deposit_amount - (purchase_amount + withd_amount)) 
		OVER(PARTITION BY customer_id ORDER BY month) AS total_amount
FROM cte_1 
GROUP BY 1,2)
, cte_3 AS(
SELECT
	customer_id
    ,FIRST_VALUE(total_amount)
		OVER(PARTITION BY customer_id ORDER BY month) AS first_amount
	,LAST_VALUE(total_amount)
		OVER(PARTITION BY customer_id ORDER BY month) AS last_amount
FROM cte_2)
, cte_4 AS(
SELECT
	customer_id
    ,((last_amount - first_amount)/(first_amount))*100 AS pct_change
FROM cte_3
WHERE ((last_amount - first_amount)/(first_amount))*100 >= 5 AND last_amount > first_amount)
SELECT
	CONCAT(ROUND((COUNT(DISTINCT customer_id)/
    (SELECT COUNT(DISTINCT customer_id) FROM customer_transactions)*100),0),'%') AS pct_over_5
FROM cte_4;
```
![Screen Shot 2023-06-28 at 11 24 31 AM](https://github.com/kevincombs08/8_week_sql_challenge/assets/126277909/f3015bbd-1adc-4bc8-aa9a-68464feddccc)


