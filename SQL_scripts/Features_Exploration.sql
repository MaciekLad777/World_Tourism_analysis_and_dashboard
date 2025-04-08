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

select * from Location_classification

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
COMMIT

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
Tourism_export. The percentage of a country’s total exports derived from international tourism receipts. 
*/


SELECT
    year,
    MAX(CASE WHEN rank = 1 THEN country END) AS rank1,
    MAX(CASE WHEN rank = 1 THEN tourism_exports END) AS rank1_exports,
    MAX(CASE WHEN rank = 2 THEN country END) AS rank2,
    MAX(CASE WHEN rank = 2 THEN tourism_exports END) AS rank2_exports,
    MAX(CASE WHEN rank = 3 THEN country END) AS rank3,
    MAX(CASE WHEN rank = 3 THEN tourism_exports END) AS rank3_exports,
    MAX(CASE WHEN rank = 4 THEN country END) AS rank4,
    MAX(CASE WHEN rank = 4 THEN tourism_exports END) AS rank4_exports,
    MAX(CASE WHEN rank = 5 THEN country END) AS rank5,
    MAX(CASE WHEN rank = 5 THEN tourism_exports END) AS rank5_exports

FROM (
    SELECT 
        year,
        country,
        tourism_exports,
        RANK() OVER (PARTITION BY year ORDER BY tourism_exports DESC) AS rank
    FROM tourism_data
    WHERE 
        tourism_exports IS NOT NULL
        AND geo_category = 'Country'
)
WHERE rank <= 5
GROUP BY year
ORDER BY year;


/*
This basically shows us which countries live from tourism, it is thiers main source of income.
Most of top countries here are small "paradsie" islands, which don't produce anything significant.
Only thing they can offer, are beautifull sunny beaches and views.
*/



SELECT
    year,
    MAX(CASE WHEN rank = 1 THEN country END) AS rank1,
    MAX(CASE WHEN rank = 1 THEN tourism_exports END) AS rank1_exports,
    MAX(CASE WHEN rank = 2 THEN country END) AS rank2,
    MAX(CASE WHEN rank = 2 THEN tourism_exports END) AS rank2_exports,
    MAX(CASE WHEN rank = 3 THEN country END) AS rank3,
    MAX(CASE WHEN rank = 3 THEN tourism_exports END) AS rank3_exports,
    MAX(CASE WHEN rank = 4 THEN country END) AS rank4,
    MAX(CASE WHEN rank = 4 THEN tourism_exports END) AS rank4_exports,
    MAX(CASE WHEN rank = 5 THEN country END) AS rank5,
    MAX(CASE WHEN rank = 5 THEN tourism_exports END) AS rank5_exports

FROM (
    SELECT 
        year,
        country,
        tourism_exports,
        RANK() OVER (PARTITION BY year ORDER BY tourism_exports DESC) AS rank
    FROM tourism_data
    WHERE 
        tourism_exports IS NOT NULL
        AND geo_category = 'Macroregion'
)
WHERE rank <= 5
GROUP BY year
ORDER BY year;

/*
Region analysis shows this good.
All top ranks are for sunny islands regions, like Caribbeans and pacific islands
In Rank 4 and 5 we can also see some middle east and africa
*/


/*
Step 6
Tourism_expenditures. The percentage of a country’s total imports spent on international tourism.
--!!There is no info about countries import in dolars, so we can't precisly calculate country profits from tourism. We can only compare percentages !!
*/

SELECT
    year,
    MAX(CASE WHEN rank = 1 THEN country END) AS rank1,
    MAX(CASE WHEN rank = 1 THEN tourism_expenditures END) AS rank1_expenditures,
    MAX(CASE WHEN rank = 2 THEN country END) AS rank2,
    MAX(CASE WHEN rank = 2 THEN tourism_expenditures END) AS rank2_expenditures,
    MAX(CASE WHEN rank = 3 THEN country END) AS rank3,
    MAX(CASE WHEN rank = 3 THEN tourism_expenditures END) AS rank3_expenditures,
    MAX(CASE WHEN rank = 4 THEN country END) AS rank4,
    MAX(CASE WHEN rank = 4 THEN tourism_expenditures END) AS rank4_expenditures,
    MAX(CASE WHEN rank = 5 THEN country END) AS rank5,
    MAX(CASE WHEN rank = 5 THEN tourism_expenditures END) AS rank5_expenditures

