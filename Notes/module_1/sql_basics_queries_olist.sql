/*
-- Selecting a sample
Clauses:
-SELECT
-FROM
-LIMIT
*/
/*
-- All of these are the same
SELECT * 
FROM olist.customers;
SELECT * FROM olist.customers;
seLecT * fRoM olist.customers;
*/
SELECT * 
FROM olist.customers
LIMIT 100;

-- Selecting columns
SELECT 
	customer_id, 
	customer_zip_code_prefix,
    customer_state
FROM olist.customers
LIMIT 100;

-- Sorting
SELECT *
FROM olist.orders
ORDER BY order_purchase_timestamp -- Ascending order  (default)
LIMIT 1000;

SELECT 
	order_id,
    customer_id,
    order_status,
    order_purchase_timestamp
FROM olist.orders
ORDER BY order_purchase_timestamp DESC -- Descending order
LIMIT 1000;

SELECT 
	order_id 		AS order_identifier,
    customer_id 	AS customer_identifier,
    order_status 	AS order_status_string
FROM olist.orders
ORDER BY order_purchase_timestamp DESC
LIMIT 1000;

-- Selecting rows
-- Select orders placed in Feb 2018
SELECT *
FROM olist.orders
WHERE order_purchase_timestamp >= '2018-02-01'
	AND order_purchase_timestamp < '2018-03-01'
LIMIT 1000;

SELECT *
FROM olist.customers
WHERE customer_state = 'BA'
LIMIT 1000;

SELECT *
FROM olist.customers
WHERE customer_state = 'BA'
	AND customer_city = 'salvador'
    AND customer_id LIKE 'a%'
LIMIT 1000;

SELECT *
FROM olist.customers
WHERE (customer_state = 'BA'
	OR customer_state ='GO')
    AND customer_id LIKE 'a%'
LIMIT 1000;

SELECT *
FROM olist.customers
WHERE customer_state IN ('BA', 'GO')
    AND customer_id LIKE 'a%'
LIMIT 1000;

-- Column transformations

-- Add a new column that states in which price category a product is
SELECT 
	order_id,
    product_id,
    price,
    IF (price < 100,  'cheap', 'expensive') AS price_category
FROM olist.order_items
LIMIT 1000;

SELECT 
	order_id,
    product_id,
    price,
    IF (price < 100,  'cheap', IF (price < 350, 'medium', 'expensive')) AS price_category
FROM olist.order_items
LIMIT 1000;

SELECT 
	order_id,
    product_id,
    price,
    CASE
		WHEN price < 100 THEN 'cheap'
        WHEN price < 350 THEN 'medium'
        ELSE 'expensive'
	END									AS price_category
FROM olist.order_items
LIMIT 1000;

SELECT
	order_id,
	product_id
    price,
    freight_value,
    price + freight_value AS total_volume
FROM olist.order_items;

-- Example: orders and order_items
SELECT *
FROM olist.orders
LIMIT 10; 

SELECT *
FROM olist.order_items
WHERE order_id = 'e481f51cbdc54678b7cc49136f2d6af7';

SELECT *
FROM olist.products
WHERE product_id = '87285b34884572647811a353c7ac498a';

-- Deduplication
SELECT *
FROM olist.order_items
LIMIT 1000;

SELECT *
FROM olist.order_items
WHERE DATE(shipping_limit_date) = '2017-05-17';

-- deduplicating using SELECT DISTINCT
SELECT
	seller_id
FROM olist.order_items
WHERE DATE(shipping_limit_date) = '2017-05-17';

SELECT distinct
	seller_id
FROM olist.order_items
WHERE DATE(shipping_limit_date) = '2017-05-17';
-- equivalent
SELECT
	seller_id
FROM olist.order_items
WHERE DATE(shipping_limit_date) = '2017-05-17'
GROUP BY seller_id;

-- aggregate functions*

SELECT
	count(*) 					AS no_of_rows,
    count(DISTINCT seller_id)   AS unique_sellers,
    count(product_id) 			AS products
FROM olist.order_items;

-- group by
SELECT
	DATE(shipping_limit_date),
    COUNT(*)					AS order_items
FROM olist.order_items
GROUP BY DATE(shipping_limit_date)
ORDER BY DATE(shipping_limit_date)
LIMIT 200;

-- top 10 sellers
/*
| seller id | no_of_items | total_revenue |
|-----------|-------------|---------------|
|xyz        |2353         |124135036      |
...
*/
SELECT 
	seller_id,
    count(*)	AS no_of_items,
    SUM(price)	AS total_revenue
FROM olist.order_items
GROUP BY seller_id
ORDER BY total_revenue DESC
LIMIT 10;

-- top 10 prodcuts by quantity
SELECT
	product_id,
    count(*)	AS quantity
FROM olist.order_items
GROUP BY product_id
ORDER BY (quantity) DESC
LIMIT 10;

-- for each day how many items did each seller sell
/*
| date id   | seller_id   | no_items |
|-----------|-------------|----------|
|2018-01-01 |xyz          |56        |
...
*/
SELECT
	DATE(shipping_limit_date)	AS date_id,
    seller_id,
    COUNT(*)					AS items_sold
FROM olist.order_items
GROUP BY
	DATE(shipping_limit_date),
    seller_id
ORDER BY
	seller_id,
    date_id;