select * from subscriptions;
select * from plans;

select sub.customer_id, pan.plan_name, sub.start_date
from subscriptions as sub
join plans as pan
on sub.plan_id = pan.plan_id;

 SELECT *, RANK() OVER(PARTITION BY customer_id ORDER BY start_date)
  FROM subscriptions;
  
--  How many customers has Foodie-Fi ever had? -- 
 select count(distinct customer_id)
  from subscriptions;
  
-- What is the monthly distribution of trial plan start_date values for our dataset - use the start of the month as the group by value --  
  select extract(MONTH from start_date) as start_month
  from subscriptions
 where plan_id = 0
 group by start_month
 order by start_month;
 
  select extract(MONTH from start_date) as start_month,
 count(start_date) as order_count
  from subscriptions
 where plan_id = 0
 group by start_month
 order by start_month;
 
 select extract(MONTH from start_date) as start_month,
 extract(year from start_date) as start_year,
 count(start_date) as order_count
  from subscriptions
 where plan_id = 0
 group by start_month,start_year
 order by start_month,start_year;
 
-- What plan start_date values occur after the year 2020 for our dataset? Show the breakdown by count of events for each plan_name
select pan.plan_name, pan.plan_id, 
count(sub.plan_id) 
from subscriptions as sub
join plans as pan
on sub.plan_id = pan.plan_id
group by pan.plan_name, pan.plan_id;

select pan.plan_id, pan.plan_name,
count(*) from subscriptions as sub
join plans as pan 
on sub.plan_id = pan.plan_id
where start_date >= '2021-01-01'
group by pan.plan_id, pan.plan_name
order by plan_id;


-- What is the customer count and percentage of customers who have churned rounded to 1 decimal place

select * from plans;

select count(customer_id) churn_count,
round(count(customer_id) / count(*) over(), 1)  as percentage_of_churn 
from subscriptions
where plan_id = 4;

select count(*),
round(count(customer_id) / count(*) over(), 1) 
from subscriptions;

select customer_id,
count(customer_id) churn_count,
round(count(customer_id) / count(*) over(), 1)  as percentage_of_churn
from subscriptions
where plan_id = 4
group by customer_id;

--	How many customers have churned straight after their initial free trial - what percentage is this rounded to the nearest whole number?
select * from subscriptions;
select * from plans;

select
round(count(customer_id) / count(*) over()) as percentage_of_churn
from subscriptions;

select *,
lag(plan_id,1) over(partition by customer_id) as prev_plan
from subscriptions;

 with chun_cte
  as (select customer_id, plan_id,
		row_number() over(partition by customer_id) as rn 
		from subscriptions
        ) 
        select count(customer_id)  as intitial_churn,
         count(customer_id) /count(*) over () as per_initial_churn
        from chun_cte
    where plan_id = 4 and rn = 2;

with churn_cte
as (
select * ,
lag(plan_id,1) over(partition by customer_id) as prev_plan
from subscriptions)
select prev_plan,
count(*) as num_cust,
count(*) * 100 / (select count(distinct customer_id)from subscriptions) as perc_of_churn_initial
from churn_cte
where prev_plan = 1 and plan_id = 0
group by prev_plan
order by prev_plan;

--	What is the customer count and percentage breakdown of all 5 plan_name values at 2020-12-31?
select s.plan_id, p.plan_name, count(customer_id) as count_cust,
round(count(customer_id)/ count(*) over())as per_cust
from subscriptions s
join plans p
on s.plan_id = p.plan_id
where s.start_date >= '2020-12-31'
group by  s.plan_id, p.plan_name
order by plan_id ;

select count(customer_id) as intitial_churn
from
       (select *,
		row_number() over(partition by customer_id) as rn 
		from	subscriptions) x
       where plan_id = 4 and rn = 2; 
	
-- How many customers have upgraded to an annual plan in 2020?
select count(customer_id)
from subscriptions 
where plan_id = 3 and start_date <= '2020-12-31';

--	How many days on average does it take for a customer to an annual plan from the day they join Foodie-Fi?
--	Can you further breakdown this average value into 30 day periods (i.e. 0-30 days, 31-60 days etc)

--	How many customers downgraded from a pro monthly to a basic monthly plan in 2020?
select * from plans;
select * from subscriptions;

select * ,
row_number () over (partition by customer_id) as rn
from subscriptions
where plan_id =1 or plan_id =2 ;

select * ,
lead (plan_id,1) over (partition by customer_id) as ld
from subscriptions;

--	What is the customer count and percentage breakdown of all 5 plan_name values at 2020-12-31?

select s.plan_id, p.plan_name, count(customer_id) as count_cust,
round(count(customer_id)/ count(*) over())as per_cust
from subscriptions s
join plans p
on s.plan_id = p.plan_id
where s.start_date >= '2020-12-31'
group by  s.plan_id, p.plan_name
order by plan_id ;
 select *,
 row_number() over(partition by customer_id)
 from subscriptions;
 
 select plan_id,count(customer_id),
 count(customer_id)/count(*) over() as per
 from subscriptions
 where start_date < '2020-12-31'
 group by plan_id
 ;
 
 use foodie_fi;
 
 -- What is the number and percentage of customer plans after their initial free trial
 select count(customer_id) cust_count, plan_id,
 count(customer_id) / count(*) over() as per,
( 
 select *,
 row_number() over(partition by customer_id) rn
 from subscriptions
 )
 where rn <> 1;
 
 with cust_cte  as
(
select plan_id, customer_id, 
row_number() over(partition by customer_id) as rn
 from subscriptions
 )
   select count(customer_id) as initial_churn
   from cust_cte
   where plan_id = 4 and rn = 2;
  

with cust_cte2 as
   (select  plan_id,count(customer_id), 
   count(customer_id)/count(*) over() as Per
   from subscriptions
   group by  plan_id
   order by plan_id)
select plan_id ,per from cust_cte2;

select * from subscriptions;
select plan_id, count(2)
from subscriptions
group by plan_id;

--	How many customers have churned straight after their initial free trial - what percentage is this rounded to the nearest whole number?

with Percentage (plan_id, per_per_plan) as
   (select  plan_id, 
   count(customer_id)/count(*) over() as Per
   from subscriptions
   group by  plan_id
   order by plan_id),
row_no_of_cust (plan_id, row_no) as
    (select customer_id, plan_id,
     row_number() over(partition by customer_id) as rn
     from subscriptions)
 select * from Percentage ;

with cust_cte  as
(
	select plan_id, customer_id, 
	row_number() over(partition by customer_id) as rn,
	(plan_id/ customer_id) * 100 as per
	 from subscriptions
 )
   select count(customer_id) as initial_churn
   from cust_cte
   where plan_id = 4 and rn = 2;
   
   --	How many days on average does it take for a customer to an annual plan from the day they join Foodie-Fi?
select * from subscriptions;
select count(start_date)
from subscriptions;

select extract(day from start_date) as start_month
  from subscriptions;
