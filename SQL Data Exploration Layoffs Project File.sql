-- DATA EXPLORATION PROJECT

-- Max number of people laid off in a single day.

select max(total_laid_off), max(percentage_laid_off) from layoff_staging2;

-- Companies that laid off everyone and shut down

select * from layoff_staging2
where percentage_laid_off =1 
order by company;

-- Highest to Lowest number of people laid off from companies

select company, SUM(total_laid_off)
from layoff_staging2
group by company
order by 2 desc;

-- Highest to Lowest number of people laid off from companies
select industry, SUM(total_laid_off)
from layoff_staging2
group by industry
order by 2 desc;

-- Highest to Lowest number of people laid off from country
select country, SUM(total_laid_off)
from layoff_staging2
group by country
order by 2 desc;

-- Number of people laid off w.r.t year
select YEAR(date), sum(total_laid_off) from layoff_staging2
group by YEAR(date)
order by sum(total_laid_off) desc;

-- Companies with the biggest single Layoff
SELECT company, total_laid_off
FROM layoff_staging2
ORDER BY 2 DESC
LIMIT 5;

-- Top 5 companies that laid off every year
with company_year(company,years,total_laid_off) as
(
select company, year(`date`), sum(total_laid_off)
from layoff_staging2
group by company, year(`date`)
),
company_year_rank as
(select *,
dense_rank () over(partition by years order by total_laid_off desc) as ranking
from company_year
where years is not null
order by ranking asc)
select * from company_year_rank
where ranking <= 5
order by years;

-- Rolling Total
with rolling_total as
(
 select substring(`date`,1,7) as `month`, sum(total_laid_off) as total_laidoff
 from layoff_staging2
 where substring(`date`,1,7) is not null
 group by `month`
 order by 1 asc
 )
select `month`, total_laidoff, sum(total_laidoff) over(order by `month`) as rolling_tot
from rolling_total;