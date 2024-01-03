ALTER TABLE customers
modify column customer_id varchar(20);

ALTER TABLE customers
ADD PRIMARY KEY (customer_id);

ALTER TABLE orders
modify column customer_name varchar(20);

ALTER TABLE pizzas
ADD PRIMARY KEY (pizza_id);

ALTER TABLE orders 
ADD FOREIGN KEY (customer_id) 
REFERENCES customers (customer_id); 

ALTER TABLE orders 
ADD FOREIGN KEY (pizza_id) 
REFERENCES pizzas (pizza_id);

--------------------------------------------------------------------------------------------------------
#converting dates into weekday names to create a new column 'weekday'

SELECT WEEKDAY("2017-01-03");

SELECT order_date, DAYNAME(order_date) FROM orders;


with cte as
(SELECT order_date, date(concat(SUBSTRING(order_date,7,4),'-',SUBSTRING(order_date,4,2),'-',SUBSTRING(order_date,1,2))) AS SERVICE_DATE
FROM orders
)
SELECT order_date, WEEKDAY(SERVICE_DATE)
FROM CTE;

alter table orders
add column SERVICE_DATE date; #SERVICE date is a new column with dates in the order of yyyy-mm-dd

update orders set SERVICE_DATE = date(concat(SUBSTRING(order_date,7,4),'-',SUBSTRING(order_date,4,2),'-',SUBSTRING(order_date,1,2)));

SELECT WEEKDAY(SERVICE_DATE)
from orders; #this code gives dates in weekday numbers

SELECT SERVICE_DATE,
(CASE WHEN WEEKDAY(SERVICE_DATE) = '0' THEN 'Monday'
    WHEN WEEKDAY(SERVICE_DATE) = '1' THEN 'Tuesday'
    WHEN WEEKDAY(SERVICE_DATE) = '2' THEN 'Wednesday'
    WHEN WEEKDAY(SERVICE_DATE) = '3' THEN 'Thursday'
    WHEN WEEKDAY(SERVICE_DATE) = '4' THEN 'Friday'
    WHEN WEEKDAY(SERVICE_DATE) = '5' THEN 'Saturday'
    WHEN WEEKDAY(SERVICE_DATE) = '6' THEN 'Sunday'
    ELSE 'other'
END) AS weekday
FROM orders; #this code gives weekday name

alter table orders
add column weekday char(15);

update orders set weekday = (CASE WHEN WEEKDAY(SERVICE_DATE) = '0' THEN 'Monday'
    WHEN WEEKDAY(SERVICE_DATE) = '1' THEN 'Tuesday'
    WHEN WEEKDAY(SERVICE_DATE) = '2' THEN 'Wednesday'
    WHEN WEEKDAY(SERVICE_DATE) = '3' THEN 'Thursday'
    WHEN WEEKDAY(SERVICE_DATE) = '4' THEN 'Friday'
    WHEN WEEKDAY(SERVICE_DATE) = '5' THEN 'Saturday'
    WHEN WEEKDAY(SERVICE_DATE) = '6' THEN 'Sunday'
    ELSE 'other'
END);

select weekday
from orders; #we now created a new column to show wweekday names
--------------------------------------------------------------------------------------------------------

## To check which hour in a day is busiest
select hour(order_time) as hr_time, count(hour(order_time)) as count
from orders
group by 1
order by 1 ;

alter table orders
add column hours int;

update orders set hours = hour(order_time);

select * from orders;
--------------------------------------------------------------------------------------------------------

##average order values as grand_total 
select distinct *, sum(total_price) over (partition by order_id order by null) as grand_total
from orders
order by 1;

with cte as
(SELECT order_id, sum(total_price) as order_total
FROM orders
group by 1
)
update orders a set grand_total = (select distinct order_total 
from cte b 
where a.order_id = b.order_id);

select * from orders;

alter table orders
add column grand_total float;

update orders a
set a.grand_total = (select order_total from (select distinct b.order_id, sum(b.total_price) as order_total
from orders b
where a.order_id=b.order_id)
);
update orders a set grand_total = sum(total_price) over (partition by order_id order by null);
select avg(sum(total_price))/avg(order_id)
from orders;
--------------------------------------------------------------------------------------------------------

## best and worst selling pizzas
select pizza_name, count(pizza_id) as sold
from pizzas
group by 1
order by 2 desc;

--------------------------------------------------------------------------------------------------------

## which part of the nation is getting more customers
select ZIPCODE, count(ZIPCODE) as density, state
from customers
group by 1, 3
order by 2 desc;
--------------------------------------------------------------------------------------------------------
