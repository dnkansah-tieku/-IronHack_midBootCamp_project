######################## SQL SOLUTIONS - GROUP 6 ########################

create database house_price_regression;
use house_price_regression;

CREATE TABLE house_price_data (
  `id` varchar(24) NOT NULL,
  `date` int DEFAULT NULL,
  `bedrooms` int(4) DEFAULT NULL,
  `bathrooms` float DEFAULT NULL,
  `sqft_living` float DEFAULT NULL,
  `sqft_lot` float DEFAULT NULL,
  `floors` int(4) DEFAULT NULL,
  `waterfront` int(4) DEFAULT NULL,
  `view` int(4) DEFAULT NULL,
  `condition` int(4) DEFAULT NULL,
  `grade` int(4) DEFAULT NULL,
  `sqft_above` float DEFAULT NULL,
  `sqft_basement` float DEFAULT NULL,
  `yr_built` int(11) DEFAULT NULL,
  `yr_renovated` int(11) DEFAULT NULL,
  `zip_code` int(11) DEFAULT NULL,
  `lat` float DEFAULT NULL,
  `lon` float DEFAULT NULL,
  `sqft_living15` float DEFAULT NULL,
  `sqft_lot15` float DEFAULT NULL,
  `price` float DEFAULT NULL
  -- CONSTRAINT PRIMARY KEY (`id`)  -- constraint keyword is optional but its a good practice 
);


SHOW VARIABLES LIKE 'local_infile';
SET GLOBAL local_infile = 1;
load data local infile '/Users/Dennis Nkansah//Desktop/BootCamp/Labs/Unit_5/New_files/regression_data.csv'
into table house_price_data
fields terminated BY ',';


-- 4. Select all the data from table house_price_data to check if the data was imported correctly

SELECT 
    *
FROM
    house_price_data;


-- 5. Use the alter table command to drop the column date from the database, as we would not use it in the analysis with SQL. Select all the data from the table to verify if the command worked. 
-- Limit your returned results to 10.

alter table house_price_data
drop column `date`;


-- 6. Use sql query to find how many rows of data you have.

SELECT COUNT(*) as 'Number of Records' FROM house_price_data;


/*
7. Now we will try to find the unique values in some of the categorical columns:
        1. What are the unique values in the column bedrooms?
        2. What are the unique values in the column bathrooms?
        3. What are the unique values in the column floors?
        4. What are the unique values in the column condition?
        5. What are the unique values in the column grade?
*/
-- 7.1
SELECT DISTINCT
    bedrooms
FROM
    house_price_data;

-- 7.2 
SELECT DISTINCT
    bathrooms
FROM
    house_price_data;

-- 7.3
SELECT DISTINCT
    floors
FROM
    house_price_data;

-- 7.4
SELECT DISTINCT
    house_price_data.condition
FROM
    house_price_data;

-- 7.5
SELECT DISTINCT
    grade
FROM
    house_price_data;


-- 8. Arrange the data in a decreasing order by the price of the house. Return only the IDs of the top 10 most expensive houses in your data.

SELECT 
    id
FROM
    house_price_data
ORDER BY price DESC
LIMIT 10;


-- 9. What is the average price of all the properties in your data?
SELECT 
    ROUND(AVG(price), 2) AS 'AveragePrice'
FROM
    house_price_data;


/*10. In this exercise we will use simple group by to check the properties of some of the categorical variables in our data
10.1 What is the average price of the houses grouped by bedrooms? The returned result should have only two columns, bedrooms and Average of the prices. Use an alias to change the name of the second column.
10.2 What is the average sqft_living of the houses grouped by bedrooms? The returned result should have only two columns, bedrooms and Average of the sqft_living. Use an alias to change the name of the second column
10.3 What is the average price of the houses with a waterfront and without a waterfront? The returned result should have only two columns, waterfront and Average of the prices. Use an alias to change the name of the
second column.
        
10.4
Is there any correlation between the columns condition and grade? 
You can analyse this by grouping the data by one of the variables and then aggregating the results of the other column. 
Visually check if there is a positive correlation or negative correlation or no correlation between the variables.
*/
 -- 10.1
SELECT 
    bedrooms as Bedrooms, ROUND(AVG(price), 2) AS Average_Price
FROM
    house_price_data
GROUP BY bedrooms;

-- 10.2
SELECT bedrooms as Bedrooms, round(AVG(sqft_living15),2) as Average_sqft_living FROM house_price_data
GROUP BY bedrooms;

-- 10.3

SELECT DISTINCT
    waterfront AS Waterfront,
    ROUND(AVG(price), 3) AS Average_Price
FROM
    house_price_data
GROUP BY waterfront;

-- 10.4
SELECT 
    house_price_data.condition AS 'Condition', grade AS Grade
FROM
    house_price_data
GROUP BY house_price_data.condition
ORDER BY house_price_data.condition DESC;


-- 11. One of the customers is only interested in the following houses: 		
	-- 	○ Number of bedrooms either 3 or 4
	-- 	○ Bathrooms more than 3
	-- 	○ One Floor
	-- 	○ No waterfront
	-- 	○ Condition should be 3 at least
	-- 	○ Grade should be 5 at least
	-- 	○ Price less than 300000
 -- For the rest of the things, they are not too concerned. Write a simple query to find what are the options available for them?
        
SELECT 
    *
FROM
    house_price_data
WHERE
    (bedrooms = 3 OR bedrooms = 4)
        AND (bathrooms > 3 AND floors = 1
        AND waterfront = 0
        AND house_price_data.condition >= 3
        AND grade >= 5)
        AND price < 600000;
        

-- 12. Your manager wants to find out the list of properties whose prices are twice more than the average of all the properties in the database. 
-- 		Write a query to show them the list of such properties. You might need to use a sub query for this problem.

select * 
from house_price_data
where price > 
(
select avg(price) * 2 from house_price_data
);


-- 13. Since this is something that the senior management is regularly interested in, create a view of the same query.

CREATE OR REPLACE VIEW twice_more_than_the_average AS
    SELECT 
        *
    FROM
        house_price_data
    WHERE
        price > (SELECT 
                AVG(price) * 2
            FROM
                house_price_data);

select * from house_price_twice_average;


-- 14. Most customers are interested in properties with three or four bedrooms.
-- What is the difference in average prices of the properties with three and four bedrooms?

select round(max(avg_price) - min(avg_price),2) as 'Differnce in Avg. Price'
from
(
select  bedrooms, round(avg(price),2) as avg_price 
from house_price_data
where bedrooms = 3 or bedrooms = 4
group by bedrooms
)sub;   


-- 15. What are the different locations where properties are available in your database? (distinct zip codes)

SELECT 
    DISTINCT `zip_code`
FROM
    house_price_data;  

    
-- 16. Show the list of all the properties that were renovated

SELECT 
    *
FROM
    house_price_data
WHERE
    yr_renovated != 0;   
    
-- 17. Provide the details of the property that is the 11th most expensive property in your database.
    
with rank_price AS
(
SELECT *, rank() over (ORDER BY price DESC) as 'Rank'
from house_price_data
)
SELECT * FROM rank_price
LIMIT 10,1;


-- Side note: comparing sqrt_living and sqrt_lot with sqrt_living15 and sqrt_lot15 and differences in size, 
-- it could be the case that a lot of the houses were extended in a way without being reported as renovated. 
-- But realistically this is renovation if the space is different

SELECT 
    id, sqft_living, sqft_living15
FROM
    house_price_data
WHERE
    NOT sqft_living = sqft_living15
ORDER BY id ASC;


                 


