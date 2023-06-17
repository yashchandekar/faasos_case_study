create database faasos_project;
use faasos_project;


CREATE TABLE driver(driver_id integer,reg_date date); 

INSERT INTO driver(driver_id,reg_date) 
 VALUES (1,'01-01-2021'),
(2,'01-03-2021'),
(3,'01-08-2021'),
(4,'01-15-2021');


drop table if exists ingredients;
CREATE TABLE ingredients(ingredients_id integer,ingredients_name varchar(60)); 

INSERT INTO ingredients(ingredients_id ,ingredients_name) 
 VALUES (1,'BBQ Chicken'),
(2,'Chilli Sauce'),
(3,'Chicken'),
(4,'Cheese'),
(5,'Kebab'),
(6,'Mushrooms'),
(7,'Onions'),
(8,'Egg'),
(9,'Peppers'),
(10,'schezwan sauce'),
(11,'Tomatoes'),
(12,'Tomato Sauce');

drop table if exists rolls;
CREATE TABLE rolls(roll_id integer,roll_name varchar(30)); 

INSERT INTO rolls(roll_id ,roll_name) 
 VALUES (1	,'Non Veg Roll'),
(2	,'Veg Roll');

drop table if exists rolls_recipes;
CREATE TABLE rolls_recipes(roll_id integer,ingredients varchar(24)); 

INSERT INTO rolls_recipes(roll_id ,ingredients) 
 VALUES (1,'1,2,3,4,5,6,8,10'),
(2,'4,6,7,9,11,12');

drop table if exists driver_order;
CREATE TABLE driver_order(order_id integer,driver_id integer,pickup_time datetime,distance VARCHAR(7),duration VARCHAR(10),cancellation VARCHAR(23));
INSERT INTO driver_order(order_id,driver_id,pickup_time,distance,duration,cancellation) 
 VALUES(1,1,'01-01-2021 18:15:34','20km','32 minutes',''),
(2,1,'01-01-2021 19:10:54','20km','27 minutes',''),
(3,1,'01-03-2021 00:12:37','13.4km','20 mins','NaN'),
(4,2,'01-04-2021 13:53:03','23.4','40','NaN'),
(5,3,'01-08-2021 21:10:57','10','15','NaN'),
(6,3,null,null,null,'Cancellation'),
(7,2,'01-08-2021 21:30:45','25km','25mins',null),
(8,2,'01-10-2021 00:15:02','23.4 km','15 minute',null),
(9,2,null,null,null,'Customer Cancellation'),
(10,1,'01-11-2021 18:50:20','10km','10minutes',null);
truncate table driver_order;

drop table if exists customer_orders;
CREATE TABLE customer_orders(order_id integer,customer_id integer,roll_id integer,not_include_items VARCHAR(4),extra_items_included VARCHAR(4),order_date datetime);
INSERT INTO customer_orders(order_id,customer_id,roll_id,not_include_items,extra_items_included,order_date)
values (1,101,1,'','','01-01-2021  18:05:02'),
(2,101,1,'','','01-01-2021 19:00:52'),
(3,102,1,'','','01-02-2021 23:51:23'),
(3,102,2,'','NaN','01-02-2021 23:51:23'),
(4,103,1,'4','','01-04-2021 13:23:46'),
(4,103,1,'4','','01-04-2021 13:23:46'),
(4,103,2,'4','','01-04-2021 13:23:46'),
(5,104,1,null,'1','01-08-2021 21:00:29'),
(6,101,2,null,null,'01-08-2021 21:03:13'),
(7,105,2,null,'1','01-08-2021 21:20:29'),
(8,102,1,null,null,'01-09-2021 23:54:33'),
(9,103,1,'4','1,5','01-10-2021 11:22:59'),
(10,104,1,null,null,'01-11-2021 18:34:49'),
(10,104,1,'2,6','1,4','01-11-2021 18:34:49');

select * from customer_orders;
select * from driver_order;
select * from ingredients;
select * from driver;
select * from rolls;
select * from rolls_recipes;


-- questions

select * from customer_orders;
select count(roll_id) from customer_orders;

-- how many rolls were ordered
select count(roll_id) as no_of_roll_ord from customer_orders;


-- how many unique customer orders were made
select count(distinct customer_id) as unique_cus_order from customer_orders;

-- how many succesful orders were delivered by each driver


