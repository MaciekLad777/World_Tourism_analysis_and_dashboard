/*
Creating tables
Goal: Preparing tables and importing our data
*/

/*
  Step 1: Creating the main tables for tourism-related metrics.
  We split data into 4 thematic tables: country, tourism, economy, and weather.
*/

/* COUNTRY TABLE */
CREATE TABLE country (
    country                 VARCHAR2(100) NOT NULL,
    country_code            VARCHAR2(10) PRIMARY KEY
);

/* TOURISM TABLE */
CREATE TABLE tourism (
    country_code            VARCHAR2(10),
    year                    NUMBER(4),
    tourism_receipts        NUMBER(15,2),
    tourism_arrivals        NUMBER(15,0),
    tourism_exports         NUMBER(15,2),
    tourism_departures      NUMBER(15,0),
    tourism_expenditures    NUMBER(15,2),
    PRIMARY KEY (country_code, year),
    FOREIGN KEY (country_code) REFERENCES country(country_code)
);

/* ECONOMY TABLE */
CREATE TABLE economy (
    country_code            VARCHAR2(10),
    year                    NUMBER(4),
    gdp                     NUMBER(20,2),
    inflation               NUMBER(5,2),
    unemployment            NUMBER(5,2),
    PRIMARY KEY (country_code, year),
    FOREIGN KEY (country_code) REFERENCES country(country_code)
);

/* WEATHER TABLE */
CREATE TABLE weather (
    country_code            VARCHAR2(10),
    year                    NUMBER(4),
    avg_temperature         NUMBER(5,2),
    PRIMARY KEY (country_code, year),
    FOREIGN KEY (country_code) REFERENCES country(country_code)
);
