/*
FEATURES EXPLORATION
Goal: Simple exploring every column, what are theirs characteristics, getting in touch with countries performance.
*/

/*
Step 1
We will explore country column, to this moment we know about only that it contains Strings, "propably" country names
*/


SELECT * from country

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


ALTER TABLE country ADD geo_category VARCHAR2(50);


UPDATE country c
SET geo_category = (
  SELECT lc.category
  FROM location_classification lc
  WHERE lc.country = c.country
)
WHERE EXISTS (
  SELECT 1
  FROM location_classification lc
  WHERE lc.country = c.country
);


COMMIT


select * from tourism

/*
Step 2
Country code. It does not give us any data insights, but works as country indicator-id.
It is helpfull when it comes to combining tables, operating on country codes is much easier than on country names.
*/

/*
Step 3
Year, axis of our analysis. 
*/
SELECT COUNT(DISTINCT year) AS Years_amount,MIN(year) AS First_year,MAX(year) AS Last_year
FROM tourism



/*
STEP 4
Tourism_receipts – this feature represents each country's income from international tourism, expressed in USD.
Data comes from the tourism table. To access readable country names and region types, we join with the country table.
*/

-- Top 5 countries by tourism receipts, year by year
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
        t.year,
        c.country,
        t.tourism_receipts,
        RANK() OVER (PARTITION BY t.year ORDER BY t.tourism_receipts DESC) AS rank
    FROM tourism t
    JOIN country c ON t.country_code = c.country_code
    WHERE 
        t.tourism_receipts IS NOT NULL
        AND c.geo_category = 'Country'
)
WHERE rank <= 5
GROUP BY year
ORDER BY year;

/*
Insights:
- The USA consistently dominates in terms of tourism income.
- France remains a strong second.
- Italy, Germany, Thailand, and Australia frequently rotate in ranks 3–4.
- Rank 5 occasionally includes China, Türkiye, and other emerging tourism economies.
*/

-- Top 5 macroregions by tourism receipts per year
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
        t.year,
        c.country,
        t.tourism_receipts,
        RANK() OVER (PARTITION BY t.year ORDER BY t.tourism_receipts DESC) AS rank
    FROM tourism t
    JOIN country c ON t.country_code = c.country_code
    WHERE 
        t.tourism_receipts IS NOT NULL
        AND c.geo_category = 'Macroregion'
)
WHERE rank <= 5
GROUP BY year
ORDER BY year;

/*
Insights:
- Europe holds all top three positions (Continent, EU, Euro Area).
- North America consistently appears in 4th place.
- Latin America and the Caribbean held 5th until 2007, when they were overtaken by the MENA region.
*/

/*
STEP 5
Tourism_exports – the percentage of a country’s total exports that comes from international tourism receipts.
This metric shows how strongly a country's economy depends on tourism exports.
*/

-- Top 5 countries by share of tourism in total exports (year by year)
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
        t.year,
        c.country,
        t.tourism_exports,
        RANK() OVER (PARTITION BY t.year ORDER BY t.tourism_exports DESC) AS rank
    FROM tourism t
    JOIN country c ON t.country_code = c.country_code
    WHERE 
        t.tourism_exports IS NOT NULL
        AND c.geo_category = 'Country'
)
WHERE rank <= 5
GROUP BY year
ORDER BY year;

/*
Insights:
- This metric highlights countries that heavily rely on tourism as their main export sector.
- Most top performers are small island nations or destinations with minimal industrial or manufacturing capacity.
- Their primary economic value lies in offering tropical, sunny, and scenic experiences to international tourists.
*/

-- Top 5 macroregions by share of tourism in exports (year by year)
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
        t.year,
        c.country,
        t.tourism_exports,
        RANK() OVER (PARTITION BY t.year ORDER BY t.tourism_exports DESC) AS rank
    FROM tourism t
    JOIN country c ON t.country_code = c.country_code
    WHERE 
        t.tourism_exports IS NOT NULL
        AND c.geo_category = 'Macroregion'
)
WHERE rank <= 5
GROUP BY year
ORDER BY year;

/*
Insights:
- Regional analysis confirms the dominance of island regions such as the Caribbean and the Pacific.
- Ranks 4 and 5 frequently feature the Middle East and African macroregions, showing moderate reliance on tourism exports.
*/

/*
STEP 6
Tourism_expenditures – the percentage of a country’s total imports spent on international tourism.
Note: We do not have access to total import values in dollars, so we can only compare relative percentages – not actual profits or balances.
*/