select driver_id,count(order_id) succesful_orders from driver_order where cancellation not in ('Cancellation','Customer Cancellation') group by driver_id;

-- how many of each type of roll were delivered

select * from customer_orders;
select * from driver_order;
select * from rolls;



with cte as 
(select * from 
(select *,case when cancellation in ('Cancellation','Customer Cancellation') then 1 else 0 end as n_can from driver_order) x where n_can=0)
select c.roll_id,roll_name,count(c.roll_id) as roll_count from cte d
inner join customer_orders c 
on d.order_id=c.order_id
inner join rolls r
on r.roll_id=c.roll_id
group by c.roll_id,roll_name;


 -- how many veg and nonveg rolls were ordered by each customer;

 select * from customer_orders;

 select c.customer_id,c.roll_id,r.roll_name,count(c.roll_id) as roll_count from customer_orders c
 inner join rolls r
 on c.roll_id=r.roll_id
 group by c.customer_id,c.roll_id,r.roll_name;


 -- what was maximum no of roll delivered in single order

 select * from customer_orders;
 select * from driver_order;


select * from driver_order;

with cte as 
(select * from
(select *,case when cancellation in ('Cancellation','Customer Cancellation') then 1 else 0 end as cancellation2 from driver_order) x
where cancellation2=0)
select  c2.order_id,count(roll_id) no_of_rolls from cte c1
inner join customer_orders c2
on c1.order_id=c2.order_id
group by c2.order_id
order by no_of_rolls desc;


select * from customer_orders;
select * from driver_order;

-- for each customer, how many delivered rolls had atleast 1 change and how many has no changes
select * from customer_orders;

with cte1 as 
(select *,case when not_include_items=' ' or not_include_items is null then '0' else not_include_items end as n_i_i,
case when extra_items_included=' ' or extra_items_included is null or extra_items_included = 'NaN' then '0' else extra_items_included end as e_i_i from customer_orders),
cte2 as 
(select * from
(select *,case when cancellation in ('Cancellation','Customer Cancellation') then 1 else 0 end as cancellation2 from driver_order) x
where cancellation2=0),
cte3 as
(select cte2.order_id,customer_id,roll_id,n_i_i,e_i_i from cte1 inner join cte2 on cte1.order_id=cte2.order_id),
cte4 as
(select *,case when n_i_i='0' and e_i_i='0' then 'No change' else 'at least one change' end as changes from cte3 )
select customer_id,changes,count(changes) from cte4 group by customer_id,changes;


with cte as 
(select * from
(select order_id,driver_id,case when cancellation  in ('Cancellation','Customer Cancellation') then 1 else 0 end as n_cancellation from driver_order) x
where n_cancellation=0),
cte2 as
(select order_id,customer_id,roll_id,case when not_include_items=' ' or not_include_items is null then '0' else not_include_items end as n_n_i_i,
case when extra_items_included=' ' or extra_items_included is null or extra_items_included='NaN' then '0' else extra_items_included end as n_e_i_i
from customer_orders),
cte3 as 
(select customer_id,case when n_n_i_i='0' and n_e_i_i='0' then 'no change' else 'change' end as changes from cte 
inner join cte2
on cte.order_id=cte2.order_id)
select *,COUNT(changes) as change_count from cte3 
group by customer_id,changes;


-- how many orders were delivered that had both exclusion and extras; 

select * from customer_orders;
select * from driver_order;



with cte1 as 
(select order_id,customer_id,roll_id,
case when not_include_items is null or not_include_items=' ' then '0' else not_include_items end as n_not_include_items,
case when extra_items_included is null or extra_items_included='NaN' or extra_items_included=' ' then '0' else extra_items_included end as n_extra_items_included
from customer_orders),
cte2 as
(select * from 
(select order_id,driver_id,case when cancellation='Cancellation' or cancellation='Customer Cancellation' then 1 else 0 end as n_cancellation from driver_order) x where n_cancellation=0),
cte3 as 
(select cte1.order_id,customer_id,roll_id,n_not_include_items,n_extra_items_included,
case when  n_not_include_items!='0' and n_extra_items_included!='0' then 'both exc and ext' else 'either 1 exc and ext' end as 'whether_both_or_either'
from cte1 
inner join cte2 
on cte1.order_id=cte2.order_id)
select whether_both_or_either,count(*) as no_of_orders from cte3 group by whether_both_or_either;


