-- SQL Project - Data Cleaning on Layoffs Dataset
-- Dataset Source: https://www.kaggle.com/datasets/swaptr/layoffs-2022

-- 1. Load Raw Data for Review
SELECT * 
FROM world_layoffs.layoffs;

-- 2. Create a Staging Table for Data Cleaning
-- This ensures we keep the raw data intact for reference.
CREATE TABLE world_layoffs.layoffs_staging 
LIKE world_layoffs.layoffs;

INSERT INTO world_layoffs.layoffs_staging 
SELECT * FROM world_layoffs.layoffs;

-- ---------------------------------------------------
-- Step 1: Remove Duplicates
-- ---------------------------------------------------

-- Check for Duplicates by Identifying Rows with Similar Key Columns
SELECT company, industry, total_laid_off, `date`,
    ROW_NUMBER() OVER (
        PARTITION BY company, industry, total_laid_off, `date`
    ) AS row_num
FROM world_layoffs.layoffs_staging;

-- Filter Out Duplicate Rows Based on Identified Patterns
SELECT *
FROM (
    SELECT company, location, industry, total_laid_off, percentage_laid_off, `date`, stage, country, funds_raised_millions,
        ROW_NUMBER() OVER (
            PARTITION BY company, location, industry, total_laid_off, percentage_laid_off, `date`, stage, country, funds_raised_millions
        ) AS row_num
    FROM world_layoffs.layoffs_staging
) duplicates
WHERE row_num > 1;

-- Delete Duplicate Records While Keeping One Copy
WITH DELETE_CTE AS (
    SELECT company, location, industry, total_laid_off, percentage_laid_off, `date`, stage, country, funds_raised_millions, 
        ROW_NUMBER() OVER (
            PARTITION BY company, location, industry, total_laid_off, percentage_laid_off, `date`, stage, country, funds_raised_millions
        ) AS row_num
    FROM world_layoffs.layoffs_staging
)
DELETE FROM world_layoffs.layoffs_staging
WHERE (company, location, industry, total_laid_off, percentage_laid_off, `date`, stage, country, funds_raised_millions, row_num) IN (
    SELECT company, location, industry, total_laid_off, percentage_laid_off, `date`, stage, country, funds_raised_millions, row_num
    FROM DELETE_CTE
) AND row_num > 1;

-- ---------------------------------------------------
-- Step 2: Standardize Data
-- ---------------------------------------------------

-- Standardize the Industry Column: Replace Blank Values with NULL
UPDATE world_layoffs.layoffs_staging2
SET industry = NULL
WHERE industry = '';

-- Populate Null Industry Fields Based on Other Rows of the Same Company
UPDATE world_layoffs.layoffs_staging2 t1
JOIN world_layoffs.layoffs_staging2 t2
ON t1.company = t2.company
SET t1.industry = t2.industry
WHERE t1.industry IS NULL AND t2.industry IS NOT NULL;

-- Standardize Variants of the 'Crypto' Industry to a Single Term
UPDATE world_layoffs.layoffs_staging2
SET industry = 'Crypto'
WHERE industry IN ('Crypto Currency', 'CryptoCurrency');

-- Standardize Country Names: Remove Trailing Period in 'United States.'
UPDATE world_layoffs.layoffs_staging2
SET country = TRIM(TRAILING '.' FROM country);

-- Convert 'date' Column from Text to Date Format
UPDATE world_layoffs.layoffs_staging2
SET `date` = STR_TO_DATE(`date`, '%m/%d/%Y');

-- Alter 'date' Column to Proper DATE Data Type
ALTER TABLE world_layoffs.layoffs_staging2
MODIFY COLUMN `date` DATE;

-- ---------------------------------------------------
-- Step 3: Review and Handle Null Values
-- ---------------------------------------------------

-- Review Null Values in Key Columns: `total_laid_off`, `percentage_laid_off`, and `funds_raised_millions`
SELECT *
FROM world_layoffs.layoffs_staging2
WHERE total_laid_off IS NULL;

-- Remove Rows with Both 'total_laid_off' and 'percentage_laid_off' as Null (Non-useful Data)
DELETE FROM world_layoffs.layoffs_staging2
WHERE total_laid_off IS NULL AND percentage_laid_off IS NULL;

-- ---------------------------------------------------
-- Step 4: Final Data Cleanup and Remove Temporary Columns
-- ---------------------------------------------------

-- Remove the Temporary 'row_num' Column Now that Duplicates Have Been Handled
ALTER TABLE world_layoffs.layoffs_staging2
DROP COLUMN row_num;

-- Final Verification of Cleaned Data
SELECT * 
FROM world_layoffs.layoffs_staging2;



























