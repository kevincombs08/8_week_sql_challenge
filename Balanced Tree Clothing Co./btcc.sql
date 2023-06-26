		-- High Level Sales Analysis
-- What was the total quantity sold for all products?

SELECT
	pd.product_name AS prod_name
    ,SUM(s.qty) AS total_sold
FROM bt_product_details AS pd
	LEFT JOIN bt_sales AS s 
		ON pd.product_id = s.prod_id
GROUP BY 1
ORDER BY SUM(s.qty) DESC; 
	
-- What is the total generated revenue for all products before discounts?

SELECT
	pd.product_name
    ,SUM(s.qty*s.price) AS revenue
FROM bt_product_details AS pd
	LEFT JOIN bt_sales AS s
		ON pd.product_id = s.prod_id
GROUP BY 1
ORDER BY SUM(s.qty*s.price) DESC;

-- What was the total discount amount for all products?

SELECT
	pd.product_name
    ,ROUND(SUM(((s.qty*s.price*s.discount)/100)),0) AS discount
FROM bt_product_details AS pd
	LEFT JOIN bt_sales AS s
		ON pd.product_id = s.prod_id
GROUP BY 1 
ORDER BY SUM(((s.qty*s.price*s.discount)/100)) DESC;

		-- Transaction Analysis
-- How many unique transactions were there?

SELECT
	COUNT(DISTINCT txn_id) AS unique_transactions
FROM bt_sales;

-- What is the average unique products purchased in each transaction?

WITH cte_1 AS(
SELECT
	txn_id
    ,SUM(qty) AS total_qty
FROM bt_sales
GROUP BY 1)
SELECT
	ROUND(AVG(total_qty),0) AS avg_qt
FROM cte_1;

-- What is the average discount value per transaction?

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

-- What is the percentage split of all transactions for members vs non-members?

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

-- What is the average revenue for member transactions and non-member transactions?

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

		-- Product Analysis
-- What are the top 3 products by total revenue before discount?

SELECT
	pd.product_name
    ,SUM(s.qty*s.price) AS rev
FROM bt_product_details AS pd
	LEFT JOIN bt_sales AS s
		ON pd.product_id = s.prod_id
GROUP BY 1
ORDER BY SUM(s.qty*s.price) DESC
LIMIT 3;

-- What is the total quantity, revenue and discount for each segment?

SELECT
	pd.segment_name
    ,SUM(s.qty) AS qty
    ,SUM(s.qty*s.price) AS rev
    ,ROUND((SUM(s.qty*s.price*s.discount)/100),0) AS discount
FROM bt_sales AS s
	LEFT JOIN bt_product_details AS pd
		ON pd.product_id = s.prod_id
GROUP BY 1;

-- What is the top selling product for each segment?

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

-- What is the total quantity, revenue and discount for each category?

SELECT
	pd.category_name
    ,SUM(s.qty) AS qty
    ,SUM(s.qty*s.price) AS rev
    ,ROUND((SUM(s.qty*s.price*s.discount)/100),0) AS discount
FROM bt_sales AS s
	LEFT JOIN bt_product_details AS pd
		ON pd.product_id = s.prod_id
GROUP BY 1;

-- What is the top selling product for each category?

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

-- What is the percentage split of revenue by product for each segment?

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

-- What is the percentage split of revenue by segment for each category?

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

-- What is the percentage split of total revenue by category?

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
	
	
-- What is the total transaction “penetration” for each product? (hint: penetration = number of transactions where at least 1 quantity of a product was purchased divided by total number of transactions)

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

-- What is the most common combination of at least 1 quantity of any 3 products in a 1 single transaction?

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


