-- Create Database 
CREATE DATABASE IF NOT EXISTS wildlife;

-- Use Database 
USE wildlife;

-- Create table
CREATE TABLE IF NOT EXISTS crocodile_observations (
    id BIGINT PRIMARY KEY,
    observed_on DATE,
    place_guess VARCHAR(255),
    latitude DECIMAL(9,6),
    longitude DECIMAL(9,6),
    place_county_name VARCHAR(100),
    place_state_name VARCHAR(100),
    scientific_name VARCHAR(100),
    common_name VARCHAR(100)
);

-- ========================
-- DATA EXPLORATION 
-- ========================

-- View the first 5 rows
SELECT * 
FROM crocodile_observations
LIMIT 5;

-- Count the total number of crocodile observations

SELECT COUNT(*) AS total_observations
FROM crocodile_observations;

-- Identify the counties with the highest number of American crocodile observations

SELECT
    place_county_name,
    COUNT(*) AS observations
FROM crocodile_observations
GROUP BY place_county_name
ORDER BY observations DESC;

-- Count observations by year to identify trends over time

SELECT
    YEAR(observed_on) AS year,
    COUNT(*) AS observations
FROM crocodile_observations
GROUP BY year
ORDER BY year;

-- Find the earliest crocodile observation in the dataset
SELECT MIN(observed_on) AS earliest_observation
FROM crocodile_observations; 

-- Find the most recent crocodile observation in the dataset
SELECT MAX(observed_on) AS latest_observation
FROM crocodile_observations;

-- Display the 10 most recent crocodile observations
SELECT observed_on, place_county_name, common_name
FROM crocodile_observations
ORDER BY observed_on DESC
LIMIT 10;

-- How many observations occurred in each month across the entire dataset 
SELECT
    MONTH(observed_on) AS month,
    COUNT(*) AS observations
FROM crocodile_observations
GROUP BY month
ORDER BY month;

-- Which month has the highest number of observations?
SELECT
    MONTH(observed_on) AS month,
    COUNT(*) AS observations
FROM crocodile_observations
GROUP BY month
ORDER BY observations DESC
LIMIT 1;

-- Which county had the most observations?
SELECT place_county_name, COUNT(*) AS observations
FROM crocodile_observations
GROUP BY place_county_name
ORDER BY observations DESC
LIMIT 1;

-- How many different counties are reperesented in the dataset?
SELECT COUNT(DISTINCT place_county_name) AS unique_counties
FROM crocodile_observations;

-- How many observations occurred in Monroe county?
SELECT COUNT(*) as monroe_observations
FROM crocodile_observations
WHERE place_county_name = 'Monroe';

-- How many Monroe County observations occurred after January 1, 2020?
SELECT COUNT(*) as monroe_observations
FROM crocodile_observations
WHERE place_county_name = 'Monroe' AND (observed_on) >= '2020-01-01';

-- How many observations occurred in March? 
SELECT COUNT(*) as march_observations
FROM crocodile_observations	
WHERE MONTH(observed_on) = 3;

SELECT * 
FROM crocodile_observations
LIMIT 5;

-- ====================================
-- MULTI-SPECIES EXPANSION
-- ====================================

-- Create species table
CREATE TABLE IF NOT EXISTS species(
	species_id INT PRIMARY KEY,
    common_name VARCHAR(100) NOT NULL,
    scientific_name VARCHAR(100) NOT NULL
);

-- Populate species table
INSERT INTO species (
	species_id,
	common_name,
    scientific_name
)
VALUES
	(1, 'American Crocodile', 'Crocodylus acutus'),
    (2, 'Burmese Python', 'Python bivittatus'),
	(3, 'Argentine Black-and-white Tegu', 'Salvator merianae')
;
-- Review species table
SELECT *
FROM species;

-- Create observations table 
CREATE TABLE IF NOT EXISTS observations(
	observation_id BIGINT PRIMARY KEY,
    species_id INT NOT NULL,
    observed_on DATE NOT NULL,
    place_guess VARCHAR(255),
    latitude DECIMAL(9,6),
	longitude DECIMAL(9,6),
    place_county_name VARCHAR(100),
	place_state_name VARCHAR(100),
    FOREIGN KEY (species_id)
		REFERENCES species(species_id)
);
-- Ensure every record has an observation date
SELECT COUNT(*)
FROM crocodile_observations
WHERE observed_on IS NULL;

-- ========================================
-- ETL PIPELINE: CROCODILES
-- ========================================
-- Staging tables store raw imported CSV data before it is transformed
-- and loaded into the normalized observations table.
-- Create staging table of raw crocodile observation data
CREATE TABLE IF NOT EXISTS staging_crocodiles (
	id BIGINT PRIMARY KEY,
    observed_on DATE NOT NULL,
    place_guess VARCHAR(255),
    latitude DECIMAL(9,6) NOT NULL,
    longitude DECIMAL(9,6) NOT NULL,
    place_county_name VARCHAR(100),
    place_state_name VARCHAR(100),
    scientific_name VARCHAR(100) NOT NULL,
    common_name VARCHAR(100) NOT NULL
    );
-- Verify that all rows were imported 
SELECT COUNT(*) AS crocodile_rows
FROM staging_crocodiles;

-- Insert rows into the observations table. Take the id from staging and put it into observation_id. 
-- Set species_id to 1 (crocodile) for every row. Copy the remaining columns across.
INSERT INTO observations(
	observation_id,
    species_id,
    observed_on,
    place_guess,
    latitude,
    longitude,
    place_county_name,
    place_state_name
)
SELECT
	id,
    1,
    observed_on,
    place_guess,
    latitude,
    longitude,
    place_county_name,
    place_state_name
