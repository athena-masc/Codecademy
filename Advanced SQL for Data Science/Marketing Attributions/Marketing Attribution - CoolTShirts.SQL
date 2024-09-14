
--Select * from page_visits LIMIT 10;

--unique campaigns
SELECT DISTINCT utm_campaign
 from page_visits;
--unique sources
SELECT DISTINCT utm_source
 from page_visits;
--unique campaign/source combo
SELECT DISTINCT utm_campaign, utm_source
 from page_visits;
-- unique pages
SELECT DISTINCT page_name 
from page_visits;

--First touch campaigns
WITH first_touch AS (
    SELECT user_id,
        MIN(timestamp) as first_touch_at
    FROM page_visits
    GROUP BY user_id),
total_users AS (
  SELECT COUNT(DISTINCT user_id) AS total_users from page_visits),
ft_counts AS (
   SELECT pv.utm_source,
    pv.utm_campaign, 
    total_users,  
    COUNT(*) as users
FROM first_touch ft
JOIN page_visits pv
    ON ft.user_id = pv.user_id
    AND ft.first_touch_at = pv.timestamp
CROSS JOIN total_users tu
    GROUP BY 1,2
    ORDER BY 3 DESC)
  SELECT utm_source, 
  utm_campaign, 
  users, 
  ROUND(1.0 * users/total_users,2) as proportion_of_users
  FROM ft_counts
  ORDER BY 3 DESC;


--last touch campaigns
WITH last_touch AS (
    SELECT user_id,
        MAX(timestamp) as last_touch_at
    FROM page_visits
    GROUP BY user_id),
total_users AS (
  SELECT COUNT(DISTINCT user_id) AS total_users from 	page_visits),
lt_counts AS (
  SELECT 
    pv.utm_source,
    pv.utm_campaign,
    tu.total_users,
    COUNT(*) as users
FROM last_touch lt
JOIN page_visits pv
    ON lt.user_id = pv.user_id
    AND lt.last_touch_at = pv.timestamp
CROSS JOIN total_users tu
    GROUP BY 1,2
    ORDER BY 3 DESC)  
SELECT utm_source, 
  utm_campaign, 
  users, 
  ROUND(1.0 * users/total_users,2) as proportion_of_users
  FROM lt_counts
  ORDER BY 3 DESC;



--purchased users
WITH total_users AS (
  SELECT COUNT(DISTINCT user_id) AS total_users from page_visits),
purchased AS (
SELECT COUNT(DISTINCT user_id) AS users_that_purchased 
from page_visits
where page_name = '4 - purchase')
SELECT total_users, 
  users_that_purchased,
  ROUND(1.0 * users_that_purchased/total_users,2) as proportion_of_users_that_purchased
  FROM purchased p
  CROSS JOIN total_users;


--last touch campaigns for purchased users
WITH last_touch AS (
    SELECT user_id,
        MAX(timestamp) as last_touch_at
    FROM page_visits
    where page_name = '4 - purchase'
    GROUP BY user_id),
total_users AS (
  SELECT COUNT(DISTINCT user_id) AS total_users
    from 	page_visits
   where page_name = '4 - purchase'),
lt_counts AS (
  SELECT 
    pv.utm_source,
    pv.utm_campaign,
    tu.total_users,
    COUNT(*) as users
FROM last_touch lt
JOIN page_visits pv
    ON lt.user_id = pv.user_id
    AND lt.last_touch_at = pv.timestamp
CROSS JOIN total_users tu
    GROUP BY 1,2
    ORDER BY 3 DESC)  
SELECT utm_source, 
  utm_campaign, 
  users as users_purchased, 
  ROUND(1.0 * users/total_users,2) as proportion_of_users_purchased
  FROM lt_counts
  ORDER BY 3 DESC;

--Page funnel
SELECT page_name, 
  COUNT(DISTINCT user_id) as users
  FROM page_visits
  GROUP BY 1;