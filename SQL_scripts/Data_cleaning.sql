/*
CLEANING DATA
Goal: Preprocess and clean the data so it is ready for further exploration.
*/

/*
----------
STEP 1
Handling NULL values
*/


SELECT
  COUNT(*) AS total_rows,
   ROUND(COUNT(country)/COUNT(*)*100,2) AS country_non_null_percentage,
   ROUND(COUNT(country_code)/COUNT(*)*100,2) AS country_code_non_null_percentage
FROM country;

--Country table does not contain any NULLs


SELECT
  COUNT(*) AS total_rows,
   ROUND(COUNT(country_code)/COUNT(*)*100,2) AS country_code_non_null_percentage,
   ROUND(COUNT(year)/COUNT(*)*100,2) AS year_non_null_percentage,
   ROUND(COUNT(tourism_receipts)/COUNT(*)*100,2) AS receipts_non_null_percentage,
   ROUND(COUNT(tourism_arrivals)/COUNT(*)*100,2) AS arrivals_non_null_percentage,
   ROUND(COUNT(tourism_exports)/COUNT(*)*100,2) AS exports_non_null_percentage,
   ROUND(COUNT(tourism_departures)/COUNT(*)*100,2) AS departures_non_null_percentage,
   ROUND(COUNT(tourism_expenditures)/COUNT(*)*100,2) AS expenditures_non_null_percentage
FROM tourism;

SELECT
  country.country,
   ROUND(COUNT(t.country_code)/COUNT(*)*100,2) AS country_code_non_null_percentage,
   ROUND(COUNT(t.year)/COUNT(*)*100,2) AS year_non_null_percentage,
   ROUND(COUNT(t.tourism_receipts)/COUNT(*)*100,2) AS receipts_non_null_percentage,
   ROUND(COUNT(t.tourism_arrivals)/COUNT(*)*100,2) AS arrivals_non_null_percentage,
   ROUND(COUNT(t.tourism_exports)/COUNT(*)*100,2) AS exports_non_null_percentage,
   ROUND(COUNT(t.tourism_departures)/COUNT(*)*100,2) AS departures_non_null_percentage,
   ROUND(COUNT(t.tourism_expenditures)/COUNT(*)*100,2) AS expenditures_non_null_percentage
FROM tourism t JOIN country ON t.country_code=country.country_code
GROUP BY country.country
ORDER BY receipts_non_null_percentage DESC;


/*
 There is a significant number of NULL values in the dataset.
 Removing these rows would result in excessive data loss.
 Imputing with averages, medians, or surrounding values would skew the analysis — especially with such a high volume of missing values.
 While it is possible to estimate missing values based on global tourism growth trends, this would involve speculative assumptions that could distort the dataset even further.
 Therefore, the most reasonable approach is to leave NULLs as they are.
 Our analysis will mainly focus on top-performing countries, which have relatively few NULLs — so the overall impact on results will be minimal.
**/


SELECT
  COUNT(*) AS total_rows,
   ROUND(COUNT(country_code)/COUNT(*)*100,2) AS country_code_non_null_percentage,
   ROUND(COUNT(year)/COUNT(*)*100,2) AS year_non_null_percentage,
   ROUND(COUNT(gdp)/COUNT(*)*100,2) AS gdp_non_null_percentage,
   ROUND(COUNT(inflation)/COUNT(*)*100,2) AS inflation_non_null_percentage,
   ROUND(COUNT(unemployment)/COUNT(*)*100,2) AS unemployment_non_null_percentage
FROM economy;


SELECT
  country.country,
   ROUND(COUNT(e.unemployment)/COUNT(*)*100,2) AS unemployment_non_null_percentage
FROM economy e JOIN country ON e.country_code=country.country_code
GROUP BY country.country
ORDER BY unemployment_non_null_percentage DESC;

--Economy data looks much better than tourism.
--The only issue is with the unemployment rate, where nearly half the data is missing.
--However, just like in the tourism dataset, most NULLs come from countries that will not be included in the final analysis.


SELECT
  COUNT(*) AS total_rows,
   ROUND(COUNT(country_code)/COUNT(*)*100,2) AS country_code_non_null_percentage,
   ROUND(COUNT(year)/COUNT(*)*100,2) AS year_non_null_percentage,
   ROUND(COUNT(AVG_TEMPERATURE)/COUNT(*)*100,2) AS avg_temperature_non_null_percentage