-- Top 5 countries by tourism expenditures as % of total imports (year by year)
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
        t.year,
        c.country,
        t.tourism_expenditures,
        RANK() OVER (PARTITION BY t.year ORDER BY t.tourism_expenditures DESC) AS rank
    FROM tourism t
    JOIN country c ON t.country_code = c.country_code
    WHERE 
        t.tourism_expenditures IS NOT NULL
        AND c.geo_category = 'Country'
)
WHERE rank <= 5
GROUP BY year
ORDER BY year;

/*
Insights:
- Tourism expenditures share some similarities with tourism exports, but not entirely.
- Many top spenders are countries without classic tourism appeal (e.g. warm beaches), such as Kuwait, Qatar, or Albania.
- These countries are building tourism sectors despite geographical or political disadvantages.
- Their high percentage suggests tourism is a significant portion of their foreign spending.
*/

-- Top 5 macroregions by tourism expenditures (percentage of imports)
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
        t.year,
        c.country,
        t.tourism_expenditures,
        RANK() OVER (PARTITION BY t.year ORDER BY t.tourism_expenditures DESC) AS rank
    FROM tourism t
    JOIN country c ON t.country_code = c.country_code
    WHERE 
        t.tourism_expenditures IS NOT NULL
        AND c.geo_category = 'Macroregion'
)
WHERE rank <= 5
GROUP BY year
ORDER BY year;

/*
Insights:
- Among regions, the top spenders are typically from the Middle East and lower-income African macroregions.
- By contrast, Caribbean and Pacific regions – which are top exporters of tourism – spend significantly less abroad.
*/


/*
STEP 7
Tourism_arrivals – represents the number of international tourists arriving in each country per year.
This metric is a direct indicator of a country's popularity as a travel destination.
*/

-- Top 5 countries by international tourist arrivals (year by year)
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
        t.year,
        c.country,
        t.tourism_arrivals,
        RANK() OVER (PARTITION BY t.year ORDER BY t.tourism_arrivals DESC) AS rank
    FROM tourism t
    JOIN country c ON t.country_code = c.country_code
    WHERE 
        t.tourism_arrivals IS NOT NULL
        AND c.geo_category = 'Country'
)
WHERE rank <= 5
GROUP BY year
ORDER BY year;

/*
Insights:
- The first few years may contain some inconsistencies due to missing or incomplete data.
- France consistently attracts the most tourists across the dataset.
- China ranks 3rd in many years, while Spain and Mexico frequently appear in 4th and 5th – 
  despite not being in the top 5 for revenue or expenditures.
- This highlights countries that may attract large volumes of tourists but generate relatively lower income per visitor.
*/

-- Top 5 macroregions by international tourist arrivals (year by year)
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
        t.year,
        c.country,
        t.tourism_arrivals,
        RANK() OVER (PARTITION BY t.year ORDER BY t.tourism_arrivals DESC) AS rank
    FROM tourism t
    JOIN country c ON t.country_code = c.country_code
    WHERE 
        t.tourism_arrivals IS NOT NULL
        AND c.geo_category = 'Macroregion'
)
WHERE rank <= 5
GROUP BY year
ORDER BY year;

/*
Insights:
- Similar to receipts, Europe dominates in terms of incoming tourist volume.
- While the United States is a top destination individually, the entire North American region does not rank as high.
- East Asia & Pacific emerges strongly, showing concentrated tourism demand in specific subregions.
*/


/*
STEP 8
Tourism_departures – the number of citizens or residents of a given country who travel abroad for tourism purposes.
This metric indicates a population’s capacity and tendency to engage in international travel.
*/

-- Top 5 countries by number of outgoing tourists (year by year)
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
        t.year,
        c.country,
        t.tourism_departures,
        RANK() OVER (PARTITION BY t.year ORDER BY t.tourism_departures DESC) AS rank
    FROM tourism t
    JOIN country c ON t.country_code = c.country_code
    WHERE 
        t.tourism_departures IS NOT NULL
        AND c.geo_category = 'Country'
)
WHERE rank <= 5
GROUP BY year
ORDER BY year;

/*
Insights:
- Most outbound tourism is generated by economically developed countries such as the USA, Germany, China, and the UK.
- These nations tend to have high disposable income, good global mobility, and a strong culture of international travel.
*/

-- Top 5 macroregions by number of outgoing tourists (year by year)
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
        t.year,
        c.country,
        t.tourism_departures,
        RANK() OVER (PARTITION BY t.year ORDER BY t.tourism_departures DESC) AS rank
    FROM tourism t
    JOIN country c ON t.country_code = c.country_code
    WHERE 
        t.tourism_departures IS NOT NULL
        AND c.geo_category = 'Macroregion'
)
WHERE rank <= 5
GROUP BY year
ORDER BY year;

