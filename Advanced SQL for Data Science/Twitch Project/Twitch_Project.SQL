--Start by getting a feel for the stream table and the chat table.
--Select the first 20 rows from each of the two tables.
SELECT * from stream LIMIT 20;

--SELECT * FROM chat LIMIT 20;

--What are the unique games in the stream table?
SELECT DISTINCT game from stream;

--What are the unique channels in the stream table?
SELECT DISTINCT channel from stream;

--What are the most popular games in the stream table?
SELECT game, count(*) from stream
GROUP BY 1
ORDER BY 2 DESC;

--Where are these League of Legends(LoL) stream viewers located?
SELECT country, count(*) from stream
WHERE game = 'League of Legends'
GROUP BY 1
ORDER BY 2 DESC;
--Create a list of players and their number of streamers
SELECT player, count(*) from stream
GROUP BY 1
ORDER BY 2 DESC;

/*Create a new column named genre for each of the games.

Group the games into their genres: Multiplayer Online Battle Arena (MOBA), First Person Shooter (FPS), Survival, and Other.

Using CASE, your logic should be:

If League of Legends → MOBA
If Dota 2 → MOBA
If Heroes of the Storm → MOBA
If Counter-Strike: Global Offensive → FPS
If DayZ → Survival
If ARK: Survival Evolved → Survival
Else → Other*/

SELECT game, 
  CASE WHEN game in ('League of Legends','Dota 2','Heroes of the Storm') THEN 'MOBA'
  WHEN game = 'Counter-Strike: Global Offensive' THEN 'FPS'
  WHEN game in ('DayZ', 'ARK: Survival Evolved') THEN 'Survival'
  ELSE 'Other' END AS genre, COUNT(*)
  from stream
  GROUP BY 1
  ORDER BY 3 DESC;

/*Let’s write a query that returns two columns:

-The hours of the time column
-The view count for each hour
Lastly, filter the result with only the users in your country using a WHERE clause.*/
SELECT 
   strftime('%H', time) as hour, 
   count(*) as count_of_streamers
FROM stream
WHERE country = 'US'
GROUP BY 1
ORDER BY 1;

--How many streamers used chat that are also subscribers
SELECT s.game, count(*)  FROM stream s
LEFT JOIN chat c on s.device_id = c.device_id
WHERE c.device_id is not null
AND s.subscriber = 'True'
GROUP BY 1
ORDER BY 2 DESC;



