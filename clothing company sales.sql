SELECT * FROM clothing_company.sales;
-- What was the total quantity sold for all products?
select * from product_details;
select sum(s.qty)
from sales as s	
join product_details  as pd on s.product_id = pd.product_id;
 

select sum(s.price), pd.product_name
from sales as s	
join product_details  as pd on s.product_id = pd.product_id
group by pd.product_name ;

-- What is the total generated revenue for all products before discounts?
select * from sales;
select (1-discount*0.01)  as total_discount  from sales
join product_details on sales.product_id = product_details.product_id ;

select sum((s.qty*s.price)*(1-s.discount*0.01)) as original_price from sales as s
join product_details  as pd on s.product_id=pd.product_id ;

select sum(s.qty*s.price) as original_price from sales as s
join product_details  as pd on s.product_id=pd.product_id ;


-- What was the total discount amount for all products?
select round(sum(discount*(qty*price)/100),2) as total_discount  from sales as s
join product_details  as pd on s.product_id=pd.product_id ;

-- -- Transaction Analysis------------------------------------
-- How many unique transactions were there?
select * from sales;
select count(distinct(txn_id)) as unique_txn_id from sales;

-- What is the average unique products purchased in each transaction?
select distinct product_id, sum(price)
over(partition by product_id)
from sales
order by 2 desc;
select distinct product_id, sum(price)
from sales
group by product_id
order by 2 desc;

select avg(avg_product_sold) as avg_unique_prdu_sold from
(select distinct txn_id, count(product_id)
over(partition by txn_id) as avg_product_sold 
from sales) s ;

select sum(product_id)/count(txn_id)
from  sales;

-- What are the 25th, 50th and 75th percentile values for the revenue per transaction?
select sum(qty*price) as total_revenue from sales;

select distinct txn_id, sum(qty*price) as transaction_revenue
from sales
group by 1;

with percentile as
(select distinct txn_id, sum(qty*price) as transaction_revenue
from sales
group by 1)
select percentile_cont(0.25) within group (order by transaction_revenue) as percentile_25;

select   distinct
percentile_cont (0.25) within group (order by ((qty*price)*(1-discount*0.01)))over(partition by txn_id) as percentile_25,
percentile_cont (0.5) within group (order by ((qty*price)*(1-discount*0.01)))over(partition by txn_id) as percentile_50,
percentile_cont (0.75) within group (order by ((qty*price)*(1-discount*0.01)))over(partition by txn_id) as percentile_75
from sales;

SELECT percentile_cont(0.25) WITHIN GROUP (ORDER BY transaction_revenue) AS revenue_25percentile,
       percentile_cont(0.5) WITHIN GROUP (ORDER BY transaction_revenue) AS revenue_50percentile,
       percentile_cont(0.75) WITHIN GROUP (ORDER BY transaction_revenue) AS revenue_75percentile
FROM sales;

-- What is the average discount value per transaction?
select  avg(sum(discount*(qty*price)/100))  as avg_revenue
from sales;
select round(sum(discount*(qty*price)/100),2) as total_discount  from sales;
with trans as
(select txn_id, (sum(discount*(qty*price)/100))  as revenue
from sales)
select avg(revenue) over(partition by txn_id)from trans;

select avg(avg_product_sold) as avg_unique_prdu_sold from
(select distinct txn_id, count(product_id)
over(partition by txn_id) as avg_product_sold 
from sales) s;

-- creating a duplicate table for data wrangling.
create table sales_staging as (select *from sales);

alter table sales_staging
add column 
month_name text;

UPDATE sales_staging SET month_name = TO_CHAR(start_txn_time::date, 'Month');

alter table sales_staging
add column 
month int;
update sales_staging set month = extract(month from start_txn_time);
select * from sales_staging;

select start_txn_time,
extract(month from start_txn_time)as sales_month
from sales_staging;  

SELECT start_txn_time, TO_CHAR(start_txn_time::date, 'Month') AS month_name
from sales;

SELECT start_txn_time, TO_CHAR(start_txn_time::date, 'day') AS day_name
from sales;

-- Reporting Challenge
Write a single SQL script that combines all of the previous questions into a scheduled 
report that the Balanced Tree team can run at the beginning of each month to calculate the previous month’s values.

Imagine that the Chief Financial Officer has asked for all of these questions at the end of every month.

He first wants you to generate the data for January only - but then he also wants you to demonstrate 
that you can easily run the samne analysis for February without many changes (if at all).

Feel free to split up your final outputs into as many tables as you need - but be sure to 
explicitly reference which table outputs relate to which question for full marks :)

select month_name,
category_name,segment_name,s.product_id,p.product_name,
sum(qty) as sold,sum((qty*s.price)*(1-discount*0.01)) as Revenues_before_discount,
round(sum((discount*(qty*s.price)/100.0)),2) as Total_Discount,
round(sum((qty*s.price)*(1-discount*0.01)) *100.0/ (select sum((qty*price)*(1-discount*0.01)) from sales),2) as revenue_prcnt,
round(count(distinct txn_id)*100.0/(select count(distinct txn_id) from sales ),2) as penetration,
 round(sum(case when member_type='t' then 1 else 0 end)*100.0/count(*),2) as member_transaction,
round(sum(case when member_type='f' then 1 else 0 end)*100.0/count(*),2) as non_member_transaction,
round(avg(case when member_type='t' then (qty*s.price)*(1-discount*0.01) end),2) as avg_revenue_member,
round(avg(case when member_type='f' then (qty*s.price)*(1-discount*0.01) end),2) as avg_revenue_non_member
from sales_staging s join product_details p 
on s.product_id=p.product_id
where extract(month from start_txn_time)  = 2
group by month_name,category_name,segment_name,s.product_id,p.product_name
order by 1,2,6 desc;




























