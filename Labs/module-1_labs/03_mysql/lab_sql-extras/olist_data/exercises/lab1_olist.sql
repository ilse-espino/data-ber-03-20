-- 1. From the order_items table, find the price of the highest priced order item and lowest price order item.
SELECT
	max(price) AS max,
	min(price) AS min
FROM olist.order_items;

-- 2. From the order_items table, what is range of the shipping_limit_date of the orders?
SELECT 
	max(shipping_limit_date),
    min(shipping_limit_date)
FROm olist.order_items;

-- 3. From the customers table, find the 3 states with the greatest number of customers.
SELECT
	count(customer_id),
    customer_state
FROM olist.customers
GROUP BY customer_state
ORDER BY count(customer_id) DESC
LIMIT 3;


-- 4. From the customers table, within the state with the greatest number of customers, find the 3 cities with the greatest number of customers.
SELECT
	customer_city,
    count(customer_id)
FROM olist.customers
WHERE customer_state = 'SP'
GROUP BY customer_city
ORDER BY count(customer_id) DESC
LIMIT 3;

-- other solution
SELECT
	customer_city,
    count(customer_id)
FROM olist.customers
WHERE customer_state = (SELECT
							customer_state
						FROM olist.customers
						GROUP BY customer_state
						ORDER BY count(customer_id) DESC
						LIMIT 1)
GROUP BY customer_city
ORDER BY count(customer_id) DESC
LIMIT 3;

-- other solution
WITH top_state AS (
	SELECT
		customer_state
	FROM olist.customers
	GROUP BY customer_state
	ORDER BY count(customer_id) DESC
	LIMIT 1)

SELECT
	customer_city,
    COUNT(*) 	AS customers
FROM olist.customers c
	INNER JOIN top_state ts
    ON c.customer_state=ts.customer_state
GROUP BY customer_city
ORDER BY customers DESC
LIMIT 3;

-- LAB SOLUTION
SELECT
    customer_state,
    customer_city, COUNT(customer_city)
FROM olist.customers
WHERE customer_state = 'SP'
GROUP BY customer_state,
         customer_city
ORDER BY COUNT(customer_city) DESC
LIMIT 3;

-- 5. From the closed_deals table, how many distinct business segments are there (not including null)?
SELECT 
	count(DISTINCT (business_segment))
FROM olist.closed_deals;

-- 6. From the closed_deals table, sum the declared_monthly_revenue for duplicate row values in business_segment and find the 3 business segments with the highest declared monthly revenue 
-- (of those that declared revenue).
SELECT 
	business_segment,
    sum(declared_monthly_revenue)
FROM olist.closed_deals
GROUP BY (business_segment)
ORDER BY sum(declared_monthly_revenue) DESC;

-- 7. From the order_reviews table, find the total number of distinct review score values.
SELECT 
	count(DISTINCT review_score)
FROm olist.order_reviews;

-- 8. In the order_reviews table, create a new column with a description that corresponds to each number category for each review score from 1 - 5.
SELECT 
    review_score,
    CASE
		WHEN review_score = 1 THEN 'extremely poor'
        WHEN review_score = 2 THEN 'poor'
        WHEN review_score = 3 THEN 'neutral'
        WHEN review_score = 4 THEN 'good'
        ELSE 'extremley good'
	END										AS review_description
FROm olist.order_reviews
ORDER BY review_score DESC
LIMIT 100;

-- 9. From the order_reviews table, find the review score occurring most frequently and how many times it occurs.
SELECT
	review_score,
    count(review_score) AS value_ocurrance
FROM olist.order_reviews
GROUP BY review_score
ORDER BY value_ocurrance DESC
LIMIT 1;