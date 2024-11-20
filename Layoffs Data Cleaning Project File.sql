-- DATA CLEANING SQL PROJECT ----------------------------------------------------------------------------------------------------------------------------------------------------

select * from layoffs;

-- Creating a staging table.
-- We will work on staging table to clean the data. We want a table with the raw data without any change made to it.

create table layoff_staging
like layoffs;

select * from layoff_staging;

insert layoff_staging
select * from layoffs;
-- ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- DATA CLEANING STEPS
-- 1. Check for duplicates and remove any

# Check for duplicates using ROW_NUMBER window function
select *,
row_number() over(
partition by company, location, industry,total_laid_off,percentage_laid_off,`date`, stage, country, funds_raised_millions) as row_num
from layoff_staging;

with duplicates as
(
	select *,
	row_number() over(
	partition by company, location, industry,total_laid_off,percentage_laid_off,`date`, stage, country, funds_raised_millions) as row_num
	from layoff_staging
)
select * from duplicates
where row_num > 1;


CREATE TABLE `layoff_staging2` (
  `company` text,
  `location` text,
  `industry` text,
  `total_laid_off` int DEFAULT NULL,
  `percentage_laid_off` text,
  `date` text,
  `stage` text,
  `country` text,
  `funds_raised_millions` int DEFAULT NULL,
  row_num INT
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

INSERT INTO layoff_staging2
	select *,
	row_number() over(
	partition by company, location, industry,total_laid_off,percentage_laid_off,`date`, stage, country, funds_raised_millions) as row_num
	from layoff_staging;

# Delete Duplicates by using with clause, window function and a different staging area
delete from layoff_staging2
where row_num > 1;

select * from layoff_staging2
where row_num > 1;

-- 2. Standardize data and fix errors -------------------------------------------------------------------------------------------------------------------------------------------

select distinct(trim(company)) from layoff_staging2;

update layoff_staging2
set company = trim(company);

# Noticed the Industry Crypto has multiple different variations. We need to standardize that - let's set all to Crypto
select * from layoff_staging2
where industry like 'Crypto%';

update layoff_staging2
set industry = 'Crypto'
where industry like 'Crypto%';

select distinct(industry) from layoff_staging2
order by 1;

# Noticed the Country United States has multiple different variations. We need to standardize that - let's set all to United States
update layoff_staging2
set country = 'United States'
where country like 'United States%';

# Update date coloumn to DATE data type
select `date`,
str_to_date(`date`, '%m/%d/%Y')
from layoff_staging2;

update layoff_staging2
set `date` = str_to_date(`date`, '%m/%d/%Y');

alter table layoff_staging2
modify column `date` DATE;

# Adressing Nul Values
select * from layoff_staging2
where total_laid_off is null
and percentage_laid_off is null;

select * from layoff_staging2
where industry is null or industry = '';

select * from layoff_staging2 t1
join layoff_staging2 t2 on t1.company = t2.company
						and t1.location = t2.location
where (t1.industry is null OR t1.industry = '')
and t2.industry is not null;

update layoff_staging2
set industry = null
where industry = '';

update layoff_staging2 t1
join layoff_staging2 t2 on t1.company = t2.company
set t1.industry = t2.industry
where t1.industry is null
and t2.industry is not null;

select * from layoff_staging2
where company =  'Airbnb';

-- 3. Remove any columns and rows that are not necessary --------------------------------------------------------------------------------------------------------------------------
select * from layoff_staging2
where total_laid_off is null
and percentage_laid_off is null;

delete from layoff_staging2
where total_laid_off is null
and percentage_laid_off is null;

alter table layoff_staging2
drop column row_num;

select * from layoff_staging2;