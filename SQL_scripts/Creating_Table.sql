/*
  Step 1: Creating the main table for tourism data

  We begin by creating a table that will store all the tourism-related metrics.
  Since we have full knowledge of the dataset structure (from the CSV file), 
  we can define the schema precisely based on the column names and data types.
*/


CREATE TABLE tourism_data (
    country                 VARCHAR2(100),
    country_code            VARCHAR2(10),
    year                    NUMBER(4),

    tourism_receipts        NUMBER(15,2),
    tourism_arrivals        NUMBER(15,0),
    tourism_exports         NUMBER(15,2),
    tourism_departures      NUMBER(15,0),
    tourism_expenditures    NUMBER(15,2),

    gdp                     NUMBER(20,2),
    inflation               NUMBER(5,2),
    unemployment            NUMBER(5,2)
);



SELECT * FROM tourism_data
/*
    Step 2: Importing data from csv to Table
*/

/*
    Step 3: Creating table for temperature data.
*/

CREATE TABLE TEMPERATURE_DATA (
    country                 VARCHAR2(100),
    year                    NUMBER(4),
    AnnualMean           NUMBER(5,2),
    five_yr_smooth          NUMBER(5,2),
    Code                    Varchar2(3)
)

SELECT * FROM temperature_data

/*
    Step 4: Importing temperature data
*/
DELETE FROM temperature_data
WHERE year < 1999;




/*
    Step 5: Adding temperature data to tourism_data.
*/

ALTER TABLE tourism_data
ADD avg_temperature NUMBER(5,2);

UPDATE tourism_data t
SET avg_temperature = (
  SELECT MAX(annualmean)
  FROM temperature_data temp
  WHERE temp.code = t.country_code
    AND temp.year = t.year
);
COMMIT





