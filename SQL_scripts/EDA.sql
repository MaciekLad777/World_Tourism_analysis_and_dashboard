/*
Step 0
Let's see our columns
*/

SELECT column_name
FROM user_tab_columns
WHERE table_name = 'TOURISM_DATA'
ORDER BY column_id;

/*
Step 1
We will explore country column, to this moment we know about only that it contains Strings, "propably" country names
*/


SELECT UNIQUE(COUNTRY) FROM TOURISM_DATA

/*Country column has a lot of types of countries, regions ,continents, even economic zones,
we must label all this to explore properly. It is nearly 300 records and any good automation aproach we can use.
Only good way to determine what is waht, would be labeling all this by ourselves, but who have time for that... 
Well chatgpt has! This is ain't no personal data so we can "outsorce" task like that.
*/

--We have all country records properly assigned to categories, we know what is country, what is micro or macro region, continent etc.

CREATE TABLE location_classification (
  country VARCHAR2(100),
  category VARCHAR2(50)
);


--Adding new column for our geo category and labeling records in tourism_data


ALTER TABLE tourism_data ADD geo_category VARCHAR2(50);


UPDATE tourism_data td
SET geo_category = (
  SELECT lc.category
  FROM location_classification lc
  WHERE lc.country = td.country
)
WHERE EXISTS (
  SELECT 1
  FROM location_classification lc
  WHERE lc.country = td.country
);

select * from tourism_data


/*
Step 2
Country code. It does not give us any data insights, but works as country indicator-id.
It is helpfull when it comes to combining tables, operating on country codes is much easier than on country names. We can lave it as it is.
*/

/*
Step 3
Year, axis of our analysis. 
*/
SELECT COUNT(DISTINCT year) AS Years_amount,MIN(year) AS First_year,MAX(year) AS Last_year
FROM TOURISM_DATA


/*
Step 4
Tourism_receipts. This feature shows country income from internatinoal tourism, all in USD.
*/

--Year by year countries with most tourism receipts
SELECT
    year,
    MAX(CASE WHEN rank = 1 THEN country END) AS rank1,
    MAX(CASE WHEN rank = 1 THEN tourism_receipts END) AS rank1_receipts,
    MAX(CASE WHEN rank = 2 THEN country END) AS rank2,
    MAX(CASE WHEN rank = 2 THEN tourism_receipts END) AS rank2_receipts,
    MAX(CASE WHEN rank = 3 THEN country END) AS rank3,
    MAX(CASE WHEN rank = 3 THEN tourism_receipts END) AS rank3_receipts,
    MAX(CASE WHEN rank = 4 THEN country END) AS rank4,
    MAX(CASE WHEN rank = 4 THEN tourism_receipts END) AS rank4_receipts,
    MAX(CASE WHEN rank = 5 THEN country END) AS rank5,
    MAX(CASE WHEN rank = 5 THEN tourism_receipts END) AS rank5_receipts

FROM (
    SELECT 
        year,
        country,
        tourism_receipts,
        RANK() OVER (PARTITION BY year ORDER BY tourism_receipts DESC) AS rank
    FROM tourism_data
    WHERE 
        tourism_receipts IS NOT NULL
        AND geo_category = 'Country'
)
WHERE rank <= 5
GROUP BY year
ORDER BY year;
/*
-USA is obliterating every one, best in every year.
-Rank2 is France, but far from US
-Rank3 and 4 is migrating back and forth mostly Italy, Germany, Thailand and Australia
-Rank5, introduce some new countries, like China and Turkiye
*/

-- Now lets see performance of whole macroregions

SELECT
    year,
    MAX(CASE WHEN rank = 1 THEN country END) AS rank1,
    MAX(CASE WHEN rank = 1 THEN tourism_receipts END) AS rank1_receipts,
    MAX(CASE WHEN rank = 2 THEN country END) AS rank2,
    MAX(CASE WHEN rank = 2 THEN tourism_receipts END) AS rank2_receipts,
    MAX(CASE WHEN rank = 3 THEN country END) AS rank3,
    MAX(CASE WHEN rank = 3 THEN tourism_receipts END) AS rank3_receipts,
    MAX(CASE WHEN rank = 4 THEN country END) AS rank4,
    MAX(CASE WHEN rank = 4 THEN tourism_receipts END) AS rank4_receipts,
    MAX(CASE WHEN rank = 5 THEN country END) AS rank5,
    MAX(CASE WHEN rank = 5 THEN tourism_receipts END) AS rank5_receipts

