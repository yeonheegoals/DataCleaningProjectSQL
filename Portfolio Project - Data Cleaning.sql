-- SQL Project - Data Cleaning

-- Dataset source: https://www.kaggle.com/datasets/swaptr/layoffs-2022

-- Initial exploration of the data
SELECT * 
FROM world_layoffs.layoffs;

-- Step 1: Create a staging table for data cleaning to preserve original data
CREATE TABLE world_layoffs.layoffs_staging 
LIKE world_layoffs.layoffs;

-- Insert data into staging table
INSERT INTO layoffs_staging 
SELECT * FROM world_layoffs.layoffs;

-- Data Cleaning Steps:
-- 1. Remove duplicates
-- 2. Standardize data and correct inconsistencies
-- 3. Handle null values
-- 4. Remove unnecessary rows and columns

-- Step 1: Identify and remove duplicate rows

-- Retrieve all rows from staging table
SELECT *
FROM world_layoffs.layoffs_staging;

-- Use ROW_NUMBER to identify duplicate rows based on company, industry, total_laid_off, and date
SELECT company, industry, total_laid_off, date,
		ROW_NUMBER() OVER (
			PARTITION BY company, industry, total_laid_off, date) AS row_num
	FROM 
		world_layoffs.layoffs_staging;

-- Check for rows with duplicates
SELECT *
FROM (
	SELECT company, industry, total_laid_off, date,
		ROW_NUMBER() OVER (
			PARTITION BY company, industry, total_laid_off, date
			) AS row_num
	FROM 
		world_layoffs.layoffs_staging
) duplicates
WHERE 
	row_num > 1;

-- Example check for specific company 'Oda' to ensure data accuracy
SELECT *
FROM world_layoffs.layoffs_staging
WHERE company = 'Oda';

-- Further refine duplicate search by expanding to additional columns
SELECT *
FROM (
	SELECT company, location, industry, total_laid_off, percentage_laid_off, date, stage, country, funds_raised_millions,
		ROW_NUMBER() OVER (
			PARTITION BY company, location, industry, total_laid_off, percentage_laid_off, date, stage, country, funds_raised_millions
			) AS row_num
	FROM 
		world_layoffs.layoffs_staging
) duplicates
WHERE 
	row_num > 1;

-- Use a Common Table Expression (CTE) to delete duplicates based on row numbers
WITH DELETE_CTE AS 
(
SELECT *
FROM (
	SELECT company, location, industry, total_laid_off, percentage_laid_off, date, stage, country, funds_raised_millions,
		ROW_NUMBER() OVER (
			PARTITION BY company, location, industry, total_laid_off, percentage_laid_off, date, stage, country, funds_raised_millions
			) AS row_num
	FROM 
		world_layoffs.layoffs_staging
) duplicates
WHERE 
	row_num > 1
)
DELETE
FROM DELETE_CTE;

-- Alternative duplicate removal approach by adding a row number column for tracking
ALTER TABLE world_layoffs.layoffs_staging ADD row_num INT;

-- Create new staging table with row numbers for further deduplication
CREATE TABLE world_layoffs.layoffs_staging2 (
	company TEXT,
	location TEXT,
	industry TEXT,
	total_laid_off INT,
	percentage_laid_off TEXT,
	date TEXT,
	stage TEXT,
	country TEXT,
	funds_raised_millions INT,
	row_num INT
);

-- Populate new staging table with ROW_NUMBER for duplicates identification
INSERT INTO world_layoffs.layoffs_staging2
(company, location, industry, total_laid_off, percentage_laid_off, date, stage, country, funds_raised_millions, row_num)
SELECT company, location, industry, total_laid_off, percentage_laid_off, date, stage, country, funds_raised_millions,
	ROW_NUMBER() OVER (
		PARTITION BY company, location, industry, total_laid_off, percentage_laid_off, date, stage, country, funds_raised_millions
	) AS row_num
FROM 
	world_layoffs.layoffs_staging;

-- Delete rows in new staging table where row_num >= 2
DELETE FROM world_layoffs.layoffs_staging2
WHERE row_num >= 2;

-- Step 2: Standardize Data

-- Check for inconsistent or missing 'industry' entries
SELECT DISTINCT industry
FROM world_layoffs.layoffs_staging2
ORDER BY industry;

-- Identify rows with null or blank 'industry' values
SELECT *
FROM world_layoffs.layoffs_staging2
WHERE industry IS NULL 
OR industry = ''
ORDER BY industry;

-- Set empty strings to NULL for easier handling
UPDATE world_layoffs.layoffs_staging2
SET industry = NULL
WHERE industry = '';

-- Populate null industry values by referencing similar entries
UPDATE layoffs_staging2 t1
JOIN layoffs_staging2 t2
ON t1.company = t2.company
SET t1.industry = t2.industry
WHERE t1.industry IS NULL
AND t2.industry IS NOT NULL;

-- Standardize variations in 'industry' entries, e.g., 'Crypto' variations
UPDATE layoffs_staging2
SET industry = 'Crypto'
WHERE industry IN ('Crypto Currency', 'CryptoCurrency');

-- Standardize country names by removing trailing periods
UPDATE layoffs_staging2
SET country = TRIM(TRAILING '.' FROM country);

-- Convert 'date' column to proper date format and data type
UPDATE layoffs_staging2
SET date = STR_TO_DATE(date, '%m/%d/%Y');

ALTER TABLE layoffs_staging2
MODIFY COLUMN date DATE;

-- Step 3: Handle Null Values

-- Review null values for potential issues, leaving as null for EDA phase
SELECT *
FROM world_layoffs.layoffs_staging2
WHERE total_laid_off IS NULL
AND percentage_laid_off IS NULL;

-- Remove rows with non-informative null values in key columns
DELETE FROM world_layoffs.layoffs_staging2
WHERE total_laid_off IS NULL
AND percentage_laid_off IS NULL;

-- Step 4: Remove unnecessary columns

-- Drop 'row_num' column as it is no longer needed
ALTER TABLE layoffs_staging2
DROP COLUMN row_num;

-- Final result after cleaning
SELECT * 
FROM world_layoffs.layoffs_staging2;
























