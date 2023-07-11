-- 1. What is the total amount each customer spent at the restaurant?
```
SELECT
	customer_id
    ,SUM(m.price) total
FROM sales AS s
	LEFT JOIN menu AS m
		ON s.product_id = m.product_id
GROUP BY customer_id
ORDER BY SUM(price) DESC;
```
![Screen Shot 2023-07-11 at 3 04 06 PM](https://github.com/kevincombs08/8_week_sql_challenge/assets/126277909/4b531146-3da5-4a43-8c9d-cdd72f744bb5)

-- 2. How many days has each customer visited the restaurant?
```
 SELECT
	customer_id
    ,COUNT(DISTINCT order_date) AS visits
FROM sales
GROUP BY customer_id 
ORDER BY COUNT(DISTINCT order_date) DESC; 
```
![Screen Shot 2023-06-27 at 10 03 28 AM](https://github.com/kevincombs08/8_week_sql_challenge/assets/126277909/28453b56-1d80-4ba0-a289-2d36465c4934)

-- 3. What was the first item from the menu purchased by each customer?
```
with cte_1 as(
SELECT
	customer_id
    ,order_date AS first_order
    ,m.product_name AS item
    ,DENSE_RANK()
		OVER(PARTITION BY customer_id
				ORDER BY customer_id, order_date) AS rnk
FROM sales AS s
	LEFT JOIN menu AS m
		ON s.product_id=m.product_id
ORDER BY customer_id)
SELECT
	customer_id
    ,first_order
    ,item
FROM cte_1
WHERE rnk = 1
GROUP BY 1,2,3;
```
![Screen Shot 2023-06-27 at 10 12 23 AM](https://github.com/kevincombs08/8_week_sql_challenge/assets/126277909/ca36a0ee-d9df-436a-842e-7f8d8144d2c5)

-- 4. What is the most purchased item on the menu and how many times was it purchased by all customers?
```
SELECT
    m.product_name AS product_name
    ,COUNT(*) AS item_count
FROM sales AS s
	LEFT JOIN menu AS m 
		ON s.product_id = m.product_id
GROUP BY product_name
ORDER BY COUNT(*) DESC
LIMIT 1;
```
![Screen Shot 2023-06-27 at 10 13 44 AM](https://github.com/kevincombs08/8_week_sql_challenge/assets/126277909/a0a6bb7c-74ae-4afd-95a6-909eec1868d3)

-- 5. Which item was the most popular for each customer?
```
with cte_1 as(
SELECT
	customer_id
    ,m.product_name
    ,COUNT(s.product_id) AS ct
    ,DENSE_RANK()
		OVER(PARTITION BY customer_id
				ORDER BY COUNT(s.product_id) DESC) AS d_rnk
FROM sales AS s
	LEFT JOIN menu AS m
		ON s.product_id = m.product_id
GROUP BY 1,2)
SELECT
	customer_id
    ,product_name
    ,ct
FROM cte_1
WHERE d_rnk = 1;
```
![Screen Shot 2023-06-27 at 10 15 07 AM](https://github.com/kevincombs08/8_week_sql_challenge/assets/126277909/9beb625d-f83d-4a1d-92ac-f4b48fb878a8)

-- 6. Which item was purchased first by the customer after they became a member?
```
with cte_1 AS(
SELECT
	mem.customer_id
    ,mem.join_date
    ,s.order_date
    ,m.product_name
    ,DENSE_RANK()
		OVER(PARTITION BY mem.customer_id
				ORDER BY s.order_date) AS d_rnk
FROM members AS mem
	LEFT JOIN sales AS s
		ON mem.customer_id = s.customer_id
	LEFT JOIN menu AS m
		ON s.product_id = m.product_id
WHERE s.order_date >= join_date)
SELECT
	customer_id
    ,product_name
    ,join_date
    ,order_date
FROM cte_1
WHERE d_rnk = 1;
```
![Screen Shot 2023-06-27 at 10 16 05 AM](https://github.com/kevincombs08/8_week_sql_challenge/assets/126277909/d6aff483-b1eb-4d55-bec2-07e1015eda85)

-- 7. Which item was purchased just before the customer became a member?
```
with cte_1 AS(
SELECT
	mem.customer_id
    ,mem.join_date
    ,s.order_date
    ,m.product_name
    ,DENSE_RANK()
		OVER(PARTITION BY mem.customer_id
				ORDER BY s.order_date DESC) AS d_rnk
FROM members AS mem
	LEFT JOIN sales AS s
		ON mem.customer_id = s.customer_id
	LEFT JOIN menu AS m
		ON s.product_id = m.product_id
WHERE s.order_date < join_date)
SELECT
	customer_id
    ,product_name
    ,join_date
    ,order_date
FROM cte_1
WHERE d_rnk = 1;
```
![Screen Shot 2023-06-27 at 10 16 44 AM](https://github.com/kevincombs08/8_week_sql_challenge/assets/126277909/5822e0da-cc5b-4a55-9ce4-1d81bf300cc4)

-- 8. What is the total items and amount spent for each member before they became a member?
```
with cte_1 AS(
SELECT
	mem.customer_id
    ,mem.join_date
    ,s.order_date
    ,m.product_name
    ,m.price
FROM members AS mem
	LEFT JOIN sales AS s
		ON mem.customer_id = s.customer_id
	LEFT JOIN menu AS m
		ON s.product_id = m.product_id
WHERE s.order_date < join_date)
SELECT
	customer_id
    ,COUNT(DISTINCT product_name) AS product
    ,SUM(price) AS total
FROM cte_1
GROUP BY 1; 
```
![Screen Shot 2023-06-27 at 10 17 13 AM](https://github.com/kevincombs08/8_week_sql_challenge/assets/126277909/34d35a20-62a9-48ba-9a12-53fd2406ad37)

-- 9.  If each $1 spent equates to 10 points and sushi has a 2x points multiplier - how many points would each customer have?
```
with cte_1 AS(
SELECT
	s.customer_id
	,s.product_id
    ,m.product_name
    ,m.price
    ,CASE WHEN m.product_id = 1 THEN (m.price * 20) ELSE (m.price * 10)END AS points
FROM sales AS s
	LEFT JOIN menu AS m
		ON s.product_id = m.product_id)
SELECT 
	customer_id
    ,SUM(points) AS points
FROM cte_1
GROUP BY 1; 
```
![Screen Shot 2023-06-27 at 10 18 03 AM](https://github.com/kevincombs08/8_week_sql_challenge/assets/126277909/78ee1d19-cb0c-462a-b062-a9adad8ad2bc)

-- 10. In the first week after a customer joins the program (including their join date) they earn 2x points on all items, not just sushi - how many points do customer A and B have at the end of January?
```
with cte_1 as(
SELECT
	s.customer_id
	,s.order_date
    ,join_date
    ,date_add(join_date, INTERVAL 6 DAY) AS join_plus_6
    ,last_day(join_date) AS EOM
    ,m.product_name
    ,m.price
    ,CASE WHEN m.product_id = 1 THEN (m.price * 20) 
			WHEN s.order_date BETWEEN join_date AND date_add(join_date, INTERVAL 6 DAY) THEN (m.price * 20) 
            ELSE (m.price * 10) END AS points
FROM members AS mem
	LEFT JOIN sales AS s
		ON mem.customer_id = s.customer_id
	LEFT JOIN menu AS m
		ON s.product_id = m.product_id
WHERE s.order_date < last_day(join_date)
ORDER BY s.order_date)
SELECT
	customer_id
    ,SUM(points) AS total
FROM cte_1
GROUP BY 1;
```
![Screen Shot 2023-06-27 at 10 18 40 AM](https://github.com/kevincombs08/8_week_sql_challenge/assets/126277909/eeb0b565-7c20-426b-b90d-2b7be76d91d3)