FROM (
    SELECT 
        year,
        country,
        tourism_receipts,
        RANK() OVER (PARTITION BY year ORDER BY tourism_receipts DESC) AS rank
    FROM tourism_data
    WHERE 
        tourism_receipts IS NOT NULL
        AND geo_category = 'Macroregion'
)
WHERE rank <= 5
GROUP BY year
ORDER BY year;

/*
-Europe took whole podium, First place to European continet, second to European union, third to euro area
-Rank 4 Is North America
-Rank 5 was Latin america and Caribbeans, but in 2007 it switched to middle east and north africa
*/



/*
Step 5
Tourism_arrivals. This feature shows amount of tourists.Distribution is propably similar to the previous one.
*/

SELECT
    year,
    MAX(CASE WHEN rank = 1 THEN country END) AS rank1,
    MAX(CASE WHEN rank = 1 THEN tourism_arrivals END) AS rank1_arrivals,
    MAX(CASE WHEN rank = 2 THEN country END) AS rank2,
    MAX(CASE WHEN rank = 2 THEN tourism_arrivals END) AS rank2_arrivals,
    MAX(CASE WHEN rank = 3 THEN country END) AS rank3,
    MAX(CASE WHEN rank = 3 THEN tourism_arrivals END) AS rank3_arrivals,
    MAX(CASE WHEN rank = 4 THEN country END) AS rank4,
    MAX(CASE WHEN rank = 4 THEN tourism_arrivals END) AS rank4_arrivals,
    MAX(CASE WHEN rank = 5 THEN country END) AS rank5,
    MAX(CASE WHEN rank = 5 THEN tourism_arrivals END) AS rank5_arrivals

FROM (
    SELECT 
        year,
        country,
        tourism_arrivals,
        RANK() OVER (PARTITION BY year ORDER BY tourism_arrivals DESC) AS rank
    FROM tourism_data
    WHERE 
        tourism_arrivals IS NOT NULL AND
         geo_category = 'Country'
)
WHERE rank <= 5
GROUP BY year
ORDER BY year;

/*
Couple of first years are propably biased becuase of some null data, but later all looks legit
France have the most tourists, it switched places with USA.
Rank 3 belongs to China. 
Rank 4 and 5 are most intresting, Spain and Mexico came out, both despite not apearing in top5 tourism income table, they took alot of tourists
*/



SELECT    year,
    MAX(CASE WHEN rank = 1 THEN country END) AS rank1,
    MAX(CASE WHEN rank = 1 THEN tourism_arrivals END) AS rank1_arrivals,
    MAX(CASE WHEN rank = 2 THEN country END) AS rank2,
    MAX(CASE WHEN rank = 2 THEN tourism_arrivals END) AS rank2_arrivals,
    MAX(CASE WHEN rank = 3 THEN country END) AS rank3,
    MAX(CASE WHEN rank = 3 THEN tourism_arrivals END) AS rank3_arrivals,
    MAX(CASE WHEN rank = 4 THEN country END) AS rank4,
    MAX(CASE WHEN rank = 4 THEN tourism_arrivals END) AS rank4_arrivals,
    MAX(CASE WHEN rank = 5 THEN country END) AS rank5,
    MAX(CASE WHEN rank = 5 THEN tourism_arrivals END) AS rank5_arrivals

FROM (
    SELECT 
        year,
        country,
        tourism_arrivals,
        RANK() OVER (PARTITION BY year ORDER BY tourism_arrivals DESC) AS rank
    FROM tourism_data
    WHERE 
        tourism_arrivals IS NOT NULL AND
         geo_category = 'Macroregion'
)
WHERE rank <= 5
GROUP BY year
ORDER BY year;


/*
Here situation is similar to the income table, but North America is not even there, we have East Asia and Pacific instead
*/


/*
Step 6
Tourism_Exports. Amount of people that are tourists and goes to another countries.
*/

