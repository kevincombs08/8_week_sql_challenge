# -- Digital Analysis
-- Using the available datasets - answer the following questions using a single query for each one:

-- How many users are there?
```
SELECT
	COUNT(DISTINCT user_id) AS user_count
FROM users; 
```
![Screen Shot 2023-06-28 at 3 16 29 PM](https://github.com/kevincombs08/8_week_sql_challenge/assets/126277909/caf7b17b-9415-4210-9b29-2f34511c9d51)

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
![Screen Shot 2023-06-28 at 3 16 50 PM](https://github.com/kevincombs08/8_week_sql_challenge/assets/126277909/53587921-a554-43d5-8223-c04bf6d19563)

-- What is the unique number of visits by all users per month?
```    
SELECT
	EXTRACT(MONTH FROM event_time) AS month
    ,COUNT(DISTINCT visit_id) visit_count
FROM events
GROUP BY 1; 
```
![Screen Shot 2023-06-28 at 3 17 11 PM](https://github.com/kevincombs08/8_week_sql_challenge/assets/126277909/f3983259-e0d2-45cc-b612-de6a7a30e3d9)

-- What is the number of events for each event type?
```    
SELECT
	event_type
	,COUNT(*) AS event_count
FROM events
GROUP BY 1; 
```
![Screen Shot 2023-06-28 at 3 17 34 PM](https://github.com/kevincombs08/8_week_sql_challenge/assets/126277909/90db3fcc-2711-4fd8-9695-339ce8c911ba)
 
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
![Screen Shot 2023-06-28 at 3 25 48 PM](https://github.com/kevincombs08/8_week_sql_challenge/assets/126277909/b0de708e-fdf6-4949-ba9f-9052c0313daa)
 
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
![Screen Shot 2023-06-28 at 3 26 13 PM](https://github.com/kevincombs08/8_week_sql_challenge/assets/126277909/d2bc2644-abcf-4e69-ad50-f1012318757c)

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
![Screen Shot 2023-06-28 at 3 26 27 PM](https://github.com/kevincombs08/8_week_sql_challenge/assets/126277909/0a13f605-118f-414a-b73b-33ab15c76283)

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
![Screen Shot 2023-06-28 at 3 26 49 PM](https://github.com/kevincombs08/8_week_sql_challenge/assets/126277909/ed078f68-e0da-48b0-ae5b-457b3e74704d)

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
![Screen Shot 2023-06-28 at 3 27 14 PM](https://github.com/kevincombs08/8_week_sql_challenge/assets/126277909/985fddc3-0d96-4766-bcf3-9f23200e50f5)
   
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
![Screen Shot 2023-06-28 at 3 27 39 PM](https://github.com/kevincombs08/8_week_sql_challenge/assets/126277909/fa127a60-abe2-46bb-8f95-438f2b24642c)

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
![Screen Shot 2023-06-28 at 3 28 05 PM](https://github.com/kevincombs08/8_week_sql_challenge/assets/126277909/7fb99b88-1a5f-4072-83d6-da1819620dd9)

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
![Screen Shot 2023-06-28 at 3 28 35 PM](https://github.com/kevincombs08/8_week_sql_challenge/assets/126277909/18436199-99fe-44dc-870e-a36b78294815)

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
 ![Screen Shot 2023-06-28 at 3 29 00 PM](https://github.com/kevincombs08/8_week_sql_challenge/assets/126277909/76445690-6a5e-401f-a3ff-e7a87cdf379f)
   
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
![Screen Shot 2023-06-28 at 3 31 22 PM](https://github.com/kevincombs08/8_week_sql_challenge/assets/126277909/e6b13995-3229-4849-aed8-726294174b9a)
    
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
![Screen Shot 2023-06-28 at 3 31 56 PM](https://github.com/kevincombs08/8_week_sql_challenge/assets/126277909/c778e931-e6b9-4eb1-aa2c-a2cefb9b690e)

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
![Screen Shot 2023-06-28 at 3 32 38 PM](https://github.com/kevincombs08/8_week_sql_challenge/assets/126277909/f17720cb-056a-4a2e-85b9-d4c5cdb2781c)
  
