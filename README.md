# DATA CLEANING SQL
This SQL project focuses on data cleaning for a dataset of global layoffs from 2022, sourced from Kaggle. The process includes several key steps aimed at preparing the dataset for analysis. Here’s a summary of the approach and methodology:

1. Setting Up the Environment
The first step is to create a staging table (layoffs_staging) from the original data table (layoffs). This staging table is used to perform all cleaning tasks, keeping the original data intact.
2. Removing Duplicates
The process begins by identifying and removing duplicate rows. This is done by using the ROW_NUMBER() function to partition data based on multiple columns (e.g., company, industry, total_laid_off, and date), assigning row numbers to each partition.
Rows with a row number greater than one within a partition are considered duplicates and are removed. A Common Table Expression (CTE) is employed to simplify this process and streamline deletion.
An alternative method involves creating a new staging table (layoffs_staging2) with an additional row_num column to facilitate identifying and removing duplicate rows.
3. Standardizing Data
After handling duplicates, the next step is data standardization. This involves ensuring consistency within key columns such as industry and country.
Inconsistencies within the industry column are addressed by replacing different variations of terms, such as "Crypto Currency" and "CryptoCurrency," with a single standard term "Crypto."
Any blank values in the industry column are converted to NULL for easier handling, and efforts are made to fill these NULL values by referencing other rows with matching company names.
Similarly, minor variations in the country column (like “United States” and “United States.”) are corrected using string functions.
4. Handling Dates and Null Values
The date column is reformatted from string to date format (DATE) using STR_TO_DATE(), enabling consistent date handling for subsequent analysis.
The total_laid_off, percentage_laid_off, and funds_raised_millions columns are examined for null values. The decision is made to retain nulls here, as they might provide useful insights during exploratory data analysis (EDA).
5. Removing Unnecessary Data
Rows with null values in critical columns, such as total_laid_off and percentage_laid_off, which do not contribute meaningful information, are deleted.
Finally, the row_num column, initially added for managing duplicates, is removed as it is no longer necessary.
