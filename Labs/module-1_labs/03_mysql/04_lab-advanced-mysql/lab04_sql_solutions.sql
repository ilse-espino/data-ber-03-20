-- Challenge 1 - Most Profiting Authors
-- Step 1: Calculate the royalties of each sales for each author

-- titleauthor has royaltyper and title_id
-- authors has au_id
-- titles has the price of the book and royalty
-- sales has the quantity of books sold

SELECT
	t.title_id,
    a.au_id,
    t.price * s.qty * t.royalty * ta.royaltyper / 10000 AS ROYALTY
FROM titles t
	INNER JOIN titleauthor ta
    ON t.title_id=ta.title_id
    INNER JOIN authors a
    ON ta.au_id=a.au_id
    INNER JOIN sales s
    ON t.title_id=s.title_id;

-- some titles appear more than once for each author, a title can have more than one sales.
-- Step 2: Aggregate the total royalties for each title for each author

WITH royalties AS (
	SELECT
		t.title_id AS title_id,
		a.au_id AS au_id,
		t.price * s.qty * t.royalty * ta.royaltyper / 10000 AS ROYALTY
	FROM titles t
		INNER JOIN titleauthor ta
		ON t.title_id=ta.title_id
		INNER JOIN authors a
		ON ta.au_id=a.au_id
		INNER JOIN sales s
		ON t.title_id=s.title_id)
SELECT
	title_id,
    au_id,
    sum(ROYALTY)
FROM royalties
GROUP BY au_id, title_id;

-- Step 3: Calculate the total profits of each author

WITH royalties AS (
	SELECT
		t.title_id AS title_id,
		a.au_id AS au_id,
		t.price * s.qty * t.royalty * ta.royaltyper / 10000 AS ROYALTY
	FROM titles t
		INNER JOIN titleauthor ta
		ON t.title_id=ta.title_id
		INNER JOIN authors a
		ON ta.au_id=a.au_id
		INNER JOIN sales s
		ON t.title_id=s.title_id),
royalties_per_author AS (
	SELECT
		title_id,
		au_id,
		sum(ROYALTY) AS total_royalties
	FROM royalties
	GROUP BY au_id, title_id)


-- Final solution

SELECT
	au_id AS 'AUTHOR ID',
    au_lname AS 'LAST NAME',
    au_fname AS 'FIRST NAME',
    sum(advance + ROYALTIES) as 'PROFITS'
FROM (
	SELECT title_id, au_id, au_lname, au_fname, ADVANCE, sum(ROYALTIES) as ROYALTIES
		FROM (
			SELECT
					t.title_id, a.au_id, a.au_lname, a.au_fname, t.price * s.qty * t.royalty * ta.royaltyper / 10000 AS ROYALTIES, t.advance*ta.royaltyper/100 AS ADVANCE
				FROM titles t
					INNER JOIN titleauthor ta ON t.title_id=ta.title_id
					INNER JOIN authors a ON ta.au_id=a.au_id
					INNER JOIN sales s ON t.title_id=s.title_id) as table_1
		GROUP BY au_id, title_id) AS table_2
GROUP BY au_id
ORDER BY PROFITS DESC
LIMIT 3;

-- Alternative solution
WITH royalties_per_title AS (
	SELECT
		t.title_id AS title_id,
		t.advance,
		t.price * s.qty * t.royalty * ta.royaltyper / 10000 AS ROYALTY
	FROM titles t
		INNER JOIN titleauthor ta
		ON t.title_id=ta.title_id
		INNER JOIN authors a
		ON ta.au_id=a.au_id
		INNER JOIN sales s
		ON t.title_id=s.title_id)
					

-- LAB SOLUTION
select au_id as "AUTHOR ID", au_lname as "LAST NAME", au_fname as "FIRST NAME", sum(advance + ROYALTIES) as PROFITS from (
	select title_id, au_id, au_lname, au_fname, advance, sum(ROYALTIES) as ROYALTIES from (
		select t.title_id, t.price, t.advance * (ta.royaltyper / 100) as advance, t.royalty, s.qty, a.au_id, au_lname, au_fname, ta.royaltyper, (t.price * s.qty * t.royalty * ta.royaltyper / 10000) as ROYALTIES
		from titles t
		inner join sales s on s.title_id = t.title_id
		inner join titleauthor ta on ta.title_id = s.title_id
		inner join authors a on a.au_id = ta.au_id
	) as tmp
	group by au_id, title_id
) as tmp2
group by au_id
order by PROFITS desc
limit 3;

-- Alternative Solution

WITH profit_per_title AS (
    SELECT
        s.title_id,
        t.advance,
        t.price * (t.royalty / 100) AS royalty_per_sale,
        SUM(s.qty)                  AS titles_sold
    FROM sales s
        JOIN titles t
        ON s.title_id = t.title_id
    GROUP BY 1,2,3)
SELECT
    t.au_id,
    a.au_lname,
    a.au_fname,
    SUM((ept.advance * (t.royaltyper / 100)) +
    (ept.royalty_per_sale * ept.titles_sold * (t.royaltyper / 100)))  AS profit
FROM titleauthor t
    JOIN profit_per_title ept
    ON t.title_id = ept.title_id
    JOIN authors a
    ON t.au_id = a.au_id
GROUP BY 1,2,3
ORDER BY profit DESC;