/*
HOW TO PROFIT FROM TOURISM.

GOAL: Understand what factors make tourism sector most profitable, what pulls a lot of tourists.


Case Analysis
    
    How to run a tourism-driven economy?
Economic Analysis  TOP 20 performing countries of ALL-TIME
    1. What increases total tourism revenue?       RICH-tourism
        TOP 20 
            AVG(), MEDIAN(), STDDEV(), MIN(), MAX(), PERCENTILE_DISC()
                - arrivals
                - depatures
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


--As we have our's top performers, lets calculate country statistics precisly.
--We will apply a couple of statisitcs actions to understand every measurment deeply.

--We will create one single table, for all the stats, we need only 4 columns


--DROP TABLE feature_overall_stats


CREATE TABLE feature_overall_stats (
    country_code    VARCHAR2(10),
    feature         VARCHAR2(50),
    stat_name       VARCHAR2(20),
    stat_value      NUMBER(20, 4)
)
COMMIT;





CREATE OR REPLACE PROCEDURE insert_feature_stats (
    p_column_name  IN VARCHAR2,  -- np. 'tourism_arrivals', 'gdp'
    p_table_name   IN VARCHAR2   -- np. 'tourism', 'economy'
) AS
    v_sql   CLOB;
BEGIN
    -- AVG
    v_sql := 'INSERT INTO feature_overall_stats (country_code, feature, stat_name, stat_value)
              SELECT country_code, ''' || p_column_name || ''', ''AVG'', ROUND(AVG(' || p_column_name || '), 2)
              FROM ' || p_table_name || '
              GROUP BY country_code';
    EXECUTE IMMEDIATE v_sql;
    COMMIT;

    -- SUM
    v_sql := 'INSERT INTO feature_overall_stats (country_code, feature, stat_name, stat_value)
              SELECT country_code, ''' || p_column_name || ''', ''SUM'', ROUND(SUM(' || p_column_name || '), 2)
              FROM ' || p_table_name || '
              GROUP BY country_code';
    EXECUTE IMMEDIATE v_sql;
    COMMIT;

    -- MIN
    v_sql := 'INSERT INTO feature_overall_stats (country_code, feature, stat_name, stat_value)
              SELECT country_code, ''' || p_column_name || ''', ''MIN'', MIN(' || p_column_name || ')
              FROM ' || p_table_name || '
              GROUP BY country_code';
    EXECUTE IMMEDIATE v_sql;
    COMMIT;

    -- MAX
    v_sql := 'INSERT INTO feature_overall_stats (country_code, feature, stat_name, stat_value)
              SELECT country_code, ''' || p_column_name || ''', ''MAX'', MAX(' || p_column_name || ')
              FROM ' || p_table_name || '
              GROUP BY country_code';
    EXECUTE IMMEDIATE v_sql;
    COMMIT;

    -- STDDEV
    v_sql := 'INSERT INTO feature_overall_stats (country_code, feature, stat_name, stat_value)
              SELECT country_code, ''' || p_column_name || ''', ''STDDEV'', ROUND(STDDEV(' || p_column_name || '), 2)
              FROM ' || p_table_name || '
              GROUP BY country_code';
    EXECUTE IMMEDIATE v_sql;
    COMMIT;

    -- MEDIAN
    v_sql := 'INSERT INTO feature_overall_stats (country_code, feature, stat_name, stat_value)
              SELECT country_code, ''' || p_column_name || ''', ''MEDIAN'', ROUND(PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY ' || p_column_name || '), 2)
              FROM ' || p_table_name || '
              WHERE ' || p_column_name || ' IS NOT NULL
              GROUP BY country_code';
    EXECUTE IMMEDIATE v_sql;
    COMMIT;

    -- QUALITY (23 lat)
    v_sql := 'INSERT INTO feature_overall_stats (country_code, feature, stat_name, stat_value)
              SELECT country_code, ''' || p_column_name || ''', ''QUALITY'', ROUND(COUNT(' || p_column_name || ') * 100 / 23, 2)
              FROM ' || p_table_name || '
              GROUP BY country_code';
    EXECUTE IMMEDIATE v_sql;
    COMMIT;

    -- PCTL (percentile rank by SUM)
    v_sql := 'INSERT INTO feature_overall_stats (country_code, feature, stat_name, stat_value)
              SELECT * FROM (
                SELECT country_code,
                       ''' || p_column_name || ''' AS feature,
                       ''PCTL'' AS stat_name,
                       ROUND(PERCENT_RANK() OVER (ORDER BY SUM(' || p_column_name || ')), 4) AS stat_value
                FROM ' || p_table_name || '
                GROUP BY country_code
              )';
    EXECUTE IMMEDIATE v_sql;
    COMMIT;
END;
/

--Now we can simply calculate it all with only a couple of lines
BEGIN
  -- TOURISM FEATURES
  insert_feature_stats('tourism_arrivals', 'tourism');
  insert_feature_stats('tourism_departures', 'tourism');
  insert_feature_stats('tourism_receipts', 'tourism');
  insert_feature_stats('tourism_exports', 'tourism');
  insert_feature_stats('tourism_expenditures', 'tourism');

  -- ECONOMY FEATURES
  insert_feature_stats('gdp', 'economy');
  insert_feature_stats('inflation', 'economy');
  insert_feature_stats('unemployment', 'economy');
  -- WEATHER FEATURES
  insert_feature_stats('avg_temperature','weather');
END;
/


select * from feature_overall_stats
select COUNT(*) from feature_overall_stats
-- Now we have nearly 18 thousnt rows of measures








