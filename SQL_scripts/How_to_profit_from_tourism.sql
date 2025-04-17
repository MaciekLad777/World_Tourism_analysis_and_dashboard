/*
HOW TO PROFIT FROM TOURISM.

GOAL: Understand what factors make tourism sector most profitable, what pulls a lot of tourists.


Case Analysis
    
    How to run a tourism-driven economy?
    
Economic Analysis
TOP 20 performing countries of ALL-TIME
Goal:
-Find out which features corelates the most with high tourism receipts,what determine succes of countries tourism sector?
            SUM(),AVG(), MEDIAN(), STDDEV(), MIN(), MAX()
                - arrivals
                - depatures
                - gdp
                - unemployment
                - inflation
                - weather
                - import
                - export
                
        Quick insights
            -Which countries have best USD/tourist ratio (Divide and order by)
            -Which countries have biggest tourism dependency (What percentage of gdp are tourist receipts)
            -Whats the best export-import ratio(examples from t20)
    

--We will put ours top performers into table, as we will use it often.


-- STEP 1: Create a helper table for Top 20 countries
--         by total tourism receipts
CREATE TABLE T20_RECEIPTS (
    rank           NUMBER PRIMARY KEY,
    country        VARCHAR2(100),
    country_code   VARCHAR2(10)
);

-- Insert Top 20 performers based on total receipts.
-- Using RANK() to assign the position and aggregating all available years.
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

COMMIT;

-- Review the inserted top 20 countries
SELECT * FROM T20_RECEIPTS;



-- STEP 2: Create the main statistics table
-- This table stores all aggregated stats per feature,
-- including each country's percentile compared to others.
CREATE TABLE feature_stats_percentiled (
    country_code      VARCHAR2(10),
    feature           VARCHAR2(50),    -- Feature name, e.g. 'gdp', 'tourism_arrivals'
    stat_name         VARCHAR2(20),    -- Statistic type: 'AVG', 'MEDIAN', etc.
    stat_value        NUMBER(20, 4),   -- Actual calculated value
    percentile_rank   NUMBER(5, 4)     -- Percentile position of this country vs others
);


-- STEP 3: Create a dynamic PL/SQL procedure that calculates
--         all statistics for any given feature and table
--         and stores them into `feature_stats_percentiled`
CREATE OR REPLACE PROCEDURE insert_feature_stats (
    p_column_name  IN VARCHAR2,  -- Name of the column (e.g. 'gdp', 'tourism_arrivals')
    p_table_name   IN VARCHAR2   -- Name of the table containing the column
) AS
    v_sql   CLOB;
BEGIN
    -- AVG + Percentile
    v_sql := '
        INSERT INTO feature_stats_percentiled (country_code, feature, stat_name, stat_value, percentile_rank)
        SELECT country_code,
               ''' || p_column_name || ''' AS feature,
               ''AVG'' AS stat_name,
               ROUND(AVG(' || p_column_name || '), 2),
               ROUND(PERCENT_RANK() OVER (ORDER BY AVG(' || p_column_name || ')), 4)
        FROM ' || p_table_name || '
        WHERE ' || p_column_name || ' IS NOT NULL
        GROUP BY country_code';
    EXECUTE IMMEDIATE v_sql;
    COMMIT;

    -- SUM + Percentile
    v_sql := '
        INSERT INTO feature_stats_percentiled (country_code, feature, stat_name, stat_value, percentile_rank)
        SELECT country_code,
               ''' || p_column_name || ''' AS feature,
               ''SUM'' AS stat_name,
               ROUND(SUM(' || p_column_name || '), 2),
               ROUND(PERCENT_RANK() OVER (ORDER BY SUM(' || p_column_name || ')), 4)
        FROM ' || p_table_name || '
        WHERE ' || p_column_name || ' IS NOT NULL
        GROUP BY country_code';
    EXECUTE IMMEDIATE v_sql;
    COMMIT;

    -- MIN + Percentile
    v_sql := '
        INSERT INTO feature_stats_percentiled (country_code, feature, stat_name, stat_value, percentile_rank)
        SELECT country_code,
               ''' || p_column_name || ''' AS feature,
               ''MIN'' AS stat_name,
               MIN(' || p_column_name || '),
               ROUND(PERCENT_RANK() OVER (ORDER BY MIN(' || p_column_name || ')), 4)
        FROM ' || p_table_name || '
        WHERE ' || p_column_name || ' IS NOT NULL
        GROUP BY country_code';
    EXECUTE IMMEDIATE v_sql;
    COMMIT;

    -- MAX + Percentile
    v_sql := '
        INSERT INTO feature_stats_percentiled (country_code, feature, stat_name, stat_value, percentile_rank)
        SELECT country_code,
               ''' || p_column_name || ''' AS feature,
               ''MAX'' AS stat_name,
               MAX(' || p_column_name || '),
               ROUND(PERCENT_RANK() OVER (ORDER BY MAX(' || p_column_name || ')), 4)
        FROM ' || p_table_name || '
        WHERE ' || p_column_name || ' IS NOT NULL
        GROUP BY country_code';
    EXECUTE IMMEDIATE v_sql;
    COMMIT;

    -- STDDEV + Percentile
    v_sql := '
        INSERT INTO feature_stats_percentiled (country_code, feature, stat_name, stat_value, percentile_rank)
        SELECT country_code,
               ''' || p_column_name || ''' AS feature,
               ''STDDEV'' AS stat_name,
               ROUND(STDDEV(' || p_column_name || '), 2),
               ROUND(PERCENT_RANK() OVER (ORDER BY STDDEV(' || p_column_name || ')), 4)
        FROM ' || p_table_name || '
        WHERE ' || p_column_name || ' IS NOT NULL
        GROUP BY country_code';
    EXECUTE IMMEDIATE v_sql;
    COMMIT;

    -- MEDIAN + Percentile (requires CTE since MEDIAN is not compatible with analytic OVER)
    v_sql := '
        INSERT INTO feature_stats_percentiled (country_code, feature, stat_name, stat_value, percentile_rank)
        SELECT country_code, feature, stat_name, stat_value,
               ROUND(PERCENT_RANK() OVER (ORDER BY stat_value), 4)
        FROM (
            SELECT
                country_code,
                ''' || p_column_name || ''' AS feature,
                ''MEDIAN'' AS stat_name,
                ROUND(PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY ' || p_column_name || '), 2) AS stat_value
            FROM ' || p_table_name || '
            WHERE ' || p_column_name || ' IS NOT NULL
            GROUP BY country_code
        )';
    EXECUTE IMMEDIATE v_sql;

    COMMIT;
END;
/



-- STEP 4: Run the procedure for all selected features
BEGIN
  -- TOURISM INDICATORS
  insert_feature_stats('tourism_arrivals', 'tourism');
  insert_feature_stats('tourism_departures', 'tourism');
  insert_feature_stats('tourism_receipts', 'tourism');
  insert_feature_stats('tourism_exports', 'tourism');
  insert_feature_stats('tourism_expenditures', 'tourism');

  -- ECONOMIC INDICATORS
  insert_feature_stats('gdp', 'economy');
  insert_feature_stats('inflation', 'economy');
  insert_feature_stats('unemployment', 'economy');

  -- CLIMATE INDICATOR
  insert_feature_stats('avg_temperature','weather');
END;
/


-- STEP 5: Verify the number of inserted rows
-- (Each feature × 6 stats × ~250 countries)
SELECT COUNT(*) FROM feature_stats_percentiled;
-- There is over 12k calculated rows

-- STEP 6: Summary stats for top performers
-- This query shows how T20 countries compare to others.
-- We calculate average, min and max percentile rank for each stat & feature

SELECT
  feature,
  stat_name,
  ROUND(AVG(percentile_rank), 2) AS avg_percentile,
  ROUND(MIN(percentile_rank), 2) AS min_percentile,
  ROUND(MAX(percentile_rank), 2) AS max_percentile
FROM feature_stats_percentiled
WHERE country_code IN (SELECT country_code FROM t20_receipts)
GROUP BY feature, stat_name
ORDER BY feature, stat_name;





-- ===========================
--         TOURISM
-- ===========================

-- ARRIVALS
-- Of course, the number of tourist arrivals correlates with tourism receipts — not perfectly, but the relationship is evident.
-- On average, T20 countries rank in the top 23% for arrivals.
-- The lowest-ranking T20 country is at the 63rd percentile, while the highest is at the 93rd.
-- This shows strong consistency with minor expected variation.

-- DEPARTURES
-- A similar trend to arrivals.
-- Tourist departures moderately correlate with tourism receipts.
-- This might reflect economic development and international connectedness.

-- TOURISM EXPORTS %
-- Here, we observe no strong correlation.
-- T20 countries are on average in the 39th percentile, with a wide range from 8th to 81st.
-- Values are distributed evenly, meaning there's no clear relationship.

-- Example:
-- Greece ranks 11th in receipts, with 81% of its exports from tourism.
-- Japan ranks 8th, with only 7% of its exports from tourism.

-- Therefore, no optimal or common ratio of tourism in exports exists for high revenue.

SELECT t.country, f.stat_value, f.percentile_rank
FROM t20_receipts t
JOIN feature_stats_percentiled f ON t.country_code = f.country_code 
WHERE f.feature = 'tourism_exports' AND stat_name = 'AVG'
ORDER BY t.rank;

-- TOURISM EXPENDITURES %
-- Similar to exports.
-- Average percentiles of expenditures among T20 countries are below 40, but again the variance is wide.
-- Some countries spend a lot on tourism imports, others very little — both can perform well.
-- Overall: on average, T20 countries allocate a smaller share of their import spending to tourism.

SELECT t.country, f.stat_value, f.percentile_rank
FROM t20_receipts t
JOIN feature_stats_percentiled f ON t.country_code = f.country_code 
WHERE f.feature = 'tourism_expenditures' AND stat_name = 'AVG'
ORDER BY t.rank;


-- ===========================
--         ECONOMY
-- ===========================

-- GDP
-- The strongest indicator of tourism receipts.
-- T20 countries have large, stable economies — typically placing in the top 20%.
-- The weakest T20 country ranks 66th percentile, the strongest 96th.
-- Also aligns closely with high arrival numbers.

-- INFLATION
-- T20 countries have relatively low inflation — averaging around the 30th percentile.
-- Range is wide: from 0th percentile to 96th.

-- Only Russia and India have inflation higher than the global average.
-- Conclusion: Low inflation helps, but is not a deal-breaker.

SELECT t.country, f.stat_value, f.percentile_rank
FROM t20_receipts t
JOIN feature_stats_percentiled f ON t.country_code = f.country_code 
WHERE f.feature = 'inflation' AND stat_name = 'AVG'
ORDER BY t.rank;

-- UNEMPLOYMENT
-- Mirrors the inflation situation.
-- Most T20 countries have low unemployment, but the range spans from 1st to 96th percentile.
-- Generally, lower unemployment aligns with tourism success, but not conclusively.

SELECT t.country, f.stat_value, f.percentile_rank
FROM t20_receipts t
JOIN feature_stats_percentiled f ON t.country_code = f.country_code 
WHERE f.feature = 'unemployment' AND stat_name = 'AVG'
ORDER BY t.rank;

-- AVERAGE TEMPERATURE
-- Interesting result: T20 countries tend to be colder, averaging 29th percentile in temperature.
-- The range spans from 0th to 83rd percentile.
-- Most fall in the 30–40 range — moderate climate — but exceptions like Russia (cold) and Malaysia (hot) show that temperature is not a key factor.

SELECT t.country, f.stat_value, f.percentile_rank
FROM t20_receipts t
JOIN feature_stats_percentiled f ON t.country_code = f.country_code 
WHERE f.feature = 'avg_temperature' AND stat_name = 'AVG'
ORDER BY t.rank;


    

CONCLUSION

ARRIVALS                — strong positive correlation   — More tourists simply mean more money
DEPARTURES              — moderate correlation          — Possibly reflects wealth & international engagement
TOURISM EXPORTS %       — no correlation                — Values spread evenly, no clear pattern
TOURISM EXPENDITURES %  — no correlation                — Slight tendency to be lower, but inconsistent
GDP                     — strong positive correlation   — High GDP = high tourism capability and infrastructure
INFLATION               — moderate negative correlation — Lower inflation helps, but not decisive
UNEMPLOYMENT            — moderate negative correlation — Lower unemployment often helps, but many exceptions
AVG TEMPERATURE         — weak/mixed correlation        — Moderate climate is common, but not required


Most powerful predictors of high tourism revenue are:

    -High number of arrivals,
    -High and stable GDP,
    -Relatively low inflation.

This means that being a well-developed, globally visible and accessible country matters
far more than structural dependency on tourism sector or even climate.
These results provide solid groundwork for modeling tourism performance
or identifying potential high-performers among underdogs.

    
    
    
    
    
*/