FROM staging_crocodiles;

-- Verify that the load worked 
SELECT COUNT(*) AS observation_count
FROM observations;

-- ========================================
-- ETL PIPELINE: PYTHONS
-- ========================================

-- Create staging table of raw python observations
CREATE TABLE IF NOT EXISTS staging_pythons (
	id BIGINT PRIMARY KEY,
    observed_on DATE NOT NULL,
    place_guess VARCHAR(255),
    latitude DECIMAL(9,6) NOT NULL,
    longitude DECIMAL(9,6) NOT NULL,
    place_county_name VARCHAR(100),
    place_state_name VARCHAR(100),
    scientific_name VARCHAR(100) NOT NULL,
    common_name VARCHAR(100) NOT NULL
    );

-- Insert rows into the observations table. Take the id from staging and put it into observation_id. 
-- Set species_id to 2 (python) for every row. Copy the remaining columns across.
INSERT INTO observations(
	observation_id,
    species_id,
    observed_on,
    place_guess,
    latitude,
    longitude,
    place_county_name,
    place_state_name
)
SELECT
	id,
    2,
    observed_on,
    place_guess,
    latitude,
    longitude,
    place_county_name,
    place_state_name
FROM staging_pythons;

-- Verify that the load worked
SELECT COUNT(*) AS total_observations
FROM observations;

-- ========================================
-- ETL PIPELINE: TEGUS
-- ========================================
-- Create staging table of raw tegu observations
CREATE TABLE IF NOT EXISTS staging_tegus (
	id BIGINT PRIMARY KEY,
    observed_on DATE NOT NULL,
    place_guess VARCHAR(255),
    latitude DECIMAL(9,6) NOT NULL,
    longitude DECIMAL(9,6) NOT NULL,
    place_county_name VARCHAR(100),
    place_state_name VARCHAR(100),
    scientific_name VARCHAR(100) NOT NULL,
    common_name VARCHAR(100) NOT NULL
    );

-- Insert rows into the observations table. Take the id from staging and put it into observation_id. 
-- Set species_id to 3 (tegu) for every row. Copy the remaining columns across.
INSERT INTO observations(
	observation_id,
    species_id,
    observed_on,
    place_guess,
    latitude,
    longitude,
    place_county_name,
    place_state_name
)
SELECT
	id,
    3,
    observed_on,
    place_guess,
    latitude,
    longitude,
    place_county_name,
    place_state_name
FROM staging_tegus;

SELECT
    species_id,
    COUNT(*) AS observations
FROM observations
GROUP BY species_id;

-- ========================================
-- RELATIONAL DATABASE ANALYSIS
-- ========================================

-- Count observations for each species using a JOIN.
SELECT
    s.common_name,
    COUNT(*) AS observations
FROM observations o
JOIN species s
    ON o.species_id = s.species_id
GROUP BY s.common_name
ORDER BY observations DESC;

-- Which species is observed across the greatest number of counties?
SELECT
    s.common_name,
    COUNT(DISTINCT o.place_county_name) AS counties
FROM observations o
JOIN species s
    ON o.species_id = s.species_id
GROUP BY s.common_name
ORDER BY counties DESC;

-- How have observations changed over time for each species?
SELECT s.common_name, YEAR(o.observed_on) AS year, COUNT(*) AS records
FROM species s
JOIN observations o
	ON s.species_id = o.species_id
GROUP BY
    s.common_name,
    YEAR(o.observed_on)
ORDER BY 
	year, s.common_name;


-- Which counties have the highest number of observations for each species?    
WITH county_counts AS (SELECT 
	s.common_name,
	o.place_county_name,
    COUNT(*) as observations
FROM species s
JOIN observations o
	ON s.species_id = o.species_id
GROUP BY
    o.place_county_name,
    s.common_name),
    max_counts AS (
    SELECT
        common_name,
        MAX(observations) AS max_observations
    FROM county_counts
    GROUP BY common_name
)
SELECT
    county_counts.common_name,
    county_counts.place_county_name,
    county_counts.observations
FROM county_counts
JOIN max_counts 
	ON county_counts.common_name = max_counts.common_name
	AND county_counts.observations = max_counts.max_observations;

-- Which counties contain all three species?
SELECT o.place_county_name
FROM observations o
GROUP BY place_county_name
HAVING COUNT(DISTINCT(o.species_id)) = 3
;

-- Which counties have more observations than the average county? Using subqueries

SELECT *
FROM
(
    SELECT
        place_county_name,
        COUNT(*) AS observations
    FROM observations
    GROUP BY place_county_name
) county_totals

WHERE observations >
(
    SELECT AVG(observations)
    FROM
    (
        SELECT
            place_county_name,
            COUNT(*) AS observations
        FROM observations
        GROUP BY place_county_name
    ) county_totals
);

-- Which counties have more observations than the average county? Using CTE

WITH county_totals AS (
    SELECT
        place_county_name,
        COUNT(*) AS observations
    FROM observations
    GROUP BY place_county_name
)

SELECT
    place_county_name,
    observations
FROM county_totals
WHERE observations >
(
    SELECT AVG(observations)
    FROM county_totals
)
ORDER BY observations DESC;

-- Which observations belong to crocodiles?
SELECT *
FROM observations
WHERE species_id = 
(
	SELECT species_id
    FROM species
    WHERE common_name = 'American Crocodile'
);


	


















































































