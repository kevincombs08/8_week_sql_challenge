		-- Data Exploration and Cleansing
-- Update the fresh_segments.interest_metrics table by modifying the month_year column to be a date data type with the start of the month

UPDATE fs_interest_metrics
	SET day_month_year = STR_TO_DATE(day_month_year, '%d-%m-%Y');

ALTER TABLE fs_interest_metrics
	MODIFY COLUMN day_month_year DATE;

-- What is count of records in the fresh_segments.interest_metrics for each month_year value sorted in chronological order (earliest to latest) with the null values appearing first?

SELECT
	day_month_year
    ,COUNT(1)
FROM fs_interest_metrics
GROUP BY 1
ORDER BY 1 IS NULL DESC, 1 ASC; 

-- What do you think we should do with these null values in the fresh_segments.interest_metrics

CREATE TABLE fs_interest_metrics_clean AS(
SELECT * FROM fs_interest_metrics
WHERE day_month_year IS NOT NULL);

-- How many interest_id values exist in the fresh_segments.interest_metrics table but not in the fresh_segments.interest_map table? What about the other way around?

ALTER TABLE fs_interest_metrics
	MODIFY COLUMN interest_id INT;
ALTER TABLE fs_interest_metrics_clean
	MODIFY COLUMN interest_id INT;

SELECT
	COUNT(interest_id)
FROM fs_interest_metrics_clean
WHERE interest_id NOT IN
	(SELECT id FROM fs_interest_map); 

SELECT 
	COUNT(id)
FROM fs_interest_map
WHERE id NOT IN
	(SELECT interest_id FROM fs_interest_metrics_clean);

-- Summarise the id values in the fresh_segments.interest_map by its total record count in this table

SELECT
	COUNT(DISTINCT id)
FROM fs_interest_map;

-- What sort of table join should we perform for our analysis and why? Check your logic by checking the rows where interest_id = 21246 in your joined output and include all columns from fresh_segments.interest_metrics and all columns from fresh_segments.interest_map except from the id column.

SELECT
	fc.interest_id
	,fc._month
    ,fc._year
    ,fc.day_month_year
    ,fc.composition
    ,fc.index_value
    ,fc.ranking
    ,fc.percentile_ranking
    ,fm.interest_name
    ,fm.interest_summary
    ,fm.created_at
    ,fm.last_modified
FROM fs_interest_metrics_clean AS fc
LEFT JOIN fs_interest_map AS fm
	ON fc.interest_id = fm.id
WHERE fc.interest_id = '21246';
    
-- Are there any records in your joined table where the month_year value is before the created_at value from the fresh_segments.interest_map table? Do you think these values are valid and why?

WITH cte_1 AS(
SELECT
	fc.interest_id
	,fc._month
    ,fc._year
    ,fc.day_month_year
    ,fc.composition
    ,fc.index_value
    ,fc.ranking
    ,fc.percentile_ranking
    ,fm.interest_name
    ,fm.interest_summary
    ,fm.created_at
    ,fm.last_modified
FROM fs_interest_metrics_clean AS fc
INNER JOIN fs_interest_map AS fm
	ON fc.interest_id = fm.id
AND fc.day_month_year < fm.created_at)
SELECT
	COUNT(*)
FROM cte_1; 

        -- Interest Analysis
-- Which interests have been present in all month_year dates in our dataset?

WITH cte_1 AS(
	SELECT
		interest_id
        ,COUNT(DISTINCT day_month_year) AS dt
	FROM fs_interest_metrics_clean
    GROUP BY 1
    HAVING COUNT(DISTINCT day_month_year) = '14'
    ORDER BY 2 DESC)
SELECT
	COUNT(*)
FROM cte_1;
	
-- Using this same total_months measure - calculate the cumulative percentage of all records starting at 14 months - which total_months value passes the 90% cumulative percentage value?

WITH cte_1 AS(
SELECT
		interest_id
        ,COUNT(DISTINCT day_month_year) AS dt
	FROM fs_interest_metrics_clean
    GROUP BY 1
    ORDER BY 2 DESC)
,
cte_2 AS(
SELECT
	dt
    ,COUNT(DISTINCT interest_id) AS int_ct
FROM cte_1 
GROUP BY 1
ORDER BY 2 DESC)
,
cte_3 AS(
SELECT
	dt
    ,int_ct
    ,CONCAT(ROUND(100*(int_ct/(SELECT SUM(int_ct) FROM cte_2)),0),'%') AS pct
FROM cte_2)
SELECT
	dt
    ,int_ct
    ,pct
    ,CONCAT(SUM(pct)
		OVER(ORDER BY dt DESC),'%') AS sum_pct
FROM cte_3;

-- If we were to remove all interest_id values which are lower than the total_months value we found in the previous question - how many total data points would we be removing?

SELECT COUNT(*) AS rows_cnt_to_remove
FROM fs_interest_joined
WHERE interest_id IN (SELECT interest_id
					  FROM (SELECT interest_id,
                                   COUNT(DISTINCT day_month_year) AS dates_cnt
                            FROM fs_interest_joined
                            GROUP BY 1
                            HAVING COUNT(DISTINCT day_month_year) < 6) t);
                            
WITH cte_1 AS(
SELECT
	interest_id
FROM(SELECT
	interest_id
    ,COUNT(DISTINCT day_month_year)
FROM fs_interest_joined
GROUP BY 1
HAVING COUNT(DISTINCT day_month_year) < 6) AS t)
SELECT COUNT(*)
FROM cte_1;

-- Does this decision make sense to remove these data points from a business perspective? Use an example where there are all 14 months present to a removed interest example for your arguments - think about what it means to have less months present from a segment perspective.
-- After removing these interests - how many unique interests are there for each month?
		
        -- Segment Analysis
-- Using our filtered dataset by removing the interests with less than 6 months worth of data, which are the top 10 and bottom 10 interests which have the largest composition values in any month_year? Only use the maximum composition value for each interest but you must keep the corresponding month_year
-- Which 5 interests had the lowest average ranking value?
-- Which 5 interests had the largest standard deviation in their percentile_ranking value?
-- For the 5 interests found in the previous question - what was minimum and maximum percentile_ranking values for each interest and its corresponding year_month value? Can you describe what is happening for these 5 interests?
-- How would you describe our customers in this segment based off their composition and ranking values? What sort of products or services should we show to these customers and what should we avoid?
		
        -- Index Analysis
-- The index_value is a measure which can be used to reverse calculate the average composition for Fresh Segments’ clients.
-- Average composition can be calculated by dividing the composition column by the index_value column rounded to 2 decimal places.
-- What is the top 10 interests by the average composition for each month?
-- For all of these top 10 interests - which interest appears the most often?
-- What is the average of the average composition for the top 10 interests for each month?
-- What is the 3 month rolling average of the max average composition value from September 2018 to August 2019 and include the previous top ranking interests in the same output shown below.
-- Provide a possible reason why the max average composition might change from month to month? Could it signal something is not quite right with the overall business model for Fresh Segments?
