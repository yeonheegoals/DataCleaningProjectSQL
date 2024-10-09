# DATA CLEANING SQL
Alright, here’s the rundown of what went down in this SQL project on cleaning up a dataset of layoffs in 2022 from Kaggle. The whole process is about getting messy data organized and consistent so we can actually work with it later. Here’s how it went down:

Step 1: Setting Up a Staging Table
First off, we didn’t want to mess with the raw data directly, so we made a copy of it into a new table called layoffs_staging. This is where all the cleaning happens. It’s a good habit to keep the original data untouched, just in case something goes wrong or you need to reference it later.

Step 2: Removing Duplicates
Next up was finding and getting rid of duplicates. We ran a query with ROW_NUMBER() to assign row numbers to each row based on things like company, industry, total_laid_off, and date. Any row with a row number greater than one is a duplicate.

I used a Common Table Expression (CTE) to isolate these duplicates and delete them. I also tried out a method that involves creating a new staging table with an extra row_num column so we can visually check which rows are considered duplicates before deleting.

Step 3: Standardizing Data
Then we tackled standardizing the data. This step involved checking for inconsistencies and making things uniform. For example, the industry column had some terms spelled out differently. So, we replaced all the variations with just "Crypto."

We also found blank values in the industry column and converted them to NULL values, which are generally easier to handle in SQL. Then, I ran a query to fill in these nulls based on other rows that had the same company name but a filled-out industry. It saved a lot of manual checking!

The country column had some minor issues, like "United States" versus "United States." with a period at the end. We used TRIM() to fix that in one shot.

Step 4: Cleaning Up Dates and Handling Nulls
The date column needed some attention, so we converted it from a string to a proper date format using STR_TO_DATE(). This will make it much easier to sort and analyze by date later on.

For columns like total_laid_off, percentage_laid_off, and funds_raised_millions, I decided to keep the null values. These might actually be useful later when we’re exploring the data, as they can indicate missing information that could be meaningful.

Step 5: Dropping Unnecessary Data
Finally, I did a quick check on the rows where total_laid_off and percentage_laid_off were null. Since they don’t really add value and are pretty much useless for our analysis, I went ahead and deleted those rows.

We also removed the row_num column that we added earlier for handling duplicates, as it was just there temporarily to help with the cleanup.

Wrapping Up
Now, we have a clean, consistent dataset in the layoffs_staging2 table. It’s ready to be analyzed without us worrying about duplicates, inconsistent terms, or random blanks in the data. This setup makes it a lot easier to dive into trends and insights, like which industries were hit the hardest or which regions had the most layoffs.

So, that’s the whole process! It’s a great example of how SQL can help whip a messy dataset into shape, step by step.






