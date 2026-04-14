
create table sales_data (
    order_id varchar(20),
    customer_id varchar(20),
    customer_name varchar(100),
    product_id varchar(20),
    product_name varchar(100),
    category varchar(50),
    order_date date,
    quantity int,
    price numeric(10,2),
    revenue numeric(12,2),
    region varchar(50),
    payment_method varchar(50)
);

-- =========================================
-- STEP 1: CHECK DATA
-- =========================================
select * from sales_data limit 20;

- Total rows before cleaning
select count(*) as total_rows_before from sales_data;



-- =========================================
-- STEP 2: NULL VALUES CHECK
-- =========================================
select *
from sales_data
where order_id is null
   or customer_id is null
   or customer_name is null
   or product_name is null
   or order_date is null;



-- =========================================
-- STEP 3: HANDLE NULL VALUES
-- =========================================
update sales_data
set customer_name = 'Unknown'
where customer_name is null;



-- =========================================
-- STEP 4: DUPLICATE CHECK
-- =========================================
select order_id, count(*) as cnt
from sales_data
group by order_id
having count(*) > 1;



-- =========================================
-- STEP 5: PREVIEW DUPLICATES
-- =========================================
select *
from (
    select *,
           row_number() over (partition by order_id order by order_date) as rn
    from sales_data
) t
where rn > 1;



-- =========================================
-- STEP 6: REMOVE DUPLICATES
-- =========================================
delete from sales_data
where ctid in (
    select ctid
    from (
        select ctid,
               row_number() over (partition by order_id order by order_date) as rn
        from sales_data
    ) t
    where rn > 1
);



-- =========================================
-- STEP 7: INVALID VALUES CHECK
-- =========================================
select *
from sales_data
where quantity <= 0 or price <= 0;



-- =========================================
-- STEP 8: FIX INVALID VALUES
-- =========================================
update sales_data
set quantity = 1
where quantity <= 0;

update sales_data
set price = 100
where price <= 0;



-- =========================================
-- STEP 9: REVENUE FIX
-- =========================================
update sales_data
set revenue = quantity * price;



-- =========================================
-- STEP 10: TEXT CLEANING
-- =========================================
update sales_data
set 
    customer_name = initcap(customer_name),
    product_name = initcap(product_name),
    category = initcap(category),
    region = initcap(region),
    payment_method = initcap(payment_method);



-- =========================================
-- STEP 11: DATE CHECK & FIX
-- =========================================
select *
from sales_data
where order_date > current_date
   or order_date < '2022-01-01';

update sales_data
set order_date = current_date
where order_date > current_date;



-- =========================================
-- STEP 12: ADD NEW COLUMNS
-- =========================================
alter table sales_data add column order_month text;

alter table sales_data add column order_year int;



-- =========================================
-- STEP 13: FILL NEW COLUMNS (FIXED)
-- =========================================
update sales_data
set 
    order_month = to_char(order_date, 'Month'),
    order_year = extract(year from order_date);



-- =========================================
-- STEP 14: FINAL CHECK
-- =========================================
select count(*) as total_rows_after from sales_data;

select * from sales_data limit 20;

SELECT * FROM sales_data;