/*
Insights:
- As expected, Europe dominates outbound tourism by a large margin, occupying the top 3 positions.
- Asia & Pacific and North America also appear frequently, reflecting their large populations and growing tourism industries.
*/


/*
STEP 9
GDP – Gross Domestic Product (in USD).
This metric shows the total economic output of a country. We’ll use it to check the top economies over time
and analyze any visible correlation between economic power and tourism performance.
*/

-- Top 5 countries by GDP (year by year)
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
        e.year,
        c.country,
        e.gdp,
        RANK() OVER (PARTITION BY e.year ORDER BY e.gdp DESC) AS rank
    FROM economy e
    JOIN country c ON e.country_code = c.country_code
    WHERE 
        e.gdp IS NOT NULL
        AND c.geo_category = 'Country'
)
WHERE rank <= 5
GROUP BY year
ORDER BY year;

/*
Insights:
- Unsurprisingly, the top economies remain consistent: USA, China, Japan, Germany, the UK, and France.
- There is a noticeable correlation between GDP and tourism revenue — most countries leading economically are also top tourism earners.
- However, the relationship is not perfect — GDP reflects economic size, while tourism depends on specific attractiveness and infrastructure.
*/


/*
STEP 10
Inflation – general price growth in the economy, measured as a percentage.
High inflation typically reflects economic instability, which can discourage both domestic and international travel.
*/

-- Top 5 countries by inflation rate (year by year)
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
        e.year,
        c.country,
        e.inflation,
        RANK() OVER (PARTITION BY e.year ORDER BY e.inflation DESC) AS rank
    FROM economy e
    JOIN country c ON e.country_code = c.country_code
    WHERE 
        e.inflation IS NOT NULL
        AND c.geo_category = 'Country'
)
WHERE rank <= 5
GROUP BY year
ORDER BY year;

/*
Insights:
- Countries with the highest inflation rarely appear in top tourism performance rankings.
- This suggests that economic crises, reflected by high inflation, can significantly hinder tourism growth.
- Many of the countries in this list may face instability, currency depreciation, or reduced attractiveness for visitors.
*/

-- Top 5 macroregions by inflation rate (year by year)
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
        e.year,
        c.country,
        e.inflation,
        RANK() OVER (PARTITION BY e.year ORDER BY e.inflation DESC) AS rank
    FROM economy e
    JOIN country c ON e.country_code = c.country_code
    WHERE 
        e.inflation IS NOT NULL
        AND c.geo_category = 'Macroregion'
)
WHERE rank <= 5
GROUP BY year
ORDER BY year;

/*
Insights:
- Similar patterns are observed at the macroregional level.
- High-inflation regions are not among the leaders in tourism, confirming the negative relationship between inflation and tourism development.
*/


/*
STEP 11
Unemployment rate – percentage of the labor force that is unemployed.
High unemployment often signals economic distress and lower consumer spending, which can negatively affect tourism infrastructure and travel behavior.
*/

-- Top 5 countries by unemployment rate (year by year)
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
        e.year,
        c.country,
        e.unemployment,
        RANK() OVER (PARTITION BY e.year ORDER BY e.unemployment DESC) AS rank
    FROM economy e
    JOIN country c ON e.country_code = c.country_code
    WHERE 
        e.unemployment IS NOT NULL
        AND c.geo_category = 'Country'
)
WHERE rank <= 5
GROUP BY year
ORDER BY year;

/*
Insights:
- Countries with the highest unemployment are often those with ongoing political or economic instability.
- These are typically not major tourism destinations, suggesting that high unemployment correlates negatively with inbound tourism activity.
*/

-- Top 5 macroregions by unemployment rate (year by year)
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
        e.year,
        c.country,
        e.unemployment,
        RANK() OVER (PARTITION BY e.year ORDER BY e.unemployment DESC) AS rank
    FROM economy e
    JOIN country c ON e.country_code = c.country_code
    WHERE 
        e.unemployment IS NOT NULL
        AND c.geo_category = 'Macroregion'
)
WHERE rank <= 5
GROUP BY year
ORDER BY year;

/*
Insights:
- South Africa consistently ranks highest, with unemployment rates between 20% and 30%.
- Other regions typically range from 5% to 13%.
- Europe and North America occasionally appear, showing that moderate unemployment (around 10%) doesn’t severely affect tourism, but extreme levels can be harmful.
*/

