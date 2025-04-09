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

Create table T20_RECEIPTS(
    country                 VARCHAR2(100) NOT NULL,
    country_code            VARCHAR2(10) PRIMARY KEY,
    total_revenue           NUMBER(20,2)
)

INSERT INTO T20_RECEIPTS (country,country_code, total_revenue)
SELECT c.country,MIN(c.country_code), SUM(t.tourism_receipts)
FROM country c
JOIN tourism t ON c.country_code = t.country_code
WHERE c.geo_category = 'Country'
GROUP BY c.country
HAVING SUM(t.tourism_receipts) IS NOT NULL
ORDER BY SUM(t.tourism_receipts) DESC
FETCH FIRST 20 ROWS ONLY;
Commit

--Now let's see what are average tourism metrics of this countries,AVG yearly departures, arrivals, tourism export and import percentage.

ALTER TABLE t20_receipts
ADD AVG_yearly_arrival NUMBER(15,2)
ADD AVG_yearly_departures NUMBER(15,2)
ADD AVG_yearly_arr_dep_ratio NUMBER(5,2) --Arrivals/Departures ratio
ADD AVG_yearly_exports_percentage NUMBER(15,2)
ADD AVG_yearly_import_percentage NUMBER(15,2)
ADD AVG_yearly_import_export_ratio NUMBER(5,2) --Export/Import Ratio  >1 = Export bigger than import (by percentages)

--
SELECT tr.country, ROUND(AVG(t.tourism_arrivals),0)
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