FROM (
    SELECT 
        year,
        country,
        tourism_expenditures,
        RANK() OVER (PARTITION BY year ORDER BY tourism_expenditures DESC) AS rank
    FROM tourism_data
    WHERE 
        tourism_expenditures IS NOT NULL
        AND geo_category = 'Country'
)
WHERE rank <= 5
GROUP BY year
ORDER BY year;

/*
Expanditures has a lot of common with export, a lot of spots are taken by small paradise islands,
but it is definitely not one to one.
Top expenditurers are countries, that do not have paradise climate, that pulls tourists from the whoel world,
these are more niche, inland countries that try to build tourism sector despite lack of natural aids.
Kuwait and Qatar , which on their own, are just chunks of desert, or Albania, which is hardly devastated becasue of region instability.
*/




SELECT
    year,
    MAX(CASE WHEN rank = 1 THEN country END) AS rank1,
    MAX(CASE WHEN rank = 1 THEN tourism_expenditures END) AS rank1_expenditures,
    MAX(CASE WHEN rank = 2 THEN country END) AS rank2,
    MAX(CASE WHEN rank = 2 THEN tourism_expenditures END) AS rank2_expenditures,
    MAX(CASE WHEN rank = 3 THEN country END) AS rank3,
    MAX(CASE WHEN rank = 3 THEN tourism_expenditures END) AS rank3_expenditures,
    MAX(CASE WHEN rank = 4 THEN country END) AS rank4,
    MAX(CASE WHEN rank = 4 THEN tourism_expenditures END) AS rank4_expenditures,
    MAX(CASE WHEN rank = 5 THEN country END) AS rank5,
    MAX(CASE WHEN rank = 5 THEN tourism_expenditures END) AS rank5_expenditures

FROM (
    SELECT 
        year,
        country,
        tourism_expenditures,
        RANK() OVER (PARTITION BY year ORDER BY tourism_expenditures DESC) AS rank
    FROM tourism_data
    WHERE 
        tourism_expenditures IS NOT NULL
        AND geo_category = 'Macroregion'
)
WHERE rank <= 5
GROUP BY year
ORDER BY year;

/*
In region Comparision, top spenders are middle east, and poor african countries, carribean and pacific spends much less.
*/


/*
Step 7
Tourism_arrivals. This feature shows amount of tourists that come to the country.
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
France have the most tourists.
Rank 3 belongs to China. 
Rank 4 and 5 are most intresting, Spain and Mexico came out, both despite not apearing in top5 tourism income or expenditure table, they took alot of tourists
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
Here situation is similar to the income table,Europe as a region pulls masive amount of tourists.
While USA have a lot of tourists, North America as a whole, is not even there, we have East Asia and Pacific instead
*/


/*
Step 8
Tourism_departures.  The number of citizens or residents of a country who travel abroad for tourism.
*/


SELECT
    year,
    MAX(CASE WHEN rank = 1 THEN country END) AS rank1,
    MAX(CASE WHEN rank = 1 THEN tourism_departures END) AS rank1_departures,
    MAX(CASE WHEN rank = 2 THEN country END) AS rank2,
    MAX(CASE WHEN rank = 2 THEN tourism_departures END) AS rank2_departures,
    MAX(CASE WHEN rank = 3 THEN country END) AS rank3,
    MAX(CASE WHEN rank = 3 THEN tourism_departures END) AS rank3_departures,
    MAX(CASE WHEN rank = 4 THEN country END) AS rank4,
    MAX(CASE WHEN rank = 4 THEN tourism_departures END) AS rank4_departures,
    MAX(CASE WHEN rank = 5 THEN country END) AS rank5,
    MAX(CASE WHEN rank = 5 THEN tourism_departures END) AS rank5_departures

FROM (
    SELECT 
        year,
        country,
        tourism_departures,
        RANK() OVER (PARTITION BY year ORDER BY tourism_departures DESC) AS rank
    FROM tourism_data
    WHERE 
        tourism_departures IS NOT NULL
        AND geo_category = 'Country'
)
WHERE rank <= 5
GROUP BY year
ORDER BY year;

/*
Most of tourists come from developed countries, like USA, Germany, China, UK.
*/



