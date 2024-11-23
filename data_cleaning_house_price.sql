CREATE DATABASE housing_prices;

USE housing_prices;

CREATE TABLE houseprice_staging
LIKE house_price;

INSERT houseprice_staging
SELECT *
FROM house_price;

SELECT *
FROM houseprice_staging;

-- 1.Removing duplicate values

WITH duplicate_cte AS 
(SELECT *, 
ROW_NUMBER() OVER(
PARTITION BY
title, 
bedrooms, 
bathrooms,
floor_no, 
occupancy_status, 
floor_area, 
city, 
price_in_taka, 
location) AS row_num
FROM houseprice_staging)
SELECT *
FROM duplicate_cte
WHERE row_num > 1;

CREATE TABLE houseprice_staging2 (
  `Title` text,
  `Bedrooms` int DEFAULT NULL,
  `Bathrooms` int DEFAULT NULL,
  `Floor_no` int DEFAULT NULL,
  `Occupancy_status` text,
  `Floor_area` int DEFAULT NULL,
  `City` text,
  `Price_in_taka` text,
  `Location` text, 
  `row_num` INT
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

INSERT INTO houseprice_staging2
SELECT *, 
ROW_NUMBER() OVER(
PARTITION BY
title, 
bedrooms, 
bathrooms,
floor_no, 
occupancy_status, 
floor_area, 
city, 
price_in_taka, 
location) AS row_num
FROM houseprice_staging;

SELECT * 
FROM houseprice_staging2;

SELECT *
FROM houseprice_staging2
WHERE row_num > 1;

DELETE FROM houseprice_staging2
WHERE row_num > 1;

-- 2.Standardizing the data

SELECT price_in_taka , TRIM(LEADING 'à§³' FROM price_in_taka)
FROM houseprice_staging2;

SELECT price_in_taka 
FROM houseprice_staging2
WHERE price_in_taka NOT LIKE 'à§³%';

UPDATE houseprice_staging2
SET price_in_taka = TRIM(LEADING 'à§³' FROM price_in_taka);

SELECT price_in_taka , REPLACE(price_in_taka,',','')
FROM houseprice_staging2;

UPDATE houseprice_staging2
SET price_in_taka = REPLACE(price_in_taka,',','');

SELECT price_in_taka
FROM houseprice_staging2
WHERE price_in_taka LIKE '%.%';

ALTER TABLE houseprice_staging2
MODIFY COLUMN price_in_taka INT;

SELECT title =  TRIM(title), occupancy_status = TRIM(occupancy_status), location = TRIM(location)
FROM houseprice_staging2
WHERE (title = TRIM(title)) = 0 OR
(occupancy_status = TRIM(occupancy_status)) = 0 OR 
(location = TRIM(location)) = 0;

UPDATE houseprice_staging2
SET title = UPPER(title), 
occupancy_status = UPPER(occupancy_status), 
location = UPPER(location),
city = UPPER(city);

SELECT occupancy_status
FROM houseprice_staging2
WHERE occupancy_status NOT LIKE 'VACANT';

ALTER TABLE houseprice_staging2
ADD COLUMN price_per_sqft DOUBLE;

UPDATE houseprice_staging2
SET price_per_sqft = price_in_taka / NULLIF(floor_area,0);

UPDATE houseprice_staging2
SET price_per_sqft = ROUND(price_per_sqft,4);

-- 3.Removing unecessary columns

ALTER TABLE houseprice_staging2
DROP COLUMN `row_num`;















