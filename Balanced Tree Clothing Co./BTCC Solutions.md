# -- High Level Sales Analysis

-- What was the total quantity sold for all products?
```
SELECT
	pd.product_name AS prod_name
    ,SUM(s.qty) AS total_sold
FROM bt_product_details AS pd
	LEFT JOIN bt_sales AS s 
		ON pd.product_id = s.prod_id
GROUP BY 1
ORDER BY SUM(s.qty) DESC; 
```
![Screen Shot 2023-07-17 at 11 53 54 AM](https://github.com/kevincombs08/8_week_sql_challenge/assets/126277909/44d983e1-02a8-40b3-89e6-cb40359cd664)

-- What is the total generated revenue for all products before discounts?
```
SELECT
	pd.product_name
    ,SUM(s.qty*s.price) AS revenue
FROM bt_product_details AS pd
	LEFT JOIN bt_sales AS s
		ON pd.product_id = s.prod_id
GROUP BY 1
ORDER BY SUM(s.qty*s.price) DESC;
```
![Screen Shot 2023-07-17 at 11 54 20 AM](https://github.com/kevincombs08/8_week_sql_challenge/assets/126277909/f072dca6-da09-447c-9fdc-70ee9a5a7028)

-- What was the total discount amount for all products?
```
SELECT
	pd.product_name
    ,ROUND(SUM(((s.qty*s.price*s.discount)/100)),0) AS discount
FROM bt_product_details AS pd
	LEFT JOIN bt_sales AS s
		ON pd.product_id = s.prod_id
GROUP BY 1 
ORDER BY SUM(((s.qty*s.price*s.discount)/100)) DESC;
```
![Screen Shot 2023-07-17 at 11 55 23 AM](https://github.com/kevincombs08/8_week_sql_challenge/assets/126277909/e8df821d-f5f2-4aa7-a189-f75924a89e92)

# -- Transaction Analysis

-- How many unique transactions were there?
```
SELECT
	COUNT(DISTINCT txn_id) AS unique_transactions
FROM bt_sales;
```
![Screen Shot 2023-07-17 at 11 55 59 AM](https://github.com/kevincombs08/8_week_sql_challenge/assets/126277909/cfddc5b1-54e1-4093-9ce0-f4af278e5b49)

-- What is the average unique products purchased in each transaction?
```
WITH cte_1 AS(
SELECT
	txn_id
    ,SUM(qty) AS total_qty
FROM bt_sales
GROUP BY 1)
SELECT
	ROUND(AVG(total_qty),0) AS avg_qt
FROM cte_1;
```
![Screen Shot 2023-07-17 at 12 00 10 PM](https://github.com/kevincombs08/8_week_sql_challenge/assets/126277909/5f6b5f55-8a38-442a-b4fb-f0de5195c6c5)

-- What is the average discount value per transaction?
```
WITH cte_1 AS(
SELECT
	txn_id
    ,(SUM(qty*price*discount)/100) AS discount
FROM bt_sales
GROUP BY 1)
SELECT
	ROUND(AVG(discount),0) AS avg_discount
FROM cte_1
ORDER BY ROUND(AVG(discount),0) DESC;
```
![Screen Shot 2023-07-17 at 12 00 33 PM](https://github.com/kevincombs08/8_week_sql_challenge/assets/126277909/cf9535fa-6eef-434a-a800-e9b29b6ed3a6)

-- What is the percentage split of all transactions for members vs non-members?
```
WITH cte_1 AS(
SELECT
	COUNT(txn_id) AS total_txn
    ,SUM(CASE WHEN member = 't' THEN 1 ELSE 0 END) AS member
    ,SUM(CASE WHEN member = 'f' THEN 1 ELSE 0 END) AS nonmember
FROM bt_sales)
SELECT
	CONCAT(ROUND(((member/total_txn)*100),0), '%') AS member_txn
    ,CONCAT(ROUND(((nonmember/total_txn)*100),0), '%') AS nonmember_txn
FROM cte_1; 
```
![Screen Shot 2023-07-17 at 12 10 29 PM](https://github.com/kevincombs08/8_week_sql_challenge/assets/126277909/b54dca58-74e3-42a4-9273-cd40f75fceca)

-- What is the average revenue for member transactions and non-member transactions?
```
WITH cte_1 AS(
SELECT 
	member
    ,txn_id
    ,SUM(qty*price) AS rev
FROM bt_sales
GROUP BY 1,2)
SELECT
	member
	,ROUND(AVG(rev),0) AS avg_rev
FROM cte_1
GROUP BY 1;
```
![Screen Shot 2023-07-17 at 12 10 48 PM](https://github.com/kevincombs08/8_week_sql_challenge/assets/126277909/7ebdf312-e8f0-45b4-8331-821fc997b5cd)

# -- Product Analysis

-- What are the top 3 products by total revenue before discount?
```
SELECT
	pd.product_name
    ,SUM(s.qty*s.price) AS rev
FROM bt_product_details AS pd
	LEFT JOIN bt_sales AS s
		ON pd.product_id = s.prod_id
GROUP BY 1
ORDER BY SUM(s.qty*s.price) DESC
LIMIT 3;
```
![Screen Shot 2023-07-17 at 12 14 50 PM](https://github.com/kevincombs08/8_week_sql_challenge/assets/126277909/8564e343-5253-4acf-9413-9ec8f85de827)

-- What is the total quantity, revenue and discount for each segment?
```
SELECT
	pd.segment_name
    ,SUM(s.qty) AS qty
    ,SUM(s.qty*s.price) AS rev
    ,ROUND((SUM(s.qty*s.price*s.discount)/100),0) AS discount
FROM bt_sales AS s
	LEFT JOIN bt_product_details AS pd
		ON pd.product_id = s.prod_id
GROUP BY 1;
```
![Screen Shot 2023-07-17 at 12 15 08 PM](https://github.com/kevincombs08/8_week_sql_challenge/assets/126277909/9316bf36-6d84-4735-9b7e-7aa61f74134e)

-- What is the top selling product for each segment?
```
WITH cte_1 AS(
SELECT
	pd.segment_name AS segment
    ,pd.product_name AS product
    ,SUM(s.qty*s.price) AS rev
    ,DENSE_RANK()
		OVER(PARTITION BY pd.segment_name ORDER BY SUM(s.qty*s.price) DESC) AS rnk
FROM bt_sales AS s
	LEFT JOIN bt_product_details AS pd
		ON pd.product_id = s.prod_id
GROUP BY 1,2)
SELECT
	segment
    ,product
    ,rev
FROM cte_1
WHERE rnk = 1; 
```
![Screen Shot 2023-07-17 at 12 15 37 PM](https://github.com/kevincombs08/8_week_sql_challenge/assets/126277909/9f3a7f12-33ef-4207-86dc-7f18ae346df1)

-- What is the total quantity, revenue and discount for each category?
```
SELECT
	pd.category_name
    ,SUM(s.qty) AS qty
    ,SUM(s.qty*s.price) AS rev
    ,ROUND((SUM(s.qty*s.price*s.discount)/100),0) AS discount
FROM bt_sales AS s
	LEFT JOIN bt_product_details AS pd
		ON pd.product_id = s.prod_id
GROUP BY 1;
```
![Screen Shot 2023-07-17 at 12 15 54 PM](https://github.com/kevincombs08/8_week_sql_challenge/assets/126277909/3b1d39b8-0622-440e-983e-9b33cff66cf0)

-- What is the top selling product for each category?
```
WITH cte_1 AS(
SELECT
	pd.category_name AS category
    ,pd.product_name AS product
    ,SUM(s.qty*s.price) AS rev
    ,DENSE_RANK()
		OVER(PARTITION BY pd.category_name ORDER BY SUM(s.qty*s.price) DESC) AS rnk
FROM bt_sales AS s
	LEFT JOIN bt_product_details AS pd
		ON pd.product_id = s.prod_id
GROUP BY 1,2)
SELECT
	category
    ,product
    ,rev
FROM cte_1
WHERE rnk = 1;
```
![Screen Shot 2023-07-17 at 12 16 14 PM](https://github.com/kevincombs08/8_week_sql_challenge/assets/126277909/2b29f6e2-6b4f-49fd-9084-3b8119570505)

-- What is the percentage split of revenue by product for each segment?
```
WITH cte_1 AS(
SELECT
	pd.segment_name AS segment
    ,pd.product_name AS prod
    ,SUM(s.qty*s.price) AS rev
FROM bt_sales AS s
	LEFT JOIN bt_product_details AS pd
		ON pd.product_id = s.prod_id
GROUP BY 1,2)
SELECT
	segment
    ,prod
    ,rev
    ,ROUND(rev/SUM(rev)
		OVER(PARTITION BY segment),2) AS pct_split
FROM cte_1
GROUP BY 1,2,3
ORDER BY 1,3 DESC;
```
![Screen Shot 2023-07-17 at 12 16 36 PM](https://github.com/kevincombs08/8_week_sql_challenge/assets/126277909/27e0cd80-42c1-4316-8452-7dc19b1c9e78)

-- What is the percentage split of revenue by segment for each category?
```
WITH cte_1 AS(
SELECT
	pd.category_name AS category
    ,pd.segment_name AS segment
    ,SUM(s.qty*s.price) AS rev
FROM bt_sales AS s
	LEFT JOIN bt_product_details AS pd
		ON pd.product_id = s.prod_id
GROUP BY 1,2)
SELECT
	category
    ,segment
    ,rev
    ,ROUND(rev/SUM(rev)
		OVER(PARTITION BY category),2) AS pct_split
FROM cte_1
GROUP BY 1,2,3
ORDER BY 1,3 DESC;
```
![Screen Shot 2023-07-17 at 12 18 09 PM](https://github.com/kevincombs08/8_week_sql_challenge/assets/126277909/d441b95b-564d-4de5-88d8-87993ea22746)

-- What is the percentage split of total revenue by category?
```
WITH cte_1 AS(
SELECT
	pd.category_name AS category
    ,SUM(s.qty*s.price) AS rev
FROM bt_sales AS s
	LEFT JOIN bt_product_details AS pd
		ON pd.product_id = s.prod_id
GROUP BY 1)
SELECT
	category
    ,rev
    ,ROUND((rev/(SELECT SUM(rev) FROM cte_1)),2) AS split_pct
FROM cte_1
GROUP BY 1
ORDER BY 3 DESC;
```	
![Screen Shot 2023-07-17 at 12 18 35 PM](https://github.com/kevincombs08/8_week_sql_challenge/assets/126277909/4d925185-fd96-4fc8-852d-4928072a93d7)

-- What is the total transaction “penetration” for each product? (hint: penetration = number of transactions where at least 1 quantity of a product was purchased divided by total number of transactions)
```
SELECT
	pd.product_name
    ,COUNT(DISTINCT s.txn_id)/
		(SELECT COUNT(DISTINCT txn_id) 
			FROM bt_sales) AS pent_pct
FROM bt_sales AS s
	LEFT JOIN bt_product_details AS pd
		ON pd.product_id = s.prod_id
GROUP BY 1
ORDER BY 2 DESC;
```
![Screen Shot 2023-07-17 at 12 23 14 PM](https://github.com/kevincombs08/8_week_sql_challenge/assets/126277909/962136d1-90b6-4222-9dd9-d391886c1287)

-- What is the most common combination of at least 1 quantity of any 3 products in a 1 single transaction?
```
SELECT
	s.prod_id AS prod_1
    ,s2.prod_id AS prod_2
    ,s3.prod_id AS prod_3
    ,COUNT(*) AS combos
FROM bt_sales AS s
	INNER JOIN bt_sales AS s2
		ON s.txn_id = s2.txn_id
			AND s.prod_id < s2.prod_id
	INNER JOIN bt_sales AS s3
		ON s2.txn_id = s3.txn_id
			AND s2.prod_id < s3.prod_id
WHERE s.qty >= 1
GROUP BY 1,2,3
ORDER BY 4 DESC
LIMIT 1;
```
![Screen Shot 2023-07-17 at 12 23 37 PM](https://github.com/kevincombs08/8_week_sql_challenge/assets/126277909/1e7d819b-b6be-4fd5-bbd3-41a33b7bef91)