SELECT
    year,
    MAX(CASE WHEN rank = 1 THEN country END) AS rank1,
    MAX(CASE WHEN rank = 1 THEN tourism_departures END) AS rank1_departures,
    MAX(CASE WHEN rank = 2 THEN country END) AS rank2,
    MAX(CASE WHEN rank = 2 THEN tourism_departures END) AS rank2_departures,
    MAX(CASE WHEN rank = 3 THEN country END) AS rank3,
    MAX(CASE WHEN rank = 3 THEN tourism_departures END) AS rank3_departures,
    MAX(CASE WHEN rank = 4 THEN country END) AS rank4,
    MAX(CASE WHEN rank = 4 THEN tourism_departures END) AS rank4_departures,
    MAX(CASE WHEN rank = 5 THEN country END) AS rank5,
    MAX(CASE WHEN rank = 5 THEN tourism_departures END) AS rank5_departures

FROM (
    SELECT 
        year,
        country,
        tourism_departures,
        RANK() OVER (PARTITION BY year ORDER BY tourism_departures DESC) AS rank
    FROM tourism_data
    WHERE 
        tourism_departures IS NOT NULL
        AND geo_category = 'Macroregion'
)
WHERE rank <= 5
GROUP BY year
ORDER BY year;

/*
No suprise that Europe took whole podium here.
Then we have Asia and pacific, North America
*/



/*
Step 9
Now we will check some more economic data. GDP.
*/

SELECT
    year,
    MAX(CASE WHEN rank = 1 THEN country END) AS rank1,
    MAX(CASE WHEN rank = 1 THEN gdp END) AS rank1_gdp,
    MAX(CASE WHEN rank = 2 THEN country END) AS rank2,
    MAX(CASE WHEN rank = 2 THEN gdp END) AS rank2_gdp,
    MAX(CASE WHEN rank = 3 THEN country END) AS rank3,
    MAX(CASE WHEN rank = 3 THEN gdp END) AS rank3_gdp,
    MAX(CASE WHEN rank = 4 THEN country END) AS rank4,
    MAX(CASE WHEN rank = 4 THEN gdp END) AS rank4_gdp,
    MAX(CASE WHEN rank = 5 THEN country END) AS rank5,
    MAX(CASE WHEN rank = 5 THEN gdp END) AS rank5_gdp

FROM (
    SELECT 
        year,
        country,
        gdp,
        RANK() OVER (PARTITION BY year ORDER BY gdp DESC) AS rank
    FROM tourism_data
    WHERE 
        gdp IS NOT NULL
        AND geo_category = 'Country'
)
WHERE rank <= 5
GROUP BY year
ORDER BY year;

/*
Top performers of course USA, China, Japan, Geramyny, UK, France.
We can see that there is some corellation between this and tourism.
*/



/*
Step 10
Inflation
*/

SELECT
    year,
    MAX(CASE WHEN rank = 1 THEN country END) AS rank1,
    MAX(CASE WHEN rank = 1 THEN inflation END) AS rank1_inflation,
    MAX(CASE WHEN rank = 2 THEN country END) AS rank2,
    MAX(CASE WHEN rank = 2 THEN inflation END) AS rank2_inflation,
    MAX(CASE WHEN rank = 3 THEN country END) AS rank3,
    MAX(CASE WHEN rank = 3 THEN inflation END) AS rank3_inflation,
    MAX(CASE WHEN rank = 4 THEN country END) AS rank4,
    MAX(CASE WHEN rank = 4 THEN inflation END) AS rank4_inflation,
    MAX(CASE WHEN rank = 5 THEN country END) AS rank5,
    MAX(CASE WHEN rank = 5 THEN inflation END) AS rank5_inflation

FROM (
    SELECT 
        year,
        country,
        inflation,
        RANK() OVER (PARTITION BY year ORDER BY inflation DESC) AS rank
    FROM tourism_data
    WHERE 
        inflation IS NOT NULL
        AND geo_category = 'Country'
)
WHERE rank <= 5
GROUP BY year
ORDER BY year;

/*
None of countries in this inflation ranking, even apear in our tourism rankings, we can propably say, that economy crisis do not help in developing tourism
*/


