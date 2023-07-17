# -- Digital Analysis
-- Using the available datasets - answer the following questions using a single query for each one:

-- How many users are there?
```
SELECT
	COUNT(DISTINCT user_id) AS user_count
FROM users; 
```
![Screen Shot 2023-07-17 at 2 55 42 PM](https://github.com/kevincombs08/8_week_sql_challenge/assets/126277909/f7b19588-6594-4245-b383-b56d6d48c5ec)

-- How many cookies does each user have on average?
```
WITH cookie_count AS(
SELECT 
	user_id
    ,COUNT(cookie_id) cookie_count
FROM users
GROUP BY 1)
SELECT 
	ROUND(AVG(cookie_count),0) AS avg_count
FROM cookie_count;
```
![Screen Shot 2023-07-17 at 2 56 06 PM](https://github.com/kevincombs08/8_week_sql_challenge/assets/126277909/7c905e52-b9d3-4a08-93e3-c24204b8e7d7)

-- What is the unique number of visits by all users per month?
```    
SELECT
	EXTRACT(MONTH FROM event_time) AS month
    ,COUNT(DISTINCT visit_id) visit_count
FROM events
GROUP BY 1; 
```
![Screen Shot 2023-07-17 at 2 56 28 PM](https://github.com/kevincombs08/8_week_sql_challenge/assets/126277909/dde0e9dc-5f2c-4acc-a495-2f0b9d603f6c)

-- What is the number of events for each event type?
```    
SELECT
	event_type
	,COUNT(*) AS event_count
FROM events
GROUP BY 1; 
```
![Screen Shot 2023-07-17 at 3 14 25 PM](https://github.com/kevincombs08/8_week_sql_challenge/assets/126277909/58cf0d15-6c3b-4e92-b7b6-c1cc7aa278ce)

-- What is the percentage of visits which have a purchase event?
```
WITH purchases_per_visit AS(    
SELECT
	COUNT(DISTINCT visit_id) AS visit_count
    ,SUM(CASE WHEN event_type = '3' THEN 1 ELSE 0 END) AS purchases 
FROM events)
SELECT
	CONCAT(ROUND(((purchases/visit_count)*100),0),'%') AS purchase_pct
FROM purchases_per_visit;
```
 ![Screen Shot 2023-07-17 at 3 14 45 PM](https://github.com/kevincombs08/8_week_sql_challenge/assets/126277909/1a398584-6a59-4e08-abe3-7ec74dc3c784)

-- What is the percentage of visits which view the checkout page but do not have a purchase event?
```
WITH checkouts AS(    
SELECT
	visit_id
    ,SUM(CASE WHEN page_id = '12' THEN 1 ELSE 0 END) AS checkout
    ,SUM(CASE WHEN event_type = '3' THEN 1 ELSE 0 END) AS purchases
FROM events
GROUP BY 1)
SELECT
	CONCAT(ROUND(((1-(SUM(purchases)/SUM(checkout)))*100),0),'%') AS checkout_pct
FROM checkouts;
```
![Screen Shot 2023-07-17 at 3 15 05 PM](https://github.com/kevincombs08/8_week_sql_challenge/assets/126277909/7cc3648a-0c8e-498a-854a-8222b73922fb)

-- What are the top 3 pages by number of views?
```    
SELECT
	page_id
    ,SUM(CASE WHEN event_type = '1' THEN 1 ELSE 0 END) AS page_views
FROM events
GROUP BY 1
ORDER BY page_views DESC
LIMIT 3;
```
![Screen Shot 2023-07-17 at 3 18 11 PM](https://github.com/kevincombs08/8_week_sql_challenge/assets/126277909/8f03e9bf-5ac7-48b0-9999-a7149e17690f)

-- What is the number of views and cart adds for each product category?
```    
SELECT
	p.product_category
    ,SUM(CASE WHEN e.event_type = '1' THEN 1 ELSE 0 END) AS page_view
    ,SUM(CASE WHEN e.event_type = '2' THEN 1 ELSE 0 END) AS cart_adds
FROM events AS e
	LEFT JOIN page_hierarchy AS p
		ON e.page_id = p.page_id
WHERE p.product_category IS NOT NULL
GROUP BY 1
ORDER BY page_view DESC; 
```
![Screen Shot 2023-07-17 at 3 18 32 PM](https://github.com/kevincombs08/8_week_sql_challenge/assets/126277909/b449fbed-2c4c-4a11-884d-6636d455f47f)

# -- Product Funnel Analysis
-- Using a single SQL query - create a new output table which has the following details:

-- How many times was each product viewed?

-- How many times was each product added to cart?

-- How many times was each product added to a cart but not purchased (abandoned)?

-- How many times was each product purchased?

```    
WITH page_stats AS(
SELECT
	e.visit_id AS visit_id
    ,ph.page_name AS page_name
    ,SUM(CASE WHEN e.event_type = '1' THEN 1 ELSE 0 END) AS page_views
    ,SUM(CASE WHEN e.event_type = '2' THEN 1 ELSE 0 END) AS add_to_cart
FROM events AS e
	LEFT JOIN page_hierarchy AS ph
		ON e.page_id = ph.page_id
WHERE ph.product_category IS NOT NULL
GROUP BY 1,2)
,
purchase_stats AS(
SELECT
	 DISTINCT visit_id
FROM events
WHERE event_type = '3')
,
overall_stats AS(
SELECT
	ps.visit_id AS visit_id
    ,ps.page_name AS pages
    ,SUM(ps.page_views) AS pv
    ,SUM(ps.add_to_cart) AS atc
    ,COUNT(pu.visit_id) AS purchases
FROM page_stats AS ps
	LEFT JOIN purchase_stats AS pu
		ON ps.visit_id = pu.visit_id
GROUP BY 1,2)
,
tables AS(
SELECT
	pages
    ,SUM(pv) AS page_views
    ,SUM(atc) AS add_to_carts
    ,SUM(CASE WHEN atc = '1' AND purchases = '0' THEN 1 ELSE 0 END) AS abandoned
    ,SUM(CASE WHEN atc = '1' AND purchases = '1' THEN 1 ELSE 0 END) AS purchases
FROM overall_stats
GROUP BY 1)
SELECT 
	* 
FROM tables
ORDER BY pages ASC;
```
![Screen Shot 2023-07-17 at 3 18 58 PM](https://github.com/kevincombs08/8_week_sql_challenge/assets/126277909/0a155062-68dd-4873-9306-e55bae0dc9dd)

-- Additionally, create another table which further aggregates the data for the above points but this time for each product category instead of individual products.
```    
WITH page_stats AS(
SELECT
	e.visit_id AS visit_id
    ,ph.page_name AS page_name
    ,ph.product_category AS product_category
    ,SUM(CASE WHEN e.event_type = '1' THEN 1 ELSE 0 END) AS page_views
    ,SUM(CASE WHEN e.event_type = '2' THEN 1 ELSE 0 END) AS add_to_cart
FROM events AS e
	LEFT JOIN page_hierarchy AS ph
		ON e.page_id = ph.page_id
WHERE ph.product_category IS NOT NULL
GROUP BY 1,2,3)
,
purchase_stats AS(
SELECT
	 DISTINCT visit_id
FROM events
WHERE event_type = '3')
,
overall_stats AS(
SELECT
	ps.visit_id AS visit_id
    ,ps.page_name AS pages
    ,ps.product_category AS category
    ,SUM(ps.page_views) AS pv
    ,SUM(ps.add_to_cart) AS atc
    ,COUNT(pu.visit_id) AS purchases
FROM page_stats AS ps
	LEFT JOIN purchase_stats AS pu
		ON ps.visit_id = pu.visit_id
GROUP BY 1,2,3)
,
tables AS(
SELECT
	pages
    ,category
    ,SUM(pv) AS page_views
    ,SUM(atc) AS add_to_carts
    ,SUM(CASE WHEN atc = '1' AND purchases = '0' THEN 1 ELSE 0 END) AS abandoned
    ,SUM(CASE WHEN atc = '1' AND purchases = '1' THEN 1 ELSE 0 END) AS purchases
FROM overall_stats
GROUP BY 1,2)
SELECT 
	category
	,SUM(page_views) AS page_views
    ,SUM(add_to_carts) AS add_to_carts
    ,SUM(abandoned) AS abandoned
    ,SUM(purchases) AS purchases
FROM tables
GROUP BY 1;
```
![Screen Shot 2023-07-17 at 3 19 28 PM](https://github.com/kevincombs08/8_week_sql_challenge/assets/126277909/211cf734-6c31-4edd-b586-e5f6e0df9693)


-- Use your 2 new output tables - answer the following questions:

-- Which product had the most views, cart adds and purchases?
```
WITH page_stats AS(
SELECT
	e.visit_id AS visit_id
    ,ph.page_name AS page_name
    ,SUM(CASE WHEN e.event_type = '1' THEN 1 ELSE 0 END) AS page_views
    ,SUM(CASE WHEN e.event_type = '2' THEN 1 ELSE 0 END) AS add_to_cart
FROM events AS e
	LEFT JOIN page_hierarchy AS ph
		ON e.page_id = ph.page_id
WHERE ph.product_category IS NOT NULL
GROUP BY 1,2)
,
purchase_stats AS(
SELECT
	 DISTINCT visit_id
FROM events
WHERE event_type = '3')
,
overall_stats AS(
SELECT
	ps.visit_id AS visit_id
    ,ps.page_name AS pages
    ,SUM(ps.page_views) AS pv
    ,SUM(ps.add_to_cart) AS atc
    ,COUNT(pu.visit_id) AS purchases
FROM page_stats AS ps
	LEFT JOIN purchase_stats AS pu
		ON ps.visit_id = pu.visit_id
GROUP BY 1,2)
,
tables AS(
SELECT
	pages
    ,SUM(pv) AS page_views
    ,SUM(atc) AS add_to_carts
    ,SUM(CASE WHEN atc = '1' AND purchases = '0' THEN 1 ELSE 0 END) AS abandoned
    ,SUM(CASE WHEN atc = '1' AND purchases = '1' THEN 1 ELSE 0 END) AS purchases
FROM overall_stats
GROUP BY 1)
SELECT 
	*
FROM tables
ORDER BY page_views DESC;
```
![Screen Shot 2023-07-17 at 3 19 52 PM](https://github.com/kevincombs08/8_week_sql_challenge/assets/126277909/fba4593e-0a41-4b2b-9e58-11096b716f2f)

-- Which product was most likely to be abandoned?
```    
WITH page_stats AS(
SELECT
	e.visit_id AS visit_id
    ,ph.page_name AS page_name
    ,SUM(CASE WHEN e.event_type = '1' THEN 1 ELSE 0 END) AS page_views
    ,SUM(CASE WHEN e.event_type = '2' THEN 1 ELSE 0 END) AS add_to_cart
FROM events AS e
	LEFT JOIN page_hierarchy AS ph
		ON e.page_id = ph.page_id
WHERE ph.product_category IS NOT NULL
GROUP BY 1,2)
,
purchase_stats AS(
SELECT
	 DISTINCT visit_id
FROM events
WHERE event_type = '3')
,
overall_stats AS(
SELECT
	ps.visit_id AS visit_id
    ,ps.page_name AS pages
    ,SUM(ps.page_views) AS pv
    ,SUM(ps.add_to_cart) AS atc
    ,COUNT(pu.visit_id) AS purchases
FROM page_stats AS ps
	LEFT JOIN purchase_stats AS pu
		ON ps.visit_id = pu.visit_id
GROUP BY 1,2)
,
tables AS(
SELECT
	pages
    ,SUM(pv) AS page_views
    ,SUM(atc) AS add_to_carts
    ,SUM(CASE WHEN atc = '1' AND purchases = '0' THEN 1 ELSE 0 END) AS abandoned
    ,SUM(CASE WHEN atc = '1' AND purchases = '1' THEN 1 ELSE 0 END) AS purchases
FROM overall_stats
GROUP BY 1)
SELECT 
	*
FROM tables
ORDER BY abandoned DESC;
```
![Screen Shot 2023-07-17 at 3 20 20 PM](https://github.com/kevincombs08/8_week_sql_challenge/assets/126277909/ec4b9cf0-3609-4bef-ab8b-6b032647de6c)

-- Which product had the highest view to purchase percentage?
```    
WITH page_stats AS(
SELECT
	e.visit_id AS visit_id
    ,ph.page_name AS page_name
    ,SUM(CASE WHEN e.event_type = '1' THEN 1 ELSE 0 END) AS page_views
    ,SUM(CASE WHEN e.event_type = '2' THEN 1 ELSE 0 END) AS add_to_cart
FROM events AS e
	LEFT JOIN page_hierarchy AS ph
		ON e.page_id = ph.page_id
WHERE ph.product_category IS NOT NULL
GROUP BY 1,2)
,
purchase_stats AS(
SELECT
	 DISTINCT visit_id
FROM events
WHERE event_type = '3')
,
overall_stats AS(
SELECT
	ps.visit_id AS visit_id
    ,ps.page_name AS pages
    ,SUM(ps.page_views) AS pv
    ,SUM(ps.add_to_cart) AS atc
    ,COUNT(pu.visit_id) AS purchases
FROM page_stats AS ps
	LEFT JOIN purchase_stats AS pu
		ON ps.visit_id = pu.visit_id
GROUP BY 1,2)
,
tables AS(
SELECT
	pages
    ,SUM(pv) AS page_views
    ,SUM(atc) AS add_to_carts
    ,SUM(CASE WHEN atc = '1' AND purchases = '0' THEN 1 ELSE 0 END) AS abandoned
    ,SUM(CASE WHEN atc = '1' AND purchases = '1' THEN 1 ELSE 0 END) AS purchases
FROM overall_stats
GROUP BY 1)
SELECT 
	pages
    ,CONCAT(ROUND(((purchases/page_views)*100),2), '%') AS view_to_purchase
FROM tables
ORDER BY CONCAT(ROUND(((purchases/page_views)*100),2), '%') DESC;
```
![Screen Shot 2023-07-17 at 3 20 44 PM](https://github.com/kevincombs08/8_week_sql_challenge/assets/126277909/7e841919-dd8e-4464-9e91-0bbbc9ebdb28)

-- What is the average conversion rate from view to cart add?
```    
WITH page_stats AS(
SELECT
	e.visit_id AS visit_id
    ,ph.page_name AS page_name
    ,SUM(CASE WHEN e.event_type = '1' THEN 1 ELSE 0 END) AS page_views
    ,SUM(CASE WHEN e.event_type = '2' THEN 1 ELSE 0 END) AS add_to_cart
FROM events AS e
	LEFT JOIN page_hierarchy AS ph
		ON e.page_id = ph.page_id
WHERE ph.product_category IS NOT NULL
GROUP BY 1,2)
,
purchase_stats AS(
SELECT
	 DISTINCT visit_id
FROM events
WHERE event_type = '3')
,
overall_stats AS(
SELECT
	ps.visit_id AS visit_id
    ,ps.page_name AS pages
    ,SUM(ps.page_views) AS pv
    ,SUM(ps.add_to_cart) AS atc
    ,COUNT(pu.visit_id) AS purchases
FROM page_stats AS ps
	LEFT JOIN purchase_stats AS pu
		ON ps.visit_id = pu.visit_id
GROUP BY 1,2)
,
tables AS(
SELECT
	pages
    ,SUM(pv) AS page_views
    ,SUM(atc) AS add_to_carts
    ,SUM(CASE WHEN atc = '1' AND purchases = '0' THEN 1 ELSE 0 END) AS abandoned
    ,SUM(CASE WHEN atc = '1' AND purchases = '1' THEN 1 ELSE 0 END) AS purchases
FROM overall_stats
GROUP BY 1)
SELECT 
	pages
    ,CONCAT(ROUND(((add_to_carts/page_views)*100),2), '%') AS atc_to_view
FROM tables
ORDER BY CONCAT(ROUND(((add_to_carts/page_views)*100),2), '%') DESC;
```
![Screen Shot 2023-07-17 at 3 21 17 PM](https://github.com/kevincombs08/8_week_sql_challenge/assets/126277909/aa86115b-14bb-4a9c-9f29-cf00f9e6915c)

    
-- What is the average conversion rate from cart add to purchase?
```    
WITH page_stats AS(
SELECT
	e.visit_id AS visit_id
    ,ph.page_name AS page_name
    ,SUM(CASE WHEN e.event_type = '1' THEN 1 ELSE 0 END) AS page_views
    ,SUM(CASE WHEN e.event_type = '2' THEN 1 ELSE 0 END) AS add_to_cart
FROM events AS e
	LEFT JOIN page_hierarchy AS ph
		ON e.page_id = ph.page_id
WHERE ph.product_category IS NOT NULL
GROUP BY 1,2)
,
purchase_stats AS(
SELECT
	 DISTINCT visit_id
FROM events
WHERE event_type = '3')
,
overall_stats AS(
SELECT
	ps.visit_id AS visit_id
    ,ps.page_name AS pages
    ,SUM(ps.page_views) AS pv
    ,SUM(ps.add_to_cart) AS atc
    ,COUNT(pu.visit_id) AS purchases
FROM page_stats AS ps
	LEFT JOIN purchase_stats AS pu
		ON ps.visit_id = pu.visit_id
GROUP BY 1,2)
,
tables AS(
SELECT
	pages
    ,SUM(pv) AS page_views
    ,SUM(atc) AS add_to_carts
    ,SUM(CASE WHEN atc = '1' AND purchases = '0' THEN 1 ELSE 0 END) AS abandoned
    ,SUM(CASE WHEN atc = '1' AND purchases = '1' THEN 1 ELSE 0 END) AS purchases
FROM overall_stats
GROUP BY 1)
SELECT 
	pages
    ,CONCAT(ROUND(((purchases/add_to_carts)*100),2), '%') AS purchase_cvr
FROM tables
ORDER BY CONCAT(ROUND(((purchases/add_to_carts)*100),2), '%') DESC;
```
![Screen Shot 2023-07-17 at 3 21 39 PM](https://github.com/kevincombs08/8_week_sql_challenge/assets/126277909/ba1e454a-0b00-4422-8df6-b0607dfc4f19)

# -- Campaigns Analysis
-- Generate a table that has 1 single row for every unique visit_id record and has the following columns:

-- user_id

-- visit_id

-- visit_start_time: the earliest event_time for each visit

-- page_views: count of page views for each visit

-- cart_adds: count of product cart add events for each visit

-- purchase: 1/0 flag if a purchase event exists for each visit

-- campaign_name: map the visit to a campaign if the visit_start_time falls between the start_date and end_date

-- impression: count of ad impressions for each visit

-- click: count of ad clicks for each visit

-- (Optional column) cart_products: a comma separated text value with products added to the cart sorted by the order they were added to the cart (hint: use the sequence_number)

```
SELECT
	u.user_id AS user_id
    ,ev.visit_id AS visit_id
    ,c.campaign_name AS camp_name
    ,MIN(ev.event_time) AS start_date
    ,SUM(CASE WHEN ev.event_type = 1 THEN 1 ELSE 0 END) AS pvs
	,SUM(CASE WHEN ev.event_type = 2 THEN 1 ELSE 0 END) AS atc
	,SUM(CASE WHEN ev.event_type = 3 THEN 1 ELSE 0 END) AS purchase
    ,SUM(CASE WHEN ev.event_type = 4 THEN 1 ELSE 0 END) AS impression
    ,SUM(CASE WHEN ev.event_type = 5 THEN 1 ELSE 0 END) AS click
    ,GROUP_CONCAT(CASE WHEN ph.product_id IS NOT NULL AND ev.event_type = 2 THEN ph.page_name ELSE NULL END ORDER BY ev.sequence_number) AS atc_products
FROM events AS ev
	INNER JOIN users AS u
		ON ev.cookie_id = u.cookie_id
	LEFT JOIN page_hierarchy AS ph
		ON ph.page_id = ev.page_id
	LEFT JOIN campaign_identifier AS c
		ON ev.event_time BETWEEN c.start_date AND c.end_date
GROUP BY 1,2,3;
ORDER BY u.user_id;
```
![Screen Shot 2023-07-17 at 3 22 02 PM](https://github.com/kevincombs08/8_week_sql_challenge/assets/126277909/c11072f3-f36d-43af-afcc-0c0a3329763a)


