/*
CLEANING DATA
Goal: Preprocess and clean data, so it is ready to further exploration

*/

/*
----------
STEP 1
Checking proper column data types
*/

SELECT 
  column_name,
  data_type,
  data_length,
  data_precision,
  data_scale
FROM all_tab_columns
WHERE table_name = 'TOURISM_DATA'


SELECT * FROM TOURISM_DATA

/*
Everything looks good
*/




/*
----------
STEP 2
Handling NULL values
*/


SELECT
  COUNT(*) AS total_rows,
   ROUND(COUNT(country)/COUNT(*)*100,2) AS country_non_null_percentage,
   ROUND(COUNT(tourism_receipts)/COUNT(*)*100,2) AS receipts_non_null_percentage,
   ROUND(COUNT(tourism_arrivals)/COUNT(*)*100,2) AS arrivals_non_null_percentage,
   ROUND(COUNT(tourism_exports)/COUNT(*)*100,2) AS exports_non_null_percentage,
   ROUND(COUNT(gdp)/COUNT(*)*100,2) AS gdp_non_null_percentage,
   ROUND(COUNT(inflation)/COUNT(*)*100,2) AS inflation_non_null_percentage,
  ROUND(COUNT(unemployment)/COUNT(*)*100,2) AS unemployment_non_null_percentage,
  ROUND(COUNT(AVG_TEMPERATURE)/COUNT(*)*100,2) AS avg_temperature_non_null_percentage
FROM tourism_data;


--Amount of NULL values in columns is huge, but becuase of data characteristics we can not delete this rows jsut like that, it would destroy , year-by-year view on every country
--Let's check how null values distributes throughout the table
SELECT
    t.year,
    ROUND(100 * COUNT(CASE WHEN t.tourism_receipts IS NULL THEN 1 END) / COUNT(*), 2) AS null_tourism_receipts,
    ROUND(100 * COUNT(CASE WHEN t.tourism_arrivals IS NULL THEN 1 END) / COUNT(*), 2) AS null_tourism_arrivals,
    ROUND(100 * COUNT(CASE WHEN t.tourism_exports IS NULL THEN 1 END) / COUNT(*), 2) AS null_tourism_exports,
    ROUND(100 * COUNT(CASE WHEN t.tourism_departures IS NULL THEN 1 END) / COUNT(*), 2) AS null_tourism_departures,
    ROUND(100 * COUNT(CASE WHEN t.tourism_expenditures IS NULL THEN 1 END) / COUNT(*), 2) AS null_tourism_expenditures,
    ROUND(100 * COUNT(CASE WHEN t.gdp IS NULL THEN 1 END) / COUNT(*), 2) AS null_gdp,
    ROUND(100 * COUNT(CASE WHEN t.inflation IS NULL THEN 1 END) / COUNT(*), 2) AS null_inflation,
    ROUND(100 * COUNT(CASE WHEN t.unemployment IS NULL THEN 1 END) / COUNT(*), 2) AS null_unemployment,
    ROUND(100 * COUNT(CASE WHEN t.avg_temperature IS NULL THEN 1 END) / COUNT(*), 2) AS null_avg_temperature
FROM tourism_data t
GROUP BY t.year
ORDER BY t.year;

/*
All years have similar NULLs distribution, instead of last 3 years.
There we don't have any data about tourist arrival, departures etc.
This makes, those year, useless in our analysis. We should delete them.
*/

DELETE FROM tourism_data
WHERE year > 2020;



/*
----------
STEP 3
Checking for duplicates.
We msut be sure that every year contains data of specific country only once
*/

SELECT country, year, COUNT(*) as occurrences
FROM tourism_data
GROUP BY country, year
HAVING COUNT(*) > 1;

--There is no duplicates

/*
----------
STEP 4
Checking for inconsistency in names.
We will count how many rows every Country have. If some has less than amount of year rows it should have, we will see it
*/

SELECT country, 
       MIN(year) AS min_year,
       MAX(year) AS max_year,
       COUNT(*) AS row_count,
       (MAX(year) - MIN(year) + 1) AS expected_years
FROM tourism_data
GROUP BY country
HAVING COUNT(*) < (MAX(year) - MIN(year) + 1)
ORDER BY row_count ASC;

--There is no incosistencies

/*
----------
STEP 5
At last, we will round all numbers to second place after comma,  we don't need higher precision.
*/

UPDATE TOURISM_DATA
SET tourism_receipts = ROUND(tourism_receipts,2),
    gdp = ROUND(gdp,2),
    tourism_exports = ROUND(tourism_exports,2),
    tourism_expenditures = ROUND(tourism_expenditures,2),
    inflation = ROUND(inflation,2),
    unemployment= ROUND(unemployment,2)


--Now all looks good
COMMIT