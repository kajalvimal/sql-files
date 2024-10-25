
use housingdata;
select * from layoffs;
-- Data Cleaning -----
-- first step make a dupliacte table ---
create table layoffs_staging
like layoffs;

insert layoffs_staging
select * from layoffs;

select * from layoffs_staging;

-- now when we are data cleaning we usually follow a few steps
-- 1. check for duplicates and remove if any
-- 2. standardize data and fix errors
-- 3. Look at null values and see what 
-- 4. remove any columns and rows that are not necessary - few ways

# 1. Checking for duplicates ---
select *,
row_number() over(partition by company, location, industry, total_laid_off, percentage_laid_off, `date`,stage,country,funds_raised_millions ) as copy
 from layoffs_staging;

with duplicate_cte as
(select *,
row_number() over(partition by company, location, industry, total_laid_off, percentage_laid_off, `date`, stage,country,funds_raised_millions) as copy
 from layoffs_staging)
 select * from duplicate_cte
 where copy > 1;

-- check whether the statement is working properly or not --

select * from layoffs_staging
where company = 'casper';

# Removla of duplicates ----

CREATE TABLE `layoffs_staging2` (
  `company` text,
  `location` text,
  `industry` text,
  `total_laid_off` int DEFAULT NULL,
  `percentage_laid_off` text,
  `date` text,
  `stage` text,
  `country` text,
  `funds_raised_millions` int DEFAULT NULL,
  `copy` int
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

insert into layoffs_staging2
 select *,
row_number() over(partition by company, location, industry, total_laid_off, percentage_laid_off, `date`,stage,country,funds_raised_millions ) as copy
 from layoffs_staging;

select * from layoffs_staging2;

select * from layoffs_staging2
where copy >1;

delete  from layoffs_staging2
where copy >1;

SET SQL_SAFE_UPDATES = 0; -- for diable the safe mode for temperary
 
--- standardizing data ----
select distinct(company)
from layoffs_staging2;

select trim(company)
from layoffs_staging2;

update layoffs_staging2
set company = trim(company);

select distinct (industry)
from layoffs_staging2
order by 1; 

select * from layoffs_staging2
where industry like 'crypto %' ;

update layoffs_staging2
set industry = 'crypto'
where industry like 'crypto %';

select distinct (industry)
from layoffs_staging2;

select `date` from layoffs_staging2;


select distinct country, trim(trailing '.' from country)
from layoffs_staging2
order by 1;

update layoffs_staging2
set  country = trim(trailing '.' from country)
where country like 'united states%';

select `date`,
str_to_date(`date`, '%m/%d/%Y')
from layoffs_staging2;

update layoffs_staging2
set `date` = str_to_date(`date`, '%m/%d/%Y');

alter table layoffs_staging2
modify column `date` date;

select `date` from layoffs_staging2;

select `date` ,
date_format(`date`,'%m/%d/%Y' )
from  layoffs_staging2;

-- removing nulls and blank --- populating data
update layoffs_staging2
set industry = null 
where industry = '';

select * from layoffs_staging2
where industry = ''
or industry is null;

 select  * from layoffs_staging2
where company = "Bally's Interactive";

select * 
from  layoffs_staging2 t1
join  layoffs_staging2 t2
  on t1.company = t2.company
 where (t1.industry is null )
 and t2.industry is not null;
 
update layoffs_staging2 t1
join  layoffs_staging2 t2
 on t1.company = t2.company
  set t1.industry = t2.industry
   where (t1.industry is null )
 and t2.industry is not null;
 
 delete from  layoffs_staging2
 where total_laid_off is null
 and percentage_laid_off is null;
 
 delete from layoffs_staging2 
 where company = "Bally's Interactive";
 
alter table layoffs_staging2
  drop column copy;
 
 alter table layoffs_staging2
 add column copy int;
 
 select * from layoffs_staging2
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 