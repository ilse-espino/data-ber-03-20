    
-- Challenge 1 - Who Have Published What At Where?
SELECT
	authors.au_id 		AS AUTHOR_ID,
    authors.au_lname 	AS LAST_NAME,
    authors.au_fname	AS FIRST_NAME,
	titles.title 		AS TITLE,
    publishers.pub_name AS PUBLISHER
FROM publications.authors
-- adding title_id by au_id from tables titleauthor and authors
INNER JOIN publications.titleauthor ON authors.au_id=titleauthor.au_id
-- adding titles by title_id from tables titleauthor and titles
INNER JOIN publications.titles ON titleauthor.title_id=titles.title_id
-- adding publisher by pub_id from tables titles and publishers
INNER JOIN publications.publishers ON titles.pub_id=publishers.pub_id
ORDER BY AUTHOR_ID, PUBLISHER DESC;

-- Example of join
SELECT
	titleauthor.title_id,
    titles.title AS TITLE
FROM publications.titles
INNER JOIN publications.titleauthor
ON titleauthor.title_id=titles.title_id;

SELECT
	count(*)
FROM publications.titleauthor;

-- Challenge 2 - Who Have Published How Many At Where?

SELECT
	authors.au_id 		AS AUTHOR_ID,
    authors.au_lname 	AS LAST_NAME,
    authors.au_fname	AS FIRST_NAME,
    publishers.pub_name AS PUBLISHER,
    COUNT(*) 			AS TITLE_COUNT
FROM publications.authors
-- adding table_id by au_id from tables titleauthor and authors
INNER JOIN publications.titleauthor ON authors.au_id=titleauthor.au_id
-- adding titles by title_id from tables titleauthor and titles
INNER JOIN publications.titles ON titleauthor.title_id=titles.title_id
-- adding publisher by pub_id from tables titles and publishers
INNER JOIN publications.publishers ON titles.pub_id=publishers.pub_id
GROUP BY AUTHOR_ID, PUBLISHER
ORDER BY TITLE_COUNT DESC, AUTHOR_ID DESC;

SELECT COUNT(*) FROM publications.titleauthor;

-- Challenge 3 - Best Selling Authors
SELECT
	authors.au_id 		AS AUTHOR_ID,
    authors.au_lname 	AS LAST_NAME,
    authors.au_fname	AS FIRST_NAME,
    sum(sales.qty)		AS TOTAL
FROM publications.authors
INNER JOIN publications.titleauthor ON authors.au_id=titleauthor.au_id
INNER JOIN publications.sales ON titleauthor.title_id=sales.title_id
GROUP BY AUTHOR_ID
ORDER BY TOTAL DESC
LIMIT 3;

SELECT *
FROM publications.titles;

SELECT *
FROM publications.sales;

-- Challenge 4 - Best Selling Authors Ranking
SELECT
	authors.au_id 		AS AUTHOR_ID,
    authors.au_lname 	AS LAST_NAME,
    authors.au_fname	AS FIRST_NAME,
    IFNULL(sum(sales.qty),0) 		AS TOTAL
FROM publications.authors
-- using left join to add all the title_id
LEFT JOIN publications.titleauthor ON authors.au_id=titleauthor.au_id
LEFT JOIN publications.sales ON titleauthor.title_id=sales.title_id
GROUP BY AUTHOR_ID
ORDER BY TOTAL DESC;

-- Bonus Challenge - Most Profiting Authors
SELECT *
FROM publications.titles;

SELECT *
FROM publications.titleauthor;

SELECT *
FROM publications.roysched;

SELECT
	authors.au_id 																	AS AUTHOR_ID,
    authors.au_lname 																AS LAST_NAME,
    authors.au_fname																AS FIRST_NAME,
    sum(titles.advance + titles.price*sales.qty*titles.royalty*titleauthor.royaltyper/10000)			AS PROFIT
FROM publications.authors
-- using left join to add all the title_id
INNER JOIN publications.titleauthor ON authors.au_id=titleauthor.au_id
INNER JOIN publications.titles ON titleauthor.title_id=titles.title_id
INNER JOIN publications.sales ON titleauthor.title_id=titles.title_id
GROUP BY AUTHOR_ID
ORDER BY PROFIT DESC
LIMIT 3;

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

SELECT *
FROM sales;