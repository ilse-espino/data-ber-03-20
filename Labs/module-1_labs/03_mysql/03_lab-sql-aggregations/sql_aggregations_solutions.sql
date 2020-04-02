-- Assume that any _id columns are incremental, meaning that higher ids always occured after lower ids. For example, a client with a higher client_id joined the bank after a client with a lower client_id.

-- 1. From the client table, of all districts with a district_id lower than 10, how many clients are from each district_id? Show the results sorted by district_id in ascending order.
USE bank;

SELECT
	DISTINCT district_id AS district,
    COUNT(client_id)
FROM bank.client
GROUP BY district
ORDER BY district
LIMIT 9;

SELECT
	district_id,
    COUNT(client_id)
FROM bank.client
GROUP BY district_id
ORDER BY district_id
LIMIT 9;

-- 2. From the card table, how many cards exist for each type? Rank the result starting with the most frequent type.

SELECT
	type,
    COUNT(card_id)
FROM card
GROUP BY type;

-- 3. Using the loan table, print the top 10 account_ids based on the sum of all of their loan amounts.

SELECT
	account_id,
    sum(amount) AS total_loan_amount
FROM loan
GROUP BY account_id
ORDER BY total_loan_amount DESC
LIMIT 10;

-- 4. From the loan table, retrieve the number of loans issued for each day, before (excl) 930907, ordered by date in descending order

SELECT
	date,
    count(*) AS number_of_loans
FROM loan
WHERE date < 930907
GROUP BY date
ORDER BY date DESC;

-- 5. From the loan table, for each day in December 1997, count the number of loans issued for each unique loan duration, ordered by date and duration, both in ascending order.
-- You can ignore days without any loans in your output.
-- DATE = YYMMDD

SELECT
	date,
    duration,
    count(*) AS no_loans   
FROM loan
WHERE date > 971200
GROUP BY date, duration
ORDER BY date, duration;

-- 6. From the trans table, for account_id 396, sum the amount of transactions for each type (VYDAJ = Outgoing, PRIJEM = Incoming).
-- Your output should have the account_id, the type and the sum of amount, named as total_amount. Sort alphabetically by type.

SELECT
	account_id,
    type,
    sum(amount) AS sum_amount
FROM trans
WHERE account_id = 396
GROUP BY type
ORDER BY type;

-- 7. From the previous output, translate the values for type to English, rename the column to transaction_type, round total_amount down to an integer
SELECT
	account_id,
    CASE
		WHEN type = 'PRIJEM' THEN 'INCOMING'
        WHEN type = 'VYDAJ' THEN 'OUTGOING'
	END 									AS transaction_type,
    FLOOR(SUM(amount))						AS total_amount
FROM trans
WHERE account_id = 396
GROUP BY type
ORDER BY type;

-- 8. From the previous result, modify you query so that it returns only one row, with a column for incoming amount, outgoing amount and the difference
WITH incoming_amount AS (
	SELECT
		account_id,
        FLOOR(sum(amount)) AS i_amount
	FROM trans
    WHERE type = 'PRIJEM'
		AND account_id = 396),
outgoing_amount AS(
	SELECT
		account_id,
        FLOOR(sum(amount)) AS o_amount
	FROM trans
    WHERE type = 'VYDAJ'
		AND account_id = 396)
SELECT
	ia.account_id,
    ia.i_amount AS incoming_amount,
    oa.o_amount AS outgoing_amount,
    ia.i_amount - oa.o_amount AS difference    
FROM incoming_amount ia
	INNER JOIN outgoing_amount oa
    ON oa.account_id = ia.account_id;

-- 9. Continuing with the previous example, rank the top 10 account_ids based on their difference

WITH incoming_amount_customers AS (
	SELECT
		account_id,
		type,
		FLOOR(sum(amount)) AS incoming_amount
	FROM trans
	WHERE type = 'PRIJEM'
	GROUP BY account_id),
outgoing_amount_customers AS (
	SELECT
		account_id,
		type,
		FLOOR(sum(amount)) AS outgoing_amount
	FROM trans
	WHERE type = 'VYDAJ'
	GROUP BY account_id)
SELECT
	t.account_id,
    iac.incoming_amount - oac.outgoing_amount AS difference
FROM trans t
	INNER JOIN incoming_amount_customers iac
    ON t.account_id=iac.account_id
    INNER JOIN outgoing_amount_customers oac
    ON t.account_id=oac.account_id
GROUP BY account_id
ORDER BY difference DESC;
