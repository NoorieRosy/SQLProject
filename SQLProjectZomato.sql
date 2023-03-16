Use sales;
drop table if exists goldusers_signup;
CREATE TABLE goldusers_signup(userid integer,gold_signup_date date); 

INSERT INTO goldusers_signup(userid,gold_signup_date) 
 VALUES (1,'2017-09-22'), (3,'2017-04-21');

drop table if exists users;
CREATE TABLE users(userid integer,signup_date date); 

INSERT INTO users(userid,signup_date) 
 VALUES (1,'2014-09-02'),
(2,'2015-01-15'),
(3,'2014-04-11');

drop table if exists sales;
CREATE TABLE sales(userid integer,created_date date,product_id integer); 

INSERT INTO sales(userid,created_date,product_id) 
 VALUES (1,'2017-04-19',2),
(3,'2019-12-18',1),
(2,'2020-07-20',3),
(1,'2019-10-23',2),
(1,'2018-03-19',3),
(3,'2016-12-20',2),
(1,'2016-11-09',1),
(1,'2016-05-20',3),
(2,'2017-09-24',1),
(1,'2017-03-11',2),
(1,'2016-03-11',1),
(3,'2016-11-10',1),
(3,'2017-12-07',2),
(3,'2016-12-15',2),
(2,'2017-11-08',2),
(2,'2018-09-10',3);


drop table if exists product;
CREATE TABLE product(product_id integer,product_name text,price integer); 

INSERT INTO product(product_id,product_name,price) 
 VALUES
(1,'p1',980),
(2,'p2',870),
(3,'p3',330);

select * from sales;
select * from product;
select * from goldusers_signup;
select * from users;

-- What is the total amount each customer spent on Zomato?

Select a.userid, sum(b.price) as total_price_sum
from sales a
inner join
product b on a.product_id = b.product_id
group by a.userid;

-- How many days does each customer visited Zomato?

Select userid, count(distinct created_date) as unique_dates
from sales
group by userid;

-- What was the first product purchased by each customer?

Select * from
(Select *, rank() over(partition by userid order by created_date ) rnk from sales) a where rnk = 1;


/*-- What is the most purchased item on the menu and how many times was it purchashed by all the customers?
-- 2nd product was purchased 7 times and 1st user had bought it 3 times and similarly others */

Select userid, count(product_id) as cnt from sales where product_id = 
(Select product_id from sales group by product_id order by count(product_id) desc limit 1)
group by userid order by userid;

-- To count the number of purchase of an item
Select product_id, count(product_id) as cnt from sales group by product_id order by count(product_id) desc limit 1;

-- Which item was most popular among each customer?

Select * from
(Select *, rank() over(partition by userid order by cnt desc) rnk from
(select userid, product_id, count(product_id) as cnt from sales group by userid, product_id) a)b
where rnk = 1;

-- Which item was purchased first after they become a gold member?

select * from
(Select c.*, rank() over(partition by userid order by created_date ) rnk from
(Select a.userid, a.created_date, a.product_id, b.gold_signup_date from sales a
Inner join
goldusers_signup b on a.userid = b.userid and created_date >= gold_signup_date) c)d 
where rnk = 1;

-- What items were purchased just before the customer became a member?

select * from
(Select c.*, rank() over(partition by userid order by created_date desc ) rnk from
(Select a.userid, a.created_date, a.product_id, b.gold_signup_date from sales a
Inner join
goldusers_signup b on a.userid = b.userid and created_date <= gold_signup_date) c)d 
where rnk = 1;

-- What is total amount and order spent by each member before becoming a member?

Select userid, count(created_date) as order_purchased, sum(price) as total_amt_spent from
(Select c.*, d.price from
(Select a.userid, a.created_date, a.product_id, b.gold_signup_date from sales a
Inner join
goldusers_signup b on a.userid = b.userid and created_date <= gold_signup_date) c 
Inner Join
product d on c.product_id = d.product_id) e
group by userid order by userid
;

