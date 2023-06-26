-- Case Study Questions

-- 1) Which product has the highest price? Only return a single row.

SELECT
	product_name
    ,price
FROM dim_products
ORDER by price DESC
LIMIT 1; 

-- 2) Which customer has made the most orders?

SELECT 
	do.customer_id
    ,CONCAT(dc.first_name,' ', dc.last_name) as name
    ,COUNT(do.order_id)
FROM dim_orders as do
JOIN dim_customers as dc
	ON do.customer_id = dc.customer_id
GROUP BY 1,2;


-- 3) What’s the total revenue per product?

WITH cte_1 AS(
SELECT
	doi.product_id AS product_id
    ,dp.product_name AS product_name
    ,dp.price AS price
    ,sum(doi.quantity) AS quantity
FROM dim_order_items as doi
JOIN dim_products AS dp
	ON doi.product_id = dp.product_id
GROUP BY 1,2,3)
SELECT
	product_name
    ,(quantity*price) AS revenue
FROM cte_1
ORDER BY revenue DESC; 

-- 4) Find the day with the highest revenue.

WITH cte_1 AS(
SELECT
	DAY(do.order_date) AS day
    ,dp.price
    ,SUM(doi.quantity) AS quantity
FROM dim_orders AS do
JOIN dim_order_items AS doi
	ON do.order_id = doi.order_id
JOIN dim_products AS dp
	ON dp.product_id = doi.product_id
GROUP BY 1,2)
SELECT
	day
    ,SUM(price*quantity) AS revenue
FROM cte_1
GROUP BY 1
ORDER BY revenue DESC;
    

-- 5) Find the first order (by date) for each customer.

WITH cte_1 AS(
SELECT
	customer_id
    ,order_date
    ,RANK()
		OVER(PARTITION BY customer_id ORDER BY order_date) AS date_rank
FROM dim_orders)
SELECT
	customer_id
    ,order_date
FROM cte_1 
WHERE date_rank = 1;

-- 6) Find the top 3 customers who have ordered the most distinct products

SELECT
	do.customer_id AS customer_id
    ,COUNT(DISTINCT doi.product_id) AS distinct_products
FROM dim_orders AS do
JOIN dim_order_items AS doi
	ON do.order_id = doi.order_id
GROUP BY 1;

-- 7) Which product has been bought the least in terms of quantity?

SELECT
	product_id
    ,SUM(quantity) AS quantity
FROM dim_order_items
GROUP BY 1
ORDER BY SUM(quantity) ASC; 

-- 8) What is the median order total?

WITH cte_1 AS(
SELECT
	do.order_date AS date
    ,dp.price AS price
    ,SUM(doi.quantity) AS quantity
FROM dim_orders AS do
JOIN dim_order_items AS doi
	ON do.order_id = doi.order_id
JOIN dim_products AS dp
	ON dp.product_id = doi.product_id
GROUP BY 1,2)
,
cte_2 AS(
SELECT
	date
    ,SUM(price*quantity) AS order_total
    ,ROW_NUMBER()
		OVER(ORDER BY SUM(price*quantity)) AS row_num
FROM cte_1
GROUP BY 1)
SELECT
	order_total
FROM cte_2
WHERE row_num = 8;

-- 9) For each order, determine if it was ‘Expensive’ (total over 300), ‘Affordable’ (total over 100), or ‘Cheap’.

WITH cte_1 AS(
SELECT
	do.order_id AS order_id
    ,COUNT(doi.product_id) AS product_id
    ,SUM(dp.price) AS price
    ,SUM(doi.quantity) AS quantity
FROM dim_orders AS do
JOIN dim_order_items AS doi
	ON do.order_id = doi.order_id
JOIN dim_products AS dp
	ON dp.product_id = doi.product_id
GROUP BY 1)
SELECT
	order_id
    ,(price*quantity) AS order_total
    ,CASE WHEN (price*quantity) > 300 THEN 'Expensive'
		WHEN (price*quantity) > 100 THEN 'Affordable' 
        WHEN (price*quantity) <= 100 THEN 'Cheap'
			ELSE 'Unknown'
				END AS affordability
FROM cte_1; 

-- 10) Find customers who have ordered the product with the highest price.

WITH cte_1 AS(
SELECT
	doi.order_id
    ,doi.product_id
    ,do.customer_id
FROM dim_orders AS do
JOIN dim_order_items AS doi
	ON do.order_id = doi.order_id
WHERE doi.product_id = 13)
SELECT
	customer_id
FROM cte_1;
