create database Zomato;
use Zomato;
create table Zomato2(
Restaurant_ID INT,	
Restaurant_Name	VARCHAR(255),
Country_Code INT,
City TEXT,
Address	VARCHAR(500) ,
Cuisines VARCHAR (500),	
Average_Cost_for_two INT,	
Currency VARCHAR(50),	
Has_Table_booking TEXT,	
Has_Online_delivery TEXT,		
Aggregate_rating DECIMAL(3,1),		
Rating_text TEXT,
Votes INT
);
DROP TABLE IF EXISTS zomato;
DROP TABLE IF EXISTS zomato;

CREATE TABLE zomato (
    Restaurant_ID INT,
    Restaurant_Name VARCHAR(255),
    Country_Code INT,
    City VARCHAR(100),
    Address VARCHAR(500),
    Locality VARCHAR(255),
    Locality_Verbose VARCHAR(500),
    Longitude DECIMAL(10,6),
    Latitude DECIMAL(10,6),
    Cuisines VARCHAR(500),
    Average_Cost_for_two INT,
    Currency VARCHAR(100),
    Has_Table_booking VARCHAR(10),
    Has_Online_delivery VARCHAR(10),
    Is_delivering_now VARCHAR(10),
    Switch_to_order_menu VARCHAR(10),
    Price_range INT,
    Aggregate_rating DECIMAL(3,1),
    Rating_color VARCHAR(30),
    Rating_text VARCHAR(50),
    Votes INT
);
LOAD DATA LOCAL INFILE "D:/IIM SKILLS PROJECTS/zomato SQL(Zomato Restuarant Deep Dive)/zomato utf-8.csv"
INTO TABLE zomato
CHARACTER SET latin1
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\r\n'
IGNORE 1 ROWS;

select count(*) from zomato;
SET GLOBAL LOCAL_INFILE = ON;
select * from zomato;
SHOW WARNINGS;
SHOW VARIABLES LIKE 'LOCAL_INFILE';

-- Focus on India only (Country_Code = 1)
-- Check rating distribution

SELECT Rating_text, COUNT(*) AS count
FROM zomato2
WHERE Country_Code = 1
GROUP BY Rating_text
ORDER BY count DESC ;

-- Q1: Which cities in India have the most restaurants?
SELECT City,count(*) as Restaurant_count from zomato
where Country_Code =1
GROUP BY City
ORDER BY Restaurant_count DESC
limit 10;

-- Q2: Most popular cuisines in India

SELECT Cuisines,
       COUNT(*) AS count,
       ROUND(AVG(Aggregate_rating), 2) AS avg_rating
FROM zomato
WHERE Country_Code = 1
  AND Cuisines IS NOT NULL
GROUP BY Cuisines
ORDER BY count DESC
LIMIT 15;

-- Q3: Online delivery adoption by city
SELECT City,
       COUNT(*) AS total,
       SUM(CASE WHEN Has_Online_delivery = 'Yes' THEN 1 ELSE 0 END) AS with_delivery,
       ROUND(100.0 * SUM(CASE WHEN Has_Online_delivery = 'Yes' THEN 1 ELSE 0 END) / COUNT(*), 1) AS delivery_pct
FROM zomato
WHERE Country_Code = 1
GROUP BY City
HAVING COUNT(*) > 50
ORDER BY delivery_pct DESC
LIMIT 10;

-- Q4: Does table booking affect ratings?
SELECT Has_Table_booking,
       COUNT(*) AS restaurants,
       ROUND(AVG(Aggregate_rating), 2) AS avg_rating,
       ROUND(AVG(Votes), 0) AS avg_votes
FROM zomato
WHERE Country_Code = 1
  AND Aggregate_rating > 0
GROUP BY Has_Table_booking;

-- Q5: Price range vs average rating
SELECT
  CASE
    WHEN Average_Cost_for_two < 300 THEN 'Budget (under 300)'
    WHEN Average_Cost_for_two BETWEEN 300 AND 700 THEN 'Mid (300-700)'
    WHEN Average_Cost_for_two BETWEEN 700 AND 1500 THEN 'Premium (700-1500)'
    ELSE 'Fine Dining (1500+)'
  END AS price_category,
  COUNT(*) AS restaurant_count,
  ROUND(AVG(Aggregate_rating), 2) AS avg_rating,
  ROUND(AVG(Votes), 0) AS avg_votes
FROM zomato
WHERE Country_Code = 1
  AND Aggregate_rating > 0
GROUP BY price_category
ORDER BY avg_rating DESC;

-- Q6: Best value restaurants — high rating, low cost, high votes
SELECT Restaurant_Name, City, Cuisines,
       Average_Cost_for_two, Aggregate_rating, Votes
FROM zomato
WHERE Country_Code = 1
  AND Aggregate_rating >= 4.0
  AND Average_Cost_for_two <= 500
  AND Votes >= 200
ORDER BY Aggregate_rating DESC, Votes DESC
LIMIT 20;

-- Q7: Which city has the most Excellent rated restaurants?
SELECT City,
       COUNT(*) AS excellent_restaurants
FROM zomato
WHERE Country_Code = 1
  AND Rating_text = 'Excellent'
GROUP BY City
ORDER BY excellent_restaurants DESC
LIMIT 10;

-- Q8: Correlation — do more votes mean higher rating?
SELECT
  CASE
    WHEN Votes < 100 THEN 'Low votes (under 100)'
    WHEN Votes BETWEEN 100 AND 500 THEN 'Medium (100-500)'
    WHEN Votes BETWEEN 500 AND 2000 THEN 'High (500-2000)'
    ELSE 'Very High (2000+)'
  END AS vote_category,
  COUNT(*) AS restaurants,
  ROUND(AVG(Aggregate_rating), 1) AS avg_rating
FROM zomato
WHERE Country_Code = 1
  AND Aggregate_rating > 0
GROUP BY vote_category
ORDER BY avg_rating DESC;