/*-- If buying each product generate points. eg. 5rs = 2 zomato points and product have different purchasing point.
 for ex. p1 5rs= 1 zomato point, p2 10rs= 5 zomato point, p1 5rs= 1 zomato point, 2rs = 1 zomato points
 calculate point collected by each customer and for which prodoct most points has been given till now.
 
 in the next query...to calculate the amount we are taking eg. 5rs = 2 zomato points so 1 zomato point = 2.5rs
 and we are multiplying the sum by 2.5*/
 

-- total points earned
Select userid, sum(total_zomato_points) as total_points_earns from 
(Select e.*, round(amt/points) as total_zomato_points from
(SELECT 
    d.*,
    CASE
        WHEN product_id = 1 THEN 5
        WHEN product_id = 2 THEN 2
        WHEN product_id = 3 THEN 5
        ELSE 0
    END AS points
FROM
    (SELECT 
        c.userid, c.product_id, SUM(price) AS amt
    FROM
        (SELECT 
        a.*, b.price
    FROM
        sales a
    INNER JOIN product b ON a.product_id = b.product_id) c
    GROUP BY product_id , userid) d) e) f group by userid order by userid;

-- max points earned
Select product_id, sum(total_zomato_points) as max_points_earns from 
(Select e.*, round(amt/points) as total_zomato_points from
(SELECT 
    d.*,
    CASE
        WHEN product_id = 1 THEN 5
        WHEN product_id = 2 THEN 2
        WHEN product_id = 3 THEN 5
        ELSE 0
    END AS points
FROM
    (SELECT 
        c.userid, c.product_id, SUM(price) AS amt
    FROM
        (SELECT 
        a.*, b.price
    FROM
        sales a
    INNER JOIN product b ON a.product_id = b.product_id) c
    GROUP BY userid , product_id) d) e) f group by product_id order by product_id;
    

-- total cashback    
Select userid, sum(total_zomato_points)*2.5 as total_money_earns from 
(Select e.*, round(amt/points) as total_zomato_points from
(SELECT 
    d.*,
    CASE
        WHEN product_id = 1 THEN 5
        WHEN product_id = 2 THEN 2
        WHEN product_id = 3 THEN 5
        ELSE 0
    END AS points
FROM
    (SELECT 
        c.userid, c.product_id, SUM(price) AS amt
    FROM
        (SELECT 
        a.*, b.price
    FROM
        sales a
    INNER JOIN product b ON a.product_id = b.product_id) c
    GROUP BY product_id , userid) d) e) f group by userid order by userid;
    
    
/*--  In the first 1 year after the customer joins the gold program ( including their join data) irrespective of what the customer has purchased,
they earned 5 zomato points for every 10rs spent. Who earned more - 1 or 3? and what was their earning point in the first year? 
1 zp = 2rs
0.5 zp = 1rs*/

select c.*, d.price*0.5 as total_points_earned from
(Select a.userid, a.created_date, a.product_id, b.gold_signup_date from sales a
Inner join
goldusers_signup b on a.userid = b.userid and created_date >= gold_signup_date and created_date <= date_add(gold_signup_date, interval 365 day))c
Inner join
product d on c.product_id = d.product_id;

-- Rank all the transaction of the customer

select *, rank() over(partition by userid order by created_date) as rnk from sales;

-- Rank all the transaction for each member, whenever they are zomato gold member for every non gold member, transaction mark as NA.

select e.*, case when rnk = 0 then 'NA' else rnk end as rnkk from
(
	Select c.*, case when gold_signup_date is null then 0 else rank() over(partition by userid order by created_date desc) end as rnk from
    (
		Select a.userid, a.created_date, a.product_id, b.gold_signup_date from sales a
        Left join
        goldusers_signup b on a.userid = b.userid
        and created_date >= gold_signup_date) c)e;
 