SELECT
    year,
    MAX(CASE WHEN rank = 1 THEN country END) AS rank1,
    MAX(CASE WHEN rank = 1 THEN inflation END) AS rank1_inflation,
    MAX(CASE WHEN rank = 2 THEN country END) AS rank2,
    MAX(CASE WHEN rank = 2 THEN inflation END) AS rank2_inflation,
    MAX(CASE WHEN rank = 3 THEN country END) AS rank3,
    MAX(CASE WHEN rank = 3 THEN inflation END) AS rank3_inflation,
    MAX(CASE WHEN rank = 4 THEN country END) AS rank4,
    MAX(CASE WHEN rank = 4 THEN inflation END) AS rank4_inflation,
    MAX(CASE WHEN rank = 5 THEN country END) AS rank5,
    MAX(CASE WHEN rank = 5 THEN inflation END) AS rank5_inflation

FROM (
    SELECT 
        year,
        country,
        inflation,
        RANK() OVER (PARTITION BY year ORDER BY inflation DESC) AS rank
    FROM tourism_data
    WHERE 
        inflation IS NOT NULL
        AND geo_category = 'Macroregion'
)
WHERE rank <= 5
GROUP BY year
ORDER BY year;

/*
Same thing here. Any top tourism performer region, dont even apear here.
*/


/*
Step 11
Unemployment rate
*/

SELECT
    year,
    MAX(CASE WHEN rank = 1 THEN country END) AS rank1,
    MAX(CASE WHEN rank = 1 THEN unemployment END) AS rank1_unemployment,
    MAX(CASE WHEN rank = 2 THEN country END) AS rank2,
    MAX(CASE WHEN rank = 2 THEN unemployment END) AS rank2_unemployment,
    MAX(CASE WHEN rank = 3 THEN country END) AS rank3,
    MAX(CASE WHEN rank = 3 THEN unemployment END) AS rank3_unemployment,
    MAX(CASE WHEN rank = 4 THEN country END) AS rank4,
    MAX(CASE WHEN rank = 4 THEN unemployment END) AS rank4_unemployment,
    MAX(CASE WHEN rank = 5 THEN country END) AS rank5,
    MAX(CASE WHEN rank = 5 THEN unemployment END) AS rank5_unemployment

FROM (
    SELECT 
        year,
        country,
        unemployment,
        RANK() OVER (PARTITION BY year ORDER BY unemployment DESC) AS rank
    FROM tourism_data
    WHERE 
        unemployment IS NOT NULL
        AND geo_category = 'Country'
)
WHERE rank <= 5
GROUP BY year
ORDER BY year;

/*
Unemployment rate also does not help. All top countries here are ones known for political or economical instability
*/

SELECT
    year,
    MAX(CASE WHEN rank = 1 THEN country END) AS rank1,
    MAX(CASE WHEN rank = 1 THEN unemployment END) AS rank1_unemployment,
    MAX(CASE WHEN rank = 2 THEN country END) AS rank2,
    MAX(CASE WHEN rank = 2 THEN unemployment END) AS rank2_unemployment,
    MAX(CASE WHEN rank = 3 THEN country END) AS rank3,
    MAX(CASE WHEN rank = 3 THEN unemployment END) AS rank3_unemployment,
    MAX(CASE WHEN rank = 4 THEN country END) AS rank4,
    MAX(CASE WHEN rank = 4 THEN unemployment END) AS rank4_unemployment,
    MAX(CASE WHEN rank = 5 THEN country END) AS rank5,
    MAX(CASE WHEN rank = 5 THEN unemployment END) AS rank5_unemployment

FROM (
    SELECT 
        year,
        country,
        unemployment,
        RANK() OVER (PARTITION BY year ORDER BY unemployment DESC) AS rank
    FROM tourism_data
    WHERE 
        unemployment IS NOT NULL
        AND geo_category = 'Macroregion'
)
WHERE rank <= 5
GROUP BY year
ORDER BY year;

/*
Situation in here is not so harsh.
South africa has biggest unemployment rate with indicator between 20% and 30%,
but next positions situation is much better, mostly from 5% to about 13%.
We can spot here regions like Europe or north america also. High unemployment kills tourism, but medium like 10% is not so problematic.
*/

--MAKE TABLES OF ALL RANKINGS COUNTRIES,SETS,LISTS
