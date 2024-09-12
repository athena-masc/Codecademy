--survey table
SELECT * FROM survey LIMIT 10;

--Number of responses per question in survey
 SELECT question, 
    COUNT(user_id) as response_count
    FROM survey
    GROUP BY 1
    ORDER BY 1 ASC, 2 DESC;

--Sneak peek of quiz, home_try_on and purchase tables

SELECT * FROM quiz LIMIT 5;

SELECT * FROM home_try_on LIMIT 5;

SELECT * FROM purchase LIMIT 5;


-- Created funnel for quiz>hometry>purchase
--Calculated the difference in purchase rates between customers who had 3 number_of_pairs with ones who had 5.
WITH funnel AS (
SELECT q.user_id, 
  CASE WHEN hto.number_of_pairs IS NOT NULL THEN 'True' ELSE 'False' END as is_home_try_on,
  hto.number_of_pairs,
  CASE WHEN p.product_id IS NOT NULL THEN 'True' ELSE 'False' END as is_purchase  
  FROM quiz q
  LEFT JOIN home_try_on hto on q.user_id = hto.user_id
  LEFT JOIN purchase p on hto.user_id = p.user_id)

  SELECT COUNT(*) as total_num_quiz, 
  SUM(is_home_try_on == 'True') as total_num_home_try_on,
  SUM(number_of_pairs == '3 pairs' and is_home_try_on == 'True') as num_tryon_3pair,
  SUM(number_of_pairs == '5 pairs' and is_home_try_on == 'True') as num_tryon_5pair,
  SUM(is_purchase == 'True') as total_num_purchase,
  SUM(number_of_pairs == '3 pairs' and is_purchase == 'True') as num_purchase_3pair,
  SUM(number_of_pairs == '5 pairs' and is_purchase == 'True') as num_purchase_5pair
  FROM funnel;

--Calculated the most common purchases results for each style

SELECT RANK() OVER (
	PARTITION BY style 
	ORDER BY purchase_num DESC) as rank, 
style, model_name, color, price, purchase_num 
from  (
SELECT style, model_name, color, price, 
	COUNT(user_ID) as purchase_num 
FROM purchase 
GROUP BY 1,2,3
ORDER by 4 DESC);
