SELECT * FROM subscriptions LIMIT 100; 

--Number of segments: 2 segments 87 and 30
SELECT DISTINCT segment FROM subscriptions;

--Select the range of months
SELECT MIN(subscription_start) as date_min, MAX(subscription_start) as date_max 
FROM subscriptions;

--Churn Rate Code
WITH months as (
  SELECT '2017-01-01' as first_day,
  '2017-01-31' as last_day
  UNION
  SELECT '2017-02-01' as first_day,
  '2017-02-28' as last_day 
  UNION
  SELECT '2017-03-01' as first_day,
  '2017-03-31' as last_day
), 
  cross_join as (
  SELECT * from subscriptions
  CROSS JOIN months
),
status as (
  SELECT id, first_day as month, 
  CASE WHEN (
	segment == 87  AND 
  	subscription_start < first_day AND 
	(subscription_end > first_day  OR 
      	subscription_end IS NULL)
  	) THEN 1 
	ELSE 0 END AS is_active_87,
  CASE WHEN (
	segment == 30  AND 
  	subscription_start < first_day AND 
	(subscription_end > first_day  OR 
      	subscription_end IS NULL)
  	) THEN 1 
	ELSE 0 END AS is_active_30,
  CASE WHEN (
	segment == 87  AND
    	subscription_end BETWEEN first_day and last_day
  	) THEN 1 
	ELSE 0 END AS is_canceled_87,
  CASE WHEN (
	segment == 30  AND
    	subscription_end BETWEEN first_day and last_day
  	) THEN 1 
	ELSE 0 END AS is_canceled_30
  FROM cross_join),
  status_aggregate as (
    SELECT month, 
	SUM(is_active_87) as active_87,
    	SUM(is_active_30) as active_30,
    	SUM(is_canceled_87) as canceled_87,
    	SUM(is_canceled_30) as canceled_30
    FROM status
    GROUP BY 1
  )
  Select month, 
  	1.0 * canceled_87/active_87 as churn_rate_87,
  	1.0 * canceled_30/active_30 as churn_rate_30
  FROM status_aggregate;


--Alternative Code for Churn rate (no hard code of segments)
  --create temporary months table
WITH months as (
  SELECT '2017-01-01' as first_day,
  '2017-01-31' as last_day
  UNION
  SELECT '2017-02-01' as first_day,
  '2017-02-28' as last_day 
  UNION
  SELECT '2017-03-01' as first_day,
  '2017-03-31' as last_day
), 
  cross_join as (
  SELECT * from subscriptions
  CROSS JOIN months
),
status as (
  SELECT id, first_day as month, segment,
  CASE WHEN (
  	subscription_start < first_day AND 
	(subscription_end > first_day  OR 
      	subscription_end IS NULL)
  	) THEN 1 
	ELSE 0 END AS is_active,
  CASE WHEN (
    	subscription_end BETWEEN first_day and last_day
  	) THEN 1 
	ELSE 0 END AS is_canceled
  FROM cross_join
), status_aggregate AS (
  SELECT month, segment,
	    SUM(is_active) as active,
    	SUM(is_canceled) as canceled
    FROM status
    GROUP BY 1,2
  ) SELECT month, segment,
  1.0 * canceled/active as churn_rate
  FROM status_aggregate;
  