-- what was the total no of rolls ordered for each hour of day

select datepart(hour,order_date) as hr,count(roll_id) from customer_orders group by datepart(hour,order_date) ;

select concat(datepart(hour,order_date),'-',datepart(hour,order_date)+1)  as hrs,count(roll_id) as no_of_rolls from customer_orders group by concat(datepart(hour,order_date),'-',datepart(hour,order_date)+1);

-- what was the no of orders for each day of the week
select * from customer_orders;
select datename(WEEKDAY,order_date) as day_of_week,count(distinct order_id) no_of_orders from customer_orders group by  datename(WEEKDAY,order_date);

select DATEname(WEEKDAY,order_date) as daynme,count(distinct order_id) as no_of_rolls from customer_orders group by DATEname(WEEKDAY,order_date) ;


-- what is the average time in minutes   it took for each driver to arrive at faasos hq to pickup order;

SELECT * from customer_orders;


with cte as  
(select * from 
(select *,ROW_NUMBER() over(partition by order_id order by customer_id) as rn from customer_orders) x where rn=1),
cte2 as 
(select cte.order_id,driver_id,order_date,pickup_time,DATEDIFF(minute,order_date,pickup_time) as timediff from cte inner join driver_order on cte.order_id=driver_order.order_id where pickup_time is not null)
select driver_id,avg(timediff) avg_time_req from cte2 group by driver_id;


select driver_id,sum(time_req)/count(distinct order_id) as avg_time_req from (
select *,row_number() over(partition by order_id order by time_req) as rn from
(select c.order_id,customer_id,roll_id,driver_id,order_date,pickup_time,DATEDIFF(MINUTE,order_date,pickup_time) as time_req from customer_orders c
inner join driver_order d
on c.order_id=d.order_id
where pickup_time is not null) x) y
where rn=1
group by driver_id;


-- what was avg distance travelled for each customer
with cte as 
(select customer_id,c.order_id,cast(REPLACE(distance,'km','') as float) as distance,row_number() over(partition by customer_id order by c.order_id) as rn from driver_order d
inner join customer_orders c on d.order_id=c.order_id where distance is not null)
select customer_id,avg(distance) from cte where rn=1 group by customer_id order by customer_id ;




with cte as
(select c.order_id,d.driver_id,roll_id,customer_id,replace(distance,'km','') n_dis from driver_order d
inner join customer_orders c 
on d.order_id=c.order_id)
select *,dense_rank() over (partition by customer_id order by order_id) as rn  from cte where n_dis is not null;


with cte as
(select c.order_id,d.driver_id,roll_id,customer_id,replace(distance,'km','') n_dis from driver_order d
inner join customer_orders c 
on d.order_id=c.order_id),
cte2 as
(select *,ROW_NUMBER() over (partition by customer_id order by order_id) as rn  from cte where n_dis is not null)
select * from cte2 where rn=1;

with cte as
(select c.order_id,d.driver_id,roll_id,customer_id,replace(distance,'km','') n_dis from driver_order d
inner join customer_orders c 
on d.order_id=c.order_id)
select customer_id,avg(cast(n_dis as float)) from cte where n_dis is not null
group by customer_id,order_id;


-- what was the diffrence between shortlest and the longest delivery for all orders;

with cte as 
(select *,left(duration,2) as n_duration from driver_order),
cte2 AS
(select * from cte where n_duration is not null)
select cast(max(n_duration) as int)- cast(min(n_duration)as int) delivery_diff from cte2;

 
select *,cast(case when duration like '%min%' then left(duration,CHARINDEX('m',duration)-1) else duration end as int) as n_duration from driver_order where duration is not null;
with cte as 
(select *,cast(case when duration like '%min%' then left(duration,CHARINDEX('m',duration)-1) else duration end as int) as n_duration from driver_order where duration is not null)
select max(n_duration)-min(n_duration) as del_diff from cte;

--what was the average speed for each driver  for each delivery and do you notice any trend
with cte as 
(select order_id,driver_id,cast(trim(replace(lower(distance),'km','')) as decimal(4,2)) as n_distance ,
cast(case when duration like '%min%' then left(duration,CHARINDEX('m',duration)-1) else duration end as int) as n_duration 
from driver_order where duration is not null)
select driver_Id,order_id,avg(n_distance/n_duration) from cte
group by driver_Id,order_id;

