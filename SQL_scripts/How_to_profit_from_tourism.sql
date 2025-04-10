/*
HOW TO PROFIT FROM TOURISM.

GOAL: Understand what factors make tourism sector most profitable, what pulls a lot of tourists.


Case Analysis
    
    How to run a tourism-driven economy?
Economic Analysis  TOP 20 performing countries of ALL-TIME
    1. What increases total tourism revenue?       RICH-tourism
        TOP 20 
            AVG(), MEDIAN(), STDDEV(), MIN(), MAX(), PERCENTILE_DISC()
                - gdp
                - unemployment
                - inflation
                - weather
                - import
                - export
                
            import-export percentage ratio
    
    2. What increases the number of tourists?       POOR-tourism
        Points 1 and 2 do not have to correlate. This must be verified.
            AVG(every feature), MEDIAN(every feature)
                - gdp
                - unemployment
                - inflation
                - weather
                - import
                - export
            import-export percentage ratio

    USD per tourist – what influences the growth of this metric?
    What is the best ratio of features?
    What actions to take to run a stable and profitable tourism economy?
*/

--We will put ours top performers into table, as we will use it often.


CREATE TABLE T20_RECEIPTS (
    rank           NUMBER PRIMARY KEY,
    country        VARCHAR2(100),
    country_code   VARCHAR2(10)
);

INSERT INTO T20_RECEIPTS (rank, country, country_code)
SELECT
    RANK() OVER (ORDER BY SUM(t.tourism_receipts) DESC) AS rank,
    c.country,
    MIN(c.country_code) AS country_code
FROM country c
JOIN tourism t ON c.country_code = t.country_code
WHERE c.geo_category = 'Country'
GROUP BY c.country
HAVING SUM(t.tourism_receipts) IS NOT NULL
ORDER BY SUM(t.tourism_receipts) DESC
FETCH FIRST 20 ROWS ONLY;

Commit

select * from t20_receipts;


--Now let's see what are average tourism metrics of this countries,AVG yearly departures, arrivals, tourism export and import percentage.
--START from here 

--Now we will create seperate tables for every feature statistics
--TABLES WILL LOOK LIKE THAT, LOT OF FEATURES
CREATE TABLE Arrivals_STATS (
    country_code                 VARCHAR2(10) PRIMARY KEY,

    SUM_arrivals                 NUMBER(20,2),
    SUM_arrivals_PCTL            NUMBER(5,2),
    SUM_arrivals_QUALITY         NUMBER(5,2),

    AVG_arrivals                 NUMBER(15,2),
    AVG_arrivals_PCTL            NUMBER(5,2),
    AVG_arrivals_QUALITY         NUMBER(5,2),

    MEDIAN_arrivals              NUMBER(15,2),
    MEDIAN_arrivals_PCTL         NUMBER(5,2),
    MEDIAN_arrivals_QUALITY      NUMBER(5,2),

    MIN_arrivals                 NUMBER(15,2),
    MIN_arrivals_PCTL            NUMBER(5,2),
    MIN_arrivals_QUALITY         NUMBER(5,2),

    MAX_arrivals                 NUMBER(15,2),
    MAX_arrivals_PCTL            NUMBER(5,2),
    MAX_arrivals_QUALITY         NUMBER(5,2),

    STDDEV_arrivals              NUMBER(15,2),
    STDDEV_arrivals_PCTL         NUMBER(5,2),
    STDDEV_arrivals_QUALITY      NUMBER(5,2)
);


--
SELECT tr.country_code,
ROUND(SUM(t.tourism_arrivals),0),
ROUND(AVG(t.tourism_arrivals),0),
ROUND(MEDIAN(t.tourism_arrivals),0),
ROUND(MIN(t.tourism_arrivals),0),
ROUND(MAX(t.tourism_arrivals),0),
ROUND(STDDEV(t.tourism_arrivals),0),
FROM t20_receipts tr
JOIN tourism t ON tr.country_code = t.country_code
GROUP BY tr.country
ORDER BY ROUND(AVG(t.tourism_arrivals),0) DESC
--
SELECT tr.country, ROUND(AVG(t.tourism_departures),0)
FROM t20_receipts tr
JOIN tourism t ON tr.country_code = t.country_code
GROUP BY tr.country
ORDER BY ROUND(AVG(t.tourism_departures),0) DESC

--
SELECT tr.country, ROUND(AVG(t.tourism_exports),0)
FROM t20_receipts tr
JOIN tourism t ON tr.country_code = t.country_code
GROUP BY tr.country
ORDER BY ROUND(AVG(t.tourism_exports),0) DESC

SELECT tr.country, ROUND(AVG(t.tourism_expenditures),0)
FROM t20_receipts tr
JOIN tourism t ON tr.country_code = t.country_code
GROUP BY tr.country
ORDER BY ROUND(AVG(t.tourism_expenditures),0) DESC

SELECT tr.country, ROUND(AVG(t.tourism_exports)/AVG(t.tourism_expenditures),2) AS export_import_ratio
FROM t20_receipts tr
JOIN tourism t ON tr.country_code = t.country_code
GROUP BY tr.country
ORDER BY export_import_ratio DESC


SELECT tr.country, ROUND(AVG(e.gdp),0) AS AVG_gdp
FROM t20_receipts tr
JOIN economy e ON tr.country_code = e.country_code
GROUP BY tr.country
ORDER BY  AVG_gdp DESC



SELECT tr.country, ROUND(AVG(e.inflation),0) AS AVG_inflation
FROM t20_receipts tr
JOIN economy e ON tr.country_code = e.country_code
GROUP BY tr.country
ORDER BY  AVG_inflation DESC

SELECT tr.country, ROUND(AVG(e.unemployment),0) AS AVG_unemployment
FROM t20_receipts tr
JOIN economy e ON tr.country_code = e.country_code
GROUP BY tr.country
ORDER BY  AVG_unemployment DESC



SELECT tr.country, ROUND(AVG(w.avg_temperature),0) AS AVG_temperature
FROM t20_receipts tr
JOIN weather w ON tr.country_code = w.country_code
GROUP BY tr.country
ORDER BY  AVG_temperature DESC