FROM weather;

--Weather data comes from another source, and there are no NULLs in this dataset.



--The amount of NULL values in some columns is significant.
--However, due to the time-series structure of the data, we cannot simply delete those rows without destroying the year-by-year view per country.
--Let’s now examine how NULL values are distributed over time:


SELECT
  tourism.year, COUNT(*) AS total_rows,
   ROUND(COUNT(country_code)/COUNT(*)*100,2) AS country_code_non_null_percentage,
   ROUND(COUNT(year)/COUNT(*)*100,2) AS year_non_null_percentage,
   ROUND(COUNT(tourism_receipts)/COUNT(*)*100,2) AS receipts_non_null_percentage,
   ROUND(COUNT(tourism_arrivals)/COUNT(*)*100,2) AS arrivals_non_null_percentage,
   ROUND(COUNT(tourism_exports)/COUNT(*)*100,2) AS exports_non_null_percentage,
   ROUND(COUNT(tourism_departures)/COUNT(*)*100,2) AS departures_non_null_percentage,
   ROUND(COUNT(tourism_expenditures)/COUNT(*)*100,2) AS expenditures_non_null_percentage
FROM tourism
GROUP BY tourism.year
ORDER BY tourism.year;


/*
NULL distribution is fairly consistent across all years — except for the last 3 years.
Those years are missing key indicators like tourist arrivals, departures, etc.
This makes those years unusable for our analysis and they should be removed.
*/

DELETE FROM tourism
WHERE year > 2020 OR year < 1999;

DELETE FROM economy
WHERE year > 2020 OR year < 1999;

DELETE FROM weather
WHERE year > 2020 OR year < 1999;


/*
----------
STEP 3
Checking for duplicates.
We must ensure that each country has only one record per year.
*/

SELECT country_code, year, COUNT(*) AS occurrences
FROM tourism
GROUP BY country_code, year
HAVING COUNT(*) > 1;

SELECT country_code, year, COUNT(*) AS occurrences
FROM economy
GROUP BY country_code, year
HAVING COUNT(*) > 1;

SELECT country_code, year, COUNT(*) AS occurrences
FROM weather
GROUP BY country_code, year
HAVING COUNT(*) > 1;

--There are no duplicates in any of the datasets


/*
----------
STEP 4
Checking for inconsistencies in country names.
We will count how many rows each country has. 
If any country has fewer or more records than it should (based on year range), 
this may indicate that some of its records were assigned to a different name variant.
*/

--Tourism
SELECT
    country.country AS country_name,
    MIN(tourism.year) AS min_year,
    MAX(tourism.year) AS max_year,
    COUNT(*) AS row_count,
    (MAX(tourism.year) - MIN(tourism.year) + 1) AS expected_years
FROM tourism
JOIN country ON country.country_code = tourism.country_code
GROUP BY country.country
HAVING COUNT(*) < (MAX(tourism.year) - MIN(tourism.year) + 1) OR COUNT(*) > (MAX(tourism.year) - MIN(tourism.year) + 1)
ORDER BY row_count ASC;


--Economy
SELECT
    country.country AS country_name,
    MIN(economy.year) AS min_year,
    MAX(economy.year) AS max_year,
    COUNT(*) AS row_count,
    (MAX(economy.year) - MIN(economy.year) + 1) AS expected_years
FROM economy
JOIN country ON country.country_code = economy.country_code
GROUP BY country.country
HAVING COUNT(*) < (MAX(economy.year) - MIN(economy.year) + 1)
    OR COUNT(*) > (MAX(economy.year) - MIN(economy.year) + 1)
ORDER BY row_count ASC;


--Weather
SELECT
    country.country AS country_name,
    MIN(weather.year) AS min_year,
    MAX(weather.year) AS max_year,
    COUNT(*) AS row_count,
    (MAX(weather.year) - MIN(weather.year) + 1) AS expected_years
FROM weather
JOIN country ON country.country_code = weather.country_code
GROUP BY country.country
HAVING COUNT(*) < (MAX(weather.year) - MIN(weather.year) + 1)
    OR COUNT(*) > (MAX(weather.year) - MIN(weather.year) + 1)
ORDER BY row_count ASC;

--There are no inconsistencies in country name usage or record count.



--Now everything looks good and the dataset is ready for further analysis.
COMMIT;